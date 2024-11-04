;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; post.asm -- Power On Self Test
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   This version is for assembly by  NASM 0.98.39 or later
;
; Copyright (C) 2017,2020 John R. Coffman.  All rights reserved.
; Licensed for hobbyist use only.
; For use on the RetroBrew SBC-188 & SBC-188v3 boards.
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
;
; SBC-188 board revisions:
;       1.0     production board
;	2.0	production board with errata
;------------------------------------------------------------------------
;	3.0	2 x 512k SRAM chips, GALs for glue logic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	cpu	8086

; begin P.O.S.T.
post0:
;;;	cli			; make sure interrupts are off
; CLI done in 'startup.asm'

	xor	ax,ax		; AX=0; S=0, Z=1, P=1, C=0, OV=0, A=?
	jc	.halt
	jo	.halt
	jnz	.halt
	js	.halt
	jnp	.halt		; jmp if Parity not Even
	ja	.halt		; jmp if C=0 and Z=0
	jg	.halt		; jmp if S=OV and Z=0

	add	ax,1		; AX=1; S=0, Z=0, P=0, C=0, O=0, A=0
	jc	.halt
	jz	.halt
	js	.halt
	jpe	.halt
	jbe	.halt

	sub	ax,8002h 	; add 7ffeh
	jns	.post1		; AX=7FFFh

.halt:	hlt			; stop right here

.post1:	
	jo	.halt
	jnc	.halt
	jz	.halt

	inc	ax		; AX=8000h
	jz	.halt
	jno	.halt

	mov	bx,5555h | 8000h
	add	bx,ax		; BX='0101010101010101'B = 5555h
;;;
	cmp	bx,5555h
	jne	.halt
;;;
.bittest:
	mov	ss,bx
	mov	cx,ss
	mov	ds,cx
	mov	bp,ds
	mov	ax,bp
	mov	di,ax
	mov	dx,di
	mov	si,dx
	mov	es,si
	mov	bx,es
	cmp	bx,5555h
	jne	.halt

	not	bx
	cmp	bx,0AAAAh
	jne	.halt

	mov	es,bx
	mov	si,es
	mov	dx,si
	mov	di,dx
	mov	ax,di
	mov	bp,ax
	mov	ds,bp
	mov	cx,ds
	mov	ss,cx
	mov	bx,ss
	cmp	bx,0AAAAh
	jne	.halt
; register bits looking good

.post99:
