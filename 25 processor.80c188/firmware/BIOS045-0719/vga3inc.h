/*************************************************************************
*  vga3inc.h -- support include for CVDU text and graphics
*	controller chip 8563 for the N8VEM  SBC-188
*
*   Copyright (C) 2012 John R. Coffman.  All rights reserved.
*   Provided for hobbyist use on the N8VEM SBC-188 board.
*************************************************************************/
#ifndef _VGA3INC_H_
#define _VGA3INC_H_
#include "sbc188.h"
#include "v3std.h"

#include "v3_par1.h"		/* 80 x 25 @ 70hz mode */
#include "vga_def.h"		/* initialization table */


#define YPitch HORIZONTAL_DISPLAYED

/*#define CDECL __cdecl */
#define CDECL

#define FASTCALL __fastcall



void CDECL LoadScreen(void);
void CDECL SetScreenAttrib(void);
int  Init_vga3(byte mode);
void CDECL LoadFont(void);
void vga3Put(byte,byte);
byte vga3Get(byte );
void CDECL FillMemory(word from, word count, byte data);
void CDECL CopyMemory(word to, word from, word count);
word FASTCALL vga3_tty_out(T_CURSOR_POSITION regAX, T_CURSOR_POSITION regBX);
void vga3_set_cursor_pos(T_CURSOR_POSITION regDX);
#if 0
byte CDECL SizeMemory8563(void);
byte CDECL SetMemSize8563(byte size);
#endif

/*#undef CDECL*/

#endif /* _VGA3INC_H_ */
/* end vga3inc.h */
