#include <stdio.h>
#include <udp.h>
#include <string.h>

#define printf(...)                     fprintf(1, __VA_ARGS__)
#define putc(c)                         printf("%c", c)


#define BUFSIZE                         4096
#define WHITESPACE                      " \t\r\n"

unsigned int file_buffer[2048], fsize = 0;//NB size and how to use
int *udp_data1 ;


char *
readline(const char *prompt) {
    static char buffer[BUFSIZE];
    if (prompt != NULL) {
        printf("%s", prompt);
    }
    int ret, i = 0;
    while (1) {
        char c;
        if ((ret = read(0, &c, sizeof(char))) < 0) {
            return NULL;
        }
        else if (ret == 0) {
            if (i > 0) {
                buffer[i] = '\0';
                break;
            }
            return NULL;
        }

        if (c == 3) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            putc(c);
            buffer[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
            putc(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
            putc(c);
            buffer[i] = '\0';
            break;
        }
    }
    return buffer;
}

int send_buffer[1024];

void send_request_file(char *filename)
{
	send_buffer[0] = 'r';
	int i = 0, len = 1;
	while (i < BUFSIZE && filename[i] != 0) {
		send_buffer[i + 1] = (int)filename[i];
		len++;
	}
	//send_buffer[i]
	udp_send_packet(send_buffer, len);
}

void send_len(int len)
{
	send_buffer[0] = 'l';
	send_buffer[1] = len & 0xff;
	send_buffer[2] = len >> 8;
	udp_send_packet(send_buffer, 3);
}

void send_OK()
{
	send_buffer[0] = 'o';
	udp_send_packet(send_buffer, 1);
}

void wait_recv()
{
	while (get_udp_status() == 0) ;
	set_udp_status(0);
}

int receive_len()
{
	while (1) {
		wait_recv();
		int *udp_data1 = get_udp_data();
		if (udp_data1[0] == 'l') {
			return udp_data1[1] + udp_data1[2] * 256;
		}
	}
}

int receive_OK()
{
	wait_recv();
	int *udp_data1 = get_udp_data();
	if (udp_data1[0] == 'o') 
		return 1;
	else
		return 0;
}

int receive_file()
{
	wait_recv();
	int *udp_data1 = get_udp_data();
	if (udp_data1[0] == 'f') {
		int i;
		for (i = 1; i < get_udp_data_len(); i++)
			file_buffer[fsize++] = udp_data1[i];
		return 1;
	}
	else
		return 0;
}

int main(int argc, char **argv) {
	char *server_file = readline("File on the server: ");
	cprintf("%s\n", server_file);
	send_request_file(server_file);
	
	int filelen = receive_len();
	cprintf("len: %d\n", filelen);
	send_len(filelen);
	//while (receive_OK() == 0);
	
	int succeed;
	do {
		succeed = receive_file();
		send_OK();
	} while (succeed);
	
	//write_to_disk;
	int i;
	for (i = 0; i < fsize; i++) cprintf("%c", file_buffer[i]);
	
	return 0;
}
	
	
	