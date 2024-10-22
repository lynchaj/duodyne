;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MISC15.ASM -- Miscellaneous BIOS calls (mostly int 15h)
;  with mods for version -45 assembly
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
%include	"date.asm"
%include        "equates.asm"


%if NEED_TIMER_FIX
; swap the timers in the intiialization table
timer0          equ     TIM1
timer1          equ     TIM0
%else
; timers are their true selves in the initialization table
timer0          equ     TIM0
timer1          equ     TIM1
%endif


	SEGMENT	_TEXT

        global  BIOS_call_15h

; The stack offsets 
offset_BP       equ     0
offset_AX       equ     offset_BP+2
;offset_AL	equ	offset_AX+0
offset_AH       equ     offset_AX+1
offset_BX       equ     offset_AX+2
offset_DX	equ	offset_BX+2	; added for cassette I/O
offset_DS       equ     offset_DX+2
offset_IP       equ     offset_DS+2
offset_CS       equ     offset_IP+2
offset_FLAGS    equ     offset_CS+2


BIOS_call_15h:
	cmp     ah,04Fh         ; null keyboard intercept handler
        jne	.1
        iret			; carry was set by the call
.1:	
        pushm   bp,ax,bx,dx,ds
        mov     bp,sp           ; establish stack frame addressing

%if 0
	cmp     ah,04Fh         ; null keyboard intercept handler
        je      bye_bye		; was 'set_carry'

	cmp	ah,0		; cassette motor on command
	je	fn00
	cmp	ah,1		; cassette motor off
	je	fn01
	cmp	ah,2		; cassette read block
	je	fn02
	cmp	ah,3		; cassette write block
	je	fn03
	cmp	ah,4		; cassette GPIO2 on command
	je	fn04
	cmp	ah,5		; cassette GPIO2 off command
	je	fn05
%else	
        mov     bl,ah
        xor     bh,bh
        cmp     bl,fn00max/2
        jae     try_fn80

        add     bx,bx
    cs  jmp     near [int15fn00+bx]     ; dispatch
%endif

try_fn80:
	cmp     ah,0C0h
        je      fnC0
        cmp     ah,0C1h
        je      fnC1

        mov     bl,ah
        xor     bh,bh

        sub     bl,80h          ; miscellaneous Int15 functions
        cmp     bl,fn80max/2
        jae     unknown

        add     bx,bx
    cs  jmp     near [int15fn80+bx]     ; dispatch

         
unknown:
	mov	byte [offset_AH+bp],0FFh	; flag error
set_carry:
        or      byte [bp+offset_FLAGS],1        ; set the carry bit
        jmp     bye_bye

okay:
	mov	byte [offset_AH+bp],00h		; flag dummy okay
clear_carry:
        and     byte [bp+offset_FLAGS],~1       ; clear the carry flag
bye_bye:
        popm    bp,ax,bx,dx,ds
        iret


int15fn00:
	dw	fn00		; cassette motor on command
	dw	fn01		; cassette motor off
	dw	fn02		; cassette read block
	dw	fn03		; cassette write block
	dw	fn04		; cassette GPIO2 on command
	dw	fn05		; cassette GPIO2 off command
fn00max         equ     $-int15fn00

int15fn80:
        dw      fn80            ; device open
        dw      fn81            ; device close
        dw      fn82            ; process termination
        dw      fn83            ; event wait
        dw      fn84            ; read joystick
        dw      fn85            ; SysReq key
        dw      fn86            ; delay
        dw      fn87            ; move extended memory block
        dw      fn88            ; get extended memory size
        dw      fn89            ; enter protected mode
%if TBASIC
        dw      fn8a            ; getline code
%else
	dw	unknown		; no TBASIC, so no call
%endif
	dw	fn8b
	dw	fn8c
	dw	fn8e
	dw	fn8f
	dw	fn90		; Device Wait
	dw	fn91		; Device Post
fn80max         equ     $-int15fn80


; Dummy routines for the following:
fn80    equ     okay		; Device Open
fn81    equ     okay		; Device Close
fn82    equ     okay		; Process Termination

fn84    equ     unknown		; Read Joystick
fn85    equ     okay		; SysReq Key make/break

fn87    equ     unknown		; Move Extended Memory Block
fn89    equ     unknown		; Enter Protected Mode

fn8b	equ	unknown
fn8c	equ	unknown
fn8d	equ	unknown
fn8e	equ	unknown
fn8f	equ	unknown

