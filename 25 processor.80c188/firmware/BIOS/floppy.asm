	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; floppy.asm - - WD37C65B floppy disk controller driver
	; Version 2.0 - - Apr 2013, JRC
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	; This version is for assembly by NASM 0.98.39 or later
	;
	; Copyright (C) 2010 - 2013 John R. Coffman. All rights reserved.
	; Provided for hobbyist use on the N8VEM SBC - 188 board.
	;
	; This program is free software: you can redistribute it and / or modify
	; it under the terms of the GNU General Public License as published by
	; the Free Software Foundation, either version 3 of the License, or
	; (at your option) any later version.
	;
	; This program is distributed in the hope that it will be useful,
	; but WITHOUT ANY WARRANTY; without even the implied warranty of
	; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	; GNU General Public License for more details.
	;
	; You should have received a copy of the GNU General Public License
	; along with this program. If not, see <http: / / www.gnu.org / licenses / >.
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	%include "config.asm"
	%include "cpuregs.asm"
	%include "equates.asm"

	%define DUMP 0
	%define DEBUG 0
	%define SOFT_DEBUG 0
	; sterilize SOFT_DEBUG for now
	%if SOFT_DEBUG > 1
	%undef SOFT_DEBUG
	%define SOFT_DEBUG 1
	%endif

	global BIOS_call_13h
	;; global Floppy_BIOS_call_13h_entry
	global wait12
	global @enable, @disable
	%if SOFT_DEBUG
	extern _cprintf
	global undefined
	global fn00, fn02, fn03, fn04
	global get_msr
	global get_data
	global put_data
	global check_DL
	global get_disk_type
	global get_media
	global set_media_pointer
	global rwv_common
	global Seek, recalibrate, Specify
	global rwv_common.marker
	global end_rwv
	global xfer_read_sector, xfer_write_sector, xfer_verify_sector
	global xfer_format_track
	global Check_RW_Status
	%endif

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Error, Okay, Complete status conditions
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	%define Error stc
	; test with:
	; JC xxx (jump on error)
	; JNC xxx (jump on no error)

	%define Okay xor ah, ah
	; test with:
	; JZ xxx (jump okay)
	; JNZ xxx (jump not okay)

	%define Complete or ah, 3
	; test with:
	; JA xxx (jump complete AND no error)
	; JNZ xxx (jump complete)
	; JZ xxx (jump not complete)

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	; at most we use 2 floppies
	%define FLOPPY_MAX 2

	; there is some disagreement about whether ES:DI gets set
	; for Floppy calls to "int 13h, function 8"
	FN08_SET_ES_DI equ 1
	;FN08_SET_ES_DI equ 0

	; Define the three modes of operation of the WD37C65B floppy controller
	%define BASE 0FFh
	%define SPECIAL 80h
	%define PC_AT 00h

	; DMA watch threshhold
	%define THRESHHOLD 12

	; Define the mode in which the WD37C65B is operated
	%define MODE PC_AT           ; This MUST NOT be changed

	; specify bits in the Operations Register
	%define DSEL1 00h
	%define DSEL2 01h
	%define DSEL_MASK (DSEL1|DSEL2)
	%define NO_RESET 04h
	%define RESET 00h
	%define DMAEN 08h
	%define MOEN1 10h
	%define MOEN2 20h
	%define MOEN_MASK (MOEN1|MOEN2)

	%define TurnOn 8             ; used by all DSEL's

	; the Motor turn - on delay in milliseconds
	%define MOTOR_DELAY (TurnOn * 125)

	; define the disk density clock rate selects
	%define FDC_HD 00h
	%define FDC_DD 02h

	; The individual floppy disk status bits
	%define FDC_DRIVE_PRESENT 1
	%define FDC_DRIVE_READY 2


	; define the MSR bits:
	RQM equ 80h                  ; request for master
	DIO equ 40h                  ; data IN=1, out=0
	EXM equ 20h                  ; Execution phase in non - DMA mode
	; this should NEVER be set
	BUSY equ 10h                 ; Controller Busy
	FD3 equ 08h                  ; DS3 is seeking
	FD2 equ 04h                  ; DS2 is seeking
	FD1 equ 02h                  ; DS1 is seeking
	FD0 equ 01h                  ; DS0 is seeking

	; MSR I / O status (in / out from CPU)
	MSR_IN equ RQM | DIO
	MSR_OUT equ RQM
	MSR_MASK equ RQM | DIO

	; This is the list of controller commands that we use

	CMD_RECALIBRATE equ 7        ; 1 param byte (unit #)
	; No result bytes
	CMD_SENSE_INT_STATUS equ 8   ; No paramter bytes
	; 2 result bytes
	CMD_SENSE_DRIVE_STATUS equ 4 ; 1 param byte
	; 1 result byte
	CMD_SPECIFY equ 3            ; 2 parameter bytes
	; No result bytes
	CMD_SEEK equ 15              ; 2 parameter bytes
	; No result bytes
	CMD_READ_ID equ 10           ; param in cmd; 1 param byte
	; 7 result bytes
	CMD_READ_DATA equ 6          ; params in cmd; 8 param bytes
	; 7 result bytes
	CMD_WRITE_DATA equ 5         ; params in cmd; 8 param bytes
	; 7 result bytes
	CMD_READ_A_TRACK equ 2       ; params in cmd; 8 param bytes
	; 7 result bytes
	CMD_FORMAT_A_TRACK equ 13    ; params in cmd; 5 param bytes
	; 7 result bytes
	CMD_SCAN_EQUAL equ 11h       ; params in cmd; 8 param bytes
	; 7 result bytes
	CMD_SCAN_LOW_OR_EQUAL equ 19h ; params in cmd; 8 param bytes
	; 7 result bytes
	CMD_SCAN_HIGH_OR_EQUAL equ 1Dh ; params in cmd; 8 param bytes
	; 7 result bytes


	; define the extra bits in some command codes

	CMD_MT equ 80h               ; Multi - track operation
	CMD_MF equ 40h               ; MFM recording mode
	CMD_SK equ 20h               ; skip deleted data mark



	; define the ST3 status bits

	ST3_WP equ 40h               ; NOT Write Protected
	ST3_TR00 equ 10h             ; Track 0 signal
	ST3_WP2 equ 08h              ; duplicate of ST3_WP; ST3_2S for 8" floppies
	ST3_HS equ 04h               ; head 0 or 1
	ST3_US equ 03h               ; Unit mask (0..3)


	; define the ST2 status bits

	ST2_CM equ 40h               ; Control Mark (deleted data mark)
	ST2_DD equ 20h               ; Data Error (data field)
	ST2_WC equ 10h               ; Wrong Cylinder
	ST2_SH equ 08h               ; Scan Hit (not used here)
	ST2_SN equ 04h               ; Scan Not Satisfied (not used here)
	ST2_BC equ 02h               ; Bad Cylinder
	ST2_MD equ 01h               ; Missing address mark

	ST2_ANY equ ST2_CM + ST2_DD + ST2_WC + ST2_BC + ST2_MD


	; define the ST1 status bits

	ST1_EN equ 80h               ; End of cylinder
	ST1_DE equ 20h               ; Data error (CRC err in address or data field)
	ST1_OR equ 10h               ; Overrun (we will always see this flag)
	ST1_ND equ 04h               ; No Data
	ST1_NW equ 02h               ; Not writeable (WP is set)
	ST1_MA equ 01h               ; Missing address mark

	; define the ST0 status bits

	ST0_IC equ 0C0h              ; Interrupt code mask
	; 00 = normal termination
	; 01 = abnormal termination
	; 10 = invalid command
	; 11 = abnormal termination - - change in ready status

	ST0_SE equ 20h               ; Seek end
	ST0_EC equ 10h               ; Equipment check
	ST0_NR equ 08h               ; Not Ready (always 0 on WD37C65B)
	ST0_HS equ 04h               ; Head Select
	;ST0_US equ 03h ; Unit select mask
	ST0_US equ 01h               ; Unit select mask

	ST0_ANY equ ST0_EC + ST0_NR  ; Any ST0 error



	; The FDC interrupt control register
	fdc_int_control equ PIC_I1CON


	; Standard int 13h stack frame layout is
	; created by: PUSHM ALL, DS, ES
	; MOV BP, SP
	;
	offset_DI equ 0
	offset_SI equ offset_DI + 2
	offset_BP equ offset_SI + 2
	offset_SP equ offset_BP + 2
	offset_BX equ offset_SP + 2
	offset_DX equ offset_BX + 2
	offset_CX equ offset_DX + 2
	offset_AX equ offset_CX + 2
	offset_DS equ offset_AX + 2
	offset_ES equ offset_DS + 2
	offset_IP equ offset_ES + 2
	offset_CS equ offset_IP + 2
	offset_FLAGS equ offset_CS + 2

	; The byte registers in the stack
	offset_AL equ offset_AX
	offset_AH equ offset_AX + 1
	offset_BL equ offset_BX
	offset_BH equ offset_BX + 1
	offset_CL equ offset_CX
	offset_CH equ offset_CX + 1
	offset_DL equ offset_DX
	offset_DH equ offset_DX + 1


	; FDC error codes (returned in AH)
	;
	ERR_no_error equ 0           ; no error (return Carry clear)
	; everything below returns with the Carry set to indicate an error
	ERR_invalid_command equ 1
	ERR_address_mark_not_found equ 2
	ERR_write_protect equ 3
	ERR_sector_not_found equ 4
	ERR_disk_removed equ 6
	ERR_dma_overrun equ 8
	ERR_dma_crossed_64k equ 9


	ERR_media_type_not_found equ 12 ; 0Ch
	ERR_uncorrectable_CRC_error equ 10h
	ERR_controller_failure equ 20h
	ERR_seek_failed equ 40h
	ERR_disk_timeout equ 80h

	ERR_81 equ 81h               ; fdc_ready_for_cmd, not rdy for input
	ERR_82 equ 82h               ; fdc_ready_for_result, not rdy for output
	ERR_83 equ 83h               ; input_result_from_fdc, after input, still busy
	ERR_84 equ 84h               ; fdc_wait_seek_done, abnormal ST0_IC code
	ERR_85 equ 85h               ; xfer_read_sector timeout
	ERR_86 equ 86h               ; cylinder requested is invalid for drive
	ERR_87 equ 87h               ; not on track 0 after recalibrate
	ERR_88 equ 88h               ; wait for operation complete to be posted
	ERR_89 equ 89h               ; fdc_ready_for_cmd, unexpectedly BUSY
	ERR_8A equ 8Ah               ; second "seek failed" error (ignore during Format)

	ERR_unknown equ 8Fh          ; ADDED - - JRC (may need to change)


	SEGMENT _TEXT
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; BIOS call entry for Floppy Disk driver
	; int 13h
	;
	; The Fixed Disk driver will move the vector from 13h to 40h
	; At the moment there is no Fixed Disk Driver
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global BIOS_call_13h
BIOS_call_13h:                ; Floppy driver entry
	sti                          ; Enable interrupts
	pushm all, ds, es            ; Standard register save
	mov bp, sp                   ; establish stack addressing

	cld                          ; may NOT assume direction flag is clear
	push bios_data_seg
	popm ds                      ; establish addressability for all functions
	mov byte [lock_count], 0     ; clear the lock counter

	%if SOFT_DEBUG & DUMP
	pushm ax, cx, dx, es

	push bx
	push es
	xor bh, bh
	mov bl, dl
	push bx
	mov bl, cl
	push bx
	mov bl, dh
	push bx
	mov bl, ch
	push bx
	mov bx, ax
	push bx
	push cs
	push rwvc
	call _cprintf
	add sp, 18

	popm ax, cx, dx, es
	xor bh, bh
	%endif
	mov bl, ah                   ; set to index into dispatch table
	cmp ah, max / 2
	jb .1
	mov bl, 14h                  ; fn not defined for Floppy diskette
.1: xor bh, bh
	shl bx, 1                    ; index words
	cs call near [dispatch + bx]

	; returns come here with AH set

	or ah, ah                    ; is return code 0? sets carry=0, too
	jz exit_pops
error_exit:
	stc
exit_pops:
	mov [bp + offset_AH], ah     ; store for return
	mov sp, bp                   ; remove any allocated variables
	%if SOFT_DEBUG & DUMP
	pushm f                      ;, ax, bx, cx, dx, es
	mov al, ah                   ; save AH in AL
	lahf                         ; get flags
	xor bh, bh                   ; Zap BH
	mov bl, [fdc_op_start + 1]
	push bx
	mov bl, [fdc_op_start]
	push bx
	mov bl, ah
	and bx, 1                    ; mask Carry
	push bx
	mov bl, al                   ; former AH
	push bx
	push cs                      ; far pointer to ...
	push fnret                   ; format
	call _cprintf
	add sp, 12
	popm f                       ;, ax, bx, cx, dx, es
	%endif
	popm all, ds, es
	retf 2                       ; return the carry



	;fn00 ; Reset Disk System
fn01:                         ; Get Disk System Status
	;fn02 ; Read Sector
	;fn03 ; Write Sector
	;fn04 ; Verify Sector
	;fn05: ; Format Track
fn06:                         ; Format Bad Track (fixed disk) [PC]
fn07:                         ; Format Drive (fixed disk) [PC]
	;fn08 ; Get Drive Parameters
fn09:
fn0A:
fn0B:
fn0C:
fn0D:
fn0E:
fn0F:
fn10:
fn11:
fn12:
fn13:
fn14:                         ; * * * fixed disk only * * *
	;fn15: ; Get Disk Type [AT]
	;fn16: ; Get Disk Change Status (floppy)
fn17:                         ; Set Disk Type (floppy)
	;fn18: ; Set Media Type for Format (floppy)
undefined:
	mov ah, ERR_invalid_command  ; equ 1
	ret


dispatch:
	dw fn00                      ; Reset Disk System
	dw fn01                      ;
	dw fn02
	dw fn03
	dw fn04
	dw fn05
	dw fn06
	dw fn07
	dw fn08
	dw fn09
	dw fn0A
	dw fn0B
	dw fn0C
	dw fn0D
	dw fn0E
	dw fn0F
	dw fn10
	dw fn11
	dw fn12
	dw fn13
	dw fn14
	dw fn15
	dw fn16
	dw fn17
	dw fn18
	max equ $ - dispatch


	;
	; Floppy Drive Types (fn08)
	;
	; We support:
	; 1 = 5.25" 360K 40track yes
	; 2 = 5.25" 1.2M 80track yes
	; 3 = 3.5" 720K 80track yes
	; 4 = 3.5" 1.44M 80track yes
	; 6 = 3.5" 2.88M 80track no (WD37C65CJM & 32Mhz osc)
	; 7 = 3.5" 1.28M 1024sect no (Japan)
	;
	; Floppy Combos
	; 5 = 5.25" 360K 40track in Drive Type 2 no
	; 8 = 5.25" 512k 77track / 128sector in Drv 2 (future) CP / M
	; 9 = 3.5" 256k 77track / 128sector in Drv 3 (future) CP / M
	; 10 = 3.5" 512k 77track / 128sector in Drv 4 (future) CP / M
	;;

D_table:
	dw 0
	dw DTAB1                     ; 360K (MFM)
	dw DTAB2                     ; 1.2M
	dw DTAB3                     ; 720K
	dw DTAB4                     ; 1.44M
	dw 0                         ; DTAB5
	dw 0                         ; DTAB6
	dw DTAB7                     ; 1024 byte sectors (Japan)
	dw DTAB8                     ; CP / M 26 / 77 in 1.2M drive (128 byte FM sectors)
	dw DTAB9                     ; CP / M 13 / 77 in 720K drive
	dw DTAB10                    ; CP / M 26 / 77 in 1.44M drive
	L_table equ ($ - D_table) / 2


	; Disk Information
	; specify off N R gp DTL gp3 fill unk on cyl clk
	;;; The DOS MFM floppies
	; 360K 5.25" DD floppy
DTAB1: db 0DFh, 2, 25h, 2, 9, 2Ah, 0FFh, 50h, 0F6h, 0Fh, 8, 39, 80h

	; 1.2M 5.25" HD floppy
DTAB2: db 0DFh, 2, 25h, 2, 15, 1Bh, 0FFh, 54h, 0F6h, 0Fh, 8, 79, 00h

	; 720K 3.5" or 5.25" DD floppy
DTAB3: db 0DFh, 2, 25h, 2, 9, 2Ah, 0FFh, 50h, 0F6h, 0Fh, 8, 79, 80h

	; 1.44M 3.5" HD floppy
DTAB4: db 0AFh, 2, 25h, 2, 18, 1Bh, 0FFh, 6Ch, 0F6h, 0Fh, 8, 79, 00h

	; 360K 5.25" DD floppy in 1.2M HD drive
DTAB5: db 0DFh, 2, 25h, 2, 9, 2Ah, 0FFh, 50h, 0F6h, 0Fh, 8, 39, 40h

	; 2.88M 3.5" XD floppy
DTAB6: db 0AFh, 2, 25h, 2, 36, 1Bh, 0FFh, 50h, 0F6h, 0Fh, 8, 79, 0C0h

	; 1.28M 3.5" HD floppy with 1K sectors (Japan)
DTAB7: db 0AFh, 2, 25h, 3, 8, 35h, 0FFh, 74h, 0F6h, 0Fh, 8, 79, 00h

	; specify off N R gp DTL gp3 fill unk on cyl clk
	;;; The CP / M FM floppies
	; 500K 5.25" CP / M (FM) floppy in 1.2M drive
DTAB8: db 0DFh, 2, 25h, 0, 26, 9, 80h, 35, 0E5h, 0Fh, 8, 76, 00h
	;;; 7h 1Bh

	; 250K 3.5" CP / M (FM) floppy in 720K drive
DTAB9: db 0DFh, 2, 25h, 0, 13, 19, 80h, 70, 0E5h, 0Fh, 8, 76, 80h

	; 500K 3.5" CP / M (FM) floppy in 1.44M drive
DTAB10: db 0AFh, 2, 25h, 0, 26, 21, 80h, 75, 0E5h, 0Fh, 8, 76, 00h


	; DTAB table offsets
	DTAB_specify equ 0
	DTAB_specify2 equ DTAB_specify + 1
	DTAB_turnoff_ticks equ DTAB_specify2 + 1
	DTAB_N_param equ DTAB_turnoff_ticks + 1
	DTAB_EOT_nsect equ DTAB_N_param + 1
	DTAB_rw_gap equ DTAB_EOT_nsect + 1
	DTAB_data_len equ DTAB_rw_gap + 1
	DTAB_fmt_gap3 equ DTAB_data_len + 1
	DTAB_fmt_fill equ DTAB_fmt_gap3 + 1
	DTAB_unknown equ DTAB_fmt_fill + 1
	DTAB_startup equ DTAB_unknown + 1 ; in 1 / 8 seconds
	DTAB_max_cylinder equ DTAB_startup + 1
	DTAB_control equ DTAB_max_cylinder + 1

	;
	; takes:
	; AL = contents of FDC_DATA (Data Register)
	;
put_data:
	push dx
	mov dx, FDC_DATA
	out dx, al
	pop dx
	ret

	;
	; Returns:
	; AL = contents of FDC_DATA (Data Register)
	;
get_data:
	push dx
	mov dx, FDC_DATA
	in al, dx
	pop dx
	ret
	;
	; Returns:
	; AL = contents of FDC_MSR (Main Status Register)
	;
get_msr:
	push dx
	mov dx, FDC_MSR
	in al, dx
	pop dx
	ret

	; delay for about 12 microseconds for MSR to be set
	extern microsecond
	global wait12
wait12:
	push cx
	%if 1
	; mov cx, 12 ; 12 microseconds
	xor ch, ch
	mov cl, [cpu_xtal]           ; 2x clock (32usec on 16Mhz CPU)
	shr cl, 1
	sub cx, 5                    ; fudge factor for overhead
	%else
	xor ch, ch
	mov cl, [wait12_count]
	%endif
	call microsecond
	pop cx
	ret
wait1000:
	push cx
	mov cx, 1000                 ; 1 ms delay
	call microsecond
	pop cx
	ret

	; FDC Operations Register operations
	; put out the LDOR write - only register
	; Assumes DS is BIOS data segment
	; Destroys AX and DX
out_LDOR_mem:

	%if SOFT_DEBUG & DUMP
	pushm f                      ;, ax, bx, cx, dx, es
	mov al, ah                   ; save AH in AL
	lahf                         ; get flags
	xor bh, bh                   ; Zap BH
	mov bl, [fdc_motor_LDOR]
	push bx
	push cs                      ; far pointer to ...
	push fnldor                  ; format
	call _cprintf
	add sp, 6
	popm f                       ;, ax, bx, cx, dx, es
	%endif


	mov al, [fdc_motor_LDOR]
	mov dx, FDC_LDOR
	out dx, al
	ret


	;__CHECKINT__________________________________________________________________________________________________________________________
	;
	; CHECK FOR ACTIVE FDC INTERRUPTS BEFORE GIVING I8272 COMMANDS
	; POLL RQM FOR WHEN NOT BUSY AND THEN SEND FDC
	; SENSE INTERRUPT COMMAND. IF IT RTSURNS WITH NON ZERO
	; ERROR CODE, PASS BACK TO JSRING ROUTINE FOR HANDLING
	;________________________________________________________________________________________________________________________________
	;
CHECKINT:
	push cx

	mov cx, 0F100h                  ; setup to allow timeout
.1:
	call get_msr
	test al, RQM
	jnz .2                       ; WAIT FOR RQM TO BE TRUE. WAIT UNTIL DONE
	call wait12
	loop .1
	jmp ERRCLR
.2:
	call get_msr
	test al, 040h                ; WAITING FOR INPUT?
	jnz .3
	call SENDINT
.3:
	okay
	pop cx
	ret

ERRCLR:
	mov cx, 0F100h                 ; setup to allow timeout
.1:
	call get_data
	call get_msr
	test al, RQM
	jnz .2                       ; WAIT FOR RQM TO BE TRUE. WAIT UNTIL DONE
	call wait12
	loop .1
.2:
	error
	pop cx
	ret



	;__SENDINT__________________________________________________________________________________________________________________________
	;
	; SENSE INTERRUPT COMMAND
	;________________________________________________________________________________________________________________________________
	;
SENDINT:
	mov al, CMD_SENSE_DRIVE_STATUS ; SENSE INTERRUPT COMMAND
	call PFDATA                  ; SEND IT
	call wait12
	call GFDATA                  ; GET RESULTS
	mov [fdc_ctrl_status], al    ; STORE THAT
	and al, 0C0h                 ; MASK OFF INTERRUPT STATUS BITS
	cmp al, 80h                  ; CHECK IF INVALID COMMAND
	jz .1                        ; YES, EXIT
	call GFDATA                  ; GET ANOTHER (STATUS CODE 1)
	mov al, [fdc_ctrl_status]    ; GET FIRST ONE
	and al, 0C0h                 ; MASK OFF ALL BUT INTERRUPT CODE 00 IS NORMAL
.1:
	ret


	;__GFDATA__________________________________________________________________________________________________________________________
	;
	; GET DATA FROM FLOPPY CONTROLLER
	;
	; TRANSFERS ARE SYNCHONIZED BYT MSR D7 <RQM> AND D6 <DIO>
	; RQM DIO
	; 0 0 BUSY
	; 1 0 WRITE TO DATA REGISTER PERMITTED
	; 1 1 BYTE FOR READ BY HOST PENDING
	; 0 1 BUSY
	;
	;________________________________________________________________________________________________________________________________
	;
GFDATA:
	mov cx, 0F100h
.1:
	call get_msr                 ; GET STATUS
	test al, RQM
	loopz .1                    ; NOT READY, WAIT
	jnz .3                       ; ok, continue
.2:

	%if SOFT_DEBUG & DUMP
	pushm f                      ;, ax, bx, cx, dx, es
	mov al, ah                   ; save AH in AL
	lahf                         ; get flags
	push cx
	push ax
	push cs                      ; far pointer to ...
	push fngferr                 ; format
	call _cprintf
	add sp, 8
	popm f                       ;, ax, bx, cx, dx, es
	%endif

	mov al, 0FFh                 ; timeout
	ret
.3:
	test al, DIO                 ; ANY DATA FOR US?
	jz .2                        ; NO, SKIP IT
	call get_data
	ret

	;__PFDATA__________________________________________________________________________________________________________________________
	;
	; WRITE A COMMAND OR PARAMETER SEQUENCE
	;
	; TRANSFERS ARE SYNCHONIZED BY MSR D7 <RQM> AND D6 <DIO>
	; RQM DIO
	; 0 0 BUSY
	; 1 0 WRITE TO DATA REGISTER PERMITTED
	; 1 1 BYTE FOR READ BY HOST PENDING
	; 0 1 BUSY
	;
	;________________________________________________________________________________________________________________________________
	;
PFDATA:
	mov ah, al                   ; SAVE DATA BYTE
	mov cx, 0F100h                ; set timeout
.1:
	call get_msr                 ; READ FDC STATUS
	test al, RQM
	loopz .1
	jnz .2


	%if SOFT_DEBUG & DUMP
	pushm f                      ;, ax, bx, cx, dx, es
	mov al, ah                   ; save AH in AL
	lahf                         ; get flags
	mov bx, ax
	push bx
	push cs                      ; far pointer to ...
	push fnpferr                 ; format
	call _cprintf
	add sp, 6
	popm f                       ;, ax, bx, cx, dx, es
	%endif


	mov al, 0FFh
	ret
.2:
	test al, DIO                 ; TEST DIO BIT
	jnz .3                       ; FDC IS OUT OF SYNC
	mov al, ah                   ; RESTORE DATA
	call put_data                ; WRITE TO FDC
	call wait12
	ret
.3:                           ; FDC IS OUT OF SYNC CLEAR IT OUT AND RE - TRY
	call get_data                ; READ DATA REGISTER
	JP .1                        ; AND CONTINUE

	;__PFDATAS_________________________________________________________________________________________________________________________
	;
	; WRITE A COMMAND OR PARAMETER SEQUENCE (NO PAUSE)
	;
	; TRANSFERS ARE SYNCHONIZED BY MSR D7 <RQM> AND D6 <DIO>
	; RQM DIO
	; 0 0 BUSY
	; 1 0 WRITE TO DATA REGISTER PERMITTED
	; 1 1 BYTE FOR READ BY HOST PENDING
	; 0 1 BUSY
	;
	;________________________________________________________________________________________________________________________________
	;
PFDATAS:
	mov ah, al                   ; SAVE DATA BYTE
	mov cx, 0100h                ; set timeout
.1:
	call get_msr                 ; READ FDC STATUS
	test al, RQM
	loopz .1
	jnz .2
	mov al, 0FFh
	ret
.2:
	test al, DIO                 ; TEST DIO BIT
	jnz .3                       ; FDC IS OUT OF SYNC
	mov ah, al                   ; RESTORE DATA
	call put_data                ; WRITE TO FDC
	ret
.3:                           ; FDC IS OUT OF SYNC CLEAR IT OUT AND RE - TRY
	call get_data                ; READ DATA REGISTER
	JP .1                        ; AND CONTINUE


	global fdc_timer_hook
	; called from Timer Tick code with DS - >BIOS data area
	; Destroys AX and DX
	global fdc_timer_hook
fdc_timer_hook:
	cmp byte [fdc_motor_ticks], 0
	je .9
	dec byte [fdc_motor_ticks]
	jnz .9
	; timer expired, stop the motors
	and byte [fdc_motor_LDOR], ~( MOEN_MASK )
	call out_LDOR_mem
.9: ret


	;
	; power on init
	;
	global @floppy_init
@floppy_init:
	mov ah, 0                    ; fn00
	int 13h
	ret


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Function 00h Reset the Disk System
	; Used both at power on and after a serious error
	;
	; Enter with:
	; AH = 00h
	; DL = drive 0 or 1
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn00:

	mov byte [wait12_count], 32  ; this is about the max.
	call wait12                  ; wait 12 microseconds
	call get_msr                 ; set BASE mode
	call wait12                  ; wait 12 microseconds

	mov byte [fdc_motor_LDOR], (MODE + RESET + DMAEN) ; set PC_AT mode
	call out_LDOR_mem
	call wait12

	%if 1
	;;; This read may not be necessary, unless Special Mode is set
	mov dx, FDC_LDCR
	in al, dx                    ; read a write - only register to latch Mode
	;;;;;
	%endif
	call wait1000

	or byte [fdc_motor_LDOR], (MODE + NO_RESET + DMAEN) ; remove the RESET
	call out_LDOR_mem
	call wait12

	%if 0
	mov dx, FDC_LDCR
	mov al, FDC_HD               ; set for HD disks
	out dx, al
	%endif

	xor ax, ax
	mov [fdc_motor_ticks], al    ; Zero the timer tick counter
	mov [fdc_last_rate], al      ; force a specify command

	mov es, ax
	cnop
	es mov [1Eh * 4], ax
	es mov [1Eh * 4 + 2], ax     ; Zap the parameter pointer

	mov word [fdc_cylinder], - 1 ; Specify & Recalibration needed

	; now allow time for the polling interrupts
	mov cx, 102400>>16           ; 0.1 seconds
	xor dx, dx                   ; CX:DX is delay in usec
	mov ah, 86h                  ; delay in microseconds
	int 15h

	Okay                         ; signal good execution
	ret                          ; end of FN00

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Function 08h Get Drive Parameters
	;
	; Enter with:
	; AH = 08h
	; DL = drive 0 or 1
	;
	; Return with:
	; Carry clear if no error
	; BL = drive type (2 or 4 for us)
	; CH = max cylinder number
	; CL = max sector number
	; DH = max head number
	; DL = number of drives
	; ES:DI = address of disk parameter table
	;
	; Carry set on error
	; AH = error code
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn08:                         ; Get Drive Parameters
	mov al, [equipment_flag]
	mov ah, 1
	and ah, al                   ; any floppies at all?
	jz .2
	rol al, 2                    ; at least one
	and al, 3
	add ah, al                   ; 1..4
.2:
	mov [offset_DL + bp], ah     ; return # of drives
	call check_DL
	jc .err_no_drive
	call get_disk_type
	mov [offset_BL + bp], al     ; return BL = disk type
	call get_media
	cs mov ah, [DTAB_max_cylinder + bx]
	cs mov al, [DTAB_EOT_nsect + bx]
	mov [offset_CX + bp], ax     ; return CYL | SECT in CX
	mov byte [offset_DH + bp], 1 ; head max. always 1
	mov [offset_ES + bp], cs     ; return ES param table
	mov [offset_DI + bp], bx     ; return DI param table

	xor ah, ah                   ; no error
	ret

.err_no_drive:
	mov ah, ERR_invalid_command  ; error if no floppies
	ret                          ; DL is still zero !!!






	%if 0
	; validate the READ / WRITE CHS, SC parameters
	; Enter with DI pointing at the type table
	;
	; Carry clear if okay
	; Carry set if invalid
	; AX & all other registers are preserved
validate_call:
	push ax

	cs cmp ch, [DTAB_max_cyl + di]
	jnbe .7
	cs mov ah, [DI_heads + di]
	sub ah, dh
	jbe .7
	cs mov al, [DTAB_EOT_nsect + di]
	dec cl                       ; base sectors at 0
	cmp cl, al
	jnc .6                       ; JNC = JNB = JAE
	mul ah
	; AX is 1 or 2 * sectors
	sub al, cl
	; AL is the maximum number of sectors we can transfer
	cmp al, [offset_AX + bp]     ; compare to sector count
.6: inc cl                    ; back to sectors from 1
	jnc .8                       ; JAE = JNB = JNC
.7: stc
.8: pop ax                    ;
	ret
	%endif



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Function 02h Read Sectors
	; Function 03h Write Sectors
	; Function 04h Verify Sectors
	;
	; Enter with:
	; AH = 02h (read)
	; AH = 03h (write)
	; AH = 04h (verify)
	; AL = number of sectors to transfer
	; CH = cylinder number
	; CL = sector number
	; DH = head number
	; DL = drive 0 or 1
	; ES:BX = buffer to read into or write from
	;
	; Return with:
	; Carry clear if no error
	; AH = 0
	; AL = number of sectors transferred
	;
	; Carry set on error
	; AH = error code
	;
	; All other registers are preserved.
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	; Stack variables
	;
	rwv_return equ - 2           ; offset from BP
	rwv_dma equ rwv_return - 2
	rwv_xfer equ rwv_dma - 2
	rwv_cmd equ rwv_xfer - 9
	rwv_AL equ rwv_cmd - 1
	rwv_stack equ - rwv_AL

fn02:                         ; READ
	mov ah, (CMD_READ_DATA | CMD_MT | CMD_MF | CMD_SK)
	mov bx, xfer_read_sector
	jmp rwv_common

	%define EXTRA 0
fn03:                         ; WRITE
	%if EXTRA
	cmp al, 1
	jbe .10

	mov bx, [offset_BX + bp]     ; restore BX
	mov [offset_AH + bp], al     ; use return code as counter

.1: mov ax, 0301h             ; write 1 sector
	int 13h
	jc .5

	inc cl                       ; increment sector number
	add bx, 200h                 ; increment transfer address
	dec byte [offset_AH + bp]
	jnz .1

	Okay                         ; all went Okay
	ret

	; process error return
	; AH = error code
.5: mov al, [offset_AL + bp]  ; sectors requested
	sub al, [offset_AH + bp]     ; sectors remaining
	mov [offset_AL + bp], al     ; set sectors transferred
	Error
	ret

.10:
	%endif
	mov ah, (CMD_WRITE_DATA | CMD_MT | CMD_MF)
	mov bx, xfer_write_sector
	jmp rwv_common

fn04:                         ; VERIFY
	mov ah, (CMD_READ_DATA | CMD_MT | CMD_MF | CMD_SK)
	mov bx, xfer_verify_sector
	;;; jmp rwv_common

	; Common code to READ, WRITE, and VERIFY
rwv_common:
	push di                      ; dma control register
	push bx                      ; transfer function
	sub sp, rwv_stack - 8        ; 4 words in stack by pushes or Call
	push ax                      ; including this push

	call check_DL                ; sets DI
	mov ah, ERR_invalid_command
	jc .exit

	call get_disk_type
	call get_media               ; get media pointer to CS:BX
	call set_media_pointer       ; set up Int 1Eh
	call motor_on                ; use DI to start motor
	call Seek                    ; use CH to seek to track
	; recalibrate is possible
	jc .exit                     ; AH is error code

	call make_head_unit          ; AL is next byte

	pushm es, ds, di
	lea di, [rwv_cmd + 1 + bp]   ; SS override not needed
	lea si, [DTAB_N_param + bx]
	pushm cs, ss
	popm ds, es
	stosb                        ; store head unit in cmd stream
	mov al, ch                   ; cylinder
	stosb
	mov al, dh                   ; head
	stosb
	mov al, cl                   ; sector (R)
	stosb
	lodsb                        ; get N
	mov cl, al
	stosb                        ; store N
	movsb                        ; EOT
	movsb                        ; GPL
	movsb                        ; DTL = FF
	lea si, [rwv_cmd + bp]       ; get command start
	popm es, ds, di

	mov ax, 128                  ; minimum sector size
	mul byte [rwv_AL + bp]       ; times number of sectors to transfer
	shl ax, cl                   ; shift by N_param
	mov cx, ax                   ; CX is byte count of transfer

	pushm bx                     ; save DTAB pointer

	mov ax, [offset_BX + bp]     ; get Xfer address offset
	mov bx, es                   ; segment to AX
	mov dx, bx                   ; and to DX
	shr bx, 12                   ; high 4 bits of address
	shl dx, 4                    ; high part of offset from segment
	add ax, dx                   ; form low 16 bits of 20 - bit address
	adc bx, 0                    ; and carry into the high bits

	mov dx, ss                   ; DX:SI points at command start

.marker:
	; BX:AX transfer 20 - bit address in memory
	; CX transfer byte count
	; DX:SI pointer to 9 - byte FDC command
	;
	and byte [fdc_drv_calib], 00h ;POST no interrupts received

	call near [rwv_xfer + bp]    ;call specific transfer function


	%if SOFT_DEBUG
	pushm ax, dx
	mov dx, FRONT_PANEL_LED
	mov al, 09h
	out dx, al
	popm ax, dx
	%endif


	popm bx                      ; restor DTAB pointer (CS:BX)
	;;; jc .exit ; AH is set to error code

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; call Check_RW_Status ; get final return code

.exit:
	lea sp, [rwv_return + bp]
	ret

	%if SOFT_DEBUG
	end_rwv equ $
	%endif



	; Format stack layout
	fmt_return equ - 2           ; return from fn05 call
	fmt_dma equ fmt_return - 2
	fmt_cmd equ fmt_dma - 6
	fmt_stack equ - fmt_cmd      ; stack size

	%if fmt_dma != rwv_dma
	%error "fmt_dma != rwv_dma"
	%endif

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Function 05h Format a Track
	;
	; Precede with call to Function 18h (or 17h) to set the disk type
	;
	; Enter with:
	; AH = 05h
	; CH = cylinder number
	; DH = head number
	; DL = drive 0 or 1
	; ES:BX = segment / offset of address field list (C / H / R / N)
	;
	; Return with:
	; Carry clear if no error
	; AH = 0
	;
	; Carry set on error
	; AH = error code
	;
	; All other registers are preserved.
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn05:
	sub sp, fmt_stack            ; allocate stack space

	call check_DL                ; sets DI
	mov ah, ERR_invalid_command
	jc .exit

	pushm es                     ; save ES
	push 0
	popm es
	mov bx, cs                   ; get CS segment
	es cmp bx, [1Eh * 4 + 2]     ; check segment is CS
	jne .exit                    ; (will restore stack)

	es mov bx, [1Eh * 4]         ; get CS:BX as disk param table pointer
	popm es                      ; restore Stack

	call motor_on                ; use DI to start motor

	call Seek                    ; use CH to seek to track
	; recalibrate is possible
	jc .exit                     ; AH is error code

	call make_head_unit          ; AL is next byte
	mov ah, al                   ; save head / unit in AH

	pushm es, ds, di

	pushm cs, ss
	popm ds, es
	lea di, [bp + fmt_cmd]
	lea si, [bx + DTAB_N_param]

	mov al, CMD_FORMAT_A_TRACK
	cmp byte [si], 0             ; is N==0
	je .2
	or al, CMD_MF                ; MFM recording
.2:
	stosw                        ; AH=head / unit, AL=format cmd
	movsb                        ; set N
	lodsb                        ; get SC
	mov cl, al                   ; save SC in AL
	stosb                        ; set SC
	add si, 2                    ; advance to GPL3
	movsw                        ; set GPL3 and Fill

	lea si, [bp + fmt_cmd]
	popm es, ds, di              ; restore regs

	xor ch, ch                   ; CX = sector count
	shl cx, 2                    ; CX = byte count of param table

	pushm bx                     ; save DTAB pointer

	mov ax, [offset_BX + bp]     ; get Xfer address offset
	mov bx, es                   ; segment to AX
	mov dx, bx                   ; and to DX
	shr bx, 12                   ; high 4 bits of address
	shl dx, 4                    ; high part of offset from segment
	add ax, dx                   ; form low 16 bits of 20 - bit address
	adc bx, 0                    ; and carry into the high bits

	mov dx, ss                   ; DX:SI points at command start

	;.marker:
	; BX:AX transfer 20 - bit address in memory
	; CX transfer byte count
	; DX:SI pointer to 9 - byte FDC command
	;
	and byte [fdc_drv_calib], 00h ;POST no interrupts received

	call xfer_format_track       ; format the track

	popm bx                      ; restor DTAB pointer (CS:BX)
	;;; jc .exit ; AH is set to error code

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;call Check_RW_Status ; get final return code


.exit:
	lea sp, [rwv_return + bp]    ; restore stack location
	ret

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Function 15h Get Disk Type
	;
	; Enter with:
	; AH = 15h
	; DL = drive 0 or 1
	;
	; Return with:
	; Carry clear if no error
	; AH = drive type code
	; 0 = no drive present
	; 1 = floppy without change line support
	; 2 = floppy with change line support
	; 3 = fixed disk
	;
	; Carry set on error
	; AH = error code
	;
	; All other registers are preserved.
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn15:
	xor ah, ah                   ; No drive present
	call check_DL
	jnc .ok
	cmp di, - 1
	je undefined                 ; DL is really bad
	ret                          ; AH=0, no drive present
	; carry will be cleared
.ok:
	inc ah                       ; drive ok, no change line support
	clc
	jmp exit_pops                ;



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Function 16h Get Disk Change Status
	;
	; Enter with:
	; AH = 16h
	; DL = drive 0 or 1
	;
	; Return with:
	; Carry clear
	; AH = 0 disk not changed
	;
	; Carry set
	; AH = 6 disk has been changed
	; 0 error
	;
	; All other registers are preserved.
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn16:
	call check_DL
	jc undefined

	mov ax, di                   ; AL = 0, 1 AH = 0
	; AH is now 0
	inc al                       ; AL = 1, 2
	rol al, 4                    ; AL = MOEN1 or MOEN2
	test [fdc_motor_LDOR], al    ; test if motor running
	jnz .on

	mov ah, ERR_disk_removed     ; signal disk changed
.on:
	ret                          ; AH=6, Carry will be set



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Function 17h Set Disk Type for Format (PC - AT)
	;
	; Enter with:
	; AH = 17h
	; AL = 00h not used
	; 01h 160, 180, 320, or 360Kb diskette in 360kb drive
	; 02h 360Kb diskette in 1.2Mb drive
	; 03h 1.2Mb diskette in 1.2Mb drive
	; 04h 720Kb diskette in 720Kb drive
	; DL = drive number
	;
	; Return with:
	; AH = 0 success
	; Carry clear
	;
	; Carry set error
	; AH = error code
	;
	; note 1) This function is probably enhanced for the PS / 2 series to detect
	; 1.44 in 1.44 and 720k in 1.44.
	; 2) This function is not supported for floppy disks on the PC or XT.
	; 3) If the change line is active for the specified drive, it is reset.
	; 4) The BIOS sets the data rate for the specified drive and media type.
	; The rate is 250k / sec for double - density media and 500k / sec for high
	; density media. The proper hardware is required.
	; 5) This function is used by DOS <= 3.1
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;fn17:
	;;; ret



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Function 18h Set Media Type For Format (diskette) (AT, XT2, XT / 286, PS / 2)
	;
	; Enter with:
	; AH = 18h
	; CH = max. cylinder number (80 or 40 minus 1)
	; CL = number of sectors (9, 15, 18)
	; DL = drive number
	;
	; Return with:
	; Carry clear - - no errors
	; AH = 00h if requested combination supported
	; ES:DI pointer to 13 - byte parameter table
	;
	; Carry set - - error
	; AH = 01h if function not available
	; 0Ch if not suppported or drive type unknown
	; 80h if there is no media in the drive
	;
	; note 1) A floppy disk must be present in the drive.
	; 2) This function should be called prior to formatting a disk with Int 13h
	; Fn 05h so the BIOS can set the correct data rate for the media.
	; 3) If the change line is active for the specified drive, it is reset.
	; 4) This function is used by DOS >= 3.2
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn18:
	call check_DL                ; check validity of drive no.
	jc undefined

	call get_disk_type           ; get disk type to AL
	cmp al, L_table
	jnb .alt
	mov bl, al
	xor bh, bh
	shl bx, 1
	cs mov bx, [D_table + bx]    ; get offset of DTAB entry
	test bx, bx
	jz .errC
	cs cmp [DTAB_EOT_nsect + bx], cl ; check number of sectors
	jne .alt                     ; try alternate
	cs cmp [DTAB_max_cylinder + bx], ch ; check number of cylinders
	jne .alt
