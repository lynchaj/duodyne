	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; USB.ASM - - CH376S USB Module Fixed Disk Driver
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; This version is for assembly by NASM 0.98.39 or later
	;
	; This program is free software: you can redistribute it and / or modify
	; it under the terms of the GNU General Public License as published by
	; the Free Software Foundation, either version 3 of the License, or
	; (at your option) any later version.
	;
	; This program is distributed in the hope that it will be useful,
	; but WITHOUT ANY WARRANTY; without even the implied warranty of
	; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	; GNU General Public License for more details.
	;
	; You should have received a copy of the GNU General Public License
	; along with this program. If not, see <http: / / www.gnu.org / licenses / >.
	;
	; https: / / www.wch - ic.com /
	;
	; Thanks and credit to Alan Cox. Much of this driver is based on
	; his code in FUZIX (https: / / github.com / EtchedPixels / FUZIX),
	; and the code in the RomWBW CH37X driver.
	;
	; This file is the core driver file for the CH37x devices. The
	; CH376 supports both a USB Drive interface and an SD Card interface,
	; however this code only supports the USB interface (for now).
	; The USB support is implemented as pure raw sector I / O. The CH376
	; file - level support is not utilized.
	;
	; NOTES:
	; - There seem to be compatibility issues with older USB thumb drives.
	; Such drives will complete DISK_INIT successfully, but then return
	; an error attempting to do any I / O. The error is 17h indicating
	; the CH37x encountered an overflow during communication with the
	; device. It seems that adding a DISK_MOUNT command (only possible
	; on CH376) resolved the issue for some devices, so that has been
	; added to the RESET routine when using CH376.
	;
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	%include "config.asm"
	%include "cpuregs.asm"
	%include "equates.asm"
	%include "disk.inc"

	; CHUSB DEVICE STATUS
	;
	CHUSB_STOK equ 0
	CHUSB_STNOMEDIA equ - 1
	CHUSB_STCMDERR equ - 2
	CHUSB_STIOERR equ - 3
	CHUSB_STTO equ - 4
	CHUSB_STNOTSUP equ - 5
	;
	;
	; CH MODE MANAGEMENT
	;
	CH_MODE_UNK equ 0            ; CURRENT MODE UNKNOWN
	CH_MODE_USB equ 1            ; CURRENT MODE = USB
	CH_MODE_SD equ 2             ; CURRENT MODE = SD
	;
	; CH375 / 376 COMMANDS
	;
	CH_CMD_VER equ 01h           ; GET IC VER
	CH_CMD_RESET equ 05h         ; FULL CH37X RESET
	CH_CMD_EXIST equ 06h         ; CHECK EXISTS
	CH_CMD_MAXLUN equ 0Ah        ; GET MAX LUN NUMBER
	CH_CMD_PKTSEC equ 0Bh        ; SET PACKETS PER SECTOR
	CH_CMD_SETRETRY equ 0Bh      ; SET RETRIES
	CH_CMD_FILESIZE equ 0Ch      ; GET FILE SIZE (376)
	CH_CMD_MODE equ 15h          ; SET USB MODE
	CH_CMD_TSTCON equ 16h        ; TEST CONNECT
	CH_CMD_ABRTNAK equ 17h       ; ABORT DEVICE NAK RETRIES
	CH_CMD_STAT equ 22h          ; GET STATUS
	CH_CMD_RD6 equ 27h           ; READ USB DATA (375 & 376)
	CH_CMD_RD5 equ 28h           ; READ USB DATA (375)
	CH_CMD_WR5 equ 2Bh           ; WRITE USB DATA (375)
	CH_CMD_WR6 equ 2Ch           ; WRITE USB DATA (376)
	CH_CMD_WRREQDAT equ 2Dh      ; WRITE REQUESTED DATA (376)
	CH_CMD_SET_FN equ 2Fh        ; SET FILENAME (376)
	CH_CMD_DSKMNT equ 31h        ; DISK MOUNT
	CH_CMD_FOPEN equ 32h         ; FILE OPEN (376)
	CH_CMD_FCREAT equ 34h        ; FILE CREATE (376)
	CH_CMD_BYTE_LOC equ 39h      ; BYTE LOCATE
	CH_CMD_BYTERD equ 3Ah        ; BYTE READ
	CH_CMD_BYTERDGO equ 3Bh      ; BYTE READ GO
	CH_CMD_BYTEWR equ 3Ch        ; BYTE WRITE
	CH_CMD_BYTEWRGO equ 3Dh      ; BYTE WRITE GO
	CH_CMD_DSKCAP equ 3Eh        ; DISK CAPACITY
	CH_CMD_AUTOSET equ 4Dh       ; USB AUTO SETUP
	CH_CMD_DSKINIT equ 51h       ; DISK INIT
	CH_CMD_DSKRES equ 52h        ; DISK RESET
	CH_CMD_DSKSIZ equ 53h        ; DISK SIZE
	CH_CMD_DSKRD equ 54h         ; DISK READ
	CH_CMD_DSKRDGO equ 55h       ; CONTINUE DISK READ
	CH_CMD_DSKWR equ 56h         ; DISK WRITE
	CH_CMD_DSKWRGO equ 57h       ; CONTINUE DISK WRITE
	CH_CMD_DSKINQ equ 58h        ; DISK INQUIRY
	CH_CMD_DSKRDY equ 59h        ; DISK READY

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Error, Okay, Complete status conditions
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	%define Error stc
	; test with:
	; JC xxx (jump on error)
	; JNC xxx (jump on no error)

	%define Okay xor ah, ah
	; test with:
	; JZ xxx (jump okay)
	; JNZ xxx (jump not okay)

	%define Complete or ah, 3
	; test with:
	; JA xxx (jump complete AND no error)
	; JNZ xxx (jump complete)
	; JZ xxx (jump not complete)

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	global _USB_WRITE_SECTOR
	global _USB_READ_SECTOR
	global _USB_READ_ID
	extern @mulLS
	extern microsecond
	extern wait12



	SEGMENT _TEXT

	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	; CH376S USB Module Fixed Disk Driver
	;
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	; USB_READ_ID
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	; Read the ID information from the attached drive
	;
	; int USB_READ_ID(far byte * buffer, byte slave);
	;
	;
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
_USB_READ_ID:
	push bp
	mov bp, sp
	pushm es, bx

	;mov cx, ARG(3) ; select unit 0=usb / 1=sd

	les bx, ARG(1)               ; CLEAR OUT DATA AREA
	mov di, bx
	mov cx, 512
