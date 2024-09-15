;========================================================================
; tests.asm -- various h/w tests
;------------------------------------------------------------------------
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
; TODO:
;========================================================================

	extern	_cprintf

%include	"config.asm"
%include	"equates.asm"

	segment	_TEXT

;========================================================================
; tests - run tests
;========================================================================
	global	tests
tests:
	push	ds
	push	msg_tests
	call	_cprintf
	add	sp,4
	mov	ah,0
	int	16h
	cmp	al,'v'
	jnz	.1
	call	test_video
	jmp	tests
.1:
	cmp	al,'k'
	jnz	.2
	call	test_keyboard
	jmp	tests
.2:
	cmp	al,'i'
	jnz	.3
	int	21h		; call some interrupt
	jmp	tests
.3:
	cmp	al,'h'
	jnz	.4
	jmp	test_halt
.4:
	cmp	al,'b'
	jnz	.loop
	int	19h		; boot the OS
.loop:
	jmp	tests

;========================================================================
; test_keyboard - wait for key, print its ASCII and scan codes
;========================================================================
test_keyboard:
	push	ds
	push	msg_kbd_test
	call	_cprintf
	add	sp,4
.loop:
	mov	ah,0
	int	16h
	mov	bh,0
	mov	bl,ah
	push	bx
	mov	bl,al
	push	bx
	push	ds
	push	msg_kbd_code
	call	_cprintf
	cmp	al,1Bh		; ESC?
	je	.exit
	add	sp,8
	jmp	.loop

.exit:
	ret

;========================================================================
; test_video - switch video modes and test various int 10h functions
;========================================================================
test_video:
	mov	si,video_modes
	mov	cx,10
.loop:
	push	cx
	mov	ah,02h
	mov	bh,0
	mov	dx,1704h
	int	10h
	mov	ah,0
	mov	al,byte [si]
	push	ax
	push	ax
	push	ds
	push	msg_video_mode_test
	call	_cprintf
	add	sp,6
	mov	ah,0
	int	16h
	pop	ax
	int	10h
	mov	dh,al		; row = mode number
	mov	ah,01h
	mov	cx,2607h
	int	10h
	and	dh,7fh
	add	dh,2
	mov	dl,8
	mov	ax,1302h
	mov	bh,0
	mov	cx,256
	push	ds
	pop	es
	mov	bp,msg_mode_test
	int	10h
	mov	ah,00h
	int	16h

	call	test_int10_fn06
	call	test_int10_fn09

	mov	ah,01h
	mov	cx,0007h
	int	10h
	pop	cx
	inc	si
	loop	.loop

	mov	ax,0007h	; set video mode 7 before exiting
	int	10h
	ret

test_int10_fn06:
	mov	ax,0602h
	mov	bh,3Eh
	mov	cx,0500h
	mov	dx,0827h
	int	10h
	mov	ah,00h
	int	16h
	mov	ax,0701h
	mov	bh,3Eh
	mov	cx,0900h
	mov	dx,0B27h
	int	10h
	mov	ah,00h
	int	16h
	mov	ax,0600h
	mov	bh,3Eh
	mov	cx,0B00h
	mov	dx,0C27h
	int	10h
	mov	ah,00h
	int	16h
	ret

test_int10_fn09:
	mov	ah,02h
	mov	bh,0
	mov	dx,0000h
	int	10h

	mov	ax,0930h
	mov	bx,003Eh
	mov	cx,80*24
	int	10h

	mov	ah,0
	int	16h
	ret

;========================================================================
; test_halt - halt the system
;========================================================================
test_halt:
	push	ds
	push	msg_halted
	call	_cprintf
	add	sp,4
	cli
	hlt
	jmp	test_halt
;========================================================================

        segment	CONST
msg_tests:
	db	"Tests menu", NL
	db	"------------------------------------------------------", NL
	db	'h - halt', NL
	db	"i - call an unitialized interrupt", NL
	db	"k - run keyboard test", NL
	db	"v - run video test", NL
	db	"b - boot the OS", NL
	db	NL
	db	"Please enter your selection:", NL, 0

msg_kbd_test:
	db	"Testing keyboard. Press keys to see their ASCII and scan codes. ESC to exit", NL, 0
msg_kbd_code:
	db	"Keyboard: ASCII=0x%02x, scan=0x%02x", NL, 0
msg_video_mode_test:
	db	"Testing video mode 0x%x. Press any key to continue...", NL,0
video_modes:
	db	00h,01h,02h,03h,07h,80h,81h,82h,83h,07h
