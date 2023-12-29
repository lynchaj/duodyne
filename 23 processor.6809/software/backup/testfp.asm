.P816
;__TESTFP__________________________________________________________________________________________
;
;	TEST FRONT PANEL FOR THE THE RBC 65c816 SBC
;
;	WRITTEN BY: DAN WERNER -- 9/16/2017
;
;__________________________________________________________________________________________________
;
; DATA CONSTANTS
;__________________________________________________________________________________________________

        CHIP    65816           ; SET CHIP
        LONGA   OFF             ; ASSUME EMULATION MODE
        LONGI   OFF             ;
        PW      128
        PL      60
        INCLIST ON


;__________________________________________________________________________________________________
; $80A0-$80A3 FRONT PANEL 8255
;__________________________________________________________________________________________________

FPPORTA         .EQU $80A0
FPPORTB         .EQU $80A1
FPPORTC         .EQU $80A2
FPPIOCONT       .EQU $80A3


; ZERO PAGE TEMP STUFF

IRQVECTADD      .EQU $30        ; VECTOR FOR USER IRQ RTN
WORKPTR         .EQU $32        ; WORK POINTER FOR COMMAND PROCESSOR
JUMPPTR         .EQU $34        ; JUMP VECTOR FOR LOOKUP TABLE
TEMPWORD        .EQU $36        ;
TEMPWORD1       .EQU $38        ;
TEMPWORD2       .EQU $3A        ;
TEMPBYTE        .EQU $3B        ;
ACC             .EQU $3D        ; ACC STORAGE
XREG            .EQU $3E        ; X REG STORAGE
YREG            .EQU $3F        ; Y REG STORAGE
PREG            .EQU $40        ; CURRENT STACK POINTER
PCL             .EQU $41        ; PROGRAM COUNTER LOW
PCH             .EQU $42        ; PROGRAM COUNTER HIGH
SPTR            .EQU $43        ; CPU STATUS REGISTER
CKSM            .EQU $44        ; CHECKSUM
BYTECT          .EQU $45        ; BYTE COUNT
STRPTR          .EQU $48        ;
COUNTER         .EQU $4A        ;
SRC             .EQU $4C        ;
DEST            .EQU $4E        ;
COUNTER1        .EQU $50        ;

INBUFFER        .EQU $0200      ;


; BIOS JUMP TABLE
PRINTVEC        .EQU $FFD0
INPVEC          .EQU $FFD3
INPWVEC         .EQU $FFD6




        .ORG    4000H


        LDA     #MSG .AND $FF   ;
        STA     STRPTR          ;
        LDA     #MSG/256        ;
        STA     STRPTR+1        ;
        JSR     $C4A1           ; OUTPUT THE STRING


        JSR     FP_Init         ; Init 8255 for mTerm
        LDA     #CPUUP .AND $FF ;
        STA     STRPTR          ;
        LDA     #CPUUP/256      ;
        STA     STRPTR+1        ;

        JSR     SEGDISPLAY      ; DISPLAY
        BRK


;Loop:
;	CALL	KB_Get			; Get Key from KB
;	CP	012H			; IS '.'?
;	JR	Z,Exit			; YES, EXIT
;	CALL	HEXDISPLAY		; DISPLAY DIGIT ON 7 SEG
;	CALL    HEXSTR                  ; Change Number in 'A' to ASCII
;	LD	A,H
;       LD 	(PRINT_BUFFER),A       	; store ASCII to Print
;	LD	A,L
;       LD 	(PRINT_BUFFER1),A       ; store ASCII to Print
;	LD	DE,PRINT_BUFFER
;	LD	C,09H			; CP/M write string to console call
;	CALL	0005H
;	JR	Loop

;Exit:
;       LD	C,00H			; EXIT PROGRAM
;	CALL	0005H
;	RET




;__FP_Init________________________________________________________________________________________
;
;  FRONT PANEL INIT
;  Setup 8255, Mode 0, Port A=Out, Port B=In, Port C=Out/Out
;
;____________________________________________________________________________________________________
FP_Init:
        LDA     #$82
        STA     FPPIOCONT
        LDA     #$04
        STA     FPPORTC

        LDX     #$00            ; SET ADDRESS 9 TO 0, NO DECODE
        LDY     #$09            ; SET ADDRESS 9 TO 0, NO DECODE
        JSR     MAXOUT          ; SEND TO MAX7219
        LDX     #$0F            ; SET ADDRESS A TO 0F, FULL INTENSITY
        LDY     #$0A            ; SET ADDRESS A TO 0F, FULL INTENSITY
        JSR     MAXOUT          ; SEND TO MAX7219
        LDX     #$07            ; SET ADDRESS B TO 07, DISPLAY ALL DIGITS
        LDY     #$0B            ; SET ADDRESS B TO 07, DISPLAY ALL DIGITS
        JSR     MAXOUT          ; SEND TO MAX7219
        LDX     #$01            ; SET ADDRESS C TO 01, NO SHUTDOWN
        LDY     #$0C            ; SET ADDRESS C TO 01, NO SHUTDOWN
        JSR     MAXOUT          ; SEND TO MAX7219
        LDX     #$00            ; SET ADDRESS F TO 00, NO SELF-TEST
        LDY     #$0F            ; SET ADDRESS F TO 00, NO SELF-TEST
        JSR     MAXOUT          ; SEND TO MAX7219
        RTS