.1:
	es mov byte [di], 0
	inc di
	loop .1

	call CHUSB_RESET             ; RESET & DISCOVER MEDIA

	call CHUSB_DSKMNT            ; TRY MOUNT
	; read the 36 byte data structure that is returned
	; id.ModelNumber[40] 27 - 46
	call CH_CMD_RD               ; SEND READ USB DATA CMD
	call CH_RD                   ; READ DATA BLOCK LENGTH
	xor ah, ah
	push ax
	mov cx, 8                    ; ignore the first 8 bytes of data structure
.2:
	call CH_RD
	loop .2
	les bx, ARG(1)
	mov di, bx
	add di, 54
	pop ax
	sub al, 8
	mov cx, ax
.3:
	call CH_RD
	mov ah, al
	xor al, al
	dec cx
	jz .3a
	call CH_RD
	.3a
	es mov word [di], ax
	inc di
	inc di
	loop .3

	les bx, ARG(1)
	mov di, bx
	call CHUSB_DSKSIZ            ; GET AND RECORD DISK SIZE

	es mov word [di + 108], 00   ; id.NumberOfCurrentCylinders
	es mov [di + 110], dx        ; id.NumberOfCurrentHeads
	es mov [di + 112], cx        ; id.CurrentSectorsPerTrack

	es mov [di + 114], cx        ; id.CurrentSectorCapacity
	es mov [di + 116], dx

	es mov [di + 120], cx        ; id.UserAddressableSectors 60 - 61
	es mov [di + 122], dx

	mov dh, dl
	mov dl, ch
	es mov [di + 2], dx          ; id.NumCylinders
	es mov byte [di + 6], 16     ; id.NumHeads
	es mov byte [di + 12], 16    ; id.NumSectorsPerTrack


	les bx, ARG(1)
	mov di, bx
	es mov word [di + 98], 0000001000000000b
	xor ax, ax
	popm es, bx
	leave
	ret



	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	; USB_READ_SECTOR
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	;read a sector, specified by the 4 bytes in "lba",
	;Return, acc is zero on success, non - zero for an error
	;
	; int IDE_READ_SECTOR(far byte * buffer, long lba_sector, byte slave);
	;
	;
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@USB_READ_SECTOR:
	pushm bx, es, ax, dx, cx
	call _USB_READ_SECTOR
	popm  bx, es, ax, dx, cx
	ret

_USB_READ_SECTOR:
	push bp
	mov bp, sp
	pushm es, bx, di

	mov Al, CH_MODE_USB          ; REQUEST USB MODE
	call CH_SETMODE              ; DO IT
	jc CHUSB_CMDERR              ; HANDLE ERROR

	mov cx, ARG(3)
	mov dx, ARG(4)
	mov al, CH_CMD_DSKRD         ; DISK READ COMMAND
	call CHUSB_RWSTART           ; SEND CMD AND LBA(DX:CX)

	les bx, ARG(1)
        mov di,bx
	;
	; READ THE SECTOR IN 64 BYTE CHUNKS
	mov cx, 8                    ; 8 CHUNKS OF 64 FOR 512 BYTE SECTOR
CHUSB_READ1:
	call CH_POLL                 ; WAIT FOR DATA READY
	cmp al, 1Dh                  ; DATA READY TO READ?
	jne CHUSB_IOERR              ; HANDLE IO ERROR
	call CH_CMD_RD               ; SEND READ USB DATA CMD
	call CH_RD                   ; READ DATA BLOCK LENGTH
	cmp al, 64                   ; AS EXPECTED?
	jne CHUSB_IOERR              ; IF NOT, HANDLE ERROR
	;
	; BYTE READ LOOP
	push cx                      ; SAVE LOOP CONTROL
	mov cx, 64                   ; READ 64 BYTES
