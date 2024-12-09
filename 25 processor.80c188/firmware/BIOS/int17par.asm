	;========================================================================
	; int17ser.asm - - Parallel Port Print Services
	;========================================================================
	;
	; Compiles with NASM 2.14, might work with other versions
	;
	; Based on the code contained in the "Generic XT BIOS" from Anonymous
	; (1988)
	;
	; Provided for hobbyist use on the N8VEM SBC - 188 board.
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
	;========================================================================

	%include "config.asm"
	%include "cpuregs.asm"
	%include "equates.asm"

	SEGMENT _TEXT
	;===============================================================================
	; BIOS_call_17h - Print services
	;
	; Purpose: INT 17h BIOS printer services.
	; Entry : AH = 0 Print character in AL
	; AH = 1 Initialize port
	; AH = 2 Read printer port status to AH
	;
	; AL = character to print
	; DX = 0 - based port number
	; All registers preserved except AX
	;
	; Exit : AH = Port Status
	; |7|6|5|4|3|2|1|0| AH (status)
	; | | | | | | | ` - - - - time - out
	; | | | | | ` - ' - - - - - - unused
	; | | | | ` - - - - - - - - 1 = I / O error (pin 15)
	; | | | ` - - - - - - - - - 1 = printer selected / on - line (pin 13)
	; | | ` - - - - - - - - - - 1 = out of paper (pin 12)
	; | ` - - - - - - - - - - - 1 = printer acknowledgment (pin 10)
	; ` - - - - - - - - - - - - 1 = printer not busy (pin 11)
	;
	;===============================================================================
	; ENTRY 0EFD2h ; IBM entry for parallel LPT

	global BIOS_call_17h

BIOS_call_17h:
	pushm dx, bx, cx
	sti                          ; Printer Services - Support Duodyne Media Board LPT
	cmp ah, 0
	je LP_OUT                    ; Function is print, AH=0
	cmp ah, 1
	je LP_INI                    ; Function is init, AH=1
	cmp ah, 2
	je LP_STS                    ; Get the status, AH=2
	popm dx, bx, cx
	iret

LP_OUT:
	mov dx, ParPrinter
	out dx, al                   ; Char - - > data lines 0 - 7
	mov dx, ParPrinter + 1       ; Printer status port
	mov bh, PrinterTimeout       ; Load time out parameter
	mov ah, al

.1:
	xor cx, cx                   ; Clear lo order time out

.2:
	in al, dx                    ; Get line printer status
	or al, al                    ; ...ready?
	js .3                        ; ...done if so
	loop .2
	dec bh                       ; Decrement time out
	jnz .1

	or al, 00000001b             ; Set timeout in Status Byte
	and al, 11111001b            ; ...bits returned to caller
	xor al, 01001000b            ; ...toggle ERROR, ACKNOWLEDGE
	xchg al, ah
	; Exit, AH=Status, AL=character
	popm dx, bx, cx
	iret

.3:
	mov dx, ParPrinter + 2       ; Printer control port
	mov al, 00001101b            ; Set output strobe hi
	out dx, al                   ; ...data lines 0 - 7 valid
	mov al, 00001100b            ; Set output strobe lo
	out dx, al                   ; ...data lines 0 - 7 ?????
        jmp LP_STS

LP_INI:
        mov ah,al                ; Initialize the line printer
	mov dx, ParPrinter + 2       ; Printer control port
	mov al, 00001000b
	out dx, al                   ; Request initialize

	mov cx, 5DCh                 ; ...delay
.4:
        loop .4
	mov al, 00001100b            ; Set output strobe lo
	out dx, al                   ; ...data lines 0 - 7 ?????
LP_STS:
	mov dx, ParPrinter + 1       ; Printer status port
	in al, dx                    ; Read printer status
	and al, 11111000b            ; ...bits returned to caller
	xor al, 01001000b            ; ...toggle ERROR, ACKNOWLEDGE
	xchg al, ah
	popm dx, bx, cx
	iret