fn90	equ	okay		; Device Wait
fn91	equ	okay		; Device Post

;
; Get Extended Memory size
;
;       There is No high memory on an 80186/8
;       Always return 0
;
fn88:
        mov     word [bp+offset_AX],0
        jmp     clear_carry


        
%if TBASIC
; Get Line (direct access to SIO.C 'getline' routine)
;
;  Enter with:
;       CX      length of buffer
;       DS:DX   pointer to the buffer
;
;  Return with:
;       Buffer of length-1 characters (maximum), NUL terminated
;
fn8a:
        sti                             ; enable interrupts
        pushm   cx,dx

        mov     ax,dx                   ; DX:AX is pointer argument
        mov     dx,ds                   ; **
        mov     bx,cx                   ; BX is second argument

        push    DGROUP                  ; for the C-code
        popm    ds
        extern  getline_                ; this is a __fastcall entry
        call    getline_

        popm    cx,dx
        jmp     clear_carry
%endif


%include "cassette.asm"
%if 0
;--------------------------------------------------------
; Cassette support routines
;	(AH) = 0 TURN CASSETTE MOTOR ON
;	(AH) = 1 TURN CASSETTE MOTOR OFF
;	(AH) = 2 READ 1 OR MORE 256 BYTE BLOCKS FROM CASSETTE
;		(ES,BX) = POINTER TO DATA BUFFER
;		(CX) = COUNT OF BYTES TO READ
;		ON EXIT:
;  		(ES,BX) = POINTER TO LAST BYTE READ + 1
;  		(DX) = COUNT OF BYTES ACTUALLY READ
;  		(CY) = 0 IF NO ERROR OCCURRED
;  		     = 1 IF ERROR OCCURRED
;  		(AH) = ERROR RETURN IF (CY)= 1
;  			= 01 IF CRC ERROR WAS DETECTED
;  			= 02 IF DATA TRANSITIONS ARE LOST
;  			= 04 IF NO DATA WAS FOUND
;  	(AH) = 3 WRITE 1 OR MORE 256 BYTE BLOCKS TO CASSETTE
;  		(ES,BX) = POINTER TO DATA BUFFER
;  		(CX) = COUNT OF BYTES TO WRITE
;  		ON EXIT:
;		(EX,BX) = POINTER TO LAST BYTE WRITTEN + 1
;		(CX) = 0
;	(AH) = 4 TURN GPIO2 ON
;	(AH) = 5 TURN GPIO2 OFF
;	(AH) = ANY OTHER THAN ABOVE VALUES CAUSES (CY)= 1
;		AND (AH)= 80 TO BE RETURNED (INVALID COMMAND).
;--------------------------------------------------------
; PURPOSE:
;  TO TURN ON CASSETTE MOTOR
;  16550 I/O pins are active low so we need to add
;  an inverter (7400) before the 75452 to make this work.
;  Cassette motor connected to OUT1* on 16550, which is
;  bit2 of MCR.
;--------------------------------------------------------
fn00:
	mov	dx,cuart_mcr			; get device code
	in	al,dx				;read cassette uart mcr
	or	al,04H				; SET BIT TO TURN ON
W3:	out	dx,al				;WRITE IT OUT
	mov	word [bp+offset_AX],0000h	; signal success to caller
	jmp	clear_carry


;----------------------------------
; PURPOSE:
;  TO TURN CASSETTE MOTOR OFF
;-----------------------------------
fn01:
	mov	dx,cuart_mcr			; get device code
	in	al,dx				;read cassette uart mcr
	and	al,~04h				; clear bit to turn off motor
	jmp	W3				;write it, clear error, return


;--------------------------------------------
; PURPOSE:
;  TO READ 1 OR MORE 256 BYTE BLOCKS FROM CASSETTE
;
; ON ENTRY:
;  ES IS SEGMENT FOR MEMORY BUFFER (FOR COMPACT CODE)
;  BX POINTS TO START OF MEMORY BUFFER
;  CX CONTAINS NUMBER OF BYTES TO READ
; ON EXIT:
;  BX POINTS 1 BYTE PAST LAST BYTE PUT IN MEM
;  CX CONTAINS DECREMENTED BYTE COUNT
;  DX CONTAINS NUMBER OF BYTES ACTUALLY READ
;
;  CARRY FLAG IS CLEAR IF NO ERROR DETECTED
;  CARRY FLAG IS SET IF CRC ERROR DETECTED
;--------------------------------------------
fn02:
	mov	word [bp+offset_AX],80ffh	; return error code to caller
	jmp	set_carry


