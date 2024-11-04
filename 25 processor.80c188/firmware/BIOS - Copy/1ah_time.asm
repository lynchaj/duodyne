;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1Ah_time.asm -- date/time, NVRAM, and timers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Copyright (C) 2018 John R. Coffman.  All rights reserved.
; Provided for hobbyist use on the RetroBrew SBC-386EX board.
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
; along with this program in the file COPYING in the topmost source
; directory.  If not, see <http://www.gnu.org/licenses/>.
;
;
; Assembly by NASM 2.08 is preferred
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include	"config.asm"
%include	"cpuregs.asm"
%include	"macros.inc"

%include "..\..\sbc386\bios\seg_def.inc"
%include "..\..\sbc386\bios\i386ex.inc"
%include "..\..\sbc386\bios\bda.inc"
;%include "macro.inx"
%include "..\..\sbc386\bios\timer.inc"


%ifndef DEBUG
%define	DEBUG 1
%endif


	global	int_1Ah

segment	_TEXT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; INT 1A
;
; Enter with:
;       AH      function code
;
; Exit with:
;	varies
;
;       Carry clear
;
; Error:
;	AH	error code
;       Carry set
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int_1Ah:
	;cli done by the  INT 1Ah  call
	cld
	mov	di,scan
	xchg	al,ah
	mov	cx,len_scan
 repne	cs scasb
	sti	; the scasb may not be interrupted !!!
 	jne	fn_not_defined
	sub	di,scan+1
	shl	di,1
;;	add	di,scan+len_scan
	jmp	[cs:di+scan+len_scan]

	
%include "dispatch.inc"

%define	_DISPATCH 1
scan:
%include "1ah_disp.inc"
%undef	_DISPATCH
len_scan	equ	$-scan
%define _DISPATCH 2
%include "1ah_disp.inc"
%undef	_DISPATCH


set_alarm:
reset_alarm:
	jmp	fn_not_defined
;


fn_not_defined:
t0tab:
ttime:
tick:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INT 1A
; function 00	get_tick_count
;
;    Enter with:
;	AH	00h
;
;    Exit with:
;	CX:DX	tick count
;	AL	rolled over flag  0=no	1=day rollover
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	align	2
get_tick_count:
	push	ds		;save
	get_bda	DS
	cli		;disable interrupts
	mov	dx,[timer_count_low]
	mov	cx,[timer_count_high]
	xor	al,al
	xchg	al,[timer_overflow]
	sti		;restore interrupts
	clc
	pop	ds
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer 0 interrupt handler
;
;	Count down the tick timer
;	Reset if it reaches zero
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	int_irq0
	align	2
int_irq0:
	extern	clear_irq0	; currently in stub.asm
	jmp	clear_irq0


	global	start_timer0_
	extern	initb			; in start.asm
start_timer0_:
	pushm	ds,si
	push	cs
	pop	ds
	mov	si,t0tab
	call	initb
	popm	ds,si
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INT 1A
; function 01	set_tick_count
;
;    Enter with:
;	AH	01h
;	CX:DX	tick count
;
;    Exit with:
;	nothing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_tick_count:
	push	ds
	get_bda	DS	;address BDA
	cli		;disable interrupts
	mov	[timer_count_low],dx
	mov	[timer_count_high],cx
	mov	byte [timer_overflow],0	; 'byte' qualifier needed
	sti		;interrupts back on
	clc
	pop	ds
	ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; INT 1A
; function 02   Get Time
;
; Enter with:
;       AH      0x02
;
; Exit with:
;	CH	hours in BCD
;	CL	minutes in BCD
;	DH	seconds in BCD
;	DL	daylight savings time flag
;		  00=not DST, 01==DST
;	
;       Carry clear	if clock is running
;
; Error:
;       Carry set	if clock is stopped
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	get_time
get_time:
	pushm	ax
	xor	bx,bx		; saved at a higher level
	mov	ax, 1000_0001B << 8 | 0		;seconds
	mov	dl,al		; DST off
	call	byte_read
	mov	dh,ah		; save seconds

