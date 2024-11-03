%ifndef SOFT_DEBUG
;;%define SOFT_DEBUG 1
%endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RBIOS.ASM -- Relocatable BIOS for the RetroBrew SBC-188 v.0.4 to 3.1
; Updated for the Duodyne 80c188 SBC 10/2024
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   This version is for assembly by  NASM 0.98.39 or later
;
; Copyright (C) 2011-2017 John R. Coffman.  All rights reserved.
; Provided for hobbyist use on the RetroBrew SBC-188 board.
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

	cpu	186




%include	"config.asm"
%include	"cpuregs.asm"
%include	"date.asm"
%include	"equates.asm"

%define	VERSION	VERSION_STRING
%define	DATE	DATE_STRING1

;;      global  begin_here
	global	cold_boot
        global  initialization
	extern	ident2
        extern  _cprintf
%if TRACE
	extern	int_trace
%endif	; TRACE


	segment         _TEXT

cold_boot:
        cli                     ; Should be clear already
	mov	bx,ax		; save board revision in BX
%if SOFT_DEBUG
        mov     dx,FRONT_PANEL_LED
        mov     al,0A5h         ; A5 to the LITES
        out     dx,al
%endif
        mov     ax,bios_data_seg
        mov     ss,ax
        mov     sp,7000h        ; Stack should be out of the way
; cannot use the stack yet, since memory is not tested
%if 0
    ss	mov	bx,word [warm_boot]	; check for 1234h == Warm Boot
%else
	xor	bh,bh			; not warm boot
    ss  cmp	word [warm_boot],1234h
	jne	.1
	inc	bh			; it IS a warm boot
	jmp	cold_continue		; JRC - DEBUG test
.1:
%endif
%if SOFT_DEBUG
	push	5Ah
	call	lites
%endif
memory_testing:
; Immediately test low memory
        xor     ax,ax           ; Segment 0
        mov     bp,.0           ; return address
        jmp     memtest0        ; don't use the stack
.0:
; BX was preserved by 'memtest0'

%if SOFT_DEBUG
        jnc     cold_continue
        mov     dx,FRONT_PANEL_LED
        mov     al,0F1h         ; F1 to the LITES
        out     dx,al
.1:
        hlt
        jmp     .1              ; solid halt on error
%endif

cold_continue:
        cld                     ; Clear the direction flag
        xor     ax,ax
        mov     es,ax
        cnop
        mov     di,ax
        mov     cx,600h/2       ; clear segments 00h, 040h and 050h
   rep  stosw                   ; clear out BIOS DATA AREA

%if 0
   ss	mov	word [warm_boot],bx	; save only warm boot flag
%else
   ss	mov	byte [sbc188_rev],bl	; save board revision
   ss	mov	word [warm_boot],bx	; save warm boot garbage
   	or	bh,bh			; test for warm boot
	jz	.3
   ss	mov	word [warm_boot],1234h	; restore warm boot code
.3:
%endif
        call    get_ramsize
        shl     ax,6            ; convert to Segment address
%if SOFT_DEBUG
	mov	cx,_BSS		; paragraph of _BSS segment
; since the BSS is of length 0000, this is beyond all data

        mov     bx,cs           ; Code Segment
        sub     cx,bx           ; Code paragraphs
        push    cx
        mov     bx,ax           ; Save HMA in K
        sub     bx,cx           ; new Code segment
        mov     es,bx           ; Destination
        cnop
        mov     ax,bx           ; Paragraph address to AX

        push    cs
        popm     ds              ; Source
        xor     si,si
        xor     di,di
        pop     cx              ; Code length in Paragraphs
        shl     cx,3            ; Code length in words
   rep  movsw                   ; move all of it
        push    es              ; new Code segment
        push    word SOFT_continue   ; IP
        retf

        global  SOFT_continue
SOFT_continue:                  ; Continue here in soft memory
;
;  Allocate the DEBUG static area
;
	mov	cx,(NBREAK+1)*8 + 15
	shr	cx,4		; CX=needed paragraphs
	sub	ax,cx		; allocate space
  ss	mov	[debug_static_ptr+2],ax	 	; setup static area segment
  ss	mov	word [debug_static_ptr],0	; and offset
  	shl	cx,4		; word count
	pushm	ax,ax		; save segment, twice
	popm	es		; set segment to zap
	xor	di,di		; start at offset 0
	mov	ax,di		; AL=0
  rep	stosb	    		; Zap memory
	popm	ax		; restore AX, EBDA paragraph segment
