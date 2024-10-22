			bits 16
			cpu 186
F_CPU		equ 10000000
F_UART		equ 1843200
			%define uartdll(baud) (F_UART/(16*baud)) & 0FFh
			%define uartdlm(baud) (F_UART/(16*baud)) >> 8

%imacro setloc 1.nolist
			times (%1-($-$$)) db 0ffh
%endm

%imacro db_lo 1
			db %1 & 0ffh
%endm

%imacro outp 2
			mov dx, %1
			mov al, %2
			out dx, al
%endm

; External peripheral interface
ep_base		equ 0F800h
ep_pcs0		equ ep_base
ep_pcs1		equ ep_base+80h
ep_pcs2		equ ep_base+100h
ep_pcs3		equ ep_base+180h
ep_pcs4		equ ep_base+200h
ep_pcs5		equ ep_base+280h
ep_pcs6		equ ep_base+300h

; 8250 UART
uart_base	equ ep_pcs5
uart_rbr	equ uart_base				; Receiver buffer register (read)
uart_thr	equ uart_base				; Transmitter holding register (write)
uart_ier	equ uart_base+1				; Interrupt enable register
uart_iir	equ uart_base+2				; Interrupt identification register (read)
uart_lcr	equ uart_base+3				; Line control register
uart_mcr	equ uart_base+4				; Modem control register
uart_lsr	equ uart_base+5				; Line status register
uart_msr	equ uart_base+6				; Modem status register
uart_scr	equ uart_base+7				; Scratch register

uart_dll	equ uart_base				; Divisor latch (LSB) (when DLAB=1)
uart_dlm	equ uart_base+1				; Divisor latch (MSB) (when DLAB=1)


; Internal peripheral interface
ip_base		equ 0ff00h				; Control block base address
ip_rr		equ ip_base+0feh			; Relocation register
ip_pdcon	equ ip_base+0f0h			; Power-save control register (enhanced mode only)

; DRAM refresh (enhanced mode only)
idr_mdram	equ ip_base+0e0h			; Memory partition register
idr_cdram	equ ip_base+0e2h			; Clock pre-scaler register
idr_edram	equ ip_base+0e4h			; Enable RCU register

; Chip selects
ics_umcs	equ ip_base+0a0h			; Upper memory base address
ics_lmcs	equ ip_base+0a2h			; Lower memory end address
ics_pacs	equ ip_base+0a4h			; Peripheral base address
ics_mmcs	equ ip_base+0a6h			; Middle memory base address
ics_mpcs	equ ip_base+0a8h			; Middle memory size, peripheral mapping

; DMA
id0_cw		equ ip_base+0cah			; Control word
id0_tc		equ ip_base+0c8h			; Transfer count
id0_dph		equ ip_base+0c6h			; Destination pointer, upper 4 bits
id0_dp		equ ip_base+0c4h			; Destination pointer
id0_sph		equ ip_base+0c2h			; Source pointer, upper 4 bits
id0_sp		equ ip_base+0c0h			; Source pointer

id1_cw		equ ip_base+0dah			; Control word
id1_tc		equ ip_base+0d8h			; Transfer count
id1_dph		equ ip_base+0d6h			; Destination pointer, upper 4 bits
id1_dp		equ ip_base+0d4h			; Destination pointer
id1_sph		equ ip_base+0d2h			; Source pointer, upper 4 bits
id1_sp		equ ip_base+0d0h			; Source pointer

; Timers
it0_cw		equ ip_base+56h				; Control word
it0_mcb		equ ip_base+54h				; Max count B
it0_mca		equ ip_base+52h				; Max count A
it0_cr		equ ip_base+50h				; Count register

it1_cw		equ ip_base+5eh				; Control word
it1_mcb		equ ip_base+5ch				; Max count B
it1_mca		equ ip_base+5ah				; Max count A
it1_cr		equ ip_base+58h				; Count register

it2_cw		equ ip_base+66h				; Control word
it2_mca		equ ip_base+62h				; Max count A
it2_cr		equ ip_base+60h				; Count register

; Interrupt controller
iim_int3	equ ip_base+3eh				; INT3 control
iim_int2	equ ip_base+3ch				; INT2 control
iim_int1	equ ip_base+3ah				; INT1 control
iim_int0	equ ip_base+38h				; INT0 control
iim_dma1	equ ip_base+36h				; DMA 1 control
iim_dma0	equ ip_base+34h				; DMA 0 control
iim_tim		equ ip_base+32h				; Timer control
iim_ist		equ ip_base+30h				; Interrupt status
iim_irq		equ ip_base+2eh				; Interrupt request
iim_is		equ ip_base+2ch				; In-service
iim_plm		equ ip_base+2ah				; Priority level mask
iim_msk		equ ip_base+28h				; Mask
iim_plst	equ ip_base+26h				; Poll status
iim_poll	equ ip_base+24h				; Poll
iim_eoi		equ ip_base+22h				; End-of-interrupt

iis_tim2	equ ip_base+3ah				; Timer 2 control
iis_tim1	equ ip_base+38h				; Timer 1 control
iis_dma1	equ ip_base+36h				; DMA 1 control
iis_dma0	equ ip_base+34h				; DMA 0 control
iis_tim0	equ ip_base+32h				; Timer 0 control
iis_ist		equ ip_base+30h				; Interrupt status
iis_irq		equ ip_base+2eh				; Interrupt request
iis_is		equ ip_base+2ch				; In-service
iis_plm		equ ip_base+2ah				; Priority level mask
iis_msk		equ ip_base+28h				; Mask
iis_eoi		equ ip_base+22h				; End-of-interrupt
iis_iv		equ ip_base+20h				; Interrupt vector
