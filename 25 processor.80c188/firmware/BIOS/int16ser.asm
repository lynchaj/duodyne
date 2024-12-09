%ifndef SOFT_DEBUG
;;;%define SOFT_DEBUG 1
%endif
;========================================================================
; int16ser.asm -- Keyboard service implementation using serial port
;========================================================================
;
; Compiles with NASM 2.07, might work with other versions
;
; Copyright (C) 2010 Sergey Kiselev.
; Provided for hobbyist use on the N8VEM SBC-188 board.
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
; UPDATES:
;       31-Dec-2010 -- JRCoffman - add HLT to fn00 code.
;	17-Oct-2010 -- JRCoffman - fix .5 label bug & add ctrl-B debugger
;			escape.
;
; TODO:
; - add UART autodetection and FIFO for 16550
; - add escape sequence handling for function keys
; - raw mode (e.g. for firmware uploads)
; - Ctrl-Alt-Del (not possible literally, some other keys for soft reboot)
;========================================================================

%include	"config.asm"
%include	"cpuregs.asm"
%include	"equates.asm"

offset_BP	equ	0
offset_BX	equ	offset_BP+2
offset_DS	equ	offset_BX+2
offset_IP	equ	offset_DS+2
offset_CS	equ	offset_IP+2
offset_FLAGS	equ	offset_CS+2

	SEGMENT	_TEXT
;========================================================================
; BIOS call entry for keyboard service
;	int  16h
;========================================================================
	global  BIOS_call_16h
BIOS_call_16h:			; Keyboard service entry
	sti			; Enable interrupts
	pushm   bp,bx,ds	; Standard register save
	mov	bp,sp		; establish stack addressing

	push	bios_data_seg
	popm	ds		; establish addressability

	mov     bl,ah		; set to index into dispatch table
	mov	bh,0

	cmp     bl,.max/2
	jae    	.testEnh
	add	bx,bx		; index words
    cs	jmp     near [.dispatch+bx]

.testEnh:
	sub	bl,10h
	cmp	bl,.max10/2
	jae	err_exit
	add	bx,bx		; index words
    cs	jmp	near [.dispatch10+bx]

.dispatch:
	dw      fn00		; Read char from buffer, wait if empty
	dw      fn01		; Check buffer, do not clear
	dw      fn02		; Return Keyboard flags in AL
	dw	err_exit	; Set Repeat Rate
	dw	err_exit	; Set Keyclick
	dw	fn05		; Push Char and Scan Code in CX
.max	equ     $-.dispatch

.dispatch10:
	dw	fn10		; Read Enhanced Keyboard
	dw	fn11		; Check Enh. kbd buffer
	dw	fn12		; Get Enh. kbd flags in AX
.max10	equ	$-.dispatch10

err_exit:
	or	word [offset_FLAGS+bp],41h	; set the Carry & Zero flags
exit:
	popm	bp,bx,ds
	iret

;========================================================================
; Function 00h - Read char from buffer, wait if empty
; Input:
;	AH = 00h	PC
;	AH = 10h	enhanced
; Output:
;	AH = scan code
;	AL = character
;========================================================================
fn00w:
%if SOFT_DEBUG
	jmp	fn001
%else
        hlt                     ; wait for interrupt
%endif
;;;	jmp	fn001

fn00:
fn10:

fn001:
	mov	bx,word [kbd_buffer_head]
	cmp	bx,word [kbd_buffer_tail]
	jz	fn00w		; buffer is empty - let's wait
	mov	ax,word [bx]

	inc	bx		; move kbd_buffer_head to the next location
	inc	bx
	cmp	bx,kbd_buffer_last
	jne	.1
	mov	bx,kbd_buffer
.1:
	mov	word [kbd_buffer_head],bx
	jmp	exit

