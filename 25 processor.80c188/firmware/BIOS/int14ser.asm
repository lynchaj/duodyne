;========================================================================
; int14ser.asm -- Serial Port Services
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


%define u_rbr	equ     0	;Rcvr Buffer / read only
%define u_thr	equ     0 	;Transmit Holding / write only
%define u_ier	equ     1	;Interrupt Enable
%define u_iir	equ     2	;Interrupt Ident / read only
%define u_fcr	equ     2	;FIFO Control / write only
%define u_lcr	equ     3	;Line Control
%define u_mcr	equ     4	;Modem Control
%define u_lsr	equ     5	;Line Status
%define u_msr	equ	6	;Modem Status
%define u_sr	equ	7	;Scratch
%define u_dll	equ     0	;Divisor Latch LS Byte
%define u_dlm 	equ     1	;Divisor Latch MS Byte


	SEGMENT	_TEXT
;===============================================================================
;  BIOS_call_14h  - Serial port communication services
;
;			Registers	Function
;	Entry  :	AH = 0		Initialize port
;			AH = 1		Send character in AL
;			AH = 2		Receive character in AL
;			AH = 3		Get serial port status
;			
;			AL = 		character to send or receive
;			DX =		0-based port number
;			All registers preserved except AX
;
;	Exit   :	AH =	Port Status
;				|7|6|5|4|3|2|1|0|
;		 		 | | | | | | | `---- data ready
;				 | | | | | | `----- overrun error
;	 			 | | | | | `------ parity error
;	 			 | | | | `------- framing error
;		 		 | | | `-------- break detect
;	 			 | | `--------- transmit holding register empty
;	 			 | `---------- transmit shift register empty
;	 			 `----------- time out (N/A for functions 1 and 2)
;			AL =	Modem Status
;				|7|6|5|4|3|2|1|0|
;		 		 | | | | | | | `---- clear to send status changed
;		 		 | | | | | | `----- data set ready status changed
;		 		 | | | | | `------ trailing edge ring indicator
;		 		 | | | | `------- receive line signal changed
;		 		 | | | `-------- clear to send
;		 		 | | `--------- data set ready
;		 		 | `---------- ring indicator
;		 		 `----------- receive line signal detected
;
;===============================================================================

	global BIOS_call_14h

BIOS_call_14h:
%if TRACE
	call	int_trace
%endif	; TRACE
	
	STI                                     ; Serial com. RS232 services
        PUSH    DS                              ;  ...thru IC 8250 uart (ugh)
        PUSH    DX                              ;  ...DX = COM device (0 - 3)
        PUSH    SI
        PUSH    DI
        PUSH    CX
        PUSH    BX
        MOV     BX,40h
        MOV     DS,BX
        MOV     DI,DX                           ;
        MOV     BX,DX                           ; RS232 serial COM index (0-3)
        SHL     BX,1                            ;  ...index by bytes
        MOV     DX,[BX]                         ; Convert index to port number
        OR      DX,DX                           ;  ...by indexing 40:0
        JZ      COM_ND                          ;  ...no such COM device, exit
        OR      AH,AH                           ; Init on AH=0
        JZ      COMINI
        DEC     AH
        JZ      COMSND                          ; Send on AH=1
        DEC     AH
        JZ      COMGET                          ; Rcvd on AH=2
        DEC     AH
        JZ      COMSTS                          ; Stat on AH=3

COM_ND: POP     BX                              ; End of COM service
        POP     CX
        POP     DI
        POP     SI
        POP     DX
        POP     DS
        IRET

divisors:				; expanded to higher bit rates for SBC-188
					; limited to 8 slots
;	dw	UART_OSC/16/300		; 300 Kbit/sec
	dw	0180h
;	dw	UART_OSC/16/1200	; 1200 Kbit/sec
	dw	0060h
;	dw	UART_OSC/16/2400	; 2400 Kbit/sec
	dw	0030h