CHUSB_READ2:
	call CH_RD                   ; GET NEXT BYTE
	es mov [di], al
	add di, 1
	loop CHUSB_READ2             ; LOOP AS NEEDED
	pop cx                       ; RESTORE LOOP CONTROL

	;
	; PREPARE FOR NEXT CHUNK
	mov Al, CH_CMD_DSKRDGO       ; CONTINUE DISK READ
	call CH_CMD                  ; SEND IT
	loop CHUSB_READ1             ; LOOP TILL DONE
	;
	; FINAL CHECK FOR COMPLETION & SUCCESS
	call CH_POLL                 ; WAIT FOR COMPLETION
	cmp al, 14h                  ; SUCCESS?
	jne CHUSB_IOERR              ; IF NOT, HANDLE ERROR

	xor ax, ax
	popm es, bx, di
	leave
	ret


	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	; IDE_VERIFY_SECTOR
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	;read a sector, specified by the 4 bytes in "lba",
	;Return, acc is zero on success, non - zero for an error
	;
	; int IDE_VERIFY_SECTOR(long lba_sector, byte slave);
	;
	;
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@USB_VERIFY_SECTOR:
	pushm ax, dx, cx
	call _USB_VERIFY_SECTOR
	popm ax, dx, cx
	ret

_USB_VERIFY_SECTOR:
	push bp
	mov bp, sp
	pushm es, bx, di

	mov Al, CH_MODE_USB          ; REQUEST USB MODE
	call CH_SETMODE              ; DO IT
	jc CHUSB_CMDERR              ; HANDLE ERROR

	mov cx, ARG(3)
	mov dx, ARG(4)
	mov al, CH_CMD_DSKRD         ; DISK READ COMMAND
	call CHUSB_RWSTART           ; SEND CMD AND LBA(DX:CX)

	les bx, ARG(1)
        mov di,bx
	;
	; READ THE SECTOR IN 64 BYTE CHUNKS
	mov cx, 8                    ; 8 CHUNKS OF 64 FOR 512 BYTE SECTOR
CHUSB_VERIFY1:
	call CH_POLL                 ; WAIT FOR DATA READY
	cmp al, 1Dh                  ; DATA READY TO READ?
	jne CHUSB_IOERR              ; HANDLE IO ERROR
	call CH_CMD_RD               ; SEND READ USB DATA CMD
	call CH_RD                   ; READ DATA BLOCK LENGTH
	cmp al, 64                   ; AS EXPECTED?
	jne CHUSB_IOERR              ; IF NOT, HANDLE ERROR
	;
	; BYTE READ LOOP
	push cx                      ; SAVE LOOP CONTROL
	mov cx, 64                   ; READ 64 BYTES
CHUSB_VERIFY2:
	call CH_RD                   ; GET NEXT BYTE
	es mov ah,[di]
	add di, 1
        cmp ah,al
        jne CHUSB_IOERR
	loop CHUSB_VERIFY2             ; LOOP AS NEEDED
	pop cx                       ; RESTORE LOOP CONTROL

	;
	; PREPARE FOR NEXT CHUNK
	mov Al, CH_CMD_DSKRDGO       ; CONTINUE DISK READ
	call CH_CMD                  ; SEND IT
	loop CHUSB_VERIFY1             ; LOOP TILL DONE
	;
	; FINAL CHECK FOR COMPLETION & SUCCESS
	call CH_POLL                 ; WAIT FOR COMPLETION
	cmp al, 14h                  ; SUCCESS?
	jne CHUSB_IOERR              ; IF NOT, HANDLE ERROR

	xor ax, ax
	popm es, bx, di
	leave
	ret


	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	; IDE_WRITE_SECTOR
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	;write a sector, specified by the 4 bytes in "lba",
	;whatever is in the buffer gets written to the drive!
	;Return, acc is zero on success, non - zero for an error
	;
	; int IDE_WRITE_SECTOR(far byte * buffer, long lba_sector, byte slave);
	;
	;
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@USB_WRITE_SECTOR:
	pushm bx, es, ax, dx, cx
	call _USB_WRITE_SECTOR
	popm bx, es, ax, dx, cx
	ret

_USB_WRITE_SECTOR:
	push bp
	mov bp, sp
	pushm es, bx, di

	mov Al, CH_MODE_USB          ; REQUEST USB MODE
	call CH_SETMODE              ; DO IT
	jc CHUSB_CMDERR              ; HANDLE ERROR

	mov cx, ARG(3)
	mov dx, ARG(4)
	mov al, CH_CMD_DSKWR         ; DISK WRITE COMMAND
	call CHUSB_RWSTART           ; SEND CMD AND LBA(DX:CX)

	les bx, ARG(1)
        mov di,bx
	;
	; WRITE THE SECTOR IN 64 BYTE CHUNKS
	mov cx, 8                    ; 8 CHUNKS OF 64 FOR 512 BYTE SECTOR
CHUSB_WRITE1:
	call CH_POLL                 ; WAIT FOR DATA READY
	cmp al, 1Eh                  ; DATA READY TO WRITE
	jne CHUSB_IOERR              ; HANDLE IO ERROR
	call CH_CMD_WR               ; SEND WRITE USB DATA CMD
	mov al, 64                   ; 64 BYTE CHUNK
	call CH_WR                   ; SEND DATA BLOCK LENGTH
	;
	; BYTE WRITE LOOP
	push cx                      ; SAVE LOOP CONTROL
	mov cx, 64                   ; WRITE 64 BYTES
CHUSB_WRITE2:
	es mov al, [di]              ; GET NEXT BYTE
	add di, 1
	call CH_WR                   ; WRITE NEXT BYTE
	loop CHUSB_WRITE2            ; LOOP AS NEEDED
	pop cx                       ; RESTORE LOOP CONTROL
	;
	; PREPARE FOR NEXT CHUNK
	mov al, CH_CMD_DSKWRGO       ; CONTINUE DISK READ
	call CH_CMD                  ; SEND IT
	loop CHUSB_WRITE1            ; LOOP TILL DONE
	;
	; FINAL CHECK FOR COMPLETION & SUCCESS
	call CH_POLL                 ; WAIT FOR COMPLETION
	cmp al, 14h                  ; SUCCESS?
	jne CHUSB_IOERR              ; IF NOT, HANDLE ERROR

	xor ax, ax

	popm es, bx, di
	leave
	ret


	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



	global USB_entry
