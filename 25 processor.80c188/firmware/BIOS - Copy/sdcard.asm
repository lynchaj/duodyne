;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDcard.ASM -- Basic I/O routines for the Dual SDcard add-on board
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

%define QUICK_VERIFY 1
%define DEBUG 0
%include	"sdcard.inc"

; Do we use CRC's with commands and data transfers?
%define USE_CRCs	TRUE

        global  SDcard_BIOS_call_13h
        extern  @mulLS
        extern  microsecond

	SEGMENT	_TEXT

Zero:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  BIOS call entry for Dual SD Card driver
;       int  13h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDcard_BIOS_call_13h:           ; SDcard driver entry
        sti                     ; Enable interrupts
        pushm   all,ds,es       ; Standard register save
        mov     bp,sp           ; establish stack addressing
        push    bios_data_seg
        popm    ds              ; establish addressability
        cld
; above done in general Fixed disk entry point


	global	DSD_entry
DSD_entry:
%if SOFT_DEBUG & 0
	int 5
%endif
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
        int 5
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
%if SOFT_DEBUG & 0
	int 5
%endif
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



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDsetunit	set the selected unit (0 or 1) in DI and in SDselect reg.
;
;  Enter with:
;	DS =	Bios Data Area pointer is set
;	DL =	hard drive specifier (80h..83h)
;
;  Return with:
;	DI = 	unit number selected in the h/w (0 or 1)
;	All other registers preserved, including AX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDsetunit:
	mov	di,dx			; device code to DI
	and	di,FIXED_DISK_MAX-1	; mask device code
	mov	di,[fixed_disk_tab+di]	; only the low byte matters
	and	di,UnitMask
	push	dx   			; save DX
	xchg	ax,di			; save AX and DI
	mov	dx,SDselect		; unit selection register
	out	dx,al			; select unit 0 or 1
	xchg	ax,di			; restore AX and DI
	pop	dx			; restore DX
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDgetunit	get the selected unit# in DI
;
;  Enter with:
;	Nothing
;
;  Return with:
;	DI = 	unit number selected in the h/w (0 or 1)
;	DX =	Operation Register device code
;	All other registers preserved, including AX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDgetunit:
	xchg	ax,di		; save AX in DI
	mov	dx,SDselect	; get Select register device code
	in	al,dx
	and	ax,UnitMask
	xchg	ax,di		; set DI, restore AX
	dec	dx		; set Operation Register device code
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDputchar	Put a byte to DATIN on the SD card
;
;  Enter with:
;	AL = byte to put out
;	DX = SDoperation register I/O device code
;  Assume:
;	Chip Select is already asserted
;	Clock may be high or low
;
;  Return with:
;	AX is trashed
;	Clock is deasserted, Chip Select is asserted
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	SDputchar
SDputchar:
	pushm	cx

	mov	ah,al			; move character to AH
	mov	cx,8			; count 8 bits

.1:	mov	al, ChipSelect / 2	; will shift it, no clock yet
	rol	ax,1			; rotate bit into register
	out	dx,al			; output data, no clock
	or	al, Clock		; rising clock edge
	out	dx,al			; 
	loop	.1

	and	al,~Clock
	out	dx,al			; set clock low

	popm	cx
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDgetchar	Get a byte from DATOUT on the SD card
;
;  Enter with:
;	DX = SDoperation register I/O device code
;  Assume:
;	Chip Select is already asserted
;	Clock is low
;
;  Return with:
;	AL = the byte received
;	AH = copy of AL
;	Clock is low, Chip Select is still asserted
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	SDgetchar
SDgetchar:
	push	cx

	mov	al, ChipSelect | DataIn
	out	dx,al			; set clock low

	mov	cx,8			; count 8 bits
.1:	in	al,dx			; get input bit
	shr	al,1
	rcl	ah,1			; bit into AH
	mov	al,ChipSelect | Clock | DataIn
	out	dx,al			; acknowledge receipt of bit
	mov	al, ChipSelect | DataIn		; no clock
	out	dx,al
	loop	.1

	mov	al,ah			; return byte in AL
	pop	cx
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; spin		apply clock pulses to the SD card
;
;  Enter with:
;	CX = character count to spin
;
;  Exit with:
;	AX is trashed
;	CX = 0
;	DX = SDoperation register I/O device code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spin:
	mov	dx,SDoperation
.1:	mov	al,-1
	call	SDputchar
  	loop	.1
 	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDsendclks	send clock transitions to the card
