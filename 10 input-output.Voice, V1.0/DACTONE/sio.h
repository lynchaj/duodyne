/* SPDX-License-Identifier: GPL-2.0-or-later */

#ifndef __SIO_H__
#define __SIO_H__

#define SIO0_PORTA 0
#define SIO0_PORTB 1

void init_sio_8n1(int port);
void sio_write_buffer(const char *buf, int size);
void sio_write_string(const char *str);

#endif