%endif
;
; Save the memory pointers
;
    ss  mov     [EBDA_paragraph],ax
        shr     ax,6
    ss  mov     [memory_size],ax

        push    DGROUP
        popm    ds              ; This is for the C-programs

        call    set_traps	; setup interrupt table
	call	set_interrupt_priority ; set default interrupt priorities

	mov	ax,UART_RATE	; set the default rate
	extern	@nvram_get_video
	call	@nvram_get_video
				; get RAM_serial byte - UART speed
				; returned in AL
%if SOFT_DEBUG
	PUSH	3
	CALL	lites
%endif
	extern	video_init
	call	video_init

%if SOFT_DEBUG
	PUSH	4
	CALL	lites
%endif
	extern	keyboard_init
	call	keyboard_init

%if SOFT_DEBUG
	PUSH	5
	CALL	lites
%endif
	sti                     ; enable interrupts
%if FPEM
	finit			; will allocate memory
%endif
%if SOFT_DEBUG
	PUSH	1
	CALL	lites
%endif

	push	VERSION_SEQUENCE
	push	cs
	push	ident1
	call	_cprintf
	pop     ax
	push	ident2
	call	_cprintf
	pop     ax
	push	ident3
	call	_cprintf
	pop     ax
	pop     ax
	pop	ax

%if SOFT_DEBUG
%if SOFT_DEBUG>1
	PUSH	2
	CALL	lites
%endif
        extern     redbug

        pushf           ; push the flags
        push    cs      ; simulate a far call
        call    redbug  ; call our weak debugger
   es   mov     cx,[bp+si+4]
%if SOFT_DEBUG>1
	PUSH	3
	CALL	lites
%endif

%endif

HAS_FLOPPY	equ	0000000000000001b
HAS_FPU		equ	0000000000000010b
HAS_MOUSE	equ	0000000000000100b
VIDEO_EGA	equ	0000000000000000b
VIDEO_COLOR_40	equ	0000000000010000b
VIDEO_COLOR_80	equ	0000000000100000b
VIDEO_MONO	equ	0000000000110000b
FLOPPIES_1	equ	0000000000000000b
FLOPPIES_2	equ	0000000001000000b
FLOPPIES_3	equ	0000000010000000b
FLOPPIES_4	equ	0000000011000000b
SERIAL_0	equ	0000000000000000b
SERIAL_1	equ	0000001000000000b
SERIAL_2	equ	0000010000000000b
SERIAL_3	equ	0000011000000000b
SERIAL_4	equ	0000100000000000b
SERIAL_5	equ	0000101000000000b
SERIAL_6	equ	0000110000000000b
SERIAL_7	equ	0000111000000000b
PARALLEL_0	equ	0000000000000000b
PARALLEL_1	equ	0100000000000000b
PARALLEL_2	equ	1000000000000000b
PARALLEL_3	equ	1100000000000000b


; setup BIOS data area
	push	bios_data_seg
	popm	ds
	mov	byte [lock_count],0	; zap the @enable/@disable lock count
; no serial interface -- it is used for the video driver
	mov	ax,PARALLEL_0|SERIAL_0|FLOPPIES_1|VIDEO_MONO|HAS_FLOPPY
%if FPEM
        or      ax,HAS_FPU              ; a bit of a lie
%endif
	mov	word [equipment_flag],ax

	extern	_cpu_speed
	call	_cpu_speed
	add	ax,600
	mov	cx,1250
	xor	dx,dx
	div	cx
	mov	byte [cpu_xtal],al	; CPU oscillator frequency

	push	word [memory_size]

	push	DGROUP
	popm	ds			; This is for the C-programs

	push	ax
	extern	@timer_init
	call	@timer_init
	pop	ax

	push	ds
	test	ax,1
	jnz	.cpu_clock_05
	push	msg_cpu_clock_00
	jmp	.print_cpu_clock
.cpu_clock_05:
	push	msg_cpu_clock_05
.print_cpu_clock:
	shr	ax,1
	push	ax
	push	ds
	push	msg_cpu_memory
	call	_cprintf
	add	sp,12-2
