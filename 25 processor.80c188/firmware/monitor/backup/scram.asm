
;_________________________________________________________________________________________________________________________
;
;       SCREAM test for Duodyne 80c188 board
;
;       This should use no RAM and will output a stream of "A" on the onboard serial debug console
;       9600 N 8 1
;
;_________________________________________________________________________________________________________________________



        CPU     186

temp            equ     02000h

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

        mov	byte [ds:temp],65


loop:

        MOV     al,01h                  ; light first LED on RAM Card
        MOV     dx,RAMROM_card_1
        OUT     dx,al

        MOV     al,0AAh                 ; Put LED Pattern on Front Panel
        MOV     dx,front_panel_LEDs
        OUT     dx,al

        MOV     al,00h                  ; Turn on First LED on CPU Card
        MOV     dx,local_ls259_LED1
        OUT     dx,al
        MOV     al,01h                  ; Turn off Second LED on CPU Card
        MOV     dx,local_ls259_LED2
        OUT     dx,al
        MOV     al,00h                  ; Turn on Third LED on CPU Card
        MOV     dx,local_ls259_LED3
        OUT     dx,al
        MOV     al,01h                  ; Turn off Fourth LED on CPU Card
        MOV     dx,local_ls259_LED4
        OUT     dx,al

.3:
        MOV     dx,uart_lsr             ; READ LINE STATUS REGISTER
        IN      AL,DX
        AND     AL,20h                  ; And status with user BH mask
        JZ      .3

        MOV     al,65
        MOV     dx,uart_thr
        OUT     dx,al

.1:
        MOV     dx,uart_lsr             ; READ LINE STATUS REGISTER
        IN      AL,DX
        AND     AL,20h                  ; And status with user BH mask
        JZ      .1

        MOV     al,[ds:temp]
        MOV     dx,uart_thr
        OUT     dx,al

        inc     byte [ds:temp]

        MOV     AL,[ds:temp]
        CMP     AL,127
        JNZ      .2
        mov	byte [ds:temp],32
.2:
        JMP     loop


        %INCLUDE "startup.asm"
