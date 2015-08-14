#include "arp.h"
#include "tcp.h"
#include "utils.h"
#include <stdio.h>
#include <intr.h>

int IP_ADDR[4] = {192, 168, 1, 233};
int ARP_FIX_HDR[] = {
    0x00, 0x01, // ethernet
    0x08, 0x00, // IP
    0x06, 0x04, // mac/IP size
    0x00,       // high bit of type (hack)
};

int BROADCAST[6] = {
    0xff, 0xff,
    0xff, 0xff,
    0xff, 0xff
};

int DEFAULT[6] = {
    0x0, 0x0,
    0x0, 0x0,
    0x0, 0x0,
};

int remote_mac[6];

void arp_request(){
    ethernet_tx_len = ETHERNET_HDR_LEN + ARP_BODY_LEN;

    ethernet_set_tx(BROADCAST, ETHERNET_TYPE_ARP);

    int * buf = ethernet_tx_data + ETHERNET_HDR_LEN;
    eth_memcpy(buf, ARP_FIX_HDR, 6 + 1);
    buf[ARP_TYPE] = ARP_TYPE_REQUEST;
    eth_memcpy(buf + ARP_SENDER_MAC, MAC_ADDR, 6);
    eth_memcpy(buf + ARP_SENDER_IP, IP_ADDR, 4);
    eth_memcpy(buf + ARP_TARGET_MAC, DEFAULT, 6);
    eth_memcpy(buf + ARP_TARGET_IP,
               tcp_dst_addr, 4);
			   
	intr_disable();
    ethernet_send();
	intr_enable();
    //cprintf("send arp ...........................\n");
}

void arp_handle() {

    //cprintf("receive arp .............................\n");
    int * data = ethernet_rx_data + ETHERNET_HDR_LEN;
    if(data[ARP_TYPE] == ARP_TYPE_REPLY) {
        if(eth_memcmp(data + ARP_TARGET_IP, IP_ADDR, 4) != 0);
            return;

        int i=0;
        for (i=0; i<4; i++)
            cprintf("%d\n", *(data+ARP_SENDER_IP+i));
        //tcp_request();
		
		for (i = 0; i < 6; i++)
			remote_mac[i] = *(data+ARP_SENDER_MAC+i);
		
 
    }
	else if (data[ARP_TYPE] == ARP_TYPE_REQUEST && 
		     data[ARP_TARGET_IP] == IP_ADDR[0] &&
			 data[ARP_TARGET_IP + 1] == IP_ADDR[1] &&
			 data[ARP_TARGET_IP + 2] == IP_ADDR[2] &&
			 data[ARP_TARGET_IP + 3] == IP_ADDR[3]) 
	{
		ethernet_tx_len = ETHERNET_HDR_LEN + ARP_BODY_LEN;
        ethernet_set_tx(ethernet_rx_src, ETHERNET_TYPE_ARP);
		
        int * buf = ethernet_tx_data + ETHERNET_HDR_LEN;
		eth_memcpy(buf, ARP_FIX_HDR, 6 + 1);
		buf[ARP_TYPE] = ARP_TYPE_REPLY;
        eth_memcpy(buf + ARP_SENDER_MAC, MAC_ADDR, 6);
        eth_memcpy(buf + ARP_SENDER_IP, IP_ADDR, 4);
        eth_memcpy(buf + ARP_TARGET_MAC,
               data + ARP_SENDER_MAC, 6);
        eth_memcpy(buf + ARP_TARGET_IP,
               data + ARP_SENDER_IP, 4);
		
		cprintf("send arp response...\n");
		
        ethernet_send();
	}
	else if (data[ARP_TYPE] == ARP_TYPE_REQUEST && 
		     data[ARP_TARGET_IP] == data[ARP_SENDER_IP] &&
			 data[ARP_TARGET_IP + 1] == data[ARP_SENDER_IP + 1] &&
			 data[ARP_TARGET_IP + 2] == data[ARP_SENDER_IP + 2] &&
			 data[ARP_TARGET_IP + 3] == data[ARP_SENDER_IP + 3]) //Is gratuitous = true
	{
		if (data[ARP_TARGET_IP] ==  tcp_dst_addr[0] &&
			 data[ARP_TARGET_IP + 1] == tcp_dst_addr[1] &&
			 data[ARP_TARGET_IP + 2] == tcp_dst_addr[2] &&
			 data[ARP_TARGET_IP + 3] == tcp_dst_addr[3])
		{
			int i;
			for (i = 0; i < 6; i++)
				remote_mac[i] = *(data+ARP_SENDER_MAC+i);
			arp_request();
			tcp_request();
		}
	}
}