USB_entry:
	xor bh, bh                   ; zero extend byte
	mov bl, ah                   ; set to index into dispatch table
	cmp ah, max / 2
	jae try_extended
	shl bx, 1                    ; index words

	cs jmp near [dispatch + bx]

try_extended:
	sub bl, 41h                  ; start of extended calls
	cmp bl, max41 / 2
	jae undefined
	shl bx, 1                    ; index word addresses
	cs jmp near [dispatch41 + bx]


	;fn00: ; Reset Disk System
fn01:                         ; Get Disk System Status
	;fn02: ; Read Sector
	;fn03: ; Write Sector
	;fn04: ; Verify Sector
fn05:                         ; Format Track
fn06:                         ; Format Bad Track (fixed disk) [PC]
fn07:                         ; Format Drive (fixed disk) [PC]
	;fn08: ; Get Drive Parameters
fn09:                         ; Initialize Fixed Disk Characteristics [PC, AT, PS / 2]
fn0A:                         ; Read Sector Long (fixed disk) [PC, AT, PS / 2]
fn0B:                         ; Write Sector Long (fixed disk) [PC, AT, PS / 2]
fn0C:                         ; Seek (fixed disk)
fn0D:                         ; Reset Fixed Disk System
fn0E:                         ; Read Sector Buffer (fixed disk) [PC only]
fn0F:                         ; Write Sector Buffer (fixed disk) [PC only]
fn10:                         ; Get Drive Status (fixed disk)
fn11:                         ; Recalibrate Drive (fixed disk)
fn12:                         ; Controller RAM Diagnostic (fixed disk) [PC / XT]
fn13:                         ; Controller Drive Diagnostic (fixed disk) [PC / XT]
fn14:                         ; Controller Internal Diagnostic (fixed disk) [PC, AT, PS / 2]
	;fn15: ; Get Disk Type [AT]
fn16:                         ; Get Disk Change Status (floppy)
fn17:                         ; Set Disk Type (floppy)
fn18:                         ; Set Media Type for Format (floppy)

	;fn41: ; Check Extensions Present
	;fn42: ; Extended Read
	;fn43: ; Extended Write
	;fn44: ; Extended Verify
fn45:                         ; Lock / Unlock Drive
fn46:                         ; Eject Drive
	;fn47: ; Extended Seek
	;fn48: ; Get Drive Parameters
fn49:                         ; Get Extended Disk Change Status
	;fn4E: ; Set Hardware Configuration

	;;; global undefined
undefined:
	%if SOFT_DEBUG
	int 0
	%endif
	mov AH, 01h                  ; Invalid command

exit_sequence:
	mov [bp + offset_AH], ah     ; set the error code
	;;; mov [fdc_status], ah ; save error code
	or ah, ah
	jnz error_exit
good_exit:
	and byte [bp + offset_FLAGS], ~1 ; clear the carry
	jmp exit_pops
error_exit:
	or byte [bp + offset_FLAGS], 1 ; set the carry
exit_pops:
	mov sp, bp
	popm ALL, ds, es
	iret


dispatch:
	dw fn00                      ; Reset Disk System
	dw fn01                      ;
	dw fn02
	dw fn03
	dw fn04
	dw fn05
	dw fn06
	dw fn07
	dw fn08
	dw fn09
	dw fn0A
	dw fn0B
	dw fn0C
	dw fn0D
	dw fn0E
	dw fn0F
	dw fn10
	dw fn11
	dw fn12
	dw fn13
	dw fn14
	dw fn15
	dw fn16
	dw fn17
	dw fn18
	max equ $ - dispatch

dispatch41:
	dw fn41
	dw fn42
	dw fn43
	dw fn44
	dw fn45
	dw fn46
	dw fn47
	dw fn48
	dw fn49
	dw undefined                 ; 4A
	dw undefined                 ; 4B
	dw undefined                 ; 4C
	dw undefined                 ; 4D
	dw fn4E
	max41 equ $ - dispatch41



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; integrity: Check integrity of fixed disk table
	;
	; Call with:
	; DL = device code (80 or 81)
	; DS set to BIOS data area
	;
	; Exit with:
	; DS:SI points at the fixed disk table
	;
	; Error Exit:
	; If the disk table checksum is bad, give immediate error return
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
integrity:
	pushm ax, cx
	%if 0
	mov al, 7Fh
	and al, dl                   ; mask out the high bit
	cmp al, [n_fixed_disks]
	%else
	extern get_IDE_num
	call get_IDE_num             ; get number of IDE disks total
	mov ah, al
	mov al, 7Fh
	and al, dl                   ; mask out the high bit
	cmp al, ah                   ; compare against max
	%endif
	jae undefined                ; harsh error exit
	mov si, fx80
	mov cx, fx81 - fx80          ; size of fixed disk table
	test al, al
	jz .1
.0: add si, cx                ; point at fx81
	dec al
	jnz .0
.1:
	push si
	mov ax, 0EE00h               ; error code and zero checksum

