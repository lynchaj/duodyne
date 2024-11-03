	NAME	UNASM
        PAGE    55,120
        M186    =       1
	.XLIST
INCLUDE cutmacs.asm
	.LIST

_TEXT   SEGMENT PUBLIC PARA 'CODE'
_TEXT   ENDS
;CONST   SEGMENT PUBLIC PARA 'CONST'
;CONST   ENDS
_DATA   SEGMENT PUBLIC PARA 'DATA'
_DATA   ENDS
_BSS    SEGMENT PUBLIC PARA 'BSS'
_BSS    ENDS

;DGROUP  GROUP   CONST,_DATA,_BSS
DGROUP  GROUP   _DATA,_BSS


        public  _unasm_msg

_TEXT   SEGMENT

;UNASM_DATA	SEGMENT	WORD PUBLIC 'DATA'
;UNASM_DATA	SEGMENT	PARA PUBLIC 'CODE'
        ASSUME  CS:_TEXT,DS:_TEXT

_unasm_msg:

msg		db	80 DUP(?)
msgData		equ	msg+0
msgInstr	equ	msgData+14
msgArgs		equ	msgInstr+8

;;UNASM_DATA	ENDS


;;UNASM_TEXT	SEGMENT	WORD PUBLIC 'CODE'
;;	ASSUME	CS:UNASM_TEXT,DS:UNASM_DATA
        ASSUME  CS:_TEXT,DS:_TEXT

;;	extrn	PrintString:NEAR
;;	extrn	PrintNewLine:NEAR
;;	extrn	U_IP:WORD

;;  C-declaration of unasm (all 3 pointers are far)
;;
;;   char* unasm(byte *IP, word *length, word IP);
;;
;;

is_far  equ     0
arg1    equ     is_far+4        ; far ptr   Instruction ptr
arg2    equ     arg1+4          ; far ptr   length ptr
arg3    equ     arg2+4          ; word      base IP

	public	_unasm
_unasm	PROC	near
	ENTER	0,0
	PUSHM	DS,ES,SI,DI

;;	MOV	AX,SEG UNASM_DATA
;;	MOV	DS,AX

        PUSH    CS
        POP     DS

;*************************************************************************
;desc:	display next instruction
;	ES:DI	points to instruction to disassemble
;returns
;	dx = byte length
;	ES:DI	points to next instrution
;*************************************************************************

        push    ds
        pop     es
	mov	cx,80-1		;clear msg buffer
	mov	al,' '
	cld
	lea	di,msg
	rep	stosb   	;clear the buffer
	sub	al,al
	stosb

	LES	DI,DWORD PTR [BP+arg1]	;GET ARGUMENT

COMMENT	^
	lea	bx,msg
	mov	ax,es
	call	StoreHexWord
	call	StoreColon
	mov	ax,di
	call	StoreHexWord
^ END COMMENT

	xor	dx,dx			;keep track of number of bytes in instr

	lea	bx,msgInstr
	mov	al,es:[di]		;get 1st byte of instruction
	xor	ah,ah
MSH	shl	ax,2			;build index to table
	add	ax,offset disop
	mov	si,ax
	cmp	word ptr DS:[si],0	;valid instruction name?
	je	UA_1			;nope - have to wait
	push	si
	mov	si,DS:[si]
	call	StoreString
	pop	si
UA_1:
	jmp	DS:[si+2]

UNASM_END:
	lea	bx,msgData		;insert instruction bytes
	mov	cx,dx			;if dx <0,then we just found a prefix code
	inc	cx			;-1 becomes 0
	jnz	UA_10			;inc 0 to 1
	inc	cx
UA_10:
	mov	al,es:[di]
	inc	di
	call	StoreHexByte
	loop	UA_10

;;	lea	si,msg
;;	call	PrintString
;;	call	PrintNewLine
	cmp	dx,0
	jl	_unasm

	mov	cx,80
	lea	si,msg+80-1
	mov	ax,0020H
zap_loop:
	cmp	byte ptr [si],al
	ja	unasm_done
	mov	byte ptr [si],ah
	dec	si
	loop	zap_loop

unasm_done:
	les	bx,dword ptr [bp+arg2]
	sub	di,word ptr [bp+arg1]
	mov	es:[bx],di		;instruction length
	MOV	DX,DS			;return char string ptr
	LEA	AX,msg
	POPM	DS,ES,SI,DI
	LEAVE
	ret
_unasm	ENDP


;****************************************************************************
;* Disassemble Addressing modes
;****************************************************************************
ARITHIMM:				;done
	LEA	SI,DS:$ARITHGRP
	CALL	GETSUBNAME
	mov	ch,es:[di]		;get real s,w bits
	JMP	IMMRM0

DROPARG:				;done
	INC	DX
	JMP	NEAR PTR UNASM_END

ENTERARGS:				;done
	LEA	BX,msgArgs
	mov	AX,ES:[DI+1]
	call	StoreHexWord
	call	StoreComma
	mov	al,ES:[DI+3]
	call	StoreHexByte
	add	dx,3
	JMP	NEAR PTR UNASM_END



COMMENT ^
ESCRM:					;done
	LEA	BX,msgArgs
	MOV	AX,ES:[DI]
	AND	AX,0000011100111000B
	AND	AL,AH
	CALL	StoreHexByte
	CALL	StoreComma
	CALL	GetModRM
	JMP	NEAR PTR UNASM_END
^ END COMMENT 

ESC_D8:
	inc	dx
	LEA	SI,DS:$FARITH
	CALL	GETSUBNAME
	LEA	BX,msgArgs
	mov	AL,ES:[DI+1]
	CMP	AL,11000000B	;CHECK MOD BITS
	JAE	D8RR
; HAVE MEMORY REFERENCE
	MOV	CH,ES:[DI]		;GET FORMAT BITS
	CALL	FGetModRM
	JMP	NEAR PTR UNASM_END

D8RR:
	AND	AL,00110111b		;check for FCOM & FCOMP
	CMP	AL,00010001B		; = FCOM ST(1) &c.
	JE	D8done

	SUB	AX,AX
	call	FPac
	call	StoreComma
	mov	AL,ES:[DI+1]
	call	FPac
D8done:
	JMP	NEAR PTR UNASM_END


