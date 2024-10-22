
;_________________________________________________________________________________________________________________________
;
;       SCREAM test for Duodyne 80c188 board
;
;       This should use no RAM and will output a stream of "A" on the onboard serial debug console
;       9600 N 8 1
;
;_________________________________________________________________________________________________________________________



        CPU     186




        SECTION scream  start=1F000h vstart=0F0F00h
        GLOBAL  cold_boot
        GLOBAL  initialization

        SEGMENT _TEXT

cold_boot:
; setup UART
        MOV     al,80h
        MOV     dx,uart_lcr
        OUT     dx,al
        MOV     al,12
        MOV     dx,uart_thr
        OUT     dx,al
        MOV     al,00
        MOV     dx,uart_ier
        OUT     dx,al
        MOV     al,03
        MOV     dx,uart_lcr
        OUT     dx,al
        MOV     dx,uart_mcr
        OUT     dx,al


loop:
        MOV     al,65
        MOV     dx,uart_thr
        OUT     dx,al
        JMP     loop


        %INCLUDE "startup.asm"
