%define DEBUG 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IDE8.ASM -- SBC188v3 IDE8 (8-bit) driver
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   This version is for assembly by  NASM 0.98.39 or later
;
; Copyright (C) 2020 John R. Coffman.  All rights reserved.
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

        global  IDE8_BIOS_call_13h
        global  _IDE8_WRITE_SECTOR
        global  _IDE8_READ_SECTOR
        global  _IDE8_READ_ID
        extern  @mulLS
        extern  microsecond
        extern	FIXED_error	; invalid command
        extern	lites

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
;;ide_dmack	equ	9		; DMA acknowledge
;;  the below are different for v3 IDE8; usually 0Eh & 0Fh
ide_control	equ	16h		; aux control port
ide_astatus	equ	17h		; aux status port

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

; IDE interface Features
SET_8BIT	equ    0x01
RESET_8BIT	equ    0x81
SET_16BIT	equ    RESET_8BIT


	SEGMENT	_TEXT
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  BIOS call entry for IDE8 Fixed Disk driver
;       int  13h
;
; The Fixed Disk driver will move the vector from 13h to 40h
; At the moment there is no Fixed Disk Driver
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IDE8_BIOS_call_13h:          ; Floppy driver entry
        sti                     ; Enable interrupts
        pushm   all,ds,es       ; Standard register save
        mov     bp,sp           ; establish stack addressing
        push    bios_data_seg
        popm    ds              ; establish addressability
        cld

	global	IDE8_entry
IDE8_entry:
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

undefined:
%if SOFT_DEBUG & 0
        int 0
%endif
        mov     ah,ERR_invalid_command     ; Invalid command
	jmp	error_exit

good_exit:
	xor	ah,ah			; clear the carry, AH=0
exit_sequence:
        or      ah,ah
        jz     exit_pops
error_exit:
	stc				; set the carry
exit_pops:
        mov     [bp+offset_AH],ah          ; set the error code
        mov     sp,bp			; deallocate any variables
        popm    ALL,ds,es
        retf	2			; rather than IRET


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



; -----------------------------------------------------------------------------	
;  IDE8_READ_ID
; -----------------------------------------------------------------------------	
; Read the 512 byte ID information from the attached drive
;
;  int __cdecl IDE8_READ_ID(far byte *buffer, byte slave);
;
;
;-----------------------------------------------------------------------------
_IDE8_READ_ID:
        push    bp
        mov     bp,sp
        pushm   es,bx,di
%if DEBUG
	push	0x81
	call	lites
%endif

	mov	di,IDE8_CS0

	call	ide_wait_not_busy		;make sure drive is ready
%if DEBUG
	push	0x82
	call	lites
%endif

        xor     ax,ax
        xor     dx,dx
        mov     cx,ARG(3)               ; select Master/Slave
        call    wr_lba                  ; select device
%if DEBUG
	push	0x83
	call	lites
%endif

;;;	call	ide_set_8bit
	
%if DEBUG
	push	0x85
	call	lites
%endif


	mov	al,ide_cmd_ident
	lea	dx,[ide_command+di]
	out	dx,al
%if DEBUG
	push	0x86
	call	lites
%endif


	call	ide_wait_drq			;wait until it's got the data
%if DEBUG
	push	0x87
	call	lites
%endif


        les     bx,ARG(1)
	call	read_data				;grab the data
%if DEBUG
	push	0x88
	call	lites
%endif


        xor     ax,ax
%if DEBUG
	push	ax
	call	lites
%endif

        popm    es,bx,di
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
@IDE8_READ_SECTOR:
        pushm   bx,es,ax,dx,cx
        call    _IDE8_READ_SECTOR
        popm    bx,es,ax,dx,cx
        ret

_IDE8_READ_SECTOR:
        push    bp
        mov     bp,sp
        pushm   es,bx,di

        mov     cx,ARG(5)
; set device code into DI
	mov	di,IDE8_CS0
	and	cl,0F0h

	call	ide_wait_not_busy		;make sure drive is ready

        mov     ax,ARG(3)
        mov     dx,ARG(4)
	call	wr_lba					;tell it which sector we want


        mov     al,ide_cmd_read
	lea	dx,[ide_command+di]
	out	dx,al

	call	ide_wait_drq			;wait until it's got the data
        les     bx,ARG(1)
	call	read_data				;grab the data
        xor     ax,ax

        popm    es,bx,di
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
@IDE8_VERIFY_SECTOR:
        pushm   ax,dx,cx
        call    _IDE8_VERIFY_SECTOR
        popm    ax,dx,cx
        ret

_IDE8_VERIFY_SECTOR:
        push    bp
        mov     bp,sp
        pushm   es,bx,di

        mov     cx,ARG(3)
