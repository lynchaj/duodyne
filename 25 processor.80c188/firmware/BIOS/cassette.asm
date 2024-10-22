;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CASSETTE.ASM -- Cassette I/O BIOS calls (int 15h functions)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   This version is for assembly by  NASM 0.98.39 or later
;
; Copyright (C) 2013 Richard Cini.  All rights reserved.
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
;--------------------------------------------------------
; Cassette support routines
;	(AH) = 0 TURN CASSETTE MOTOR ON
;	(AH) = 1 TURN CASSETTE MOTOR OFF
;	(AH) = 2 READ 1 OR MORE 256 BYTE BLOCKS FROM CASSETTE
;		(ES,BX) = POINTER TO DATA BUFFER
;		(CX) = COUNT OF BYTES TO READ
;		ON EXIT:
;  		(ES,BX) = POINTER TO LAST BYTE READ + 1
;  		(DX) = COUNT OF BYTES ACTUALLY READ
;  		(CY) = 0 IF NO ERROR OCCURRED
;  		     = 1 IF ERROR OCCURRED
;  		(AH) = ERROR RETURN IF (CY)= 1
;  			= 01 IF CRC ERROR WAS DETECTED
;  			= 02 IF DATA TRANSITIONS ARE LOST
;  			= 04 IF NO DATA WAS FOUND
;  	(AH) = 3 WRITE 1 OR MORE 256 BYTE BLOCKS TO CASSETTE
;  		(ES,BX) = POINTER TO DATA BUFFER
;  		(CX) = COUNT OF BYTES TO WRITE
;  		ON EXIT:
;		(EX,BX) = POINTER TO LAST BYTE WRITTEN + 1
;		(CX) = 0
;	(AH) = 4 TURN GPIO2 ON
;	(AH) = 5 TURN GPIO2 OFF
;	(AH) = ANY OTHER THAN ABOVE VALUES CAUSES (CY)= 1
;		AND (AH)= 80 TO BE RETURNED (INVALID COMMAND).
;--------------------------------------------------------
; PURPOSE:
;  TO TURN ON CASSETTE MOTOR
;  16550 I/O pins are active low so we need to add
;  an inverter (7400) before the 75452 to make this work.
;  Cassette motor connected to OUT1* on 16550, which is
;  bit2 of MCR.
;--------------------------------------------------------
fn00:
	and	byte [break_flag],07FH		; turn off break flag   jrc
	mov	dx,cuart_mcr			; get device code
	in	al,dx				;read cassette uart mcr
	or	al,04H				; SET BIT TO TURN ON
W3:	out	dx,al				;WRITE IT OUT
	mov	word [bp+offset_AX],0000h	; signal success to caller
	jmp	clear_carry


;----------------------------------
; PURPOSE:
;  TO TURN CASSETTE MOTOR OFF
;-----------------------------------
fn01:
	and	byte [break_flag],07FH	; turn off break flag    jrc
	mov	dx,cuart_mcr		; get device code
	in	al,dx			;read cassette uart mcr
	and	al,~04h			; clear bit to turn off motor
	jmp	W3			;write it, clear error, return


;--------------------------------------------
; PURPOSE:
;  TO READ 1 OR MORE 256 BYTE BLOCKS FROM CASSETTE
;
; ON ENTRY:
;  ES IS SEGMENT FOR MEMORY BUFFER (FOR COMPACT CODE)
;  BX POINTS TO START OF MEMORY BUFFER
;  CX CONTAINS NUMBER OF BYTES TO READ
; ON EXIT:
;  BX POINTS 1 BYTE PAST LAST BYTE PUT IN MEM
;  CX CONTAINS DECREMENTED BYTE COUNT
;  DX CONTAINS NUMBER OF BYTES ACTUALLY READ
;
;  CARRY FLAG IS CLEAR IF NO ERROR DETECTED
;  CARRY FLAG IS SET IF CRC ERROR DETECTED
;--------------------------------------------
fn02:
READ_BLOCK:
	PUSH	BX
	PUSH	CX
	PUSH	SI
	and	byte [break_flag],07FH	; turn off break flag    jrc
	MOV	SI,7		; retry count for leader
	CALL	BEGIN_OP	; start the tape
	
