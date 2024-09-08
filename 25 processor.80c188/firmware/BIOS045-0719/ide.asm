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
	dw	FIXED_error	; NO_disk
	dw	FIXED_error	; NO_disk
	dw	FIXED_error	; NO_disk
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

  

	global	FIXED_error
FIXED_error:
	mov	ah,ERR_invalid_command
        or      byte [bp+offset_FLAGS],1        ; set the carry
	mov	sp,bp
	popm	all,ds,es
	iret



;  External references

%if PPIDE_driver
	extern	PPIDE_entry
%else
PPIDE_entry	equ	FIXED_error
%endif
%if DIDE_driver
	extern	DIDE0_entry, DIDE1_entry
%else
DIDE0_entry	equ	FIXED_error
DIDE1_entry	equ	FIXED_error
%endif
%if DSD_driver
	extern	DSD_entry
%else
DSD_entry	equ	FIXED_error
%endif


	global	get_IDE_num		; to AX (AH will be clear)
	global	_get_IDE_num		; to AX (AH will be clear)
_get_IDE_num:
get_IDE_num:
	pushm	bx,cx,ds
	push	bios_data_seg
	popm	ds
	mov	cx,FIXED_DISK_MAX
	mov	bx,fixed_disk_tab
	xor	ax,ax
.1:
	test	byte [bx],0Fh
   	jz	.2
	inc	ax
.2:
	inc	bx
	loop	.1

	popm	bx,cx,ds
	ret


%if 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Below this point to be deleted soon (4/15/2013)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		SEGMENT		_TEXT

%if (PPIDE_driver!=0 && DIDE_driver!=0)
	extern	PPIDE_BIOS_call_13h, DIDE_BIOS_call_13h

%if PPIDE_driver < DIDE_driver
; PPIDE is the preferred driver (1 vs 2 in precedence)
	pushm	ax
	call	get_PPIDE_num		; get number of PPIDE drives
	mov	ah,dl			; get drive number to AH
	and	ah,0Fh			; mask to count
	cmp	ah,al
	popm	ax			; restor AX
	jb	$+5
	jmp	DIDE_BIOS_call_13h
	jmp	PPIDE_BIOS_call_13h
%else
; DIDE is the preferred driver if precedence is the same
	pushm	ax
	call	get_DIDE_num		; get number of DIDE drives
	mov	ah,dl			; get drive number to AH
	and	ah,0Fh			; mask to count
	cmp	ah,al
	popm	ax			; restor AX
	jb	$+5
	jmp	PPIDE_BIOS_call_13h
	jmp	DIDE_BIOS_call_13h
%endif

%else
%if DIDE_driver
	extern	DIDE_BIOS_call_13h
	jmp	DIDE_BIOS_call_13h

%else
	extern	PPIDE_BIOS_call_13h
	jmp	PPIDE_BIOS_call_13h
%endif
%endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; get the number of DIDE drives in AX (different from below)
;	AH is set to zero
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	get_DIDE_num
	global	_get_DIDE_num
_get_DIDE_num:
get_DIDE_num:
%if DIDE_driver
	pushm	ds

	push	bios_data_seg		; address BIOS data segment
	popm	ds
	mov	al,[n_fixed_disks]	; get # fixed disk structure
	shr	al,2			; DIDE0 count
	mov	ah,al			;
	shr	ah,2			; DIDE1 count
	and	al,3
	and	ah,3			; mask counts
	add	al,ah			; total to AL
	cbw
	popm	ds
%else
	xor	ax,ax			; return zero
%endif
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; get the number of PPIDE disks in AL
;	AH is preserved
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	get_PPIDE_num
get_PPIDE_num:
%if PPIDE_driver
	pushm	ds

	push	bios_data_seg		; address BIOS data segment
	popm	ds

	mov	al,[n_fixed_disks]	; get # fixed disk structure
	and	al,3			; don't touch AH

	popm	ds
%else
	xor	al,al			; return 0 in AL (AH is not touched)
%endif
	ret

%endif

