.P816
;__SCRM816_________________________________________________________________________________________
;
;	SCREAM FOR THE RBC 65c816N SBC
;
;	WRITTEN BY: DAN WERNER -- 9/14/2017
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


IRQVECTADD      = $30           ; VECTOR FOR USER IRQ RTN
WORKPTR         = $32           ; WORK POINTER FOR COMMAND PROCESSOR
JUMPPTR         = $34           ; JUMP VECTOR FOR LOOKUP TABLE
TEMPWORD        = $36           ;
TEMPWORD1       = $38           ;
TEMPWORD2       = $3A           ;
TEMPBYTE        = $3B           ;
ACC             = $3D           ; ACC STORAGE
XREG            = $3E           ; X REG STORAGE
YREG            = $3F           ; Y REG STORAGE
PREG            = $40           ; CURRENT STACK POINTER
PCL             = $41           ; PROGRAM COUNTER LOW
PCH             = $42           ; PROGRAM COUNTER HIGH
SPTR            = $43           ; CPU STATUS REGISTER
CKSM            = $44           ; CHECKSUM
BYTECT          = $45           ; BYTE COUNT
STRPTR          = $48           ;
COUNTER         = $4A           ;
SRC             = $4C           ;
DEST            = $4E           ;
INBUFFER        = $0200         ;


        .SEGMENT "ROM"
        .ORG    $E000

;__COLD_START___________________________________________________
;
; PERFORM SYSTEM COLD INIT
;
;_______________________________________________________________
COLD_START:
        SEI                     ;  Disable Interrupts
        CLD                     ;  VERIFY DECIMAL MODE IS OFF

        LDA     #$80            ;
        STA     UART3           ; SET DLAB FLAG
        LDA     #12             ; SET TO 12 = 9600 BAUD
        STA     UART0           ;
        LDA     #00             ;
        STA     UART1           ;
        LDA     #03             ;
        STA     UART3           ; SET 8 BIT DATA, 1 STOPBIT
        STA     UART4           ; SET 8 BIT DATA, 1 STOPBIT


        LDX     #$00
TX:
        LDA     UART5           ; READ LINE STATUS REGISTER
        AND     #$20            ; TEST IF UART IS READY TO SEND (BIT 5)
        CMP     #$00
        BEQ     TX              ; IF NOT REPEAT

;   LDA     #'A'
        TXA
        STA     $0100
        LDA     $0100
        STA     UART0           ; THEN WRITE THE CHAR TO UART
        INX
        JMP     TX

        BRK                     ; PERFORM BRK (START MONITOR)


        .SEGMENT "VECTORS"
; 65c816 Native Vectors
        .ORG    $FFE4
COPVECTOR:
        .WORD   COLD_START
BRKVECTOR:
        .WORD   COLD_START
ABTVECTOR:
        .WORD   COLD_START
NMIVECTOR:
        .WORD   COLD_START
resv1:
        .WORD   COLD_START
IRQVECTOR:
        .WORD   COLD_START


        .WORD   $0000,$0000


; 6502 Emulation Vectors
        .ORG    $FFF4
ECOPVECTOR:
        .WORD   COLD_START
resv2:
        .WORD   COLD_START
EABTVECTOR:
        .WORD   COLD_START
ENMIVECTOR:
        .WORD   COLD_START
RSTVECTOR:
        .WORD   COLD_START      ;
EINTVECTOR:
        .WORD   COLD_START

        .END