.found:
	call set_media_pointer
	mov [offset_DI + bp], bx
	mov [offset_ES + bp], cs     ; return in ES:DI
	xor ah, ah
	ret

.alt:
	call get_disk_alt_type       ; get disk type to AL
	cmp al, L_table
	jnb .errC
	mov bl, al
	xor bh, bh
	shl bx, 1
	cs mov bx, [D_table + bx]    ; get offset of DTAB entry
	test bx, bx
	jz .errC
	cs cmp [DTAB_EOT_nsect + bx], cl ; check number of sectors
	jne .errC                    ; no match?
	cs cmp [DTAB_max_cylinder + bx], ch ; check number of cylinders
	je .found

.errC: mov ah, ERR_media_type_not_found
	ret





	check cpu_xtal - 0FFh


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; check_DL - - check for valid disk #
	;
	; Return:
	; DI = 0 or 1 if DL is valid floppy
	; Carry clear
	;
	; DI not valid if DL is invalid
	; Carry set
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_DL:
	mov di, - 1                  ; invalid DI
	cmp dl, FLOPPY_MAX
	jnb .err
	mov di, dx
	and di, FLOPPY_MAX - 1       ; clear the carry
	test byte [fdc_type + di], 0Fh ; drive present?
	jz .err
	ret                          ; carry is clear