;
;  Enter with:
;	AL = initial state of bits to bang
;	CX = transition count
;	DX = card Operation Register device code
;
;  Return with:
;	AL modified
;	CX = 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDsendclks:
.1:	out	dx,al		; put out state of bits specified
	xor	al,Clock
	loop	.1
	out	dx,al		; put out last transition
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDdone	complete a transaction
;
;  Enter with:
;	DX = Operation Register device code
;
;  Return with:
;	All registers are preserved
;	Flags are preserved, too
;
;	The card is deselected!!!
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDdone:
	pushm	ax,cx,f

	mov	al,DataIn	; no ChipSelect or Clock
	mov	cx,16
	call	SDsendclks

	popm	ax,cx,f
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDwaitrdy	wait for card to become ready
;
;  Enter with:
;	DX = Operation Register device code
;
;  Return with:
;	Carry = 0	Clear means no error	(AL = 0)
;	Carry = 1	Set means error		(AL = 0xFF)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDwaitrdy:
	pushm	cx

	mov	al, ChipSelect | DataIn
	out	dx,al		; set clock to 0

	mov	cx,7FFFh
.1:
	call	SDgetchar
	inc	al		; 0FFh -> 00h
	jz	.9
	loop	.1

	dec	al		; return error byte
	stc			; flag error
	jmp	.99		; error exit

.9:	clc			; clear the carry
.99:	cbw			; extend byte to full word
	popm	cx
	ret
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDgoidle	put card in the idle state
;
;  Enter with:
;	DX	Operation register device code
;
;  Return with:
;	AX	response to CMD0
;	Zero flag is set by compare to '01'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDgoidle:
	mov	cx,5000		; about 5 milliseconds
.0:	nop
	loop	.0

	mov	si,CMD0
	pushm	cs
	popm	es
	call	cmd_R1

	call	SDdone
	jz	.5
	cmp	al,01h
.5:
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDcmdset	set up a command with parameters
;
;  Enter with:
;	BL	command byte (40h | ??)
;	DX:AX	4-byte parameter, DH is ms-byte, AL is ls-byte
;
;  Exit with:
;	SP	decreased by 6 bytes
;	ES:SI	(or SS:SP) points at command in the stack
;	AX,BX,CX  are all trashed
;	DX	is reset to Operation register device code
;
;  After the command is executed, the stack is cleared with
;	ADD	SP,6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDcmdset:
	pop	cx		; pop return address

;  bl:dh:dl:ah:al:FF
	xchg	dl,bl
;  dl:dh:bl:ah:al:FF
	xchg	al,bl
;  dl:dh:al:ah:bl:FF
;;;	mov	bh,0FFh
;  dl:dh:al:ah:bl:bh
	push	bx
	push	ax
	push	dx
	mov	si,sp
	pushm	ss
	popm	es
	push	cx		; reset return address
%if USE_CRCs
	mov	cx,5		; CRC7 for 5 bytes
	call	calcCRC7
  es	mov	[si],al		; store the CRC7
	sub	si,5		; reset SI to point at CMD string
%endif
	mov	dx,SDoperation	; set for Operation Register device code
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDcmdset0	set up a command with no parameters
;
;  Enter with:
;	AL	command code
;
;  Return with:
;	SP	decreased by 6 bytes
;	ES:SI	(or SS:SP) points at command in the stack
;	DX	is reset to Operation register device code
;	AX	is destroyed
;
;  After the command is executed, the stack is cleared with
;	ADD	SP,6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDcmdset0:
	pop	dx		; save return address
	push	0		; push 0,CRC
	push	0		; push 0,0
	xor	ah,ah
	push	ax		; push CMDx,0
	
	mov	si,sp		; set DS:SI to point at command
	pushm	ss
	popm	es
	push	dx		; push return address

%if USE_CRCs
	pushm	cx,si
	mov	cx,5		; CRC7 for 5 bytes
	call	calcCRC7
	mov	[si],al		; store the CRC7
	popm	cx,si		; DS:SI set, DX=Oper. reg
%endif
	mov	dx,SDoperation	; set for Operation Register device code
	ret





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDinit	initialize card status to "init required"
;
;  Enter with:
;	nothing
;
;  Return with:
;	nothing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	@SDinit		; C-fastcall
@SDinit:
SDinit:
	push	ds
	push	bios_data_seg
	pop	ds
	mov	word [SDstatus], -1	; zap both status bytes to 0FFh
	pop	ds
	ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDinitcard	initialize a newly inserted SD card