ESC_D9:
	inc	dx
	mov	al,byte ptr es:[di+1]
	CMP	al,11000000B	;CHECK MOD BITS
	jae	D9spc
	lea	si,DS:$FARITH1
	mov	ch,8			;Dword format
	test	al,00100000B		
	jz	D9go
	shr	ch,1
	test	al,00001000B
	jnz	D9go
	shr	ch,1
D9go:
	CALL	GETSUBNAME
	lea	bx,msgArgs
	call	FGetModRM
	JMP	NEAR PTR UNASM_END

D9spc:
	TEST	AL,00100000B			;CHECK
	jnz	D9op5
	lea	si,DS:$FLDRR1
	CALL	GETSUBNAME
	test	al,00010000B
	jnz	D9_done
	lea	bx,msgArgs
	call	FPac
D9_done:
	JMP	NEAR PTR UNASM_END

D9op5:
	AND	ax,0011111B
	add	ax,ax
	mov	si,ax
	mov	si,DS:$FARITH3[si]
	call	StoreString

	JMP	NEAR PTR UNASM_END


ESC_DA:
	inc	dx
	CMP	BYTE PTR ES:[DI+1],11000000B
	JAE	DAspc
	LEA	SI,DS:$FIARITH
	CALL	GETSUBNAME
	LEA	BX,msgArgs
; HAVE MEMORY REFERENCE
	MOV	CH,ES:[DI]		;GET FORMAT BITS
	CALL	FGetModRM
	JMP	NEAR PTR UNASM_END

DAspc:
	lea	si,DS:$FUCOMPP
	cmp	byte ptr ES:[DI+1],0E9h
	jne	DAerr
	call	StoreString
DAerr:
	JMP	NEAR PTR UNASM_END

ESC_DB:
	inc	dx
	mov	al,byte ptr es:[di+1]
	CMP	al,11000000B	;CHECK MOD BITS
	jae	DBspc
	lea	si,DS:$FIARITH1
	MOV	CH,0AH		;DWORD PTR
	TEST	AL,00100000B
	JZ	DB00
	XOR	CH,CH
DB00:
	call	GETSUBNAME
	lea	bx,msgArgs
	call	FGetModRM
	JMP	NEAR PTR UNASM_END

DBspc:
	AND	ax,0011111B
	add	ax,ax
	mov	si,ax
	mov	si,DS:$FCTRL[si]
	call	StoreString

	JMP	NEAR PTR UNASM_END


ESC_DC:
	LEA	SI,DS:$FARITH
	CMP	BYTE PTR ES:[DI+1],11000000B	;CHECK MOD BITS
	JAE	DcRR
	CALL	GETSUBNAME
	LEA	BX,msgArgs
; HAVE MEMORY REFERENCE
	MOV	CH,ES:[DI]		;GET FORMAT BITS
	CALL	FGetModRM
	inc	dx
	JMP	NEAR PTR UNASM_END

DcRR:
	LEA	SI,DS:$FARITHR
	CALL	GETSUBNAME
	LEA	BX,msgArgs
	mov	AL,ES:[DI+1]
	call	FPac
	call	StoreComma
	SUB	AX,AX
	call	FPac
	inc	dx
	JMP	NEAR PTR UNASM_END


ESC_DD:
	inc	dx
	mov	al,byte ptr es:[di+1]
	CMP	al,11000000B	;CHECK MOD BITS
	jae	DDspc
	lea	si,DS:$FARITH2
	MOV	CH,0CH		;QWORD PTR
	TEST	AL,00100000B
	JZ	DD00
	ADD	CH,2		;WORD PTR
DD00:
	call	GETSUBNAME
	lea	bx,msgArgs
	call	FGetModRM
	JMP	NEAR PTR UNASM_END

DDspc:
	LEA	SI,DS:$FLDRR2
	call	GETSUBNAME
	lea	bx,msgArgs
	MOV	AL,ES:[DI+1]
	call	FPac

	JMP	NEAR PTR UNASM_END


ESC_DE:
	inc	dx
	mov	al,es:[di+1]
	cmp	al,11000000B
	jae	DEspc

	lea	si,DS:$FIARITH
	CALL	GETSUBNAME
	lea	bx,msgArgs
	mov	ch,es:[di]
	call	FGetModRM
	JMP	NEAR PTR UNASM_END
DEspc:
	and	al,7			;extract register
	cmp	al,1
	je	DErr1
	lea	si,DS:$FARITHP
	call	GETSUBNAME
	lea	bx,msgArgs
	mov	al,es:[di+1]		;get register #
	call	FPac
	call	StoreComma
	sub	al,al
	call	FPac
	JMP	NEAR PTR UNASM_END

DErr1:
	lea	si,DS:$FARITHR
	call	GETSUBNAME
	JMP	NEAR PTR UNASM_END

ESC_DF:
	inc	dx
	mov	al,es:[di+1]
	mov	ch,es:[di]
	lea	si,DS:$FIARITH2
	cmp	al,11000000B
	jae	DFspc
	test	al,00100000B
	jz	DFgo
	sub	ch,2			;word -> Qword ptr
	test	al,001000B
	jnz	DFgo
	xor	ch,ch			;Tbyte Ptr
DFgo:		
      	call	GETSUBNAME
	lea	bx,msgArgs
	call	FGetModRM
	JMP	NEAR PTR UNASM_END

DFspc:
	cmp	al,0E0h
	jne	DFerr
	lea	si,DS:$FSTSW
	call	StoreString
	lea	bx,msgArgs
	lea	si,DS:$REG16
	call	StoreString
DFerr:
	JMP	NEAR PTR UNASM_END



FARADR:					;done
	LEA	BX,msgArgs
	MOV	AX,ES:[DI+3]
	CALL	StoreHexWord
	CALL	StoreColon
	MOV	AX,ES:[DI+1]
	CALL	StoreHexWord
	add	dx,4
	JMP	NEAR PTR UNASM_END

GRP1:						;done ?
	LEA	SI,DS:$GRP1
	CALL	GETSUBNAME
	LEA	BX,msgArgs
	mov	ch,es:[di]
	call	GetModRM
	test	byte ptr es:[di+1],00111000B	;test immediate - special case
	jne	GRP1b
	call	StoreComma
	push	di
	add	di,dx
	mov	al,es:[di+2]
	test	CH,00000001B
	jnz	GRP1a				;is word

	call	StoreHexByte
	inc	dx
	JMP	Short GRP1c
GRP1a:
	mov	ah,ES:[DI+3]		;fetch high order byte
	add	dx,2			;inc instruction length
	call	StoreHexWord
	
