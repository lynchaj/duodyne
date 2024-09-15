;========================================================================
; inttrace.asm -- Interrupt tracing
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

%include	"config.asm"
%include	"cpuregs.asm"
%include	"equates.asm"

offset_BP	equ	0
offset_ES	equ	offset_BP+2
offset_DS	equ	offset_ES+2
offset_SI	equ	offset_DS+2
offset_DX	equ	offset_SI+2
offset_CX	equ	offset_DX+2
offset_BX	equ	offset_CX+2
offset_AX	equ	offset_BX+2
offset_RET	equ	offset_AX+2
offset_IP	equ	offset_RET+2
offset_CS	equ	offset_IP+2
offset_FLAGS	equ	offset_CS+2

offset_si_IP	equ	0
offset_si_CS	equ	offset_si_IP+2
offset_si_FLAGS	equ	offset_si_CS+2
original_SP	equ	offset_si_FLAGS+2

	segment	_TEXT
%if TRACE | 1
;========================================================================
; int_trace - print registers at interrupt service routine
;========================================================================
	global	int_trace
int_trace:
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	ds
	push	es
	push	bp
	mov	bp,sp

	xor	ax,ax			; AX = 0
	lea	si,[offset_IP+bp]	; SI = interrupt return CS:IP

.test_int:
    ss	lds	bx,[si]			; DS:BX = caller's CS:IP
	cmp	byte [bx-2], 0CDh	; int opcode
	jne	.test_call_ptr		; not an int opcode
	mov	al,byte[bx-1]		; interrupt vector
	jmp	.print_regs

.test_call_ptr:
	cmp	word [bx-4], 1EFFh	; interupt emulation - call dword ptr
	jne	.print_regs

;	add	si,6			; 3 words up in the stack
	inc	ah
;	jmp	.test_int

.print_regs:
	push	DGROUP
	pop	ds

	mov 	bx,word [offset_si_FLAGS+si]
	and	bx,0FFDh
	push	bx			; FLAGS
	mov	bx,bp
	add	bx,original_SP
	push	bx			; original SP value
	push	ss			; SS
    ss	push	word [offset_si_IP+si]	; IP
    ss	push	word [offset_si_CS+si]	; CS
	push	es			; ES
    ss	push	word [offset_DS+bp]	; DS
	push	di			; DI
    ss	push	word [offset_SI+bp]	; SI
    ss	push	word [offset_BP+bp]	; BP
	push	dx			; DX
	push	cx			; CX
    ss	push	word [offset_BX+bp]	; BX
    ss	push	word [offset_AX+bp]	; AX
	push	ax			; interrupt vector
	push	ds
	push	regs_msg
	extern	_cprintf
	call	_cprintf
	add	sp,34

	pop	bp
	pop	es
	pop	ds
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret

;========================================================================
; nmi - save registers at NMI for later analysis
;========================================================================
nmi_offset_DS	equ	0
nmi_offset_BP	equ	nmi_offset_DS+2
nmi_offset_DX	equ	nmi_offset_BP+2
nmi_offset_AX	equ	nmi_offset_DX+2
nmi_offset_IP	equ	nmi_offset_AX+2
nmi_offset_CS	equ	nmi_offset_IP+2
nmi_offset_FLAGS equ	nmi_offset_CS+2
nmi_SP		equ	nmi_offset_FLAGS+2

	global	nmi
nmi:
	push	ax
	push	dx
	push	bp
	push	ds
	mov	bp,sp
	xor	ax,ax
	mov	ds,ax
	mov	ax,0ADDEh
	mov	word [7FF0h],ax		; DEAD
	mov	ax,sp
	add	ax,nmi_SP
	mov	word [7FF2h],ax		; SP
	mov	ax,ss
	mov	word [7FF4h],ax		; SS
    ss	mov	ax,word [nmi_offset_IP+bp]
	mov	word [7FF6h],ax		; IP
    ss	mov	ax,word [nmi_offset_CS+bp]
	mov	word [7FF8h],ax		; CS
    ss	mov	ax,word [nmi_offset_FLAGS+bp]
	mov	word [7FFAh],ax		; FLAGS
    ss	mov	ax,word [nmi_offset_BP+bp]
	mov	word [7FFCh],ax		; BP
	mov	al,'N'
	call	uart_putchar
	mov	al,'M'
	call	uart_putchar
	mov	al,'I'
	call	uart_putchar
	mov	al,0Dh
	call	uart_putchar
	mov	al,0Ah
	call	uart_putchar
	mov	ax,0EFBEh
	mov	word [7FFEh],ax		; BEEF
	pop	ds
	pop	bp
	pop	dx
	pop	ax
	iret

;========================================================================
; uart_putchar - write character to serial port
; Input:
;	AL = character to write
; Output:
;	Trashes AX and DX
;========================================================================
uart_putchar:
	mov	ah,al
	mov	dx,uart_lsr
.1:
	in	al,dx
	test	al,20h		; THRE is empty
        jz	.1
	mov	al,ah
	mov     dx,uart_thr
	out     dx,al		; write character
	ret

;========================================================================
	segment	CONST
regs_msg:
	db	'INT=%03x AX=%04x BX=%04x CX=%04x DX=%04x BP=%04x SI=%04x DI=%04x', NL
	db	'DS=%04x ES=%04x CS:IP=%04x:%04x SS:SP=%04x:%04x Flags=%03x', NL, 0

;========================================================================
%endif	; TRACE
