; BASEio.ASM -- Basic I/O routines for the Dual SDcard add-on board
;
;
%define DEBUG 5
%include "sdcard.inc"

; Do we use CRC's with commands and data transfers?
%define USE_CRCs	TRUE
;%define USE_CRCs	FALSE


%ifndef BINFILE

	SEGMENT  _TEXT ALIGN=16 PUBLIC CLASS=CODE
	SEGMENT  _DATA ALIGN=2 PUBLIC CLASS=DATA
        SEGMENT  CONST ALIGN=2 PUBLIC CLASS=DATA
	SEGMENT  _BSS  ALIGN=2 PUBLIC CLASS=BSS
	GROUP	DGROUP CONST _DATA _BSS

	SEGMENT	_TEXT
%else

	org	100h
	global	STARTUP
STARTUP:
	mov	ax,cs
	mov	es,ax
	nop
	mov	ds,ax
	nop
	mov	ss,ax
	mov	sp,8000h

	cld

%if DEBUG>=5
	mov	si,CMD10	; read CID
	mov	cx,5
	call	calcCRC7

	mov	si,CMD59	; enable / disable CRSs
	mov	cx,5
	call	calcCRC7

	mov	si,CMD16
	mov	cx,5
	call	calcCRC7

; NEWLY ADDED ABOVE HERE

	mov	si,CMD9
	mov	cx,5
	call	calcCRC7

	mov	si,CMD58
	mov	cx,5
	call	calcCRC7

	mov	si,ACMD41
	mov	cx,5
	call	calcCRC7

	mov	si,CMD55
	mov	cx,5
	call	calcCRC7

	mov	si,CMD8
	mov	cx,5
	call	calcCRC7

	mov	si,CMD0
	mov	cx,5
	call	calcCRC7

	mov	bl,0
	mov	dx,0403h
	mov	ax,0201h
	call	SDcmdset
	add	sp,6

	mov	ax,4C00h | 50
	int	21h
%endif

	call	SDinit

	push	4000h
	popm	es
; zap the buffer and beyond
	mov	di,0
	mov	cx,2048
	mov	al,0E6h
   rep	stosb
   	mov	di,ax		; just garbage it

	xor	bx,bx
;	xor	ax,ax
; read sector 57
	mov	ax,57		; read sector 57
	xor	dx,dx
	call	SDread1sec
	jnz	.err

; write sector 2
	sub	bx,512
	mov	ax,2
	xor	dx,dx
	call	SDwrite1sec
	jnz	.err

; read sector 2 into a new buffer
	mov	ax,2
	xor	dx,dx
	call	SDread1sec
	jnz	.err
	
	mov	dx,SDoperation
	call	SDdone

	mov	si,0
	mov	di,200h
	mov	cx,di
	push	ds		; save DS
	pushm	es
	popm	ds		; DS=ES

  repe	cmpsb
	popm	ds		; restore DS
	mov	ax,cx
	je	.err
	inc	ax		; compare error

.err:
	nop			; place for breakpoint

	mov	ah,4Ch		; exit with return code in AL
	int	21h


%endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; @SDcsd	extract information from the CSD register
;
;  word __fastcall SDcsd(word what)
;
;  Enter with:
;	AX = what: AH=hi-bit number, AL=lo-bit number
;
;  Exit with:
;	AX = extracted value
;
;  Uses:
;	xbits
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	@SDcsd
@SDcsd:
	pushm	si
	mov	cx,ax		; "what" to CX
	push	ds
	popm	es
	mov	si,SDcsd+15
	call	xbits
	popm	si
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

;;;	xor	al,al		; set to deselect
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
	cmp	al,01h
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
	mov	word [SDstatus], -1	; zap both status bytes to 0FFh
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

	mov	cx,256			; init try counter
.1:
	pushm	cx
	mov	cx,128		       	; send a bunch of clocks
	mov	al, ChipSelect | DataIn
	call	SDsendclks
	popm	cx

	pushm	cs
	popm	es
	mov	si,CMD55
	call	cmd_R1
	test	al,~01h			; only OK(0) or Idle(1) are allowed
					;  responses
	call	SDdone
	jnz	.error

	mov	si,ACMD41
	call	cmd_R1
	call	SDdone
	cmp	al,00h
	je	.2
	cmp	al,01h
	jne	.error
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
	jnz	.error
%endif

; set the desired block length -- CMD16(512)
	xor	dx,dx			; MS word
	mov	ax,512			; LS word
	mov	bl, 40h | 16		; CMD16
	call	SDcmdset
	call	cmd_R1
	mov	sp,si			; clear command from stack
	call	SDdone
	jnz	.error

	mov	[SDstatus + di], al	; save SD card status

