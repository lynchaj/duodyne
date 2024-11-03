;========================================================================
; DS3UART.ASM -- support on the SBC-188v3 for the DS1302 chip
;========================================================================
;
;   This version is for assembly by  NASM 2.08
;
; Copyright (C) 2010   John R. Coffman
; Provided for hobbyist use on the N8VEM SBC-188 board
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

        segment         _TEXT


; in the MCR - modem control register  (uart+4)
rtc_data        equ     1	;DTR	; Data mask bit
;			2	;RTS
rtc_clk         equ     4	;OUT1	; Clock signal (true)
rtc_rst         equ     8	;OUT2	; Reset bit  (1=reset, 0=enable)

; in the MSR - modem status register   (uart+6)
rtd_data_in	equ	128	;DCD	; Data in bit



;        global  _rtc_reset
rtc_reset:
        mov     dx,uart_mcr             ; set the device code
	in	al,dx			; read current value
	and	al,~rtc_clk		; clock low
	call	rtc_out

        or      al,rtc_rst		; reset on
%if SOFT_DEBUG
	test	al,2		; test if RTS is gone
	jnz	rtc_out
	push	dx
	mov	dx,4FFh
	out	dx,al
	hlt
	jmp	$-1
	pop	dx
%endif
        jmp     rtc_out


;        global  _rtc_reset_off
rtc_reset_off:
        mov     dx,uart_mcr
	in	al,dx
	and	al,~rtc_clk		; set clock low
	call	rtc_out
	and	al,~rtc_rst		; turn reset off
; assume clock is low from previous reset_on

rtc_out:
	mov	dx,uart_mcr	; insurance, for the moment
        out     dx,al
        mov     cx,16
        jmp     microsecond             ; delay 16 us


;        global  @rtc_write
@rtc_write:
rtc_write:
        push    bx

        mov     ah,al                   ; save data in AH
        mov     bl,8                    ; set loop count

        mov     dx,uart_mcr
	in	al,dx			; get current state
; assume reset is off
.1:	and	al,~rtc_clk		; set clock low
	call	rtc_out

	shr	ax,1			; data to bit 7, old DTR to carry
	rol	al,1			; data to bit 0
        call    rtc_out                 ; put out the data

        or      al,rtc_clk              ; set the clock bit
        call    rtc_out                 ; put out the data

        dec     bl                      ; count a bit
        jnz     .1

; rtc_write ends with the reset off, clock high, data bit unknown

        pop     bx
        ret




rtc_read:
        push    bx

        mov     bl,8                    ; bit count

.1:	mov     dx,uart_mcr
	in	al,dx			; get current state
	or	al,rtc_clk+rtc_data
	call	rtc_out			; clock high, data high for read

	and	al,~(rtc_rst+rtc_clk)	; reset off, clock off
        call    rtc_out
; delay was included in the above output call
	mov	dx,uart_msr		; data is in bit 7
        in      al,dx                   ; read a data bit
	rcl	al,1			; shift into Carry
	rcr	ah,1			; and rotate into the left of AH

	dec     bl
        jnz     .1

        shr     ax,8                    ; return data in AL,  AH=0

; rtc_read ends with reset off, clock low, data high
; MSR, not MCR is in DX

        pop     bx
        ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  rtc_get_loc          RTC get location as addressed
;       Enter with      AL = address of the location to get
;                       AH = Flag RAM/clock  (RAM=!0, clock=0)
;       Exit with data in AL
;               All other registers are preserved
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        global  @rtc_get_loc
        global  rtc_get_loc
@rtc_get_loc:
rtc_get_loc:
        push    dx
        push    cx              ; 3 register saves
        push    bx

        or      ah,ah           ; test flag
        jz      .1
        mov     ah,040h         ; RAM flag
.1:     mov     bh,ah           ; save flag in BH
        and     al,31           ; mask address to 5 bits
        add     al,al           ; shift left
        or      bh,al           ; form command
        or      bh,81h          ; Clock Command / READ bit = 01h

        call    rtc_reset
        call    rtc_reset_off   ; signal that a command is coming
        mov     al,bh
        call    rtc_write       ; write out the command
        call    rtc_read        ; read the data location
        push    ax              ; save the result
	call	rtc_reset_off	;
        call    rtc_reset       ; and finish up

        pop     ax              ; return value

        pop     bx
        pop     cx              ; plus 3 register restores
        pop     dx
        ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  rtc_set_loc          RTC set location as addressed
;       Enter with      AL = address of the location to set
;                       AH = Flag RAM/clock  (RAM=!0, clock=0)
;                       DL = data to write to location
;               AX is undefined on return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        global  @rtc_set_loc
        global  rtc_set_loc
@rtc_set_loc:
rtc_set_loc:
        push    dx
        push    cx              ; 3 register saves
        push    bx

        push    dx              ; save data

        or      ah,ah           ; test flag
        jz      .1
        mov     ah,040h         ; RAM flag
.1:     mov     bh,ah           ; save flag in BH
        and     al,31           ; mask address to 5 bits
        add     al,al           ; shift left
        or      bh,al           ; form command
        or      bh,80h          ; Clock Command / WRITE bit = 00h

        call    rtc_reset
        call    rtc_reset_off   ; signal that a command is coming
        mov     al,bh           ; command to AL
        call    rtc_write       ; write out the command
        pop     ax              ; get the data value
        call    rtc_write       ; write the data
        call    rtc_reset_off   ; end of command
        call    rtc_reset

        pop     bx
        pop     cx              ; plus 3 register restores
        pop     dx
        ret
