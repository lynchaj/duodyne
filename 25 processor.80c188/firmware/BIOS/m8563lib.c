/*************************************************************************
*  M8563lib.c -- library of support routines for CVDU text
*	controller chip 8563 for the N8VEM  SBC-188
**************************************************************************
*
*   Copyright (C) 2012 John R. Coffman.  All rights reserved.
*   Provided for hobbyist use on the N8VEM SBC-188 board.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*************************************************************************/
#include "sbc188.h"
#include "equates.h"
#include "sio.h"
#include "m8563inc.h"

#define TESTING 1

byte M8563init[] = {
#include "ega9a.h"
};

#if SOFT_DEBUG
const byte Font[] = 
	{
#include "font_vga.h"
/* The font may be 256 characters or 512 characters ("extended" attribute) */
#if 1
	,
#include "font_vga.h"
#endif
	};
#else
extern const byte __far *Font;
#endif

STATIC
word PixAddrMode3( byte X, byte Y, byte page)
{
	word addr = TextStartAddress + page * AttributeOffset * 2;
	return (addr + Y * YPitch + X);
}

#if 0
#define PixAddr(xy) PixAddrMode3((xy).b.x, (xy).b.y, 0)
//	((xy.b.y * YPitch)  +  xy.b.x  +  TextStartAddress)
#else
#define PixAddr(xy) ((xy).b.y * YPitch  +  (xy).b.x + TextStartAddress)
#endif


STATIC
void FASTCALL put_mem(word dest, byte data)
{
	M8563Put(18, dest>>8);
	M8563Put(19, dest);
	M8563Put(31, data);
}

STATIC
byte FASTCALL get_mem(word srs)
{
	M8563Put(18, srs>>8);
	M8563Put(19, srs);
	return M8563Get(31);
}

/* return 0 on success, 1 on failure */
int Scroll8563(word fn_lines, word lower_right, word page_attr, word upper_left)
{
	int delta, blank;
	word To, From;
	word func = fn_lines >> 8;
	int lines = fn_lines & 255;
	word Ymin = upper_left >> 8;
	word Xmin = upper_left & 255;
	word Ymax = lower_right >> 8;
	word Xmax = lower_right & 255;
	word page = page_attr >> 8;
	word attr = page_attr & 255;
	word nchar = Xmax - Xmin + 1;

#if TESTING>=2
	cprintf("%x %x %x %x\n", fn_lines, page_attr, upper_left, lower_right);
	cprintf("func=%d lines=%d\n", func, lines);
	cprintf("Xmin=%d Ymin=%d   Xmax=%d Ymax=%d\n", Xmin, Ymin, Xmax, Ymax);
	cprintf("page=%d attr=0x%02x nchar=%d\n", page, attr, nchar);
#endif

	if (lines==0) {
		blank = Ymax - Ymin + 1;
	} else {
		blank = lines;
		lines = Ymax - Ymin + 1 - blank;
	}
	if (page != 0) return 1;

	if (func==6) {
		To = PixAddrMode3(Xmin, Ymin, 0);
		delta = YPitch;
	} else {
		To = PixAddrMode3(Xmin, Ymax, 0);
		delta = -YPitch;
	}
	From = To + delta*blank;

#if TESTING>=2
  	cprintf("To = %04x   From = %04x  delta = %d\n", To, From, delta);
	cprintf("lines = %d  blank = %d\n", lines, blank);
#endif

	while (lines) {
		CopyMemory(To, From, nchar);
		CopyMemory(To+AttributeOffset, From+AttributeOffset, nchar);
		To += delta;
		From += delta;
		--lines;
	}
#if TESTING>=2
  	cprintf("To = %04x   From = %04x  delta = %d\n", To, From, delta);
	cprintf("lines = %d  blank = %d\n", lines, blank);
#endif

	while (blank) {
		FillMemory(To, nchar, ' ');
		FillMemory(To+AttributeOffset, nchar, 0x0E);
		To += delta;
		--blank;
	}
#if TESTING>=2
  	cprintf("To = %04x   From = %04x  delta = %d\n", To, From, delta);
	cprintf("lines = %d  blank = %d\n", lines, blank);
#endif

	return 0;
}


#if TESTING
STATIC
void CDECL LoadScreen(void)
{
	int x;
	
	M8563Put(18,0x00);
	M8563Put(19,00);
	
	for( x = 0 ;x<2047; x++)
	{
		M8563Put(31, (byte)(x & 0xff));
   }
}

STATIC
void CDECL SetScreenAttrib(void)
{
	int x, y, z;
	
	M8563Put(18,0x08);
	M8563Put(19,00);
	
	for( x=y=z= 0 ;x<2047; x++, y++, z++)
	{
		z &= 0x0F;
		if (!z) y++, z++;
		if (y & 0x100) z |= 0x80;
		M8563Put(31, (byte)z );
   }
	
}