.1:	push	dx
	mov	ax, 1000_0001B << 8 | 1		; minutes
	call	byte_read
	mov	cl,ah		; save minutes
	mov	ax, 1000_0001B << 8 | 2		; hours
	call	byte_read
	mov	ch,ah		; save hours
	mov	ax, 1000_0001B << 8 | 0		;seconds
	call	byte_read
	pop	dx
	xchg	dh,ah
	cmp	ah,dh
	jne	.1		; loop back

	and	dh,0x7F		; mask clock halt bit
	add	ah,ah		; set carry if halted

	popm	ax
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; INT 1A
; function 03   Set Time
;
; Enter with:
;       AH      0x03
;
;	CH	hours in BCD
;	CL	minutes in BCD
;	DH	seconds in BCD
;	DL	daylight savings time flag (ignored)
;		  00=not DST, 01==DST
;	
; Exit with:
;       Carry clear	if clock is running
;
; Error:
;       Carry set	if clock is stopped
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	set_time
set_time:
	pushm	ax,dx

	pushm	cx,dx		;protect the parameters

	mov	al,0		;disable write protect
	call	wr_protect	;**
%if 0
	mov	ax, 1000_0000B << 8 | 0		;seconds
	mov	cl,80h			; stop the clock
	call	byte_write
%endif
	popm	bx		; was CX

	mov	ax, 1000_0000B << 8 | 2		;hours
	mov	cl,bh		; **
	and	cl,0x7F		; 24-hr format
	call	byte_write

	mov	ax, 1000_0000B << 8 | 1		;minutes
	mov	cl,bl		; **
	call	byte_write

	popm	bx		; was DX

	mov	ax, 1000_0000B << 8 | 0		;seconds
	mov	cl,bh
	and	cl,0x7F			; enable the clock
	call	byte_write

	mov	al,80h		;set Write Protect
	call	wr_protect

	jmp	ds_full_exit



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; INT 1A
; function 04   Get Date
;
; Enter with:
;       AH      0x04
;
; Exit with:
;	CH	century in BCD
;	CL	year in BCD
;	DH	month in BCD
;	DL	day in BCD
;	
;       Carry clear	if clock is running
;
; Error:
;       Carry set	if clock is stopped
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	get_date
get_date:
	mov	ax,1000_0001B << 8 | 6	;year
	call	byte_read
	mov	cl,ah		; return in CL

	mov	ax,1000_0001B << 8 | 4	;month
	call	byte_read
	mov	bh,ah		; save in BH

	mov	ax,1000_0001B << 8 | 3	;day of month (DATE)
	call	byte_read
	mov	bl,ah
	
	mov	ax,1000_0001B << 8 | 5	;day of week (DAY)
	call	byte_read
	mov	ch,ah		; save in Century byte

	mov	ax,1000_0001B << 8 | 0	;clock halt flag
	call	byte_read
; clock halt flag is in AH

	mov	dx,bx		;
	mov	al,ch		; Day-of-Week flag to AL
	mov	ch,0x19		; 20th century in CH
	cmp	cl,0x70		; year less than '70 sets carry
