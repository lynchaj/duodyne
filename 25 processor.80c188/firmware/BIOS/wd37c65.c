/* WD37c65.c		FDC operations for the Western Digital WD37C65-B chip */
/* 	uses the Intel PL/M driver for the 8272 (NEC 765) chip */
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
#include "wd37c65.h"

byte timeout;		/* counted down in 'pic202.s' */

struct WD_REGS {
	byte	ldor, ldcr;
} wd_reg;

/* set bits in the Operations Register */
/* return former contents */
byte wd_set_ldor(byte bits)
{
	byte former = wd_reg.ldor;

	wd_reg.ldor |= bits;
	outp(fdc_WD_ldor, wd_reg.ldor);

	return former;
}

/* clear the selected bits in the Operations Register */
/* return former contents */
byte wd_clear_ldor(byte bits)
{
	byte former = wd_reg.ldor;

	wd_reg.ldor &= ~bits;
	outp(fdc_WD_ldor, wd_reg.ldor);

	return former;
}


/* set the Control Register */
/* not an OR operation, it is an ASSIGN operation */
byte wd_set_ldcr(byte value)
{
	byte former = wd_reg.ldcr;

	outp(fdc_WD_ldcr, (wd_reg.ldcr = value));
	return former;
}


void set_PCAT_mode(void)
{
	wd_clear_ldor(0xFF);		/* set LDOR to 00h */
	wd_reg.ldcr = inp(fdc_WD_ldcr);   /* lock mode by reading the Control Register */
	wd_set_ldor(0x0C);		/* release RESET and enable DMA */
}


/* called at interrupt level when 'timeout' expires */
void floppy_timeout(void)
{
	wd_clear_ldor(0x33);		/* clear the MotorON and DS bits */
}

/* wait for the number of timer ticks < 250 */
void wait_for(byte ticks)
{
	byte when, temp;

	temp = timeout;
	if (temp < ticks) timeout = 255;
	when = timeout - ticks;
	do {
		usec16();
	} while (timeout && timeout>when);
	if (temp < ticks) timeout = temp;
}


/* floppy select -- select drive and turn motor on */
void wd_select(T_floppy *floppy)
{
/* MotorOn1 + DS0=1     ---   shift for MotorOn0 + DS0=0 */
#define DRIVE1		0x21
	byte drive = DRIVE1;
	byte was_on;
	byte drive_no = floppy->disk.slave;
	
	if (drive_no == 0) drive >>= 1;		/* shift by 1 */
	was_on = drive & wd_set_ldor(drive);
	timeout = floppy->param->timeout;
	if (!was_on) {
		wait_for(floppy->param->del_mot_on);
		timeout = floppy->param->timeout;
	}
/* motor is on and up to speed */
}


/* (end) */
