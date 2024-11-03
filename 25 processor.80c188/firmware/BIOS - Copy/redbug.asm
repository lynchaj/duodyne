;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; redbug.asm -- Relocatable BIOS Debugger
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   This version is for assembly by  NASM 0.98.39 or later
;
; Copyright (C) 2010 John R. Coffman.  All rights reserved.
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include        "config.asm"
%include        "cpuregs.asm"
%include        "equates.asm"
;
        global  redbug
        global  crlf
        extern  _cprintf
        extern  @uart_putchar
;        extern  _unasm
        extern  @len_instr
        extern  _unassemble
        extern  _command

;***************************************************************************
; **** This debugger does not allow the modification of the SS or SP ****
;***************************************************************************


regSS   equ     0               ; offset from BP
regDS   equ     regSS+2
regES   equ     regDS+2
; from the pusha:
regDI   equ     regES+2
regSI   equ     regDI+2
regBP   equ     regSI+2
regSP   equ     regBP+2
regBX   equ     regSP+2
regDX   equ     regBX+2
regCX   equ     regDX+2
regAX   equ     regCX+2
; from the interrupt call:
regIP   equ     regAX+2
regCS   equ     regIP+2
regFLAGS equ    regCS+2


        SEGMENT _TEXT

;length  dw      0               ; length of instruction


        global  zero_divide
        global  single_step
        global  nmi_interrupt
        global  breakpoint
        global  INTO_trap
        global  bound_trap
        global  undefined_op


%if 0
; These are the traps
trap00:
        dw      zero_divide     ; divide by zero
        dw      single_step     ; single step
        dw      nmi_interrupt   ; NMI
        dw      breakpoint      ; breakpoint (int 3)
        dw      INTO_trap       ; INTO
        dw      bound_trap      ; BOUND
        dw      undefined_op    ; undefined opcode
; traps 0..6  a total of 7
%endif


single_step:
   cs   dec     word [trace_count]
        jz      .1
        push    bp              ; address into the stack
        mov     bp,sp
        or      byte [bp+regFLAGS-regAX+1],1   ; set Trace bit
        pop     bp
        iret                    ; and continue
.1:
        pusha                   ; save all the registers
        mov     bx,1
        jmp     common_entry

breakpoint:
        pusha
        mov     bx,0
        jmp     common_entry
zero_divide:
        pusha
        mov     bx,2
        jmp     common_entry
undefined_op:
        pusha
        mov     bx,4
        jmp     common_entry
nmi_interrupt:
        pusha
        mov     bx,6
        jmp     common_entry
INTO_trap:
        pusha
        mov     bx,8
        jmp     common_entry
bound_trap:
        pusha
        mov     bx,10
        jmp     common_entry
redbug:                                 ; actual call:
        pusha
        mov     bx,12
common_entry:
        push    es
        push    ds
        push    ss
        mov     bp,sp           ; SS:BP points at machine status
	cld			; 02-Nov_2014 ; clear the direction flag
			; the IRET will restore this flag
        and     byte [bp+regFLAGS+1],0FEh    ; clear the TRACE bit
        add     word [bp+regSP],6 ; fix the SP value by size of IRET
                                ; return block
        or      bx,bx           ; test for Breakpoint Trap
        jnz     .5
        dec     word [bp+regIP] ; move IP back 1 to the INT3 instruction
.5:     push    DGROUP
        popm    ds
        test    bl,1            ; odd one is trace trap
        jnz     .3
        push    ds
        push    word [m_table+bx]
        call    _cprintf
        add     sp,4
        call    crlf
.3:
        push    ss
        push    bp
        call    _command
        add     sp,4
;***************************************************************************
; the command dispatch goes here    based on DX:AX
;       AX == code
;       DX == count
;
;       AX==0 && DX==0  means GO
;       AX==0 && DX     means TRACE (DX is trace count)
;       AX    && DX==0  means STEP OVER, AX is length of present instr.
;***************************************************************************
        mov     bx,ax           ; copy the Code
        or      ax,dx           ; destroy AX
        jz      common_exit     ; both zero, we got the GO
