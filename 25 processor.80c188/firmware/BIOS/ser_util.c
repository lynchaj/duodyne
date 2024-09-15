/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ser_util.c -- serial I/O utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   This version is for compilation by Watcom 1.9 or later
;
; Copyright (C) 2020 John R. Coffman.  All rights reserved.
; Licensed for hobbyist use only.
; For use on the RetroBrew SBC-188 & SBC-188v3 boards.
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;
; SBC-188 board revisions:
;       1.0     production board
;       2.0	production board with errata
;------------------------------------------------------------------------
;       3.0	2 num 512k SRAM chips, GALs for glue logic
;------------------------------------------------------------------------
; Two boards provide serial interfacing on the ECB bus
;
; 4UART - up to 4 serial interfaces, all of which may not be used
;	The A & B interfaces are for USB connections at high speeds
;	The C & D interfaces may be USB or RS-232
;	Two CMOS clocks are selectable: 7.3728Mhz (4 num 1.8432Mhz) or 48Mhz
;	Under program control, MCR bit 4? 5? may be set to divide the 
;	  clock by 4. Default setup is to divide by 4, set by a jumper.
;
; 2S1P - board from Rich Cini usint the TL16C552 chip; 2 serial, 1 parallel
;	Serial ports are clocked at 1.8432Mhz.
;	The Parallel port is may be connected to a Centronics printer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/
#include "mytypes.h"



/* count the number of '1' bits in a dword */
int cob(dword num)
{
	int i = 0;

	while (num) num &= num-1, i++;
	return i;
}



/* return the logarithm base 2 >= (log2 of num); return -1 if num is 0 */
int log2(dword num)
{
	int log = -1;

	while (num) num >>= 1, log++;
	return log;
}



/* encode baud rate in 5 bits:
	baud rate must be a multiple of 75
	0x0010	indicates a division factor of 3
	0x000?	indicates a factor of 2**?
	
	return -1 if baud rate is < 150 && .ne. 75
		or baud rate cannot be represented
*/
int encode75(dword baud)
{
	int code = -1;

	if (baud % 75 != 0) return code;
	else baud /= 75;

	if (baud % 3 == 0) baud /= 3, code = 0x0010;
	else code = 0;

	if (cob(baud) != 1  ||  baud > 32768) return -1;
	code |= log2(baud);

	return code;
}


dword decode75(byte code)
{
	dword rate;

	if (code > 0x1F) return 0;
	rate = 1<<(code&0x0F);
	if (code & 0x10) rate *= 3;
	return rate*75;
}


#define DIV0  (7372800/16)
#define DIV1  (48000000/16)

int encode(dword baud)
{
	if (baud % 25000 == 0)
		return (DIV1 / baud) + 128;
	if (baud < 150) {
		if (baud==134 || baud==135) /* assume 134.5 is called for */
			return 127;
		else if (baud > 127 || baud < 32) return -1;
		else return baud;
	}
	return encode75(baud);
}


int serial_check(byte code, dword *clock)
{
	int divisor = -1;

	if (code==0 || code==0xFF) return divisor;

	if (code<32) {
		*clock = DIV0*16;
		divisor = DIV0 / decode75(code);
		if (divisor >= 4) *clock /= 4, divisor /= 4;
	}
	else if (code & 0x80) {
		divisor = code - 128;
		*clock = DIV1*16;
	}
	else if (code==127) {	/* 134.5 called for */
		*clock = DIV0*16;
		divisor = DIV0*2/269;	/* 269 = 134.5 x2 */
	}
	else {
		*clock = DIV0*4;
		divisor = (DIV0/4) / code;
	}
	return divisor;
}


#ifdef STANDALONE
#include <stdio.h>
#include <stdlib.h>

void main(int argc, char **argv)
{
	char * cp;
	dword baud, clock;
	int code, divisor;

	while (--argc) {
		cp = argv[1];
		baud = strtoul(cp, NULL, 0);
		code = encode(baud);
		printf("baud=%lu encode=0x%02x\n", baud, code);
		if ( !(code<0) ) {
			divisor = serial_check(code, &clock);
			printf("  clock=%ld divisor=%d\n", clock, divisor);
		}
		argv++;
	}
}
#endif
