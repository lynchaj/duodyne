/*************************************************************************
*  M8563inc.h -- support include for CVDU text and graphics
*	controller chip 8563 for the N8VEM  SBC-188
*
*   Copyright (C) 2012 John R. Coffman.  All rights reserved.
*   Provided for hobbyist use on the N8VEM SBC-188 board.
*************************************************************************/
#ifndef _M8563INC_H_
#define _M8563INC_H_
#include "sbc188.h"


#ifdef SBC188
#define BasePort 0x4E0
#else
#define BasePort 0xE0
#endif


//#define CDECL __cdecl
#define CDECL
#define STATIC

#define FASTCALL __fastcall


#define M8563Status BasePort+4		/* rev(2) */
#define M8563Register BasePort+4		/* rev(2) */
#define M8563Data BasePort+0xC		/* rev(3) */


STATIC
void CDECL LoadScreen(void);
STATIC
void CDECL SetScreenAttrib(void);
int  Init8563(byte mode);
void CDECL LoadFont(void);
void M8563Put(byte,byte);
byte M8563Get(byte );
STATIC
void CDECL FillMemory(word from, word count, byte data);
STATIC
void CDECL CopyMemory(word to, word from, word count);
word FASTCALL cvdu_tty_out(T_CURSOR_POSITION regAX, T_CURSOR_POSITION regBX);
void set_cursor_pos(T_CURSOR_POSITION regDX);
STATIC
byte CDECL SizeMemory8563(void);
STATIC
byte CDECL SetMemSize8563(byte size);

//#undef CDECL

#endif /* _M8563INC_H_ */
/* end M8563inc.h */
