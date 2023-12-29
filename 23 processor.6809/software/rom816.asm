.P816
;__ROM816__________________________________________________________________________________________
;
;	ROM MONITOR FOR THE RBC 65c816N SBC
;
;	WRITTEN BY: DAN WERNER -- 9/8/2017
;
;__________________________________________________________________________________________________
;
; DATA CONSTANTS
;__________________________________________________________________________________________________

;        CHIP    65816           ; SET CHIP
;        LONGA   OFF             ; ASSUME EMULATION MODE
;        LONGI   OFF             ;
;        PW      128
;        PL      60
;        INCLIST ON

        .SEGMENT "ROM"

IO_AREA         = $DF00
;__________________________________________________________________________________________________
; $8000-$8007 UART 16C550
;__________________________________________________________________________________________________
UART0           = IO_AREA+$58   ;   DATA IN/OUT
UART1           = IO_AREA+$59   ;   CHECK RX
UART2           = IO_AREA+$5A   ;   INTERRUPTS
UART3           = IO_AREA+$5B   ;   LINE CONTROL
UART4           = IO_AREA+$5C   ;   MODEM CONTROL
UART5           = IO_AREA+$5D   ;   LINE STATUS
UART6           = IO_AREA+$5E   ;   MODEM STATUS
UART7           = IO_AREA+$5F   ;   SCRATCH REG.

OPTIONREGISTER  = IO_AREA+$51   ;   OPTION REG.

STACK           = $7FFF         ;   POINTER TO TOP OF STACK
;
KEYBUFF         = $0200         ; 256 BYTE KEYBOARD BUFFER
; NATIVE VECTORS
ICOPVECTOR      = $0300         ;COP handler indirect vector...
IBRKVECTOR      = $0302         ;BRK handler indirect vector...
IABTVECTOR      = $0304         ;ABT handler indirect vector...
INMIVECTOR      = $0306         ;NMI handler indirect vector...
IIRQVECTOR      = $0308         ;IRQ handler indirect vector...
; 6502 Emulation Vectors
IECOPVECTOR     = $030A         ;ECOP handler indirect vector...
IEABTVECTOR     = $030C         ;EABT handler indirect vector...
IENMIVECTOR     = $030E         ;ENMI handler indirect vector...
IEINTVECTOR     = $0310         ;EINT handler indirect vector...
ConsoleDevice   = $0341         ; Current Console Device
; $00 On-Board Serial

TRUE            = 1
FALSE           = 0

        .INCLUDE "MACROS.ASM"

        .ORG    $E000
;__COLD_START___________________________________________________
;
; PERFORM SYSTEM COLD INIT
;
;_______________________________________________________________
COLD_START:
        CLD                     ; VERIFY DECIMAL MODE IS OFF
        LDA     #$00            ; ensure interrupts are off
        STA     OPTIONREGISTER
        CLC                     ;
        XCE                     ; SET NATIVE MODE
        ACCUMULATORINDEX16
        LDA     #STACK          ; get the stack address
        TCS                     ; and set the stack to it
        ACCUMULATORINDEX8

        JSR     CONSOLE_INIT    ; Init UART

; Announce that system is alive

        JSR     BATEST          ; Perform Basic Assurance Test

        ACCUMULATOR16
        LDA     #INTRETURN      ;
        STA     ICOPVECTOR
        STA     IBRKVECTOR
        STA     IABTVECTOR
        STA     INMIVECTOR
        STA     IIRQVECTOR
        STA     IECOPVECTOR
        STA     IEABTVECTOR
        STA     IENMIVECTOR
        STA     IEINTVECTOR

        ACCUMULATORINDEX8
        JMP     mon

RCOPVECTOR:
        JMP     (ICOPVECTOR)
RBRKVECTOR:
        JMP     (IBRKVECTOR)
RABTVECTOR:
        JMP     (IABTVECTOR)
RNMIVECTOR:
        JMP     (INMIVECTOR)
RIRQVECTOR:
        JMP     (IIRQVECTOR)
RECOPVECTOR:
        JMP     (IECOPVECTOR)
