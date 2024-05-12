/* SPDX-License-Identifier: GPL-2.0-or-later */

#ifndef __HBIOS_H__
#define __HBIOS_H__

int get_hbios_intr_info(void);
int get_hbios_version(void);
int get_hbios_platform(void);

int get_interrupt(int ivt_num);
/* returns previous handler */
int set_interrupt(int ivt_num, void (*handler)(void));

#endif
