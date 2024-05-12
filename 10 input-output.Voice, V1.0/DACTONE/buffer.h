
#if 0
/* SPDX-License-Identifier: GPL-2.0-or-later */
#endif 

#ifndef __BUFFER_H__
#define __BUFFER_H__

#define BUFFER_INFO 0xC000

#define BUF_HEAD   BUFFER_INFO
#define BUF_END    BUFFER_INFO+2
#define BUF_START  BUFFER_INFO+4
#define BUF_PASSES BUFFER_INFO+6

#define LED_PORT 0x94
#define DAC_PORT 0xBB

#define SIO0BASE 0x60
#define SIO0A_CMD (SIO0BASE + 6)
#define SIO0A_DAT (SIO0BASE + 4)
#define SIO0B_CMD (SIO0BASE + 7)
#define SIO0B_DAT (SIO0BASE + 5)

#endif