GRP1c:
	pop	DI
GRP1b:
	inc	dx
	JMP	NEAR PTR UNASM_END

GRP2:
	LEA	SI,DS:$GRP2
	CALL	GETSUBNAME
	LEA	BX,msgArgs
	mov	ch,es:[di]		;get word/byte bit
	cmp	al,6			;Call intersegment indirect
	je	GRP2a
	cmp	al,0aH			;JMP intersegment indirect
	je	GRP2a

	call	GetModRM
	inc	dx
	JMP	NEAR PTR UNASM_END

GRP2a:
	mov	ch,8			;signal Dword type
	call	FGetModRM
	inc	dx
	JMP	NEAR PTR UNASM_END

ILLBYTE:				;done
	LEA	BX,msgArgs
	MOV	AL,es:[di]
	CALL	StoreHexByte
	JMP	NEAR PTR UNASM_END

IMMAX:					;done
	LEA	BX,msgArgs
	TEST	BYTE PTR ES:[DI],1
	JNE	IMMAX_WORD
	LEA	SI,DS:$REG8
	CALL	StoreString
	CALL	StoreComma
	MOV	AL,ES:[DI+1]
	CALL	StoreHexByte
	INC	DX
	JMP	NEAR PTR UNASM_END

IMMAX_WORD:
	LEA	SI,DS:$REG16
	CALL	StoreString
	CALL	StoreComma
	MOV	AX,ES:[DI+1]
	CALL	StoreHexWord
	ADD	DX,2
	JMP	NEAR PTR UNASM_END

IMMRM:					;done
	MOV	ch,es:[di]
	AND	ch,00000001B		;mask to W bit only, S=0
IMMRM0:
	LEA	BX,msgArgs
	CALL	GetModRM
	CALL	StoreComma
	push	di			;point to immediate data-2
	add	di,dx
	inc	dx			;inc instruction length
	mov	ax,ES:[DI+2]		;fetch 1st immediate byte & second
	test	CH,00000001B
	jnz	IMMRM1			;is word

	call	StoreHexByte
	inc	dx
	JMP	Short IMMRM3

IMMRM1:
	inc	dx			;inc instruction length
	test	CH,00000010B		;sign extend to word?
	JZ	IMMRM2a

IMMRM2:
	cbw				;sign extend to word
	dec	dx
IMMRM2a:
	call	StoreHexWord
	inc	dx			;inc instruction length
IMMRM3:
	pop	di
	JMP	NEAR PTR UNASM_END

IMMREG:					;done
	LEA	BX,msgArgs
	MOV	AL,ES:[DI]
	MOV	CH,AL
	AND	AL,00000111B		;mask off register
	test	ch,00001000B		;byte or word instruction?
	jne	IMMREG1
	call	GetByteRegister
	call	StoreComma
	mov	al,es:[di+1]
	call	StoreHexByte
	inc	dx
	JMP	NEAR PTR UNASM_END

IMMREG1:
	call	GetWordRegister
	call	StoreComma
	mov	ax,es:[di+1]
	call	StoreHexWord
	add	dx,2
	JMP	NEAR PTR UNASM_END

INCREG:					;done
	LEA	BX,msgArgs
	MOV	AL,ES:[DI]
	AND	AX,00000111B
	CALL	GetWordRegister
	JMP	NEAR PTR UNASM_END

INDJMP:					;almost done
	LEA	BX,msgArgs
	MOV	CH,ES:[DI]
	CALL	GetModRM
	JMP	NEAR PTR UNASM_END

IODX:					;done
	LEA	BX,msgArgs
	MOV	CH,ES:[DI]
	test	ch,00000010B		;direction (in/out)
	jne	IODX1
	xor	al,al			;register 0 is AX/AL
	call	GetRegister
	call	StoreComma
	mov	al,2			;register 2 is DX
	call	GetWordRegister
	JMP	NEAR PTR UNASM_END

IODX1:
	mov	al,2			;register 2 is DX
	call	GetWordRegister
	call	StoreComma
	xor	al,al			;register 0 is AX/AL
	call	GetRegister
	JMP	NEAR PTR UNASM_END

IOIMM:					;done
	LEA	BX,msgArgs
	MOV	CH,ES:[DI]
	test	ch,00000010B		;direction (in/out)
	jne	IOIMM1
	xor	al,al			;register 0 is AX/AL
	call	GetRegister
	call	StoreComma
	mov	al,es:[di+1]
	call	StoreHexByte
	inc	dx
	JMP	NEAR PTR UNASM_END

IOIMM1:
	mov	al,es:[di+1]
	call	StoreHexByte
	call	StoreComma
	xor	al,al			;register 0 is AX/AL
	call	GetRegister
	inc	dx
	JMP	NEAR PTR UNASM_END

MEMAL:					;done
	LEA	BX,msgArgs
	MOV	CH,ES:[DI]
	test	ch,00000010B		;direction (to/from)
	jne	MEMAL1
	xor	al,al			;register 0 is AX/AL
	call	GetRegister
	call	StoreComma
	call	GetPointerType
	mov	ax,es:[DI+1]
	call	StoreHexWord
	JMP	SHORT MEMAL2

MEMAL1:
	call	GetPointerType
	mov	ax,es:[DI+1]
	call	StoreHexWord
	call	StoreComma
	xor	al,al			;register 0 is AX/AL
	call	GetRegister

MEMAL2:
	add	dx,2
	JMP	NEAR PTR UNASM_END

LEAINS:
	mov	ch,00000011B
	jmp	short ModRM01

MODRM:					;done
	mov	ch,es:[di]
ModRM01:
	LEA	BX,msgArgs
	mov	al,es:[di+1]
	and	al,00111000B		;get register number
MSH	shr	al,3			;and position it
	test	ch,00000010B		;direction?
	je	ModRMTo			;register to reg/memory
	call	GetRegister
	call	StoreComma
	call	GetModRM
	inc	dx
	JMP	NEAR PTR UNASM_END

ModRMTo:
	push	ax
	call	GetModRM
	call	StoreComma
	pop	ax
	call	GetRegister
	inc	dx
	JMP	NEAR PTR UNASM_END

MODRM2:					;done
	LEA	BX,msgArgs
	mov	ch,es:[di]
	call	GetModRM
	JMP	NEAR PTR UNASM_END

