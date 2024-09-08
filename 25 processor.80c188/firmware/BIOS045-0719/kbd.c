/*************************************************************************
*  kbd.c   for the N8VEM  SBC-188
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
/* kbd.c   */
#include <stdio.h>
#include <stdlib.h>
/*#include <conio.h>*/
#include "mytypes.h"
#include "config.asm"
#include "sbc188.h"
#include	"equates.h"

#pragma intrinsic(inp,inpw,outp,outpw)

#define STANDALONE 0

#include "kbd_pc.h"
#include "kbd_stat.h"



#ifdef SBC188
#define BasePort 0x4E0
#else
#define BasePort 0xE0
#endif

/* watch out, CVDU & CVDU_8563 are only defined in assembly files */
#if VGA3==0
#define I8242Status BasePort+0xA		/* rev(5) */
#define I8242CommandRegister BasePort+0xA	/* rev(5) */
#define I8242Data BasePort+2			/* rev(4) */
#else
/* this came in from 'config.asm' with VGA3 defined */
#define I8242Status BasePort+1
#define I8242CommandRegister BasePort+1
#define I8242Data BasePort
#endif

void Init8242(void);
void I8242CommandPut(byte value);	/* put Controller command byte */
int  I8242GetValue(void);				/* get Controller data byte */
void I8242PutKeyboard(byte value);	/* send directly to keyboard */
void I8242UpdateLites(void);
word __fastcall I8242process(byte scancode);


#if STANDALONE==0

#define KeyboardStatus (bios_data_area_ptr->keyboard_flags_0)
//#define LiteByte (bios_data_area_ptr->unused_01)
#define KeyboardStatus2 (bios_data_area_ptr->keypad_char)

#else

word KeyboardStatus;
//byte LiteByte;
byte KeyboardStatus2;		/* for E0 flagging */

void main(int argc, char* argv[])
{
	int t=-1;
	int s=-1;

	printf("Test 82C42 Keyboard Controller\n"); 
	Init8242();
	
	while(s!=1)
	{
		s=t=I8242GetValue();
		if(t!=-1) {
			printf("KK->%x",t);
			t = I8242process((byte)t);
			if (t) {
				printf("  AA->%04x",t);
				t &= 0377;
				if (t>=040&&t<0177) printf("  CC->%c",t);
			}
			printf("\n");
		}
	}
	I8242SetLites(0);		/* reset all the lites */
    exit(0);
}
#endif
/* end STANDALONE */



#define PURGE 256
int PurgeQueue(void)
{
	int i, j;
	int k = -1;

	for (i=PURGE; i; --i) {
		j = I8242GetValue();
		if (j != -1) {
#if TESTING
			printf("Q-->%02x\n", j);
#endif
			i = PURGE;
			k = j;
		}
	}
	return k;
}


void Init8242(void)
{
	int t;

//	PurgeQueue();
	I8242CommandPut(0xa7);	/* disable mouse */
//	PurgeQueue();
	I8242CommandPut(0xae);	/* enable keyboard */
	PurgeQueue();
	I8242CommandPut(0xaa);	/* self-test */
	while(I8242GetValue() != 0x55) ;
	I8242CommandPut(0x20);	/* read controller status as keycode */
	PurgeQueue();
//	while(PurgeQueue() != 0x71) ;

	KeyboardStatus = 0x20;	/* NumLock ON */
	I8242UpdateLites();
//	PurgeQueue();
}

#if 0
void I8242CommandPut(byte value)
{
 while ((inp(I8242Status) & 0x02)!=0);	
    outp(I8242CommandRegister, value);
 	
}

int I8242GetValue(void)
{
 if(!(inp(I8242Status) & 0x01)) return -1;
 return inp(I8242Data); 	
}
#endif

void I8242PutKeyboard(byte value)
{
//	int t;

	while ((inp(I8242Status) & 0x02)!=0)  ;	
	outp(I8242Data, value);
	while ((/*t=*/I8242GetValue())==-1) ;
//	printf("Ak->%x\n",t);

}

#if 1
void I8242UpdateLites(void)
{
	byte value = KeyboardStatus >> 4;

	I8242CommandPut(0xad);		/* disable the keyboard */
	I8242PutKeyboard(0xed);
	I8242PutKeyboard(value & 7);
	I8242CommandPut(0xae);		/* enable the keyboard */
	PurgeQueue();
}

#else
void I8242SetLites(byte value)
{
	if (LiteByte == value) return;

	I8242CommandPut(0xad);		/* disable the keyboard */
	I8242PutKeyboard(0xed);
	I8242PutKeyboard(value);
	I8242CommandPut(0xae);		/* enable the keyboard */
	LiteByte = value;
}

void SetLite(byte value)
{
	I8242SetLites(LiteByte | value);
}

void ResetLite(byte value)
{
	I8242SetLites(LiteByte & ~value);
}
#endif