;	dw	UART_OSC/16/9600	; 9600 Kbit/sec
	dw	000Ch
;	dw	UART_OSC/16/19200	; 19200 Kbit/sec
	dw	0006h
;	dw	UART_OSC/16/38400	; 38400 Kbit/sec
	dw	0003h
;	dw	UART_OSC/16/57600	; 57600 Kbit/sec
	dw	0002h
;	dw	UART_OSC/16/115200	; 115200 Kbit/sec
	dw	0001h
	
	
COMINI: PUSH    AX                              ; Init COM port.  AL has data
                                                ; = (Word Length in Bits - 5)
                                                ;  +(1 iff two stop bits) *  4
                                                ;  +(1 iff parity enable) *  8
                                                ;  +(1 iff parity even  ) * 16
                                                ;  +(BAUD: select 0-7   ) * 32
        MOV     BL,AL
        ADD     DX,3                            ; Line Control Register (LCR)
        MOV     AL,80h                          ;  ...index RS232_BASE + 3
        OUT     DX,AL                           ; Tell LCR to set (latch) baud
        MOV     CL,4
        ROL     BL,CL                           ; Baud rate selects by words
        AND     BX,00001110b                    ;  ...mask off extraneous
    cs  MOV     AX,Word [divisors + bx]		; Clock divisor in AX ***CS?
        SUB     DX,3                            ; Load in lo order baud rate
        OUT     DX,AL                           ;  ...index RS232_BASE + 0
        INC     DX                              ; Load in hi order baud rate
        MOV     AL,AH
        OUT     DX,AL                           ;  ...index RS232_BASE + 1
        POP     AX
        INC     DX                              ; Find Line Control Register
        INC     DX                              ;  ...index RS232_BASE + 3
        AND     AL,00011111b                    ; Mask out the baud rate
        OUT     DX,AL                           ;  ...set (censored) init stat
        MOV     AL,0
        DEC     DX                              ; Interrupt Enable Reg. (IER)
        DEC     DX                              ;  ...index RS232_BASE + 1
        OUT     DX,AL                           ; Interrupt is disabled
        DEC     DX
        JMP     short COMSTS                    ; Return current status

COMSND: PUSH    AX                              ; Send AL thru COM port
        MOV     AL,3
        MOV     BH,00110000b                    ;(Data Set Ready,Clear To Send)
        MOV     BL,00100000b                    ;  ..(Data Terminal Ready) wait
        CALL    WAITFR                          ; Wait for transmitter to idle
        JNZ     HUNG                            ;  ...time-out error
        SUB     DX,5                            ;  ...(xmit) index RS232_BASE
        POP     CX                              ; Restore char to CL register
        MOV     AL,CL                           ;  ...get copy to load in uart
        OUT     DX,AL                           ;  ...transmit char to IC 8250
        JMP     COM_ND                          ;  ...AH register has status

HUNG:   POP     CX                              ; Transmit error, restore char
        MOV     AL,CL                           ;  ...in AL for compatibility
                                                ;  ...fall thru to gen. error
HUNGG:  OR      AH,80h                          ; Set error (=sign) bit in AH
        JMP     COM_ND                          ;  ...common exit

COMGET: MOV     AL,1                            ; Get char. from COM port
        MOV     BH,00100000b                    ; Wait on DSR (Data Set  Ready)
        MOV     BL,00000001b                    ; Wait on DTR (Data Term.Ready)
        CALL    WAITFR                          ;  ...wait for character
        JNZ     HUNGG                           ;  ...time-out error
        AND     AH,00011110b                    ; Mask AH for error bits
        SUB     DX,5                            ;  ...(rcvr) index RS232_BASE
        IN      AL,DX                           ; Read the character
        JMP     COM_ND                          ;  ...AH register has status

