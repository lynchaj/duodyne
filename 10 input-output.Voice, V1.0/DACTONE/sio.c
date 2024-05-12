
/* SPDX-License-Identifier: GPL-2.0-or-later */

#include <stdint.h>
#include <stdlib.h>

#include "sio.h"
#include "buffer.h"

static void do_delay(void)
{
}

static void write_sio(int port, uint8_t reg, uint8_t data)
{
    uint8_t cmd_port = port == SIO0_PORTA ? SIO0A_CMD : SIO0B_CMD;
    uint8_t data_port = port == SIO0_PORTA ? SIO0A_DAT : SIO0B_DAT;
    if (reg == 0) outp(cmd_port, data);
    else {
        outp(cmd_port, reg);
        do_delay();
        outp(cmd_port, data);
    }
}

void init_sio_8n1(int port)
{
    write_sio(port, 0, 0x18); /* channel reset*/
    write_sio(port, 1, 0x00); /* no interrupts */
    write_sio(port, 2, 0x00); /* interrupt vector = 0 */
    write_sio(port, 3, 0xC1); /* receive enable, receive 8 bits per char */
    write_sio(port, 4, 0x44); /* X16 clock mode, one stop bit, no parity */
    write_sio(port, 5, 0xEA); /* transmit enable, transmit 8 bits per char, assert RTS# */
    write_sio(port, 0, 0x10); /* Reset external status interrupt */
}

static int8_t bcostatSIO0A(void)
{   
    uint8_t control = inp(SIO0A_CMD);
    //if (control  & 0x80) return 0; /* HACK!!! */
    return control & 4 ? -1 : 0;
}       
  
static uint8_t bconoutSIO0A(uint16_t dev, uint8_t b)
{       
    while (!bcostatSIO0A())
        ;
    outp(SIO0A_DAT, b);
    return 0;
}

void sio_write_buffer(const char *buf, int size)
{
    for (int i = 0; i < size; i++) { 
        bconoutSIO0A(0, buf[i]);
    }
}

void sio_write_string(const char *str)
{ 
    for (const char *p = str; *p != 0; p++) {
        bconoutSIO0A(0, *p);
    }
}
