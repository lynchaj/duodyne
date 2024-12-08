;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CPUREGS.ASM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   This version is for assembly by  NASM 0.98.39 or later
;
; Copyright (C) 2010,2011 John R. Coffman.  All rights reserved.
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
; Updated for the Duodyne 80c188 SBC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include	"macros.inc"

	cpu     186
;
;
; IBM model byte -- must be less than a 286
;

MODEL_BYTE		equ	0FEh	; PC-XT
SUBMODEL_BYTE		equ	00h	;  "


; 80188 peripheral control register block address
CPU_CSCR	        equ	0FF00h

; Compatible Mode registers

cpu_relocation          equ     CPU_CSCR+0FEh

; The memory and peripheral chip select register offsets from 0FF00h

cpu_umcs                equ     CPU_CSCR+0A0h          ; Upper memory select
cpu_lmcs                equ     CPU_CSCR+0A2h          ; Lower memory select
cpu_pacs                equ     CPU_CSCR+0A4h          ; Peripheral select
cpu_mmcs                equ     CPU_CSCR+0A6h          ; Middle memory base
cpu_mpcs                equ     CPU_CSCR+0A8h          ; Mid mem. & peripherals

; Enhanced Mode registers

cpu_mdram               equ     CPU_CSCR+0E0h          ; memory partition reg.
cpu_cdram               equ     CPU_CSCR+0E2h          ; clock prescaler
cpu_edram               equ     CPU_CSCR+0E4h          ; Enable refresh reg.
cpu_pdcon               equ     CPU_CSCR+0F0h          ; Power-Save control


; On-board internal peripheral equates
; Programmable Interrupt Controller
PIC	        equ	CPU_CSCR+020H
PIC_EOI	        equ	PIC+2           ; End Of Interrupt
PIC_POLLR	equ	PIC+4
PIC_POLLSR	equ	PIC+6
PIC_IMASK	equ	PIC+8
PIC_PMREG	equ	PIC+0AH
PIC_SRVR	equ	PIC+0CH
PIC_IRQR	equ	PIC+0EH
PIC_IRQSR	equ	PIC+10H
PIC_TCR	        equ	PIC+12H
PIC_DMA0CR	equ	PIC+14H
PIC_DMA1CR	equ	PIC+16H
PIC_I0CON	equ	PIC+18H
PIC_I1CON	equ	PIC+1AH
PIC_I2CON	equ	PIC+1CH
PIC_I3CON	equ	PIC+1EH

EOI_NSPEC       equ     8000h           ; Non-Specific EOI

; Interrupt masks (Master Mode)
;
mask_timer_all          equ     0001h
mask_dma0               equ     0004h
mask_dma1               equ     0008h
mask_int0               equ     0010h
mask_int1               equ     0020h
mask_int2               equ     0040h
mask_int3               equ     0080h



; Timers
TIM0	        equ	CPU_CSCR+050H
TIM1	        equ	CPU_CSCR+058H
TIM2	        equ	CPU_CSCR+060H

TCNT	        equ	0	; count register
CMPA	        equ	2	; max count A
CMPB	        equ	4	; max count B (not present on TIM2)
TCON	        equ	6	; mode/control word

; Timer control bits:
tc_EN           equ     8000h   ; Enable bit
tc_nINH         equ     4000h   ; not Inhibit Enable
tc_INT          equ     2000h   ; Interrupt Enable
tc_RIU          equ     1000h   ; Register A/B (0/1) in Use
tc_MC           equ     0020h   ; Maximum Count reached
tc_RTG          equ     0010h   ; Retrigger (internal source)
tc_P            equ     0008h   ; Prescale internal clock (timers 0 & 1 only)
tc_EXT          equ     0004h   ; External clock
tc_ALT          equ     0002h   ; Alternate between A & B max count registers
tc_CONT         equ     0001h   ; Continuous: continue after max count




; DMA
DMA0	        equ	CPU_CSCR+0C0H
DMA1	        equ	CPU_CSCR+0D0H
DMASPL	        equ	0	; source pointer low
DMASPU	        equ	2	; source pointer high
DMADPL	        equ	4	; destination pointer low
DMADPU	        equ	6	; destination pointer high
DMATC	        equ	8	; terminal count
DMACW	        equ	0AH	; control word





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;       SBC-188 external devices
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IO_BASE			equ	0400h



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The UART registers (Duodyne SBC 80c188 Console port)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

uart_base               equ     IO_BASE+0280h
uart_rbr                equ     uart_base       ;Rcvr Buffer / read only
uart_thr                equ     uart_base       ;Transmit Holding / write only
uart_ier                equ     uart_base+1     ;Interrupt Enable
uart_iir                equ     uart_base+2     ;Interrupt Ident / read only
uart_fcr                equ     uart_base+2     ;FIFO Control / write only
uart_lcr                equ     uart_base+3     ;Line Control
uart_mcr                equ     uart_base+4     ;Modem Control
uart_lsr                equ     uart_base+5     ;Line Status
uart_msr                equ     uart_base+6     ;Modem Status
uart_sr			equ	uart_base+7	;Scratch

uart_dll                equ     uart_base       ;Divisor Latch LS Byte
uart_dlm                equ     uart_base+1     ;Divisor Latch MS Byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONTROL LS259 PORT  (DuoDyne 80C188)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CTRL259		equ	IO_BASE+0238H
; LEDS are at addresses 0..3
; other control ports on 4..7
LED0		equ	CTRL259+0
LED1		equ	LED0+1
LED2		equ	LED0+2
LED3		equ	LED0+3
T1OSC18		equ	CTRL259+4	; ON=1.8432mhz, OFF="1" (for use of TIMER2)
;unused		equ	CTRL259+5
;unused		equ	CTRL259+6
;unused		equ	CTRL259+7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Front Panel Connector  (DuoDyne 80C188)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FRONT_PANEL_LED	equ	IO_BASE+0230H



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Floppy controller (Duodyne Disk IO)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FDC	        equ	IO_BASE+0080H
FDC_MSR         equ     FDC
FDC_DATA        equ     FDC+1
FDC_TC	        equ	FDC+2
FDC_RES	        equ	FDC+3
FDC_LDCR	equ	FDC+5
FDC_LDOR	equ	FDC+6
FDC_DACK        equ	FDC+6
FDC_DACK_TC     equ     FDC+7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CH376 controller (Duodyne Multi IO)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CH376	        equ	IO_BASE+004EH



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DS1302 RTC (Duodyne Ram/ROM Card)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RTC	equ	IO_BASE+0094H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PIO 82C55 I/O  (Duodyne Disk IO)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PPI	        equ	IO_BASE+0088H

PIO_A	        equ	PPI+0	; (OUTPUT)
PIO_B	        equ	PPI+1	; (INPUT)
PIO_C	        equ	PPI+2	; (CENTRONICS control low nibble)
PIO_CTRL	equ	PPI+3	; CONTROL BYTE PIO 82C55

portA           equ     PPI+0   ;
portB           equ     PPI+1   ;
portC           equ     PPI+2   ;

; end CPUREGS.ASM
