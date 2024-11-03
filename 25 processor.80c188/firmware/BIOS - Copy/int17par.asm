;========================================================================
; int17ser.asm -- Parallel Port Print Services
;========================================================================
;
; Compiles with NASM 2.14, might work with other versions
;
; Copyright (C) 2019 Richard Cini. Based on the code contained in the
; "Generic XT BIOS" from Anonymous (1988)
;
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

%include	"config.asm"
%include	"cpuregs.asm"
%include	"equates.asm"

	SEGMENT	_TEXT
;===============================================================================
;  BIOS_call_17h  - Print services
;
;	Purpose:  INT 17h BIOS printer services.
;	Entry  :	AH = 0		Print character in AL
;			AH = 1		Initialize port
;			AH = 2		Read printer port status to AH
;			
;			AL = 		character to print
;			DX =		0-based port number
;			All registers preserved except AX
;
;	Exit   :	AH =	Port Status
;				|7|6|5|4|3|2|1|0|  AH (status)
;	 			 | | | | | | | `----  time-out
;	 			 | | | | | `-'------  unused
;	 			 | | | | `--------  1 = I/O error (pin 15)
;	 			 | | | `---------  1 = printer selected/on-line (pin 13)
;	 			 | | `----------  1 = out of paper (pin 12)
;	 			 | `-----------  1 = printer acknowledgment (pin 10)
;	 			 `------------	1 = printer not busy (pin 11)
;
;===============================================================================
;        ENTRY   0EFD2h				; IBM entry for parallel LPT

	global	BIOS_call_17h

BIOS_call_17h:
%if TRACE
	call	int_trace
%endif	; TRACE
	
	STI                                     ; Parallel printer services
        PUSH    DS
        PUSH    BX
        PUSH    CX
        PUSH    DX
        MOV     BX,40h
        MOV     DS,BX
        MOV     BX,DX                           ; DX is printer index (0 - 3)
        SHL     BX,1                            ;  ...word index
        MOV     DX,[BX+8]                       ; Load printer port
        OR      DX,DX
        JZ      LP_01                           ; Goes to black hole
        OR      AH,AH
        JZ      LP_02                           ; Function is print, AH=0
        DEC     AH
        JZ      LP_INI                          ; Function is init , AH=1
        DEC     AH
        JZ      LP_STS                          ; Get the status   , AH=2

LP_01:  POP     DX
        POP     CX
        POP     BX
        POP     DS
        IRET

LP_02:  OUT     DX,AL                           ; Char --> data lines 0-7
        INC     DX                              ; Printer status port
        MOV     BH,[BX+78h]                     ; Load time out parameter
        MOV     AH,AL

LP_05:  XOR     CX,CX                           ; Clear lo order time out

LP_POL: IN      AL,DX                           ; Get line printer status
        OR      AL,AL                           ;  ...ready?
        JS      LP_DON                          ;  ...done if so
        LOOP    LP_POL
        DEC     BH                              ; Decrement hi order time out
        JNZ     LP_05

        OR      AL,00000001b                    ; Set timeout in Status Byte
        AND     AL,11111001b                    ;  ...bits returned to caller
        JMP     short LP_TOG

LP_DON: INC     DX                              ; Printer control port
        MOV     AL,00001101b                    ; Set output strobe hi
        OUT     DX,AL                           ;  ...data lines 0-7 valid

LP_STR: MOV     AL,00001100b                    ; Set output strobe lo
        OUT     DX,AL                           ;  ...data lines 0-7 ?????
        DEC     DX                              ; Printer status port
        JMP     short LP_ST1			; ...get line printer status

LP_STS: MOV     AH,AL                           ; Save copy of character
        INC     DX                              ; Printer status port

LP_ST1: IN      AL,DX                           ; Read printer status
        AND     AL,11111000b                    ;  ...bits returned to caller

LP_TOG: XOR     AL,01001000b                    ;  ...toggle ERROR,ACKNOWLEDGE
        XCHG    AL,AH
        JMP     LP_01                           ; Exit, AH=Status,AL=character

LP_INI: MOV     AH,AL                           ; Initialize the line printer
        INC     DX
        INC     DX
        MOV     AL,00001000b
        OUT     DX,AL                           ; Request initialize
        MOV     CX,5DCh                         ;  ...delay
LP_DLY: LOOP    LP_DLY
        JMP     LP_STR                          ; Strobe the line printer