;========================================================================
; Function 01h - Check buffer, do not clear
; Function 11h - Check Enhanced Keyboard buffer
; Input:
;	AH = 01h	PC
;	AH = 11h	enhanced
; Output:
;	ZF - clear if character in buffer
;		AH = scan code
;		AL = character
;	ZF - set if no character in buffer
;========================================================================
fn01:
fn11:
	mov	bx,word [kbd_buffer_head]
	cmp	bx,word [kbd_buffer_tail]
	jz	.1
	mov	ax,word [bx]
	and	word [bp+offset_FLAGS],~40h	; clear ZF in the stack
	jmp	exit
.1:
	or	word [bp+offset_FLAGS],40h	; set ZF in the stack
	jmp	exit

;========================================================================
; Function 02h - Return Keyboard Shift Key Status
; Function 12h - Return Enhanced Keyboard Shift/Alt/Ctrl/NumLock Status
; Input:
;	AH = 02h	PC-keyboard
;	AH = 12h	enhanced
; Output:
;	AL = shift status bits
;		0 = right shift key depressed
;		1 = left shift key depressed
;		2 = CTRL depressed
;		3 = ALT depressed
;		4 = SCROLL LOCK active
;		5 = NUM LOCK active
;		6 = CAPS LOCK active
;		7 = INSERT state active
;
;  and for Function 12h:
;	AX = enhanced keyboard status, above plus:
;		8 = left CTRL key down
;		9 = left ALT key down
;		10 = right CTRL key down
;		11 = right ALT key down
;		12 = SCROLL key is down
;		13 = NUM LOCK key is down
;		14 = CAPS LOCK key is down
;		15 = SYSREQ key is down
;
;========================================================================
fn02:
	mov	al,byte [keyboard_flags_0]
	jmp	exit
fn12:
	mov	ax,word [keyboard_flags_0]
	jmp	exit

;========================================================================
; Function 05h - Check buffer, do not clear
; Input:
;	AH = 05h
;	CH = scan code
;	CL = character
; Output:
;	CF - clear if successful
;	AL = 00h
;
;	CF - set if buffer full
;	AL = 01h
;========================================================================
fn05:
	mov	ax,cx		; AX is argument to enqueue
	call	enqueue		; DS is bios_data_seg
	jc	.2
	mov	ax,0501h
	jmp	err_exit

.2:	mov	ax,0500h
	and	word [offset_FLAGS+bp],~01h	; clear the carry
	jmp	exit



;========================================================================
; enqueue - add a word in AX to the keyboard buffer
;
;  Input:
;	DS = bios data area pointer
;	AH = scan code
;	AL = character
;  Uses:
;	BX
;
;  Output:
;	the word is enqueued or discarded if buffer is full
;========================================================================
enqueue:
; do we have space in the buffer?
	mov	bx,word [kbd_buffer_tail]
	inc	bx
	inc	bx
	cmp	bx,kbd_buffer_last
	jne	.3
	mov	bx,kbd_buffer
.3:
	cmp	bx,word [kbd_buffer_head]
	jne	.4
			; no space in buffer, throw away char
			; but check for the next one anyway
	stc
	ret		; Return with carry Set if no space

.4:	; we have some space in the buffer
	mov	bx,word [kbd_buffer_tail]
	mov	word [bx],ax	; store ASCII and scan code to the buffer
	inc	bx
	inc	bx
	cmp	bx,kbd_buffer_last
	jne	.5
	mov	bx,kbd_buffer
.5:
	mov	word [kbd_buffer_tail],bx
	clc		; Return with carry clear if A-okay
	ret


;========================================================================
; multiio_kbd_hook - examine keyboard on every timer tick
;========================================================================
	global	multiio_kbd_hook
multiio_kbd_hook:
	call	I8242GetValue_
	jnc	.2
	ret
.2:
	pushm	all,ds,es	; save EVERYTHING