;__MAXOUT________________________________________________________________________________________
;
;  OUT TO MAX7219
;  CLOCK BYTE X TO ADDRESS Y
;
;____________________________________________________________________________________________________
MAXOUT:
        LDA     #$08
        STA     COUNTER
MAXOUT_1:
        TYA
        ROL     A
        BCS     MAXOUT_1A
        PHA
        LDA     #$00
        STA     FPPORTC
        JSR     PAUSE
        LDA     #$02
        STA     FPPORTC
        PLA
        JMP     MAXOUT_1B
MAXOUT_1A:
        PHA
        LDA     #$01
        STA     FPPORTC
        JSR     PAUSE
        LDA     #$03
        STA     FPPORTC
        PLA
MAXOUT_1B:
        TAY
        JSR     PAUSE
        LDA     #$00
        STA     FPPORTC
        DEC     COUNTER
        LDA     COUNTER
        CMP     #$00
        BNE     MAXOUT_1

        LDA     #$08
        STA     COUNTER
MAXOUT_2:
        TXA
        ROL     A
        BCS     MAXOUT_2A
        PHA
        LDA     #$00
        STA     FPPORTC
        JSR     PAUSE
        LDA     #$02
        STA     FPPORTC
        PLA
        JMP     MAXOUT_2B
MAXOUT_2A:
        PHA
        LDA     #$01
        STA     FPPORTC
        JSR     PAUSE
        LDA     #$03
        STA     FPPORTC
        PLA
MAXOUT_2B:
        TAX
        JSR     PAUSE
        LDA     #$00
        STA     FPPORTC
        DEC     COUNTER
        LDA     COUNTER
        CMP     #$00
        BNE     MAXOUT_2

        JSR     PAUSE
        LDA     #$04
        STA     FPPORTC
        RET



;__KB_Get____________________________________________________________________________________________
;
;  Get a Single Key and Decode
;
;____________________________________________________________________________________________________
;KB_Get:
;
;KB_Get_Loop:				; WAIT FOR KEY
;	CALL	KB_Scan			;  Scan KB Once
;	CP	00H			;  Null?
;	JR	Z,KB_Get_Loop		;  Loop while zero
;	LD      D,A			;  Store A
;	LD	A,0FH			;  Scan All Col Lines
;	OUT 	(FPPORTA),A		;  Send to Column Lines
;       CALL    KB_Scan_Delay		;  Delay to allow lines to stabilize
;KB_Clear_Loop:				; WAIT FOR KEY TO CLEAR
;	IN	A,(FPPORTB)		;  Get Rows
;	CP	00H 			;  Anything Pressed?
;	JR	NZ,KB_Clear_Loop	;  Yes, Exit.
;	LD	A,D			;  Restore A
;	LD	D,00H			;
;	LD	HL,KB_Decode		;  Point to beginning of Table
;KB_Get_LLoop:
;	CP	(HL)			;  Match?
;	JR	Z,KB_Get_Done		;  Found, Done
;	INC	HL
;	INC	D			;  D + 1
;	JP	NZ,KB_Get_LLoop		;  Not Found, Loop until EOT
;KB_Get_Done:
;	LD	A,D			;  Result Into A
;	RET



;__KB_Scan____________________________________________________________________________________________
;
;  SCan Keyboard Matrix for an input
;
;____________________________________________________________________________________________________
;KB_Scan:
;
;	LD      C,0000H
;	LD	A,01H			;  Scan Col One
;	OUT 	(FPPORTA),A		;  Send to Column Lines
;       CALL    KB_Scan_Delay		;  Delay to allow lines to stabilize
;	IN	A,(FPPORTB)		;  Get Rows
;	AND	1FH			;  Clear Top three Bits
;	JP	NZ,KB_Scan_Found	;  Yes, Exit.
;
;	LD      C,0020H
;	LD	A,02H			;  Scan Col Two
;	OUT 	(FPPORTA),A		;  Send to Column Lines
;       CALL    KB_Scan_Delay		;  Delay to allow lines to stabilize
;	IN	A,(FPPORTB)		;  Get Rows
;	AND	1FH			;  Clear Top three Bits
;	JP	NZ,KB_Scan_Found	;  Yes, Exit.
;
;	LD      C,0040H
;	LD	A,04H			;  Scan Col Three
;	OUT 	(FPPORTA),A		;  Send to Column Lines
;       CALL    KB_Scan_Delay		;  Delay to allow lines to stabilize
;	IN	A,(FPPORTB)		;  Get Rows
;	AND	1FH			;  Clear Top three Bits
;	JP	NZ,KB_Scan_Found	;  Yes, Exit.
;
;	LD      C,0080H			;
;	LD	A,08H			;  Scan Col Four
;	OUT 	(FPPORTA),A		;  Send to Column Lines
;       CALL    KB_Scan_Delay		;  Delay to allow lines to stabilize
;	IN	A,(FPPORTB)		;  Get Rows
;	AND	1FH			;  Clear Top three Bits
;	JP	NZ,KB_Scan_Found	;  Yes, Exit.
;
;	LD	A, 00H			;  Turn off All Columns
;	OUT 	(FPPORTA),A		;  Send to Column Lines
;	LD	A, 00H			;  RETURN NULL
;	RET				;  Exit

