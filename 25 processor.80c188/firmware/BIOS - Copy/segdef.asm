;========================================================================
; SEGDEF.ASM -- Lots of Defintions for Relocatable BIOS
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

%ifndef __SEGDEF_
%define __SEGDEF_

	SEGMENT  _TEXT ALIGN=2 PUBLIC CLASS=CODE
        SEGMENT  CONST ALIGN=2 PUBLIC CLASS=DATA
        SEGMENT  CONST2 ALIGN=2 PUBLIC CLASS=DATA
	SEGMENT  _DATA ALIGN=16 PUBLIC CLASS=DATA
	SEGMENT  _BSS  ALIGN=2 PUBLIC CLASS=BSS
;;;        SEGMENT  _BASIC ALIGN=16 PUBLIC CLASS=BASIC

	GROUP	DGROUP CONST CONST2 _DATA _BSS

%endif

