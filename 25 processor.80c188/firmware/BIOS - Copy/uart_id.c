/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; uart_id.c -- identify a uart based on its device code
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
;       3.0	2 x 512k SRAM chips, GALs for glue logic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/
#include <stdio.h>
#include <stdlib.h>

unsigned char near uart_det(unsigned dev);
int is_present_2S1P(void);
int is_present_4UART(void);

static
char *name[] = {
	"none",
	"8250",
	"8250A/16450",
	"16550",
	"16550A",
	"16550C",
	"16650",
	"16750",
	"16850"
};

void usage(void)
{
	printf("Usage:\n    uart_id <device code>  -> identify UART at device code; e.g., 4C0"
                     "\n            <blank>  -> test for 2P1S and/or 4UART boards\n\n\n");
}


int main(int argc, char *argv[])
{
	int id = 0;
	unsigned dev = 0x680;	/* uart on the SBC-188 board */

	if (argc==1) {
		usage();
		id = is_present_2S1P();
		if (id) printf("2S1P board is present at 0x%04x\n", id);
		else printf("2S1P board is not present\n");

		id = is_present_4UART();
		if (id) printf("4UART board is present at 0x%04x\n", id);
		else printf("4UART board is not present\n");
		
		return 0;	
	}

	if (argc==2) {
		if (*argv[1] == '?') { usage(); return 0; }
		dev = strtoul(argv[1], NULL, 16);
	}

	id = uart_det(dev);
	printf("The UART at 0x%04X is %s.\n", dev, name[id]);

	return id;
}