STATIC
void __fastcall millisecond(word count)
{
	while (count--) microsecond(1000);
}

#endif




int Init8563(byte mode)
{
	int i, memory;
	byte reg, data;

	for (i=0; i<nelem(M8563init); ) {
		reg = M8563init[i++];
		data = M8563init[i++];
		M8563Put(reg, data);
	}

	memory = DRAMSize;			/* 64 */
	put_mem(0, 0x00);
/* memory is initialized to 64K */
	put_mem(256, 0x5A);
	if (get_mem(0)) SetMemSize8563(memory=16);
	FillMemory(0, 4*1024, 0);

	LoadFont();
#if TESTING
	SetScreenAttrib();
	LoadScreen();
	millisecond(1000);
#if TESTING>=2
	Scroll8563(0x0703, (24<<8)+70, 0x0007, 0x0206);
	millisecond(10000);
#endif
#endif
	if ( !(mode & 0x80) )
		FillMemory(TextStartAddress, HorizontalDisplayed * VerticalDisplayed, ' ');

	return memory;		/* return memory size in ??K */
}


void CDECL LoadFont(void)
{
	int x, y;
	
	M8563Put(18,CharsetAddress>>8);
	M8563Put(19,CharsetAddress&255);
	
//	for( x = 0 ; x < 8192; x++)
	for( x = 0 ; x < 4096; x++)
	{
		M8563Put(31,Font[x]);
   }
	for( x = 0 ; x < 256; x++) {
		for ( y = 0; y < 8; y++)
			M8563Put(31,Font[8*x + y + 4096]);
		for ( ; y < 16; y++)
			M8563Put(31, 000);
	}
	
}


STATIC
void CDECL FillMemory(word dest, word count, byte data)
{
	byte reg24 = M8563Get(24);
	word rem;

	M8563Put(18, (byte)(dest>>8));
	M8563Put(19, (byte)dest);
	M8563Put(31, data);
	count--;
	M8563Put(24, (byte)(reg24 & 0x7F));
	do {
		rem = count>255 ? 255 : count;
		M8563Put(30, (byte)rem);
		count -= rem;
	} while (count);

}


STATIC
void CDECL CopyMemory(word dest, word srs, word count)
{
	byte reg24 = M8563Get(24);
	word rem;

	M8563Put(18, (byte)(dest>>8));
	M8563Put(19, (byte)dest);
	M8563Put(32, (byte)(srs>>8));
	M8563Put(33, (byte)srs);
	M8563Put(24, (byte)(reg24 | 0x80));
	do {
		rem = count>255 ? 255 : count;
		M8563Put(30, (byte)rem);
		count -= rem;
	} while (count);
//	M8563Put(24, (byte)(reg24 & 0x7F));
}


#define ASSEMBLY 1
void M8563Put(byte Register, byte Value)
{	
#if ASSEMBLY
	__asm
	{
p1:	
		mov	dx,M8563Status
		in		al,dx
		or		al,al
		jns	p1
		mov	dx,M8563Status
		mov	al,Register
		out	dx,al
p2:
		mov	dx,M8563Status
		in		al,dx
		or		al,al
		jns	p2
		mov	al,Value
		mov	dx,M8563Data
		out	dx,al
	}
#else
    while (!(inp(M8563Status) & 0x80));	/* spin here */
    outp(M8563Register, Register);    
    while (!(inp(M8563Status) & 0x80));	/* spin here */
    outp(M8563Data, Value);
#endif
}


byte M8563Get(byte Register)
{
#if ASSEMBLY
	__asm
	{
g1:	
		mov	dx,M8563Status
		in		al,dx
		or		al,al
		jns	g1
		mov	dx,M8563Status
		mov	al,Register
		out	dx,al
g2:
		mov	dx,M8563Status
		in		al,dx
		or		al,al
		jns	g2
		mov	dx,M8563Data
		in		al,dx
		mov	Register,al
	}
	return Register;
#else
    while (!(inp(M8563Status) & 0x80)) ;	/* spin here */
    outp(M8563Register, Register);
    while (!(inp(M8563Status) & 0x80)) ;	/* spin here */
    return (byte)inp(M8563Data);
#endif
}

/* attribute mapping from IBM-PC to 8563; viz., IRGB to RGBI */
STATIC
byte amap(byte PC_attr)
{
	byte attr = PC_attr << 1;		/* move RGB bits */
	if (PC_attr & 010) attr++;		/* handle Intensity bit */
	
	return (attr & 0x0F);
}

/* map an attribute from 8563 to IBM-PC; viz., RGBI to IRGB */
STATIC
byte umap(byte a8563)
{
	byte attr = a8563 >> 1;
	if (a8563 & 1) attr += 010;

	return (attr & 0x0F);
}