MODRM3:					;done
	LEA	BX,msgArgs		;this case always moves MEM to register
	mov	ch,8			;Dword format code
	mov	al,es:[di+1]
	and	ax,00111000B		;get register number
MSH	shr	al,3			;and position it
	call	GetWordRegister
	call	StoreComma
	call	FGetModRM
	inc	dx
	JMP	NEAR PTR UNASM_END

NOARGS:					;done
	JMP	NEAR PTR UNASM_END

PPSEG:					;done
	LEA	BX,msgArgs
	MOV	AL,ES:[DI]
	AND	AX,00011000B		;get segment register bits
MSH	SHR	AX,3
	CALL	GetSegRegister
	JMP	NEAR PTR UNASM_END

IMM8:
	LEA	BX,msgArgs
	mov	al,es:[di+1]
	call	StoreHexByte
	inc	dx
	JMP	NEAR PTR UNASM_END

IMM16:
	LEA	BX,msgArgs
	mov	ax,es:[di+1]
	call	StoreHexWord
	inc	dx
	inc	dx
	JMP	NEAR PTR UNASM_END

IMULIMM:
	inc	dx
	LEA	BX,msgArgs
	mov	al,es:[di+1]
	and	al,00111000B		;get register number
MSH	shr	al,3			;and position it
	call	GetWordRegister
	call	StoreComma
	mov	ch,00000001B		;say word reg
	push	dx
	call	GetModRM	
	call	StoreComma
	pop	ax
	push	di
	sub	ax,dx			;AX = 0 or -2
	sub	di,ax			;DI is offset to constant
	mov	ax,es:[di+2]		;get constant
	pop	di
	jmp	short PUSHIMM0


PUSHIMM:					;done
	LEA	BX,msgArgs
	MOV	AX,ES:[DI+1]
PUSHIMM0:
	inc	dx
	inc	dx
	TEST	byte ptr ES:[DI],00000010B	;BYTE OR WORD?
	JZ	PUSHIMM1			;It's a word

	CBW
	dec	dx
PUSHIMM1:
	CALL	StoreHexWord
	JMP	NEAR PTR UNASM_END

PREFIX:					;done
	call	StoreColon
;;jrc	mov	dx,-1
	JMP	NEAR PTR UNASM_END

REL8JMP:				;done
	LEA	BX,msgArgs
	MOV	AL,ES:[DI+1]		;compute byte relative address
	CBW
	ADD	AX,WORD PTR [BP+arg3]	;USE BASE IP PASSED IN
	ADD	AX,2
	CALL	StoreHexWord
	INC	DX
	JMP	NEAR PTR UNASM_END

REL16JMP:				;done
	LEA	BX,msgArgs
	MOV	AX,ES:[DI+1]		;compute word relative address
;;	ADD	AX,DI
	ADD	AX,WORD PTR [BP+arg3]
	ADD	AX,3
	CALL	StoreHexWord
	ADD	DX,2
	JMP	NEAR PTR UNASM_END

SEGRM:					;done
	LEA	BX,msgArgs
	mov	ch,es:[di]
	or	ch,1			;identify it as a word access
	mov	al,es:[di+1]
	and	al,00011000B		;get register number
MSH	shr	al,3			;and position it
	test	ch,00000010B		;direction?
	je	SegRMTo			;register to reg/memory
	call	GetSegRegister
	call	StoreComma
	call	GetModRM
	inc	dx
	JMP	NEAR PTR UNASM_END

SegRMTo:
	push	ax
	call	GetModRM
	call	StoreComma
	pop	ax
	call	GetSegRegister
	inc	dx
	JMP	NEAR PTR UNASM_END

SHFT:					;done
	LEA	SI,DS:$SHFTGRP
	CALL	GETSUBNAME
	LEA	BX,msgArgs
	mov	ch,es:[di]
	call	GetModRM
	call	StoreComma
	mov	al,1
	test	ch,2			;test for CL
	jnz	SHFTCL
	call	StoreHexByte
	inc	dx
	JMP	NEAR PTR UNASM_END

SHFTCL:
	call	GetByteRegister
	inc	dx
	JMP	NEAR PTR UNASM_END
	

SHFTCNT:				;done
	LEA	SI,DS:$SHFTGRP
	CALL	GETSUBNAME
	LEA	BX,msgArgs
	mov	ch,es:[di]
	call	GetModRM
	call	StoreComma
	push	DI
	add	DI,DX			;point to [immediate data - 2]
	mov	al,es:[di+2]
	call	StoreHexByte
	add	dx,2
	pop	di
	JMP	NEAR PTR UNASM_END

XCHGREG:				;done
	LEA	BX,msgArgs
	XOR	AX,AX			;write ax
	CALL	GetWordRegister
	CALL	StoreComma
	MOV	AL,ES:[DI]
	AND	AX,00000111B
	CALL	GetWordRegister
	JMP	NEAR PTR UNASM_END

;****************************************************************************
; get sub function name
; input:	es:[di+1] points to modrm byte
;		SI points to table of name addresses
GETSUBNAME:
	MOV	AL,ES:[DI+1]
	AND	AX,00111000B		;GET INSTRUCTION BITS
MSH	SHR	AX,2			;CONVERT TO WORD INDEX
	ADD	SI,AX
	MOV	SI,DS:[SI]
	CALL	StoreString
	RET

;*************************************************************************
; Get Mod RM address 
; input:	ES:[di] points to instruction to decode
;		ch = sign extend and byte/word bits
GetModRM:
	MOV	AL,ES:[DI+1]
	AND	AL,11000111B		;mask bits
	xor	ah,ah
MSH	shl	ax,2			;shift off mod bits
	shr	al,1			;make lower 3 bits into a word index
	cmp	ah,3			;register specified?
	je	GetModReg		;yep, go to it!

	call	GetPointerType
	cmp	ah,00			;is there a displacement??
	jne	GetModDisplace		;get displacement
	cmp	al,01100B		;special case of direct address?
	jne	GetModAddress
	
	mov	ax,es:[di+2]
	call	StoreHexWord
	add	dx,2
	ret

;*************************************************************************
; Get Mod RM address -- Floating Format
; input:	ES:[di] points to instruction to decode
;		ch = Format code in bits 3,2,1
FGetModRM:
	MOV	AL,ES:[DI+1]
	AND	AL,11000111B		;mask bits
	xor	ah,ah