; get the Card Specific Data (CSD) register contents
	pushm	cs
	popm	es
	mov	si,CMD9
	call	cmd_R1
	pushm	ds
	popm	es
	mov	bx,SDcsd
	mov	cx,16
	call	SDgetdata
	call	SDdone
	jnz	.error
%if DEBUG>=2
	call	writeCSD
hi	equ	256
	mov	si,SDcsd+15
	mov	cx,127*hi+126		; CSD version
	call	xbits
	mov	cx,83*hi + 80		; read_bl_len (log2)
	call	xbits
	mov	cx, 73*hi + 62		; dev_size
	call	xbits
	mov	cx, 49*hi + 47		; size mult
	call	xbits
	mov	cx, 46*hi + 46		; erase bl en
	call	xbits
	mov	cx, 45*hi + 39		; erase sector size
	call	xbits

	xor	ax,ax
%endif


.okay:	clc

.exitstatus:
	mov	[SDstatus + di], al	; save SD card status
.exit:
	popm	si,di,es
	or	al,al			; set the Z-flag
	ret

.err58:
	call	SDdone
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
CMD10		db	40h | 10, 0, 0, 0, 0, 000
CMD16		db	40h | 16, 0, 0, 512>>8, 512&0FFh, 15h
CMD55		db	40h | 55, 0, 0, 0, 0, 65h
CMD59		db	40h | 59, 0, 0, 0, 1, 83h
ACMD41		db	40h | 41, 40h, 0, 0, 0, 077h
CMD58		db	40h | 58, 0, 0, 0, 0, 0FDh


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

	 global stepCRC7
stepCRC7:
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
	inc	al
	jz	.3
	mov	bl,al
	dec	bl
.3:	loop	.2
	mov	ax,bx 

	popm	bx,di,es
%else
	mov	cx,9			; response must come within 8 chars
.2:	call	SDgetchar
	test	al,80h			; check high bit for zero
	jz	.4			; 0xxx xxxxb is result byte
	loop	.2
.4:
%endif
	cbw				; extend to whole word
	or	al,al			; set Zero flag based on result
	popm	cx
	ret



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
;	ES:BX	points beyond end of buffer
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
;	AX	CRC16 byte to send
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
	pushm	ax			; save CRC16 byte

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
; _SDread1sector
;
;   int __cdecl SDread1sector(char buffer[512], long sector, byte unit);
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global	_SDread1sector
_SDread1sector:
	enter	0,0
	push	bx

	mov	al,ARG(5)
	and	al,UnitMask
	mov	dx,SDselect		; Select register
	out	dx,al

	les	bx,ARG(1)
	mov	ax,ARG(3)
	mov	dx,ARG(4)
	call	SDread1sec

	pop	bx
	leave
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDread1sec	Read a single sector (of 512 bytes)
;
;  Enter with:
;	DX:AX	sector number to read
;	ES:BX	buffer to receive data
;
;  Return with:
;	AX	error code (0 means success)
;	DX	is trashed
;	ES:BX	updated to beyond end of data
;	SI, DI, CX are preserved
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDread1sec:
	pushm	cx,si,di

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
	sub	ax,cx		; compare the two CRC16's
	jz	.exit
	mov	al,-8		; CRC error on read
%endif
	jmp	.exit		; exit with error code

.err2:
	popm	si,di		; clear sector number
.err1:
	popm	si,di		; clear buffer address
.exit:
	cbw
	popm	cx,si,di	; restore regs
	or	ax,ax		; set Z flag as appropriate
	ret


	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDwrite1sec	write a sector
;
;  Enter with:
;	DX:AX	sector number to write
;	ES:BX	data buffer from which to write
;
;  Return with:
;	AX	error code (0 means success)
;	DX	is trashed
;	ES:BX	updated to beyond end of data
;	SI, DI, CX are preserved
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDwrite1sec:
	pushm	cx,si,di

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
	mov	cx,512		; read 512 bytes
%if USE_CRCs
	xor	ax,ax		; start CRC16 at zero
	call	crc16
	mov	cx,512		; read 512 bytes
	sub	bx,cx		; restore data pointer
%else
	mov	ax,0FFFFh	; dummy CRC16 
%endif
	call	SDputdata	; **
	call	SDdone		; end of command
	jmp	.exit

.err2:
	popm	si,di		; clear sector number
.err1:
	popm	si,di		; clear buffer address
.exit:
	cbw
	popm	cx,si,di	; restore regs
	or	ax,ax		; set Z flag as appropriate
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
SDcardtype	db	0, 0		; SD card type SDtypeSDSC=2, HC=3, ...
SDstatus	db	0, 0		; status byte from command

SDcsd		times 16 db 0		; SD card CSD

%if DEBUG>=1
buffer:	
	times	512 db 0E7h
lbuf	equ	$-buffer
%endif