.2: add al, [si]              ; compute checksum
	inc si
	loop .2                      ; loop back

	pop si
	or al, al                    ; test AL for zero
	jnz error_exit               ; BIOS data area clobbered

	popm ax, cx
	ret


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; cv_lba Convert CHS in CX & DX to LBA address in DX:AX
	;
	; Call with:
	; DS:SI points to fixed disk table
	; CX & DX are CHS input parameters
	;
	; Exit with:
	; DX:AX is the corresponding LBA address
	; BX and CX are modified
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cv_lba:
	mov ax, cx                   ; cylinder info to AX
	rol al, 2                    ; position high 2 bits
	and al, 3                    ; mask 2 bits
	xchg al, ah                  ; AX = cylinder number
	shr dx, 8                    ; heads to DL DH=0

	mov bx, dx                   ; heads to BX
	mov dl, [fx_log_heads - fx80 + si] ; may be 0, meaning 256
	dec dl
	inc dx                       ; recover 256 !!!

	mul dx
	add ax, bx                   ; add in the head number
	adc dx, 0                    ; * *

	mov bl, [fx_log_sectors - fx80 + si] ; BH is already 0
	push cx
	call @mulLS                  ; DX:AX = DX:AX * BX
	pop cx
	dec cl                       ; sector address is from 1, not 0
	and cx, 63
	add ax, cx                   ; add in sector number
	adc dx, 0                    ; * *
	ret


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; fn00 - - Reset the Disk Subsystem
	;
	; Call with:
	; AH = 0 function code
	;
	; Exit with:
	; Nothing
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn00:
	call integrity               ; perhaps no subsystem
	call usb_hard_reset          ; do the dirty
	mov ah, 0
	jmp exit_sequence





	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; fn02 - - Disk Read
	; fn03 - - Disk Write
	; fn04 - - Disk Verify
	;
	; Enter with:
	; AH = 2 (read)
	; AH = 3 (write)
	; AH = 4 (verify)
	; AL = number of sectors to transfer
	; CH = low 8 bits of cylinder number
	; CL = sector number & high 2 bits of sector number
	; DH = head number
	; DL = device code
	; ES:BX = buffer to receive / provide the data (except on verify)
	;
	; Exit with:
	; AH = success(0) or error code
	; Carry flag set, if error; clear otherwise
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn02:
fn03:
fn04:
	call integrity               ; set pointer to Fixed Disk Table in SI
	call cv_lba                  ; convert to LBA address in DX:AX
	mov cl, [fx_drive_control - fx80 + si]
	mov ch, [bp + offset_AL]     ; get sector count
	mov bx, [bp + offset_BX]     ; get transfer address

	; Enter here on Read, Write, Verify or
	; extended Read, Write, Verify, Seek
RWV:
	inc ch                       ; zero is valid for no transfer
	jmp .6                       ; enter loop at the bottom
	; the read / write / verify loop
.1:
	test cl, 40h                 ; test LBA bit in drive control
	jz .7
	; LBA call is okay
	test byte [bp + offset_AH], 04h ; Seek / Verify?
	jnz .4
	test byte [bp + offset_AH], 01h ; Write?
	jnz .3
.2: call @USB_READ_SECTOR
	jmp .5
.3: call @USB_WRITE_SECTOR
	jmp .5
.4: call @USB_VERIFY_SECTOR

.5:
	add ax, 1                    ; increment the LBA address
	adc dx, 0                    ; * *
	add bh, 2                    ; add 512 == 200h to the BX
	jnc .6
	mov di, es
	add di, 10h
	mov es, di                   ; update the segment register
.6: dec ch
	jnz .1
	jmp .8

	; CHS call is required
.7: call undefined