;
;  Enter with:
;	AX = card selection (0 or 1)
;
;  Return with:
;	AX = status	(0 means success)
;	Zero flag reflects status
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	@SDinitcard		; C-fastcall
@SDinitcard:
	pushm	bx,cx,dx,ds
	push	bios_data_seg		; get BDA on a C-call
	pop	ds
	call	SDinitcard
	popm	bx,cx,dx,ds
	ret

SDinitcard:
	pushm	si,di,es

	test	ax,~UnitMask		; bits must not be set
	jnz	.error1

	mov	dx,SDselect
	out	dx,al			; select card  1 or 0
	dec	dx			; set to Operation Register
	mov	di,ax			; set Unit Index

; Check for card present
	in	al,dx			; read Operation register
	test	al,20h			; test for Card Detect bit
	mov	ax,-4			; error code for No Card inserted
	mov	[SDstatus + di],al	; say there is no card
	jz	.error			; set error code & return
 
	call	SDdone			; seems to help some cards

	mov	al,ChipSelect | DataIn	; DataIn is into the SDcard
	mov	cx,256			; 256 clock transitions
	call	SDsendclks

	call	SDwaitrdy		; wait for card to go ready
	jc	.rdytimeout

;;;	call	SDgoidle
;;;	je	.okay
	call	SDgoidle		; only 1 needed
;;	mov	ah,$-Zero
	jne	.error			; SDsendclks glitch fixed

	pushm	cs
	popm	es
	mov	si,CMD8			; v.2 cards require CMD8
	call	cmd_R1
	test	al,~01h			; any error bits set (v.1 card)
	jnz	.0
	call	SDgetchar		; v.2 card returns 4 more bytes
	call	SDgetchar
	call	SDgetchar
	call	SDgetchar
.0:
	call	SDdone

	mov	cx,7FFFh	; init try counter
.1:
	pushm	cx
	mov	cx,5000		; about 5 milliseconds
.11:	nop
	loop	.11		; delay loop
	popm	cx

	pushm	cs
	popm	es
	mov	si,CMD55
	call	cmd_R1
	call	SDdone
	jnz	.error
	test	al,~01h		; only 0 and 1 are okay responses
;;	mov	ah,$-Zero
	jnz	.error

	mov	si,ACMD41
	call	cmd_R1
	call	SDdone
	or	al,al		; test for zero
	jz	.2
	dec	al		; test for 1
;;	mov	ah,$-Zero
	jnz	.error
	loop	.1

	jmp	.timeout

.2:

	mov	si,CMD58
	call	cmd_R1
	jnz	.err58			; must respond with a 00h
	call	SDgetchar		; get command response
	mov	ah,SDtypeSDSC		; assume standard card
	test	al,40h			; test bit 30 of response
	jz	.21
	mov	ah,SDtypeSDHC		; set HC card type
.21:	call	SDgetunit
	mov	[SDcardtype + di],ah	; set card type

	call	SDgetchar		; discard rest of the response
	call	SDgetchar		; 
	call	SDgetchar		; 
	call	SDdone

%if USE_CRCs
	mov	ax,1			; turn on CRC checking
	xor	dx,dx
	mov	bl, 40h | 59		; CMD59 (CRC on/off)
	call	SDcmdset
	call	cmd_R1
	mov	sp,si			; clear command from stack
	call	SDdone
;;	mov	ah,$-Zero
	jnz	.error
%endif

; set the desired block length -- CMD16(512)
	pushm	cs
	popm	es
	mov	si,CMD16
	call	cmd_R1
	call	SDdone
;;	mov	ah,$-Zero
	jnz	.error

.okay:	xor	ax,ax			; clear the carry, too

.exitstatus:
	mov	[SDstatus + di], al	; save SD card status
.exit:
	popm	si,di,es
	or	al,al			; set the Z-flag
	ret

.err58:
	call	SDdone
;;	mov	ah,$-Zero
	jmp	.error
.rdytimeout:
	mov	ax,-2
	jmp	.error
.timeout:
	mov	ax,-1
;;;	jmp	.error
.error:	
	stc
	jmp	.exitstatus

.error1:			; caution here, DI is not set up
	mov	ax,-3
	stc
	jmp	.exit





CRC_unknown	equ	0FFh

