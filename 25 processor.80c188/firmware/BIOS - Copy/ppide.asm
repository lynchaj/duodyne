;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PPIDE.ASM -- Parallel Port IDE driver
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;* Updated 1-Jul-2010 Max Scane - Added PPIDE driver and conditionals
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
;   (modified from Max Scane's driver for the Z80)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include	"config.asm"
%include	"cpuregs.asm"
%include	"equates.asm"
%include	"disk.inc"


        global  _PPIDE_WRITE_SECTOR
        global  _PPIDE_READ_SECTOR
        global  _PPIDE_READ_ID
        extern  @mulLS
                extern  microsecond

;
; PIO 82C55 I/O IS ATTACHED TO THE FIRST IO BASE ADDRESS

IDELSB          equ     PIO_A           ; LSB
IDEMSB          equ     PIO_B           ; MSB
IDECTL		equ	PIO_C           ; Control Signals
PIO1CONT	equ	PIO_CTRL	; CONTROL BYTE PIO 82C55

; PPI control bytes for read and write to IDE drive

rd_ide_8255	equ	10010010b	;ide_8255_ctl out, ide_8255_lsb/msb input
wr_ide_8255	equ	10000000b	;all three ports output

;ide control lines for use with ide_8255_ctl.  Change these 8
;constants to reflect where each signal of the 8255 each of the
;ide control signals is connected.  All the control signals must
;be on the same port, but these 8 lines let you connect them to
;whichever pins on that port.

ide_a0_line	equ	01H		;direct from 8255 to ide interface
ide_a1_line	equ	02H		;direct from 8255 to ide interface
ide_a2_line	equ	04H		;direct from 8255 to ide interface
ide_cs0_line	equ	08H		;inverter between 8255 and ide interface
ide_cs1_line	equ	10H		;inverter between 8255 and ide interface
ide_wr_line	equ	20H		;inverter between 8255 and ide interface
ide_rd_line	equ	40H		;inverter between 8255 and ide interface
ide_rst_line	equ	80H		;inverter between 8255 and ide interface


;------------------------------------------------------------------
; More symbolic constants... these should not be changed, unless of
; course the IDE drive interface changes, perhaps when drives get
; to 128G and the PC industry will do yet another kludge.

;some symbolic constants for the ide registers, which makes the
;code more readable than always specifying the address pins

ide_data       	equ	ide_cs0_line
ide_err		equ	ide_cs0_line + ide_a0_line
ide_sec_cnt	equ	ide_cs0_line + ide_a1_line
ide_sector     	equ	ide_cs0_line + ide_a1_line + ide_a0_line
ide_cyl_lsb	equ	ide_cs0_line + ide_a2_line
ide_cyl_msb	equ	ide_cs0_line + ide_a2_line + ide_a0_line
ide_head       	equ	ide_cs0_line + ide_a2_line + ide_a1_line
ide_command	equ	ide_cs0_line + ide_a2_line + ide_a1_line + ide_a0_line
ide_status     	equ	ide_cs0_line + ide_a2_line + ide_a1_line + ide_a0_line
ide_control	equ	ide_cs1_line + ide_a2_line + ide_a1_line
ide_astatus	equ	ide_cs1_line + ide_a2_line + ide_a1_line + ide_a0_line

;IDE Command Constants.  These should never change.


	SEGMENT	_TEXT
	
;------------------------------------------------------------------------------------		
; Parallel port IDE driver
;	
;
	



; -----------------------------------------------------------------------------	
;  IDE_READ_ID
; -----------------------------------------------------------------------------	
; Read the 512 byte ID information from the attached drive
;
;  int IDE_READ_ID(far byte *buffer, byte slave);
;
;
;-----------------------------------------------------------------------------
_PPIDE_READ_ID:
        push    bp
        mov     bp,sp
        pushm   es,bx

	call	ide_wait_not_busy		;make sure drive is ready
        xor     ax,ax
        xor     dx,dx
        mov     cx,ARG(3)               ; select Master/Slave
        call    wr_lba                  ; select device

        mov     al,ide_command
        mov     bl,ide_cmd_ident
	call	ide_write				;ask the drive to read it
	call	ide_wait_drq			;wait until it's got the data

        les     bx,ARG(1)
	call	read_data				;grab the data

        xor     ax,ax

        popm    es,bx
        leave
	ret


	
; -----------------------------------------------------------------------------	
;  IDE_READ_SECTOR
; -----------------------------------------------------------------------------	
	;read a sector, specified by the 4 bytes in "lba",
	;Return, acc is zero on success, non-zero for an error
;
;  int IDE_READ_SECTOR(far byte *buffer, long lba_sector, byte slave);
;
;
;-----------------------------------------------------------------------------
@PPIDE_READ_SECTOR:
        pushm   bx,es,ax,dx,cx
        call    _PPIDE_READ_SECTOR
        popm    bx,es,ax,dx,cx
        ret

_PPIDE_READ_SECTOR:
        push    bp
        mov     bp,sp
        pushm   es,bx

	call	ide_wait_not_busy		;make sure drive is ready
        mov     ax,ARG(3)
        mov     dx,ARG(4)
        mov     cx,ARG(5)
	call	wr_lba					;tell it which sector we want
;	mvi		a, ide_command			;select IDE register 
;	mvi		c, ide_cmd_read
        mov     al,ide_command
        mov     bl,ide_cmd_read
	call	ide_write				;ask the drive to read it
	call	ide_wait_drq			;wait until it's got the data
;	lxi		h, SECTOR_BUFFER
        les     bx,ARG(1)
	call	read_data				;grab the data
;	mvi		a,0
        xor     ax,ax

        popm    es,bx
        leave
	ret


; -----------------------------------------------------------------------------	
;  IDE_VERIFY_SECTOR
; -----------------------------------------------------------------------------	
	;read a sector, specified by the 4 bytes in "lba",
	;Return, acc is zero on success, non-zero for an error
;
;  int IDE_VERIFY_SECTOR(long lba_sector, byte slave);
;
;
;-----------------------------------------------------------------------------
@PPIDE_VERIFY_SECTOR:
        pushm   ax,dx,cx
        call    _PPIDE_VERIFY_SECTOR
        popm    ax,dx,cx
        ret

_PPIDE_VERIFY_SECTOR:
        push    bp
        mov     bp,sp
        pushm   es,bx

	call	ide_wait_not_busy		;make sure drive is ready
        mov     ax,ARG(1)
        mov     dx,ARG(2)
        mov     cx,ARG(3)
	call	wr_lba					;tell it which sector we want
;	mvi		a, ide_command			;select IDE register 
;	mvi		c, ide_cmd_read
        mov     al,ide_command
        mov     bl,ide_cmd_read
	call	ide_write				;ask the drive to read it
	call	ide_wait_drq			;wait until it's got the data
;	lxi		h, SECTOR_BUFFER
;;        les     bx,ARG(1)
	call	verify_data				;grab the data
;	mvi		a,0
        xor     ax,ax

        popm    es,bx
        leave
	ret


;-----------------------------------------------------------------------------
;  IDE_WRITE_SECTOR
;-----------------------------------------------------------------------------
	;write a sector, specified by the 4 bytes in "lba",
	;whatever is in the buffer gets written to the drive!
	;Return, acc is zero on success, non-zero for an error
;
;  int IDE_WRITE_SECTOR(far byte *buffer, long lba_sector, byte slave);
;
;
;-----------------------------------------------------------------------------
@PPIDE_WRITE_SECTOR:
        pushm   bx,es,ax,dx,cx
        call    _PPIDE_WRITE_SECTOR
        popm    bx,es,ax,dx,cx
        ret

_PPIDE_WRITE_SECTOR:
        push    bp
        mov     bp,sp
        pushm   es,bx

	call	ide_wait_not_busy	;make sure drive is ready
        mov     ax,ARG(3)
        mov     dx,ARG(4)
        mov     cx,ARG(5)
	call	wr_lba				;tell it which sector we want
;	mvi		a, ide_command
;	mvi		c, ide_cmd_write
        mov     al,ide_command
        mov     bl,ide_cmd_write
	call	ide_write			;tell drive to write a sector
	call	ide_wait_drq		;wait unit it wants the data
;	lxi		h,SECTOR_BUFFER
        les     bx,ARG(1)
	call	write_data			;give the data to the drive
	call	ide_wait_not_busy	;wait until the write is complete
;	mvi		a,0					;signal success
        xor     ax,ax
        
        popm    es,bx
        leave
	ret


;-----------------------------------------------------------------------------
;--------ide_hard_reset-------------------------------------------------------
;
;     Do a hard reset on the drive, by pulsing its reset pin.
;
;  Call with:
;       Nothing
;
;  Exit with:
;       AX and DX are destroyed
;
;-------------------------------------------------------------------------------------------	
ide_hard_reset:
        pushm   cx

	call	set_ppi_rd
        mov     al,ide_rst_line         ; assert RST line on the Interface
        mov     dl,IDECTL & 255
        out     dx,al

        mov     cx,20000                ; 20ms delay
        call    microsecond

        xor     al,al
        mov     dl,IDECTL & 255
        out     dx,al

        popm    cx
	ret


;------------------------------------------------------------------------------
; IDE INTERNAL SUBROUTINES 
;------------------------------------------------------------------------------


	
;----------------------------------------------------------------------------
;  Get Error code
;
	;when an error occurs, we get bit 0 of A set from a call to ide_drq
	;or ide_wait_not_busy (which read the drive's status register).  If
	;that error bit is set, we should jump here to read the drive's
	;explaination of the error, to be returned to the user.  If for
	;some reason the error code is zero (shouldn't happen), we'll
	;return 255, so that the main program can always depend on a
	;return of zero to indicate success.
;
;  Exit with:
;       AL contains error code
;       All other registers preserved
;----------------------------------------------------------------------------
get_err:
        pushm   bx,dx

;	mvi		a,ide_err
        mov     al,ide_err              ; register to read
	call	ide_read
;	mov		a,c
        mov     al,bl
        or      al,al
;	jz		gerr2
;	ret
;gerr2:
;	mvi		a, 255
        jnz     .1
        dec     al      ; error code of 0 returned as 255
.1:     
        popm    bx,dx
	ret



;-----------------------------------------------------------------------------
;  Wait for RDY to be set
;
;  Exit with:
;       AL contains status
;       All other registers preserved
;
;------------------------------------------------------------------------------
ide_wait_not_busy:
        pushm   bx,dx
.1:
;	mvi		a,ide_status		;wait for RDY bit to be set
        mov     al,ide_status
	call	ide_read
;	mov		a,c
;	ani		80h					; isolate busy bit
;	jnz		ide_wait_not_busy
        mov     al,bl
        and     al,10000000b
        jnz     .1

        popm    bx,dx
	ret

;------------------------------------------------------------------------------
;  Wait for Ready from the drive
;
;  Exit with:
;       AL contains status
;       All other registers preserved
;
;------------------------------------------------------------------------------
ide_wait_ready:
        pushm   bx,dx
.1:
;	mvi		a,ide_status		;wait for RDY bit to be set
        mov     al,ide_status           ; read status
	call	ide_read
;	mov		a,c
;	ani		%11000000			
;	xri		%01000000	
        mov     al,bl
        and     al,11000000b            ;Mask off busy and ready bits
        xor     al,01000000b            ;We want Busy(7) to be 0 and Ready(6) to be 1
;	jnz		ide_wait_ready
        jnz     .1

        popm    bx,dx
	ret

;------------------------------------------------------------------------------
	;Wait for the drive to be ready to transfer data (DRQ = data request)
	;Returns the drive's status in Acc
;
;  Exit with:
;       AL contains status
;       All other registers preserved
;------------------------------------------------------------------------------
ide_wait_drq:
        pushm   bx,dx
.1:
;	mvi		a,ide_status		;wait for DRQ bit to be set
        mov     al,ide_status           ; wait for DRQ bit to be set
	call	ide_read
;	mov		a,c
;	ani		%10001000			; Mask off Busy(7) and DRQ(3)
;	xri		%00001000			; We want Busy(7) to be 0 and DRQ (3) to be 1
        mov     al,bl
        and     al,10001000b		; Mask off Busy(7) and DRQ(3)
        xor     al,00001000b		; We want Busy(7) to be 0 and DRQ (3) to be 1

;        jnz		ide_wait_drq
        jnz     .1

        popm    bx,dx
	ret



;------------------------------------------------------------------------------
	;Read a block of 512 bytes (one sector) from the drive
	;and store it in memory @ HL
; Read a sector of 512 bytes into memory at ES:[BX]
;
;  Call with:
;       ES:BX -- pointer to the data block
;
;  Exit with:
;       AX and DX are destroyed; other registers preserved
;
;-----------------------------------------------------------------------------
read_data:
        pushm   bx,cx,di
;	mvi		b, 0			; word counter
        mov     di,bx
        mov     cx,256          ; sector size in words
rdblk2:
;	push	b
;	push	h
;	mvi		a, ide_data
        mov     al,ide_data
	call	ide_read		; read form data port
;	pop		h
;	mov		m, c
;	inx		h
;	mov		m, b
;	inx		h
;	pop		b
   es   mov     [di],bx
        inc     di
        inc     di

;	dcr		b
;	jnz		rdblk2
        loop    rdblk2

        popm    bx,cx,di
	ret

;------------------------------------------------------------------------------
	;Read a block of 512 bytes (one sector) from the drive
;
;  Call with:
;       Nothing
;
;  Exit with:
;       AX and DX are destroyed; other registers preserved
;
;-----------------------------------------------------------------------------
verify_data:
        pushm   bx,cx,di
        mov     di,bx
        mov     cx,256          ; sector size in words
verblk2:
        mov     al,ide_data
	call	ide_read		; read form data port

        loop    verblk2

        popm    bx,cx,di
	ret

;-----------------------------------------------------------------------------
;Write a block of 512 bytes (at HL) to the drive
; Write a block of 512 bytes (at ES:BX to the drive)
;
;  Call with:
;       ES:BX -- pointer to the data block
;
;  Exit with:
;       AX and DX are destroyed; other registers preserved
;
;-----------------------------------------------------------------------------
write_data:
        pushm   bx,cx,si

;	mvi		b,0
        mov     cx,256          ; 512 bytes = 256 words
        mov     si,bx           ; use SI for the loads
wrblk2: 
;	push	b
;	mov		c, m	; lsb
;	inx		h
;	mov		b, m	; msb
;	inx		h
;	push	h
   es   mov     bx,[si]
        inc     si
        inc     si

;	mvi		a, ide_data
        mov     al,ide_data
	call	ide_write
;	pop		h
;	pop		b

;	dcr		b
;	jnz		wrblk2
        loop            wrblk2

        popm    bx,cx,si
	ret


;-----------------------------------------------------------------------------
; write the logical block address to the drive's registers
;
;  Call with:
;       DX:AX = logical block address
;       CL = Master/Slave selection in bit 4
;
;  Exit with:
;       AX, BX, DX are destroyed
;
;-----------------------------------------------------------------------------
wr_lba:
        push    ax
        push    dx

;	lda		IDE_LBA0+3			; MSB
;	ani		0fh
;	ori		0e0h
;	mov		c,a
;	mvi		a,ide_head
        mov     al,10h          ; Master/Slave mask
        and     al,cl           ; mask bit
        mov     bl,dh           ; high order
        and     bl,00Fh
        or      bl,0E0h         ; mark as LBA
        or      bl,al           ; Select Master/Slave
        mov     al,ide_head
	call	ide_write
	
;	lda		IDE_LBA0+2
;	mov		c,a
;	mvi		a,ide_cyl_msb
        pop     bx              ; get DL to BL
        mov     al,ide_cyl_msb
	call	ide_write
	
;	lda		IDE_LBA0+1
;	mov		c,a
;	mvi		a,ide_cyl_lsb
        pop     bx
        push    bx
        mov     bl,bh
        mov     al,ide_cyl_lsb
	call	ide_write
	
;	lda		IDE_LBA0+0			; LSB
;	mov		c,a
;	mvi		a,ide_sector
        pop     bx              ; get LSB to BL
        mov     al,ide_sector
	call	ide_write
	
;	mvi		c,1
;	mvi		a,ide_sec_cnt
        mov     bl,1
        mov     al,ide_sec_cnt
	call	ide_write
	
	ret
	
;-------------------------------------------------------------------------------

; Low Level I/O to the drive.  These are the routines that talk
; directly to the drive, via the 8255 chip.  Normally a main
; program would not call to these.

; Do a read bus cycle to the drive, using the 8255.
	;input A = ide regsiter address
	;output C = lower byte read from ide drive
	;output B = upper byte read from ide drive
        ;
;  Call With:
;       AL = ide register address
;  Exit With:
;       BX = word read from ide drive
;       AX and DX are destroyed
;
ide_read:
        push    ax              ; save register address
	call	set_ppi_rd		; setup for a read cycle
        pop     ax
	
        mov     dl,IDECTL & 255
        out     dx,al                   ; drive address onto control lines
        or      al,ide_rd_line          ; assert RD pin
        out     dx,al

        push    ax
        mov     dl,IDELSB & 255
        in      ax,dx                   ; retrieve LSB and MSB
        mov     bx,ax                   ; return in BX

	
        pop     ax                      ; restore register value
        xor     al,ide_rd_line          ; deassert RD signal
        mov     dl,IDECTL & 255
        out     dx,al
        xor     al,al
        out     dx,al                   ; deassert all control pins

	ret

	


; Do a write bus cycle to the drive, via the 8255
	;input A = ide register address
	;input register C = lsb to write
	;input register B = msb to write
	;
;  Call With:
;       AL = ide register address
;       BX = word to write out
;
;  Exit with:
;       AX and DX are lost
;

ide_write:
        push    ax
	call	set_ppi_wr		; setup for a write cycle

        mov     ax,bx           ; get parameter word
        mov     dl,IDELSB & 255
        out     dx,ax           ; output LSB and MSB

        pop     ax              ; get register address
        mov     dl,IDECTL & 255
        out     dx,al
        or      al,ide_wr_line
        out     dx,al

        xor     al,ide_wr_line
        out     dx,al

        xor     al,al
        out     dx,al

	ret


;-----------------------------------------------------------------------------------	
; ppi setup routine to configure the appropriate PPI mode
;
; NOTE: these are the only two routines that set DH!!!!
;------------------------------------------------------------------------------------

set_ppi_rd:
;	mvi	a,rd_ide_8255			
;	out	PIO1CONT			;config 8255 chip, read mode
        mov     al,rd_ide_8255
        mov     dx,PIO1CONT
        out     dx,al                   ; configure 8255 chip, read mode
	ret

set_ppi_wr:
;	mvi	a,wr_ide_8255			
;	out	PIO1CONT			;config 8255 chip, write mode
        mov     al,wr_ide_8255
        mov     dx,PIO1CONT
        out     dx,al                   ; configure 8255 chip, write mode
	ret
	


;-----------------------------------------------------------------------------
; End of PPIDE disk driver
;
; Begin SBC-188 BIOS code
;------------------------------------------------------------------------------------	
%ifndef STANDALONE
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  BIOS call entry for PPIDE Fixed Disk driver
;       int  13h
;
; The Fixed Disk driver will move the vector from 13h to 40h
; At the moment there is no Fixed Disk Driver
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        global  PPIDE_BIOS_call_13h
PPIDE_BIOS_call_13h:          ; Floppy driver entry
        sti                     ; Enable interrupts
        pushm   all,ds,es       ; Standard register save
        mov     bp,sp           ; establish stack addressing
        push    bios_data_seg
        popm    ds              ; establish addressability
        cld
; above done in general Fixed disk entry point


	global	PPIDE_entry
PPIDE_entry:
        xor     bh,bh           ; zero extend byte
        mov     bl,ah           ; set to index into dispatch table
        cmp     ah,max/2
        jae     try_extended
        shl     bx,1            ; index words

    cs  jmp     near [dispatch+bx]

try_extended:
        sub     bl,41h          ; start of extended calls
        cmp     bl,max41/2
        jae     undefined
        shl     bx,1            ; index word addresses
    cs  jmp     near [dispatch41+bx]


;fn00:           ; Reset Disk System
fn01:           ; Get Disk System Status
;fn02:           ; Read Sector
;fn03:           ; Write Sector
;fn04:           ; Verify Sector
fn05:           ; Format Track
fn06:           ; Format Bad Track (fixed disk) [PC]
fn07:           ; Format Drive (fixed disk)     [PC]
;fn08:           ; Get Drive Parameters
fn09:           ; Initialize Fixed Disk Characteristics [PC,AT,PS/2]
fn0A:           ; Read Sector Long (fixed disk) [PC,AT,PS/2]
fn0B:           ; Write Sector Long (fixed disk) [PC,AT,PS/2]
fn0C:           ; Seek (fixed disk)
fn0D:           ; Reset Fixed Disk System
fn0E:           ; Read Sector Buffer (fixed disk) [PC only]
fn0F:           ; Write Sector Buffer (fixed disk) [PC only]
fn10:           ; Get Drive Status (fixed disk)
fn11:           ; Recalibrate Drive (fixed disk)
fn12:           ; Controller RAM Diagnostic (fixed disk) [PC/XT]
fn13:           ; Controller Drive Diagnostic (fixed disk) [PC/XT]
fn14:           ; Controller Internal Diagnostic (fixed disk) [PC,AT,PS/2]
;fn15:           ; Get Disk Type                 [AT]
fn16:           ; Get Disk Change Status (floppy)
fn17:           ; Set Disk Type (floppy)
fn18:           ; Set Media Type for Format (floppy)

;fn41:           ; Check Extensions Present
;fn42:           ; Extended Read
;fn43:           ; Extended Write
;fn44:           ; Extended Verify
fn45:           ; Lock/Unlock Drive
fn46:           ; Eject Drive
;fn47:           ; Extended Seek
;fn48:           ; Get Drive Parameters
fn49:           ; Get Extended Disk Change Status
;fn4E:           ; Set Hardware Configuration

;;;        global  undefined
undefined:
%if SOFT_DEBUG
        int 0
%endif
        mov     AH,01h                  ; Invalid command

exit_sequence:
        mov     [bp+offset_AH],ah       ; set the error code
;;;        mov     [fdc_status],ah         ; save error code
        or      ah,ah
        jnz     error_exit
good_exit:
        and     byte [bp+offset_FLAGS],~1       ; clear the carry
        jmp     exit_pops
error_exit:
        or      byte [bp+offset_FLAGS],1        ; set the carry
exit_pops:
        mov     sp,bp
        popm    ALL,ds,es
        iret


dispatch:
        dw      fn00    ; Reset Disk System
        dw      fn01    ; 
        dw      fn02
        dw      fn03
        dw      fn04
        dw      fn05
        dw      fn06
        dw      fn07
        dw      fn08
        dw      fn09
        dw      fn0A
        dw      fn0B
        dw      fn0C
        dw      fn0D
        dw      fn0E
        dw      fn0F
        dw      fn10
        dw      fn11
        dw      fn12
        dw      fn13
        dw      fn14
        dw      fn15
        dw      fn16
        dw      fn17
        dw      fn18
max     equ     $-dispatch

dispatch41:
        dw      fn41
        dw      fn42
        dw      fn43
        dw      fn44
        dw      fn45
        dw      fn46
        dw      fn47
        dw      fn48
        dw      fn49
        dw      undefined       ; 4A
        dw      undefined       ; 4B
        dw      undefined       ; 4C
        dw      undefined       ; 4D
        dw      fn4E
max41   equ     $-dispatch41



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; integrity:    Check integrity of fixed disk table
;
;  Call with:
;       DL = device code (80 or 81)
;       DS set to BIOS data area
;
;  Exit with:
;       DS:SI points at the fixed disk table
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
        jae     undefined               ; harsh error exit
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
        jnz     error_exit              ; BIOS data area clobbered

        popm    ax,cx
        ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; cv_lba        Convert CHS in CX & DX to LBA address in DX:AX
;
;  Call with:
;       DS:SI points to fixed disk table
;       CX & DX are CHS input parameters
;
;  Exit with:
;       DX:AX is the corresponding LBA address
;       BX and CX are modified
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cv_lba:
        mov     ax,cx           ; cylinder info to AX
        rol     al,2            ; position high 2 bits
        and     al,3            ; mask 2 bits
        xchg    al,ah           ; AX = cylinder number
        shr     dx,8            ; heads to DL   DH=0

        mov     bx,dx           ; heads to BX
        mov     dl,[fx_log_heads - fx80 + si]   ; may be 0, meaning 256
        dec     dl
        inc     dx              ; recover 256 !!!

        mul     dx
        add     ax,bx           ; add in the head number
        adc     dx,0            ; **

        mov     bl,[fx_log_sectors - fx80 + si]    ; BH is already 0
        push    cx
        call    @mulLS          ; DX:AX = DX:AX * BX
        pop     cx
        dec     cl              ; sector address is from 1, not 0
        and     cx,63
        add     ax,cx           ; add in sector number
        adc     dx,0            ; **
        ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fn00 -- Reset the Disk Subsystem
;
;  Call with:
;       AH = 0  function code
;
;  Exit with:
;       Nothing
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn00:
        call    integrity       ; perhaps no subsystem
        call    ide_hard_reset  ; do the dirty
        mov     ah,0
        jmp     exit_sequence





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fn02 -- Disk Read
; fn03 -- Disk Write
; fn04 -- Disk Verify
;
;  Enter with:
;       AH = 2 (read)
;       AH = 3 (write)
;       AH = 4 (verify)
;       AL = number of sectors to transfer
;       CH = low 8 bits of cylinder number
;       CL = sector number & high 2 bits of sector number
;       DH = head number
;       DL = device code
;       ES:BX = buffer to receive/provide the data (except on verify)
;
;  Exit with:
;       AH = success(0) or error code
;       Carry flag set, if error; clear otherwise
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn02:
fn03:
fn04:
        call    integrity       ; set pointer to Fixed Disk Table in SI
        call    cv_lba          ; convert to LBA address in DX:AX
        mov     cl,[fx_drive_control - fx80 + si]
        mov     ch,[bp + offset_AL]      ; get sector count
        mov     bx,[bp + offset_BX]      ; get transfer address

; Enter here on Read, Write, Verify or
;     extended  Read, Write, Verify, Seek
RWV: 
        inc     ch                      ; zero is valid for no transfer
        jmp     .6              ; enter loop at the bottom
; the read/write/verify loop
.1:
        test    cl,40h          ; test LBA bit in drive control
        jz      .7
; LBA call is okay
        test    byte [bp+offset_AH],04h         ; Seek/Verify?
        jnz     .4
        test    byte [bp+offset_AH],01h         ; Write?
        jnz     .3
.2:     call    @PPIDE_READ_SECTOR
        jmp     .5
.3:     call    @PPIDE_WRITE_SECTOR
        jmp     .5
.4:     call    @PPIDE_VERIFY_SECTOR

.5:
        add     ax,1            ; increment the LBA address
        adc     dx,0            ; **
        add     bh,2            ; add 512 == 200h to the BX
        jnc     .6
        mov     di,es
        add     di,10h
        mov     es,di           ; update the segment register
.6:     dec     ch
        jnz     .1
        jmp     .8

; CHS call is required
.7:     call    undefined

.8:     
        xor     ah,ah
        jmp     exit_sequence



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fn08  --  Get Drive Parameters
;
;  Call with:
;       AH = 8  function code
;       DL = drive code (80h, 81h, ...)
;
;  Exit with:
;       CH = maximum cylinder number (low 8 bits)
;       CL = max. sector number; max. cyl in high 2 bits
;       DH = maximum head number
;       DL = number of fixed disks

;       AH = 0  and Carry is clear on success
;       AH = error code; Carry set on error
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn08:           ; Get Drive Parameters
        mov     byte [bp + offset_DL],0         ; say no fixed disks

        call    integrity       ; bad device code or no fixed disks

        mov     ax,[fx_log_cylinders - fx80 + si]
        dec     ax
        shl     ah,6
        or      ah,[fx_log_sectors - fx80 + si]
        xchg    al,ah
        mov     [bp + offset_CX],ax
        mov     dh,[fx_log_heads - fx80 + si]
        dec     dh
%if 0
        mov     dl,[n_fixed_disks]      ; return parameter
%else
	call	get_IDE_num		; get number of IDE disks
	mov	dl,al
%endif
        mov     [bp + offset_DX],dx

        xor     ah,ah
        jmp     exit_sequence


        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fn15 -- Get Disk Type
;
;  Call With:
;       AH = 15   function code
;       DL = device code (80h or 81h)
;
;  Exit With:
;     If successful, Carry is clear
;       AH = 3  indicating a hard disk
;       CX:DX   number of hard disk sectors
;
;     If unsuccessful, Carry is set
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn15:
        call    integrity       ; sets DS:SI
        mov     ax,[fx_log_cylinders - fx80 + si]
        mov     bl,[fx_log_heads - fx80 + si]
        xor     bh,bh
        dec     bl              ; 00 means 256
        inc     bx              ; do the conversion
        mul     bx              ; cyls * heads
        mov     bl,[fx_log_sectors - fx80 + si]
        xor     bh,bh
        call    @mulLS          ; cyls * heads * sectors
        mov     word [bp+offset_CX],dx  ; high order
        mov     word [bp+offset_DX],ax  ; low order word
        mov     byte [bp+offset_AH],3   ; code for HARD DISK
        jmp     good_exit



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
fn41:
        call    integrity       ; test drive number (sets DS:SI)
        cmp     word [offset_BX + bp],55AAh
        jne     undefined
        test    byte [fx_drive_control - fx80 + si],40h         ; test LBA bit
        jz      undefined

        mov     byte [offset_AH + bp],21h       ; version 1.1
        mov     word [offset_BX + bp],0AA55h    ; magic number II
        mov     word [offset_CX + bp],00000101b       ; packet calls & EDD i/f
        jmp     good_exit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fn42 -- Extended Read
; fn43 -- Extended Write
; fn44 -- Extended Verify
; fn47 -- Extended Seek (implement as Verify)
;
;  Call With:
;       AH = function code
;       AL = 0,1 write with no verify; 2 write with verify
;            not used for Read or Verify
;       DL = drive number (80h or 81h)
;       [DS:SI] was disk packet address; will be used in ES:BX
;
;  Exit With:
;       AH = 0 (no error) and Carry Clear
;       AH = error code and Carry Set
;     The block count field is updated with the number of blocks
;     correctly transferred/verified before the error occurred.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn42:
fn43:
fn44:
fn47:
        call    integrity       ; set pointer to Fixed Disk Table in SI
        mov     es,[bp + offset_DS]     ; packet pointer
        mov     bx,[bp + offset_SI]     ; **
   es   cmp     byte [bx + pkt_size],16 ; check for correct size
        jb      undefined

   es   mov     ax,[bx + pkt_LBA3]      ; LBA address
   es   or      ax,[bx + pkt_LBA2]      ; LBA address
        jnz     undefined
   es   mov     ax,[bx + pkt_LBA0]      ; LBA address
   es   mov     dx,[bx + pkt_LBA1]      ; LBA address hi

        mov     ch,1                    ; assume Seek
        cmp     byte [offset_AH + bp],47h       ; Seek?
        je      .7
   es   mov     ch,[bx + pkt_blocks]    ; sector count
.7:
        mov     cl,[fx_drive_control - fx80 + si]
   es   les     bx,[bx + pkt_address]   ; get transfer address

        jmp     RWV             ; common read/write/verify code


        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fn48 -- Get Drive Parameters
;
;  Call With:
;       AH = 48h        function code
;       DL = drive number
;       DS:SI = pointer to return buffer (26 or 30 bytes)
;
;  Exit With:
;       AH = 0 and carry clear
;       results in the buffer
;
;       AH = error code and carry set
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn48:
        call    integrity               ; set DS:SI
        mov     es,[bp + offset_DS]     ; packet pointer
        mov     bx,[bp + offset_SI]     ; **
        mov     cx,0FFFFh               ; CX = -1  (FFFFh)
        mov     ax,pkt_ptr              ; AX = 26
   es   cmp     [bx + pkt_size],ax      ; check for correct size = 26
        jb      undefined
        add     ax,4
   es   cmp     [bx + pkt_size],ax      ; check for correct size = 30
        jb      .1
   es   mov     [bx + pkt_ptr],cx       ; flag invalid pointer
   es   mov     [bx + pkt_ptr+2],cx     ; **
.1:
   es   mov     [bx + pkt_size],ax      ; set the returned size

        inc     cx                      ; CX = 0
   es   mov     word [bx + pkt_info], 000011b   ; DMA bound/ Geom OK

        mov     ax,[fx_phys_cylinders - fx80 + si]      ; cylinders
   es   mov     [bx + pkt_phys_cyl],ax  
   es   mov     [bx + pkt_phys_cyl+2],cx

        mov     al,[fx_phys_heads - fx80 + si]          ; heads
        mov     ah,ch
   es   mov     [bx + pkt_phys_hds],ax  
   es   mov     [bx + pkt_phys_hds+2],cx

        mov     al,[fx_phys_sectors - fx80 + si]        ; sectors
   es   mov     [bx + pkt_phys_spt],ax  
   es   mov     [bx + pkt_phys_spt+2],cx

        mov     ax,[fx_LBA_low - fx80 + si]             ; total LBA sectors
   es   mov     [bx + pkt_sectors],ax                   ; total sectors
        mov     ax,[fx_LBA_high - fx80 + si]            ; **
   es   mov     [bx + pkt_sectors+2],ax                 ; **
   es   mov     [bx + pkt_sectors+4],cx                 ; **
   es   mov     [bx + pkt_sectors+6],cx                 ; **
   es   mov     word [bx + pkt_bytes],512               ; sector size
        mov     ah,0
        jmp     exit_sequence



        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fn4E -- set hardware configuration
;
;  Call With:
;       AH = 4Eh        function code
;       AL = hardware function sub-code
;       DL = drive number
;
;  Exit With:
;       AH = 0          carry is clear
;       AL = 1          other devices affected
;
;       AH = error code and carry is set
;
;  This operation is a complete No-Op for the PPIDE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn4E:
        call    integrity
        mov     ax,0001h
        jmp     exit_sequence




%endif  ; STANDALONE


