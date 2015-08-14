#include <stdio.h>
#include "defs.h"
#include "ethernet.h"
#include "utils.h"
#include "arp.h"
#include "ip.h"
#include "udp.h"
#include <trap.h>
#include <intr.h>

int MAC_ADDR[6] = {0xf0, 0xde, 0xf1, 0x44, 0x55, 0x66};
int ethernet_rx_data[2048];
int ethernet_rx_len;
int ethernet_tx_data[2048];
int ethernet_tx_len;

int fixed_data[8] = {'A', 'M', 'D', 'G', 'A', 'M', 'D', 'G'};

unsigned int ethernet_read(unsigned int addr) {
    *(unsigned int *)(ENET_IO_ADDR) = addr;
    nop();nop();nop();
    return *(unsigned int *)(ENET_DATA_ADDR);
}

void ethernet_write(unsigned int addr, unsigned int data) {
    *(unsigned int *)(ENET_IO_ADDR) = addr;
    nop();
    *(unsigned int *)(ENET_DATA_ADDR) = data;
    nop();
}

void ethernet_init() {
    cprintf("Initializing network...");
    ethernet_powerup();
    ethernet_reset();
    ethernet_phy_reset();
	int i;
    // set MAC address
    for(i = 0 ; i < 6 ; i += 1)
        ethernet_write(DM9000_REG_PAR0 + i, MAC_ADDR[i]);
    // initialize hash table
    for(i = 0 ; i < 8 ; i += 1)
        ethernet_write(DM9000_REG_MAR0 + i, 0x00);
    // accept broadcast
    ethernet_write(DM9000_REG_MAR7, 0x80);
    // enable pointer auto return function
    ethernet_write(DM9000_REG_IMR, IMR_PAR);
    // clear NSR status
    ethernet_write(DM9000_REG_NSR, NSR_WAKEST | NSR_TX2END | NSR_TX1END);
    // clear interrupt flag
    ethernet_write(DM9000_REG_ISR, 
        ISR_UDRUN | ISR_ROO | ISR_ROS | ISR_PT | ISR_PR);
    
	// set connection mode
	//ethernet_phy_write(DM9000_PHY_REG_ANAR, 0x05e1);
	
	// enable interrupt (recv only)
    ethernet_write(DM9000_REG_IMR, IMR_PAR | IMR_PRI);
    // enable reciever
    ethernet_write(DM9000_REG_RCR,
        RCR_DIS_LONG | RCR_DIS_CRC | RCR_RXEN);
    // enable checksum calc
    ethernet_write(DM9000_REG_TCSCR,
        TCSCR_IPCSE);
    cprintf("Done\n");
    pic_enable(IRQ_ETH); //NB
}

int ethernet_check_iomode() {
    int val = ethernet_read(DM9000_REG_ISR) & ISR_IOMODE;
    if(val) return 8;
    return 16;
}
int ethernet_check_link() {
    return (ethernet_read(0x01) & 0x40) >> 6;
}
int ethernet_check_speed() {
    int val = ethernet_read(0x01) & 0x80;
    if(val == 0) return 100;
    return 10;
}
int ethernet_check_duplex() {
    return (ethernet_read(0x00) & 0x08) >> 3;
}

void ethernet_phy_write(int offset, int value) {
    ethernet_write(DM9000_REG_EPAR, offset | 0x40);
    ethernet_write(DM9000_REG_EPDRH, MSB(value));
    ethernet_write(DM9000_REG_EPDRL, LSB(value));

    ethernet_write(DM9000_REG_EPCR, EPCR_EPOS | EPCR_ERPRW);
    while(ethernet_read(DM9000_REG_EPCR) & EPCR_ERRE);
    delay_us(5);
    ethernet_write(DM9000_REG_EPCR, EPCR_EPOS);
}

int ethernet_phy_read(int offset) {
    ethernet_write(DM9000_REG_EPAR, offset | 0x40);
    ethernet_write(DM9000_REG_EPCR, EPCR_EPOS | EPCR_ERPRR);
    while(ethernet_read(DM9000_REG_EPCR) & EPCR_ERRE);

    ethernet_write(DM9000_REG_EPCR, EPCR_EPOS);
    delay_us(5);
    return (ethernet_read(DM9000_REG_EPDRH) << 8) | 
            ethernet_read(DM9000_REG_EPDRL);
}