%if 1
        pop     ax                      ; memory size in K
        call    POST_memory             ; Power On Self Test

   ss	mov	word [warm_boot],1234h	; set warm boot code

%endif
	call	nvram_init

	push	ds		; DS = DGROUP (CONST)
	push	msg_floppy
	call	_cprintf
	add	sp,4

	extern	@floppy_init
	call	@floppy_init

	jmp	boot_the_OS


;========================================================================
; nvram_init - check NVRAM checksum, prompt for NVRAM setup, apply NVRAM configuration
;========================================================================
nvram_init:
	extern	@nvram_check
	call	@nvram_check
	or	ax,ax
	jz	.ask_setup

	push	ds
	push	msg_nvram_bad
	call	_cprintf
	add	sp,4
	jmp	.run_setup

.ask_setup:
	push	ds
	push	msg_setup
	call	_cprintf
	add	sp,4

	mov	ah,0
	int	1Ah
	mov	bx,dx
	add	bx,18*2		; wait 2 seconds
.wait_setup:
	mov	ah,1
	int	16h
	jz	.wait_setup_1
	mov	ah,0
	int	16h
	or	al,'s'^'S'
	cmp	al,'s'
	je	.run_setup

.wait_setup_1:
	mov	ah,0
	int	1Ah
	cmp	dx,bx
	jb	.wait_setup
	jmp	.skip_setup

.run_setup:
	extern	@nvram_setup
	call	@nvram_setup

.skip_setup:
	extern	@nvram_apply
	call	@nvram_apply

        call    ticktime                ; set the tick clock

	ret

;========================================================================
; BIOS_call_18h - Start ROM Basic
; Note:
;	In this BIOS it prints a "no Basic" message and tries to boot the OS
;	or it will run tests if tests are enabled
;========================================================================
BIOS_call_18h:
	sti
%ifdef TESTS
	extern	tests
	call	tests
%else	; TESTS

%if TBASIC
;;;        extern  cbasic
;;;        extern  end_cbasic
;;;	jmp	seg cbasic:cbasic
	jmp	0F000h:0000h
%else
	mov	ax,bios_data_seg
	mov	ss,ax			; Reset SS
	mov	sp,7000h		; and SP
	push	DGROUP			; just in case DS is not pointing
	popm	ds			; were it should

	push	ds
	push	msg_no_basic
	call	_cprintf
	add	sp,4
	mov	ah,0			; get any keystroke; jrc 2012/12/02
	int	16h
	int	19h			; reboot the OS
%endif  ; TBASIC

%endif	; TESTS
.1:
	hlt				; we should never get here
	jmp	.1

;========================================================================
; BIOS_call_19h  - re-Boot the OS
;========================================================================
BIOS_call_19h:
	push	bios_data_seg
	popm	ds
	mov	word [warm_boot],1234h	; set warm boot flag
	cli				; disable interrupts
	jmp	0FFFFh:0000h		; go to STARTUP.BIN code




;========================================================================
;========================================================================
boot_the_OS:
	mov	ax,bios_data_seg
	mov	ss,ax			; Reset SS
	mov	sp,7000h		; and SP
	push	DGROUP			; just in case DS is not pointing
	popm	ds			; were it should
	sti

	push	'A'
	push	ds
	push	msg_booting
	call	_cprintf
	add	sp,6

	mov	dl,0
	call	boot_drive

	push	'C'
	push	ds
	push	msg_booting
	call	_cprintf
	add	sp,6
%if SOFT_DEBUG>1
	int 0
%endif
	mov	dl,80h
	call	boot_drive

	int	18h			; failed to boot, start ROM Basic

.1:
	hlt				; we should never get here
	jmp	.1

;========================================================================
; boot_drive - try to boot from the drive
; Input:
;	DL = drive number (00h = first floppy, 80h = first HDD)
;========================================================================
boot_drive:
	mov	si,3			; make 3 tries before giving up

%if SOFT_DEBUG>1
	nop
	int 0
%endif
.1:					; loop comes back here
	mov	ah,0			; reset the Disk Controller
	int	13h

	push	dx
	mov	ah,8			; get drive parameters
	int	13h
	mov	al,dl			; number of drives
	pop	dx
	jc	.fn8_error


