/* WD37c65.h		support for Western Digital WD37C65.c driver */
/*
	Copyright (C) 2011 John R. Coffman.
	Licensed for hobbyist use on the N8VEM baby M68k CPU board.
***********************************************************************

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    in the file COPYING in the distribution directory along with this
    program.  If not, see <http://www.gnu.org/licenses/>.

**********************************************************************/
#include "fdc8272.h"


#if _DUAL_IDE
/*#define fdc_base_port	0x2A */
word fdc_base_port;

#define fdc_status_port (fdc_base_port)
#define fdc_data_port	(fdc_base_port+1)
#define fdc_WD_ldor		(fdc_base_port+2)
#define fdc_WD_ldcr		(fdc_base_port+3)
#define fdc_8in_fault_reset	(fdc_base_port+16)
#define fdc_tc				(fdc_base_port+17)
#define fdc_dack			(fdc_base_port+18)
#define fdc_dack_and_tc	(fdc_base_port+19)
/* the following is on the MF/PIC board, rev. 1.1 (or rev. 1.0 + update) */
#define fdc_dreq			(mf_rtc & 0xFF)

#elif SBC188

#define IO_BASE	0x400
#define fdc_base_port (IO_BASE+0x200)

#define fdc_status_port (fdc_base_port)
#define fdc_data_port	(fdc_base_port+1)
#define fdc_WD_ldor		(fdc_base_port+0x20)
#define fdc_WD_ldcr		(fdc_base_port+0x30)
#define fdc_8in_fault_reset	(fdc_base_port+16)
#define fdc_tc				(fdc_base_port+0x40)
#define fdc_dack			(fdc_base_port+0x10)
#define fdc_dack_and_tc	(fdc_base_port+0x50)
/* the following is on the MF/PIC board, rev. 1.1 (or rev. 1.0 + update) */
//#define fdc_dreq			(mf_rtc & 0xFF)

#else
#define fdc_status_port 0x30
#define fdc_data_port	0x31
#endif



void set_PCAT_mode(void);
byte wd_set_ldcr(byte value);
byte wd_set_ldor(byte bits);
byte wd_clear_ldor(byte bits);

void wd_select(T_floppy *floppy);

