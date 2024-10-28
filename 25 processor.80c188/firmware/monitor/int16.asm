;----------------------------------------------------------------------
; Interrupt 16H, I/O function
; Service   00   Wait for keystroke
; Input
; Output    AL   Character, AH=ScanCode=0
; Changed   AX
;----------------------------------------------------------------------
INT16:
        PUSH    DX
        PUSH    BP
        MOV     BP,SP

ISR16_00:
        CMP     AH,00h
        JNE     ISR16_01

        CALL    RXCHAR
        XOR     AH,AH

        JMP     ISR16_RET

;----------------------------------------------------------------------
; Interrupt 16H, I/O function
; Service   01   Check for keystroke (kbhit)
; Input
; Output    AL   Character, AH=ScanCode=0 ZF=0 when keystoke available
; Changed   AX
;----------------------------------------------------------------------
ISR16_01:
        CMP     AH,01h
        JNE     ISR16_X

        XOR     AH,AH           ; Clear ScanCode
        OR      WORD [SS:BP+8],0040h; SET ZF in stack stored flag

        MOV     DX,uart_lsr
        IN      AL,DX           ; Get Status
        AND     AL,01h
        JZ      ISR16_RET       ; No keystoke

        MOV     DX,uart_rbr
        IN      AL,DX           ; return result in al
        AND     WORD [SS:BP+8],0FFBFh; Clear ZF in stack stored flag

        JMP     ISR16_RET

;----------------------------------------------------------------------
; Service Unkown service, display message int and ah value, return to monitor
;----------------------------------------------------------------------
ISR16_X:
        MOV     AL,16h
        CALL    DISPSERI        ; Display Int and service number
        JMP     INITMON         ; Jump back to monitor

ISR16_RET:
        POP     BP
        POP     DX
        IRET
