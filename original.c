/*
 * Winbond W83627HF fast serial port driver for Linux 2.4.x
 *
 * Copyright (C) 2002 Tony Lindgren <tony@atomide.com>
 *
 * NOTE: In order to use this module, load the module and then set the 
 * serial port with a custom divisor. For example, to use speed 230400, 
 * use command:
 *
 * setserial /dev/ttyS0 uart 16550A baud_base 921600 spd_cust divisor 4
 *
 * If you remove the module, and want to reset the serial port, use:
 *
 * setserial /dev/ttyS0 uart 16550A baud_base 115200 spd_normal divisor 1
 *
 * The chip init code is copied from the w83627hf-wdt.c watchdog driver, 
 * Copyright (C) 2000 Matthias Cramer <cramer@dolphins.ch>.
 *
 * This software is licensed under GNU General Public License Version 2 
 * as specified in file COPYING in the Linux kernel source tree main 
 * directory.

 Compile comand:
   gcc -D__KERNEL__ -I/usr/src/linux/include -Wall -Wstrict-prototypes -O2 \
   -DMODULE -DMODVERSIONS -include /usr/src/linux/include/linux/modversions.h \
   -c w83627hf-fast-serial.c

*/

#include <linux/config.h>
#include <linux/module.h>
#include <linux/version.h>
#include <linux/types.h>
#include <linux/errno.h>
#include <linux/kernel.h>
#include <linux/sched.h>
#include <linux/miscdevice.h>
#include <linux/watchdog.h>
#include <linux/slab.h>
#include <linux/ioport.h>
#include <linux/fcntl.h>
#include <asm/io.h>
#include <asm/uaccess.h>
#include <asm/system.h>
#include <linux/notifier.h>
#include <linux/reboot.h>
#include <linux/init.h>

//#define DEBUG 1

#define WDT_UART0		(0x00)
#define WDT_UART1		(0x01)

/* UART normal mode */
#define WDT_RBR			(0x00)	/* Receiver buffer register */
#define WDT_TBR			(0x00)	/* Transmit buffer register */
#define WDT_ICR			(0x01)	/* Interrupt control register */
#define WDT_UCR			(0x03)	/* UART control register */
#define WDT_UDR			(0x07)	/* User defined register */

/* UART BDLAB mode */
#define WDT_BLL			(0x00)	/* Baudrate divisor latch low */
#define WDT_BLH			(0x01)	/* Baudrate divisor latch high */


/* W83627 control registers */
#define WDT_CR30			/* UART A, logical device 2 */
#define WDT_CR

#define WDT_CRF0		(0x00)	/* WD config register 0 */

#define WDT_CLOCK_1846200	(0x00)	/* 1.8462MHz clock source (24MHz/13) */	
#define WDT_CLOCK_2000000	(0x01)	/* 2MHz clock source (24MHz/12) */
#define WDT_CLOCK_2400000	(0x02)	/* 24MHz clock source (24MHz/1) */
#define WDT_CLOCK_1476000	(0x03)	/* 14.769MHz clock src (24MHz/1.625) */


#define WDT_EFER		(io+0)	/* Extended Function Enable Registers */
#define WDT_EFIR		(io+0)	/* Ext Funct Index Reg (same as EFER) */
#define WDT_EFDR		(WDT_EFIR+1)	/* Extended Func Data Register */

static void w83627_enter_ext_mode(void);
static void w83627_leave_ext_mode(void);

/*
 *	You must set these - there is no sane way to probe for this board.
 *	You can use w83627=x to set these now.
 */
 
static int io=0x2E;			/* Portwell Boards, S2460 */
//static int io=0x4e;			/* Maybe used on some other boards */


#ifndef MODULE

/**
 *	w83627_setup:
 *	@str: command line string
 *
 *	Setup options. The board isn't really probe-able so we have to
 *	get the user to tell us the configuration. Sane people build it 
 *	modular but the others come here.
 */
 
static int __init w83627_setup(char *str)
{
	int ints[4];

	str = get_options (str, ARRAY_SIZE(ints), ints);

	if (ints[0] > 0)
	{
		io = ints[1];
	}

	return 1;
}

__setup("w83627=", w83627_setup);

#endif /* !MODULE */

static void w83627_enter_ext_mode()
{
 	outb_p(0x87, WDT_EFER);		/* Enter extended function mode */
 	outb_p(0x87, WDT_EFER);		/* Do it twice !! */
 	
}

static void w83627_leave_ext_mode(void)
{
 	outb_p(0x0AA, WDT_EFER);	/* Leave extended function mode */
}

/*
 * Sets the UART into baud rate change mode
 */
static void w83627_enter_bdlab_mode(int port)
{
	int ucr = 0;

	printk(KERN_INFO "Entering bdlab mode to change the UART speed\n");
	ucr = inb_p(port + WDT_UCR);
	ucr |= (1 << 7);		/* Set baud divisor latch access bit */
	outb_p(ucr, port + WDT_UCR);
}

/*
 * Returns the serial port to the normal mode
 */
static void w83627_leave_bdlab_mode(int port)
{
	int ucr = 0;

	printk(KERN_INFO "Leaving bdlab mode\n");
	ucr = inb_p(port + WDT_UCR);
	ucr &= ~(1 << 7);		/* Clear baud divisor latch access bit */
	outb_p(ucr, port + WDT_UCR);
}