void ethernet_powerup() {
    ethernet_write(DM9000_REG_GPR, 0x00);
    delay_ms(100);
}

void ethernet_reset() {
    ethernet_write(DM9000_REG_NCR, NCR_RST);
    while(ethernet_read(DM9000_REG_NCR) & NCR_RST);
}

void ethernet_phy_reset() {
    ethernet_phy_write(DM9000_PHY_REG_BMCR, BMCR_RST);
    while(ethernet_phy_read(DM9000_PHY_REG_BMCR) & BMCR_RST);
}


void ethernet_send() {

	int fail = 0;
	//intr_disable();
	do {
		// int is char
		// A dummy write
		cprintf("sending...\nlen = %d\n", ethernet_tx_len);
    
		// write length
		ethernet_write(DM9000_REG_TXPLH, MSB(ethernet_tx_len));
		ethernet_write(DM9000_REG_TXPLL, LSB(ethernet_tx_len));
		
		ethernet_write(DM9000_REG_MWCMDX, 0);
		// select reg
		//*(unsigned int *)(ENET_IO_ADDR) = DM9000_REG_MWCMD;
		nop(); nop();
		int i;
		for(i = 0 ; i < ethernet_tx_len ; i += 2){
			int val = ethernet_tx_data[i];
			if(i + 1 != ethernet_tx_len) val |= (ethernet_tx_data[i+1] << 8);
			//cprintf("%x ", val);
			//*(unsigned int *)(ENET_DATA_ADDR) = val;
			unsigned int memaddr = ethernet_read(DM9000_REG_MWRL);
			//cprintf("addr = %x \n", memaddr);
			ethernet_write(DM9000_REG_MWCMD, val);
			
			nop();
		}
		// write length
		ethernet_write(DM9000_REG_TXPLH, MSB(ethernet_tx_len));
		ethernet_write(DM9000_REG_TXPLL, LSB(ethernet_tx_len));
		// clear interrupt flag
		ethernet_write(DM9000_REG_ISR, ISR_PT);
		
		//cprintf("len h:%x l %x\n", ethernet_read(DM9000_REG_TXPLH), ethernet_read(DM9000_REG_TXPLL));
		
		// transfer data
		//ethernet_write(DM9000_REG_TCR, TCR_TXREQ);
		unsigned int tcr = ethernet_read(DM9000_REG_TCR);
		//cprintf("tcr = %x\n", tcr);
		ethernet_write(DM9000_REG_TCR, TCR_TXREQ | tcr);
		
		tcr = ethernet_read(DM9000_REG_TCR);
		//cprintf("\n tcr = %x, send finished.\n", tcr);
		//cprintf("len h: %x l: %x\n", ethernet_read(DM9000_REG_TXPLH), ethernet_read(DM9000_REG_TXPLL));
		
		while ((tcr & 1) == 1)
			tcr = ethernet_read(DM9000_REG_TCR);
		
		{
			int nsr = ethernet_read(DM9000_REG_NSR), tsr1 = ethernet_read(DM9000_REG_TSR1), tsr2 = ethernet_read(DM9000_REG_TSR2);
			cprintf("tx_status: %x\n", nsr);
			cprintf("tsr 1: %x\n", tsr1);
			cprintf("tsr 2: %x\n", tsr2);
			if ((nsr & 0x04) == 0x04) {
				if ((tsr1 & 0xfc) == 0x0) { 
					cprintf("send succeed!\n");
					fail = 0;
					//break;
				}
				else {
					cprintf("send failed!\n");
					fail = 1;
				}
			}
			else
				if ((tsr2 & 0xfc) == 0) {
					cprintf("send succeed!\n");
					fail = 0;
					//break;
				}
				else {
					cprintf("send failed!\n");
					fail = 1;
				}
					
					
		}
	} while (fail == 1);
	//pic_enable(IRQ_ETH);
	//intr_enable();
}