REABTVECTOR:
        JMP     (IEABTVECTOR)
RENMIVECTOR:
        JMP     (IENMIVECTOR)
REINTVECTOR:
        JMP     (IEINTVECTOR)


;__INTRETURN____________________________________________________
;
; Handle Interrupts
;
;_______________________________________________________________
;
INTRETURN:
        SEI
        RTI                     ;

;__BATEST_______________________________________________________
;
; Perform Basic Hardware Assurance Test
;
;_______________________________________________________________
;
BATEST:
        RTS



;__CONSOLE_INIT_________________________________________________
;
; Initialize Attached Console Devices
;
;_______________________________________________________________
;
CONSOLE_INIT:
        PHP
        ACCUMULATORINDEX8
        JSR     SERIAL_CONSOLE_INIT
        LDA     #$00
        STA     ConsoleDevice
        PLP
        RTS

;__OUTCH_______________________________________________________
;
; OUTPUT CHAR IN LOW BYTE OF ACC TO CONSOLE
;
; Current Console Device stored in ConsoleDevice
;
; 0=Serial
; 1=On Board 9918/KB
;______________________________________________________________
OUTCH:
        PHX
        PHY
        PHP
        ACCUMULATORINDEX8
        TAX
; LDA     ConsoleDevice
; CMP     #$01
; BNE     OUTCH2
; TXA
; JSR     Outch9918
; PLP
; PLY
; PLX
; RTS

; Default (serial)
OUTCH2:
        TXA
        JSR     SERIAL_OUTCH
        PLP
        PLY
        PLX
        RTS


;__INCHW_______________________________________________________
;
; INPUT CHAR FROM CONSOLE TO ACC  (WAIT FOR CHAR)
;
;______________________________________________________________
INCHW:
        PHX
        PHY
        PHP
        ACCUMULATORINDEX8

;        LDA     ConsoleDevice
;       CMP     #$01
; jmp     INCHW2
; PLP
; PLY
; PLX
; RTS

; Default (serial)
INCHW2:
        JSR     SERIAL_INCHW
        PLP
        PLY
        PLX
        RTS


;__INCH________________________________________________________
;
; INPUT CHAR FROM CONSOLE TO ACC
;
;______________________________________________________________
INCH:
        PHX
        PHY
        PHP
        ACCUMULATORINDEX8

; LDA     ConsoleDevice
; CMP     #$01
; BNE     INCH2

; JSR     ScanKeyboard
; CMP     #$FF
; BEQ     INCH2S
; JSR     GetKey
; BRA     INCH2C

; Default (serial)
INCH2:
        JSR     SERIAL_INCH
        BCS     INCH2S


INCH2C:
        PLP
        PLY
        PLX
        CLC
        RTS
INCH2S:
        PLP
        PLY
        PLX
        SEC
        RTS


        .A16
        .I16
;
;__SERIAL_CONSOLE_INIT___________________________________________
;
;	INITIALIZE UART
;	PARAMS:	SER_BAUD NEEDS TO BE SET TO BAUD RATE
;	1200:	96	 = 1,843,200 / ( 16 X 1200 )
;	2400:	48	 = 1,843,200 / ( 16 X 2400 )
;	4800:	24	 = 1,843,200 / ( 16 X 4800 )
;	9600:	12	 = 1,843,200 / ( 16 X 9600 )
;	19K2:	06	 = 1,843,200 / ( 16 X 19,200 )
;	38K4:	03
;	57K6:	02
;	115K2:	01
;
;_______________________________________________________________
;
SERIAL_CONSOLE_INIT:
        PHP
        SEP     #$30            ; 8 bit registers (A AND I)
        .A8
        .I8
        LDA     #$80            ;
        STA     UART3           ; SET DLAB FLAG
        LDA     #12             ; SET TO 12 = 9600 BAUD
        STA     UART0           ; save baud rate
        LDA     #00             ;
        STA     UART1           ;
        LDA     #03             ;
        STA     UART3           ; SET 8 BIT DATA, 1 STOPBIT
        STA     UART4           ;
        PLP
        RTS


        .A16
        .I16
