#ifndef UDP_H
#define UDP_H


#define UDP_SRC_PORT 0
#define UDP_DST_PORT 2
#define UDP_LENGTH 4
#define UDP_CHECKSUM 6
#define UDP_DATA 8
#define TCP_HDR_LEN 8

extern int udp_src_port;
extern int udp_dst_port;

extern unsigned int udp_data[1024];
extern int udp_data_arrived;
extern unsigned int udp_data_len;

void udp_send_packet(int *data, int len);
int get_udp_status();
void set_udp_status(unsigned int val);
unsigned int *get_udp_data();
unsigned int get_udp_data_len();


#endif