word cvdu_tty_out(T_CURSOR_POSITION regAX, T_CURSOR_POSITION regBX)
{
	byte ch = regAX.reg.lo;
//	byte page = regBX.reg.hi;
	byte page = 0;
	byte M8563_attr = amap(regBX.reg.lo);
	T_CURSOR_POSITION cursor = ((T_CURSOR_POSITION*)(bios_data_area_ptr->video_cursor_pos))[page];
	word addr = PixAddr(cursor);

	switch (ch) {
#if 1
		case BS:
			if (cursor.b.x != 0) {
				addr--;
				cursor.b.x--;
			}
			break;
#endif
		case CR:
			cursor.b.x = 0;
			addr = PixAddr(cursor);
			break;
		case LF:
			cursor.b.y++;
			if (cursor.b.y < VerticalDisplayed) {
				addr += YPitch;
			} else {
				cursor.b.y--;
				Scroll8563(0x0601, ((VerticalDisplayed-1)<<8)+(HorizontalDisplayed-1),
					M8563_attr, 0x0000);
				/* addr does not change after the scroll */
			}
			break;
		default:
			put_mem(addr, ch);
			put_mem(addr + AttributeOffset, M8563_attr);
			cursor.b.x++;
			addr++;
	}
	(bios_data_area_ptr->video_cursor_pos)[page] = cursor.w;
	M8563Put(14, addr>>8);	/* update the screen cursor */
	M8563Put(15, addr);

	return regAX.w;
}

void set_cursor_pos(T_CURSOR_POSITION regDX)
{
	word addr = PixAddr(regDX);

	M8563Put(14, addr>>8);	/* update the screen cursor */
	M8563Put(15, addr);
}

word get_char_and_attribute(T_CURSOR_POSITION regBX)
{
	T_CURSOR_POSITION cursor, attr_char;
//	byte page = regBX.reg.hi;
	byte page = 0;
	cursor.w = (bios_data_area_ptr->video_cursor_pos)[page];
	cursor.w = PixAddr(cursor);

	M8563Put(18,cursor.reg.hi);
	M8563Put(19,cursor.reg.lo);
	attr_char.reg.lo = M8563Get(31);

	cursor.w += AttributeOffset;

	M8563Put(18,cursor.reg.hi);
	M8563Put(19,cursor.reg.lo);
	attr_char.reg.hi = umap(M8563Get(31));

	return attr_char.w;
}

#define TC T_CURSOR_POSITION

void blast_characters(TC regAX, TC regBX /* in DX */, word count /* in BX */)
{
/* video functions:  09h -- character & attribute
							0Ah -- character only
 */
	TC cursor;
	word i;
	byte attr = amap(regBX.reg.lo);
 	byte page = regBX.reg.hi;
//	page = 0;

	cursor.w = (bios_data_area_ptr->video_cursor_pos)[page];
	cursor.w = PixAddr(cursor);

	if (regAX.reg.hi == 0x09) {
		cursor.w += AttributeOffset;
		if (count > 3)
			FillMemory(cursor.w, count, attr);
		else {
			M8563Put(18,cursor.reg.hi);
			M8563Put(19,cursor.reg.lo);
			for (i=0; i<count; i++) {
				M8563Put(31, attr);
			}
		}
		cursor.w -= AttributeOffset;
	}

	if (count > 3)
		FillMemory(cursor.w, count, regAX.reg.lo);
	else {
		M8563Put(18,cursor.reg.hi);
		M8563Put(19,cursor.reg.lo);
		for (i=0; i<count; i++) {
			M8563Put(31, regAX.reg.lo);
		}
	}
}


STATIC
byte CDECL SetMemSize8563(byte size)
{
	byte	reg28, original = 16;

	reg28 = M8563Get(28);
	if (reg28 & 16)  original = 64;

	if (size == 64) reg28 |= 16;
	else if (size == 16) reg28 &= ~16;

	M8563Put(28, reg28);

	return original;
}

#if 0
byte CDECL SizeMemory8563(void)
{
	word addr = 0;
	byte test, sizeMem;
	byte t0, t256;

	SetMemSize8563(64);
	t0 = get_mem(addr);
	t256 = get_mem(addr+256);

	put_mem(addr, 0x00);
	put_mem(addr+256, 0x6C);
	test = get_mem(addr);
	put_mem(addr, t0);
	put_mem(addr+256, t256);

	if (test==0x6C) sizeMem=16;
	else if (test==0x00) sizeMem=64;
	else sizeMem = 0;		/* signal error */

	if (sizeMem) SetMemSize8563(sizeMem);

	return sizeMem;
}
#endif

/* end M8563lib.c */