W4:
	CALL	READ_BYTE	; get initial byte
	MOV	[last_val],AL
	MOV	DX,010H		; look for 16 leader bytes

W5:
	TEST	byte [break_flag],80h		; jrc
	JZ	W6		; jump if no break key
	JMP	W17		; jump if break key hit

W6:
	CMP	AL,0FFH		; leader byte?
	JNE	W7		; try again if not found
	
	DEC	DX		; yes, a leader byte
	JNZ	W4		; find another leader byte
	JMP	W8		; jump if at least 16 found

W7:
	DEC	SI		; no leader byte...try again
	JZ	W17		; ran out of retries
	JMP	W4		; loop
		
W8:				; 16 bytes of leader found
	TEST	byte [break_flag],80h	; test for break key   jrc
	JNZ	W17		; jump if break key hit

W9:				; loop until start and sync byte
	CALL	READ_BYTE
	CMP	AL,03CH		; start byte
	JNE	W9
	
	CALL	READ_BYTE
	CMP	AL,0E6H		; sync byte
	JNE	W17		; error
	
; start and sync found, start reading data blocks
	POP	SI
	POP	CX
	POP	BX

; read 1 or more 256-byte blocks
	PUSH	CX		; save byte count

W10:
	MOV	word [crc_reg],0FFFFH	; initialize CRC
	MOV	DX,256		; for 256 byte blocks

W11:
	TEST	byte [break_flag],80h	; test for break key   jrc
	JNZ	W13		; jump if break key hit
	CALL	READ_BYTE	; get a byte from cassette
	JC	W13		; CY set indicates no data
	JCXZ	W12		; reached end of buffer; skip block
	
	MOV	[ES:BX],AL	; save to memory
	INC	BX		; increment memory pointer
	DEC	CX		; decrement count

W12:
	DEC	DX		; decrement block count
	JG	W11		; read more
	CALL	READ_BYTE	; read two CRC bytes
	CALL	READ_BYTE
	SUB	AH,AH
	CMP	word [crc_reg],1d0fh	; correct CRC?		jrc
	JNE	W14		; if not equal, CRC bad
	JCXZ	W15		; if byte count is 0, we've read enough so exit
	JMP	W10		; read more
	
W13:				; error 1 CRC
	MOV	AH,01H		; 
	
W14:
	INC	AH		; +1 error 2 

W15:
	POP	DX		; calculate count of bytes actually read
	SUB	DX,CX		; in DX
	PUSH	AX		; save return code
	TEST	AH,03H		; test for errors
	JNZ	W18		; jump if error detected
	CALL	READ_BYTE	; read trailer
	JMP	W18		; skip to turn off motor

W16:				; bad leader
	DEC	SI		; check retries
	JZ	W17		; jump if too many retries
	JMP	W4		; go back if not too many
	
W17:				; no data from cassette error
	POP	SI
	POP	CX
	POP	BX
	SUB	DX,DX		; 0 bytes read
	MOV	AH,04H		; time out error (no leader)
	PUSH	AX

W18:
	CALL	fn01		; turn off motor
	POP	AX		; restore return code
	mov	word [bp+offset_AX],ax	; return error code to caller	

	CMP	AX,0
	je	W19
	jmp	set_carry

W19:
	jmp	clear_carry


;--------------------------------------------
;  WRITE 1 OR MORE 256 BYTE BLOCKS FROM CASSETTE
;
; ON ENTRY:
;  ES IS SEGMENT FOR MEMORY BUFFER (FOR COMPACT CODE)
;  BX POINTS TO START OF MEMORY BUFFER
;  CX CONTAINS NUMBER OF BYTES TO READ
; ON EXIT:
;  BX POINTS 1 BYTE PAST LAST BYTE PUT IN MEM
;  CX CONTAINS DECREMENTED BYTE COUNT
;  DX CONTAINS NUMBER OF BYTES ACTUALLY READ
;--------------------------------------------
fn03:
WRITE_BLOCK:
	PUSH	BX		; used by BEGIN_OP
	PUSH	CX		; used in W23