.1:
	mov	AH,4Fh		; keyboard intercept
	stc			; so we can respond with IRET
	int	15h
	jnc	.20		; scancode to be bypassed

	push	DGROUP
	popm	ds		; establish addressability
	extern	@I8242process
	call	@I8242process	; convert to scan code // character

	push	bios_data_seg
	popm	ds

	or	ax,ax		; test for zero (unknown input)
	jnz	.21

.20:
	call	I8242GetValue_
	jc	.exit
	jmp	.1
.21:
	cmp	al,0E0h		; enhanced keyboard?
	jne	.3
	xor	al,al		; old PC keyboard
.3:
	cmp	ax,1234h	; Ctrl-Alt-DEL
	jne	.33
	int	19h		; re-boot the system

.33:
	call	enqueue
	mov	byte [uart_kbd_ctrl_R], 0

.exit:

;   Hook service
	popm	all,ds,es
	ret


;========================================================================
; UART interrupt handler
; This routine does most of the keyboard driver work
;========================================================================
	global	uart_int
uart_int:
	pushm	ax,bx,dx,ds
	push	bios_data_seg
	popm	ds		; establish addressability
%if SOFT_DEBUG
	push	0xFF
	extern	lites
	call	lites
	hlt
%endif
.1:
	mov	dx,uart_lsr
	in	al,dx
	and	al,01h		; do we have any data in receive buffer?
	jz	int_exit

	mov	dx,uart_rbr
	in	al,dx		; get next character

	mov	ah,0
	cmp	al,80h		; the ASCII code =< 80?
	jae	.1		; ignore, check for the next character
%if SOFT_DEBUG
	cmp	al,'B' & 01Fh	; ctrl-B
	je	v.redbug
%endif
	cmp	al,('R' & 01Fh)	; ctrl-R
	jne	.20
	inc	byte [uart_kbd_ctrl_R]
	cmp	byte [uart_kbd_ctrl_R], 3	; 3 ctrl-R's will re-boot
	jb	.2
%if 1
	int	19h		; does not return
%else
	mov	word [warm_boot],1234h		; signal warm boot
	jmp	0FFFFh:0000h
%endif
.20:
	mov	byte [uart_kbd_ctrl_R], 0	; zero the re-boot count
.2:
	mov	bl,al		; find the scan code
	mov	bh,0
    cs	mov	ah,byte [ascii2scan+bx]

    	call	enqueue

	jmp	.1		; check for the next character

int_exit:
; signal EOI (End of Interrupt)
	mov	dx,PIC_EOI	; EOI register
	mov	ax,EOI_NSPEC	; non-specific
	out	dx,ax		; signal it

	popm	ax,bx,dx,ds
	iret

; Debugging code added 10/17/2010 -- JRC
;  Use ctrl-B (^B) as immediate entry into the debugger
%if SOFT_DEBUG
	extern	redbug
v.redbug:
; signal EOI (End of Interrupt)
	mov	dx,PIC_EOI	; EOI register
	mov	ax,EOI_NSPEC	; non-specific
	out	dx,ax		; signal it
; restore the registers
	popm	ax,bx,dx,ds
; keep the 'iret' block on the stack
	jmp	redbug
%endif