.err: stc
	ret


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; get_disk_type
	;
	; Enter with:
	; DI = drive no.
	;
	; Return with:
	; AL = drive type (0..4)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_disk_type:
	mov al, [fdc_type + di]      ; get type byte
	and al, 0Fh                  ; mask low nibble
	ret

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; get_disk_alt_type
	;
	; Enter with:
	; DI = drive no.
	;
	; Return with:
	; AL = drive type (0..4)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_disk_alt_type:
	mov al, [fdc_type + di]      ; get type byte
	shr al, 4
	ret


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; get_media
	;
	; Call with:
	; AL = disk type
	;
	; Return with:
	; CS:BX pointer to 13 - byte disk media table
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_media:
	mov bl, al
	xor bh, bh
	shl bx, 1
	cs mov bx, [D_table + bx]    ; get offset of DTAB entry
	ret



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; set_media_pointer
	;
	; Call with:
	; CS:BX pointer to 13 - byte disk media table
	; DS BIOS data area pointer
	;
	; Return with:
	; CS:BX pointer to 13 - byte disk media table
	; Int 1Eh floppy media pointer set
	;
	; Carry Set = new media pointer (needed Specify command)
	; Carry Clear = same media pointer (Specify not needed)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_media_pointer:
	pushm cx, es                 ; save for later
	push 0                       ; address interrupt vectors
	pop es                       ; * *
	mov cx, cs
	es cmp word [1Eh * 4], bx
	jne .diff
	es cmp word [1Eh * 4 + 2], cx ; segment
	clc
	jz .same