/*
 * Returns the logical device number based on the UART number
 */
static int w83627_get_uart_logical_device(int uartno)
{
	int l_dev;

	switch (uartno) {
	case 0:
		l_dev = 0x02;
		break;
	case 1:
		l_dev = 0x03;
		break;
	default:
		printk(KERN_INFO "Unknown logical device for UART\n");
		return 0;
	}
	return l_dev;
}

/*
 * Gets the UART baud rate divisor
 */
static int w83627_get_baud_divisor(int port)
{
	int bdr = 0;

	bdr = inb_p(port + WDT_BLL);	/* Baudrate divisor low register */
	printk(KERN_INFO "Baudrate divisor low register: 0x%x\n", bdr);
	bdr = (bdr << 8);
	bdr |= inb_p(port + WDT_BLH);	/* Baudrate divisor high register */
	printk(KERN_INFO "Baudrate divisor: 0x%x\n", bdr);

	return bdr;
}

/*
 * Sets the UART baud rate divisor
 */
static void w83627_set_baud_divisor(int div, int port)
{
	outb_p(div & 0xff, port + WDT_BLH);
	outb_p(div >> 8, port + WDT_BLL);
}

/*
 * Gets the selected UART port address
 */
static int w83627_get_uart_port(int uartno)
{
	int l_dev, port;

	l_dev = w83627_get_uart_logical_device(uartno);

	w83627_enter_ext_mode();
	outb_p(0x07, WDT_EFIR);			/* Access logical devices */
	outb_p(l_dev, WDT_EFDR);		/* Select the logical device */
	outb_p(0x60, WDT_EFIR);			/* Select CR60 */
	port = inb(WDT_EFDR);
	outb_p(0x61, WDT_EFIR);			/* Select CR61 */
	port = (port << 8) | inb(WDT_EFDR);
	w83627_leave_ext_mode();

	return port;
}

/* 
 * Reads the UART clock source speed
 */
static int w83627_get_uart_clock(int uartno)
{
	int l_dev, clock;

	l_dev = w83627_get_uart_logical_device(uartno);

	w83627_enter_ext_mode();
	outb_p(0x7, WDT_EFIR);			/* Access logical devices */
	outb_p(l_dev, WDT_EFDR);		/* Select the locical device */
	outb_p(0xf0, WDT_EFIR);			/* Select CRF0 */
	clock = inb(WDT_EFDR);	
	w83627_leave_ext_mode();

	return (clock & 0x2);
}

/*
 * Sets the UART clock speed
 */
static void w83627_set_uart_clock(int speed, int uartno)
{
	int l_dev, clock;

	l_dev = w83627_get_uart_logical_device(uartno);
	if (speed < 0 || speed > 0x3) {
		printk(KERN_ERR "Invalid clock speed specified\n");
		return;
	}

	w83627_enter_ext_mode();
	outb_p(0x7, WDT_EFIR);			/* Access logical devices */
	outb_p(l_dev, WDT_EFDR);		/* Select the desired device */
	outb_p(0xf0, WDT_EFIR);			/* Select CRF0 */
	clock = inb(WDT_EFDR);
	clock &= ~0x2;
	//clock |= WDT_CLOCK_2400000;
	clock |= WDT_CLOCK_1476000;
	outb_p(clock, WDT_EFDR);	
	w83627_leave_ext_mode();
}

/*
 * Tries to find out where the w83627 chip is located
 */
static int w83627_detect(void)
{
	int hefras, port = 0;

	w83627_enter_ext_mode();
	outb_p(0x26, WDT_EFIR);			/* Select CR26 */
	hefras = inb(WDT_EFDR);			/* Read from CR26 */
	w83627_leave_ext_mode();
	printk(KERN_INFO "hefras: 0x%x\n", hefras);
	return port;
}

/*
 * Sets the UART serial speed
 */
static void w83627_set_serial(void)
{
	int port = 0, clock;

	port = w83627_get_uart_port(WDT_UART1);
	if (!port) {
		printk(KERN_ERR "UART port not specified, aborting\n");
		return;
	}
	printk(KERN_INFO "Uart port address seems to be: 0x%x\n", port);
	clock = w83627_get_uart_clock(WDT_UART0);	/* UART 0 clock speed */
	printk(KERN_INFO "UART 0 clock speed: 0x%x\n", clock);
	w83627_set_uart_clock(WDT_CLOCK_2400000,0);
	clock = w83627_get_uart_clock(WDT_UART0);	/* UART 0 clock speed */
	printk(KERN_INFO "UART 0 clock speed: 0x%x\n", clock);

	w83627_enter_bdlab_mode(port);
	w83627_get_baud_divisor(port);
	w83627_set_baud_divisor(0x100, port);
	w83627_get_baud_divisor(port);
	w83627_leave_bdlab_mode(port);
}

#ifdef MODULE

#define w83627_init init_module

#endif

int __init w83627_init(void)
{
	printk(KERN_INFO "W83627HF fast serial port driver 0.1 loaded\n");
	w83627_set_serial();
	return 0;
}

MODULE_LICENSE("GPL");
