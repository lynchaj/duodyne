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
#include "mytypes.h"
#include "config.asm"
#include "sbc188.h"
#include	"equates.h"

#pragma intrinsic(inp,inpw,outp,outpw)

#include "kbd_pc.h"
#include "kbd_stat.h"

/* Multi Io 82c42 */
#define BasePort 0x44C
#define I8242Status BasePort+1
#define I8242CommandRegister BasePort+1
#define I8242Data BasePort

void Init8242(void);
void I8242CommandPut(byte value);	/* put Controller command byte */
int  I8242GetValue(void);				/* get Controller data byte */
void I8242PutKeyboard(byte value);	/* send directly to keyboard */
void I8242UpdateLites(void);
word __fastcall I8242process(byte scancode);



#define KeyboardStatus (bios_data_area_ptr->keyboard_flags_0)
#define KeyboardStatus2 (bios_data_area_ptr->keypad_char)

#define PURGE 256

int PurgeQueue(void)
{
	int i, j;
	int k = -1;

	for (i=PURGE; i; --i) {
		j = I8242GetValue();
		if (j != -1) {
			i = PURGE;
			k = j;
		}
	}
	return k;
}


void Init8242(void)
{
	int t;

	I8242CommandPut(0xa7);	/* disable mouse */
	I8242CommandPut(0xae);	/* enable keyboard */
	PurgeQueue();
	I8242CommandPut(0xaa);	/* self-test */

	while(I8242GetValue() != 0x55) ;
	I8242CommandPut(0x20);	/* read controller status as keycode */
	PurgeQueue();

	KeyboardStatus = 0x20;	/* NumLock ON */
	I8242UpdateLites();
}



void I8242PutKeyboard(byte value)
{
	while ((inp(I8242Status) & 0x02)!=0)  ;
	outp(I8242Data, value);
	while ((I8242GetValue())==-1) ;
}

void I8242UpdateLites(void)
{
	byte value = KeyboardStatus >> 4;

	I8242CommandPut(0xad);		/* disable the keyboard */
	I8242PutKeyboard(0xed);
	I8242PutKeyboard(value & 7);
	I8242CommandPut(0xae);		/* enable the keyboard */
	PurgeQueue();
}

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