word I8242process(byte scancode)
{
	word ascii;

	if (scancode == 0xE0) {
		KeyboardStatus2 |= MaskE0;
		return 0;
	}

	if (KeyboardStatus & MaskAnyShift)
		ascii = (word)trans_shifted[scancode&0x7F];
	else
		ascii = (word)trans_no_shift[scancode&0x7F];

	if (ascii > ACT) {		/* special keypress for action */
		if (KeyboardStatus2 & MaskE0) ascii++;
		switch(ascii) {
			case RSH:
				if (scancode & UP) KeyboardStatus &= ~MaskRightShift;
				else KeyboardStatus |= MaskRightShift;
				break;
			case LSH:
				if (scancode & UP) KeyboardStatus &= ~MaskLeftShift;
				else KeyboardStatus |= MaskLeftShift;
				break;
			case CAP:
				if (scancode & UP) KeyboardStatus &= ~MaskCapsLockDown;
				else {
					/* must be DOWN */
					if ( !(KeyboardStatus & MaskCapsLockDown) )  {
						KeyboardStatus |= MaskCapsLockDown;
						KeyboardStatus ^= MaskCapsLock;
					}
				}
				I8242UpdateLites();
#if 0
				if (KeyboardStatus & MaskCapsLock)
					SetLite(4);
				else ResetLite(4);
#endif
				break;
			case NUM:
				if (scancode & UP) KeyboardStatus &= ~MaskNumLockDown;
				else {
					/* must be DOWN */
					if ( !(KeyboardStatus & MaskNumLockDown) )  {
						KeyboardStatus |= MaskNumLockDown;
						KeyboardStatus ^= MaskNumLock;
					}
				}
				I8242UpdateLites();
#if 0
				if (KeyboardStatus & MaskNumLock)
					SetLite(2);
				else ResetLite(2);
#endif
				break;
			case SCR:
				if (scancode & UP) KeyboardStatus &= ~MaskScrollDown;
				else {
					/* must be DOWN */
					if ( !(KeyboardStatus & MaskScrollDown) )  {
						KeyboardStatus |= MaskScrollDown;
						KeyboardStatus ^= MaskScrollLock;
					}
				}
				I8242UpdateLites();
#if 0
				if (KeyboardStatus & MaskScrollLock)
					SetLite(1);
				else ResetLite(1);
#endif
				break;
			case RCN:	/* right Control key */
				if (scancode & UP) {
					KeyboardStatus &= ~MaskRightCtrl;
					if (!(KeyboardStatus & MaskEitherCtrl))
						KeyboardStatus &= ~MaskCtrlOn;
				} else
					KeyboardStatus |= (MaskRightCtrl | MaskCtrlOn);
				break;
			case LCN:
				if (scancode & UP) {
					KeyboardStatus &= ~MaskLeftCtrl;
					if (!(KeyboardStatus & MaskEitherCtrl))
						KeyboardStatus &= ~MaskCtrlOn;
				} else
					KeyboardStatus |= (MaskLeftCtrl | MaskCtrlOn);
				break;
			case RAL:	/* right Alt key */
				if (scancode & UP) {
					KeyboardStatus &= ~MaskRightAlt;
					if (!(KeyboardStatus & MaskEitherAlt))
						KeyboardStatus &= ~MaskAltOn;
				} else
					KeyboardStatus |= (MaskRightAlt | MaskAltOn);
				break;
			case LAL:	/* left Alt key */
				if (scancode & UP) {
					KeyboardStatus &= ~MaskLeftAlt;
					if (!(KeyboardStatus & MaskEitherAlt))
						KeyboardStatus &= ~MaskAltOn;
				} else
					KeyboardStatus |= (MaskLeftAlt | MaskAltOn);
				break;
		}
		ascii = 0;
	}
	else if (ascii == FUN && !(scancode & UP) ) {	/* F1 to F10 */
		ascii = (word)scancode;
		if (KeyboardStatus & MaskAltOn)
			ascii += (0x68-0x3B);
		else if (KeyboardStatus & MaskCtrlOn)
			ascii += (0x5E-0x3B);
		else if (KeyboardStatus & (MaskRightShift|MaskLeftShift))
			ascii += (0x54-0x3B);
		ascii <<= 8;
	}
	else if (ascii == FFN && !(scancode & UP) ) {	/* F11 & F12 */
		ascii = (word)scancode + (0x85-0x57);
		if (KeyboardStatus & MaskAltOn)
			ascii += 6;
		else if (KeyboardStatus & MaskCtrlOn)
			ascii += 4;
		else if (KeyboardStatus & (MaskRightShift|MaskLeftShift))
			ascii += 2;
		ascii <<= 8;
	}
	else if (ascii == KPD && !(scancode & UP) ) {	/* Grey Keypad */
		if ( !!(KeyboardStatus & MaskNumLock) ^ !!(KeyboardStatus & MaskAnyShift) )
			ascii = keypad_numlock[(scancode & ~UP) - 0x47];
		else
			ascii = (KeyboardStatus2 & MaskE0) ? 0xE0 : 0;
		ascii |= (word)scancode << 8;
		if (scancode == 0x53 /* DEL */	&&
				(MaskCtrlAlt & ~(KeyboardStatus))==0  )  ascii = 0x1234; /* warm boot */
	}
	else if (ascii && !(scancode & UP) ) {			/* ascii character */
		if (KeyboardStatus & MaskCapsLock) {
			if (ascii>='A' && ascii<='Z'  ||  ascii>='a' && ascii<='z')
				ascii ^= 'a'-'A';
		}
		if (KeyboardStatus & MaskCtrlOn) ascii &= 0x1F;
		ascii |= (word)scancode << 8;
	}
	else ascii = 0;
	/* else NUL, return pure zero */
	KeyboardStatus2 &= ~MaskE0;

	return ascii;
}