msg_mode_test:
	db	'0',00h,'1',01h,'2',02h,'3',03h,'4',04h,'5',05h,'6',06h,'7',07h
	db	'8',08h,'9',09h,'A',0Ah,'B',0Bh,'C',0Ch,'D',0Dh,'E',0Eh,'F',0Fh
	db	'0',10h,'1',11h,'2',12h,'3',13h,'4',14h,'5',15h,'6',16h,'7',17h
	db	'8',18h,'9',19h,'A',1Ah,'B',1Bh,'C',1Ch,'D',1Dh,'E',1Eh,'F',1Fh
	db	'0',20h,'1',21h,'2',22h,'3',23h,'4',24h,'5',25h,'6',26h,'7',27h
	db	'8',28h,'9',29h,'A',2Ah,'B',2Bh,'C',2Ch,'D',2Dh,'E',2Eh,'F',2Fh
	db	'0',30h,'1',31h,'2',32h,'3',33h,'4',34h,'5',35h,'6',36h,'7',37h
	db	'8',38h,'9',39h,'A',3Ah,'B',3Bh,'C',3Ch,'D',3Dh,'E',3Eh,'F',3Fh
	db	'0',40h,'1',41h,'2',42h,'3',43h,'4',44h,'5',45h,'6',46h,'7',47h
	db	'8',48h,'9',49h,'A',4Ah,'B',4Bh,'C',4Ch,'D',4Dh,'E',4Eh,'F',4Fh
	db	'0',50h,'1',51h,'2',52h,'3',53h,'4',54h,'5',55h,'6',56h,'7',57h
	db	'8',58h,'9',59h,'A',5Ah,'B',5Bh,'C',5Ch,'D',5Dh,'E',5Eh,'F',5Fh
	db	'0',60h,'1',61h,'2',62h,'3',63h,'4',64h,'5',65h,'6',66h,'7',67h
	db	'8',68h,'9',69h,'A',6Ah,'B',6Bh,'C',6Ch,'D',6Dh,'E',6Eh,'F',6Fh
	db	'0',70h,'1',71h,'2',72h,'3',73h,'4',74h,'5',75h,'6',76h,'7',77h
	db	'8',78h,'9',79h,'A',7Ah,'B',7Bh,'C',7Ch,'D',7Dh,'E',7Eh,'F',7Fh
	db	'0',80h,'1',81h,'2',82h,'3',83h,'4',84h,'5',85h,'6',86h,'7',87h
	db	'8',88h,'9',89h,'A',8Ah,'B',8Bh,'C',8Ch,'D',8Dh,'E',8Eh,'F',8Fh
	db	'0',90h,'1',91h,'2',92h,'3',93h,'4',94h,'5',95h,'6',96h,'7',97h
	db	'8',98h,'9',99h,'A',9Ah,'B',9Bh,'C',9Ch,'D',9Dh,'E',9Eh,'F',9Fh
	db	'0',0A0h,'1',0A1h,'2',0A2h,'3',0A3h,'4',0A4h,'5',0A5h,'6',0A6h,'7',0A7h
	db	'8',0A8h,'9',0A9h,'A',0AAh,'B',0ABh,'C',0ACh,'D',0ADh,'E',0AEh,'F',0AFh
	db	'0',0B0h,'1',0B1h,'2',0B2h,'3',0B3h,'4',0B4h,'5',0B5h,'6',0B6h,'7',0B7h
	db	'8',0B8h,'9',0B9h,'A',0BAh,'B',0BBh,'C',0BCh,'D',0BDh,'E',0BEh,'F',0BFh
	db	'0',0C0h,'1',0C1h,'2',0C2h,'3',0C3h,'4',0C4h,'5',0C5h,'6',0C6h,'7',0C7h
	db	'8',0C8h,'9',0C9h,'A',0CAh,'B',0CBh,'C',0CCh,'D',0CDh,'E',0CEh,'F',0CFh
	db	'0',0D0h,'1',0D1h,'2',0D2h,'3',0D3h,'4',0D4h,'5',0D5h,'6',0D6h,'7',0D7h
	db	'8',0D8h,'9',0D9h,'A',0DAh,'B',0DBh,'C',0DCh,'D',0DDh,'E',0DEh,'F',0DFh
	db	'0',0E0h,'1',0E1h,'2',0E2h,'3',0E3h,'4',0E4h,'5',0E5h,'6',0E6h,'7',0E7h
	db	'8',0E8h,'9',0E9h,'A',0EAh,'B',0EBh,'C',0ECh,'D',0EDh,'E',0EEh,'F',0EFh
	db	'0',0F0h,'1',0F1h,'2',0F2h,'3',0F3h,'4',0F4h,'5',0F5h,'6',0F6h,'7',0F7h
	db	'8',0F8h,'9',0F9h,'A',0FAh,'B',0FBh,'C',0FCh,'D',0FDh,'E',0FEh,'F',0FFh
msg_halted:
	db	'System halted.', NL, 0