.8:
	xor ah, ah
	jmp exit_sequence



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; fn08 - - Get Drive Parameters
	;
	; Call with:
	; AH = 8 function code
	; DL = drive code (80h, 81h, ...)
	;
	; Exit with:
	; CH = maximum cylinder number (low 8 bits)
	; CL = max. sector number; max. cyl in high 2 bits
	; DH = maximum head number
	; DL = number of fixed disks

	; AH = 0 and Carry is clear on success
	; AH = error code; Carry set on error
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn08:                         ; Get Drive Parameters
	mov byte [bp + offset_DL], 0 ; say no fixed disks

	call integrity               ; bad device code or no fixed disks

	mov ax, [fx_log_cylinders - fx80 + si]
	dec ax
	shl ah, 6
	or ah, [fx_log_sectors - fx80 + si]
	xchg al, ah
	mov [bp + offset_CX], ax
	mov dh, [fx_log_heads - fx80 + si]
	dec dh
	%if 0
	mov dl, [n_fixed_disks]      ; return parameter
	%else
	call get_usb_num             ; get number of IDE disks
	mov dl, al
	%endif
	mov [bp + offset_DX], dx

	xor ah, ah
	jmp exit_sequence



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; fn15 - - Get Disk Type
	;
	; Call With:
	; AH = 15 function code
	; DL = device code (80h or 81h)
	;
	; Exit With:
	; If successful, Carry is clear
	; AH = 3 indicating a hard disk
	; CX:DX number of hard disk sectors
	;
	; If unsuccessful, Carry is set
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn15:
	call integrity               ; sets DS:SI
	mov ax, [fx_log_cylinders - fx80 + si]
	mov bl, [fx_log_heads - fx80 + si]
	xor bh, bh
	dec bl                       ; 00 means 256
	inc bx                       ; do the conversion
	mul bx                       ; cyls * heads
	mov bl, [fx_log_sectors - fx80 + si]
	xor bh, bh
	call @mulLS                  ; cyls * heads * sectors
	mov word [bp + offset_CX], dx ; high order
	mov word [bp + offset_DX], ax ; low order word
	mov byte [bp + offset_AH], 3 ; code for HARD DISK
	jmp good_exit



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; fn41 - - Check Extensions Present
	;
	; Call With:
	; AH = 41h function code
	; BX = 55AAh magic number
	; DL = drive code (80h or 81h)
	;
	; Exit With:
	; carry clear
	; AH = 21h version 1.1 support
	; BX = AA55h magic number II
	; CX = 0001b bit0=packet support; bit2=EDD drive support
	;
	; carry set
	; AH = 01h Invalid Command
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn41:
	call integrity               ; test drive number (sets DS:SI)
	cmp word [offset_BX + bp], 55AAh
	jne undefined
	test byte [fx_drive_control - fx80 + si], 40h ; test LBA bit
	jz undefined

	mov byte [offset_AH + bp], 21h ; version 1.1
	mov word [offset_BX + bp], 0AA55h ; magic number II
	mov word [offset_CX + bp], 00000101b ; packet calls & EDD i / f
	jmp good_exit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; fn42 - - Extended Read
	; fn43 - - Extended Write
	; fn44 - - Extended Verify
	; fn47 - - Extended Seek (implement as Verify)
	;
	; Call With:
	; AH = function code
	; AL = 0, 1 write with no verify; 2 write with verify
	; not used for Read or Verify
	; DL = drive number (80h or 81h)
	; [DS:SI] was disk packet address; will be used in ES:BX
	;
	; Exit With:
	; AH = 0 (no error) and Carry Clear
	; AH = error code and Carry Set
	; The block count field is updated with the number of blocks
	; correctly transferred / verified before the error occurred.
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn42:
fn43:
fn44:
fn47:
	call integrity               ; set pointer to Fixed Disk Table in SI
	mov es, [bp + offset_DS]     ; packet pointer
	mov bx, [bp + offset_SI]     ; * *
	es cmp byte [bx + pkt_size], 16 ; check for correct size
	jb undefined

	es mov ax, [bx + pkt_LBA3]   ; LBA address
	es or ax, [bx + pkt_LBA2]    ; LBA address
	jnz undefined
	es mov ax, [bx + pkt_LBA0]   ; LBA address
	es mov dx, [bx + pkt_LBA1]   ; LBA address hi

	mov ch, 1                    ; assume Seek
	cmp byte [offset_AH + bp], 47h ; Seek?
	je .7
	es mov ch, [bx + pkt_blocks] ; sector count
.7:
	mov cl, [fx_drive_control - fx80 + si]
	es les bx, [bx + pkt_address] ; get transfer address

	jmp RWV                      ; common read / write / verify code



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; fn48 - - Get Drive Parameters
	;
	; Call With:
	; AH = 48h function code
	; DL = drive number
	; DS:SI = pointer to return buffer (26 or 30 bytes)
	;
	; Exit With:
	; AH = 0 and carry clear
	; results in the buffer
	;
	; AH = error code and carry set
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn48:
	call integrity               ; set DS:SI
	mov es, [bp + offset_DS]     ; packet pointer
	mov bx, [bp + offset_SI]     ; * *
	mov cx, 0FFFFh               ; CX = - 1 (FFFFh)
	mov ax, pkt_ptr              ; AX = 26
	es cmp [bx + pkt_size], ax   ; check for correct size = 26
	jb undefined
	add ax, 4
	es cmp [bx + pkt_size], ax   ; check for correct size = 30
	jb .1
	es mov [bx + pkt_ptr], cx    ; flag invalid pointer
	es mov [bx + pkt_ptr + 2], cx ; * *
.1:
	es mov [bx + pkt_size], ax   ; set the returned size

	inc cx                       ; CX = 0
	es mov word [bx + pkt_info], 000011b ; DMA bound / Geom OK

	mov ax, [fx_phys_cylinders - fx80 + si] ; cylinders
	es mov [bx + pkt_phys_cyl], ax
	es mov [bx + pkt_phys_cyl + 2], cx

	mov al, [fx_phys_heads - fx80 + si] ; heads
	mov ah, ch
	es mov [bx + pkt_phys_hds], ax
	es mov [bx + pkt_phys_hds + 2], cx

	mov al, [fx_phys_sectors - fx80 + si] ; sectors
	es mov [bx + pkt_phys_spt], ax
	es mov [bx + pkt_phys_spt + 2], cx

	mov ax, [fx_LBA_low - fx80 + si] ; total LBA sectors
	es mov [bx + pkt_sectors], ax ; total sectors
	mov ax, [fx_LBA_high - fx80 + si] ; * *
	es mov [bx + pkt_sectors + 2], ax ; * *
	es mov [bx + pkt_sectors + 4], cx ; * *
	es mov [bx + pkt_sectors + 6], cx ; * *
	es mov word [bx + pkt_bytes], 512 ; sector size
	mov ah, 0
	jmp exit_sequence




	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; fn4E - - set hardware configuration
	;
	; Call With:
	; AH = 4Eh function code
	; AL = hardware function sub - code
	; DL = drive number
	;
	; Exit With:
	; AH = 0 carry is clear
	; AL = 1 other devices affected
	;
	; AH = error code and carry is set
	;
	; This operation is a complete No - Op for the PPIDE
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn4E:
	call integrity
	mov ax, 0001h
	jmp exit_sequence

	; get number of IDE disks (result in al)