;--------------------------------------------
;  READ 1 OR MORE 256 BYTE BLOCKS FROM CASSETTE
;
; ON ENTRY:
;  ES IS SEGMENT FOR MEMORY BUFFER (FOR COMPACT CODE)
;  BX POINTS TO START OF MEMORY BUFFER
;  CX CONTAINS NUMBER OF BYTES TO READ
; ON EXIT:
;  BX POINTS 1 BYTE PAST LAST BYTE PUT IN MEM
;  CX CONTAINS DECREMENTED BYTE COUNT
;  DX CONTAINS NUMBER OF BYTES ACTUALLY READ
;--------------------------------------------
fn03:
	mov	word [bp+offset_AX],80ffh	; return error code to caller
	jmp	set_carry


;--------------------------------------------------------
; PURPOSE:
;  TO TURN CASSETTE GPIO2 ON
;  16550 I/O pins are active low so we need to add
;  an inverter (7400) before the 75452 to make this work.
;  GPIO2 is OUT2* on 16550, which is bit3 of MCR.
;--------------------------------------------------------
fn04:
	mov	dx,cuart_mcr			; get device code
	in	al,dx   			;read cassette uart mcr
	or	al,08h				; set bit to turn on
W4:	out	dx,al				;write it out
	mov	word [bp+offset_AX],0000h	; signal success to caller
	jmp	clear_carry


;----------------------------------
; PURPOSE:
;  TO TURN CASSETTE GPIO2 OFF
;-----------------------------------
fn05:
	mov	dx,cuart_mcr			; get device code
	in	al,dx				;read cassette uart mcr
	and	al,~08h				; clear bit to turn off motor
	jmp	W4				;write it, clear error, return
%endif	


        SEGMENT CONST
env_table:
        dw      len_env_table
	db	MODEL_BYTE	; PC/XT
	db	SUBMODEL_BYTE	; rev 1		CPUREGS.ASM
	db	VERSION_MAJOR	; BIOS revision level  DATE.ASM
        db      00100100b | (CVDU_8242 << 4)
				; DMA ch 3 used = 0             7
                                ; slave 8259 present = 0        6
                                ; RTC available = 1             5
                                ; KBD intercept available (int 15h, fn4F) = 0
                                ; Wait for Event avail. = 0     3
                                ; Extended BIOS data area alloc. = 1   (FPEM will use)
                                ; Micro Channel = 0             1
                                ; reserved bit = 0              0
        db      0       ; unknown usage
        db      0       ; unknown usage
len_env_table   equ     $-env_table
        db      0,0     ; just in case


	SEGMENT	_TEXT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get System Environment
;   Input:
;	AH = 0C0h	function code
;   Returns:
;	ES:BX		pointer to the environment table above
;	Carry clear	success
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fnC0:
        mov     word [bp+offset_BX],env_table
        push    DGROUP
        popm    es                              ; return ES:BX
;;;	mov     byte [bp+offset_AH],0           ; signal no error
        jmp     clear_carry


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get Extended BIOS Data Area Address
;   Input:
;	AH = 0C1h	function code
;   Returns:
;	ES		set to the EBDA segment address
;	Carry clear	success
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fnC1:
        push    bios_data_seg
        popm    ds
        mov     es,[EBDA_paragraph]
        jmp     clear_carry


; Disable timer1 interrupts
;
;	uses AX & DX
;	exits with AX=0
;
timer_disable:
	mov	dx,timer1+TCON	
	in	ax,dx		; get control register
	and	ax,(~tc_EN)&0FFFFh  ; disable timer
	or	ax,tc_nINH		; change enable flag
	out	dx,ax		; disable the timer
	
	xor	ax,ax
	mov	dx,timer1+TCNT		; zero the count
	out	dx,ax
 	ret

; Enable timer1 interrupts
;
;	uses AX & DX
;
timer_enable:
	mov	dx,timer1+TCON	
	in	ax,dx		; get control register
	or	ax,tc_EN+tc_nINH+tc_INT		; enable timer & interrupts
	out	dx,ax		; enable the timer
 	ret	

	global set_count
set_count:
	xor	bx,bx
; wait in microseconds in BX:CX:DX

