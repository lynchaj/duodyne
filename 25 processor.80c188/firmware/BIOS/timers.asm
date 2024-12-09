;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; timers.asm
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

        extern  cpu_table_init

        global  BIOS_call_1Ch
        global  timer0_interrupt, timer1_interrupt, timer2_interrupt
        extern  fdc_timer_hook
        global  BIOS_call_1Ah   ; BIOS call
        global  @timer_init
        global  _cpu_speed
        extern  rtc_get_loc, rtc_set_loc

timer0          equ     TIM0
timer1          equ     TIM1

%if 1
;/* definitions below are from "ds1302.h" */

;/* definitions of the CMOS RAM locations */
%define RAM_trickle		0
%define RAM_century		1
%define RAM_floppy      2
%define RAM_floppy0     2
%define RAM_floppy1     3
%define RAM_bits        4
%define RAM_bits_DST    01h     ; DST flag

%define RAM_checksum		30
%define RAM_length		31

;#define rtc_WP(on) rtc_set_loc(7|CLOCK,(on?0x80:0))
%endif





        SEGMENT _TEXT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; _cpu_speed
;
;       Determine the CPU clock rate using the UART oscillator
;       as the time standard.
;
;       Return the CPU speed in AX
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_cpu_speed:
        call    cpu_table_init
         dw       speed_setup           ; start the two timers

        mov     dx,timer1+TCON
.1:
        in      ax,dx                   ; read status of timer1
        test    al,tc_MC                ; max count reached ?
        jz      .1

        mov     dx,TIM2+TCNT          ; read the count
        nop
        nop
        nop
        in      ax,dx
        ret

speed_setup:
        db_lo   timer1+TCON
        dw      tc_nINH                 ; disable

        db_lo   TIM2+TCON
        dw      tc_nINH                 ; disable

        db_lo   TIM2+CMPA             ; max. count
        dw      0FFFFh

        db_lo   timer1+CMPA             ; max. count
        dw      UART_OSC / 100          ; 10 ms interval

        db_lo   TIM2+TCNT             ; timer count = 0
        dw      0

        db_lo   timer1+TCNT             ; timer_count = 0
        dw      0

        db_lo   timer1+TCON             ; start timer 1
        dw      tc_EN+tc_nINH+tc_EXT    ; no Interrupts

        db_lo   TIM2+TCON             ; start timer 2
        dw      tc_EN+tc_nINH

        db      0               ; end of the table




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; @timer_init
;
;       Start the 18.2 Hz clock ticks by initializing
;       timers 0 & 2
;                               [1 & 2 on prototype boards]
;   Call with Xtal frequency in AX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@timer_init:
        push    si
        push    di

        push    ax              ; protect AX

        call    cpu_table_init
         dw      timer_table

        pop     ax
        mov     di,13731

        test    al,1            ; test for odd frequency
        jnz     .1
; even frequency
        shr     ax,1            ; halve the Xtal frequency
        jmp     .2
.1:     ; odd
        shr     di,1            ; halve the divisor
.2:
        mov     dx,TIM2+CMPA    ; set the timer 2 max count A
        out     dx,ax
        mov     dx,timer0+CMPA  ; set the timer 0 max count A
        mov     ax,di
        out     dx,ax

        mov     dx,PIC_TCR      ; timer control register
        in      ax,dx
        and     ax,~08h         ; clear the mask bit
        out     dx,ax

        pop     di
        pop     si
        ret

timer_table:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Set up Timer 2 to provide the 250 kHz clock to Timer 0
;
;  By dividing CPU_CLK/4, the internal input to the timer, by the
;  CPU clock rate, the 1/4 Mhz internal clock to the other
;  timers is achieved.

        db_lo   TIM2+TCNT       ; zero the count register
        dw      0

        db_lo   TIM2+TCON       ; wired: ALT=0, EXT=0, P=0, RTG=0
        dw      tc_EN+tc_nINH+tc_CONT   ; EN=1, /INH=1, INT=0, CONT=1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Set up Timer 0 to provide the 54.925 ms (18.2 Hz) PC timer tick
;

        db_lo   timer0+TCNT       ; Timer 0 count register
        dw      0

        db_lo   timer0+CMPB       ; count B register
        dw      0

;;        db_lo   timer0+CMPA       ; count A register
;;        dw      13731             ; divisor:  250000/13731 -> 18.206..

        db_lo   timer0+TCON       ; control register
        dw      tc_EN+tc_nINH+tc_INT+tc_P+tc_CONT
                                ; EN=1, /INH=1, INT=1,
                                ; RTG=0, P=1, EXT=0, ALT=0, CONT=1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Set up Timer 1 as disabled at 1024Hz
