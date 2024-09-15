; em187d.asm -- definitions for em187.asm

; define the structure of a floating point accumulator

;ACCUM   struc
	struc	ACCUM
tag     resb	1
sign    resb	1
expon   resw	1
mantis  resw	1           ; high order word in low address
        resw	1
%if  BIG
        resw	1           ; lower order words in higher addresses
        resw	1
%endif
lenACCUM	equ	$
;ACCUM   ends
;	endstruc

; define the condition code bits
C3      equ     40H
C2      equ     04H
C1      equ     02H
C0      equ     01H

; define the tag conditions
tag_valid   equ     0
tag_zero    equ     1
tag_infin   equ     2
tag_empty   equ     3
tag_invalid equ     6

;define the funny exponent internal zero has
exp_of_FPzero   equ   8001H         ;minimum negative number
exp_of_FPinf    equ   7FFFH         ;maximum positive number

;define the instruction bits
Rbit        equ     4               ;reverse source and destination
Pbit        equ     2               ;pop bit
FMbits      equ     6               ;memory format bits

;define the exception bits
Iexcept     equ     1       ;invalid operation
Dexcept     equ     2       ;denormalized operand
Zexcept     equ     4       ;zero divide
Oexcept     equ     8       ;overflow
Uexcept     equ    10h      ;underflow
Pexcept     equ    20h      ;precision

Sflag       equ    40h      ;stack flag     (new with 80187)
Estatus     equ    80h      ;error summary status

;define the high order error codes
errUnemulated   equ     0100h   ;unemulated operation
errSqrt         equ     0200h   ;error in SQRT
;unassigned
errStkOverflow  equ     0800h   ;
errStkUnderflow equ     1000h   ;

;define the layout of the saved registers
v7_regs equ   0
v7_ds   equ     v7_regs
v7_ss   equ     v7_ds+2
v7_es   equ     v7_ss+2

v7_di   equ     v7_es+2
v7_si   equ     v7_di+2
v7_bp   equ     v7_si+2
v7_sp   equ     v7_bp+2
v7_bx   equ     v7_sp+2
v7_dx   equ     v7_bx+2
v7_cx   equ     v7_dx+2
v7_ax   equ     v7_cx+2

v7_ip   equ     v7_ax+2
v7_cs   equ     v7_ip+2
v7_flag equ     v7_cs+2

CR      equ     0dH             ;carriage return
LF      equ     0aH             ;line feed

; end em187d.asm