;ResetCommand:
CMD0		db	40h | 0, 0, 0, 0, 0, 95h
CMD8		db	40h | 8, 0, 0, 01h, 0AAh, 87h
CMD9		db	40h | 9, 0, 0, 0, 0, 0AFh
CMD10:		db	40h | 10, 0, 0, 0, 0, 01Bh
CMD16:		db	40h | 16, 0, 0, 512>>8, 512&0xFF, 015h
CMD55		db	40h | 55, 0, 0, 0, 0, 065h
ACMD41		db	40h | 41, 40h, 0, 0, 0, 077h
CMD58		db	40h | 58, 0, 0, 0, 0, 0FDh


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  DSDgetInfo	C-callable routine to get OCR, CSD, & CID
;
;	byte DSDgetInfo(int unit, byte buffer[36]);
;
;  Return:
;	buffer filled with OCR, CSD, CID
;
;  Errors:
;	No Error	0
;	get OCR		1
;	get CSD		2
;	get CID		3
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	_DSDgetInfo
_DSDgetInfo:
        push    bp
        mov     bp,sp
	pushm	bx,cx,dx,di,si,es

	mov	ax,ARG(1)
	mov	dx,SDoperation
	out	dx,al

	call	SDwaitrdy	; wait for card to go ready
	les	bx,ARG(2)

; get the OCR
	push	es
	pushm	cs
	pop	es
	mov	si,CMD58
	call	cmd_R1
	pop	es
	mov	ax,0101h		; AH=1, AL=1
      	jnz	.ocr2			; error if not Zero
	mov	cx,4
.ocr	call	SDgetchar		; discard rest of the response
  es	mov	[bx],al
  	inc	bx
	loop	.ocr
	xor	ax,ax			; set the Z flag
.ocr2:
	call	SDdone
	jnz	.error

; get the Card Specific Data (CSD) register contents
	push	es
	pushm	cs
	pop	es
	mov	si,CMD9
	call	cmd_R1
	pop	es
	mov	cx,16
	call	SDgetdata
	call	SDdone
	mov	ax,0202h		; AH=2, AL=2
	jnz	.error


; get the Card Identification Data (CID) register contents
	push	es

	pushm	cs
	pop	es
	mov	si,CMD10
	call	cmd_R1
	pop	es

	mov	cx,16
	call	SDgetdata
	call	SDdone
	mov	ax,0303h		; AH=3, AL=3
	jnz	.error

	xor	ax,ax		; signal No Error
.error:

	popm	bx,cx,dx,di,si,es
	mov	sp,bp
	pop	bp
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; stepCRC7	include a byte in a CRC7 polynomial
;
;  Enter with:
;	DL = partial CRC calculation
;	AL = character to add into the calculation
;
;  Return with:
;	DL = updated CRC calculation
;	AX is trashed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CRC7poly	equ	00001001b
CRC7poly2	equ	CRC7poly*2	; 7 bits only

	 global stepCRC7, @stepCRC7
stepCRC7:
@stepCRC7:
	push	cx

	mov	cx,8 			; 8 bits in AL
.1:	
	mov	ah,dl			; copy CRC to AH
	xor	ah,al			; Sign bit is 0 or 1
	shl	ax,1
	sbb	ah,ah			; AH is 0 or -1
	shl	dl,1			; shift polynomial
	and	ah,CRC7poly2		; get bits to add into the CRC
	xor	dl,ah			; update the polynomial
	loop	.1
	
	mov	al,dl			; return in AX also
	xor	ah,ah
	pop	cx
	ret
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; calcCRC7	calculate a CRC7 polynomial (for a command)
;
;  Enter with:
;	ES:SI	points at a string of bytes
;	CX	count of bytes in the string
;	direction flag clear
;
;  Return with:
;	ES:SI	point at next byte beyond end of string
;	CX = 0
;	AL = CRC7 polynomial byte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcCRC7:
	push	dx
	xor	dx,dx		; start CRC7 at zero
.1:
  es	lodsb
	call	stepCRC7
	loop	.1

	mov	al,dl		; final CRC7 to AL
	or	al,01h		; set the low bit
	pop	dx
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; cmd_R1	issue command and get R1 response
;
;  Enter with:
;	ES:SI	far pointer to command string
;	DX	device code for Operation register
;
;  Exit with:
;	byte value of response to the command
;	-1 if error (such as no response)
;
;	SI	is incremented by 6, the length of a command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmd_R1:
	pushm	cx
	mov	cx,6		; all commands are 6 bytes
.1:
  es	lodsb
	call	SDputchar
	loop	.1
%if DEBUG>=4
	pushm	bx,di,es

	mov	bx,-1
	mov	cx,lbuf
	pushm	cs
	popm	es
	mov	di,buffer
.2:
	call	SDgetchar
	stosb				; save for debug
	test	al,80h
	jz	.3
	mov	bl,al
	loop	.2
	mov	ax,bx 