.diff:
	es mov word [1Eh * 4], bx    ; offset
	es mov word [1Eh * 4 + 2], cx ; segment
	mov es, cx
	cnop
	call Specify                 ; ES:BX is table pointer
	stc
.same:
	popm cx, es                  ; restore DS
	ret



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Specify issue specify command to FDC
	;
	; Call with:
	; ES:BX pointer to 13 - byte disk table
	; DS BIOS data area pointer
	;
	; Return with:
	; Nothing
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Specify:
	pushm ax, bx, dx, si
	call CHECKINT                ;
	mov al, CMD_SPECIFY          ; SPECIFY COMMAND
	call PFDATA                  ; OUTPUT TO FDC
	mov al, 7Fh                  ; 6 MS STEP, 480 MS HEAD UNLOAD
	call PFDATA                  ; OUTPUT TO FDC
	mov al, 05h                  ; 508 MS HEAD LOAD, NON - DMA MODE
	call PFDATA                  ; OUTPUT TO FDC

	call CHECKINT                ; SEND SEVERAL INTERRUPTS TO ENSURE PROPER STATE
	call CHECKINT                ;
	call CHECKINT                ;
	call CHECKINT                ;
	call CHECKINT                ;
	call CHECKINT                ;
	popm ax, bx, dx, si
	ret




	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; motor_on Start the drive motor & wait
	;
	; Call with:
	; DI = drive to start (0, 1)
	; CS:BX = drive parameter table pointer
	;
	; Return with:
	; motor is running and startup delay has been taken
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global motor_on
motor_on:
	pushm ax, cx, dx
	mov ax, di                   ; drive # to AL
	add al, MOEN1>>4             ; form MOENx >> 4
	shl al, 4                    ; form MOENx bitmask
	mov ah, al                   ; MOENx - > AH
	add ax, di                   ; MOENx + DSELx - > AL

	mov cl, 36                  ;2 seconds
	mov byte [fdc_motor_ticks], cl ; set long timer = 2 seconds

	test byte [fdc_motor_LDOR], ah ; motor already on?
	mov ch, al
	jnz .its_on

	; motor is not running
	cs mov ax, [DTAB_startup + bx] ; get startup delay in 1 / 8 seconds
	cbw
	imul ax, 125                 ; * 125 ms
	mov dl, 54
	div dl                       ; divided by 54ms / tick
	inc ax                       ; one more tick for good measure
	sub cl, al                   ; CL is tick to wait for

	; if motor was already running, then CL has not been changed
	; Do the select
