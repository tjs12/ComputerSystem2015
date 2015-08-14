#include "udp.h"
#include "ip.h"
#include "arp.h"
#include "ethernet.h"
#include "tcp.h"
#include "defs.h"
#include "utils.h"
#include <stdio.h>

int udp_src_port = 27015;
int udp_dst_port = 27015;

unsigned int udp_data[1024];
int udp_data_arrived = 0;
unsigned int udp_data_len;

void udp_send_packet(int *data, int len)
{
	int * packet = ethernet_tx_data + ETHERNET_HDR_LEN + IP_HDR_LEN;
	int2mem(packet + UDP_SRC_PORT, 2, udp_dst_port);
    int2mem(packet + UDP_DST_PORT, 2, udp_src_port);
	packet[UDP_LENGTH] = MSB(len + 8);
	packet[UDP_LENGTH + 1] = LSB(len + 8);
	packet[UDP_CHECKSUM] = 0;
	packet[UDP_CHECKSUM + 1] = 0;
	int i;
	for (i = 0; i < len; i++) 
		packet[UDP_DATA + i] = data[i];
	
	ip_send_packet(remote_mac, IP_PROTOCAL_UDP, len + 8);
    ethernet_tx_len = ETHERNET_HDR_LEN + IP_HDR_LEN + len + 8;
    ethernet_send();
}

void udp_handle(int len)
{
	int * data = ethernet_rx_data + ETHERNET_HDR_LEN + IP_HDR_LEN, i;
	for (i = 0; i < len - 8; i++) {
		cprintf("%c", data[i + UDP_DATA]);
		udp_data[i] = data[i + UDP_DATA];
	}
	cprintf("\n");
	udp_data_arrived = 1;
	udp_data_len = len - 8;
}

int get_udp_status()
{
	return udp_data_arrived;
}

unsigned int *get_udp_data()
{
	return udp_data;
}

unsigned int get_udp_data_len()
{
	return udp_data_len;
}

void set_udp_status(unsigned int val)
{
	udp_data_arrived = val;
}