.3:
	popm	bx,di,es
%else
	mov	cx,9			; response must come within 8 chars
.2:	call	SDgetchar
	test	al,80h			; check high bit for zero
	jz	.4			; 0xxx xxxxb is result byte
	loop	.2
%endif
	cbw				; extend to whole word
	or	al,al			; clear zero flag
.4:				; Zero flag set if jumped here
	popm	cx
	ret



%if USE_CRCs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; crc_step	one step in CRC calculation
;
;  Enter with:
;	AL	byte to be added to the CRC computation
;	CX,DX	not to be touched
;	SI	partial CRC computation
;
;  Return with:
;	CX,DX	preserved
;	BX	is destroyed
;	SI	updated CRC computation
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
crc_step:
	xchg	cx,si		; preserve CX in SI
.2:
	mov	bl,ch		; form index into table
	xor	bh,bh		; zap BH
	xor	bl,al		; use current byte in AL

  	mov	ch,cl		; update CRC16
	xor	cl,cl
	shl	bx,1
  cs	xor	cx,[crc16tab + bx]

	xchg	cx,si		; put new crc back in SI
	ret
%endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDtestdata	test crc on a block of data
;
;  Enter with:
;	CX	count of data bytes to get
;	DX	set to Operation register device code
;
;  Return with:
;    Good return:
;	CX =	CRC16 returned by the call
;	AX =	0
;	Zero flag is set
;
;    Error return:
;	BX	not changed
;	CX	not changed
;	AX =	error code
;	Zero flag is clear
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDtestdata:
	pushm	bx,si			; save BX, SI

	pushm	cx			; save byte count

	mov	cx,7FFFh		; timeout count
.1:
	call	SDgetchar		; get an input byte
	cmp	al,0FFh			; any return yet?
	jne	.2			;
	loop	.1
.2:
	popm	cx			; restore data count

	cmp	al,0FEh			; timeout or start of data?
	jne	.4			; jump if timeout

	xor	si,si			; start CRC at zero
	add	cx,2			; 
.3:	call	SDgetchar
%if USE_CRCs
	call	crc_step		; update the CRC in SI
%endif
	loop	.3			; get all the bytes

.99:
	mov	cx,si			; CRC to CX
	xor	ax,ax			; good return
.4:				; error return
	cbw
	or	al,al
	popm	bx,si			; restore regs
	ret
	global	verify_crc
verify_crc	equ	.99


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDgetdata	get a block of data
;
;  Enter with:
;	ES:BX	points at buffer to receive data
;	CX	count of data bytes to get
;	DX	set to Operation register device code
;
;  Return with:
;    Good return:
;	CX =	CRC16 returned by the call
;	AX =	0
;	Zero flag is set
;
;    Error return:
;	ES:BX	not changed
;	CX	not changed
;	AX =	error code
;	Zero flag is clear
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDgetdata:
	pushm	cx			; save byte count

	mov	cx,7FFFh		; timeout count
.1:
	call	SDgetchar		; get an input byte
	cmp	al,0FFh			; any return yet?
	jne	.2			;
	loop	.1
.2:
	popm	cx			; restore data count
	cmp	al,0FEh			; timeout or start of data?
	jne	.4			; jump if timeout

.3:	call	SDgetchar
  es	mov	[bx],al			; store data read
  	inc	bx
	loop	.3			; get all the bytes

	call	SDgetchar		; get first CRC16 byte
	mov	ch,al
	call	SDgetchar
	mov	cl,al			; low order CRC16 byte

	xor	ax,ax
.4:				; error return
	cbw
	or	al,al
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDputdata	put out the data block
;
;  Enter with:
;	AX	CRC16 bytes to send
;	ES:BX	pointer to the data block to put out
;	CX	count of data bytes to send
;	DX	device code of Operation register
;
;  Return with:
;	ES:BX	points beyond end of data
;	CX	is trash
;
;	AX = 0, Z=1  means a good return
;   or	Z=0, AX = error return byte
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDputdata:
	pushm	ax			; save CRC16 bytes

	mov	al,0FEh			; start of data packet
	call	SDputchar
.1:
  es	mov	al,[bx]			; get data byte
  	inc	bx
	call	SDputchar
	loop	.1

	popm	cx			; get CRC bytes
	mov	al,ch			; put out hi-CRC16
	call	SDputchar
	mov	al,cl			; put out lo-CRC16
	call	SDputchar

	mov	cx,7FFFh		; timeout count
.2:
	call	SDgetchar		; get byte != FF
	cmp	al,0FFh
	jne	.3
	loop	.2