.its_on:
	xor ch, [fdc_motor_LDOR]     ; set selected bits
	and ch, (MOEN_MASK | DSEL_MASK)
	xor [fdc_motor_LDOR], ch
	call out_LDOR_mem            ; Motor Starts here, or continues

.wait: cmp [fdc_motor_ticks], cl ; has tick counter expired?
	ja .wait - 1

	; reduce timer to turn - off delay time
	cs mov cl, [DTAB_turnoff_ticks + bx] ; 2 seconds
	mov [fdc_motor_ticks], cl

	popm ax, cx, dx
	ret


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; make_head_unit
	;
	; Enter with:
	; DH = head number
	; DI = unit number
	;
	; Return with:
	; AL = 0000 0huu
	; Carry clear
	;
	; Carry is set on error
	;
	; Assumes "motor_on" has done the real unit select in the LDOR (operations register)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
make_head_unit:
	mov al, dh                   ; head number to AL
	test al, ~1                  ; check for head 0 or 1
	stc                          ; set to signal error
	jnz .err
	and al, 1                    ; defensive programming
	shl al, 2                    ; shift H to position
	or ax, di                    ; clear the carry
.err: ret

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; xfer_read_sector
	;
	; Call with:
	; BX:AX transfer address in memory
	; CX transfer byte count
	; DX:SI pointer to 9 - byte FDC command
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
xfer_read_sector:
	pushm bx, cx, dx, si, ds, es

	; push cx
	; mov cx, 9 ; 9 - byte FDC command
	; call output_cmd_to_fdc
	; pop cx

	; mov si, ax
	; mov es, bx ; DS:SI is now the destination

	;.1:
	; call get_msr ; get status
	;
	; test al, 0b10000000
	; jnz .1 ; FDC IS NOT READY, WAIT FOR IT
	;
	; test al, 0b00100000
	; jz .timeout ; EXECUTION MODE? NO, ERROR
	;
	; call get_data
	; es mov al, [si + 1] ; record byte of data
	; loop .1
	;
	; mov dx, FDC_TC
	; in al, dx
	Okay
	jmp .99

