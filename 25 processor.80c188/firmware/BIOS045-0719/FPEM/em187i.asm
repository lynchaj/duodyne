; em187i.asm -- signal module
;
;  Enter with error number in AL
;
_FPSIGNAL:	;	proc	near
	push	bx
;;;	mov	bx,offset err0
	mov	bx, err0
	call	strout
	mov	bl,al
	xor	bh,bh
	shl	bx,1
  cs	mov	bx,word [FPUerrtab+bx]
	call	strout
;;;	mov	bx,offset errNL
	mov	bx, errNL
	call	strout
	pop	bx
	ret
;_FPSIGNAL	endp

;define the exception bits
; Iexcept     equ     1       ;invalid operation
; Dexcept     equ     2       ;denormalized operand
; Zexcept     equ     4       ;zero divide
; Oexcept     equ     8       ;overflow
; Uexcept     equ    10h      ;underflow
; Pexcept     equ    20h      ;precision
; 
; Sflag       equ    40h      ;stack flag     (new with 80187)
; Estatus     equ    80h      ;error summary status

;define the high order error codes
; errUnemulated   equ     0100h   ;unemulated operation
; errSqrt         equ     0200h   ;error in SQRT
;unassigned
; errStkOverflow  equ     0800h   ;
; errStkUnderflow equ     1000h   ;

err0	db	CR,LF,"FPU error:  ",0

err1	db	"Invalid Operation",0
err2	db	"Denormal",0
err3	db	"Zero Divide",0
err4	db	"Overflow",0
err5	db	"Underflow",0
err6	db	"Precision",0

err7	db	"Unemulated Instruction",0
err8	db	"SQRT error",0
err9	db	0
errA	db	"Stack Overflow",0
errB	db	"Stack Underflow",0
errC	db	0
errD	db	0
errE	db	0

errNL	db	CR,LF,0

FPUerrtab:
	dw	err1,err2,err3,err4
	dw	err5,err6,err7,err8
	dw	err9,errA,errB,errC
	dw	errD,errE

; output the string pointed to by BX
;
strout:		;	proc	near
	push	ax
strout1:
  cs	mov	al,byte [bx]
	or	al,al
	jz	strout9
	call	charout
	inc	bx
	jmp	strout1
strout9:
	pop	ax
	ret
;strout	endp
; output the character in AL
;
charout:	;	proc	near
	push	ax
	push	bx

	mov	bx,0007h
	mov	ah,0Eh
	int	10h

	pop	bx
	pop	ax
	ret
;charout	endp

; end em187i.asm