.3:
	and	al,1Fh			; mask return acknowledge
	cbw
	cmp	al,05h
       	jne	.error			; Z=0
	xor	ax,ax			; Z=1, AX=0
.error:
	ret


%if SOFT_DEBUG
	global	SD_put_return
SD_put_return equ  .3
%endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDcheck	check for drive readable/writeable
;
;  Enter with:
;	AH = 2	check for card readable
;	AH = 3	check for card writeable
;
;  Return with:
;	AX =	error code (0 means okay)
;	Zero flag is set/reset per AX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDcheck:
	call	SDgetunit		; set up DX, DI

	in	al,dx			; check HW status
	test	al,CardDetect		; card inserted?
	jz	.nocard
	test	ah,1			; test LSB of AH
	jz	.0			; read test
	test	al,WrProt		; writeable?
	jnz	.wrprot			; not writeable
.0:
	cmp	byte [SDstatus + di], 0	; check for unit initialized
	je	.1
	mov	ax,di
	call	SDinitcard
	jne	.ret			; return if error on init
.1:
	xor	ax,ax			; good return
	jmp	.ret

.nocard:
	mov	ax,-6			; no card inserted
	jmp	.exit
.wrprot:
	mov	ax,-7			; card is write protected

.exit:	or	ax,ax
.ret:	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDsetaddr	set up card sector address
;
;  Enter with:
;	DX:AX	sector address (512 byte sectors)
;	DI	unit number
;
;  Return with:
;	DX:AX	byte address for SDSC cards
;		unchanged for SDHC cards
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDsetaddr:
	cmp	byte [SDcardtype + di], SDtypeSDHC
	jae	.6
; SDSC cards and below use byte addressing
; multiply DX:AX by 512
	mov	dh,dl		; shift by 8
	mov	dl,ah
	mov	ah,al
	xor	al,al		; **
	shl	ax,1		; double shift by one more
	rcl	dx,1
				; all shifted by 9 (2**9 == 512)
.6:
	ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDread1sec	Read a single sector (of 512 bytes)
;
;  Enter with:
;	DX:AX	sector number to read
;	ES:BX	buffer to receive data
;
;  Return with:
;	CL	error code (0 means success)
;	DX:AX	preserved
;	ES:BX	preserved
;	SI, DI, CH are preserved
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDread1sec:
	pushm	ax,bx,dx,si,di
	pushm	cx

	pushm	bx,es		; save buffer address
	pushm	ax,dx		; save sector number

	mov	ah,2		; show it is a read check
	call	SDcheck
	jnz	.err2

	call	SDwaitrdy	; wait for card to go ready
	jc	.err2

	popm	ax,dx		; get sector address
	call	SDsetaddr	; set up card address in DX:AX
; DX:AX is byte address (SDSC) or sector address (SDHC)
	mov	bl, 40h | 17	; CMD17 = read one sector
	call	SDcmdset	; CMD17 (DX:AX) crc
	call	cmd_R1		; execute the command
	mov	sp,si		; purge command from the stack
	jz	.3
	call	SDdone		; done if error
      	jmp	.err1		; exit on error
.3:
	popm	bx,es		; restore data pointer
	mov	cx,512		; read 512 bytes
	call	SDgetdata	; **
	call	SDdone		; end of command
%if USE_CRCs
	jnz	.exit
	pushm	cx		; save CRC16 read in
	mov	cx,512		; check 512 bytes
	sub	bx,cx		; set ES:BX
	xor	ax,ax		; start CRC16 at zero
	call	crc16
	popm	cx
	sub	cx,ax		; compare the two CRC16's
	jz	.exit
	mov	cl,-8		; CRC error on read
%endif
	jmp	.exit		; exit with error code

.err2:
	popm	si,di		; clear sector number
.err1:
	popm	si,di		; clear buffer address
.exit:
	popm	ax		; get CX saved
	mov	ch,ah		; restore CH, CL is error code
	popm	ax,bx,dx,si,di
	or	cl,cl		; set the Z flag
	ret


	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDwrite1sec	write a sector
;
;  Enter with:
;	DX:AX	sector number to write
;	ES:BX	data buffer from which to write
;
;  Return with:
;	CL	error code (0 means success)
;	DX:AX	preserved
;	ES:BX	preserved
;	SI, DI, CH are preserved
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDwrite1sec:
	pushm	ax,bx,dx,si,di
	pushm	cx

	pushm	bx,es		; save buffer address
	pushm	ax,dx		; save sector number

	mov	ah,3		; show it is a write check
	call	SDcheck
	jnz	.err2

	call	SDwaitrdy	; wait for card to go ready
	jc	.err2

	popm	ax,dx		; get sector address
	call	SDsetaddr	; set up card address in DX:AX
