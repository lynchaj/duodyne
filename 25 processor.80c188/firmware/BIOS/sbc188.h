/*************************************************************************
*  sbc188.h
*
*   Copyright (C) 2010 John R. Coffman.  All rights reserved.
*   Provided for hobbyist use on the N8VEM SBC-188 board.
*************************************************************************/
#ifndef __SBC188_H
#define __SBC188_H 1
#include "mytypes.h"

#ifndef SBC188
# error "SBC188 must be defined"
#endif

/* universal alias for the BIOS */
#define printf cprintf

#ifdef _MSC_VER
#if _MSC_VER<600
# define __fastcall
# define __cdecl _cdecl
#endif
#endif

int __cdecl cprintf(const char * fmt, ...);

#pragma aux remLS "@*" parm caller [dx ax] [bx] value [ax] modify [cx]
word remLS(dword dividend, word divisor);
#pragma aux divLS "@*" parm caller [dx ax] [bx] value [dx ax] modify [cx]
dword divLS(dword dividend, word divisor);
#pragma aux mulLS "@*" parm caller [dx ax] [bx] value [dx ax] modify [cx]
dword mulLS(dword factor1, word factor2);

#if defined(_M_IX86)
__declspec(__watcall) extern unsigned inp(unsigned __port);
__declspec(__watcall) extern unsigned inpw(unsigned __port);
__declspec(__watcall) extern unsigned outp(unsigned __port, unsigned __value);
__declspec(__watcall) extern unsigned outpw(unsigned __port,unsigned __value);
#endif

#if defined(__INLINE_FUNCTIONS__) && defined(_M_IX86)
 #pragma intrinsic(inp,inpw,outp,outpw)
#endif


void __fastcall microsecond(word count);		/* in RBIOS.ASM */

void __fastcall uart_putchar(char ch);
int __fastcall uart_getchar();
void __fastcall VIDEO_putchar(char ch, char attr);

#endif /* __SBC188_H */