MSH	shl	ax,2			;shift off mod bits
	shr	al,1			;make lower 3 bits into a word index

	call	FGetPointerType
	cmp	ah,00			;is there a displacement??
	jne	GetModDisplace		;get displacement
	cmp	al,01100B		;special case of direct address?
	jne	GetModAddress
	
	mov	ax,es:[di+2]
	call	StoreHexWord
	add	dx,2
	ret

GetModDisplace:
	push	ax
	cmp	ah,1
	jne	GetModD2

	mov	al,es:[di+2]
	cbw
	inc	dx
	jmp	short GetModD3

GetModD2:
	mov	ax,es:[di+2]
	add	dx,2
GetModD3:
	CALL	StoreHexWord
	pop	ax
GetModAddress:
	xor	ah,ah			;compute word index
	lea	si,DS:$ModAddress
	add	si,ax
	mov	si,DS:[si]
	call	StoreString
	RET

GetModReg:
	xor	ah,ah			;re-position register number
	shr	ax,1
;;	jmp	Short GetRegister

;*************************************************************************
; Get Register
; input:	al = register number
;		ch = bit 0 contains byte/word flag
;*************************************************************************
GetRegister:
	test	ch,00000001B
	jne	GetWordRegister
	jmp	short GetByteRegister

; Get segment register name
;input:	al = register number
GetSegRegister:
	LEA	SI,DS:$SEGS
	JMP	SHORT GetReg1

;*************************************************************************
; Get word register name
;input:	al = register number

GetWordRegister:
	LEA	SI,DS:$REG16
	JMP	SHORT GetReg1

;*************************************************************************
; Get byte register name
;input:	al = register number
GetByteRegister:
	LEA	SI,DS:$REG8

GetReg1:
	XOR	AH,AH
	SHL	AX,1
	ADD	SI,AX
	CALL	StoreString
	RET
     
;*************************************************************************
; Get byte register name
;input:	ch = bit 0 is word/byte flag
GetPointerType:
	lea	si,DS:$BytePtr
	test	ch,00000001B		;byte or word?
	je	GetPTR1

	lea	si,DS:$WordPtr
GetPTR1:
	Call	StoreString
	ret

;*************************************************************************
; Get byte register name
;input:	ch = Pointer type in bits 3,2,1
FGetPointerType:
	xchg	ch,cl
	mov	si,cx
	xchg	ch,cl
	and	si,00001110B
	mov	si,DS:Fformats[si]
	call	 StoreString
	ret
;**************************************************************************
;desc:	FPac
;in:	al bits 0-2 have stack offset
;return:
;	ax destroyed
;	bx is incremented
FPac:
	mov	word ptr [bx],'T'*256+'S'
	inc	bx
	inc	bx
	and	al,07
	jz	FPac1
	mov	byte ptr [bx],'('
	inc	bx
	call	StoreHexNyb
	mov	byte ptr [bx],')'
	inc	bx
FPac1:	ret


;**************************************************************************
;desc:	StoreHexWord/Byte/Nybble
;in:	ax/al with value to print
;return:
;	ax destroyed
;	bx is incremented
;**************************************************************************
StoreHexWord	Proc	Near
	push	ax
	mov	al,ah
	call	StoreHexByte
	pop	ax
StoreHexByte:
	push	ax
MSH	shr	al,4
	call	StoreHexNyb
	pop	ax
StoreHexNyb:
	and	al,0FH
COMMENT ^
	cmp	al,09
	jle	Sxb1
	add	al,'a'-'9'-1
Sxb1:
	add	al,'0'
^ END COMMENT
        daa
        add     al,0F0H
        adc     al,40H
	mov	[bx],al
	inc	bx
	ret
StoreHexWord	Endp

;*************************************************************************
;desc: Store Comma
;	bx updated
;*************************************************************************
StoreComma:
	mov	byte ptr [bx],','
	inc	bx
	ret

;*************************************************************************
;desc: Store Colon
;	bx updated
;*************************************************************************
StoreColon:
	mov	byte ptr [bx],':'
	inc	bx
	ret

;*************************************************************************
;desc: Store sign terminated string in buffer
;in:	DS:si points to sign terminated string
;returns:
;	DS:si points past string
;	ds:bx updated
;*************************************************************************
StoreString	Proc	Near
	push	ax
SS1:
	lods	byte ptr DS:[si]
	or	al,al
	js	SSEnd
	mov	[bx],al
	inc	bx
	jmp	short SS1
SSEnd:
	and	al,7fH		;clear sign bit
	mov	[bx],al
	inc	bx
	pop	ax
	ret
StoreString	Endp