; DX:AX is byte address (SDSC) or sector address (SDHC)
	mov	bl, 40h | 24	; CMD24 = write one sector
	call	SDcmdset	; CMD24 (DX:AX) crc
	call	cmd_R1		; execute the command
	mov	sp,si		; purge command from the stack
	jz	.3
	call	SDdone		; done if error
      	jmp	.err1		; exit on error
.3:
	popm	bx,es		; restore data pointer
%if USE_CRCs
	xor	ax,ax		; start CRC16 at zero
	mov	cx,512		; write 512 bytes
	call	crc16
	mov	cx,512		; write 512 bytes
	sub	bx,cx		; restore data pointer
%else
	mov	ax,0FFFFh	; dummy CRC16 
	mov	cx,512		; write 512 bytes
%endif
	call	SDputdata	; **
	call	SDdone		; end of command
	jmp	.exit

.err2:
	popm	si,di		; clear sector number
.err1:
	popm	si,di		; clear buffer address
.exit:
	mov	cl,al		; move error code to CL
	popm	ax		; get CX saved
	mov	ch,ah		; restore CH, CL is error code
	popm	ax,bx,dx,si,di
	or	cl,cl		; set the Z flag
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDverify1sec	Verify a single sector (of 512 bytes)
;
;  Enter with:
;	DX:AX	sector number to read
;
;  Return with:
;	CL	error code (0 means success)
;	DX:AX	preserved
;	ES:BX	preserved
;	SI, DI, CH are preserved
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDverify1sec:
	pushm	ax,bx,dx,si,di
	pushm	cx

	pushm	ax,dx		; save sector number

	mov	ah,2		; show it is a read check
	call	SDcheck
	jnz	.err2

	call	SDwaitrdy	; wait for card to go ready
	jc	.err2
	popm	ax,dx		; get sector address

%if QUICK_VERIFY
	xor	cx,cx
%else
	call	SDsetaddr	; set up card address in DX:AX
; DX:AX is byte address (SDSC) or sector address (SDHC)
	mov	bl, 40h | 17	; CMD17 = read one sector
	call	SDcmdset	; CMD17 (DX:AX) crc
	call	cmd_R1		; execute the command
	mov	sp,si		; purge command from the stack
	jz	.3
	call	SDdone		; done if error
      	jmp	.err1		; exit on error
.3:
	mov	cx,512		; read 512 bytes
	call	SDtestdata	; **
%endif
	call	SDdone		; end of command

	or	cl,ch		; is CRC zero, create error code
	jz	.exit

	mov	cl, ERR_uncorrectable_CRC_error
.err2:
	popm	si,di		; clear sector number
.err1:
;;;	popm	si,di		; clear buffer address
	mov	cl,ah		; error code to CL
.exit:
	popm	ax		; get CX saved
	mov	ch,ah		; restore CH, CL is error code
	popm	ax,bx,dx,si,di
	or	cl,cl		; set the Z flag
	ret


	

%if USE_CRCs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; crc16		add data to the input CRC16 calculation
;
;  Enter with:
;	ES:BX	data pointer
;	CX	count of bytes
;	AX	partial CRC16 sum
;
;  Return with:
;	ES:BX	updated data pointer
;	CX = 0
;	AX	updated CRC16 sum
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	crc16
crc16:
	pushm	si		; save SI

	mov	si,bx		; use ES:SI to address data
.2:
	mov	bl,ah		; form index into table
	xor	bh,bh		; zap BH
  es	xor	bl,[si]		; form table index
  	inc	si
  	mov	ah,al		; update CRC16
	xor	al,al
	shl	bx,1
  cs	xor	ax,[crc16tab + bx]
  	loop	.2

	mov	bx,si		; updated BX value
	popm	si
	ret


%include "crc16tab.inc"
%endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; xbits		extract BigEndian bits
;
;  Enter with:
;	ES:SI	points at byte containing bit 0
;	CH:CL	hi-bit : lo-bit	 to be extracted
;
;  Exit with:
;	AX	extracted value
;	no other registers altered
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
xbits:
	pushm	bx,cx,si
	mov	al,cl
	xor	ah,ah
	shr	ax,3			; AX is byte offset
	sub	si,ax			; SI points at first byte
	sub	ch,cl			; CH is bit count - 1
  es	mov	al,[si]
  es	mov	ah,[si-1]
  es	mov	bl,[si-2]		; allow for max. of 12 bit field
	and	cl,7			; CL is bit offset
	jz	.3