%if 0
	adc	al,0		; add in the carry if CL<70h
	daa			; correct (DAA doesn't work???)
%else
	jnb	.8
	mov	ch,0x20		; carry is set
.8:
%endif
	shl	ah,1		; clock halt to carry
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; INT 1A
; function 05   Set Date
;
; Enter with:
;       AH      0x05
;
;	CH	century in BCD	(used for Day Of Week calculation)
;	CL	year in BCD
;	DH	month in BCD
;	DL	day in BCD
;	
; Exit with:
;	Nothing
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	set_date
set_date:
	pushm	ax,dx		;usual 2 register save
	cmp	ch,0x20		; century must be 21st
	je	.1
	cmp 	ch,0x19		; century may be 20th
	jne	ds_error
.1:
	pushm	dx,cx

	call	day_of_week_

	popm	bx,cx		; was DX,CX
	pushm	cx		; save CX

	mov	ch,al		; DOW to CH

	mov	al,0		;disable write protect
	call	wr_protect

	mov	ax,1000_0000B << 8 | 6	;year
	call	byte_write	; year is in CL already

	mov	ax,1000_0000B << 8 | 4	;month
	mov	cl,bh			; was in DH
	call	byte_write

	mov	ax,1000_0000B << 8 | 3	;day (DATE)
	mov	cl,bl			; was in DL
	call	byte_write

	mov	ax,1000_0000B << 8 | 5	;day of week (DOW)
	mov	cl,ch
	inc	cl		; DS1302 is 1..7, not 0..6
	call	byte_write

	mov	al,80h		;set Write Protect
	call	wr_protect

	popm	cx
	jmp	ds_full_exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;








;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; INT 1A
; function 20   Get NVRAM byte
;
; Enter with:
;       AH      0x20
;       AL      byte number ( 0 <= AL <= 30) 
;   (single byte read)
;
;       AH      0x20
;       AL      31
;       ES:BX   pointer to 31 byte buffer
;   (burst read)
;
; Exit with:
;       AL      byte read (single byte read)
;       Carry clear
;
;       AL      byte NVRAM[30] (burst read)
;       ES:BX buffer filled with bytes 0..30
;
;       Carry clear
;
; Error:
;       Carry set
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	ds_read
ds_read:
        pushm   ax,dx

	cmp	al,31
	jae	ds_burstr	; burst or error
	
	mov	ah,1100_0001B	; NVRAM read
 	call	byte_read

ds_read_exit:
	mov	al,ah		;return in AL
	pop	dx		;get old ax
	mov	ah,dh		;restore AH
	jmp	ds_good_exit

ds_full_exit:
	popm	ax
ds_good_exit:
	clc 			;signal good return
	popm	dx
	ret	

ds_error:
	popm	ax,dx
	stc
	ret




;
; handle burst read
ds_burstr:
        jne	ds_error	;must be 31 exactly, else error

	pushm	bx,cx		;extra save

	call	ds_reset_on	;reset before command byte
	call	ds_reset_off	;set for read


	mov	ah,1111_1111B	;burst read command
	call	ds_outb		;output the command

	mov	cx,31		;
ds_read2:
	call	ds_inb		;retrieve a byte in AH
  es	mov	byte [bx],ah	;save in the array
  	inc	bx
	loop	ds_read2	;and loop back

	call	ds_reset_on	;terminate read

	popm	bx,cx		;and restore
        jmp	ds_read_exit	;return AH
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; byte read into AH
;	AH = command bits
;	AL = register number
; byte read direct
;	AH = command bits + (reg<<1)
;
; Exit with:
;	AH is the byte read in
;
;  Uses AX, DX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
byte_read:
; single byte read
	shl	al,1		; shift by one
        or      al,ah		; Clock or NVRAM read
	mov	ah,al		; command byte to AH
byte_read_direct:
	call	ds_reset_on	;start of command, set AL & DX
	call	ds_reset_off	;remove the Reset

; output the command
        call    ds_outb

	call	ds_inb		;input byte to AH

	call	ds_reset_on	;terminate command

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; byte write
;	AH = command bits
;	AL = register number
;	CL = byte value to write
;
; byte_write_direct
;	AH = command, register<<1 included
;	CL = byte value to write
;
;  Uses AX, DX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
byte_write:
; single byte write
	shl	al,1		; prepare command
        or      al,ah		; clock or NVRAM write
	mov	ah,al		; command byte to AH
byte_write_direct:
	call	ds_reset_on	;start of command, set AL & DX
	call	ds_reset_off	;prepare for read

; output the command, will turn Reset off
        call    ds_outb

        mov     ah,cl		;single byte to write
        call    ds_outb

	call	ds_reset_on	;terminate the write
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; INT 1A
; function 21   Set NVRAM byte
;
; Enter with:
;       AH      0x21
;       AL      byte number ( 0 <= AL <= 30) 
;   (single byte write)
;       CL      byte value to write
;
;       AH      0x21
;       AL      31
;       ES:BX   pointer to 31 byte buffer
;   (burst write)
;
; Exit with:
;       Carry clear
;
; Error:
;       Carry set
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	ds_write
ds_write:
        pushm   ax,dx

	cmp	al,31
	jae	ds_burstw	; burst or error

; single byte write
%if 1
	mov	ah,1100_0000B   ; RAM/WRITE
	call	byte_write
%else
	shl	al,1		; prepare command
        or      al,1100_0000B   ; RAM/WRITE
	mov	ah,al		; command byte to AH

	call	ds_reset_on	;start of command, set AL & DX
	call	ds_reset_off	;prepare for read

; output the command, will turn Reset off
        call    ds_outb

        mov     ah,cl		;single byte to write
        call    ds_outb

	call	ds_reset_on	;terminate the write
%endif
	jmp	ds_full_exit
	
	
; burst write
ds_burstw:
        jne	ds_error	;must be 31 exactly, else error

	pushm	bx,cx		;extra save

	call	ds_reset_on	;reset before command byte
	call	ds_reset_off	;prepare for burst write

	mov	ah,1111_1110B	;burst write command
	call	ds_outb		;output the command

	mov	cx,31		;
ds_write2:
   es	mov	ah,byte [bx]	;get byte to write
   	call	ds_outb
	inc	bx		;increment
	loop	ds_write2

	call	ds_reset_on	;terminate the write

	popm	bx,cx
	jmp	ds_full_exit	;restore & return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; INT 1A
; function 22   Enable/Disable write protect
;
; Enter with:
;       AH      0x22
;       AL      0x80 to set write protect
;		0x00 to disable write protect
;
; Exit with:
;       Carry clear
;
; Error:
;       Carry set
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wr_protect:
	pushm	ax,dx
	test	al,0111_1111B	; only 00,80h allowed
	jnz	ds_error

	pushm	cx
	mov	cl,al		; option to write
	mov	ax, 1000_0000B << 8 | 7	; clock write, reg 7
	call	byte_write
	popm	cx

	jmp	ds_full_exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; INT 1A
; function 23   Set charging parameters
;
; Enter with:
;       AH      0x23
;       AL      charge parameter byte
;
; Exit with:
;       Carry clear
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ds_set_charge:
	pushm	ax,dx
	pushm	cx

	mov	ah,1000_0000B	; clock write
	mov	cl,al		; byte to write
	mov	al,8
	call	byte_write
	popm	cx

	jmp	ds_full_exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; INT 1A
; function 24   Get charging parameters
;
; Enter with:
;       AH      0x24
;
; Exit with:
;       AL      charge parameter byte
;       Carry clear
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	ds_get_charge
ds_get_charge:
	pushm	ax,dx

	mov	ax,1000_0001B << 8  | 8	; clock read
	call	byte_read
	mov	dl,ah		; save in DL
	popm	ax
	mov	al,dl		; return in AL

	jmp	ds_good_exit


;**********
; N.B. These will move to P1 from P3 on the final board
; Jan 2018 -- updated to P1 for rev 2.0 board
;**********
DSLTC   equ     P1LTC           ; DS1302 latch
DSPIN   equ     P1PIN           ;   pin value

DSDAT   equ     BIT0            ; Data must be bit 0 & idles high
DSCLK   equ     BIT2            ; Clock idles high
DSRST   equ     BIT3            ; Reset idles low (asserted)

DSMSK   equ     DSRST+DSCLK+DSDAT


%macro  us_delay 0
	jmp	$+2
	jmp	$+2
	jmp	$+2
%endmacro


	align	2
ds_out_latch:
	out	dx,al
	us_delay
	ret

;
; initializes the DSLTC in DX
; sets the Clock low, then asserts Reset
;
	global	ds_reset_on
ds_reset_on:
	mov	dx,DSLTC	;set I/O latch address in DX
	in	al,dx		;get the latch value
	and	al,~DSCLK	;set the clock low (should be idle state)
	call	ds_out_latch
	or	al,DSDAT	;set data for input
	and	al,~DSRST	;assert RESET#
	call	ds_out_latch
	ret

;
; sets the Clock low, then removes the Reset
;
	global	ds_reset_off
ds_reset_off:		; assume DX is set
	and	al,~DSCLK	;set the clock low (idle)
	or	al,DSDAT	;set data for input
	call	ds_out_latch
	or	al,DSRST	;deassert RESET#
	call	ds_out_latch
	ret			;clock idles low

;
; moves output bit into position, and then drops the clock low
; pauses, then sets the clock high to clock in the data bit
; loops back for all 8 bits
; exits with the clock HIGH
;
ds_outb:	;output the byte in AH
	pushm	cx
	mov	cx,8		;8 bits go out

.1:	and	al,~DSCLK	;drop the clock
	shr	ax,1		;LSB to AL
	rol	al,1		;data bit to position
	call	ds_out_latch
	or	al,DSCLK	
	call	ds_out_latch
	loop	.1

	popm	cx
   	ret			;clock is high on exit

;
; sets clock High and data bit for input
; pauses, drops the clock, pauses, reads the data bit
; shifts 8 bits into AH from the left, hence LSB ends up in AX bit 8
; exits with the clock low
;
ds_inb:		;input a byte to AH
	pushm	cx
	mov	cx,8

.2:	or	al,DSCLK+DSDAT	;raise the clock, O.C. data set for input
	call	ds_out_latch
	and	al,~DSCLK	;drop the clock
	call	ds_out_latch
	push	dx
   	mov	dx,DSPIN	;set to read data bit
	in	al,dx		;data bit to LSB
	pop	dx
	ror	ax,1		;data to AH MSB
	shl	al,1		;restore latch value just read in
	loop	.2

	popm	cx
	ret		; exit with clock Low

; convert packed BCD to binary int
;
;	arg in AL
;
;  int bcd2int(byte bcd);
;
	global	bcd2int_
bcd2int_:
	mov	ah,al
	shr	ah,4		; AH is unpacked high decimal digit
	and	al,0x0F		; AL is unpacked low decimal digit
	aad			; convert to integer in AX
	ret

	global	day_of_week_
day_of_week_:	;parameters in BCD
;	CH = century
;	CL = year
;	DH = month
;	DL = day
;
	mov	al,ch		;century to AL
	call	bcd2int_
	mov	bx,ax

	mov	al,cl		;year to AL
	call	bcd2int_
	mov	cx,ax

	mov	al,dh		;month to AL
	call	bcd2int_
	xchg	ax,dx		;month to DX, day to AL
	call	bcd2int_
	xchg	ax,dx		;day to DX, month to AX

; fall into 'dow_'
	global	dow_
dow_:
;	AX = month
;	DX = day
;	BX = century
;	CX = year
; normalize for calendar starting in March
	sub	ax,3		;
	jns	.4
	add	ax,12		; month went negative
	dec	cx
	jns	.4
	add	cx,100		;
	dec	bx		; year went negative
.4:
; now calculate
	add	dx,cx		; D+Y
	shr	cx,2		; Y/4
	add	dx,cx		; + Y/4
	add	dx,bx		; + C
	shl	bx,2		; C*4
	add	dx,bx		; D+Y+Y/4+5*C
	shr	bx,4		; C/4
	add	dx,bx		; + C/4
	mov	cx,5		; CX = 5
	div	cl		; M/5 to AL, Mrem to AH
	mov	bl,ah		; BX = Mrem
   cs	mov	bl,[dow_tab+bx]
   	add	dx,bx
	inc	cx		; CL = 6
	mul	cl		; AX = (M/5)*6
	add	ax,dx		; AX = sum
	xor	dx,dx
	inc	cx		; CX = 7
	inc	ax		; bias by 2
	inc	ax		; **
	div	cx		; SUM div 7
	mov	ax,dx		; result to AX
	ret

dow_tab:
	db	0,31,61,92,122;153


%if DEBUG
segment CONST
	dw	ttime		; 54925 == 0_D68Dh
	dw	54925 ; ms.
	dd	tick		; 1573050
	dd	1573050 ; ticks/day
%endif


