;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MACROS.INC  
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

; general macros for the SBC188 BIOS ASSEMBLY
;
;
%ifndef __MACROS_DEFINED_
%define __MACROS_DEFINED_ 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; some useful macros:
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	cpu	186

%imacro setloc  1.nolist
 times   (%1-($-$$)) db 0FFh
%endm

%imacro db_lo   1
 db (%1)&255
%endm

%imacro cnop    0.nolist
%if SOFT_DEBUG
        nop
%endif
%endm

%imacro popm 1-*.nolist
%rep %0
%ifidni %1,ALL
 popa
%elifidni %1,F
 popf
%else
 pop %1
%ifidni %1,DS
 cnop
%elifidni %1,ES
 cnop
%endif
%endif
%rotate 1
%endrep
%endm

%imacro pushm 1-*.nolist
%rep %0
%rotate -1
%ifidni %1,ALL
 pusha
%elifidni %1,F
 pushf
%else
 push %1
%endif
%endrep
%endm

;
; added from the 386EX project
;

; call arguments
%define ARG(n) [bp+2+(n)*2]

;
; format of the BYTE initialization table:  address, byte
;
%imacro  binit 2
        dw      %1
        db      %2
%endmacro
; end with DW -1

;
; format of the WORD initialization table:  address, word
;
%imacro  winit 2
        dw      %1
        dw      %2
%endmacro
; end with DW -1


; get the BIOS Data Area segment pointer to a [segment] register
%imacro get_bda	1.nolist
	push	0x0040
	pop	%1
	cnop
%endm


%endif
