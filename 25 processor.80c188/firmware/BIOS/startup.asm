%define DEBUG 0
;========================================================================
;  startup.asm  -  start the 80C188 processor from a power-on condition
;========================================================================
;   This version is for assembly by  NASM 0.98.39 or later
;
; Copyright (C) 2010,2020 John R Coffman.  All rights reserved.
; Provided for hobbyist use on the N8VEM SBC-188 v3 board.
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

%include	"config.asm"
%include        "cpuregs.asm"
%include	"date.asm"

warm_boot	equ	72h	; RESET_FLAG, our 'warm_boot' BDA offset

	org	0
init0:
        cli                             ; interrupts should be off already

%include	"post.asm"		; P.O.S.T. of CPU

	mov	ax,1
	mov	cl,32
	shl	ax,cl			; 186 and higher CPUs mask the shift to 5 bits
	or	ax,ax			; set Z flag in case SHL does not
	jz	.hlt			; < 80186 (8086 or 8088) will zero the AX
; proceed, we definitely have a CPU > 8088

	cpu	186

	cld                             ; clear direction flag (set to UP)
	mov	dx,cpu_relocation		; get reset state of the relocation register
	in	ax,dx			; read reset value; it is a constant
	cmp	ax,0x20FF		; it is this on the 80188/80c188
	je	.init01			;
; not equal, so it is not an 80188 class CPU,
;    or the relocation register has been moved
.hlt:
	hlt
.init01:
;;;	mov     dh,cpu_umcs>>8          ; high byte of I/O address
; high byte of I/O address is already set
        mov     si,table0               ; address of setup table
        mov     ax,cs                   ; get Code Segment
        mov     ds,ax                   ; for LODS
        mov     cx,table0_len           ; count of table items
init0_loop:
        lodsb
        mov     dl,al
        lodsw
        out     dx,ax
        loop    init0_loop
; memory selects are now set up

%if DEBUG
; do some debug I/O
	mov	dx,portD		;JRC's debug lights
	mov	al,0a5h
	out	dx,al
%endif

init1:	mov	dh,FDC>>8		; Local I/O byte setup
	mov	si,table1
	mov	cx,table1_len
init1_loop:
	lodsb
	mov	dl,al
	lodsb
	out	dx,al
	loop	init1_loop

%if 0
; output to the UART    for debugging only
	mov	al,'*'
	mov	dx,uart_thr		; transmit holding register
	out	dx,al
%endif

	xor	cx,cx			; CX guaranteed zero!!!
        mov     ds,cx                   ; CX = 0 from above
	mov	es,cx
;;;        mov     ss,cx                   ; set Stack Segment
;;;        mov     sp,400h                 ; set Stack Pointer (0400h absolute)
	mov	ax,[400h+warm_boot]	; save 'warm_boot' in SS
	mov	ss,ax		; only register not trashed by the memory test

; now let us test low memory
len_test0	equ	8192*4		; 32K words

	mov	ax,401h			; rotating 1-bit
	mov	si,0x18
	mov	cx,len_test0		; word count
	mov	bp,.1ret
	jmp	testmem00		; return through BP
.1ret:
	jc	stop

	mov	al,0
	mov	dx,LED0			; turn LED0 back on if okay
	out	dx,al

	mov	ax,0xFDFF		; rotating 0-bit
	mov	si,0x1C
	mov	cx,len_test0		; word count
	mov	bp,.2ret
	jmp	testmem00
.2ret:
	jc	stop

;;;	mov	al,0
	xor	ax,ax			; use to set SS later
	mov	dx,LED3
	out	dx,al

; now restore the SS register to 0000h
	mov	dx,ss
;;;	xor	ax,ax
	mov	ss,ax
	mov	sp,400h
	mov	[ss:400h+warm_boot],dx


; decide whether we are running on the SBC-188 v1/v2 or SBC-188 v3

	mov	ax,0x4000	; low memory not yet
	mov	ds,ax		;   enabled on the v1/v2 boards
	mov	es,ax
	mov	ax,0001
	mov	cx,len_test0
	call	testmem0
%if 0
	mov	bp,.3ret
	jmp	testmem00
.3ret:
%endif

	mov	al,'3'
	jnc	out3
	mov	al,'1'
out3:
%if 0
; output to the UART
        mov	dx,uart_thr		; transmit holding register
	out	dx,al
	mov	dx,portD
	out	dx,al			; debug output
%endif
	cmp	al,'3'
	jne	.9
        mov	al,1
	mov	dx,LED3
	out	dx,al
	dec	dx
	out	dx,al
; SBC-188 v3 identified
	mov	ax,3			; CPU board is the v3
 	jmp	startup

.9:
        mov     dh,cpu_umcs>>8          ; high byte of I/O address
        mov     si,table2               ; address of setup table
        mov     ax,cs                   ; get Code Segment
        mov     ds,ax                   ; for LODS
        mov     cx,table2_len           ; count of table items
init2_loop:
        lodsb
        mov     dl,al
        lodsw
        out     dx,ax
        loop    init2_loop
; memory selects are now set up
	mov	ax,1			; CPU board is the v1/v2

startup:
;    cs  jmp     far [goto]
%if DEBUG
; do some debug I/O
	mov	dx,portD		;JRC's debug lights
	mov	al,81h
	out	dx,al
%endif
%if DEBUG & 0
	mov	word [ss:400h+72h],1234h	; say warm boot
