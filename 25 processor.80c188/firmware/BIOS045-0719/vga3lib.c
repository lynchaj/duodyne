/*************************************************************************
*  vga3lib.c -- library of support routines for VGA3 text
*	controller chip Vga3 for the N8VEM  SBC-188
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
#include <string.h>
#include "sbc188.h"
#include "equates.h"
#include "sio.h"
#include "vga3inc.h"


#define TESTING 1
#define STATIC static

#if SOFT_DEBUG
const byte __far Font[] = 
	{
#include "font_vga.h"
/* The font may be 256 characters or 512 characters ("extended" attribute) */
	};
#else
extern const byte __far *Font;
#endif




/* from ~/VGA3 test programs */

STATIC
void update_cfg(int option, byte mask)
{
/***	static byte cfg;	***/
	byte FAR *cfg = &(bios_data_area_ptr->video_cga_palette);

	if (option != 0) *cfg |= mask;	/*  set  bits if option == 1 */
	else *cfg &= ~mask;		/* clear bits if option == 0 */
	outp(V3CFG, (int)(*cfg));
}


/* not STATIC */
byte FAR * video_buffer_ptr(void)
{	
	return (byte FAR *)(0xB8000000UL);
}


STATIC
void video_zap(void)
{
	int i;
	int j = 0;

	for (i=0; i<=39; i++) {
		outp(V3CRTC_ADDR, i);
		outp(V3CRTC_DATA, j);
	}
}


STATIC
void video_init(void)
{
	const byte *tab;

	update_cfg(0, 0xFF);		/* clear all configuration bits, same as board RESET */
	video_zap();			/* start with all CRTC registers zeroed */
		
	tab = vga_params;
	while (*tab != 0xFF) {
		outp(V3CRTC_ADDR, *tab++);
		outp(V3CRTC_DATA, *tab++);
	}
}

#define MODE 1
#define TextStartAddress 0
#define AttributeOffset 1
#define PageMemory 4096
#define Ypitch HORIZONTAL_DISPLAYED



STATIC
word char_index(T_CURSOR_POSITION xy)
{
	return (xy.b.y * YPitch + xy.b.x);
}


STATIC
byte wr_crtc(byte reg, byte data)
{
	outp(V3CRTC_ADDR, reg);
	outp(V3CRTC_DATA, data);
	return data;
}

STATIC
int rd_crtc(byte reg)
{
	outp(V3CRTC_ADDR, reg);
	return inp(V3CRTC_DATA);
}