.1:	shr	bl,1
	rcr	ax,1
	dec	cl
	jnz	.1
.3:	mov	bx,0FFFEh		; mask 1 bit
	shr	cx,8			; mov CH to CL, zero extended
	shl	bx,cl			; make BX into a mask
	not	bx
	and	ax,bx			; mask bits in AX
	popm	bx,cx,si
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; _SDcsd	extract information from the CSD register
;
;  word __cdecl SDcsd(word what, byte *csd)
;
;  Enter with:
;	arg1  = what: AH=hi-bit number, AL=lo-bit number
;	arg2  = far pointer to CSD array
;
;  Exit with:
;	AX = extracted value
;
;  Uses:
;	xbits
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	_SDcsd
_SDcsd:
	push	bp
	mov	bp,sp
	pushm	cx,si,es

	mov	cx,ARG(1)
	les	si,ARG(2)
	add	si,15		; point at end of array
	call	xbits

	popm	cx,si,es
	leave
	ret


%if DEBUG>0
writeCSD:
	mov	si,SDcsd
	mov	cx,16
.1:	lodsb
	call	boutsp
	loop	.1
; NewLine
crlf:
	mov	al,0Dh
	call	cout
	mov	al,0Ah
	call	cout
	ret


; output byte from AL, then a space
boutsp:
	call	bout
	mov	al,20h
	call	cout
	ret
; word output from AX
wout:
	xchg	al,ah
	call	bout
	xchg	al,ah
; byte output from AL
bout:
	rol	al,4
	call	nout
	rol	al,4
; nibble output from low nibble in AL
nout:
	push	ax
	and	al,0Fh		; mask nibble
	daa			; convert to decimal
	add	al,0F0h		; overflow to Carry
	adc	al,040h		; convert to ASCII decimal or hex digit
	call	cout
	pop	ax
	ret
	
; character output from AL
cout:
	pushm	ax,bx
	mov	ah,0Eh		; write character in AL
	mov	bx,0007h
	int	10h
	popm	ax,bx
	ret
%endif

	SEGMENT	_DATA
;;;SDcardtype	db	0, 0		; SD card type SDtypeSDSC=2, HC=3, ...
;;;SDstatus	db	0, 0		; status byte from command

;;;SDcsd		times 16 db 0		; SD card CSD

%if DEBUG>=1
buffer:	
	times	512 db 0E7h
lbuf	equ	$-buffer
%endif


;-------------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; End of SDcard disk driver
;
; Begin SBC-188 BIOS code
;------------------------------------------------------------------------------------	
%ifndef STANDALONE
	
	SEGMENT	_TEXT


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
;       DL = device code (80h..83h)
;       DS set to BIOS data area
;
;  Exit with:
;       DS:SI points at the fixed disk table
;	DI = unit number
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

	call	SDsetunit		; get DI as unit number

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
	call	SDinit		; no real init until referenced
        mov     ah,0
        jmp     exit_sequence





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fn02 -- Disk Read
; fn03 -- Disk Write
; fn04 -- Disk Verify (future)
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
	xor	cl,cl		; no error to begin

        mov     ch,[bp + offset_AL]      ; get sector count
        mov     bx,[bp + offset_BX]      ; get transfer address

; Enter here on Read, Write, Verify or
;     extended  Read, Write, Verify, Seek
RWV: 
        inc     ch                      ; zero is valid for no transfer
        jmp     .6              ; enter loop at the bottom
; the read/write/verify loop
.1:
; LBA call is okay
        test    byte [bp+offset_AH],04h         ; Seek/Verify?
        jnz     .4
        test    byte [bp+offset_AH],01h         ; Write?
        jnz     .3
.2:				; READ operation
	call	SDread1sec
	jz	.5
	jmp	.8		; error code in CL

.3:
	call	SDwrite1sec
	jz	.5
        jmp     .8		; error code in CL

.4:
	call	SDverify1sec
	jnz	.8		; error code is in CL

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

.8:	mov	ah,cl		; error code to AH
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
	push	dx			; protect DH
	call	get_IDE_num		; get number of IDE disks
	pop	dx			; restore DH
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
        mov     ah,3		   ; code for HARD DISK
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
;  This operation is a complete No-Op for the DIDE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn4E:
        call    integrity
        mov     ax,0001h
        jmp     exit_sequence




%endif  ; STANDALONE