;KB_Scan_Found:
;	OR	C			;  Add in Row Bits
;	LD	C,A			;  Store Value
;	LD	A, 00H			;  Turn off All Columns
;	OUT 	(FPPORTA),A		;  Send to Column Lines
;	LD	A,C			;  Restore Value
;	RET

PAUSE:
KB_Scan_Delay:
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        RTS



;__HEXDISPLAY________________________________________________________________________________________
;
;  Display contents of DISPLAYBUF in decoded Hex bits 0-3 are displayed dig, bit 7 is DP
;
;____________________________________________________________________________________________________
;HEXDISPLAY:
;	PUSH	AF			; STORE AF
;	PUSH	BC			; STORE BC
;	PUSH    DE                      ; STORE DE
;	PUSH	HL			; STORE HL
;
;	CALL	DECODEDISPLAY		; DECODE DISPLAY
;	LD      HL,DISPLAYBUF
;	LD      (HL),A
;       CALL    SEGDISPLAY
;
;	POP     HL                      ; RESTORE HL
;	POP     DE                      ; RESTORE DE
;	POP	BC			; RESTORE BC
;	POP	AF			; RESTORE AF
;	RET

;__DECODEDISPLAY_____________________________________________________________________________________
;
;  Display contents of DISPLAYBUF in decoded Hex bits 0-3 are displayed dig, bit 7 is DP
;
;____________________________________________________________________________________________________
;DECODEDISPLAY:
;	PUSH	BC			; STORE BC
;	PUSH	HL			; STORE HL
;	LD	HL,SEGDECODE		; POINT HL TO DECODE TABLE
;	LD	B,00H			; RESET HIGH BYTE
;	LD	C,A			; CHAR INTO LOW BYTE
;	ADD	HL,BC			; SET TABLE POINTER
;	LD	A,(HL)			; GET VALUE
;	POP	HL			; RESTORE HL
;	POP	BC			; RESTORE BC
;	RET


;__SEGDISPLAY________________________________________________________________________________________
;
;  Display contents of DISPLAYBUF in RAW dig, bit 7 is DP
;
;____________________________________________________________________________________________________
SEGDISPLAY:
        LDA     #08             ; SET DIGIT COUNT
        STA     COUNTER1
        LDY     #$00
SEGDISPLAY_LP:
        LDA     (STRPTR),Y      ; LOAD NEXT CHAR FROM STRING INTO ACC
        TAX
        TYA
        STA     YREG
        LDA     COUNTER1
        TAY
        JSR     MAXOUT
        LDA     YREG
        TAY
        INY
        DEC     COUNTER1
        LDA     COUNTER1
        CMP     #$00
        BNE     SEGDISPLAY_LP
        RTS



;_KB Decode Table__________________________________________________________________________________________________________
;
;
KB_Decode:
;                0  1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
        .DB     81H,41H,42H,44H,21H,22H,24H,01H,02H,04H,48H,50H,28H,30H,08H,10H
;               CL  EN  .
        .DB     88H,90H,84H
;
; F-Keys,
; CL = Clear
; EN = Enter
; . = .
;_________________________________________________________________________________________________________________________

;_Text Strings____________________________________________________________________________________________________________
;
MSG:
        .DB     "Begin Front Panel Test Program"
        .DB     $0A, $0D,00     ; line feed and carriage return
        .DB     "$"             ; Line terminator

PRINT_BUFFER:
        .DB     00              ; Buffer for output
PRINT_BUFFER1:
        .DB     00
        .DB     "<- Scan Code"
        .DB     0Ah, 0Dh        ; line feed and carriage return
        .DB     "$"             ; line terminator



DISPLAYBUF:
        .DB     00,00,00,00,00,00,00,00
CPUUP:
        .DB     001H,04EH,067H,03EH,000H,03EH,067H,001H
SEGDECODE:
        .DB     07EH,030H,06DH,079H,033H,05BH,05FH,070H,07FH,073H,077H,01FH,04EH,03DH,04FH,047H,000H,080H
;_________________________________________________________________________________________________________________________


.end
