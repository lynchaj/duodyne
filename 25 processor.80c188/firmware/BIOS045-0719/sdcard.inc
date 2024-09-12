;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDcard.INC -- include file for Basic I/O routines for the Dual SDcard
;		add-on board
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
;
;;;	cpu	186

%define	dev_SDcard	08h		; Dual SD card board device code

%define Z80	1
%define SBC188	2
%define M68K	3

%define TRUE	1
%define FALSE	0

%if 0
%define CPU	SBC188

%if	CPU==Z80
IO_BASE		equ	0
%elif	CPU==SBC188
IO_BASE		equ	0400h
%elif	CPU=M68K
IO_BASE		equ	0FFFF8000h
%else
IO_BASE		equ	0
%endif
%endif


SDoperation	equ	dev_SDcard + IO_BASE
SDselect	equ	SDoperation + 1



; Operation register bits
CardDetect	equ	20h		; read-only
WrProt		equ	10h		; read-only
ChipSelect	equ	04h		; bit 2 (through an inverter)
Clock		equ	02h		; bit 1
DataIn		equ	01h
DataOut		equ	01h		; all Data I/O through bit 0

; Select register bits
Unit		equ	01h		; read/write
UnitMask	equ	Unit

WrProt0		equ	04h		; read-only
WrProt1		equ	08h		; read-only

CardDetect0	equ	10h		; read/write	(ChangeBit must be set)
CardDetect1	equ	20h		; read/write	( ditto )

IntEnable	equ	40h		; write-only	(ChangeBit must be set)
ChangeBit	equ	80h		; write-only
Pend0		equ	40h		; read-only
Pend1		equ	80h		; read-only
PendMask	equ	Pend0 | Pend1

CDupdateMask	equ	CardDetect1 | CardDetect0 | UnitMask


; Card types:
SDtypeUnk	equ	0		; unknown card type
SDtypeMMC	equ	1		; old MMC card
SDtypeSDSC 	equ	2		; standard card
SDtypeSDHC	equ	3		; HC card


%if 1
; for the Tiny, Small, or Compact models:
%define ARG(n) [bp+2+(n)*2]
%endif