; set device code into DI
	mov	di,IDE8_CS0
	and	cl,0F0h

	call	ide_wait_not_busy		;make sure drive is ready

        mov     ax,ARG(1)
        mov     dx,ARG(2)
	call	wr_lba					;tell it which sector we want

   	mov	al,ide_cmd_read
	lea	dx,[ide_command+di]
	out	dx,al

	call	ide_wait_drq			;wait until it's got the data
	call	verify_data				;grab the data
        xor     ax,ax

        popm    es,bx,di
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
@IDE8_WRITE_SECTOR:
        pushm   bx,es,ax,dx,cx
        call    _IDE8_WRITE_SECTOR
        popm    bx,es,ax,dx,cx
        ret

_IDE8_WRITE_SECTOR:
        push    bp
        mov     bp,sp
        pushm   es,bx,di

        mov     cx,ARG(5)
; set device code into DI
	mov	di,IDE8_CS0
	and	cl,0F0h

	call	ide_wait_not_busy	;make sure drive is ready

        mov     ax,ARG(3)
        mov     dx,ARG(4)
	call	wr_lba				;tell it which sector we want
        
	mov	al,ide_cmd_write
	lea	dx,[ide_command+di]
	out	dx,al

	call	ide_wait_drq		;wait unit it wants the data
        les     bx,ARG(1)
	call	write_data			;give the data to the drive
	call	ide_wait_not_busy	;wait until the write is complete
        xor     ax,ax
        
        popm    es,bx,di
        leave
	ret


ST_ERROR	equ	01h		; error Stauts
;------------ide_set_8bit-----------------------------------------------------
; set the device for 8-bit transfers
;-----------------------------------------------------------------------------
ide_set_8bit:
	lea	dx,[ide_feature+di]
	mov	al,SET_8BIT
	out	dx,al
	call	ide_wait_ready
	
	lea	dx,[ide_command+di]
	mov	al,ide_cmd_set_feature
	out	dx,al
	
	mov	cx,4000
;;.1:	loop	.1
	call	ide_wait_ready
	
	lea	dx,[ide_status+di]
	in	al,dx

	test	al,ST_ERROR		; error flag set
	jnz	FIXED_error
	
	ret
	

;-----------------------------------------------------------------------------
; Device Control register bits
%define  CTRL_ALWAYS    0x08
; bit 3 must always be asserted when written
%define  CTRL_RESET     0x04
%define  CTRL_nIEN      0x02
; interrupt enable is active when == 0

;--------ide_soft_reset-------------------------------------------------------
;
;     Do a soft reset on the drive
;
;  Call with:
;       DI = device code of controller
;
;  Exit with:
;       AX and DX are destroyed
;
;-------------------------------------------------------------------------------------------	
ide_soft_reset:
        pushm   cx

	lea	dx,[ide_control+di]	; get device code of alt. control
 	mov	al,CTRL_ALWAYS | CTRL_RESET | CTRL_nIEN
	out	dx,al

        mov     cx,500                ; 500usec delay
        call    microsecond

 	mov	al,CTRL_ALWAYS | CTRL_nIEN
	out	dx,al

        popm    cx
	ret


;------------------------------------------------------------------------------
; IDE INTERNAL SUBROUTINES 
;------------------------------------------------------------------------------



;-----------------------------------------------------------------------------
;  Wait for RDY to be set
;
;  Exit with:
;       AL contains status
;       All other registers preserved
;
;------------------------------------------------------------------------------
ide_wait_not_busy:
        pushm   dx
.1:
	lea	dx,[ide_status+di]
	in	al,dx

        and     al,10000000b
        jnz     .1

        popm    dx
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
	lea	dx,[ide_status+di]
	in	al,dx

        and     al,11000000b            ;Mask off busy and ready bits
        xor     al,01000000b            ;We want Busy(7) to be 0 and Ready(6) to be 1
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
   	lea	dx,[ide_status+di]
	in	al,dx

        and     al,10001000b		; Mask off Busy(7) and DRQ(3)
        xor     al,00001000b		; We want Busy(7) to be 0 and DRQ (3) to be 1

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
        pushm   bx,cx

	lea	dx,[ide_data8+di]
        xchg    di,bx
	mov     cx,512          ; sector size in bytes

%if 1
rdblk2:
	in	al,dx
	nop
	stosb

        loop    rdblk2
%else
	rep	insb
%endif
	xchg	di,bx

        popm    bx,cx
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
        pushm   cx

	lea	dx,[ide_data16+di]

	mov	cx,512		; sector size in bytes

verblk2:
	nop
	nop
	nop
	in	al,dx

        loop    verblk2

        popm    cx
	ret

