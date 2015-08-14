
#include "ip.h"
#include "ethernet.h"
#include "icmp.h"
#include "utils.h"
#include "defs.h"
#include "arp.h"
#include "tcp.h"
#include "udp.h"

void ip_handle() {
    int * data = ethernet_rx_data + ETHERNET_HDR_LEN;
    // not IPv4 or header is longer than 20bit
    if(data[IP_VERSION] != IP_VERSION_VAL)
        return;

	if (data[IP_DST] != IP_ADDR[0] || 
	    data[IP_DST + 1] != IP_ADDR[1] || 
		data[IP_DST + 2] != IP_ADDR[2] || 
		data[IP_DST + 3] != IP_ADDR[3]) {
		//cprintf("IP destination not correct.\n");
		return;
	}
	
	
    int length = (data[IP_TOTAL_LEN] << 8) | data[IP_TOTAL_LEN + 1];
    length -= 20; // ip header

    if(data[IP_PROTOCAL] == IP_PROTOCAL_ICMP)
        icmp_handle(length);
    else if(data[IP_PROTOCAL] == IP_PROTOCAL_TCP)
        tcp_handle(length);
	else if (data[IP_PROTOCAL] == IP_PROTOCAL_UDP) {
		//cprintf("udp\n");
		udp_handle(length);
	}
	else
		cprintf("unknown protocal %x\n", data[IP_PROTOCAL]);
}

void ip_make_reply(int proto, int length) {
    length += 20; // ip header
    ethernet_set_tx(ethernet_rx_src, ETHERNET_TYPE_IP);
    int * data = ethernet_tx_data + ETHERNET_HDR_LEN;
    data[IP_VERSION] = IP_VERSION_VAL;
    data[IP_TOTAL_LEN] = MSB(length);
    data[IP_TOTAL_LEN + 1] = LSB(length);
    data[IP_FLAGS] = 0;
    data[IP_FLAGS + 1] = 0;
    data[IP_TTL] = 64;
    data[IP_PROTOCAL] = proto;
    eth_memcpy(data + IP_SRC, IP_ADDR, 4);
    eth_memcpy(data + IP_DST, 
        tcp_dst_addr, 4);
}


void ip_send_packet(int * macdst, int proto, int length) {
    length += 20; // ip header
    ethernet_set_tx(macdst, ETHERNET_TYPE_IP);
    int * data = ethernet_tx_data + ETHERNET_HDR_LEN;
    data[IP_VERSION] = IP_VERSION_VAL;
    data[IP_TOTAL_LEN] = MSB(length);
    data[IP_TOTAL_LEN + 1] = LSB(length);
    data[IP_FLAGS] = 0;
    data[IP_FLAGS + 1] = 0;
    data[IP_TTL] = 64;
    data[IP_PROTOCAL] = proto;
    eth_memcpy(data + IP_SRC, IP_ADDR, 4);
    eth_memcpy(data + IP_DST, 
        tcp_dst_addr, 4);
}