;  to divide by 976 microseconds, the resolution of the timer
;  we divide by 1000000/1024 == 15625/16
;  OR we multiply by 16, then divide by 15625

	pushm	cx
	mov	ax,cx		; BX:AX:DX is microsecond count
	mov	cx,4
.4:	shl	dx,1		; * 16 is left shift by 4
	rcl	ax,1
	rcl	bx,1
	loop	.4
	mov	cx,15625	; divisor
	xchg	bx,dx		; DX:AX:BX is count
	div	cx
	mov	word [rtc_count+2],ax	; AX is high quotient
	xchg	ax,bx		; and DX is remainder
	div	cx		; DX:AX is low dividend
	popm	cx

%if 0
; since count goes to -1, there will always be at least 1 tick
	or	bx,ax		; test for zero tick count
	jnz	.5
	inc	ax		; wait at least 1 tick
.5:
%endif
	mov	word [rtc_count],ax	; AX is final low quotient
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fn83 -- Event Wait
;   Input:
;	AH = 83h
;
;   Subfucntion:
;	AL = 01h	Cancel event wait
;   Output:
;	nothing
;
;   Subfunction:
;	AL = 00h	Request Event Wait
;	CX:DX = delay in microseconds
;	ES:BX = address of semaphore byte
;		the semaphore bit 7 is set at the end of the inverval
;   Output:
;	Carry flag clear if timer started
;	Carry flag set if function unsuccessful (event wait already active)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn83:		; BP,AX,BX,DX,DS already saved
	push	bios_data_seg
	popm	ds
	or	al,al		; test for zero
	jz	.set_wait

	dec	al		; test for one
	jnz	set_carry	; error on illegal subfunction
; cancel wait
	call	timer_disable
;	xor	ax,ax		; side effect of 'timer_disable'
	mov	byte [rtc_wait_active],al
	mov	word [rtc_count+2],ax
	mov	word [rtc_count],ax
	mov	word [user_semaphore+2],ax
	mov	word [user_semaphore],ax
	jmp	clear_carry

.set_wait:
	test	byte [rtc_wait_active],01h	; any wait in progress
	jnz	set_carry

	mov	bx,[offset_BX+bp]	; restore BX
	mov	word [user_semaphore+2],es
	mov	word [user_semaphore],bx

	call	set_count	
	
	call	timer_enable
	mov	byte [rtc_wait_active],01h	; flag wait active
	mov	ax,8300h
	jmp	clear_carry




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fn86 -- Delay
;   Input:
;	AH = 86h
;	CX:DX = delay in microseconds
;
;   Output:
;	Carry flag clear if delay occurred
;	Carry flag set if timer busy; no delay occurred
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn86:		; BP,AX,BX,DX,DS already saved
	push	bios_data_seg
	popm	ds
	test	byte [rtc_wait_active],01h	; is a wait active?
	jnz	set_carry		; perform no wait, we're busy

	call	set_count
	mov	byte [rtc_wait_active],01h		; mark timer active

	xor	bx,bx
	mov	word [user_semaphore],bx
	mov	word [user_semaphore+2],bx

	call	timer_enable
	sti					; don't forget to enable interrupts
	jmp	.3


.wait:	hlt
.3:	test	byte [rtc_wait_active],80h		; wait for posting
	jz	.wait

	mov	byte [rtc_wait_active],0		; mark not in use
	jmp	clear_carry

	
	global	rtc_interrupt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  rtc_interrupt             (timer0, if NEED_TIMER_FIX)
;
;       This is the 1024 Hz timer tick from INT 70h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rtc_interrupt:
	pushm	ax,dx,si,ds

	push	bios_data_seg
	popm	ds

	test	byte [rtc_wait_active],01h	; test active bit
	jz	.dismiss

	sub	word [rtc_count],1
	sbb	word [rtc_count+2],0
	jnc	.dismiss		; counted down by 1

; counted down to -1, post the event
	mov	byte [rtc_wait_active],80h	; mark posted, inactive
	lds	si,[user_semaphore]
	mov	ax,ds			; check for null pointer
	or	ax,si			; **
	jz	.2
	or	byte [si],80h			; post event
.2:	call	timer_disable

.dismiss:
; signal EOI (End of Interrupt)
        mov     dx,PIC_EOI              ; EOI register
        mov     ax,EOI_NSPEC            ; non-specific
        out     dx,ax                   ; signal it

	popm	ax,dx,si,ds
        iret

