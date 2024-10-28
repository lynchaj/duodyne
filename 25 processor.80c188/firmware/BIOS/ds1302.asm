;========================================================================
; DS1302.ASM -- support on the SBC-188 for the DS1302 chip
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
; Updated for the Duodyne 80c188 SBC
;========================================================================

        segment         _TEXT

rtc_data        equ     80H             ; Data mask bit
rtc_wren        equ     20H             ; Write enable bit
rtc_clk         equ     40H             ; Clock signal
rtc_rst         equ     10H             ; Reset bit


;        global  _rtc_reset
rtc_reset:
        mov     dx,RTC              ; set the device code
        mov     al,rtc_rst              ; Reset, enable read
        jmp     rtc_out


;        global  _rtc_reset_off
rtc_reset_off:
        mov     dx,RTC
        mov     al,0                    ; Reset Off, enable read
rtc_out:
        out     dx,al
        mov     cx,16
        jmp     microsecond             ; delay 16 us


;        global  @rtc_write
@rtc_write:
rtc_write:
        push    bx

        mov     dx,RTC
        mov     bl,al                   ; save data in BL
        mov     ah,8                    ; set loop count
.1:
        mov     al,rtc_wren             ; write enable, reset off, clock off
        shr     bl,1                    ; data bit to Carry
        adc     al,0                    ; data to BIT 0
        call    rtc_out                 ; put out the data

        or      al,rtc_clk              ; set the clock bit
        call    rtc_out                 ; put out the data

        dec     ah                      ; count a bit
        jnz     .1

; rtc_write ends with the clock high
        pop     bx
        ret




rtc_read:
        push    bx

        mov     dx,RTC
        mov     bl,8                    ; bit count
.1:
        mov     al,0                    ; clock off, reset off, read enable
        call    rtc_out
; delay was included in the above output call
        in      al,dx                   ; read a bit
        ror     ax,1                    ; rotate data into AH left to right

        mov     al,rtc_clk              ; set to clock next data bit
        call    rtc_out
        dec     bl
        jnz     .1

        shr     ax,8                    ; return data in AL,  AH=0

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

        mov     dx,RTC
        call    rtc_reset
        call    rtc_reset_off   ; signal that a command is coming
        mov     al,bh
        call    rtc_write       ; write out the command
        call    rtc_read        ; read the data location
        push    ax              ; save the result
        call    rtc_reset_off
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

        mov     dx,RTC
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
