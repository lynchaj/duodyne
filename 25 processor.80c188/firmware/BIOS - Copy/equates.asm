;========================================================================
; EQUATES.ASM -- Lots of Defintions for Relocatable BIOS
;========================================================================
;   for the N8VEM SBC-188 v.00.4 and 00.5
;
;   This version is for assembly by  NASM 0.98.39 or later
;
; Copyright (C) 2010 John R. Coffman.  All rights reserved.
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
;========================================================================

        global  FPEM_segment


%include "segdef.asm"
%include "ascii.asm"


; POST error codes. Presently one byte but can expand to word.
ER_BIOS equ	01h		; Bad ROM bios checksum, patch last byte
ER_RAM	equ	02h		; Bad RAM in main memory, replace
ER_CRT	equ	04h		; Bad RAM in video card, replace
ER_FDC	equ	08h		; Bad FDC
ER_UNK1	equ	10h		; {unassigned}
ER_MEM	equ	20h		; Bad RAM in vector area, replace
ER_ROM	equ	40h		; Bad ROM in expansion area, bad checksum
ER_UNK2	equ	80h		; {unassigned}



;; ************************ BIOS Data Segment ******************************
;; BIOS data segment - not all will  be used
;                struc   BIOS_DATA_AREA  ; at 0040:0000
%include "bda.inc"

;  this must be the same in EQUATES.H */
%if SOFT_DEBUG
%define NBREAK  8
%endif


%if 0
        segment _TEXT
;; *************************************************************************




;; ************************ DOS Data Segment *******************************
;dosdir	SEGMENT at 50h				; Boot disk directory from IPL
;xerox	label	byte				;  0 if Print Screen idle
;						;  1 if PrtSc xeroxing screen
;						;255 if PrtSc error in xerox
;						;  ...non-grafix PrtSc in bios
;	db	200h dup(?)			; PC-DOS bootstrap procedure
;						;  ...IBMBIO.COM buffers the
;						;  ...directory of the boot
;						;  ...device here at IPL time
;						;  ...when locating the guts
;						;  ...of the operating system
;						;  ...filename "IBMDOS.COM"
;dosdir	ends
;; *************************************************************************
;; ************************ DOS IPL Segment ********************************
;dosseg	SEGMENT at 70h				; "Kernel" of PC-DOS op sys
;;IBMBIO.COM file loaded by boot block. Device Drivers/Bootstrap. CONTIGUOUS<---
;;IBMDOS.COM operating system nucleus immediately follows IBMBIO.COM and       !
;;     doesn`t have to be contiguous.  The IBMDOS operating system nucleus     !
;;     binary image is loaded by transient code in IBMBIO binary image	      !
;dosseg	ends					;			      !
;iplseg	SEGMENT at 0h				; Segment for boot block      !
;;The following boot block is loaded with 512 bytes on the first sector of     !
;;the bootable device by code resident in the ROM-resident bios.  Control is   !
;;then transferred to the first word 0000:7C00 of the disk-resident bootstrap  !
;	ORG	07C00h				;  ..offset for boot block    !
;boot	db	200h dup(?)			;  ..start disk resident boot--
;iplseg	ends

%endif