;__OUTCH_______________________________________________________
;
; OUTPUT CHAR IN LOW BYTE OF ACC TO UART
;
;______________________________________________________________
SERIAL_OUTCH:
        PHP
        SEP     #$20            ; NEED 8 bit accum for this
        .A8
        PHA                     ; STORE ACC
TX_BUSYLP:
        LDA     UART5           ; READ LINE STATUS REGISTER
        AND     #$20            ; TEST IF UART IS READY TO SEND (BIT 5)
        CMP     #$00
        BEQ     TX_BUSYLP       ; IF NOT REPEAT
        PLA                     ; RESTORE ACC
        STA     UART0           ; THEN WRITE THE CHAR TO UART

        PLP                     ; RESTORE CPU CONTEXT
        RTS                     ; DONE


        .A16
        .I16
;__INCHW_______________________________________________________
;
; INPUT CHAR FROM UART TO ACC  (WAIT FOR CHAR)
;
;______________________________________________________________
SERIAL_INCHW:
        PHP
        SEP     #$20            ; NEED 8 bit accum for this
        .A8

SERIAL_INCHW1:
        LDA     UART5           ; READ LINE STATUS REGISTER
        AND     #$01            ; TEST IF DATA IN RECEIVE BUFFER
        CMP     #$00
        BEQ     SERIAL_INCHW1   ; LOOP UNTIL DATA IS READY
        LDA     UART0           ; THEN READ THE CHAR FROM THE UART

        PLP                     ; RESTORE CPU CONTEXT
        RTS


        .A16
        .I16
;__INCH_______________________________________________________
;
; INPUT CHAR FROM UART TO ACC (DO NOT WAIT FOR CHAR)
; CArry set if invalid character
;______________________________________________________________
SERIAL_INCH:
        PHP
        SEP     #$20            ; NEED 8 bit accum for this
        .A8
        LDA     UART5           ; READ LINE STATUS REGISTER
        AND     #$01            ; TEST IF DATA IN RECEIVE BUFFER
        BEQ     SERIAL_INCH1    ; NO CHAR FOUND
        LDA     UART0           ; THEN READ THE CHAR FROM THE UART
        PLP                     ; RESTORE CPU CONTEXT
        CLC
        RTS
SERIAL_INCH1:
        PLP                     ; RESTORE CPU CONTEXT
        SEC
        RTS


nothere:
        RTS

        .INCLUDE "SUPERMON816.ASM"

        .SEGMENT "NJUMP"
; BIOS JUMP TABLE (NATIVE)
        .ORG    $FD00
LPRINTVEC:
        JSR     OUTCH
        RTL
LINPVEC:
        JSR     INCH
        RTL
LINPWVEC:
        JSR     INCHW
        RTL
        .SEGMENT "EJUMP"
; BIOS JUMP TABLE (Emulation)
        .ORG    $FF71
PRINTVEC:
        JMP     OUTCH
INPVEC:
        JMP     INCH
INPWVEC:
        JMP     INCHW

        .SEGMENT "VECTORS"
; 65c816 Native Vectors
        .ORG    $FFE4
COPVECTOR:
        .WORD   RCOPVECTOR
BRKVECTOR:
        .WORD   RBRKVECTOR
ABTVECTOR:
        .WORD   RABTVECTOR
NMIVECTOR:
        .WORD   RNMIVECTOR
resv1:
        .WORD   $0000           ;
IRQVECTOR:
        .WORD   RIRQVECTOR      ; ROM VECTOR FOR IRQ

        .WORD   $0000           ;
        .WORD   $0000           ;

; 6502 Emulation Vectors
        .ORG    $FFF4
ECOPVECTOR:
        .WORD   RECOPVECTOR
resv2:
        .WORD   $0000
EABTVECTOR:
        .WORD   REABTVECTOR
ENMIVECTOR:
        .WORD   RENMIVECTOR
RSTVECTOR:
        .WORD   COLD_START      ;
EINTVECTOR:
        .WORD   REINTVECTOR     ; ROM VECTOR FOR IRQ

        .END