%endif
	jmp	startseg:0000h
	nop


stop:
	mov	ax,si
	mov	dx,portD
	out	dx,al
done:
	hlt
	jmp	done



Ignore          equ     1<<2            ; ignore external ready


table0:
        db_lo   cpu_relocation
        dw      020FFh                  ;(default)

        db_lo   cpu_umcs
	dw      0C038h | (256-CHIP)*64 | 3 | Ignore; wait states

M_RAM   equ     RAM/2		;use MMCS & LMCS on SBC188v1/v2
;M_RAM   equ     RAM		;use MMCS only
L_RAM   equ     RAM-M_RAM

;L_RAM   equ     256	; obsolete; from v3 testing
X_SIZ	equ	128	; 128K
X_AT	equ	0A0h	; A000:0000 .. B000:FFFF


%if L_RAM>0    ; don't touch LMCS if Zero
	db_lo   cpu_lmcs
        dw      00038h | (L_RAM*64-1)&3FC0h | RAM_WS&3 | Ignore
%endif

        db_lo   cpu_mmcs
        dw      001F8h | (X_AT*256) | 3; w.s. XMEM uses SRDY

        db_lo   cpu_mpcs
        dw      080B8h | (X_SIZ*32) | 3 | Ignore ; PACS 4..6 wait states

; fix I/O space at 0400h
        db_lo   cpu_pacs
        dw      00078h | 3; PACS 0..1 (really 0..3) W.S. and use SRDY

        db_lo   cpu_mdram
        dw      0000h

        db_lo   cpu_cdram
        dw      01FFh                   ; not used, so maximum

        db_lo   cpu_edram
        dw      0000h                   ; disable refresh entirely

        db_lo   cpu_pdcon
        dw      0000h                   ; Disable,  divisor=1

table0_len      equ     ($-table0)/3


; Local I/O
table1:
		db_lo	LED0
		db	1	; off (LED state is active low)

		db_lo	LED1
		db	0	; Reset state

		db_lo	LED2
		db	0	; Reset state

		db_lo	LED3
		db	1	; off (LED state is acrive low)

		db_lo	T1OSC18
		db	1	; use UART oscillator

		db_lo	FDC_RES
		db	1	; reset is active high

		db_lo	IDE8_RES
		db	0	; reset is active low (Fast IDE8)

; now add the default (9600bps/8250 UART setup)
		db_lo	uart_ier
		db	0	; disable all interrupts

		db_lo	uart_lcr
		db	80h	; DLAB latch access

		db_lo	uart_dll
		db	12	; divisor of 12 == 9600bps

		db_lo	uart_dlm
		db	0	; high order divisor

		db_lo	uart_lcr
		db	7	; disable DLAB, 8n2 char. mode

		db_lo	uart_fcr
		db	7	; FIFO enable, FIFOs reset

		db_lo	uart_mcr
		db	0Bh	; OUT2, nOUT1, RTS, DTR
		;		RESET, CLK LO, RTS, DATA HI

table1_len	equ	($-table1)/2


; the setup for the SBC v1/v2 memory selects
;

table2:
%if L_RAM>0
        db_lo   cpu_lmcs
        dw      00038h | (L_RAM*64-1)&3FC0h | RAM_WS&3 | Ignore
%endif

	db_lo	cpu_umcs		; set Config.asm wait states
	dw      0C038h | (256-CHIP)*64 | ROM_WS&3 | Ignore

        db_lo   cpu_mmcs
        dw      001F8h | (L_RAM*64) | RAM_WS&3 | Ignore

        db_lo   cpu_mpcs
        dw      080B8h | (M_RAM*32) | LCL_IO_WS&3 | Ignore

table2_len      equ     ($-table2)/3





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; testmem0 -- simple test of memory
;
;  Enter with:
;	AX	16-bit pattern
;	DS:SI	start address to test
;	CX	word count to test
;
;  Exit with:
;	Carry clear on no error
;	Carry set if there is an error
;
;	CX,SI,  DS,SS are preserved
;
;  Registers trashed:
;	direction flag is cleared
;	BP	used for return
;	ES
;	AX
;	BX
;	DX
;	DI
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
testmem0:
	pop	bp		; may use call if stack is set up
testmem00:			; entry if there is no stack
	cld
	mov	dx,ds		; make sure ES==DS
	mov	es,dx		; **
	mov	dx,ax
	mov	bx,cx		; save word count
	mov	di,si		; save start pointer
	clc			; always clear the carry
.1:
	stosw	; ES:[DI]	; store a word
	rcl	ax,1		; rotate 17-bit pattern
	loop	.1		; count through words

	mov	cx,bx		; restore count
	mov	di,si		; restore start address
	clc			; clear the carry
; for the compare, the pattern is in DX and Carry
.2:
	lahf			; save state of the Carry
	cmp	dx,[si]		; compare
	jne	short .3	; exit on error
	inc	si
	inc	si
	sahf			; restore the carry
	rcl	dx,1		; rotate 17-bit pattern
	loop	.2

	clc			; no error
	mov	si,di		; restore SI
	jmp	bp
.3:
	stc			; error return
	jmp	bp	; SI is error word, DX is expected value



        setloc  startuplength-16
start:
        jmp     startupseg:init0

	db	DATE_STRING0, 0
;  must be at F000:FFFE hex
	db	MODEL_BYTE
	db	0FFh



; At power up or reset, execution starts at label 'start'.