.timeout:
	mov ah, ERR_85
	Error
.99:
	popm bx, cx, dx, si, ds, es
	ret



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; xfer_write_sector
	; xfer_format_track (only command count is different)
	;
	; Call with:
	; BX:AX transfer address in memory
	; CX transfer byte count
	; DX:SI pointer to 9 - byte FDC command
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
xfer_format_track:
xfer_write_sector:
	; push dx

	; ; BX:AX is the transfer source address
	; mov dx, DMA0 + DMASPL ; set low source address
	; call dma_outd

	; xor bx, bx
	; mov ax, FDC_DACK

	; ; BX:AX is the transfer destination port
	; mov dx, DMA0 + DMADPL ; set low destination port
	; call dma_outd

	; mov ax, cx ; total byte count
	; out dx, ax ; set terminal count

	; mov ax, [rwv_dma + bp] ; get Control register
	; mov dx, DMA0 + DMACW
	; out dx, ax ; starts the DMA

	; pop dx ; reset DX:SI command pointer
	;
	; mov cx, 9 ; 9 - byte FDC command
	; ss test byte [si], 01000b ; test for FORMAT command
	; jz .4
	; mov cx, 6 ; it is FORMAT
	;.4:
	; call output_cmd_to_fdc


	; mov bx, DMA0 + DMADPL ; Destination to be updated
	; mov cx, FDC_DACK_TC

	; jmp xfer_common_wait


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; xfer_verify_sector
	;
	; Call with:
	; BX:AX transfer address in memory
	; CX transfer byte count
	; DX:SI pointer to 9 - byte FDC command
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
xfer_verify_sector:
	; push dx
	;
	; xor bx, bx ; BX:AX is transfer address
	; mov ax, (bios_data_seg<<4) + fdc_ctrl_status
	;
	; ; BX:AX is the transfer destination address
	; mov dx, DMA0 + DMADPL ; set low destination
	; call dma_outd
	;
	; mov ax, cx ; total byte count
	; out dx, ax ; set terminal count
	;
	; xor bx, bx
	; mov ax, FDC_DACK
	; ; BX:AX is the transfer source port
	; mov dx, DMA0 + DMASPL ; set low source pointer
	; call dma_outd
	;
	; mov ax, [rwv_dma + bp] ; get Control register
	; mov dx, DMA0 + DMACW
	; out dx, ax ; starts the DMA
	;
	; pop dx ; reset DX:SI command pointer
	;
	; mov cx, 9 ; 9 - byte FDC command
	; call output_cmd_to_fdc
	;
	;
	; mov bx, DMA0 + DMASPL
	; mov cx, FDC_DACK_TC
	;
	; jmp xfer_common_wait




	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; recalibrate
	;
	; Enter with:
	; DI = drive number
	; CS:BX = parameter area pointer
	; DS = BIOS data area pointer
	;
	; Return with:
	; Carry = 0 - - okay
	;
	; Carry = 1 - - error
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
recalibrate:
	pushm cx, dx, si
	;

	%if SOFT_DEBUG & DUMP
	pushm f                      ;, ax, bx, cx, dx, es
	mov al, ah                   ; save AH in AL
	lahf                         ; get flags
	mov bh, ch
	mov bl, [fdc_cylinder + di]
	push bx
	push cs                      ; far pointer to ...
	push fnrecal                 ; format
	call _cprintf
	add sp, 6
	popm f                       ;, ax, bx, cx, dx, es
	%endif

	call CHECKINT
	jc .9

	call motor_on
	mov al, CMD_RECALIBRATE      ; RECAL TO TRACK 0
	call PFDATA                  ; SEND IT
	mov al, ST0_US               ; mask to 2 drives
	and ax, di                   ; unit number to AL
	call PFDATA                  ; SEND THAT TOO
	;
	mov cx, 0F100h                 ;setup timeout