disop	dw	$ADD,MODRM			;00
	dw	$ADD,MODRM
	dw	$ADD,MODRM
	dw	$ADD,MODRM
	dw	$ADD,IMMAX
	dw	$ADD,IMMAX
	dw	$PUSH,PPSEG
	dw	$POP,PPSEG
	dw	$OR,MODRM
	dw	$OR,MODRM
	dw	$OR,MODRM
	dw	$OR,MODRM
	dw	$OR,IMMAX
	dw	$OR,IMMAX
	dw	$PUSH,PPSEG
	dw	$DB,ILLBYTE

	dw	$ADC,MODRM			;10
	dw	$ADC,MODRM
	dw	$ADC,MODRM
	dw	$ADC,MODRM
	dw	$ADC,IMMAX
	dw	$ADC,IMMAX
	dw	$PUSH,PPSEG
	dw	$POP,PPSEG
	dw	$SBB,MODRM
	dw	$SBB,MODRM
	dw	$SBB,MODRM
	dw	$SBB,MODRM
	dw	$SBB,IMMAX
	dw	$SBB,IMMAX
	dw	$PUSH,PPSEG
	dw	$POP,PPSEG

	dw	$AND,MODRM			;20
	dw	$AND,MODRM
	dw	$AND,MODRM
	dw	$AND,MODRM
	dw	$AND,IMMAX
	dw	$AND,IMMAX
	dw	$ES,PREFIX
	dw	$DAA,NOARGS
	dw	$SUB,MODRM
	dw	$SUB,MODRM
	dw	$SUB,MODRM
	dw	$SUB,MODRM
	dw	$SUB,IMMAX
	dw	$SUB,IMMAX
	dw	$CS,PREFIX
	dw	$DAS,NOARGS

	dw	$XOR,MODRM			;30
	dw	$XOR,MODRM
	dw	$XOR,MODRM
	dw	$XOR,MODRM
	dw	$XOR,IMMAX
	dw	$XOR,IMMAX
	dw	$SS,PREFIX
	dw	$AAA,NOARGS
	dw	$CMP,MODRM
	dw	$CMP,MODRM
	dw	$CMP,MODRM
	dw	$CMP,MODRM
	dw	$CMP,IMMAX
	dw	$CMP,IMMAX
	dw	$DS,PREFIX
	dw	$AAS,NOARGS

	dw	$INC,INCREG			;40
	dw	$INC,INCREG
	dw	$INC,INCREG 
	dw	$INC,INCREG
	dw	$INC,INCREG
	dw	$INC,INCREG
	dw	$INC,INCREG
	dw	$INC,INCREG
	dw	$DEC,INCREG
	dw	$DEC,INCREG
	dw	$DEC,INCREG 
	dw	$DEC,INCREG
	dw	$DEC,INCREG
	dw	$DEC,INCREG
	dw	$DEC,INCREG
	dw	$DEC,INCREG

	dw	$PUSH,INCREG			;50
	dw	$PUSH,INCREG
	dw	$PUSH,INCREG
	dw	$PUSH,INCREG
	dw	$PUSH,INCREG
	dw	$PUSH,INCREG
	dw	$PUSH,INCREG
	dw	$PUSH,INCREG
	dw	$POP,INCREG
	dw	$POP,INCREG
	dw	$POP,INCREG
	dw	$POP,INCREG
	dw	$POP,INCREG
	dw	$POP,INCREG
	dw	$POP,INCREG
	dw	$POP,INCREG

	dw	$PUSHA,NOARGS			;60
	dw	$POPA,NOARGS
	dw	$BOUND,MODRM
	dw	$DB,ILLBYTE
	dw	$DB,ILLBYTE
	dw	$DB,ILLBYTE
	dw	$DB,ILLBYTE
	dw	$DB,ILLBYTE
	dw	$PUSH,PUSHIMM
	dw	$IMUL,IMULIMM
	dw	$PUSH,PUSHIMM
	dw	$IMUL,IMULIMM
	dw	$INSB,NOARGS
	dw	$INSW,NOARGS
	dw	$OUTSB,NOARGS
	dw	$OUTSW,NOARGS

	dw	$JO,REL8JMP			;70
	dw	$JNO,REL8JMP
	dw	$JB,REL8JMP
	dw	$JNB,REL8JMP
	dw	$JE,REL8JMP
	dw	$JNE,REL8JMP
	dw	$JBE,REL8JMP
	dw	$JA,REL8JMP
	dw	$JS,REL8JMP
	dw	$JNS,REL8JMP
	dw	$JP,REL8JMP
	dw	$JNP,REL8JMP
	dw	$JL,REL8JMP
	dw	$JGE,REL8JMP
	dw	$JLE,REL8JMP
	dw	$JG,REL8JMP

	dw	0,ARITHIMM			;80
	dw	0,ARITHIMM
	dw	0,ARITHIMM
	dw	0,ARITHIMM
	dw	$TEST,MODRM
	dw	$TEST,MODRM
	dw	$XCHG,MODRM
	dw	$XCHG,MODRM
	dw	$MOV,MODRM
	dw	$MOV,MODRM
	dw	$MOV,MODRM
	dw	$MOV,MODRM
	dw	$MOV,SEGRM
	dw	$LEA,LEAINS
	dw	$MOV,SEGRM
	dw	$POP,MODRM2

	dw	$NOP,NOARGS			;90
	dw	$XCHG,XCHGREG
	dw	$XCHG,XCHGREG
	dw	$XCHG,XCHGREG
	dw	$XCHG,XCHGREG
	dw	$XCHG,XCHGREG
	dw	$XCHG,XCHGREG
	dw	$XCHG,XCHGREG
	dw	$CBW,NOARGS
	dw	$CWD,NOARGS
	dw	$CALL,FARADR
	dw	$FWAIT,NOARGS
	dw	$PUSHF,NOARGS
	dw	$POPF,NOARGS
	dw	$SAHF,NOARGS
	dw	$LAHF,NOARGS

	dw	$MOV,MEMAL			;A0
	dw	$MOV,MEMAL
	dw	$MOV,MEMAL
	dw	$MOV,MEMAL
	dw	$MOVSB,NOARGS
	dw	$MOVSW,NOARGS
	dw	$CMPSB,NOARGS
	dw	$CMPSW,NOARGS
	dw	$TEST,IMMAX
	dw	$TEST,IMMAX
	dw	$STOSB,NOARGS
	dw	$STOSW,NOARGS
	dw	$LODSB,NOARGS
	dw	$LODSW,NOARGS
	dw	$SCASB,NOARGS
	dw	$SCASW,NOARGS

	dw	$MOV,IMMREG			;B0
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG
	dw	$MOV,IMMREG

	dw	0,SHFTCNT			;C0
	dw	0,SHFTCNT
	dw	$RETN,IMM16
	dw	$RETN,NOARGS
	dw	$LES,MODRM3
	dw	$LDS,MODRM3
	dw	$MOV,IMMRM
	dw	$MOV,IMMRM
	dw	$ENTER,ENTERARGS
	dw	$LEAVE,NOARGS
	dw	$RETF,IMM16
	dw	$RETF,NOARGS
	dw	$INT3,NOARGS
	dw	$INT,IMM8
	dw	$INTO,NOARGS
	dw	$IRET,NOARGS

	dw	0,SHFT				;D0
	dw	0,SHFT
	dw	0,SHFT
	dw	0,SHFT
	dw	$AAM,DROPARG
	dw	$AAD,DROPARG
	dw	$DB,ILLBYTE
	dw	$XLAT,NOARGS
	dw	0,ESC_D8
	dw	0,ESC_D9
	dw	0,ESC_DA
	dw	0,ESC_DB
	dw	0,ESC_DC
	dw	0,ESC_DD
	dw	0,ESC_DE
	dw	0,ESC_DF

	dw	$LOOPNZ,REL8JMP			;E0
	dw	$LOOPZ,REL8JMP
	dw	$LOOP,REL8JMP
	dw	$JCXZ,REL8JMP
	dw	$IN,IOIMM
	dw	$IN,IOIMM
	dw	$OUT,IOIMM
	dw	$OUT,IOIMM
	dw	$CALL,REL16JMP
	dw	$JMP,REL16JMP
	dw	$JMP,FARADR
	dw	$JMP,REL8JMP
	dw	$IN,IODX
	dw	$IN,IODX
	dw	$OUT,IODX
	dw	$OUT,IODX

	dw	$LOCK,NOARGS			;F0
	dw	$DB,ILLBYTE
	dw	$REP,PREFIX
	dw	$REPZ,PREFIX
	dw	$HLT,NOARGS
	dw	$CMC,NOARGS
	dw	0,GRP1
	dw	0,GRP1
	dw	$CLC,NOARGS
	dw	$STC,NOARGS
	dw	$CLI,NOARGS
	dw	$STI,NOARGS
	dw	$CLD,NOARGS
	dw	$STD,NOARGS
	dw	0,GRP2
	dw	0,GRP2

