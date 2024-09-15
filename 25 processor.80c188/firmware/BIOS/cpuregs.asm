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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include	"macros.inc"

	cpu     186
;
;
; IBM model byte -- must be less than a 286
;
;MODEL_BYTE		equ	0FEh	; PC-XT
;SUBMODEL_BYTE		equ	0FFh	; not used

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
; The UART registers
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
; Floppy controller
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FDC	        equ	IO_BASE+0200H
FDC_MSR         equ     FDC
FDC_DATA        equ     FDC_MSR+1
FDC_DACK        equ	FDC+10H
FDC_LDOR	equ	FDC+20H
FDC_LDCR	equ	FDC+30H
FDC_TC	        equ	FDC+40H
FDC_DACK_TC     equ     FDC_DACK | FDC_TC


%if SBC188==1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DS1302 RTC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RTC	equ	IO_BASE+0300H
%endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PIO 82C55 I/O 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for the SBCv1/v2 with PPIDE adapter board
; and for the SBCv3 with PPIDE connector
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PPI	        equ	IO_BASE+0260H

PIO_A	        equ	PPI+0	; (OUTPUT)
PIO_B	        equ	PPI+1	; (INPUT)
PIO_C	        equ	PPI+2	; (CENTRONICS control low nibble)  
PIO_CTRL	equ	PPI+3	; CONTROL BYTE PIO 82C55

portA           equ     PPI+0   ;
portB           equ     PPI+1   ;
portC           equ     PPI+2   ;



;;;%if SBC188==3   startup.asm is universal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONTROL LS259 PORT ON SBC188 V3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CTRL259		equ	IO_BASE+0270H
; LEDS are at addresses 0..3
; other control ports on 4..7
LED0		equ	CTRL259+0
LED1		equ	LED0+1
LED2		equ	LED0+2
LED3		equ	LED0+3
T1OSC18		equ	CTRL259+4	; ON=1.8432mhz, OFF="1" (for use of TIMER2)
;unused		equ	CTRL259+5
FDC_RES		equ	CTRL259+6	; RESET IS ACTIVE HIGH
IDE8_RES	equ	CTRL259+7	; fast IDE RESET IS ACTIVE LOW


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FIDE8 8-bit IDE on the 80C188 bus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FIDE_BASE       equ     IO_BASE+2C0h

IDE8_CS0        equ     FIDE_BASE
IDE8_CS1        equ     FIDE_BASE+0x10

;;;%endif   startup.asm is universal


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Dual [DMA] IDE devices
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DIDE		equ	IO_BASE + 20H	; range 0x20..0x3F

DIDE0		equ	DIDE		; first interface (master & slave)
DIDE1		equ	DIDE+10h	; second interface (master & slave)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DISK I/O v3 device codes (PPIDE only)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISKIO		equ	IO_BASE + 20h	; range 0x20..0x3F

DISKIO_PPIDE	equ	DISKIO		; 82c55
DISKIO_FDC	equ	DISKIO + 10h	; FDC 9266
DISKIO_DOR	equ	DISKIO + 18h	; OPERATION REGISTER	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MF/PIC interfaces
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MFPIC		equ	IO_BASE + 40h	; range 0x40..0x4F

;MFPIC_202	equ	MFPIC		; NS32202 is not usable on SBC-188
MFPIC_PPIDE	equ	MFPIC + 4	; PPIDE disk interface
MFPIC_UART	equ	MFPIC + 8	; TL16Cx50 SIO chip


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cassette I/O
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cuart_base	EQU 	IO_BASE+80H	; BASE IO ADDRESS OF CASSETTE UART
cuart_rbr	equ     cuart_base	;Rcvr Buffer / read only
cuart_thr	equ     cuart_base	;Transmit Holding / write only
cuart_ier	equ     cuart_base+1	;Interrupt Enable
cuart_iir	equ     cuart_base+2	;Interrupt Ident / read only
cuart_fcr	equ     cuart_base+2	;FIFO Control / write only
cuart_lcr	equ     cuart_base+3	;Line Control
cuart_mcr	equ     cuart_base+4	;Modem Control
cuart_lsr	equ     cuart_base+5	;Line Status
cuart_msr	equ     cuart_base+6	;Modem Status
cuart_sr	equ	cuart_base+7	;Scratch

cuart_dll	equ     cuart_base	;Divisor Latch LS Byte
cuart_dlm	equ	cuart_base+1	;Divisor Latch MS Byte


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;       4MEM control registers
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EMM_addr        equ     1               ; high 6 bits of 20-bit address
EMM_page        equ     0               ; 4MEM page in [0..254]

EMM_BASE        equ     IO_BASE + 000h          ; first EMM (4MEM) board
EMM_unmapped    equ     255             ; unmapped 4MEM page

EMM0            equ     EMM_BASE        ; first  EMM board
EMM1            equ     EMM0 + 2        ; second EMM board
EMM2            equ     EMM1 + 2        ; third  EMM board
EMM3            equ     EMM2 + 2        ; fourth EMM board




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	ColorVDU devices
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	major select on the Z80 bus
;
devCVDU_8bit	equ	0xE0		; this may change to 0x10

devCVDUbase 	equ	IO_BASE + devCVDU_8bit

M8563status	equ	devCVDUbase + 4		; 4 == bitrev(2)
M8563register	equ	devCVDUbase + 4
M8563data	equ	devCVDUbase + 12	; 12 == bitrev(3)

%if CVDU_8563
I8242status	equ	devCVDUbase + 10	; 10 == bitrev(5)
I8242command	equ	devCVDUbase + 10
I8242data	equ	devCVDUbase + 2		; 2 == bitrev(4)
%endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	VGA3 devices
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	major select on the Z80 bus
;
devVGA3_8bit    equ     0xE0                    ; same as CVDU

devVGA3base       equ     IO_BASE + devVGA3_8bit

%if VGA3_6445
I8242status	equ	devVGA3base + 1
I8242command	equ	devVGA3base + 1
I8242data	equ	devVGA3base + 0
%endif
HD6445addr	equ	devVGA3base + 2		; to address the HD6445 registers
HD6445reg	equ	devVGA3base + 3		; to r/w a register on the CRTC

vga3cfg		equ	devVGA3base + 4
; the following are probably not used on the SBC-188, except for testing/checking
vga3adhi	equ	devVGA3base + 5
vga3adlo	equ	devVGA3base + 6
vga3data	equ	devVGA3base + 7



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;       2S1P registers
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dev_2S1P_loc		equ	0xC0	; same as 4UART !!!

dev_2S1P_base		equ	IO_BASE + dev_2S1P_loc	

dev_2S1P_A		equ	dev_2S1P_base		; serial port
dev_2S1P_B		equ	dev_2S1P_base + 8h	; serial port

dev_2S1P_C		equ	dev_2S1P_base + 10h	; parallel port


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;       4UART registers
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dev_4UART_loc		equ	0xC0	; same as 2S1P !!!
;				0xA0	; possible alternate
dev_4UART_alt_offset	equ	0xA0 - dev_4UART_loc

dev_4UART_base		equ	IO_BASE + dev_4UART_loc	

dev_4UART_A		equ	dev_4UART_base
dev_4UART_B		equ	dev_4UART_base + 8h
dev_4UART_C		equ	dev_4UART_base + 10h
dev_4UART_D		equ	dev_4UART_base + 18h

dev_4UART_config	equ	dev_4UART_B + 7		; overlays scratch register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; debug port -- JRC only
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
portD		equ	IO_BASE + 0FFh		; 0x04FF
;portD		equ	portB		     ; older 8255 output on PPI

; end CPUREGS.ASM