.1:
	call wait12
	call CHECKINT
	call get_msr                 ; READ SEEK STATUS
	test al, 0fh                 ; ANY DRIVES SEEKING?
	loopnz .1                    ; YES, WAIT FOR THEM
	jnz .9

	mov byte [fdc_cylinder + di], 0 ; set new cylinder number
.7:
	Okay                         ;
	popm cx, dx, si              ; restore
	ret
.9:
	Error                        ; signal error
	popm cx, dx, si              ; restore
	ret

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Seek seek to proper cylinder
	;
	; Call with:
	; CH = cylinder to which to position heads
	; CS:BX = disk parameter area
	; DI = unit number
	; DS = BIOS data area pointer
	;
	; Return with:
	; Carry = 0 success
	;
	; Carry = 1 error
	;
	; Assumes "motor_on" has done the real unit select in the LDOR (operations register)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Seek:
	pushm cx, dx, si

;	cmp ch,00h
;	je .dorecal

	; check for a recalibration needed
;	mov al, [fdc_cylinder + di]  ; get present cylinder (0FFh forces recalibrate)
;	cmp al,0FFh
;	je .dorecal

;	jmp .no_recal

;.dorecal
;	mov si, 2                    ; two recalibrates max.

;.rerecal:
;	call recalibrate
;	jnc .no_recal
;	dec si
;	Error
;	jz .exit                     ; two have failed
;	jmp .rerecal                 ; try again