$SEGS	DB 'E','S'+80H,'C','S'+80H,'S','S'+80H,'D','S'+80H
$REG8	DB 'A','L'+80H,'C','L'+80H,'D','L'+80H,'B','L'+80H
	DB 'A','H'+80H,'C','H'+80H,'D','H'+80H,'B','H'+80H
$REG16	DB 'A','X'+80H,'C','X'+80H,'D','X'+80H,'B','X'+80H
	DB 'S','P'+80H,'B','P'+80H,'S','I'+80H,'D','I'+80H

$BytePtr	db	'Byte Ptr',' '+80H
$WordPtr	db	'Word Ptr',' '+80H
$DwordPtr	db	'Dword Ptr',' '+80H
$QwordPtr	db	'Qword Ptr',' '+80H
$TbytePtr	db	'Tbyte Ptr',' '+80H

$ModBXSI	db	'[BX+SI',']'+80H
$ModBXDI	db	'[BX+DI',']'+80H
$ModBPSI	db	'[BP+SI',']'+80H
$ModBPDI	db	'[BP+DI',']'+80H
$ModSI		db	'[SI',']'+80H
$ModDI		db	'[DI',']'+80H
$ModBP		db	'[BP',']'+80H
$ModBX		db	'[BX',']'+80H

$ModAddress	dw	$ModBXSI,$ModBXDI,$ModBPSI,$ModBPDI
		dw	$ModSI,$ModDI,$ModBP,$ModBX
Fformats	dw	$TbytePtr,$BytePtr,$WordPtr,0,$DwordPtr,$DwordPtr,$QwordPtr,$WordPtr
$ARITHGRP	dw	$ADD,$OR,$ADC,$SBB,$AND,$SUB,$XOR,$CMP
$SHFTGRP	dw	$ROL,$ROR,$RCL,$RCR,$SHL,$SHR,$DB,$SAR
$GRP1		dw	$TEST,$DB,$NOT,$NEG,$MUL,$IMUL,$DIV,$IDIV
$GRP2		dw	$INC,$DEC,$CALL,$CALL,$JMP,$JMP,$PUSH,$DB
$FARITH		DW	$FADD,$FMUL,$FCOM,$FCOMP,$FSUB,$FSUBR,$FDIV,$FDIVR
$FARITHR	DW	$FADD,$FMUL,0,$FCOMPP,$FSUBR,$FSUB,$FDIVR,$FDIV
$FARITHP	DW	$FADDP,$FMULP,$FCOMP,$FCOMPP,$FSUBRP,$FSUBP,$FDIVRP,$FDIVP
$FIARITH	DW	$FIADD,$FIMUL,$FICOM,$FICOMP,$FISUB,$FISUBR,$FIDIV,$FIDIVR
$FARITH1	DW	$FLD,0,$FST,$FSTP,$FLDENV,$FLDCW,$FSTENV,$FSTCW
$FARITH2	DW	$FLD,0,$FST,$FSTP,$FRSTOR,0,$FSAVE,$FSTSW
$FIARITH1	DW	$FILD,0,$FIST,$FISTP,0,$FLD,0,$FSTP
$FIARITH2	DW	$FILD,0,$FIST,$FISTP,$FBLD,$FILD,$FBSTP,$FISTP
$FCTRL		DW	$FENI,$FDISI,$FCLEX,$FINIT,$FSETPM,0,0,0
$FLDRR1		DW	$FLD,$FXCH,$FNOP,0,0,0,0,0
$FLDRR2		DW	$FFREE,$FXCH,$FST,$FSTP,$FUCOM,$FUCOMP,0,0
$FARITH3	DW	$FCHS,$FABS,0,0,$FTST,$FXAM,0,0
$FCONST		DW	$FLD1,$FLDL2T,$FLDL2E,$FLDPI,$FLDLG2,$FLDLN2,$FLDZ,0
$FTRANS		DW	$F2XM1,$FYL2X,$FPTAN,$FPATAN,$FXTRACT,$FPREM1,$FDECSTP,$FINCSTP
		DW	$FPREM,$FYL2XP1,$FSQRT,$FSINCOS,$FRNDINT,$FSCALE,$FSIN,$FCOS


SYMBOL	Macro	Name
$&Name:
	lastch = 0
	IRPC	ch,Name
		if lastch
			db	lastch
		endif
		lastch = "&ch"
	endm
	db	lastch+80H
