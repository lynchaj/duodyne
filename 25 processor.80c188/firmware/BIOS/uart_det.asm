;========================================================================
; uart_detect - detect UART type, enable FIFO if present
;========================================================================
;
; Copyright (C) 2012,2020 John R Coffman.  All rights reserved.
; Provided for hobbyist use on the RetroBrew Computers' SBC-188 boards.
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
;========================================================================
; History:
;   Derived from the RetroBrew/JRCoffman UNA source code 'uart_det.s'
;   Copyright (C) 2012 John Coffman.  All rights reserved.
;   Distributed under the above GPL license.
;========================================================================
%ifdef STANDALONE
%include "config.asm"
%include "cpuregs.asm"
;
; C-language interface:
;	unsigned char near uart_det(unsigned dev);
	global	uart_det_
   SEGMENT  _TEXT ALIGN=2 PUBLIC CLASS=CODE
uart_det_:
	mov	dx,ax
	call	uart_detect
	ret
%endif
;========================================================================
; uart_detect - detect UART type, enable FIFO if present
;
; Input:
;	DX = UART device code to probe
;
; Output:
;	AL = UART type
;
; UART detection code from
; http://en.wikibooks.org/wiki/Serial_Programming/8250_UART_Programming
;========================================================================
UART_NONE	equ	0	; no UART detected
UART_8250	equ	1	; no Scratch register
UART_16450	equ	2	; or 8250A
UART_16550	equ	3
UART_16550A	equ	4
UART_16550C	equ	5
UART_16650	equ	6
UART_16750	equ	7
UART_16850	equ	8
;*******************************************************************
;***N.B.:  the above list must be kept in sync with 'sio.h' enum ***
;*******************************************************************

; macros assume DI is set to base UART register
%macro	uget 2		; dest reg8, src UART reg or offset
	mov	bl,(%2)&0xFF
	call	udet_get
	mov	%1,al
%endmacro

%macro	uput 2		; dest UART reg or offset, src reg8
	mov	bl,(%1)&0xFF
	mov	al,%2
	call	udet_put
%endmacro

%macro	 ucmp 2		; dest UART reg (read to AL), src reg8 or value
	mov	bl,(%1)&0xFF
	call	udet_get
	cmp	al,(%2)&0xFF
%endmacro

uart_detect:
	pushm	dx,cx,bx,di
	xor	cx,cx		; no uart present CL=0
	and	dx,~7		; mask 8 UART registers
	mov	di,dx		; device base to di
; UART is present if toggling the DLAT bit in LCR makes divisor available
	uget	ch,uart_lcr	; save LCR value
	uput	uart_lcr,0	; make DLAT inaccessible
	uput	uart_ier,0	; IER==DLM
	uput	uart_lcr,0x80	; LCR  set DLAT bit
	uget	bh,uart_dlm	; save DLM
	uput	uart_dlm,0x5a	; DLM==IER  set some pattern
	ucmp	uart_dlm,0x5a	; does it read back the same?
	jne	.exit		; no UART here
	uput	uart_lcr,0x00	; LCR=00, reset DLAT
	ucmp	uart_dlm,0x5a	; is it still 0x5A?
	je	.exit		; no uart if still 0x5A

; restore DLM
	uput	uart_lcr,0x80
	uput	uart_dlm,bh
	and	ch,~0x80	; clear DLAT
	uput	uart_lcr,ch	; restore DLAT
	inc	cx		; UART=8250 or above is present
; look for the Scratch register
	uput	uart_sr,0x5a	; set a value
	ucmp	uart_sr,0x5a	; does it read back
	jne	.exit		; test for no Scratch register

	inc	cx		; 8250A, 16450 or higher
	uput	uart_lcr,0xBF	; special value for higher UARTs
	ucmp	uart_sr,0x5A	; is it still 0x5a?
	je	.below650
	mov	cl,6		; it is a 16650 or 16850, which cannot
	jmp	.exit		;  be distinguished
.below650:
; UART is 16550C or below
	uput	uart_lcr,0x80	; set DLAT again
	uput	uart_fcr,0xE1	; output to FCR (FIFO Control)
	uget	bh,uart_iir	; FCR=IIR
	uput	uart_lcr,0x07	; reset the LCR DLAT bit & set 8n2