ascii2scan:
	;	NUL,SOH,STX,ETX,EOT,ENQ,ACL,BEL
	db	0,  0,  0,  0,  0,  0,  0,  0,
	;	BS, TAB,LF, VT, FF, CR, SO, SI
	db      0Eh,0Fh,0,  0,  0,  1Ch,0  ,0
	;	DLE,DC1,DC2,DC3,DC4,NAK,SYN,ETB
	db	0,  0,  0,  0,  0,  0,  0,  0,
	;	CAN,EM, SUB,ESC,FS, GS, RS, US
	db      0,  0,  0,  01h,0,  0,  0,  0,
	;	 ,  !,  ",  #,  $,  %,  &,  '
	db	39h,02h,28h,04h,05h,06h,08h,28h
	;	(,  ),  *,  +,  ,,  -,  .,  /
	db	0Ah,0Bh,09h,0Dh,33h,0Ch,34h,35h
	;	0,  1,  2,  3,  4,  5,  6,  7
	db	0Bh,02h,03h,04h,05h,06h,07h,08h
	;	8,  9,  :,  ;,  <,  =,  >,  ?
	db	09h,0Ah,27h,27h,33h,0Dh,34h,35h
	;	@,  A,  B,  C,  D,  E,  F,  G
	db	03h,1Eh,30h,2Eh,20h,12h,21h,22h
	;	H,  I,  J,  K,  L,  M,  N,  O
	db	23h,17h,24h,25h,26h,32h,31h,18h
	;	P,  Q,  R,  S,  T,  U,  V,  W
	db	19h,10h,13h,1Fh,14h,16h,2Fh,11h
	;	X,  Y,  Z,  [,  \,  ],  ^,  _
	db	2Dh,15h,2Ch,1Ah,2Bh,1Bh,07h,0Ch
	;	`,  a,  b,  c,  d,  e,  f,  g
	db	29h,1Eh,30h,2Eh,20h,12h,21h,22h
	;	h,  i,  j,  k,  l,  m,  n,  o
	db	23h,17h,24h,25h,26h,32h,31h,18h
	;	p,  q,  r,  s,  t,  u,  v,  w
	db	19h,10h,13h,1Fh,14h,16h,2Fh,11h
	;	x,  y,  z,  {,  |,  },  ~,  DEL
	db	2Dh,15h,2Ch,1Ah,2Bh,1Bh,29h,53h

;========================================================================
; keyboart_init - initialize keyboard
;========================================================================
	global	keyboard_init
keyboard_init:
	pushm	all,ds,es	; was AX,DS,ES


	push	DGROUP
	popm	ds

	push	bios_data_seg
	popm	ds

	mov	ax,kbd_buffer	; setup keyboard buffer
	mov	word [kbd_buffer_head],ax
	mov	word [kbd_buffer_tail],ax
	xor	ax,ax		; clear keyboard flags
	mov	word [keyboard_flags_0],ax

%if UART
	mov	al,01h
	mov	dx,uart_ier
	out	dx,al		; Enable interrupts on receive

	mov	dx,PIC_I0CON	; Int 1 control register
	in	ax,dx
	and	ax,~08h		; clear the mask bit
	out	dx,ax
%endif

	mov dx,FRONT_PANEL_LED
	in al, dx
	and al,80h
	jz .1
	extern	Init8242_
	call	Init8242_
.1:
	popm	all,ds,es
	ret

;========================================================================
; uart_getchar - Read char from buffer, wait if empty
; Input:
; 	none
; Output:
;	AL = character
;	AH = 0
;========================================================================
	global	@uart_getchar
@uart_getchar:
	mov	ah,0
	int	16h
	mov	ah,0
	ret


;========================================================================
;  void I8242CommandPut(byte value);
; Input:
;	AL = command byte
; Output:
;	none
;========================================================================
	global I8242CommandPut_
I8242CommandPut_:
	push	dx
	mov	ah,al		; save the command byte
.1:	mov	dx,MultiIo8242+1
	in	al,dx
	test	al,2
	jnz	.1
	mov	dx,MultiIo8242+1
	mov	al,ah
	out	dx,al
	pop	dx
	ret


;========================================================================
;  int I8242GetValue(void);
; Input:
;	none
; Output:
;	AX = -1		no value available (C-flag set)
;	AX = input byte	if available	   (C-flag clear)
;
;========================================================================
	global	I8242GetValue_
I8242GetValue_:
	push	dx
	mov	dx,MultiIo8242+1
	in	al,dx
	test	al,1
	jz	.7
	mov	dx,MultiIo8242
	in	al,dx
	xor	ah,ah		; clear high byte for 'int' return
	jmp	.9
.7:
	mov	ax,-1
	stc
.9:	pop	dx
	ret