endm
	SYMBOL	<AAA>
	SYMBOL	<AAD>
	SYMBOL	<AAM>
	SYMBOL	<AAS>
	SYMBOL	<ADC>
	SYMBOL	<ADD>
	SYMBOL	<AND>
	SYMBOL	<BOUND>
	SYMBOL	<CALL>
	SYMBOL	<CBW>
	SYMBOL	<CLC>
	SYMBOL	<CLD>
	SYMBOL	<CLI>
	SYMBOL	<CMC>
	SYMBOL	<CMP>
	SYMBOL	<CMPSB>
	SYMBOL	<CMPSW>
	SYMBOL	<CS>
	SYMBOL	<CWD>
	SYMBOL	<DAA>
	SYMBOL	<DAS>
	SYMBOL	<DB>
	SYMBOL	<DEC>
	SYMBOL	<DIV>
	SYMBOL	<DS>
	SYMBOL	<ENTER>
	SYMBOL	<ES>
	SYMBOL	<ESC>
	SYMBOL	<F2XM1>
	SYMBOL	<FABS>
	SYMBOL	<FADD>
	SYMBOL	<FADDP>
	SYMBOL	<FBLD>
	SYMBOL	<FBSTP>
	SYMBOL	<FCHS>
	SYMBOL	<FCLEX>
	SYMBOL	<FCOM>
	SYMBOL	<FCOMP>
	SYMBOL	<FCOMPP>
	SYMBOL	<FCOS>
	SYMBOL	<FDECSTP>
	SYMBOL	<FDISI>
	SYMBOL	<FDIV>
	SYMBOL	<FDIVP>
	SYMBOL	<FDIVR>
	SYMBOL	<FDIVRP>
	SYMBOL	<FENI>
	SYMBOL	<FFREE>
	SYMBOL	<FIADD>
	SYMBOL	<FICOM>
	SYMBOL	<FICOMP>
	SYMBOL	<FIDIV>
	SYMBOL	<FIDIVR>
	SYMBOL	<FILD>
	SYMBOL	<FIMUL>
	SYMBOL	<FINCSTP>
	SYMBOL	<FINIT>
	SYMBOL	<FIST>
	SYMBOL	<FISTP>
	SYMBOL	<FISUB>
	SYMBOL	<FISUBR>
	SYMBOL	<FLD>
	SYMBOL	<FLDCW>
	SYMBOL	<FLDENV>
	SYMBOL	<FLD1>
	SYMBOL	<FLDLG2>
	SYMBOL	<FLDLN2>
	SYMBOL	<FLDL2E>
	SYMBOL	<FLDL2T>
	SYMBOL	<FLDPI>
	SYMBOL	<FLDZ>
	SYMBOL	<FMUL>
	SYMBOL	<FMULP>
	SYMBOL	<FNOP>
	SYMBOL	<FNCLEX>
	SYMBOL	<FNDISI>
	SYMBOL	<FNENI>
	SYMBOL	<FNINIT>
	SYMBOL	<FNSAVE>
	SYMBOL	<FNSTCW>
	SYMBOL	<FNSTENV>
	SYMBOL	<FNSTSW>
	SYMBOL	<FPATAN>
	SYMBOL	<FPREM>
	SYMBOL	<FPREM1>
	SYMBOL	<FPTAN>
	SYMBOL	<FRNDINT>
	SYMBOL	<FRSTOR>
	SYMBOL	<FSAVE>
	SYMBOL	<FSCALE>
	SYMBOL	<FSETPM>
	SYMBOL	<FSIN>
	SYMBOL	<FSINCOS>
	SYMBOL	<FSQRT>
	SYMBOL	<FST>
	SYMBOL	<FSTCW>
	SYMBOL	<FSTENV>
	SYMBOL	<FSTP>
	SYMBOL	<FSTSW>
	SYMBOL	<FSUB>
	SYMBOL	<FSUBP>
	SYMBOL	<FSUBR>
	SYMBOL	<FSUBRP>
	SYMBOL	<FTST>
	SYMBOL	<FUCOM>
	SYMBOL	<FUCOMP>
	SYMBOL	<FUCOMPP>
	SYMBOL	<FWAIT>
	SYMBOL	<FXAM>
	SYMBOL	<FXCH>
	SYMBOL	<FXTRACT>
	SYMBOL	<FYL2X>
	SYMBOL	<FYL2XP1>
	SYMBOL	<HLT>
	SYMBOL	<IDIV>
	SYMBOL	<IMUL>
	SYMBOL	<IN>
	SYMBOL	<INC>
	SYMBOL	<INSB>
	SYMBOL	<INSW>
	SYMBOL	<INT>
	SYMBOL	<INT3>
	SYMBOL	<INTO>
	SYMBOL	<IRET>
	SYMBOL	<JA>
	SYMBOL	<JB>
	SYMBOL	<JBE>
	SYMBOL	<JC>
	SYMBOL	<JCXZ>
	SYMBOL	<JE>
	SYMBOL	<JG>
	SYMBOL	<JGE>
	SYMBOL	<JL>
	SYMBOL	<JLE>
	SYMBOL	<JMP>
	SYMBOL	<JNB>
	SYMBOL	<JNBE>
	SYMBOL	<JNC>
	SYMBOL	<JNE>
	SYMBOL	<JNO>
	SYMBOL	<JPO>
	SYMBOL	<JNP>
	SYMBOL	<JNS>
	SYMBOL	<JO>
	SYMBOL	<JP>
	SYMBOL	<JS>
	SYMBOL	<LAHF>
	SYMBOL	<LDS>
	SYMBOL	<LEA>
	SYMBOL	<LEAVE>
	SYMBOL	<LES>
	SYMBOL	<LOCK>
	SYMBOL	<LODSB>
	SYMBOL	<LODSW>
	SYMBOL	<LOOP>
	SYMBOL	<LOOPZ>
	SYMBOL	<LOOPNZ>
	SYMBOL	<MOV>
	SYMBOL	<MOVSB>
	SYMBOL	<MOVSW>
	SYMBOL	<MUL>
	SYMBOL	<NEG>
	SYMBOL	<NOP>
	SYMBOL	<NOT>
	SYMBOL	<OR>
	SYMBOL	<OUT>
	SYMBOL	<OUTSB>
	SYMBOL	<OUTSW>
	SYMBOL	<POP>
	SYMBOL	<POPA>
	SYMBOL	<POPF>
	SYMBOL	<PUSH>
	SYMBOL	<PUSHA>
	SYMBOL	<PUSHF>
	SYMBOL	<RCL>
	SYMBOL	<RCR>
	SYMBOL	<REP>
	SYMBOL	<REPZ>
	SYMBOL	<REPNZ>
	SYMBOL	<RETF>
	SYMBOL	<RETN>
	SYMBOL	<ROL>
	SYMBOL	<ROR>
	SYMBOL	<SAHF>
	SYMBOL	<SAR>
	SYMBOL	<SBB>
	SYMBOL	<SCASB>
	SYMBOL	<SCASW>
	SYMBOL	<SHL>
	SYMBOL	<SHR>
	SYMBOL	<SS>
	SYMBOL	<STC>
	SYMBOL	<STD>
	SYMBOL	<STI>
	SYMBOL	<STOSB>
	SYMBOL	<STOSW>
	SYMBOL	<SUB>
	SYMBOL	<TEST>
;	SYMBOL	<WAIT>
	SYMBOL	<XCHG>
	SYMBOL	<XLAT>
	SYMBOL	<XOR>
	
;;UNASM_TEXT	ENDS
_TEXT   ENDS

	END

