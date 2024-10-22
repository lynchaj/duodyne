;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IDELIB.ASM -- common IDE routines
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


;------------------------------------------------------------------
; More symbolic constants... these should not be changed, unless of
; course the IDE drive interface changes, perhaps when drives get
; to 128G and the PC industry will do yet another kludge.

;some symbolic constants for the ide registers, which makes the
;code more readable than always specifying the address pins

ide_data       	equ	0		; r/w
ide_data8	equ	ide_data	; 8-bit data transfer
ide_err		equ	1		; read
ide_feature	equ	1		; write
ide_sec_cnt	equ	2
ide_sector     	equ	3
ide_cyl_lsb	equ	4
ide_cyl_msb	equ	5
ide_head       	equ	6
ide_command	equ	7		; write
ide_status     	equ	7		; read
ide_data16	equ	8		; 16-bit data transfer
ide_dmack	equ	9		; DMA acknowledge
ide_control	equ	0Eh		; aux control port
ide_astatus	equ	0Fh		; aux status port

;IDE Command Constants.  These should never change.
ide_cmd_recal		equ	10H
ide_cmd_read		equ	20H
ide_cmd_write		equ	30H
ide_cmd_init		equ	91H
ide_cmd_dma_read	equ	0C8h
ide_cmd_dma_write	equ	0CAh
ide_cmd_spindown	equ	0E0h
ide_cmd_spinup		equ	0E1h
ide_cmd_ident		equ	0ECh
ide_cmd_set_feature	equ	0EFh

; Control register bits:
ide_ctrl_ALWAYS		equ	08h	; must always be set
ide_ctrl_RESET		equ	04h
ide_ctrl_nIEN		equ	02h	; no interrupt if set
					; interrupt if reset

; Master/Slave bits (head register)
ide_MASTER		equ	00h
ide_SLAVE		equ	10h
ide_LBA			equ	0E0h
ide_CHS			equ	0A0h

; Status Register Bits
ide_ST_BUSY		equ	0x80
ide_ST_READY    	equ	0x40
ide_ST_WFAULT   	equ	0x20
ide_ST_SEEKDONE 	equ	0x10
ide_ST_DATARQ   	equ	0x08
ide_ST_CORR     	equ	0x04
ide_ST_INDEX    	equ	0x02
ide_ST_ERROR    	equ	0x01

; IDE interface Features
ide_SET_8BIT		equ	0x01
ide_RESET_8BIT		equ	0x81
ide_SET_16BIT		equ	ide_RESET_8BIT

; Address Register bits (active when == 0)
ide_nDS0        	equ	0x01
ide_nDS1        	equ	0x02
ide_nHEAD       	equ	0x3C
ide_nWTG        	equ	0x40

; Error Register bits
ide_ERR_BADBLK     	equ	0x80
ide_ERR_UCORR      	equ	0x40
ide_ERR_MEDIA_CHG  	equ	0x20
ide_ERR_IDNF       	equ	0x10
ide_ERR_MCHG_REQ   	equ	0x08
ide_ERR_ABRT       	equ	0x04
ide_ERR_TK0NF      	equ	0x02
ide_ERR_AMNF       	equ	0x01




; Standard int 13h stack frame layout is 
; created by:   PUSHM  ALL,DS,ES
;               MOV    BP,SP
;
offset_DI       equ     0
offset_SI       equ     offset_DI+2
offset_BP       equ     offset_SI+2
offset_SP       equ     offset_BP+2
offset_BX       equ     offset_SP+2
offset_DX       equ     offset_BX+2
offset_CX       equ     offset_DX+2
offset_AX       equ     offset_CX+2
offset_DS       equ     offset_AX+2
offset_ES       equ     offset_DS+2
offset_IP       equ     offset_ES+2
offset_CS       equ     offset_IP+2
offset_FLAGS    equ     offset_CS+2

; The byte registers in the stack
offset_AL       equ     offset_AX
offset_AH       equ     offset_AX+1
offset_BL       equ     offset_BX
offset_BH       equ     offset_BX+1
offset_CL       equ     offset_CX
offset_CH       equ     offset_CX+1
offset_DL       equ     offset_DX
offset_DH       equ     offset_DX+1


; FDC error codes (returned in AH)
;
ERR_no_error            equ     0       ; no error (return Carry clear)
;   everything below returns with the Carry set to indicate an error
ERR_invalid_command     equ     1
ERR_address_mark_not_found      equ     2
ERR_write_protect       equ     3
ERR_sector_not_found    equ     4
ERR_disk_removed        equ     6
ERR_dma_overrun         equ     8
ERR_dma_crossed_64k     equ     9


ERR_media_type_not_found        equ     12	; 0Ch
ERR_uncorrectable_CRC_error     equ     10h
ERR_controller_failure  equ     20h
ERR_seek_failed         equ     40h
ERR_disk_timeout        equ     80h


		SEGMENT		_TEXT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; integrity:    Check integrity of fixed disk table
;
;  Call with:
;       DL = device code (80h..83h)
;       DS set to BIOS data area
;
;  Exit with:
;       DS set to BIOS data area (still)
;       SI points at the fixed disk table in the BDA
;
;  Error Exit:
;       If the disk table checksum is bad, give immediate error return
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
integrity:
        pushm   ax,cx
%if 0
        mov     al,7Fh
        and     al,dl                   ; mask out the high bit
        cmp     al,[n_fixed_disks]
%else
	extern	get_IDE_num
	call	get_IDE_num		; get number of IDE disks total
	mov	ah,al
	mov	al,7Fh
        and     al,dl                   ; mask out the high bit
	cmp	al,ah			; compare against max
%endif
        jae     .8			; harsh error exit
        mov     si,fx80
        mov     cx,fx81-fx80            ; size of fixed disk table
	test    al,al
        jz      .1
.0:	add     si,cx                   ; point at fx81
	dec	al
	jnz	.0
.1:
        push    si
        mov     ax,0EE00h               ; error code and zero checksum

.2:     add     al,[si]                 ; compute checksum
        inc     si
        loop    .2                      ; loop back

        pop     si
        or      al,al                   ; test AL for zero
        jz	.9			; good exit if zero
.8:	stc
.9:	popm    ax,cx
        ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fn41 -- Check Extensions Present
;
;  Call With:
;       AH = 41h        function code
;       BX = 55AAh      magic number
;       DL = drive code (80h or 81h)
;
;  Exit With:
;     carry clear
;       AH = 21h        version 1.1 support
;       BX = AA55h      magic number II
;       CX = 0001b  bit0=packet support; bit2=EDD drive support
;
;     carry set
;       AH = 01h        Invalid Command
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	ide_fn41
ide_fn41:
        call    integrity       ; test drive number (sets DS:SI)
	mov	ah,ERR_invalid_command
	jc	.9		; error return

        cmp     word [offset_BX + bp],55AAh
        jne     .9
        test    byte [fx_drive_control - fx80 + si],40h         ; test LBA bit
        jz      .9

        mov     byte [offset_AH + bp],21h       ; version 1.1
        mov     word [offset_BX + bp],0AA55h    ; magic number II
        mov     word [offset_CX + bp],00000101b       ; packet calls & EDD i/f
	xor	ah,ah
.9:	ret
