#include <defs.h>
#include <unistd.h>
#include <stdarg.h>
#include "syscall.h"
#include <stdio.h>

void udp_send_packet(int *data, int len)
{
	cprintf("sending packet, len = %d\n", len);
	sys_udp_send_packet(data, len);
}
int get_udp_status()
{
	return sys_get_udp_status;
}

unsigned int *get_udp_data()
{
	return sys_get_udp_data();
}

unsigned int get_udp_data_len()
{
	return sys_get_udp_data_len();
}

void set_udp_status(unsigned int val)
{
	sys_set_udp_status(val);
}

