#include <defs.h>
#include <mips32s.h>
#include <stdio.h>
#include <string.h>
#include <picirq.h>
#include <trap.h>
#include <sync.h>

/***** Serial I/O code *****/
#define COM1            0xbfd003f8
#define COM1_STATE      (COM1+4)

/***** VGA, Keyboard *****/
#define VGA            0xbfc03000
#define KBD            0xAF000000 //Nota bene!



static bool serial_exists = 0;

static void
serial_init(void) {
    serial_exists = 1;

    if (serial_exists) {
        // Do NOT response to serial int now. TODO
        pic_enable(IRQ_COM1);
    }
}

static void
kbd_init(void) {
    serial_exists = 1;

    if (serial_exists) {
        // Do NOT response to keyboard int now. TODO
        pic_enable(IRQ_KBD);
    }
}

static void
serial_putc_sub(int c) {
    while ((*(uint32_t *)COM1_STATE & 1) == 0);
    *(uint32_t *)COM1 = (uint32_t)c;
}

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}

/* vga_putc - print character to serial port */
static void
vga_putc(int c) {
    *(uint32_t *)VGA = (uint32_t)c;
}

/* *
 * Here we manage the console input buffer, where we stash characters
 * received from the keyboard or serial port whenever the corresponding
 * interrupt occurs.
 * */

#define CONSBUFSIZE 512

static struct {
    uint8_t buf[CONSBUFSIZE];
    uint32_t rpos;
    uint32_t wpos;
} cons;

/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
        if (c != 0) {
            cons.buf[cons.wpos ++] = c;
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
    int c = -1;

    if ((*(uint32_t *)COM1_STATE & 2) == 0)
        return -1;
    c = *(uint32_t *)COM1;

    if (c == 127) {
        c = '\b';
    }
    return c;
}

int
cons_getc(void);
/* kbd_proc_data - get data from keyboard */
static int
kbd_proc_data(void) {
    int c = -1;

    c = *(uint32_t *)KBD;

    if (c == 127) {
        c = '\b';
    }
	
	//cons_putc((int)c);//NB
    return c;
}

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
    if (serial_exists) {
        cons_intr(serial_proc_data);
    }
}

/* kbd_intr - try to feed input characters from keyboard */
void
kbd_intr(void) {
    //if (serial_exists) {
        cons_intr(kbd_proc_data);
    //}
}

/* cons_init - initializes the console devices */
void
cons_init(void) {
    serial_init();
    if (!serial_exists) {
        cprintf("serial port does not exist!!\n");
    }
	kbd_init();
}

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        serial_putc(c);
		vga_putc(c);
    }
    local_intr_restore(intr_flag);
}

/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
    int c = 0;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
		kbd_intr();

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
            c = cons.buf[cons.rpos ++];
            if (cons.rpos == CONSBUFSIZE) {
                cons.rpos = 0;
            }
        }
    }
    local_intr_restore(intr_flag);
    return c;
}

