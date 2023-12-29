.P816
;__TESTBUS_________________________________________________________________________________________
;
;	TEST BUS RAM FOR THE THE RBC 65c816 SBC
;
;	WRITTEN BY: DAN WERNER -- 9/17/2017
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

UART0:          .EQU $8000      ;   DATA IN/OUT
UART1:          .EQU $8001      ;   CHECK RX
UART2:          .EQU $8002      ;   INTERRUPTS
UART3:          .EQU $8003      ;   LINE CONTROL
UART4:          .EQU $8004      ;   MODEM CONTROL
UART5:          .EQU $8005      ;   LINE STATUS
UART6:          .EQU $8006      ;   MODEM STATUS
UART7:          .EQU $8007      ;   SCRATCH REG.

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




        .ORG    5000H


        LDA     #MSG .AND $FF   ;
        STA     STRPTR          ;
        LDA     #MSG/256        ;
        STA     STRPTR+1        ;
        JSR     $C4A1           ; OUTPUT THE STRING

        CLC                     ; SET THE CPU TO NATIVE MODE
        XCE                     ;

        JSR     CRLF
; PRINT OUT 255 BYTES FROM VGA RAM
        LDX     #$00            ;
        LDY     #$00
LOOP1:
        LDA     $0B5000,X       ;
        JSR     PRINTHEX        ;
        JSR     SPACE
        CPY     #$0F
        BNE     LOOP1A
        LDY     #$00
        JSR     CRLF
LOOP1A:
        INY
        INX                     ;
        CPX     #$FF            ;
        BNE     LOOP1           ;


        JSR     CRLF
        JSR     CRLF

; SET VGARAM TO A KNOWN STATE
        LDX     #$00            ;
LOOP2:
        TXA
        STA     $0B5000,X       ;
        INX                     ;
        CPX     #$FF            ;
        BNE     LOOP2           ;


; PRINT OUT 255 BYTES FROM VGA RAM
; PRINT OUT 255 BYTES FROM VGA RAM
        LDX     #$00            ;
        LDY     #$00
LOOP3:
        LDA     $0B5000,X       ;
        JSR     PRINTHEX        ;
        JSR     SPACE
        CPY     #$0F
        BNE     LOOP3A
        LDY     #$00
        JSR     CRLF
LOOP3A:
        INY
        INX                     ;
        CPX     #$FF            ;
        BNE     LOOP3           ;


        JSR     CRLF
; PRINT OUT 255 BYTES FROM VGA RAM
        LDX     #$00            ;
        LDY     #$00
LOOP4:
        LDA     $0BA000,X       ;
        JSR     PRINTHEX        ;
        JSR     SPACE
        CPY     #$0F
        BNE     LOOP4A
        LDY     #$00
        JSR     CRLF
LOOP4A:
        INY
        INX                     ;
        CPX     #$FF            ;
        BNE     LOOP4           ;


        JSR     CRLF
        JSR     CRLF

; SET VGARAM TO A KNOWN STATE
        LDX     #$00            ;
LOOP5:
        TXA
        STA     $0BA000,X       ;
        INX                     ;
        CPX     #$FF            ;
        BNE     LOOP5           ;


; PRINT OUT 255 BYTES FROM VGA RAM
; PRINT OUT 255 BYTES FROM VGA RAM
        LDX     #$00            ;
        LDY     #$00
LOOP6:
        LDA     $0BA000,X       ;
        JSR     PRINTHEX        ;
        JSR     SPACE
        CPY     #$0F
        BNE     LOOP6A
        LDY     #$00
        JSR     CRLF
LOOP6A:
        INY
        INX                     ;
        CPX     #$FF            ;
        BNE     LOOP6           ;


        SEC                     ; RETURN TO EMULATION MODE
        XCE                     ;

        BRK


;__PRINTHEX____________________________________________________
;
; PRINT OUT ACCUMULATOR AS HEX NUMBER
;
;______________________________________________________________
PRINTHEX:
        PHX
        TAX                     ; SAVE A REGISTER
        LSR     A               ; SHIFT HIGH NIBBLE TO LOW NIBBLE
        LSR     A               ;
        LSR     A               ;
        LSR     A               ;
        CLC                     ; CLEAR CARRY
        JSR     PRINT_DIGIT     ; PRINT LOW NIBBLE
        TXA                     ; RESTORE ACCUMULATOR
        JSR     PRINT_DIGIT     ; PRINT LOW NIBBLE
        PLX
        RTS


;__PRINT_DIGIT_________________________________________________
;
; PRINT OUT LOW NIBBLE OF ACCUMULATOR IN HEX
;
;______________________________________________________________
PRINT_DIGIT:
        AND     #$0F            ; STRIP OFF HIGH NIBBLE
        ORA     #$30            ; ADD $30 TO PRODUCE ASCII
        CMP     #$3A            ; IS GREATER THAN 9
        BMI     PRINT_DIGIT_OUT ; NO, SKIP ADD
        CLC                     ; CLEAR CARRY
        ADC     #$07            ; ADD ON FOR LETTER VALUES
PRINT_DIGIT_OUT:                ;
        JMP     OUTCH           ; PRINT OUT CHAR


CRLF:
        LDA     #$0D
        JSR     OUTCH
        LDA     #$0A
        JMP     OUTCH

SPACE:
        LDA     #$20            ; OUTPUT SPACE


;__OUTCH_______________________________________________________
;
; OUTPUT CHAR IN ACC TO UART
;
;______________________________________________________________
OUTCH:
        PHA                     ; STORE ACC
TX_BUSYLP:
        LDA     UART5           ; READ LINE STATUS REGISTER
        AND     #$20            ; TEST IF UART IS READY TO SEND (BIT 5)
        CMP     #$00
        BEQ     TX_BUSYLP       ; IF NOT REPEAT
        PLA                     ; RESTORE ACC
        STA     UART0           ; THEN WRITE THE CHAR TO UART
        RTS                     ; DONE					;


;_Text Strings____________________________________________________________________________________________________________
;
MSG:
        .DB     "BUS RAM Test Program"
        .DB     $0A, $0D,00     ; line feed and carriage return

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