;.no_recal:
;
;	cmp ch, [fdc_cylinder + di]  ; sought : present cylinder
;	je .okay

	; we are not on the cylinder we want

	;cs cmp ch, [DTAB_max_cylinder + bx] ; validate cylinder number
	;ja .invalid

;.valid:
	; ANY INTERUPT PENDING
	; IF YES FIND OUT WHY / CLEAR
	mov [fdc_cylinder + di], ch  ; set new cylinder number

	call CHECKINT
	jc .err

	call motor_on
	mov al, CMD_SEEK             ; SEEK COMMAND
	call PFDATA                  ; PUSH COMMAND
	mov al, ST0_US               ; mask to 2 drives
	and ax, di                   ; unit number to AL
	call PFDATA                  ; SAY WHICH UNIT
	mov al, [fdc_cylinder + di]  ; set new cylinder number
	call PFDATA                  ; SEND THAT TOO
	;
	mov cx, 0f100h                 ;setup timeout
.1:
	call wait12
	call CHECKINT
	call get_msr                 ; READ SEEK STATUS
	test al, 0fh                 ; ANY DRIVES SEEKING?
	loopnz .1                    ; YES, WAIT FOR THEM
	jnz .err

	%if SOFT_DEBUG & DUMP
	pushm f                      ;, ax, bx, cx, dx, es
	mov al, ah                   ; save AH in AL
	lahf                         ; get flags
	mov bh, ch
	mov bl, [fdc_cylinder + di]
	push bx
	push cs                      ; far pointer to ...
	push fnseek                  ; format
	call _cprintf
	add sp, 6
	popm f                       ;, ax, bx, cx, dx, es
	%endif
.okay:
	Okay
.exit:
	popm cx, dx, si
	ret
.invalid:
	; error - - the cylinder requested is invalid for this drive
	mov ah, ERR_86
.err:   Error
	mov byte [fdc_cylinder + di], 0ffh  ; set error cylinder number
	jmp .exit                    ; jump WAY out


	%if SOFT_DEBUG & DUMP
fcrw:
	db NL, "RW ST0 %02x ST1 %02x ST2 %02x C + %02x H + %02x S + %02x N %x", 0
rwvc:
	db NL, "VC AX %04x CHS %02x:%02x:%02x DL %02x ES:BX %04x:%04x", 0
fnret:
	db NL, "RET AH %02x CY %d CMD %02x %02x", NL, 0
fnldor:
	db NL, "LDOR = %02x ", NL, 0
fnseek:
	db NL, "SEEK = %04x ", NL, 0
fnrecal:
	db NL, "RECALIBRATE = %04x ", NL, 0
fnmsr:
	db NL, "MSR = %04x ", NL, 0
fndio:
	db NL, "DIO = %04x ", NL, 0
fncheckint:
	db NL, "Checkint = %04x ", NL, 0
fnpferr:
	db NL, "PFERR = %04x ", NL, 0
fngferr:
	db NL, "GFERR = %04x, %04x ", NL, 0
	%endif
