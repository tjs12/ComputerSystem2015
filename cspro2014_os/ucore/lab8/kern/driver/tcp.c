#include <stdio.h>
#include <assert.h>
#include "tcp.h"
#include "ethernet.h"
#include "ip.h"
#include "arp.h"
#include "defs.h"
#include "utils.h"

#define WINDOW_SIZE 1000
#define INIT_SEQ 1001
#define TIMEOUT 30

#define MYDATA_LENGTH (1028/4)

int tcp_inited = 0;

char* pagedata = 
	"tring to transfer this message.";

int MYDATA[MYDATA_LENGTH * 4];

#define CHUNK_LEN 1000
#define LAST_CHUNK_POS ((MYDATA_LENGTH / CHUNK_LEN) * CHUNK_LEN)

int send_pos = 0;

int tcp_timeout = 0;

int tcp_src_port, tcp_dst_port;
int tcp_dst_addr[4] = {192, 168, 1, 1};
int tcp_src_addr[4] = {192, 168, 1, 233};
int tcp_ack = 0, tcp_seq = INIT_SEQ;
int tcp_state = TCP_CLOSED;

void tcp_request(){
    tcp_src_port = 1234;
    //tcp_dst_addr;
    tcp_dst_port = 4444;
    //tcp_ack = mem2int(data + TCP_SEQ, 4) + 1;

    tcp_seq = INIT_SEQ;

    tcp_state == TCP_SYNC_SEND;

    tcp_send_packet(TCP_FLAG_SYN,
                    0, 0);

    cprintf("send tcp......................\n");
    return;
}

void tcp_handle(int length) {

    int * data = ethernet_rx_data + ETHERNET_HDR_LEN + IP_HDR_LEN;
    if(tcp_state != TCP_CLOSED) tcp_timeout += 1;
    else tcp_timeout = 0;
    if(tcp_timeout == TIMEOUT) {
        tcp_timeout = 0;
        tcp_state = TCP_CLOSED;
    }

    //
    if((data[TCP_FLAGS] & TCP_FLAG_SYN) && (data[TCP_FLAGS] & TCP_FLAG_ACK )
       && (tcp_state == TCP_SYNC_SEND )) {
        tcp_src_port = mem2int(data + TCP_SRC_PORT, 2);
        tcp_dst_port = mem2int(data + TCP_DST_PORT, 2);
        eth_memcpy(tcp_src_addr, data - IP_HDR_LEN + IP_SRC, 4);
        eth_memcpy(tcp_dst_addr, data - IP_HDR_LEN + IP_DST, 4);
        tcp_ack = mem2int(data + TCP_SEQ, 4) + 1;
        tcp_seq = tcp_ack+1;
        tcp_state = TCP_ESTABLISHED;
        send_pos = 0;
        tcp_send_packet(TCP_FLAG_ACK,
                        0, 0);
        return;
    }

    // check
    if(tcp_src_port != mem2int(data + TCP_SRC_PORT, 2)
        || tcp_dst_port != mem2int(data + TCP_DST_PORT, 2)
        || eth_memcmp(data - IP_HDR_LEN + IP_DST, tcp_dst_addr, 4) != 0
        || eth_memcmp(data - IP_HDR_LEN + IP_SRC, tcp_src_addr, 4) != 0) {
        cprintf("unknown packet\n");
        return;
    }
    if(data[TCP_FLAGS] & TCP_FLAG_RST) {
        tcp_state = TCP_CLOSED;
        return;
    }


    //
    if(tcp_state == TCP_FIN_SENT) {
        tcp_seq = mem2int(data + TCP_ACK, 4);
        tcp_send_packet(TCP_FLAG_RST, 0, 0);
        tcp_state = TCP_CLOSED;
        return;
    }


    //

    if(tcp_state == TCP_ESTABLISHED) {
        tcp_ack = mem2int(data + TCP_SEQ, 4) + (length - TCP_HDR_LEN);
        tcp_seq = mem2int(data + TCP_ACK, 4);


        int pos = tcp_seq - (INIT_SEQ + 1);
        if(pos == 0 && length == TCP_HDR_LEN) return;
        
         if(pos == MYDATA_LENGTH) {
            tcp_send_packet(TCP_FLAG_FIN | TCP_FLAG_ACK, 0, 0);
            tcp_state = TCP_FIN_SENT;
            return;
        }
        int len = CHUNK_LEN;
        if(pos == LAST_CHUNK_POS)
            len = MYDATA_LENGTH - pos;
         

        data = data + TCP_HDR_LEN;

        int i;
        for ( i=0; i<length-TCP_HDR_LEN; i++){
            cprintf("%d\n",data[i]);
        }

        int flag = TCP_FLAG_ACK;
        tcp_send_packet(flag, 0, 0);
        tcp_state = TCP_FIN_SENT;
        return;
    }
}

void tcp_send_packet(int flags, int * data, int length) {
    int * packet = ethernet_tx_data + ETHERNET_HDR_LEN + IP_HDR_LEN;
    int2mem(packet + TCP_SRC_PORT, 2, tcp_dst_port);
    int2mem(packet + TCP_DST_PORT, 2, tcp_src_port);
    int2mem(packet + TCP_SEQ, 4, tcp_seq);
    int2mem(packet + TCP_ACK, 4, tcp_ack);
    packet[TCP_DATA_OFFSET] = 0x50;
    packet[TCP_FLAGS] = flags;
    packet[TCP_URGEN] = 0;
    packet[TCP_URGEN + 1] = 0;
    packet[TCP_CHECKSUM] = 0;
    packet[TCP_CHECKSUM + 1] = 0;
    int2mem(packet + TCP_WINDOW, 2, 1000);
    eth_memcpy(packet + TCP_DATA, data, length);
    // calc checksum
    int sum = 0;
    sum += mem2int(tcp_src_addr, 2) + mem2int(tcp_src_addr + 2, 2);
    sum += mem2int(tcp_dst_addr, 2) + mem2int(tcp_dst_addr + 2, 2);
    sum += IP_PROTOCAL_TCP;
    length += TCP_HDR_LEN;
    sum += length;
	int i;
    for(i = 0 ; i < length ; i += 2) {
        int val = (packet[i] << 8);
        if(i + 1 != length) val |= packet[i+1];
        sum += val;
    }
    sum = (sum >> 16) + (sum & 0xffff);
    sum = (sum >> 16) + (sum & 0xffff);
    sum = ~sum;
    packet[TCP_CHECKSUM] = MSB(sum);
    packet[TCP_CHECKSUM + 1] = LSB(sum);
    //ip_make_reply(IP_PROTOCAL_TCP, length);
	ip_send_packet(remote_mac, IP_PROTOCAL_TCP, length);
    ethernet_tx_len = ETHERNET_HDR_LEN + IP_HDR_LEN + length;
    ethernet_send();
}