;-----------------------------------------------------------------------------
;Write a block of 512 bytes (at HL) to the drive
; Write a block of 512 bytes (at ES:BX to the drive)
;
;  Call with:
;       ES:BX -- pointer to the data block
;	DI = primary or secondary base device code
;
;  Exit with:
;       AX and DX are destroyed; other registers preserved
;
;-----------------------------------------------------------------------------
write_data:
        pushm   cx,si,ds

	push	es
	popm	ds

        mov     cx,512          ; 512 bytes = 256 words
        mov     si,bx           ; use SI for the loads
	lea	dx,[ide_data8+di]
%if 1
wrblk2: 
	lodsb	     		; slow loop
	nop
	nop
	out	dx,al
        loop            wrblk2
%else
	rep	outsb		; fastest
%endif
        popm    cx,si,ds
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

        mov     al,10h          ; Master/Slave mask
        and     al,cl           ; mask bit
        mov     bl,dh           ; high order
        and     bl,00Fh
        or      bl,0E0h         ; mark as LBA
	or	al,bl
	lea	dx,[ide_head+di]
	out	dx,al
	
        pop     bx              ; get DL to BL
	mov	al,bl
	dec	dx
	out	dx,al

        pop     bx
	mov	al,bh
	dec	dx
	out	dx,al
	
	mov	al,bl
	dec	dx
	out	dx,al
	
	mov	al,1
	dec	dx
	out	dx,al

	call	ide_set_8bit
		
	ret
	
;-------------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; End of IDE8 disk driver
;
; Begin SBC-188 BIOS code
;------------------------------------------------------------------------------------	
%ifndef STANDALONE
	


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
ERR_media_type_not_found        equ     12
ERR_uncorrectable_CRC_error     equ     10h
ERR_controller_failure  equ     20h
ERR_seek_failed         equ     40h
ERR_disk_timeout        equ     80h


; Packet call offsets
;
pkt_size        equ     0       ; byte, size of packet (==16)
pkt_reserved1   equ     1       ; byte, reserved, must be zero
pkt_blocks      equ     2       ; byte, number of blocks to transfer
                                ; max is 127 (7Fh); 0 means no transfer
pkt_reserved3   equ     3       ; byte; reserved, must be zero
pkt_address     equ     4       ; dword; segment:offset of transfer
pkt_LBA         equ     8       ; qword; LBA of transfer
; for convenience:
pkt_LBA0        equ     8       ; word
pkt_LBA1        equ     10      ; word
pkt_LBA2        equ     12      ; word          ; MBZ
pkt_LBA3        equ     14      ; word          ; MBZ

; Parameter Packet returns:
;
;pkt_size       equ     0       ; word
pkt_info        equ     2       ; word, information bits
        ; bit   usage
        ;  0    DMA boundary errors are handled transparently
        ;  1    Geometry valid (bytes 8-12)
        ;  2    Removable device (no)
        ;  3    Supports Write with Verify (no)
        ;  4    change line support (no)
        ;  5    removable & lockable (no)
        ;  6    max. geometry for a removable drive (no)
        ;  7-15  MBZ
pkt_phys_cyl    equ     4       ; dword, physical cylinders
pkt_phys_hds    equ     8       ; dword, physical heads
pkt_phys_spt    equ     12      ; dword, sectors per track
pkt_sectors     equ     16      ; qword, total number of sectors
pkt_bytes       equ     24      ; word, bytes per sector
pkt_ptr         equ     26      ; dword, EDD configuration paramter pointer
                                ; FFFF:FFFF means invalid pointer


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; integrity:    Check integrity of fixed disk table
;
;  Call with:
;       DL = device code (80 or 81)
;       DS set to BIOS data area
;
;  Exit with:
;       DS:SI points at the fixed disk table
;	DI = device code
;
;  Error Exit:
;       If the disk table checksum is bad, give immediate error return
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
integrity:
        pushm   ax,cx
%if DEBUG
	push	0x70
	call	lites        
%endif
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
.0:	add     si,cx                   ; point at fx8?
	dec	al
	jnz	.0
.1:
	mov	di,IDE8_CS0		; first controller device code

        push    si
        mov     ax,0EE00h               ; error code and zero checksum

.2:     add     al,[si]                 ; compute checksum
        inc     si
        loop    .2                      ; loop back

        pop     si
        or      al,al                   ; test AL for zero
        jnz     error_exit              ; BIOS data area clobbered
%if DEBUG
	push	0x7F
	call	lites
%endif

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
        call    ide_soft_reset  ; do the dirty
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
.2:     call    @IDE8_READ_SECTOR
        jmp     .5
.3:     call    @IDE8_WRITE_SECTOR
        jmp     .5
.4:     call    @IDE8_VERIFY_SECTOR

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
        mov     ah,3   			; code for HARD DISK
        clc
        jmp     exit_pops



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
;  This operation is a complete No-Op for the IDE8
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn4E:
        call    integrity
        mov     ax,0001h
        jmp     exit_sequence




%endif  ; STANDALONE