;jrc	STD			; always count down 
	and	byte [break_flag],07FH	; turn off break flag  jrc
	CALL	BEGIN_OP	; uses BX
	MOV	AL,0FFH		; write leader 256 dup FF
	MOV	CX,00FFH	; leader count
	
W23:
	CALL	WRITE_BYTE	; output leader byte to cassette
	LOOP	W23		; write a 256-byte leader

	POP	CX		; restore CX
	POP	BX		; balance the stack
	MOV	AL,3CH		; get start byte
	CALL	WRITE_BYTE	; output start byte to cassette
	
	MOV	AL,0E6H		; get sync byte
	CALL	WRITE_BYTE	; output sync byte to cassette

WR_BLOCK:
	MOV	word [crc_reg],0FFFFH	; initialize CRC     jrc
	MOV	DX,256		; for 256 byte blocks

W24:	
	MOV	AL,[ES:BX]	; get a data byte from memory
	CALL	WRITE_BYTE	; output data byte to cassette
	JCXZ	W25		; unlexx CX=0, decrement counters
	INC	BX		; increment buffer ptr
	DEC	CX		; decrement byte count

W25:
	DEC	DX		; decrement block count
	JG	W24		; loop until 256-byte block is written

	MOV	AX,[crc_reg]	; otherwise, get checksum
	NOT	AX	
	PUSH	AX		; save it
	XCHG	AH,AL		; write MS byte first
	CALL	WRITE_BYTE	; and output it
	POP	AX		; get it back
	CALL	WRITE_BYTE	; now write LS byte
	OR	CX,CX		; is byte count 0?
	JNZ	WR_BLOCK	; jump if not done yet

; write trailer 4 bytes of FF
	PUSH	CX
	MOV	AX,0FFH
	MOV	CX,4
W26:
	CALL	WRITE_BYTE
	LOOP	W26

W31:
	MOV	CX,2C0H		; slight delay to settle
;jrc might use int 15h, fn86
	LOOP	W31

	POP	CX
	CALL	fn01		; turn off motor
	mov	word [bp+offset_AX],0000h	; return error code to caller
	jmp	clear_carry


;--------------------------------------------------------
; PURPOSE:
;  TO TURN CASSETTE GPIO2 ON
;  16550 I/O pins are active low so we need to add
;  an inverter (7400) before the 75452 to make this work.
;  GPIO2 is OUT2* on 16550, which is bit3 of MCR.
;--------------------------------------------------------
fn04:
	mov	dx,cuart_mcr			; get device code
	in	al,dx   			;read cassette uart mcr
	or	al,08h				; set bit to turn on
W40:	out	dx,al				;write it out
	mov	word [bp+offset_AX],0000h	; signal success to caller
	jmp	clear_carry


;----------------------------------
; PURPOSE:
;  TO TURN CASSETTE GPIO2 OFF
;-----------------------------------
fn05:
	mov	dx,cuart_mcr			; get device code
	in	al,dx				;read cassette uart mcr
	and	al,~08h				; clear bit to turn off motor
	jmp	W4				;write it, clear error, return
	





READ_BYTE:
; Borrowed from INT16 code
; returns with AL=char

.1:
	push	dx
	mov	dx,cuart_lsr
	in	al,dx
	and	al,01h		; do we have any data in receive buffer?
	jz	.exit

	mov	dx,cuart_rbr
	in	al,dx		; get next character
	
.exit:						; jrc
	pop	dx
	ret
	
	
WRITE_BYTE:
; Borrowed from INT10 code
	push	dx
	push	ax

	mov	dx,cuart_lsr
.1:
	in	al,dx
	test	al,20h		; THRE is empty
	jz	.1
	pop	ax
	mov	dx,cuart_thr
	out	dx,al		; write character
	pop	dx
	RET			; return from COUT


BEGIN_OP:
; start the motor and delay
; need to adjust loop due to processor
; being 3.4x faster than PC??
; original BL == 42h
;
	CALL	fn00		; turn on motor
;jrc might use int 15h, fn86
	MOV	BL,0E0H		; delay for tape drive to reach speed (1/2s)
W33:
	MOV	CX,700H		; inner loop approx 10ms
W34:	LOOP	W34
	DEC	BL
	JNZ	W33
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; end CASSETTE.ASM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

