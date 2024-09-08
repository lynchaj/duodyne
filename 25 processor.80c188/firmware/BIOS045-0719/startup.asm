;========================================================================
;  startup.asm  -  start the 80C188 processor from a power-on condition
;========================================================================
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

        cpu     186

%include        "config.asm"
%include        "cpuregs.asm"
%include	"date.asm"
        

Ignore          equ     1<<2            ; ignore external ready
                

table0:
        db_lo   cpu_relocation
        dw      020FFh                  ;(default)

        db_lo   cpu_umcs
;;;	dw      0C038h | (256-ROM)*64 | ROM_WS&3 | Ignore
	dw      0C038h | (256-CHIP)*64 | ROM_WS&3 | Ignore

;M_RAM   equ     RAM/2
M_RAM   equ     RAM
L_RAM   equ     RAM-M_RAM

%if L_RAM>0
        db_lo   cpu_lmcs
        dw      00038h | (L_RAM*64-1)&3FC0h | RAM_WS&3 | Ignore
%endif

        db_lo   cpu_mmcs
        dw      001F8h | (L_RAM*64) | RAM_WS&3 | Ignore

        db_lo   cpu_mpcs
        dw      080B8h | (M_RAM*32) | LCL_IO_WS&3 | Ignore

; fix I/O space at 0400h
        db_lo   cpu_pacs
        dw      00078h | BUS_IO_WS&3  ; and use ARDY

        db_lo   cpu_mdram
        dw      0000h

        db_lo   cpu_cdram
        dw      01FFh                   ; not used, so maximum

        db_lo   cpu_edram
        dw      0000h                   ; disable refresh entirely

        db_lo   cpu_pdcon
        dw      0003h                   ; Disable,  divisor=16

table0_len      equ     ($-table0)/3





init0:
        cli                             ; interrupts should be off already
        cld                             ; clear direction flag (set to UP)
        mov     dh,cpu_umcs>>8          ; high byte of I/O address
        mov     si,table0               ; address of setup table
        mov     ax,cs                   ; get Code Segment
        mov     ds,ax                   ; for LODS
        mov     cx,table0_len           ; count of table items
init0_loop:
        lodsb
        mov     dl,al
        lodsw
        out     dx,ax
        loop    init0_loop
; memory selects are now set up

        mov     ds,cx                   ; CX = 0 from above
        mov     ss,cx                   ; set Stack Segment
        mov     sp,400h                 ; set Stack Pointer (0400h absolute)
      
;    cs  jmp     far [goto]
	jmp	startseg:0000h
        nop



        setloc  startuplength-16
start:
        jmp     startupseg:init0

	db	DATE_STRING0, 0
;  must be at F000:FFFE hex
;;;	db	MODEL_BYTE, SUBMODEL_BYTE
	db	MODEL_BYTE
	db	0FFh



; At power up or reset, execution starts at label 'start'.