STATIC
void wr_mem(word addr, byte value)
{
	byte FAR *v3mem = video_buffer_ptr();
#ifndef UNA
	if (MODE) {		/* use direct memory mapping */
	
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

STATIC
byte rd_mem(word addr)
{
	byte value;
	byte FAR *v3mem = video_buffer_ptr();

#ifndef UNA
	if (MODE) {		/* use direct memory mapping */
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


STATIC
void video_enable(void)
{
	update_cfg(1, 4);		/* turn on the video */
}

STATIC
void video_disable(void)
{
	update_cfg(0, 4);		/* turn off the video */
}


STATIC
void set_font_page(int page)
{
	update_cfg(0, 7<<4);	/* clear page bits */
	update_cfg(1, (page & 7)<<4);
}




STATIC
int load_font(int page, const byte FAR *font)
{
	word addr;
	int i;
	
	if ((unsigned)page > 7) return 1;	/* signal error */
	addr = page<<12;
	
	for (i=0; i<4096; i++) {
		wr_mem(addr, *font);
		addr++;
		font++;
	}
	set_font_page(page);
	
	return 0;				/* no error */
}


/* above are from ~/VGA3  */


STATIC
void fill_mem(word dest, word wvalue, word wcount)
{
	word FAR *v3mem = (word FAR *)video_buffer_ptr();
	
	while (wcount--) v3mem[dest++] = wvalue;
}


int Init_vga3(byte mode) {

/* disable video, program the CRTC */
	video_init();
	
/* address from B800:xxxx */
	update_cfg(1, CFG_B8B0);	/* set refresh half */

	if (load_font(7, Font)) return 1;
	fill_mem(0, 0x0720, 2048);	/* all white SP */
	video_enable();
	return 0;
}


#if 0
/* this move has been moved into 'int10ser.asm' to be as fast as possible */

void mv_word(word dest, word srs, word count)
{
	word FAR *v3mem = (word FAR *)video_buffer_ptr();

	while(count--) v3mem[dest++] = v3mem[srs++];
}
#else
void mv_word(word dest, word srs, word count);
#endif


STATIC
void mv_wordr(word dest, word srs, word count)
{
	word FAR *v3mem = (word FAR *)video_buffer_ptr();

	while(count--) v3mem[dest--] = v3mem[srs--];
}


int Scroll_vga3(word fn_lines, T_CURSOR_POSITION lower_right, word page_attr, T_CURSOR_POSITION upper_left)
{
	word n;
	word To, From;
	word func = fn_lines >> 8;	/* fn==6 means scroll up    fn==7 means scroll down */
	int lines = fn_lines & 255;	/* if 0, blank entire window; else # lines to scroll */
	word Ymin = upper_left.b.y;
	word Xmin = upper_left.b.x;
	word Ymax = lower_right.b.y;
	word Xmax = lower_right.b.x;
	word page = page_attr >> 8;		/* assembly 'int20ser.asm' reversed these two from BH=attr, BL=page of the FN06 call*/
	word attr = page_attr & 255;
	word nchar = Xmax - Xmin + 1;		/* number of characters on a line to blank */
	word nmove = Ymax - Ymin - lines + 1;		/* number of (partial) lines to move */
	word fill = (word)attr<<8 | ' ';	/* fill value */
	
	if (lines >= VERTICAL_DISPLAYED) lines = 0;	/* blank the display */
	if (nchar > HORIZONTAL_DISPLAYED) nchar = HORIZONTAL_DISPLAYED;

	if (func==6 || lines==0) {
		To = char_index(upper_left);
		From = To + Ypitch*lines;
		if (lines==0) { 
			lines = nmove;
			nmove = 0;
		}
#define LowRt (word)((VERTICAL_DISPLAYED-1)*256 + HORIZONTAL_DISPLAYED-1)
#define UppLf 0x0000u
		if (lines == 1  &&  lower_right.w == LowRt  &&  upper_left.w == UppLf) {
		/* special case the full screen scroll */
			int div = 2;
			nmove /= div;
			for (; div-- > 0; ) {
				while ((rd_crtc(31) & 2) != 0) ;	/* wait for screen refresh */
				while ((rd_crtc(31) & 2) == 0) ; 	/* wait for start of vertical retrace */
				mv_word(To, From, nchar*nmove);
				To += nchar*nmove;
				From += nchar*nmove;
			}			
		} else for (n=0; n<nmove; n++)  {
			mv_word(To, From, nchar);
			To += Ypitch;
			From += Ypitch;
		}
		for (n=0; n<lines; n++) {
			fill_mem(To, fill, nchar);
			To += Ypitch;
		}

	} else { /* func == 7 */
		To = char_index(lower_right);
		From = To - Ypitch*lines;
		for (n=0; n<nmove; n++)  {
			mv_wordr(To, From, nchar);
			To -= Ypitch;
			From -= Ypitch;
		}
	}
		
	
	return 0;
}

word vga3_get_char_and_attribute(T_CURSOR_POSITION regBX)
{
	byte ch;
	word attr;
	word index = char_index(regBX);
	
	ch = rd_mem(2*index);
	attr = rd_mem(2*index + 1);
	
	return (attr<<8) | (word)ch ;
}

void vga3_blast_characters(T_CURSOR_POSITION regAX, T_CURSOR_POSITION regBX /* in DX */, word count /* in BX */)
{
	byte fn = regAX.reg.hi;
	byte ch = regAX.reg.lo;
	byte attr = regBX.reg.lo;
	word page = 0;
	T_CURSOR_POSITION cursor = ((T_CURSOR_POSITION*)(bios_data_area_ptr->video_cursor_pos))[page];
	word index = char_index(cursor);

/* this function does not move the cursor */	

	while (count--) {
		wr_mem(2*index, ch);
		if (fn == 0x09) wr_mem(2*index + 1, attr);
		++index;
	}
	
	return;
}

word vga3_tty_out(T_CURSOR_POSITION regAX, T_CURSOR_POSITION regBX)
{
	byte ch = regAX.reg.lo;
//	byte page = regBX.reg.hi;
	byte page = 0;
	byte vga3_attr = regBX.reg.lo;
	T_CURSOR_POSITION cursor = ((T_CURSOR_POSITION*)(bios_data_area_ptr->video_cursor_pos))[page];
	word addr;
	
	addr = char_index(cursor);
	switch (ch) {
#if 1
		case BS:
			if (cursor.b.x != 0) {
				cursor.b.x--;
			}
			break;
#endif
		case CR:
			cursor.b.x = 0;
			break;
		case LF:
			cursor.b.y++;
			if (cursor.b.y < VERTICAL_DISPLAYED) {
				addr += YPitch;
			} else {
				T_CURSOR_POSITION upper_left, lower_right;
				upper_left.b.x = 0;
				upper_left.b.y = 0;
				lower_right.b.x = HORIZONTAL_DISPLAYED - 1;
				lower_right.b.y = VERTICAL_DISPLAYED - 1;
				
				cursor.b.y--;
				Scroll_vga3(0x0601, lower_right, vga3_attr, upper_left);
				/* addr does not change after the scroll */
			}
			break;
		default:
			wr_mem(addr*2, ch);
			wr_mem(addr*2 + AttributeOffset, vga3_attr);
			cursor.b.x++;
	}
	vga3_set_cursor_pos(cursor);	/* update the screen cursor */

	return regAX.w;
}

void vga3_set_cursor_pos(T_CURSOR_POSITION regDX)
{
	word index;
#define PAGE 0
	
	bios_data_area_ptr->video_cursor_pos[PAGE] = regDX.w;
	
	index = char_index(regDX);
	
	wr_crtc(CURSOR1_HI, (byte)(index>>8));
	wr_crtc(CURSOR1_LO, (byte)(index));
		
	return;
#undef PAGE
}



#if 0		/* major zap */

word CharAddrMode3(byte X, byte Y, byte page)
{
	word base = TextStartAddress + page * PageMemory;
	word addr = Y * Ypitch + X;
	return (base + addr*2);
}



#if 0
#define PixAddr(xy) CharAddrMode3((xy).b.x, (xy).b.y, 0)
#else
#define PixAddr(xy) (((xy).b.y * YPitch  +  (xy).b.x) + TextStartAddress)
#endif

#if 0
static
void FASTCALL put_mem(word dest, byte data)
{
	vga3Put(18, dest>>8);
	vga3Put(19, dest);
	vga3Put(31, data);
}

static
byte FASTCALL get_mem(word srs)
{
	vga3Put(18, srs>>8);
	vga3Put(19, srs);
	return vga3Get(31);
}
#endif

/* return 0 on success, 1 on failure */
int Scroll_vga3(word fn_lines, word lower_right, word page_attr, word upper_left)
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
		To = CharAddrMode3(Xmin, Ymin, 0);
		delta = YPitch;
	} else {
		To = CharAddrMode3(Xmin, Ymax, 0);
		delta = -YPitch;
	}
	From = To + 2*delta*blank;

#if TESTING>=2
  	cprintf("To = %04x   From = %04x  delta = %d\n", To, From, delta);
	cprintf("lines = %d  blank = %d\n", lines, blank);
#endif

	while (lines) {
		CopyMemory(To, From, nchar*2);
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
void CDECL LoadScreen(void)
{
	int x;
	
	vga3Put(18,0x00);
	vga3Put(19,00);
	
	for( x = 0 ;x<2047; x++)
	{
		vga3Put(31, (byte)(x & 0xff));
   }
}

void CDECL SetScreenAttrib(void)
{
	int x, y, z;
	
	vga3Put(18,0x08);
	vga3Put(19,00);
	
	for( x=y=z= 0 ;x<2047; x++, y++, z++)
	{
		z &= 0x0F;
		if (!z) y++, z++;
		if (y & 0x100) z |= 0x80;
		vga3Put(31, (byte)z );
   }
	
}

void __fastcall millisecond(word count)
{
	while (count--) microsecond(1000);
}

#endif




int Init_vga3(byte mode)
{
	int i, memory;
	byte reg, data;
#if 0
	for (i=0; i<nelem(vga3init); ) {
		reg = vga3init[i++];
		data = vga3init[i++];
		vga3Put(reg, data);
	}
#endif
/****	memory = DRAMSize;			/ * 64 * /	****/
	put_mem(0, 0x00);
/* memory is initialized to 64K */
	put_mem(256, 0x5A);
/*****	if (get_mem(0)) SetMemSizeVga3(memory=16);	*****/
	FillMemory(0, 4*1024, 0);

	LoadFont();
#if TESTING
	SetScreenAttrib();
	LoadScreen();
	millisecond(1000);
#if TESTING>=2
	Scroll_vga3(0x0703, (24<<8)+70, 0x0007, 0x0206);
	millisecond(10000);
#endif
#endif
	if ( !(mode & 0x80) )
		FillMemory(TextStartAddress, HORIZONTAL_DISPLAYED * VERTICAL_DISPLAYED, ' ');

	return memory;		/* return memory size in ??K */
}




void CDECL FillMemory(word dest, word count, byte data)
{
	byte reg24 = vga3Get(24);
	word rem;

	vga3Put(18, (byte)(dest>>8));
	vga3Put(19, (byte)dest);
	vga3Put(31, data);
	count--;
	vga3Put(24, (byte)(reg24 & 0x7F));
	do {
		rem = count>255 ? 255 : count;
		vga3Put(30, (byte)rem);
		count -= rem;
	} while (count);

}


void CDECL CopyMemory(word dest, word srs, word count)
#if 0
}
#else
{
	byte temp;
	
	while (count) {
		temp = rd_mem(srs);
		wr_mem(dest, temp);
		srs++;
		dest++;
		count--;
	}
}
#endif


#if 0
#define ASSEMBLY 1
void vga3Put(byte Register, byte Value)
{	
#if ASSEMBLY
	__asm
	{
p1:	
		mov	dx,vga3Status
		in		al,dx
		or		al,al
		jns	p1
		mov	dx,vga3Status
		mov	al,Register
		out	dx,al
p2:
		mov	dx,vga3Status
		in		al,dx
		or		al,al
		jns	p2
		mov	al,Value
		mov	dx,vga3Data
		out	dx,al
	}
#else
    while (!(inp(vga3Status) & 0x80));	/* spin here */
    outp(vga3Register, Register);    
    while (!(inp(vga3Status) & 0x80));	/* spin here */
    outp(vga3Data, Value);
#endif
}


byte vga3Get(byte Register)
{
#if ASSEMBLY
	__asm
	{
g1:	
		mov	dx,vga3Status
		in		al,dx
		or		al,al
		jns	g1
		mov	dx,vga3Status
		mov	al,Register
		out	dx,al
g2:
		mov	dx,vga3Status
		in		al,dx
		or		al,al
		jns	g2
		mov	dx,vga3Data
		in		al,dx
		mov	Register,al
	}
	return Register;
#else
    while (!(inp(vga3Status) & 0x80)) ;	/* spin here */
    outp(vga3Register, Register);
    while (!(inp(vga3Status) & 0x80)) ;	/* spin here */
    return (byte)inp(vga3Data);
#endif
}
#endif


/* attribute mapping from IBM-PC to 8563; viz., IRGB to RGBI */
#if 0
byte amap(byte PC_attr)
{
	byte attr = PC_attr << 1;		/* move RGB bits */
	if (PC_attr & 010) attr++;		/* handle Intensity bit */
	
	return (attr & 0x0F);
}

/* map an attribute from 8563 to IBM-PC; viz., RGBI to IRGB */
byte umap(byte a8563)
{
	byte attr = a8563 >> 1;
	if (a8563 & 1) attr += 010;

	return (attr & 0x0F);
}
#else
#define amap(x) (x)
#define umap(x) (x)
#endif


word vga3_tty_out(T_CURSOR_POSITION regAX, T_CURSOR_POSITION regBX)
{
	byte ch = regAX.reg.lo;
//	byte page = regBX.reg.hi;
	byte page = 0;
	byte vga3_attr = amap(regBX.reg.lo);
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
			if (cursor.b.y < VERTICAL_DISPLAYED) {
				addr += YPitch;
			} else {
				cursor.b.y--;
				Scroll_vga3(0x0601, ((VERTICAL_DISPLAYED-1)<<8)+(HORIZONTAL_DISPLAYED-1),
					vga3_attr, 0x0000);
				/* addr does not change after the scroll */
			}
			break;
		default:
			wr_mem(addr, ch);
			wr_mem(addr + AttributeOffset, vga3_attr);
			cursor.b.x++;
			addr++;
	}
	(bios_data_area_ptr->video_cursor_pos)[page] = cursor.w;
	vga3Put(14, addr>>8);	/* update the screen cursor */
	vga3Put(15, addr);

	return regAX.w;
}

void vga3_set_cursor_pos(T_CURSOR_POSITION regDX)
{
	word addr = PixAddr(regDX);

	vga3Put(14, addr>>8);	/* update the screen cursor */
	vga3Put(15, addr);
}

word vga3_get_char_and_attribute(T_CURSOR_POSITION regBX)
{
	T_CURSOR_POSITION cursor, attr_char;
//	byte page = regBX.reg.hi;
	byte page = 0;
	cursor.w = (bios_data_area_ptr->video_cursor_pos)[page];
	cursor.w = PixAddr(cursor);

	vga3Put(18,cursor.reg.hi);
	vga3Put(19,cursor.reg.lo);
	attr_char.reg.lo = vga3Get(31);

	cursor.w += AttributeOffset;

	vga3Put(18,cursor.reg.hi);
	vga3Put(19,cursor.reg.lo);
	attr_char.reg.hi = umap(vga3Get(31));

	return attr_char.w;
}

#define TC T_CURSOR_POSITION

void vga3_blast_characters(TC regAX, TC regBX /* in DX */, word count /* in BX */)
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
			vga3Put(18,cursor.reg.hi);
			vga3Put(19,cursor.reg.lo);
			for (i=0; i<count; i++) {
				vga3Put(31, attr);
			}
		}
		cursor.w -= AttributeOffset;
	}

	if (count > 3)
		FillMemory(cursor.w, count, regAX.reg.lo);
	else {
		vga3Put(18,cursor.reg.hi);
		vga3Put(19,cursor.reg.lo);
		for (i=0; i<count; i++) {
			vga3Put(31, regAX.reg.lo);
		}
	}
}


byte CDECL SetMemSize8563(byte size)
{
	byte	reg28, original = 16;

	reg28 = vga3Get(28);
	if (reg28 & 16)  original = 64;

	if (size == 64) reg28 |= 16;
	else if (size == 16) reg28 &= ~16;

	vga3Put(28, reg28);

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


#endif	/* major zap */

/* end vga3lib.c */
