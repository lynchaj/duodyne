        BITS    16
        CPU     186
F_CPU           EQU 10000000
F_UART          EQU 1843200
        %DEFINE uartdll(baud) (F_UART/(16*baud)) & 0FFh
        %DEFINE uartdlm(baud) (F_UART/(16*baud)) >> 8

	%imacro SETLOC  1.nolist
        TIMES   (%1-($-$$)) db 0ffh
	%endm

	%imacro DB_LO   1
        DB      %1 & 0ffh
	%endm

	%imacro OUTP    2
        MOV     dx, %1
        MOV     al, %2
        OUT     dx, al
	%endm

; External peripheral interface
ep_base         EQU 0F800h
ep_pcs0         EQU ep_base
ep_pcs1         EQU ep_base+80h
ep_pcs2         EQU ep_base+100h
ep_pcs3         EQU ep_base+180h
ep_pcs4         EQU ep_base+200h
ep_pcs5         EQU ep_base+280h
ep_pcs6         EQU ep_base+300h


RAMROM_card_1	 EQU ep_base+94h
front_panel_LEDs EQU ep_pcs4+30h
local_ls259_LED1 EQU ep_pcs4+38h
local_ls259_LED2 EQU ep_pcs4+39h
local_ls259_LED3 EQU ep_pcs4+3Ah
local_ls259_LED4 EQU ep_pcs4+3Bh



; 16550 UART (on board)
uart_base       EQU ep_pcs5
uart_rbr        EQU uart_base   ; Receiver buffer register (read)
uart_thr        EQU uart_base   ; Transmitter holding register (write)
uart_ier        EQU uart_base+1 ; Interrupt enable register
uart_iir        EQU uart_base+2 ; Interrupt identification register (read)
uart_lcr        EQU uart_base+3 ; Line control register
uart_mcr        EQU uart_base+4 ; Modem control register
uart_lsr        EQU uart_base+5 ; Line status register
uart_msr        EQU uart_base+6 ; Modem status register
uart_scr        EQU uart_base+7 ; Scratch register

uart_dll        EQU uart_base   ; Divisor latch (LSB) (when DLAB=1)
uart_dlm        EQU uart_base+1 ; Divisor latch (MSB) (when DLAB=1)


; Internal peripheral interface
ip_base         EQU 0ff00h      ; Control block base address
ip_rr           EQU ip_base+0feh; Relocation register
ip_pdcon        EQU ip_base+0f0h; Power-save control register (enhanced mode only)

; DRAM refresh (enhanced mode only)
idr_mdram       EQU ip_base+0e0h; Memory partition register
idr_cdram       EQU ip_base+0e2h; Clock pre-scaler register
idr_edram       EQU ip_base+0e4h; Enable RCU register

; Chip selects
ics_umcs        EQU ip_base+0a0h; Upper memory base address
ics_lmcs        EQU ip_base+0a2h; Lower memory end address
ics_pacs        EQU ip_base+0a4h; Peripheral base address
ics_mmcs        EQU ip_base+0a6h; Middle memory base address
ics_mpcs        EQU ip_base+0a8h; Middle memory size, peripheral mapping

; DMA
id0_cw          EQU ip_base+0cah; Control word
id0_tc          EQU ip_base+0c8h; Transfer count
id0_dph         EQU ip_base+0c6h; Destination pointer, upper 4 bits
id0_dp          EQU ip_base+0c4h; Destination pointer
id0_sph         EQU ip_base+0c2h; Source pointer, upper 4 bits
id0_sp          EQU ip_base+0c0h; Source pointer

id1_cw          EQU ip_base+0dah; Control word
id1_tc          EQU ip_base+0d8h; Transfer count
id1_dph         EQU ip_base+0d6h; Destination pointer, upper 4 bits
id1_dp          EQU ip_base+0d4h; Destination pointer
id1_sph         EQU ip_base+0d2h; Source pointer, upper 4 bits
id1_sp          EQU ip_base+0d0h; Source pointer

; Timers
it0_cw          EQU ip_base+56h ; Control word
it0_mcb         EQU ip_base+54h ; Max count B
it0_mca         EQU ip_base+52h ; Max count A
it0_cr          EQU ip_base+50h ; Count register

it1_cw          EQU ip_base+5eh ; Control word
it1_mcb         EQU ip_base+5ch ; Max count B
it1_mca         EQU ip_base+5ah ; Max count A
it1_cr          EQU ip_base+58h ; Count register

it2_cw          EQU ip_base+66h ; Control word
it2_mca         EQU ip_base+62h ; Max count A
it2_cr          EQU ip_base+60h ; Count register

; Interrupt controller
iim_int3        EQU ip_base+3eh ; INT3 control
iim_int2        EQU ip_base+3ch ; INT2 control
iim_int1        EQU ip_base+3ah ; INT1 control
iim_int0        EQU ip_base+38h ; INT0 control
iim_dma1        EQU ip_base+36h ; DMA 1 control
iim_dma0        EQU ip_base+34h ; DMA 0 control
iim_tim         EQU ip_base+32h ; Timer control
iim_ist         EQU ip_base+30h ; Interrupt status
iim_irq         EQU ip_base+2eh ; Interrupt request
iim_is          EQU ip_base+2ch ; In-service
iim_plm         EQU ip_base+2ah ; Priority level mask
iim_msk         EQU ip_base+28h ; Mask
iim_plst        EQU ip_base+26h ; Poll status
iim_poll        EQU ip_base+24h ; Poll
iim_eoi         EQU ip_base+22h ; End-of-interrupt

iis_tim2        EQU ip_base+3ah ; Timer 2 control
iis_tim1        EQU ip_base+38h ; Timer 1 control
iis_dma1        EQU ip_base+36h ; DMA 1 control
iis_dma0        EQU ip_base+34h ; DMA 0 control
iis_tim0        EQU ip_base+32h ; Timer 0 control
iis_ist         EQU ip_base+30h ; Interrupt status
iis_irq         EQU ip_base+2eh ; Interrupt request
iis_is          EQU ip_base+2ch ; In-service
iis_plm         EQU ip_base+2ah ; Priority level mask
iis_msk         EQU ip_base+28h ; Mask
iis_eoi         EQU ip_base+22h ; End-of-interrupt
iis_iv          EQU ip_base+20h ; Interrupt vector
