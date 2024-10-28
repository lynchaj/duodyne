

;----------------------------------------------------------------------
;  INT 1AH, timer function
;  AX is not saved!
;        Addr    Function
;====    =========================================;
; 00     current second for real-time clock
; 02     current minute
; 04     current hour
; 07     current date of month
; 08     current month
; 09     current year  (final two digits; eg, 93)
; 0A     Status Register A - Read/Write except UIP
;----------------------------------------------------------------------
INT1A:
        PUSH    DS
        PUSH    BP
        MOV     BP,SP

;----------------------------------------------------------------------
; Interrupt 1AH, Time function
; Service   00   Get System Time in ticks
; Input
; Output    CX:DX ticks since midnight
;----------------------------------------------------------------------
ISR1A_00:
        XOR     DX,DX
        XOR     CX,CX
        JMP     ISR1A_RET       ; exit


;----------------------------------------------------------------------
; Interrupt 1AH, Time function
; Service   01   Set System Time from ticks
; Input     CX:DX ticks since midnight
; Output
;----------------------------------------------------------------------
ISR1A_01:
        XOR     DX,DX
        XOR     CX,CX
        JMP     ISR1A_RET       ; exit


;----------------------------------------------------------------------
; Interrupt 1AH, Time function
; Service   02   Get RTC time
;   exit :  CF clear if successful, set on error ***NOT YET ADDED***
;           CH = hour (BCD)
;           CL = minutes (BCD)
;           DH = seconds (BCD)
;           DL = daylight savings flag  (!! NOT IMPLEMENTED !!)
;                (00h standard time, 01h daylight time)
;----------------------------------------------------------------------
ISR1A_02:
        XOR     DX,DX
        XOR     CX,CX
        JMP     ISR1A_RET       ; exit

;----------------------------------------------------------------------
; Int 1Ah function 03h - Set RTC time
;   entry:  AH = 03h
;           CH = hour (BCD)
;           CL = minutes (BCD)
;           DH = seconds (BCD)
;           DL = daylight savings flag (as above)
;   exit:   none
;----------------------------------------------------------------------
ISR1A_03:

        JMP     ISR1A_RET

;----------------------------------------------------------------------
; Int 1Ah function 04h - Get RTC date
;   entry:  AH = 04h
;   exit:   CF clear if successful, set on error
;           CH = century (BCD)
;           CL = year (BCD)
;           DH = month (BCD)
;           DL = day (BCD)
;----------------------------------------------------------------------
ISR1A_04:
        XOR     DX,DX
        XOR     CX,CX
        JMP     ISR1A_RET

;----------------------------------------------------------------------
; Int 1Ah function 05h - Set RTC date
;   entry:  AH = 05h
;           CH = century (BCD)
;           CL = year (BCD)
;           DH = month (BCD)
;           DL = day (BCD)
;   exit:   none
;----------------------------------------------------------------------
ISR1A_05:
        JMP     ISR1A_RET

;----------------------------------------------------------------------
; Interrupt 1Ah
; Service   xx   Unknown service, print message, jump to monitor
;----------------------------------------------------------------------
ISR1A_X:
        MOV     AL,1Ah
        CALL    DISPSERI        ; Display Int and service number
        JMP     INITMON         ; Jump back to monitor

ISR1A_RET:
        AND     WORD [SS:BP+8],0FFFEh; Clear Carry to indicate no error
        POP     BP
        POP     DS
        IRET
