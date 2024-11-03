;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IDE.ASM -- Fixed Disk [IDE] driver dispatcher
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   This version is for assembly by  NASM 0.98.39 or later
;
; Copyright (c) 2013 John R. Coffman.  All rights reserved.
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
; Updated for the Duodyne 80c188 SBC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include	"config.asm"
%include	"cpuregs.asm"
%include	"equates.asm"
%include	"disk.inc"


	SEGMENT		_TEXT

	extern	BIOS_call_13h
	global	FIXED_BIOS_call_13h
FIXED_BIOS_call_13h:
	or	dl,dl			; test device code in DL
	js	hard			; 80h is hard drive
	jmp	BIOS_call_13h		; 00,01 are floppy drives

	align	2
; driver dispatch table
dispatch:
	dw	FIXED_error	; NO_disk
	dw	PPIDE_entry	; PPI_type
	dw	DIDE0_entry	; DIDE0_type
	dw	DIDE1_entry	; DIDE1_type
	dw	DSD_entry	; DSD_type
	dw	IDE8_entry	; V3IDE8 type
	dw	DISKIO_entry	; DISKIO_type
	dw	MFPIC_entry	; MFPIC_type
n_dispatch	equ	$-dispatch-2

hard:
	sti			; common prefix code for all disk drivers
        pushm   all,ds,es       ; Standard register save
        mov     bp,sp           ; establish stack addressing
        cld			; make no assumptions!
        push    bios_data_seg
        popm    ds              ; establish addressability
;------------------------------------------------------------------------
; Format of the "fixed_disk_tab" in the BIOS data area:
;	byte entries:   0000 ddds (binary)  ddd=driver number, s="secondary"
;------------------------------------------------------------------------
	mov	bl,dl		; drive number (80h..83h) to BL
	and	bx,FIXED_DISK_MAX-1	; mask device code
	mov	bl,[fixed_disk_tab+bx]	; get driver number from BIOS data area
	and	bx,0Eh		; mask driver number (all even)
  cs	jmp	near [dispatch+bx]



	global	FIXED_timeout
FIXED_timeout:
	mov	ah,ERR_disk_timeout
	jmp	FIXED_exit_AH

	global	FIXED_error, FIXED_exit_AH
FIXED_error:
	mov	ah,ERR_invalid_command
FIXED_exit_AH:
        or      byte [bp+offset_FLAGS],1        ; set the carry
	mov	sp,bp
	popm	all,ds,es
	iret



;  External references

	extern	PPIDE_entry

DIDE0_entry	equ	FIXED_error
DIDE1_entry	equ	FIXED_error
DSD_entry	equ	FIXED_error
IDE8_entry	equ	FIXED_error
DISKIO_entry	equ	FIXED_error
MFPIC_entry	equ	FIXED_error


	global	get_IDE_num		; to AX (AH will be clear)
	global	_get_IDE_num		; to AX (AH will be clear)
_get_IDE_num:
get_IDE_num:
%if 0
	pushm	ds
	push	bios_data_seg
	popm	ds
	mov	al,[n_fixed_disks]
	mov	ah,0
	popm	ds
%else
	pushm	bx,cx,ds
	push	bios_data_seg
	popm	ds
	mov	cx,FIXED_DISK_MAX
	mov	bx,fixed_disk_tab
	xor	ax,ax
.1:
	test	byte [bx],03Fh
   	jz	.2
	inc	ax
.2:
	inc	bx
	loop	.1

	popm	bx,cx,ds
%endif
	ret


	global	fixed_device_code

; critical:  this table must be kept in sync with the enum at the
;	top of 'nvram.c'
;
;enum {NO_disk=0, PPI_type=2, DIDE0_type=4, DIDE1_type=6, DSD_type=8,
;	V3IDE8_type=10, DISKIO_type=12 };
;
fixed_device_code:
	dw	0		; NO_disk
	dw	PPI		; PPI_type
	dw	0x408		; DSD_type
	dw	-1
