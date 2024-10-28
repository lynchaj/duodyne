; ROM startup code Duodyne 80C188
; This is based on the STARTUP.ASM for the N8VEM SBC-188, which is under GPL 3.
        [LIST   -]
        %INCLUDE "ioports.inc"
        [LIST   +]

        SECTION startup start=1FF00h vstart=0FFF00h

begin:
        CLI
        CLD
        MOV     dh, ip_base >> 8
        MOV     si, table       ; Point to the table
        MOV     ax, cs
        MOV     ds, ax
        MOV     cx, tablecnt

.1:
        LODSB                   ; Initialise registers from table
        MOV     dl, al
        LODSW
        OUT     dx, ax
        LOOP    .1

        MOV     ax, 9100h       ; Stack at top of RAM
        MOV     ss, ax
        MOV     sp, 7000h
        MOV     ax, 9100h       ; Set DS
        MOV     ds, ax
        MOV     ax, 0F000h      ; Set CS=ES
        MOV     es, ax

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

        MOV     al,01h          ; light first LED on RAM Card
        MOV     dx,RAMROM_card_1
        OUT     dx,al

        MOV     al,00h          ; Put LED Pattern on Front Panel
        MOV     dx,front_panel_LEDs
        OUT     dx,al

        MOV     al,00h          ; Turn on First LED on CPU Card
        MOV     dx,local_ls259_LED1
        OUT     dx,al
        MOV     al,01h          ; Turn off Second LED on CPU Card
        MOV     dx,local_ls259_LED2
        OUT     dx,al
        MOV     al,00h          ; Turn on Third LED on CPU Card
        MOV     dx,local_ls259_LED3
        OUT     dx,al
        MOV     al,01h          ; Turn off Fourth LED on CPU Card
        MOV     dx,local_ls259_LED4
        OUT     dx,al

        JMP     0F000h:INITMON  ; Continue to body of ROM

table:
        DB_LO   ics_umcs        ; ROM
        DW      0E03Ch          ; 128KB, no wait states, no external ready
        DB_LO   ics_mmcs        ; RAM
        DW      01FCh           ; 00000h, no wait states, no external ready
        DB_LO   ics_mpcs        ; /MCSx size, /PCSx configuration
        DW      0C0BCh          ; 512KB, 7 /PCSx, I/O space, no wait states, no external ready
        DB_LO   ics_pacs        ; External peripherals
        DW      0FBEh           ; F800h, no wait states, no external ready (0FBCh=0 WS)
tablecnt        EQU ($-table)/3

        SETLOC  0F0h            ; Reset entry is FFFF:0000h
        JMP     0F000h:begin    ; Jump to the startup code above
        DB      "09/29/24", 00h ; BIOS date (mm/dd/yy)
        DB      0FBh, 0FFh      ; Model identifier (FBh is a 1986 XT)