; test for a FIFO
	test	bh,1<<6		; test low order FIFO bit
	jz	.exit		; 16450 if zero

	inc	cx		; 16550 or higher
	test	bh,1<<7		; test high FIFO bit
	jz	.exit		; 16550 if zero

	inc	cx		; 16550A or higher
	test	bh,1<<5		; test for 64-byte FIFO
	jz	.is550AorC
; has a 64-byte FIFO
	mov	cl,7		; it is a 16750
	jmp	.exit

; two levels of UART left to distinguish
.is550AorC:
;;;;				; 16550A or higher
	uget	bh,uart_mcr	; save MCR setting
	or	bh,1<<5		; set bit 5
	uput	uart_mcr,bh	; set the AFE bit (auto flowcontrol enable)
	uget	bh,uart_mcr	; read it back
	test	bh,1<<5		; is the bit still set
	jz	.exit
	inc	cx		; 16550C found
	and	bh,0xFF-(1<<5)	; clear the AFE bit
	uput	uart_mcr,bh	; AFC is broken on DIP version of 16550
.exit:
	mov	al,cl		; return UART ID
	cbw
	popm	dx,cx,bx,di
	ret

udet_put:
	push	bx
	and	bx,7		; mask to uart offset
	lea	dx,[di+bx]	; device code to DX
	out	dx,al
	pop	bx
	ret
udet_get:
	push	bx
	and	bx,7		; mask to uart offset
	lea	dx,[di+bx]	; device code to DX
	in	al,dx
	pop	bx
	ret



;========================================================================
; is_present_4UART -- check for presence of 4UART board
;
; Input:
;	none
;
; Output:
;	AX = 0	if board is not present
;	  != 0	if board is present (returns base device code, 4C0h or 4A0h
;
;
; C-callable:
;	int is_present_4UART(void);
;
; UART detection code from
; http://en.wikibooks.org/wiki/Serial_Programming/8250_UART_Programming
;========================================================================
	global	is_present_4UART_

is_present_4UART_:		; Watcom calling convention
	pushm	dx,si
	mov	dx,dev_4UART_D
	call	uart_detect
	cmp	al,UART_16650
	jne	.not_present

	mov	dx,dev_4UART_C
	call	uart_detect
	cmp	al,UART_16650
	jne	.not_present

; dangerouts to test the B_uart, since the 4UART control register
; overlays the B_uart scratch register.  However, the uart_detect
; code above does not set bit 7, which is the LOCKOUT bit.
%if 0
	mov	dx,dev_4UART_B
	call	uart_detect
	cmp	al,UART_16650
	jne	.not_present
%endif

	mov	dx,dev_4UART_A
	call	uart_detect
	cmp	al,UART_16650
	jne	.not_present

	mov	AX,dev_4UART_base
	jmp	.return	
.not_present:
	xor	ax,ax
.return:
	popm	dx,si
	ret





;========================================================================
; is_present_2S1P -- check for presence of 2S1P board
;	!!! This test may only be done IFF the 4UART board is NOT present
;	Otherwise, the 4UART control register may be damaged.
;
; Input:
;	none
;
; Output:
;	AX = 0	if board is not present
;	  != 0	if board is present (returns base device code, 4C0h or 4A0h
;
;
; C-callable:
;	int is_present_2S1P(void);
;
; UART detection code from
; http://en.wikibooks.org/wiki/Serial_Programming/8250_UART_Programming
;========================================================================
	global	is_present_2S1P_

is_present_2S1P_:		; Watcom calling convention
	pushm	dx,si

	mov	dx,dev_2S1P_C+8	; board selects, but there is nothing there
	call	uart_detect
	cmp	al,UART_NONE	; if a UART is there, it may be 4UART board
	jne	.not_present

	mov	dx,dev_2S1P_C
	call	uart_detect
	cmp	al,UART_NONE
	jne	.not_present

	mov	dx,dev_2S1P_B
	call	uart_detect
	cmp	al,UART_16550A		; value for TL16C552 chip
	jne	.not_present

	mov	dx,dev_2S1P_A
	call	uart_detect
	cmp	al,UART_16550A		; value for TL16C552 chip
	jne	.not_present

	mov	AX,dev_2S1P_base
	jmp	.return	
.not_present:
	xor	ax,ax
.return:
	popm	dx,si
	ret













;;; end of UART_DET.ASM