get_usb_num:
	mov al, 1
	ret

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	; Reset and initialize USB Subsystem
	; GLOBAL CH37X INITIALIZATION
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
usb_hard_reset:
	;
	call CH_DETECT               ; DETECT CHIP PRESENCE
	jnc CH_INIT3                 ; GO AHEAD IF CHIP FOUND
	Error
	ret
	;
CH_INIT3:
	call CHUSB_RESET             ; RESET & DISCOVER MEDIA
	jnc CH_INIT3A                ; GO AHEAD IF CHIP FOUND
	Error
	ret                          ; ABORT ON FAILURE

CH_INIT3A:
	ret
	;
	;
	; SEND COMMAND IN AL
	;
CH_CMD:
	push dx
	mov dx, CH376 + 1            ; CMD PORT
	out dx, al                   ; SEND COMMAND
	pop dx
	ret
	;
	; GET STATUS
	;
CH_STAT:
	push dx
	mov dx, CH376 + 1            ; CMD PORT
	in al, dx                    ; GET STATUS
	pop dx
	ret
	;
	; READ A BYTE FROM DATA PORT
	;
CH_RD:
	push dx
	mov dx, CH376                ; BASE PORT
	in al, dx                    ; GET DATA
	pop dx
	ret
	;
	; WRITE A BYTE TO DATA PORT
	;
CH_WR:
	push dx
	mov dx, CH376                ; BASE PORT
	out dx, al                   ; SEND DATA
	pop dx
	ret

	;
	; POLL WAITING FOR INTERRUPT
	;
CH_POLL:
	pushm bx, dx, cx
CH_POLL0:
	mov cx, 8000h                ; PRIMARY LOOP COUNTER
CH_POLL1:
	call CH_STAT                 ; GET INT STATUS
	test al, 80h
	jz CH_POLL2                  ; IF ZERO, MOVE ON
	loop CH_POLL1
	popm bx, dx, cx
	mov al, 0ffh                 ; timeout
	ret                          ; AND RETURN
CH_POLL2:
	mov al, CH_CMD_STAT          ; GET STATUS
	call CH_CMD                  ; SEND IT
	call wait12                  ; SMALL DELAY
	call CH_RD                   ; GET RESULT
	popm bx, dx, cx
	ret                          ; AND RETURN

	;
	; SEND READ USB DATA COMMAND
	; USING BEST OPCODE FOR DEVICE
	;
CH_CMD_RD:
	; SEND CH376 READ USB DATA CMD
	mov al, CH_CMD_RD6
	jmp CH_CMD
	;
	; SEND WRITE USB DATA COMMAND
	; USING BEST OPCODE FOR DEVICE
	;
CH_CMD_WR:
	; SEND CH376 WRITE USB DATA CMD
	mov al, CH_CMD_WR6
	jmp CH_CMD

	;
	; EMPTY THE CH37X OUTPUT QUEUE OF GARBAGE
	;
CH_FLUSH:
	mov cx, 80h
CH_FLUSH1:
	call CH_RD
	loop CH_FLUSH1
	ret
	;
	;
	;
CH_DETECT:
	mov al, CH_CMD_EXIST         ; LOAD COMMAND
	call CH_CMD                  ; SEND COMMAND
	mov al, 0AAh                 ; LOAD CHECK PATTERN
	call CH_WR                   ; SEND IT
	call wait12                  ; SMALL DELAY
	call CH_RD                   ; GET ECHO
	cmp al, 55h                  ; SHOULD BE INVERTED
	ret                          ; RETURN
	;
	; SET MODE TO VALUE IN A
	; AVOID CHANGING MODES IF CURRENT MODE = NEW MODE
	; THE CH376 DOES NOT SEEM TO MAINTAIN SEPARATE OPERATING CONTEXTS FOR
	; THE USB AND SD DEVICES. IF BOTH ARE IN OPERATION, THEN A MODE
	; SWITCH REQUIRES A COMPLETE REINITIALIZATION OF THE REQUESTED
	; DEVICE. THIS WHOLE MESS IS ONLY NEEDED IF BOTH CHSD AND CHUSB
	; ARE ENDABLED, SO IT IS CONDITIONAL.
	;
CH_SETMODE:
CH_SETMODE_USB:
	;
	; ACTIVATE USB MODE
	mov al, CH_CMD_MODE          ; SET MODE COMMAND
	call CH_CMD                  ; SEND IT
	mov al, 6                    ; USB ENABLED, SEND SOF
	call CH_WR                   ; SEND IT
	call wait12                  ; SMALL WAIT
	call CH_RD                   ; GET RESULT
	call wait12                  ; SMALL WAIT
        ret


	;
	; INITIATE A DISK SECTOR READ / WRITE OPERATION
	; A: READ OR WRITE OPCODE
	;
CHUSB_RWSTART:
	call CH_CMD                  ; SEND R / W COMMAND
	;
	; SEND LBA, 4 BYTES, LITTLE ENDIAN
	mov al, cl
	call CH_WR                   ; SEND BYTE
	mov al, ch
	call CH_WR                   ; SEND BYTE
	mov al, dl
	call CH_WR                   ; SEND BYTE
	mov al, dh
	call CH_WR                   ; SEND BYTE
	;
	; REQUEST 1 SECTOR
	mov al, 1                    ; 1 SECTOR
	call CH_WR                   ; SEND IT
	ret
	;
	;
	;
	; RESET THE INTERFACE AND REDISCOVER MEDIA
	;