;

        db_lo   timer1+CMPA     ; max count A
        dw      UART_OSC/1024   ; 1024Hz RTC counter for waits

        db_lo   timer1+TCNT     ; count
        dw      0

        db_lo   timer1+TCON       ; control register
        dw      tc_nINH+tc_P+tc_CONT+tc_EXT+tc_INT
                                ; EN=0, /INH=1, INT=1,
                                ; RTG=0, P=1, EXT=1, ALT=0, CONT=1

        db      0               ; end of the table


timer2_interrupt:       ; int 19 = 13h
        iret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  timer0_interrupt
;
;       This is the 18.2 Hz timer tick
;
;
;ONE_DAY         equ     1573040         ; timer ticks in a day (IBM PC)
ONE_DAY         equ     1573080         ; timer ticks in a day (compromise)
;ONE_DAY        equ     1573082         ; timer ticks in a day (our clock)
;                                       ; ours is a little slow
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
one_day:        dd      ONE_DAY

timer1_interrupt:       ; int 18 = 12h 	Redirected from BIOS_call_12h
	int	70h	; IRQ8 -- 1024Hz RTC timer (rtc_interrupt)
	iret



timer0_interrupt:	; true timer 0 18.2Hz interrupt
; service the timer tick interrupt
        pushm   ax,dx,ds

        push    bios_data_seg
        popm    ds              ; address the BIOS data area

;%if (ONE_DAY < 0FFFFFFh) && ( ONE_DAY & 255 )
%if 1

        call    fdc_timer_hook

; the strategy below is that the most frequently travelled path
; is the fewest branches and the fewest number of instructions
        inc     byte [timer_ticks]
        jz      .2
        cmp     byte [timer_ticks], ONE_DAY & 0FFh
        je      .3
.9:
	int	1Ch			; User timer tick interrupt

	mov dx,FRONT_PANEL_LED
	in al, dx
	and al,80h
	jz .91
	extern	multiio_kbd_hook
	call	multiio_kbd_hook
.91:
; signal EOI (End of Interrupt)
        mov     dx,PIC_EOI              ; EOI register
        mov     ax,EOI_NSPEC            ; non-specific
        out     dx,ax                   ; signal it

        popm    ax,dx,ds
	iret

; the less frequent execution paths are below
.2:     ;  low byte == 0
        inc     word [timer_ticks+1]
        jmp     .9

.3:     ; AX = low word ONE_DAY
        cmp     word [timer_ticks+1], ONE_DAY >> 8
        jne     .9

; a day has passed
        mov     word [timer_ticks],0
        mov     word [timer_ticks+2],0  ; zero the high word
        mov     byte [timer_new_day],1   ; set flag
        jmp     .9



%else
        %error "Timer interrupt service."
