;----------------------------------------------------------------------
; INT 21H, basic I/O functions
; AX REGISTER NOT SAVED
;----------------------------------------------------------------------
INT21:
        PUSH    DS              ; DS used for service 25h
        PUSH    ES
        PUSH    SI

        STI                     ; INT21 is reentrant!

;----------------------------------------------------------------------
; Interrupt 21h
; Service   01   get character from UART
; Input
; Output    AL   character read
; Changed   AX
;----------------------------------------------------------------------
ISR21_1:
        CMP     AH,01
        JNE     ISR21_2

        CALL    RXCHAR          ; Return result in AL
        JMP     ISR21_RET       ; return to caller

;----------------------------------------------------------------------
; Interrupt 21h
; Service   02   write character to UART
; Input     DL   character
; Output
; Changed   AX
;----------------------------------------------------------------------
ISR21_2:
        CMP     AH,02
        JNE     ISR21_8

        MOV     AL,DL
        CALL    TXCHAR

        JMP     ISR21_RET       ; return to caller

;----------------------------------------------------------------------
; Interrupt 21h
; Service   08   Console input without an echo
; Input
; Output
; Changed   AX
;----------------------------------------------------------------------
ISR21_8:
        CMP     AH,08
        JNE     ISR21_9

        CALL    RXCHAR          ; Return result in AL
        JMP     ISR21_RET       ; return to caller

;----------------------------------------------------------------------
; Interrupt 21h
; Service   09   write 0 terminated string to UART  (change to $ terminated ??)
; Input     DX     to string
; Output
; Changed   AX
;----------------------------------------------------------------------
ISR21_9:
        CMP     AH,09
        JNE     ISR21_25

        MOV     SI,DX
        CALL    PUTSD           ; Display string DS[SI]

        JMP     ISR21_RET       ; return to caller

;----------------------------------------------------------------------
; Interrupt 21h
; Service   25   Set Interrupt Vector
; Input     AL   Interrupt Number, DS:DX -> new interrupt handler
; Output
; Changed   AX
;----------------------------------------------------------------------
ISR21_25:
        CMP     AH,25h
        JNE     ISR21_0B

        CLI                     ; Disable Interrupts
        XOR     AH,AH
        MOV     SI,AX
        SHR     SI,1
        SHR     SI,1            ; Int number * 4

        XOR     AX,AX
        MOV     ES,AX           ; Int table segment=0000

        MOV     [ES:SI],DX      ; Set
        INC     SI
        INC     SI              ; SI POINT TO INT CS
        MOV     [ES:SI],DS      ; Set segment


        JMP     ISR21_RET       ; return to caller

;----------------------------------------------------------------------
; Interrupt 21h
; Service   48   Allocate memory
; Input
; Output
; Changed   AX
;----------------------------------------------------------------------
;ISR21_48:CMP       AH,48h
;        JNE    ISR21_4C
;        JMP    ISR21_RET                       ; return to caller


;----------------------------------------------------------------------
; Interrupt 21h
; Service   0Bh  Check for character waiting (kbhit)
; Input
; Output    AL   kbhit status !=0 if key pressed
; Changed   AL
;----------------------------------------------------------------------
ISR21_0B:
        CMP     AH,0Bh
        JNE     ISR21_2C

        XOR     AH,AH
        MOV     DX,uart_lsr     ; get UART RX status
        IN      AL,DX
        AND     AL,20h

        JMP     ISR21_RET

;----------------------------------------------------------------------
; Interrupt 21h
; Service   2Ch  Get System Time
;           CH = hour (BCD)
;           CL = minutes (BCD)
;           DH = seconds (BCD)
;           DL = 0
;----------------------------------------------------------------------
ISR21_2C:
        CMP     AH,02Ch
        JNE     ISR21_30

;            MOV        AH,02h
;            INT        1Ah
;            XOR        DL,DL                       ; Ignore 1/100 seconds value
        JMP     ISR21_RET

;----------------------------------------------------------------------
; Interrupt 21h
; Service   30h  Get DOS version, return 2
;----------------------------------------------------------------------
ISR21_30:
        CMP     AH,030h
        JNE     ISR21_4C

        MOV     AL,02           ; DOS=2.0

        JMP     ISR21_RET

;----------------------------------------------------------------------
; Interrupt 21h
; Service   4Ch  exit to bootloader
;----------------------------------------------------------------------
ISR21_4C:
        CMP     AH,04CH
        JNE     ISR21_x
        MOV     BL,AL           ; Save exit code

        MOV     AX,CS
        MOV     DS,AX
        MOV     SI,  TERM_MESS
        CALL    PUTS
        MOV     AL,BL
        CALL    PUTHEX2

        JMP     INITMON         ; Re-start MON88

;----------------------------------------------------------------------
; Interrupt 21h
; Service   xx   Unkown service, display message int and ah value, return to monitor
;----------------------------------------------------------------------
ISR21_x:
        MOV     AL,21h
        CALL    DISPSERI        ; Display Int and service number
        JMP     INITMON         ; Jump back to monitor

ISR21_RET:
        POP     SI
        POP     ES
        POP     DS
        IRET
