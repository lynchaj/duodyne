;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; timer.inc -- constants for the timers
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
; SBC-386 board revisions:
;       SBC386-0   prototype / concept testing
;	SBC-386EX 2.0	production / January 2018
;
; Assembly by NASM 2.08 is preferred
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;include "i386EX.inc" -- must be included at a higher level

TIMER_STOP	equ	BIT6+BIT0 + ZBIT1 + ZBIT3 + ZBIT5 ; stop 0, 1, 2
TIMER_RUN	equ	TIMER_STOP + BIT1 + BIT3	; run counters 0, 1


CTR0 equ ZBIT7+ZBIT6	;select counter 0
CTR1 equ ZBIT7+ BIT6	;select counter 1
CTR2 equ  BIT7+ZBIT6	;select counter 2
CWR01 equ BIT5+BIT4	;Write Count low, then high
MODE0 equ ZBIT3+ZBIT2+ZBIT1
MODE1 equ ZBIT3+ZBIT2+ BIT1
MODE2 equ ZBIT3+ BIT2+ZBIT1
MODE3 equ ZBIT3+ BIT2+ BIT1
MODE4 equ  BIT3+ZBIT2+ZBIT1
MODE5 equ  BIT3+ZBIT2+ BIT1
; counter 0 runs at 1.8432mhz / 2  =  921600  (just under 1mhz)
; @20hz, the divisor is 46080 yielding a 50ms time slot
COMCLK	equ	1843200		; standard 1.8432mhz oscillator
BAUD	equ	9600		; default SIO0 bit rate
DIVISOR	equ	COMCLK/16/BAUD	; SIO0 divisor to achieve BAUD rate
CLKIN0	equ	COMCLK/2	; Timer0 input count rate
MS50	equ	CLKIN0 / 20	; 50ms clock
MS50HI	equ	MS50/256
MS50LO	equ	MS50 & 0xFF
MS18	equ	50619		; 18.206602hz clock (54.92513ms)
				; 0x1800BA = 1573050 ticks/day
MS18b	equ	50625		; 18.204444hz clock (54.93164ms)
				; 0x180000 = 1572864 ticks/day
MS18HI	equ	MS18/256
MS18LO	equ	MS18 & 0xFF

