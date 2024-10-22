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

.1
        LODSB                   ; Initialise registers from table
        MOV     dl, al
        LODSW
        OUT     dx, ax
        LOOP    .1

        MOV     ax, 7000h       ; Stack at top of RAM
        MOV     ss, ax
        MOV     sp, 0000h
        MOV     ax, 0F000h      ; Set CS=DS=ES
        MOV     ds, ax
        MOV     es, ax
        JMP     0F000h:cold_boot; Continue to body of ROM

table
        DB_LO   ics_umcs        ; ROM
        DW      0E03Ch          ; 128KB, no wait states, no external ready
        DB_LO   ics_mmcs        ; RAM
        DW      01FCh           ; 00000h, no wait states, no external ready
        DB_LO   ics_mpcs        ; /MCSx size, /PCSx configuration
        DW      0C0BCh          ; 512KB, 7 /PCSx, I/O space, no wait states, no external ready
        DB_LO   ics_pacs        ; External peripherals
        DW      0FBCh           ; F800h, no wait states, no external ready
tablecnt        EQU ($-table)/3

        SETLOC  0F0h            ; Reset entry is FFFF:0000h
        JMP     0F000h:begin    ; Jump to the startup code above
        DB      "09/29/24", 00h ; BIOS date (mm/dd/yy)
        DB      0FBh, 0FFh      ; Model identifier (FBh is a 1986 XT)
