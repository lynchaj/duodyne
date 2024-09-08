/* v3mtst.c -- test memory on the VGA3 board */
#ifndef CPM68
#include <stdio.h>
#endif
#include <stdlib.h>

#include "mytypes.h"
#include "v3std.h"

const
byte font0[4096] = {
#include "fnt_vga0.h"
};


int	mode;		/* mode = 0 means no direct mapping, mode = 1 means use direct memory mapping */
#ifndef UNA
byte FAR *v3mem = VGA_MEML;
#endif
int	verbose;


void wr_cfg(byte cfg)
{
	outp(V3CFG, cfg);
}


void wr_mem(word addr, byte value)
{
#ifndef UNA
	if (mode) {		/* use direct memory mapping */
		v3mem[addr] = value;
	} else 
#endif
	{
		byte hi, lo;
		hi = (byte)(addr >> 8);
		lo = (byte)addr;
		outp(V3ADDH, hi);
		outp(V3ADDL, lo);
		outp(V3DATA, value);
	}
}

byte rd_mem(word addr)
{
	byte value;
#ifndef UNA
	if (mode) {		/* use direct memory mapping */
		value = v3mem[addr];
	} else 
#endif
	{
		byte hi, lo;
		hi = (byte)(addr >> 8);
		lo = (byte)addr;
		outp(V3ADDH, hi);
		outp(V3ADDL, lo);
		value = inp(V3DATA);
	}
	return value;
}

int paths(void)
{
	int addr, dat, errors = 0;

	printf("Checking data bit paths to memory; ");
	if (mode) printf("directly to memory\n");
	else printf("indirectly through addressing registers\n");
	
	dat = 01;
	for (addr=0; addr<8; addr++) {
		wr_mem(addr, dat);
		if (dat != rd_mem(addr) ) {
			printf("Error on data bit %02x\n", dat);
			errors++;
		}
		dat <<= 1;
	}
	dat = 01;
	for (addr=10; addr<18; addr++) wr_mem(addr, dat), dat <<= 1;
	dat = 01;
	for (addr=10; addr<18; addr++) {
		if (rd_mem(addr) != dat) errors++;
		dat <<= 1;
	}
	return errors;
}


int fontrw(int altmode)
{
	int page, addr, errors = 0;
	int data;

#ifdef UNA
	mode = 0;
	altmode = 0;
#endif
	printf("Checking 32k of memory by loading the VGA font to 8 pages and\n reading it back (mode=%d, alt=%d)\n", mode, altmode);
	for (page=0; page<8; page++) {
		for (addr=0; addr<4096; addr++) {
			wr_mem((page<<12)|addr, font0[addr]);
		}
		mode ^= altmode;
		for (addr=0; addr<4096; addr++) {
			if (font0[addr] != (data=rd_mem((page<<12)|addr)) ) {
				errors++;
				if (verbose>0) {
					printf("\tWmode=%d, Rmode=%d  address=$%03X  correct=$%02X  readback=$%02X\n",
						mode^altmode, mode, addr, (int)font0[addr], data);
				}
			}
		}
		printf("Page %d,  %d total errors.\n", page, errors);
	}
	return errors;
}


int main(int argc, char *argv[])
{
	int errors;

	
	verbose = 0;
	if (argc>1) {
		verbose = atoi(argv[1]);
		printf("Verbosity = %d\n\n", verbose);
	}
	
	wr_cfg(0);
	
	mode = 0;
	errors = paths();
	printf("%d error(s) detected.\n", errors);
	
	mode = 1;
	errors += paths();
	printf("%d error(s) detected.\n", errors);
	
	mode = 1;
	errors += fontrw(0);
	printf("%d error(s) detected.\n", errors);
	
	mode = 0;
	errors += fontrw(0);
	printf("%d error(s) detected.\n", errors);
	
	errors += fontrw(1);
	printf("%d error(s) detected.\n", errors);
	
	return errors;
}