void ethernet_recv() {
	//cprintf("receive\n");
    // a dummy read
    ethernet_read(DM9000_REG_MRCMDX);
	
	/*ethernet_write(DM9000_REG_IMR, 0x80); //stop INT request
	ethernet_write(DM9000_REG_ISR, 0x0F); //clear ISR status
	ethernet_write(DM9000_REG_RCR, 0x00); //stop RX function*/
	
	// clear intrrupt
    //ethernet_write(DM9000_REG_ISR, ISR_PR);
	//disable receive interrupt
	//ethernet_write(DM9000_REG_IMR, 0);
	
	
    // select reg
    //*(unsigned int *)(ENET_IO_ADDR) = DM9000_REG_MRCMDX1;
    nop(); nop();
    //int status = LSB(*(unsigned int *)(ENET_DATA_ADDR));
	
	int status = ethernet_read(DM9000_REG_MRCMDX1);
	status = LSB(status);
	
	//cprintf("status: %x\n", status);
	
    if(status != 0x01){
        ethernet_rx_len = -1;
        return;
    }
    //*(unsigned int *)(ENET_IO_ADDR) = DM9000_REG_MRCMD;
    //nop(); nop();
    //status = MSB(*(unsigned int *)(ENET_DATA_ADDR));
	
	status = MSB(ethernet_read(DM9000_REG_MRCMD));
	
    nop(); nop();
	
	//cprintf("status: %x\n", status);
	
	//ethernet_rx_len = -1;
	
    //ethernet_rx_len = *(unsigned int *)(ENET_DATA_ADDR);
	ethernet_rx_len = ethernet_read(DM9000_REG_MRCMD);
    nop(); nop();
    if(status & (RSR_LCS | RSR_RWTO | RSR_PLE | 
                 RSR_AE | RSR_CE | RSR_FOE)) {
        ethernet_rx_len = -1;
        return;
    }
	//cprintf("len = %d\n", ethernet_rx_len);
	unsigned int memaddrh = ethernet_read(DM9000_REG_MRRH);
	unsigned int memaddr = ethernet_read(DM9000_REG_MRRL);
	//cprintf("memaddr: %x%x\n", memaddrh, memaddr);
	
	int i;
    for(i = 0 ; i < ethernet_rx_len ; i += 2) {
        //int data = *(unsigned int *)(ENET_DATA_ADDR);
		unsigned int data = ethernet_read(DM9000_REG_MRCMD);
		//cprintf("data = %x ", data);
		//cprintf("%x ", data);
		memaddr = ethernet_read(DM9000_REG_MRRL);
		//cprintf("addr = %x \n", memaddr);
        ethernet_rx_data[i] = LSB(data);
        ethernet_rx_data[i+1] = MSB(data);
		
    }
    
	//is there more packets?
	ethernet_read(DM9000_REG_MRCMDX);
	status = ethernet_read(DM9000_REG_MRCMDX);
	status = LSB(status);
    if(status != 0x01) { //No more packets
		// clear intrrupt
		ethernet_write(DM9000_REG_ISR, ISR_PR);
	}
	
	//cprintf("\nrecv finished.\n");
	
	
	
}

void ethernet_set_tx(int * dst, int type) {
	cprintf("dst MAC: ");
	int i;
	for (i = 0; i < 6; i++) cprintf("%x ", dst[i]); 
	cprintf("\n");
	
    eth_memcpy(ethernet_tx_data + ETHERNET_DST_MAC, dst, 6);
    eth_memcpy(ethernet_tx_data + ETHERNET_SRC_MAC, MAC_ADDR, 6);
    ethernet_tx_data[12] = MSB(type);
    ethernet_tx_data[13] = LSB(type);
}

void ethernet_intr()
{
	//while(1)
	//{	
	//intr_disable();
	//cprintf("Receiving\n");
		ethernet_recv();
		//cprintf("Complete, len = %d\n", ethernet_rx_len);
		if(ethernet_rx_len == -1) return;
		int type = ethernet_rx_type;
		//cprintf("type = %x\n", type);
		if(type == ETHERNET_TYPE_ARP) {
		    //cprintf("arp handle\n");
			arp_handle();
		}	
		if(type == ETHERNET_TYPE_IP) {
			//cprintf("ip handle\n");
		    ip_handle();
			
			//int *data = 0;
			//udp_send_packet(fixed_data, 8);
		}
		//cprintf("intr finished.\n");
	//}
	//intr_enable();
}