COMSTS: ADD     DX,5                            ; Calculate line control stat
        IN      AL,DX                           ;  ...index RS232_BASE + 5
        MOV     AH,AL                           ;  ...save high order status
        INC     DX                              ; Calculate modem stat. reg.
        IN      AL,DX                           ;  ...index RS232_BASE + 6
        JMP     COM_ND                          ;  ...save low  order status
                                                ;AX=(DEL Clear_To_Send) *    1
                                                ;   (DEL Data_Set_ready)*    2
                                                ;   (Trailing_Ring_Det.)*    4
                                                ;   (DEL Carrier_Detect)*    8
                                                ;   (    Clear_To_Send )*   16
                                                ;   (    Data_Set_Ready)*   32
                                                ;   (    Ring_Indicator)*   64
                                                ;   (    Carrier_Detect)*  128
                                                ;        **************
                                                ;   (    Char  received)*  256
                                                ;   (    Char smothered)*  512
                                                ;   (    Parity error  )* 1024
                                                ;   (    Framing error )* 2048
                                                ;   (    Break detected)* 4096
                                                ;   (    Able to xmit  )* 8192
                                                ;   (    Transmit idle )*16384
                                                ;   (    Time out error)*32768

POLL:   MOV     BL,byte [DI+7Ch]		; Wait on BH in status or error

POLL_1: SUB     CX,CX                           ; Outer delay loop
POLL_2: IN      AL,DX                           ;  ...  inner loop
        MOV     AH,AL
        AND     AL,BH                           ; And status with user BH mask
        CMP     AL,BH
        JZ      POLLXT                          ;  ...  jump if mask set
        LOOP    POLL_2                          ; Else try again
        DEC     BL
        JNZ     POLL_1
        OR      BH,BH                           ; Clear mask to show timeout

POLLXT: RET                                     ; Exit AH reg. Z flag status

WAITFR: ADD     DX,4                            ; Reset the Modem Control Reg.
        OUT     DX,AL                           ;  ...index RS232_BASE + 4
        INC     DX                              ; Calculate Modem Status Reg.
        INC     DX                              ;  ...index RS232_BASE + 6
        PUSH    BX                              ; Save masks (BH=MSR,BL=LSR)
        CALL    POLL                            ; ...wait on MSR modem status
        POP     BX                              ; ...restore wait masks BH,BL
        JNZ     WAITF1                          ; ..."Error Somewhere" by DEC

        DEC     DX                              ; Calculate Line Status Reg.
        MOV     BH,BL                           ;  ...index RS232_BASE + 5
        CALL    POLL                            ;  ...wait on LSR line status

WAITF1: RET                                     ; Status in AH reg. and Z flag


;========================================================================
; _spp_init - Initialize 16C552 controller chip
;
;  void __cdecl spp_init(word base, word divisor)
;
;  Enter with:
;	arg1 = port address of board
;	arg2 = initial baud rate divisor
;
;  Exit with:
;	void
;
;  Uses:
;
;
;
;
;========================================================================
	global	_spp_init
_spp_init:

	push	bp
	mov	bp,sp
	pushm	bx,cx,dx

	mov	bx,ARG(2)		; get divisor
	mov	dx,ARG(1)		; get base port
	mov	al,80h			; set divisor latch bit
	add	dx,3			; LCR
	out	dx,al

	mov	al,bl			; low byte
	mov	dx,ARG(1)		; get base port
	out	dx,al			; DLL

	mov	al,bh			; high byte
	mov	dx,ARG(1)		; get base port
	add	dx,1			; DLM
	out	dx,al


	mov	al,03h			; no parity, one stop bit, 8 data bits
	mov	dx,ARG(1)		; get base port
	add	dx,3			; LCR
	out	dx,al

	mov	al,7
	mov	dx,ARG(1)		; get base port
	add	dx,4			; MCR
	out	dx,al

	mov	al,0			; disable interrupts for now
	mov	dx,ARG(1)		; get base port
	add	dx,1			; IER
	out	dx,al

	mov	dx,ARG(1)		; get base port
	add	dx,2			; FCR-disable FIFO for now
	out	dx,al

	popm	bx,cx,dx
	leave
	ret