%if SOFT_DEBUG > 2
	nop
	int	0

        mov     ax,0401h                ; verify sector
	mov	cx,1			; track 0, sector 1
	mov	dh,0			; head 0
        int     13h

        nop
        int     0
%endif

	mov	ax,0201h		; read one sector
	mov	cx,1			; track 0, sector 1
	mov	dh,0			; head 0
	xor	bx,bx
	mov	es,bx			; ES = 0
	mov	bx,7C00h		; ES:BX = 0000:7C00
	int	13h
	jnc	.read_ok

.fn8_error:
	dec	si			; go back and reset the controller
	jnz	.1			; make several tries

	push	ax
	push	ds
	push	msg_boot_err
	call	_cprintf
	add	sp,4+2
	ret

.read_ok:
	push	dx

        mov     ax,8004h                ; NVRAM bits
        call    rtc_get_loc
        test    al,2            ; RAM_bits_AA55 flag
        jnz     .cpm_bootsec
    es	cmp	word [7C00h+1FEh],0AA55h
	je	.good_signature
    es	cmp	word [7C00h+1BCh],0AA55h
    	je	.minix_bootsec
	push	ds
	push	msg_no_boot
	call	_cprintf
	add	sp,4		; remove DX also
	pop	dx		; **
	ret
.good_signature:
    es	cmp	word [7C00h+000h],0
	jne	.good_bootsec
	push	ds
	push	msg_no_loader
	call	_cprintf
	add	sp,4		; remove DX also
	pop	dx		; **
	ret

.minix_bootsec:
	push	ds		; alternate boot signature
	push	msg_alt_disk
	jmp	short .cpmbs2
.cpm_bootsec:
        push    ds
        push    msg_cpm_disk
.cpmbs2:  call    _cprintf
	add	sp,4
.good_bootsec:
	push	ds
	push	msg_boot_ok
	call	_cprintf
	add	sp,4

	pop	dx

%if SOFT_DEBUG>1
	global	major_debug
major_debug:
	cmp	dl,0
	jne	.999

	xor	bx,bx
	push	bx
	popm	es			; ES = 0
	mov	bx,7C00h		; ES:BX = 0000:7C00
	int	0

	mov	ax,0201h
	inc	cl
	int	13h

	mov	ax,0201h
	mov	cl,10h
	int	13h

	mov	ax,0201h
	mov	dh,1
	int	13h

	mov	ax,0201h
	mov	ch,1		; cylinder 1
	int	13h

	mov	ax,0201h
	mov	ch,23h
	int	13h

	mov	ax,0201h
	mov	cx,1
	mov	dh,0
	int	13h

.999:
%endif
%if SOFT_DEBUG
	push	7
	call	lites
	int 0
%endif
	jmp	0000:7C00h		; execute the boot sector



%if 0		; now part of 2P1S from R. Cini (RAC)
;========================================================================
; BIOS_call_14h  - Serial port communication services
;========================================================================
BIOS_call_14h:
%if TRACE
	call	int_trace
%endif	; TRACE
	xor	ax,ax
	iret

;========================================================================
; BIOS_call_17h  - Print services
;========================================================================
BIOS_call_17h:
%if TRACE
	call	int_trace
%endif	; TRACE
	mov	ah,0
	iret

%endif
;========================================================================

interrupt_table:

%if SOFT_DEBUG
	db	0			; Int 0 - divide by zero
	extern	zero_divide
	dw	zero_divide

	db	1			; Int 1 - single step
	extern	single_step
	dw	single_step

	db	2			; Int 2 - NMI interrupt
	extern	nmi_interrupt
	dw	nmi_interrupt

	db	3			; Int 3 - breakpoint
	extern	breakpoint
	dw	breakpoint

	db	4			; Int 4 - interrupt on overflow (INTO instruction)
	extern	INTO_trap
	dw	INTO_trap

	db	5			; Int 5 - bound check error
	extern	bound_trap
	dw	bound_trap

	db	6			; Int 6 - invalid opcode
	extern	undefined_op
	dw	undefined_op
%endif	; SOFT_DEBUG

%if FPEM
%if 0
	db	7			; ESC opcode / Floating Point
	extern	vector7
	dw	vector7
