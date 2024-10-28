
;----------------------------------------------------------------------
; Interrupt 10H, video function
; Service   0E   Teletype Output
; Input     AL   Character, BL and BH are ignored
; Output
; Changed
;----------------------------------------------------------------------
INT10:
        CMP     AH,0Eh
        JNE     ISR10_X

        CALL    TXCHAR          ; Transmit character
        JMP     ISR10_RET

;----------------------------------------------------------------------
; Service Unkown service, display message int and ah value, return to monitor
;----------------------------------------------------------------------
ISR10_X:
        MOV     AL,10h
        CALL    DISPSERI        ; Display Int and service number
        JMP     INITMON         ; Jump back to monitor

ISR10_RET:
        IRET