%endif



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  BIOS_call_1Ah        software interrupt
;
;       Functions in AH:
;               00      get tick count
;               01      set tick count
;               02      get time (from CMOS clock)
;               03      set time (to CMOS clock)
;               04      get date (from CMOS clock)
;               05      set data (to CMOS clock)
;               06      set alarm (we don't implement this one)
;               07      reset alarm
; we don't implement the following:
;               0Ah     get day count [PS/2]
;               0Bh     set day count [PS/2]
;               80h     set sound source [PC only]
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
offset_BP       equ     0
offset_BX       equ     offset_BP+2
offset_AX       equ     offset_BX+2
offset_DS       equ     offset_AX+2
offset_IP       equ     offset_DS+2
offset_CS       equ     offset_IP+2
offset_FLAGS    equ     offset_CS+2

BIOS_call_1Ah:                  ; int 1Ah  call
        pushm   ds
        push    ax
        push    bx

        push    bp              ; set to address stack
        mov     bp,sp

        push    bios_data_seg
        popm    ds              ; establish addressability

        mov     bl,ah           ; set to index into dispatch table
        cmp     ah,max/2
        jae     undefined
        xor     bh,bh
        shl     bx,1            ; index words

    cs  jmp     near [dispatch+bx]




dispatch:
        dw      fn0
        dw      fn1
        dw      fn2
        dw      fn3
        dw      fn4
        dw      fn5
        dw      fn6
        dw      fn7
max     equ     $-dispatch

fn6:
fn7:
undefined:
        mov     byte [bp+offset_AX+1],0FFh      ; error code?
set_carry:
        or      byte [bp+offset_FLAGS],1        ; set the carry
        jmp     popall
good_exit:
        and     byte [bp+offset_FLAGS],~1       ; clear the carry
popall: pop     bp
        pop     bx              ; register restores
        pop     ax
        popm    ds
BIOS_call_1Ch:
        iret

; update CMOS
;       AL = ram address (0..29)
;       DL = new contents of address
;
; the RAM location is updated with the new contents
; and the checksum (location 30) is maintained at zero
;
updateCMOS:
        pushm   bx,dx

        mov     ah,80h
        push    ax
        call    rtc_get_loc
        xchg    ax,bx
        sub     bl,dl           ; difference between contents
        pop     ax
        jz      .5              ; jump if no change
        call    rtc_set_loc     ; set DL, the changed value
        mov     ax,8000h+30     ; get checksum location
        push    ax              ; save address
        call    rtc_get_loc
        add     al,bl           ; update checksum
        mov     dl,al
        pop     ax
        call    rtc_set_loc
.5:
        popm    bx,dx
        ret

; Write Enable the CMOS chip
;
write_enable:
        pushm   ax,dx
        mov     ax,7            ;
        mov     dl,0
        call    rtc_set_loc
        popm    ax,dx
        ret

; Write Protect the CMOS chip
;
write_protect:
        pushm   ax,dx
        mov     ax,7            ;
        mov     dl,80h
        call    rtc_set_loc
        popm    ax,dx
        ret


;
; Get Tick Count
;       AL = rolled-over flag
;       CX:DX = tick counter
;
fn0:
        xor     ax,ax
        xchg    al,[timer_new_day]
        mov     [bp+offset_AX],ax
        mov     dx,[timer_ticks]
        mov     cx,[timer_ticks+2]
        jmp     good_exit

;
; Set Tick Count
;   returns:
;       CX:DX = tick counter
;
fn1:
        mov     [timer_ticks],dx
        mov     [timer_ticks+2],cx
        jmp     good_exit



;
; Get Time from CMOS clock
;   returns:
;       CH = hours in BCD
;       CL = minutes in BCD
;       DH = seconds in BCD
;       DL = DST code (00=standard time, 01=daylight time)
;
;       Carry Clear if clock is running
;
;       Carry Set if clock is stopped
;
fn2:
        mov     ax,8004h        ; RAM_bits
        call    rtc_get_loc
        mov     dl,al
        and     dl,1            ; RAM_bits_DST flag

.2:
        mov     ax,0
        call    rtc_get_loc
        mov     dh,al           ; seconds

        mov     ax,2            ; hours (AH=0)
        call    rtc_get_loc
        mov     ch,al

        mov     ax,1
        call    rtc_get_loc
        mov     cl,al           ; minutes

        mov     ax,0            ; seconds again
        call    rtc_get_loc
        cmp     dh,al
        jne     .2

        and     dh,7Fh          ; clear the ClockHalt flag

        test    al,80h          ; test the ClockHalt flag
        jz      good_exit
        jmp     set_carry




;
; Set Time into the CMOS clock
;   enter with:
;       CH = hours in BCD
;       CL = minutes in BCD
;       DH = seconds in BCD
;       DL = DST flag (0=std time, 1=daylight time)
;
fn3:
        pushm   cx,dx
        call    write_enable

        mov     bl,dl           ; BL = DST flag
        mov     dl,80h          ; Clock Halt flag
        mov     ax,0
        call    rtc_set_loc     ; stop the clock
        mov     ax,1
        mov     dl,cl           ; minutes to DL
        call    rtc_set_loc
        mov     ax,2
        mov     dl,ch           ; hours to DL
        call    rtc_set_loc
        mov     ax,0
        mov     dl,dh           ; start the clock
        call    rtc_set_loc


        mov     ax,8000h | RAM_bits        ; RAM_bits location (4)
        call    rtc_get_loc
        and     al,0FFh^RAM_bits_DST         ; RAM_bits_DST zeroed
        mov     dl,bl           ; DST code to DL
        and     dl,RAM_bits_DST ; mask to 1 bit
        or      dl,al           ; preserve the other bits

        mov     al,RAM_bits     ; DST flag is updated
                                ;   and the other flags are preserved
        call    updateCMOS      ; update loc. 4 & checksum

        call    write_protect
        popm    cx,dx
good_exit2:
        jmp     good_exit



;
; Get Date
;   return with:
;       CH = century in BCD (19h or 20h)
;       CL = year in BCD
;       DH = month in BCD
;       DL = day in BCD
;
;       Carry clear if clock is running, set if clock is stopped
;
fn4:
        mov     ax,8001h        ; century byte
        call    rtc_get_loc
        mov     ch,al

        mov     ax,6            ; year
        call    rtc_get_loc
        mov     cl,al

        mov     ax,4            ; month
        call    rtc_get_loc
        mov     dh,al

        mov     ax,3            ; day (date)
        call    rtc_get_loc
        mov     dl,al

        mov     ax,0
        call    rtc_get_loc
        test    al,80h
        jz      good_exit2
        jmp     set_carry




;
; Set Date in the CMOS clock chip
;   enter with:
;       CH = century in BCD
;       CL = year in BCD
;       DH = month in BCD
;       DL = day in BCD
;
fn5:
        pushm   cx,dx
        call    write_enable

        mov     ax,3            ; day
        call    rtc_set_loc

        mov     dl,dh
        mov     ax,4            ; month
        call    rtc_set_loc

        mov     dl,cl
        mov     ax,6            ; year
        call    rtc_set_loc

        mov     dl,ch           ; century
        mov     al,1
        call    updateCMOS      ; fix checksum, too

        call    write_protect
        popm    cx,dx
        jmp     good_exit