%endif
%else
%if SOFT_DEBUG
	db	7			; Int 7 - math coprocessor not present
	dw	undefined_op
%endif	; SOFT_DEBUG
%endif

	db	8			; Timer 0 interrupt
	extern	timer0_interrupt
	dw	timer0_interrupt

	db	0Ah			; DMA 0 interrupt
	extern	dma0_interrupt
	dw	dma0_interrupt

	db	0Bh			; DMA 1 interrupt
	dw	end_of_interrupt

	db	0Ch			; INT0 - UART
; eventually this will be PIC code here
%if UART
	extern	uart_int
	dw	uart_int
%else
	dw	end_of_interrupt
%endif

	db	0Dh			; INT1- external bus INT
	%if CVDU_8242 & (1-CVDU_USE_KBD_HOOK)
	extern	cvdu_kbd_int
	dw	cvdu_kbd_int
%else
	dw	end_of_interrupt
%endif
	db	0Fh
	extern	fdc_interrupt_level
	dw	fdc_interrupt_level	; INT3 - FDC

	db	10h			; BIOS - Video display services
	extern	BIOS_call_10h
	dw	BIOS_call_10h

	db	11h			; BIOS - Return equipment list
	dw	BIOS_call_11h		; in memory.asm

	db	12h			; BIOS - Return conventional memory size
	dw	BIOS_call_12h		; (shared with Timer 1)
;;;	dw	timer1_interrupt	; non INT 12h passed to timer1

	db	13h			; BIOS - Disk services
%if PPIDE_driver
	extern	FIXED_BIOS_call_13h
	dw	FIXED_BIOS_call_13h     ; (shared with Timer 2, prescaler, NOT USED)

        db      40h                     ; Floppy Driver
%endif
	extern	BIOS_call_13h
        dw      BIOS_call_13h

	db	14h			; BIOS - Serial port communication
	extern	BIOS_call_14h
	dw	BIOS_call_14h

	db	15h			; BIOS - Miscellaneous system services support routines
	extern	BIOS_call_15h
	dw	BIOS_call_15h

	db	16h			; BIOS - Keyboard services
	extern	BIOS_call_16h
	dw	BIOS_call_16h

	db	17h
	extern	BIOS_call_17h
	dw	BIOS_call_17h		; BIOS - Print services

%if TBASIC==0
	db	18h			; BIOS - Start ROM Basic
	dw	BIOS_call_18h
%endif

	db	19h			; BIOS - Boot the OS
	dw	BIOS_call_19h

	db	1Ah			; BIOS - RTC (real time clock) services
	extern	BIOS_call_1Ah
	dw	BIOS_call_1Ah

	db	1Ch
	extern	BIOS_call_1Ch
	dw	BIOS_call_1Ch

	db	70h			; RTC timer tick on IRQ8
	extern	rtc_interrupt
	dw	rtc_interrupt		; 1024 Hz timer

num_vectors	equ     (($-interrupt_table)/3)

;========================================================================
; end_of_interrupt - signal end of interrupt to the interrupt controller
;========================================================================
end_of_interrupt:
        pushm   ax,dx
        mov     dx,PIC_EOI              ; EOI register
        mov     ax,EOI_NSPEC            ; non-specific end of interrupt
        out     dx,ax                   ; signal it
        popm    ax,dx
	iret

skip_trap:
%if TRACE
	call	int_trace
%endif	; TRACE
        iret            ; return from interrupt is a null trap


;========================================================================
;  Interrupt priority re-assignments
;========================================================================
MASK		equ	08h	; mask interrupt
LTM		equ	10h	; Level Trigger Mode
interrupt_priority:
	db	6 | MASK	; Timers -- timer_init clears the mask
	db	2		; DMA0
	db	2 | MASK	; DMA1
	db	4 | MASK	; INT0 -- external /INT (keyboard)
	db	4		; INT1 -- UART
	db	7 | MASK	; INT2
	db	3 | LTM+MASK	; INT3 -- floppy disk
lth_int_priority   equ	$-interrupt_priority

set_interrupt_priority:
%if 0
/* for now */
	mov	dx,PIC_TCR
	mov	si,interrupt_priority
	xor	ax,ax		; zap AH
	mov	cx,lth_int_priority
