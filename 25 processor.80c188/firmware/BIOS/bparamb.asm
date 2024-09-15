;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BPARAMB.ASM -- BIOS parameter block definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;        SEGMENT _DATA
        SEGMENT CONST
BIOS_parameter_block:

bytes_per_sector        equ     0
sectors_per_cluster	equ     bytes_per_sector + 2
reserved_sectors	equ     sectors_per_cluster + 1
FAT_copies              equ     reserved_sectors + 2
directory_entries	equ     FAT_copies + 1
total_sectors           equ     directory_entries + 2
media_descriptor	equ     total_sectors + 2
sectors_per_FAT		equ     media_descriptor + 1
sectors_per_track	equ     sectors_per_FAT + 2
heads_per_cylinder	equ     sectors_per_track + 2
hidden_sectors		equ     heads_per_cylinder + 2
total_sectors_2         equ     hidden_sectors + 4
BPB_rsvd                equ     total_sectors_2 + 4
vol_id_marker           equ     BPB_rsvd + 2
volume_unique_id        equ     vol_id_marker + 1
BPB_length              equ     volume_unique_id + 4


floppy_12M:
        dw      512             ; bytes per sector
        db      1               ; sectors per cluster
        dw      1               ; reserved sectors
        db      2               ; FAT copies
        dw      224             ; dir entries
        dw      2400            ; total sectors
        db      0F9h            ; media descriptor
        dw      7               ; sectors per FAT
        dw      15              ; sectors per track
        dw      2               ; heads per cylinder
        dd      0               ; hidden sectors
        dd      0
        dw      0
        db      29h
        dd      0               ; volume ID



floppy_144M:
        dw      512             ; bytes per sector
        db      1               ; sectors per cluster
        dw      1               ; reserved sectors
        db      2               ; FAT copies
        dw      224             ; dir entries
        dw      2880            ; total sectors
        db      0F0h            ; media descriptor
        dw      9               ; sectors per FAT
        dw      18              ; sectors per track
        dw      2               ; heads per cylinder
        dd      0               ; hidden sectors
        dd      0
        dw      0
        db      29h
        dd      0               ; volume ID


floppy_720K:
        dw      512             ; bytes per sector
        db      2               ; sectors per cluster
        dw      1               ; reserved sectors
        db      2               ; FAT copies
        dw      112             ; dir entries
        dw      1440            ; total sectors
        db      0F9h            ; media descriptor
        dw      3               ; sectors per FAT
        dw      9               ; sectors per track
        dw      2               ; heads per cylinder
        dd      0               ; hidden sectors
        dd      0
        dw      0
        db      29h
        dd      0               ; volume ID


floppy_360K:
        dw      512             ; bytes per sector
        db      2               ; sectors per cluster
        dw      1               ; reserved sectors
        db      2               ; FAT copies
        dw      112             ; dir entries
        dw      720             ; total sectors
        db      0FDh            ; media descriptor
        dw      2               ; sectors per FAT
        dw      9               ; sectors per track
        dw      2               ; heads per cylinder
        dd      0               ; hidden sectors
        dd      0
        dw      0
        db      29h
        dd      0               ; volume ID





        db      BPB_length
