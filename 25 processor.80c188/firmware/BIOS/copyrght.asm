;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; copyrght.asm -- Copyright notice and startup jump
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   This version is for assembly by  NASM 0.98.39 or later
;
; Copyright (C) 2017,2020 John R. Coffman.  All rights reserved.
; Licensed for hobbyist use only.
; For use on the RetroBrew SBC-188 & SBC-188v3 boards.
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
;
; SBC-188 board revisions:
;       1.0     production board
;	2.0	production board with errata
;------------------------------------------------------------------------
;	3.0	2 x 512k SRAM chips, GALs for glue logic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	cpu	186
%include	"config.asm"
%include	"cpuregs.asm"
%include	"date.asm"
%include	"equates.asm"

        segment         _TEXT

	global	ident2, _unique
        global  begin_here
	extern	cold_boot

; startup jumps to this absolute location
..start:
begin_here:
        jmp     cold_boot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Put the Copyright notice right at the beginning of the ROM.
;  It may be printed second, but it should be at the most obvious
;  location in the ROM image.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ident2:
	db	"%12a"
        db      CR,LF
        db      "Copyright (C) 2010-2020 by The RetroBrew Users' Group.  All rights reserved."
        db      CR,LF
        db      "Provided for hobbyist use on the RetroBrew SBC-188 board."
        db      "  All code may be"
        db      CR,LF
        db      "used under the terms of the GNU General Public License, a copy of which"
        db      CR,LF
        db      "is contained in the file COPYING in the top-level source directory."
        db      CR,LF
	db	0
	
_unique:	db	DATE_STRING1, VERSION_STRING, 0