CHUSB_RESET:
	;
	; RESET THE BUS
	mov al, CH_CMD_MODE          ; SET MODE COMMAND
	call CH_CMD                  ; SEND IT
	mov al, 7                    ; RESET BUS
	call CH_WR                   ; SEND IT
	call wait12                  ; SMALL WAIT
	call CH_RD                   ; GET RESULT
	call wait12                  ; SMALL WAIT
	;
	; ACTIVATE USB MODE
	mov al, CH_CMD_MODE          ; SET MODE COMMAND
	call CH_CMD                  ; SEND IT
	mov al, 6                    ; USB ENABLED, SEND SOF
	call CH_WR                   ; SEND IT
	call wait12                  ; SMALL WAIT
	call CH_RD                   ; GET RESULT
	call wait12                  ; SMALL WAIT
	;
	mov al, CH_MODE_USB          ; WE ARE NOW IN USB MODE
	;
	; INITIALIZE DISK
	mov cx, 24                   ; TRY A FEW TIMES
CHUSB_RESET1:
	mov al, CH_CMD_DSKINIT       ; DISK INIT COMMAND
	call CH_CMD                  ; SEND IT

	push cx
	mov cx, 20000                ; 1 s delay
	call microsecond
	mov cx, 20000
	call microsecond
	mov cx, 20000
	call microsecond
	mov cx, 20000
	call microsecond
	mov cx, 20000
	call microsecond
	pop cx

	call CH_POLL                 ; WAIT FOR RESULT

	cmp al, 14h                  ; SUCCESS?
	je CHUSB_RESET2              ; IF SO, CHECK READY
	cmp al, 16h                  ; NO MEDIA
	je CHUSB_NOMEDIA             ; HANDLE IT

	call wait12
	loop CHUSB_RESET1            ; LOOP AS NEEDED
	jmp CHUSB_TO                 ; HANDLE TIMEOUT
	;
CHUSB_RESET2:
	; USE OF CH376 DISK_MOUNT COMMAND SEEMS TO IMPROVE
	; COMPATIBILITY WITH SOME OLDER USB THUMBDRIVES.
	call CHUSB_DSKMNT            ; IF SO, TRY MOUNT, IGNORE ERRS
	call CHUSB_DSKSIZ            ; GET AND RECORD DISK SIZE
	ret

	;
	; CH37X HELPER ROUTINES
	;
	;
	; PERFORM DISK MOUNT
	;
CHUSB_DSKMNT:
	mov al, CH_CMD_DSKMNT        ; DISK QUERY
	call CH_CMD                  ; DO IT
	call CH_POLL                 ; WAIT FOR RESPONSE

	cmp al, 14h                  ; SUCCESS?
	je CHUSB_DSKMNTok
	Error
	ret
CHUSB_DSKMNTok:
	Okay
	ret
	;
	; PERFORM DISK SIZE
	;
CHUSB_DSKSIZ:
	mov al, CH_CMD_DSKSIZ        ; DISK SIZE COMMAND
	call CH_CMD                  ; SEND IT
	call CH_POLL                 ; WAIT FOR RESULT
	cmp al, 14h                  ; SUCCESS?
	jne CHUSB_CMDERR             ; HANDLE CMD ERROR
	call CH_CMD_RD               ; SEND READ USB DATA CMD
	call CH_RD                   ; GET RD DATA LEN
	cmp al, 08h                  ; MAKE SURE IT IS 8
	jne CHUSB_CMDERR             ; HANDLE CMD ERROR
	call CH_RD
	mov dh, al
	call CH_RD
	mov dl, al
	call CH_RD
	mov ch, al
	call CH_RD
	mov cl, al
	call CH_RD
	call CH_RD
	call CH_RD
	call CH_RD
	Okay
	ret                          ; AND DONE
CHUSB_DSKINQ:
	mov al, CH_CMD_DSKINQ        ; DISK INQUIRY
	call CH_CMD                  ; SEND IT
	call CH_POLL                 ; WAIT FOR RESULT
	cmp al, 14h                  ; SUCCESS?
	jne CHUSB_CMDERR             ; HANDLE CMD ERROR
	call CH_CMD_RD               ; SEND READ USB DATA CMD
	call CH_RD                   ; GET RD DATA LEN
	mov cl, al
	xor ch, ch                   ; put count in cx
	mov di, bx
.1:
	call CH_RD
	es mov [di], al
	add di, 1
	loop .1
	es mov byte [di], 0
	Okay
	ret                          ; AND DONE
	;
	; ERROR HANDLERS
	;
	;
CHUSB_NOMEDIA:
	mov al, CHUSB_STNOMEDIA
	jmp CHUSB_ERR
	;
CHUSB_CMDERR:
	mov al, CHUSB_STCMDERR
	jmp CHUSB_ERR
	;
CHUSB_IOERR:
	mov al, CHUSB_STIOERR
	jmp CHUSB_ERR
	;
CHUSB_TO:
	mov al, CHUSB_STTO
	jmp CHUSB_ERR
	;
CHUSB_NOTSUP:
	mov al, CHUSB_STNOTSUP
	jmp CHUSB_ERR
	;
CHUSB_ERR:
	Error
	ret