sip_loop:
   cs	lodsb			; get priority level
   	out	dx,ax
	add	dx,2		; PIC control regs are even
	loop	sip_loop
%endif
	ret

;========================================================================
; set_traps - setup interrupt table
;========================================================================
set_traps:
        push    ds

	mov	dx,cs
	mov	cx,0100h	; number of interrupt vectors
	mov	bl,0		; start with int 0
	mov	ax,skip_trap
.set_default_loop:
	call	set_vector
	inc	bl
	loop	.set_default_loop

        mov     ds,dx           ; for LODS  CS==DX==DS
        cnop
        mov     si,interrupt_table	; load address to start
	mov	cx,num_vectors
				; note DX = CS
.set_vectors_loop:
	lodsb
	mov	bl,al
	lodsw
	call	set_vector
	loop	.set_vectors_loop

%if TBASIC
	mov	bl,18h		; int 18h is Tiny Basic
	xor	ax,ax
	mov	dx,0F000h	; absolute segment load @ 00K
	call	set_vector
%endif
%if FPEM
	mov	bl,07h		; vector 7 is FPU emulator
	xor	ax,ax
	mov	dx,0F480h	; absolute segment load @ 18K
	call	set_vector
%endif

        popm     ds
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  get_vector
;       Get an interrupt vector
;
;       Enter with vector number in BL
;       Exit with vector in DX:AX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        global  get_vector
get_vector:
        pushm   bx,ds		; register saves

        xor     ax,ax           ; zero BX
        mov     ds,ax           ; set DS=0
        cnop
	mov	bh,0
        shl     bx,2            ; index * 4

        mov     ax,[bx]         ; load the vector
        mov     dx,[bx+2]       ;

        popm    bx,ds		; register restores
        ret                     ; result in DX:AX


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  set_vector
;       Set an interrupt vector
;
;       Enter with vector number in BL
;               vector in DX:AX
;
;       All registers preserved
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        global  set_vector
set_vector:
        pushm   cx,bx,ds	; register saves

	xor	cx,cx
        mov     ds,cx           ; set DS=0
        cnop
	mov	bh,0
        shl     bx,2            ; index * 4

        mov     [bx],ax         ; set offset
        mov     [bx+2],dx       ; set segment

        popm    cx,bx,ds	; register restores
        ret                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  cpu_table_init
;
;       call    cpu_table_init
;       dw      <table>         ; table in the Code segment
;       <return here>
;               AX, CX, DX are trashed
;
;
; table:
;       db_lo   <cpu_register>
;       dw      <contents>
;       ...
;       db      0       ; ends table
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        global  cpu_table_init
cpu_table_init:
; get the table address
        mov     cx,si           ; save SI
        pop     si              ; get the return address
    cs  lodsw                   ; get the table address
        push    si              ; save incremented return address
        push    cx              ; save former SI

        mov     si,ax           ; CS:SI is table pointer
        mov     dh,cpu_relocation>>8
.1:
    cs  lodsb                   ; get low device code
        test    al,al
        jz      .9              ; done with table on zero low device code
        mov     dl,al
    cs  lodsw                   ; get cpu register data
        out     dx,ax           ; output a full word
        jmp     .1
.9:
        pop     si              ; restore SI
        ret                     ;


%if 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  C-callable:
;       dword __fastcall divLS(dword dividend, word divisor);
;
;       double word  divided by  word
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        global  @divLS
@divLS:
        ; DX:AX is dividend
        ; BX is divisor
        or      dx,dx
        jnz     .3
        div     bx
        xor     dx,dx
        ret

.3:     mov     cx,ax           ; save low dividend in CX
        mov     ax,dx
        xor     dx,dx           ; 0:DX div BX
        div     bx
        xchg    cx,ax           ; CX is high quotient
        div     bx
        mov     dx,cx
        ret

%ifndef HAS_FASTCALL
        global  _divLS
_divLS: push    bp
        mov     bp,sp
        mov     ax,ARG(1)
        mov     dx,ARG(2)
        mov     bx,ARG(3)
        call    @divLS
        leave
        ret

        global  _remLS
_remLS: push    bp
        mov     bp,sp
        mov     ax,ARG(1)
        mov     dx,ARG(2)
        mov     bx,ARG(3)
        call    @remLS
        leave
        ret
%endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  C-callable:
;       word __fastcall remLS(dword dividend, word divisor);
;
;       remainder of:
;       double word  divided by  word
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        global  @remLS
@remLS:
        ; DX:AX is dividend
        ; BX is divisor
        or      dx,dx
        jz      .5
        mov     cx,ax           ; save low dividend in CX
        mov     ax,dx
        xor     dx,dx           ; 0:DX div BX
        div     bx              ; discard quotient in AX
        mov     ax,cx           ; restore low dividend
.5:     div     bx
        mov     ax,dx           ; remainder to AX
        ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  C-callable:
;       dword __fastcall mulLS(dword factor1, word factor2);
;
;       double word  multiplied by  word
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	@mulLS
@mulLS:
	; DX:AX is factor1
	; BX is factor2
        or      dx,dx
        jnz     .1		; dx != 0
        mul     bx
        ret
.1:     mov     cx,ax           ; save low part of factor1 in CX
        mov     ax,dx
        mul     bx
        xchg    cx,ax           ; CX is a product of high part of factor1 and factor2
        mul	bx
        add     dx,cx
        ret
%endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  microsecond
;       Enter with CX = delay time in microseconds
;       Exit with CX = 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        global  @microsecond
        global  microsecond
@microsecond:		; C-callable with __fastcall
	mov	cx,ax
microsecond:
        jcxz    .9
.1:     nop		; 4 clocks
        loop    .1	; 15 clocks	loop is 19 clocks (approx.)
.9:     ret


%if 0
;========================================================================
; wout - nobody calls it, but unasm defines it as an extenal symbol
; XXX: Need to recompile unasm and kill it
;========================================================================
	global	wout
wout:
	ret
%endif


%macro  binary  1
        mov     ah,%1
        shr     ax,4
        shr     al,4
        aad
        mov     %1,al
%endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  ticktime -- set the tick count from the CMOS clock
;
;       Preserves all registers
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        global  ticktime
ticktime:
        pushm   ALL

        mov     ah,2            ; get Time
        int     1Ah

        binary  dh
        binary  cl
        binary  ch
;       mov     al,ch
        mov     ch,ah           ; CH = 0
        mov     dl,60           ; 60 min / hr,  60 sec / min
        mul     dl
        add     ax,cx           ; AX = hr*60 + min
        mov     cl,dh           ; CX = sec
        mov     dh,ch           ; DH = 0
        mul     dx              ;
        add     ax,cx
        adc     dx,0            ; DX:AX = time in seconds

        mov     bx,250
        mov     cx,dx           ; CX:AX is time in seconds
        mul     bx
        xchg    ax,cx           ; CX is low result
        mul     bl
        add     ax,dx           ; AX:CX is 250*maxseconds

        shl     bx,2            ; BX = 1000
        xchg    ax,cx           ; CX:AX is 250*maxseconds
        mul     bx              ; DX:AX is partial product
        xchg    ax,cx
        xchg    dx,bx           ; BX:CX is partial product
        mul     dx
        add     ax,bx
        adc     dx,0            ; DX:AX:CX is product

        mov     bx,54924/4      ; = 13731       (divisor)
        div     bx
        xchg    ax,cx           ; CX is high quotient
        div     bx              ; CX:AX is quotient, DX is remainder
; round the result
        sub     bx,dx           ; if DX > BX/2
        cmp     bx,dx           ;
        ja      .3
        add     ax,1
        adc     cx,0
.3:
        xchg    ax,dx           ; CX:DX is tick count to set
        mov     ah,1
        int     1Ah             ; set tick count

        popm    ALL
        ret




;========================================================================

%include        "memory.asm"
%include        "ds1302.asm"

%if SOFT_DEBUG+1
        global  lites
; call with:
;       push    code    ; code in AL
;       call    lites
;
lites:  push    bp
        mov     bp,sp           ; establish stack frame
        pushm   ax,dx
        mov     al,[bp+4]
        mov     dx,FRONT_PANEL_LED
        out     dx,al
        popm    ax,dx
        pop     bp
        ret     2               ; remove argument
%endif

%if 0
; _FPSIGNAL:
;   Enter with AL = condensed error code
;
	global	_FPSIGNAL
_FPSIGNAL:
	xor	ah,ah
	push	ax
	push	DGROUP
	push	msg_fpu_err
	call	_cprintf
	add	sp,6
	ret