; distinguish Step & Trace
        or      bx,bx           ; check length
        jnz     Step
; Trace operation (single_step)
Trace:
   cs   mov     [trace_count],dx        ; set the trace count
        or      byte [bp+regFLAGS+1],1  ; set the trace bit
        jmp     common_exit
Step:
        mov     dx,1
        jmp     Trace           ; for now

;***************************************************************************
; **** This debugger does not allow the modification of the SS or SP ****
;***************************************************************************

common_exit:
        pop     ax      ; was SS
        pop     ds
        pop     es
        popa            ;restore all but the SP
        iret            ; restore IP, CS, FLAGS


trace_count:    dw      1       ; Note variable in SOFT code segment

%if 0
;***************************************************************************
; print_regs
;       print two line register dump
;***************************************************************************
print_regs:
        push    di
        mov     di,sp
        push    word [bp+regDI]
        push    word [bp+regSI]
        push    word [bp+regBP]
        push    word [bp+regDX]
        push    word [bp+regCX]
        push    word [bp+regBX]
        push    word [bp+regAX]

        push    DGROUP
        push    word fmt_reg1
        call    _cprintf
        mov     sp,di

;;;      push    word [bp+regSP]
        mov     ax,[bp+regSP]
;;;        add     ax,6                    ; size of the IRET return block
        push    ax
        push    word [bp+regSS]
        push    word [bp+regIP]
        push    word [bp+regCS]
        push    word [bp+regES]
        push    word [bp+regDS]

        push    DGROUP
        push    word fmt_reg2
        call    _cprintf
        mov     sp,di

        mov     di,[bp+regFLAGS]
        call    print_flags
        call    crlf

        pop     di
        ret

print_flags:    ; flags are in DI
        push    ds
        push    DGROUP
        pop     ds

        cld
        mov     si,fmt_flags
        mov     ah,' '          ; Space is used below
.0:
        lodsb
        or      al,al           ; NUL terminates
        jz      .9

        cmp     al,ah           ; Char in FMT means flag bit to display
        jne      .2
        add     si,3
        shl     di,1            ; skip the bit
        jmp     .0

.2:     shl     di,1            ; test the bit
        jc      .3
        inc     si              ; flag bit is zero
        lodsb                   ; Get zero bit response
        xor     al,'a'-'A'
        call    @uart_putchar
        lodsb
        xor     al,'a'-'A'
        call    @uart_putchar
        jmp     .4
.3:     call    @uart_putchar
        lodsb
        call    @uart_putchar
        inc     si
        inc     si
.4:     mov     al,ah           ; after each response, put out a Space
        call    @uart_putchar
        jmp     .0

.9:     pop     ds
        ret
%endif

crlf:   mov     al,CR
        call    @uart_putchar
        mov     al,LF
        call    @uart_putchar
        ret


        SEGMENT CONST
%if 0
fmt_reg1:
        db      "AX=%04x  BX=%04x  CX=%04x  DX=%04x  BP=%04x  SI=%04x  DI=%04x",NL,0
fmt_reg2:
        db      "DS=%04x  ES=%04x  CS:IP=%04x:%04x  SS:SP=%04x:%04x   ",0

fmt_flags:
        db      "                "
        db      "OVNODNUPEIDI    "
        db      "MIPLZRNZ    ACNA"
        db      "    PEPO    CYNC",0,0,0,0,0,0,0
%endif

m0:     db      "Breakpoint",0
m2:     db      "Zero Divide",0
m4:     db      "Undefined Opcode",0
m6:     db      "NMI",0
m8:     db      "INTO trap",0
m10:    db      "BOUND trap",0
m12:    db      "Welcome to %4aRED%abug (? for help)",CR,LF,0

m_table:
        dw      m0,m2,m4,m6,m8,m10,m12