%endif




ident3:
%if SOFT_DEBUG
        db      NL
	db	"%7a"
        db      "             ***** SOFT BIOS *****"
        db      NL
%endif
%ifdef __DATE__
%ifdef __TIME__
        db      NL
	db	"%14a"
        db      "This BIOS copy was built at ",__TIME__," ",TIMEZONE
        db      " on ", __DATE__
%endif
%endif
        db      ".                    [%d]",NL
        db      0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  This is the banner which prints out first.
;  The letters are variable width; B is wide; -, and 1 are kerned.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ident1:
        db      NL,"%9a"
        DB      "  _____                  _ ",	NL
        DB      " |  __ \                | |",	NL
        DB      " | |  | |_   _  ___   __| |_   _ _ __   ___ ",	NL
        DB      " | |  | | | | |/ _ \ / _` | | | | '_ \ / _ \ ",	NL
        DB      " | |__| | |_| | (_) | (_| | |_| | | | |  __/",	NL
        DB      " |_____/ \__,_|\___/ \__,_|\__, |_| |_|\___|",	NL
        DB      "    80c188 pcb              __/ |  rev. ", VERSION, NL
        DB      "                           |___/   of   ", DATE, NL
        db      "                                   ("
%if ANSI
        db      "ANSI"
%elif DUMB
        db      "dumb"
%elif TTY
        db      "tty"
%else
        db      "???"
%endif
        db      ")",NL

	db      0


	align	16

bulk_of_code_end        equ     $



        segment CONST

        global  _bios_data_area_ptr
_bios_data_area_ptr:
        dw      0000h,bios_data_seg     ; pointer 40:0


msg_cpu_memory:
	db	"%15a%d%s %2aMhz CPU clock, %15a%u%2aK memory installed"
	db	NL, 0
msg_cpu_clock_05:
	db	".5", 0
msg_cpu_clock_00:
	db	0
msg_setup:
	db	"Press 's' to run NVRAM setup...", NL, 0
msg_nvram_bad:
	db	"NVRAM checksum is invalid, running setup", NL, 0
msg_floppy:
	db	"Now initializing floppy", NL, 0
%if 0
msg_fpu_err:
	db	NL, "EM187 has signalled error 0x%02x.", NL, 0
%endif
msg_booting:
	db	"Trying to boot from drive %c: ", 0
msg_boot_err:
	db	"Disk read failed  AX=%04x", NL, 0
msg_no_boot:
	db	"Boot signature not found", NL, 0
msg_no_loader:
	db	"Master boot loader not found", NL, 0
msg_boot_ok:
	db	"OK", NL, 0
msg_cpm_disk:
        db      "no signature check ", 0
msg_alt_disk:
	db	"MINIX boot signature ",0



%if TBASIC
%else
msg_no_basic:
	db	"No ROM Basic. Please implement one :-)", NL
	db	"Press any key to try again...", NL, 0
%endif


%if SOFT_DEBUG
	global	cout,bout,wout,boutsp,crlf
; NewLine
crlf:
	mov	al,0Dh
	call	cout
	mov	al,0Ah
	call	cout
	ret


; output byte from AL, then a space
boutsp:
	call	bout
	mov	al,20h
	call	cout
	ret
; word output from AX
wout:
	xchg	al,ah
	call	bout
	xchg	al,ah
; byte output from AL
bout:
	rol	al,4
	call	nout
	rol	al,4
; nibble output from low nibble in AL
nout:
	push	ax
	and	al,0Fh		; mask nibble
	daa			; convert to decimal
	add	al,0F0h		; overflow to Carry
	adc	al,040h		; convert to ASCII decimal or hex digit
	call	cout
	pop	ax
	ret

; character output from AL
cout:
%if 0
	pushm	ax,bx
	mov	ah,0Eh		; write character in AL
	mov	bx,0007h
	int	10h
	popm	ax,bx
%else
THRE	EQU	1<<5		; Transmit holding register empty
	pushm	ax,dx
.1:	mov	dx,uart_lsr
	in	al,dx
	test	al,THRE
	jz	.1
	mov	dx,uart_thr
	popm	ax
	out	dx,al
	popm	dx
%endif
	ret
%endif
