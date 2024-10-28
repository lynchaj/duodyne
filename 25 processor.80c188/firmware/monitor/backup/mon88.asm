;**********************************************************************
;
; MON88 (c) HT-LAB
;
; - Simple Monitor for 8088/86
; - Some bios calls
; converted to NASM syntax and adapted for Duodyne 80c188 by D.Werner 10/2024
;
;----------------------------------------------------------------------
;
; Copyright (C) 2005 Hans Tiggeler - http://www.ht-lab.com
; Send comments and bugs to : cpu86@ht-lab.com
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
; General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software Foundation,
; Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;----------------------------------------------------------------------
;
; Ver 0.1     30 July 2005  H.Tiggeler  WWW.HT-LAB.COM
;**********************************************************************
        %DEFINE DEBUG   1

        CPU     186

        SECTION monitor  start=1F000h vstart=0F0000h
        GLOBAL  cold_boot
        GLOBAL  INITMON

        SEGMENT _TEXT

TOS             EQU 0A000h      ; Top of stack

LF              EQU 0Ah
CR              EQU 0Dh
ESC             EQU 01Bh

;----------------------------------------------------------------------
; Used for Load Hex file command
;----------------------------------------------------------------------
EOF_REC         EQU 01          ; End of file record
DATA_REC        EQU 00          ; Load data record
EAD_REC         EQU 02          ; Extended Address Record, use to set CS
SSA_REC         EQU 03          ; Execute Address


;------------------------------------------------------------------------------------
; Default Base Segment Pointer
; All MON88 commands operate on the BASE_SEGMENT:xxxx address.
; The base_segment value can be changed by the BS command
;------------------------------------------------------------------------------------
BASE_SEGMENT    EQU 0050h

;----------------------------------------------------------------------
; Working Storage values
;----------------------------------------------------------------------
; Interrupt Vectors 0000h-03ffh
;
;----------------------------------------------------------------------
; Save Register values
;----------------------------------------------------------------------
UAX             EQU 0400h
UBX             EQU 0402h
UCX             EQU 0404h
UDX             EQU 0406h
USP             EQU 0408h
UBP             EQU 040ah
USI             EQU 040ch
UDI             EQU 040eh
UDS             EQU 0410h
UES             EQU 0412h
USS             EQU 0414h
UCS             EQU 0416h
UIP             EQU 0418h
UFL             EQU 041ah
;----------------------------------------------------------------------
; memory dump working storage
;----------------------------------------------------------------------
DUMPMEMS        EQU 041ch



        %IMACRO WRSPACE  0      ; Write space character
        MOV     AL,' '
        CALL    TXCHAR
        %ENDM

        %IMACRO WREQUAL  0      ; Write = character
        MOV     AL,'='
        CALL    TXCHAR
        %ENDM


INITMON:

        %IFDEF  DEBUG
            MOV     al,01h          ; Put POST Pattern on Front Panel
            MOV     dx,front_panel_LEDs
            OUT     dx,al
        %ENDIF

        MOV     AX,TOS          ; Top of Stack
        MOV     SP,AX           ; Set Stack pointer

;----------------------------------------------------------------------
; Install Interrupt Vectors
; INT1 & INT3 used for single stepping and breakpoints
; INT# * 4     =
; INT# * 4 + 2 = Segment
;----------------------------------------------------------------------

        XOR     AX,AX           ; Segment=0000
        MOV     ES,AX

; Point all vectors to unknown handler!
        XOR     BX,BX           ; 256 vectors * 4 bytes
NEXTINTS:
        MOV     WORD [ES:BX],   INTX; Spurious Interrupt Handler
        MOV     WORD [ES:BX+2], 0F000h; interrupts in segment 0F0000h (for now)
        ADD     BX,4
        CMP     BX,0400h
        JNE     NEXTINTS

        MOV     WORD [ES:04],   INT1_3; INT1 Single Step handler
        MOV     WORD [ES:12],   INT1_3; INT3 Breakpoint handler
        MOV     WORD [ES:64],   INT10; INT10h
        MOV     WORD [ES:88],   INT16; INT16h
        MOV     WORD [ES:104],  INT1A; INT1A, Timer functions
        MOV     WORD [ES:132],  INT21; INT21h

        %IFDEF  DEBUG
            MOV     al,02h          ; Put POST Pattern on Front Panel
            MOV     dx,front_panel_LEDs
            OUT     dx,al
        %ENDIF

        MOV     ax, 0000h       ; Set DS
        MOV     DS,AX           ;
;----------------------------------------------------------------------
; Entry point, Display welcome message
;----------------------------------------------------------------------
START:
        CLD
        MOV     SI,  WELCOME_MESS;   -> SI
        CALL    PUTS            ; String pointed to by CS:[SI]

        %IFDEF  DEBUG
            MOV     al,04h          ; Put POST Pattern on Front Panel
            MOV     dx,front_panel_LEDs
            OUT     dx,al
        %ENDIF

        MOV     AX,BASE_SEGMENT ; Get Default Base segment
        MOV     ES,AX

;----------------------------------------------------------------------
; Process commands
;----------------------------------------------------------------------
CMD:
        MOV     SI,  PROMPT_MESS; Display prompt >
        CALL    PUTS

        CALL    RXCHAR          ; Get Command First Byte
        CALL    TO_UPPER
        MOV     DH,AL

        MOV     BX,  CMDTAB1    ; Single Command?
CMPCMD1:
        MOV     AL,[CS:BX]
        CMP     AL,DH
        JNE     NEXTCMD1
        WRSPACE
        JMP     [CS:BX+2]       ; Execute Command

NEXTCMD1:
        ADD     BX,4
        CMP     BX,  ENDTAB1
        JNE     CMPCMD1         ; Continue looking

        CALL    RXCHAR          ; Get Second Command Byte, DX=command
        CALL    TO_UPPER
        MOV     DL,AL

        MOV     BX,  CMDTAB2
CMPCMD2:
        MOV     AX,[CS:BX]
        CMP     AX,DX
        JNE     NEXTCMD2
        WRSPACE
        JMP     [CS:BX+2]       ; Execute Command

NEXTCMD2:
        ADD     BX,4
        CMP     BX,  ENDTAB2
        JNE     CMPCMD2         ; Continue looking

        MOV     SI,  ERRCMD_MESS; Display Unknown Command, followed by usage message
        CALL    PUTS
        JMP     CMD             ; Try again

CMDTAB1:
        DW      'L',LOADHEX     ; Single char Command Jump Table
        DW      'R',DISPREG
        DW      'G',EXECPROG
        DW      'H',DISPHELP
        DW      '?',DISPHELP
        DW      'F',FILLMEM     ; Double char Command Jump Table
        DW      'D',DUMPMEM
        DW      'C',CHANGEREG   ; Change Register
        DW      'B',CHANGEBS    ; Change Base Segment Address
        DW      CR ,CMD
ENDTAB1:
        DW      ' '

; note bytes are reversed . . . . .
CMDTAB2:
        DW      'BO',OUTPORTB
        DW      'WO',OUTPORTW
        DW      'BI',INPORTB
        DW      'WI',INPORTW
        DW      'BW',WRMEMB     ; Write Byte to Memory
        DW      'WW',WRMEMW     ; Write Word to Memory
ENDTAB2:
        DW      '??'


;----------------------------------------------------------------------
; Write Byte to Memory
;----------------------------------------------------------------------
WRMEMB:
        CALL    GETHEX4         ; Get Address
        MOV     BX,AX           ; Store Address
        WRSPACE

        MOV     AL,[ES:BX]      ; Get current value and display it
        CALL    PUTHEX2
        WREQUAL
        CALL    GETHEX2         ; Get new value
        MOV     [ES:BX],AL      ; and write it

        JMP     CMD             ; Next Command

;----------------------------------------------------------------------
; Write Word to Memory
;----------------------------------------------------------------------
WRMEMW:
        CALL    GETHEX4         ; Get Address
        MOV     BX,AX
        WRSPACE

        MOV     AX,[ES:BX]      ; Get current value and display it
        CALL    PUTHEX4
        WREQUAL
        CALL    GETHEX4         ; Get new value
        MOV     [ES:BX],AX      ; and write it

        JMP     CMD             ; Next Command

;----------------------------------------------------------------------
; Change Register
; Valid register names: AX,BX,CX,DX,SP,BP,SI,DI,DS,ES,SS,CS,IP,FL (flag)
;----------------------------------------------------------------------
CHANGEREG:
        CALL    RXCHAR          ; Get Command First Register character
        CALL    TO_UPPER
        MOV     DH,AL
        CALL    RXCHAR          ; Get Second Register character, DX=register
        CALL    TO_UPPER
        MOV     DL,AL

        MOV     BX,  REGTAB
CMPREG:
        MOV     AX,[CS:BX]
        CMP     AX,DX           ; Compare register string with user input
        JNE     NEXTREG         ; No, continue search

        WREQUAL
        CALL    GETHEX4         ; Get new value
        MOV     CX,AX           ; CX=New reg value

        LEA     DI,UAX          ; Point to User Register Storage
        MOV     BL,[CS:BX+2]    ; Get
        XOR     BH,BH
        MOV     [DI+BX],CX
        JMP     DISPREG         ; Display All registers

NEXTREG:
        ADD     BX,4
        CMP     BX,  ENDREG
        JNE     CMPREG          ; Continue looking

        MOV     SI,  ERRREG_MESS; Display Unknown Register Name
        CALL    PUTS

        JMP     CMD             ; Try Again

REGTAB:
        DW      'AX',0          ; register name,
        DW      'BX',2
        DW      'CX',4
        DW      'DX',6
        DW      'SP',8
        DW      'BP',10
        DW      'SI',12
        DW      'DI',14
        DW      'DS',16
        DW      'ES',18
        DW      'SS',20
        DW      'CS',22
        DW      'IP',24
        DW      'FL',26
ENDREG:
        DW      '??'


;----------------------------------------------------------------------
; Change Base Segment pointer
; Dump/Fill/Load operate on BASE_SEGMENT:[USER INPUT ADDRESS]
; Note: CB command will not update the User Registers!
;----------------------------------------------------------------------
CHANGEBS:
        MOV     AX,ES           ; WORD BASE_SEGMENT
        CALL    PUTHEX4         ; Display current value
        WRSPACE
        CALL    GETHEX4
        PUSH    AX
        POP     ES
        JMP     CMD             ; Next Command


;----------------------------------------------------------------------
; Execute program
; 1) Restore User registers
; 2) Jump to BASE_SEGMENT:USER_
;----------------------------------------------------------------------
EXECPROG:
        MOV     AX,ES           ; Display Segment Address
        CALL    PUTHEX4
        MOV     AL,':'
        CALL    TXCHAR
        CALL    GETHEX4         ; Get new IP
        MOV     [UIP],AX        ; Update User IP
        MOV     AX,ES
        MOV     [UCS],AX

        MOV     AX,[UAX]        ; Restore User Registers
        MOV     BX,[UBX]
        MOV     CX,[UCX]
        MOV     DX,[UDX]
        MOV     BP,[UBP]
        MOV     SI,[USI]
        MOV     DI,[UDI]

        MOV     ES,[UES]
        CLI                     ; User User Stack!!
        MOV     SS,[USS]
        MOV     SP,[USP]

        PUSH    word [UFL]
        PUSH    word [UCS]      ; Push CS (Base Segment)
        PUSH    word [UIP]
        MOV     DS,[UDS]
        IRET                    ; Execute!

;----------------------------------------------------------------------
; Write Byte to Output port
;----------------------------------------------------------------------
OUTPORTB:
        CALL    GETHEX4         ; Get Port address
        MOV     DX,AX
        WREQUAL
        CALL    GETHEX2         ; Get Port value
        OUT     DX,AL
        JMP     CMD             ; Next Command

;----------------------------------------------------------------------
; Write Word to Output port
;----------------------------------------------------------------------
OUTPORTW:
        CALL    GETHEX4         ; Get Port address
        MOV     DX,AX
        WREQUAL
        CALL    GETHEX4         ; Get Port value
        OUT     DX,AX
        JMP     CMD             ; Next Command

;----------------------------------------------------------------------
; Read Byte from Input port
;----------------------------------------------------------------------
INPORTB:
        CALL    GETHEX4         ; Get Port address
        MOV     DX,AX
        WREQUAL
        IN      AL,DX
        CALL    PUTHEX2
        JMP     CMD             ; Next Command

;----------------------------------------------------------------------
; Read Word from Input port
;----------------------------------------------------------------------
INPORTW:
        CALL    GETHEX4         ; Get Port address
        WREQUAL
        CALL    TXCHAR
        IN      AX,DX
        CALL    PUTHEX4
        JMP     CMD             ; Next Command

;----------------------------------------------------------------------
; Display Memory
;----------------------------------------------------------------------
DUMPMEM:
        CALL    GETRANGE        ; Range from BX to DX
NEXTDMP:
        MOV     SI,  DUMPMEMS   ; Store ASCII values

        CALL    NEWLINE
        MOV     AX,ES
        CALL    PUTHEX4
        MOV     AL,':'
        CALL    TXCHAR
        MOV     AX,BX
        AND     AX,0FFF0h
        CALL    PUTHEX4
        WRSPACE                 ; Write Space
        WRSPACE                 ; Write Space

        MOV     AH,BL           ; Save lsb
        AND     AH,0Fh          ; 16 byte boundary

        CALL    WRNSPACE        ; Write AH spaces
        CALL    WRNSPACE        ; Write AH spaces
        CALL    WRNSPACE        ; Write AH spaces

DISPBYTE:
        MOV     CX,16
        SUB     CL,AH

LOOPDMP1:
        MOV     AL,[ES:BX]      ; Get Byte and display it in HEX
        MOV     [DS:SI],AL      ; Save it
        CALL    PUTHEX2
        WRSPACE                 ; Write Space
        INC     BX
        INC     SI
        CMP     BX,DX
        JNC     SHOWREM         ; show remaining
        LOOP    LOOPDMP1

        CALL    PUTSDMP         ; Display it

        CMP     DX,BX           ; End of memory range?
        JNC     NEXTDMP         ; No, continue with next 16 bytes

SHOWREM:
        MOV     SI,  DUMPMEMS   ; Stored ASCII values
        MOV     AX,BX
        AND     AX,0000Fh
        TEST    AL,AL
        JZ      SKIPCLR
        ADD     SI,AX           ;
        MOV     AH,16
        SUB     AH,AL
        MOV     CL,AH
        XOR     CH,CH
        MOV     AL,' '          ; Clear non displayed values
NEXTCLR:
        MOV     [DS:SI],AL      ; Save it
        INC     SI
        LOOP    NEXTCLR
        CALL    WRNSPACE        ; Write AH spaces
        CALL    WRNSPACE        ; Write AH spaces
        CALL    WRNSPACE        ; Write AH spaces
SKIPCLR:
        XOR     AH,AH
        CALL    PUTSDMP

EXITDMP:
        JMP     CMD             ; Next Command

PUTSDMP:
        MOV     SI,  DUMPMEMS   ; Stored ASCII values
        WRSPACE                 ; Add 2 spaces
        WRSPACE
        CALL    WRNSPACE        ; Write AH spaces
        MOV     CX,16
        SUB     CL,AH           ; Adjust if not started at xxx0
NEXTCH:
        LODSB                   ; Get character AL=DS:[SI++]
        CMP     AL,01Fh         ; 20..7E printable
        JBE     PRINTDOT
        CMP     AL,07Fh
        JAE     PRINTDOT
        JMP     PRINTCH
PRINTDOT:
        MOV     AL,'.'
PRINTCH:
        CALL    TXCHAR
        LOOP    NEXTCH          ; Next Character
        RET

WRNSPACE:
        PUSH    AX              ; Write AH space, skip if 0
        PUSH    CX
        TEST    AH,AH
        JZ      EXITWRNP
        XOR     CH,CH           ; Write AH spaces
        MOV     CL,AH
        MOV     AL,' '
NEXTDTX:
        CALL    TXCHAR
        LOOP    NEXTDTX
EXITWRNP:
        POP     CX
        POP     AX
        RET

;----------------------------------------------------------------------
; Fill Memory
;----------------------------------------------------------------------
FILLMEM:
        CALL    GETRANGE        ; First get range BX to DX
        WRSPACE
        CALL    GETHEX2
        PUSH    AX              ; Store fill character
        CALL    NEWLINE

        CMP     DX,BX
        JB      EXITFILL
DOFILL:
        SUB     DX,BX
        MOV     CX,DX
        MOV     DI,BX           ; [ES:DI]
        POP     AX              ; Restore fill char
NEXTFILL:
        STOSB
        LOOP    NEXTFILL
        STOSB                   ; Last byte
EXITFILL:
        JMP     CMD             ; Next Command

;----------------------------------------------------------------------
; Display Registers
;
; AX=0001 BX=0002 CX=0003 DX=0004 SP=0005 BP=0006 SI=0007 DI=0008
; DS=0009 ES=000A SS=000B CS=000C IP=0100   ODIT-SZAPC=0000-00000
;----------------------------------------------------------------------
DISPREG:
        CALL    NEWLINE
        MOV     SI,  REG_MESS   ;   -> SI
        LEA     DI,UAX

        MOV     CX,8
NEXTDR1:
        CALL    PUTS            ; Point to first "AX=" string
        MOV     AX,[DI]         ; DI points to AX value
        CALL    PUTHEX4         ; Display AX value
        ADD     SI,5            ; point to "BX=" string
        ADD     DI,2            ; Point to BX value
        LOOP    NEXTDR1         ; etc

        CALL    NEWLINE
        MOV     CX,5
NEXTDR2:
        CALL    PUTS            ; Point to first "DS=" string
        MOV     AX,[DI]         ; DI points to DS value
        CALL    PUTHEX4         ; Display DS value
        ADD     SI,5            ; point to "ES=" string
        ADD     DI,2            ; Point to ES value
        LOOP    NEXTDR2         ; etc

        MOV     SI,  FLAG_MESS
        CALL    PUTS
        MOV     SI,  FLAG_VALID ; String indicating which bits to display
        MOV     BX,[DI]         ; get flag value in BX

        MOV     CX,8            ; Display first 4 bits
NEXTBIT1:
        LODSB                   ; Get display/notdisplay flag AL=DS:[SI++]
        CMP     AL,'X'          ; Display?
        JNE     SHFTCAR         ; Yes, shift bit into carry and display it
        SAL     BX,1            ; no, ignore bit
        JMP     EXITDISP1
SHFTCAR:
        SAL     BX,1
        JC      DISP1
        MOV     AL,'0'
        JMP     DISPBIT
DISP1:
        MOV     AL,'1'
DISPBIT:
        CALL    TXCHAR
EXITDISP1:
        LOOP    NEXTBIT1

        MOV     AL,'-'          ; Display seperator 0000-00000
        CALL    TXCHAR

        MOV     CX,8            ; Display remaining 5 bits
NEXTBIT2:
        LODSB                   ; Get display/notdisplay flag AL=DS:[SI++]
        CMP     AL,'X'          ; Display?
        JNE     SHFTCAR2        ; Yes, shift bit into carry and display it
        SAL     BX,1            ; no, ignore bit
        JMP     EXITDISP2
SHFTCAR2:
        SAL     BX,1
        JC      DISP2
        MOV     AL,'0'
        JMP     DISPBIT2
DISP2:
        MOV     AL,'1'
DISPBIT2:
        CALL    TXCHAR
EXITDISP2:
        LOOP    NEXTBIT2

        CALL    NEWLINE         ; Display CS:IP Instr
        MOV     AX,[UCS]
        CALL    PUTHEX4
        MOV     AL,':'
        CALL    TXCHAR
        MOV     AX,[UIP]
        CALL    PUTHEX4
        WRSPACE

        JMP     CMD             ; Next Command

REG_MESS:
        DB      "AX=",0,0       ; Display Register names table
        DB      " BX=",0
        DB      " CX=",0
        DB      " DX=",0
        DB      " SP=",0
        DB      " BP=",0
        DB      " SI=",0
        DB      " DI=",0

        DB      "DS=",0,0
        DB      " ES=",0
        DB      " SS=",0
        DB      " CS=",0
        DB      " IP=",0

;----------------------------------------------------------------------
; Load Hex, terminate when ":00000001FF" is received
; Mon88 may hang if this string is not received
; Print '.' for each valid received frame, exit upon error
; Bytes are loaded at Segment=ES
;----------------------------------------------------------------------
LOADHEX:
        MOV     SI,  LOAD_MESS  ; Display Ready to receive upload
        CALL    PUTS

        MOV     AL,'>'
        JMP     DISPCH

RXBYTE:
        XCHG    BH,AH           ; save AH register
        CALL    RXNIB
        MOV     AH,AL
        SHL     AH,1            ; Can't use CL
        SHL     AH,1
        SHL     AH,1
        SHL     AH,1
        CALL    RXNIB
        OR      AL,AH
        ADD     BL,AL           ; Add to check sum
        XCHG    BH,AH           ; Restore AH register
        RET

RXNIB:
        CALL    RXCHARNE        ; Get Hex Character in AL
        CMP     AL,'0'          ; Check to make sure 0-9,A-F
        JB      ERROR           ;ERRHEX
        CMP     AL,'F'
        JA      ERROR           ;ERRHEX
        CMP     AL,'9'
        JBE     SUB0
        CMP     AL,'A'
        JB      ERROR           ; ERRHEX
        SUB     AL,07h          ; Convert to hex
SUB0:
        SUB     AL,'0'          ; Convert to hex
        RET


ERROR:
        MOV     AL,'E'
DISPCH:
        CALL    TXCHAR

WAITLDS:
        CALL    RXCHARNE        ; Wait for ':'
        CMP     AL,':'
        JNE     WAITLDS

        XOR     CX,CX           ; CL=Byte count
        XOR     BX,BX           ; BL=Checksum

        CALL    RXBYTE          ; Get length in CX
        MOV     CL,AL

        CALL    RXBYTE          ; Get Address HIGH
        MOV     AH,AL
        CALL    RXBYTE          ; Get Address LOW
        MOV     DI,AX           ; DI=Store Address

        CALL    RXBYTE          ; Get Record Type
        CMP     AL,EOF_REC      ; End Of File Record
        JE      GOENDLD
        CMP     AL,DATA_REC     ; Data Record?
        JE      GOLOAD
        CMP     AL,EAD_REC      ; Extended Address Record?
        JE      GOEAD
        CMP     AL,SSA_REC      ; Start Segment Address Record?
        JE      GOSSA
        JMP     ERROR           ;ERRREC

GOSSA:
        MOV     CX,2            ; Get 2 word
NEXTW:
        CALL    RXBYTE
        MOV     AH,AL
        CALL    RXBYTE
        PUSH    AX              ; Push CS, IP
        LOOP    NEXTW
        CALL    RXBYTE          ; Get Checksum
        SUB     BL,AL           ; Remove checksum from checksum
        NOT     AL              ; Two's complement
        ADD     AL,1
        CMP     AL,BL           ; Checksum held in BL
        JNE     ERROR           ;ERRCHKS
        RETF                    ; Execute loaded file

GOENDLD:
        CALL    RXBYTE
        SUB     BL,AL           ; Remove checksum from checksum
        NOT     AL              ; Two's complement
        ADD     AL,1
        CMP     AL,BL           ; Checksum held in BL
        JNE     ERROR           ;ERRCHKS
        JMP     LOADOK

GOCHECK:
        CALL    RXBYTE
        SUB     BL,AL           ; Remove checksum from checksum
        NOT     AL              ; Two's complement
        ADD     AL,1
        CMP     AL,BL           ; Checksum held in BL
        JNE     ERROR           ;ERRCHKS
        MOV     AL,'.'          ; After each successful record print a '.'
        JMP     DISPCH

GOLOAD:
        CALL    RXBYTE          ; Read Bytes
        STOSB                   ; ES:DI <= AL
        LOOP    GOLOAD
        JMP     GOCHECK

GOEAD:
        CALL    RXBYTE
        MOV     AH,AL
        CALL    RXBYTE
        MOV     ES,AX           ; Set Segment address (ES)
        JMP     GOCHECK

;ERRCHKS:    MOV     SI,  LD_CHKS_MESS      ; Display Checksum error
;            JMP     EXITLD                      ; Exit Load Command
;ERRREC:     MOV     SI,  LD_REC_MESS       ; Display unknown record type
;            JMP     EXITLD                      ; Exit Load Command
LOADOK:
        MOV     SI,  LD_OK_MESS ; Display Load OK
;            JMP     EXITLD
;ERRHEX:     MOV     SI,  LD_HEX_MESS       ; Display Error hex value
EXITLD:
        CALL    PUTS
        JMP     CMD             ; Exit Load Command

;----------------------------------------------------------------------
; Display Help Menu
;----------------------------------------------------------------------
DISPHELP:
        MOV     SI,  HELP_MESS  ;   -> SI
        CALL    PUTS            ; String pointed to by DS:[SI]
EXITDH:
        JMP     CMD             ; Next Command


;======================================================================
; Monitor routines
;======================================================================
;----------------------------------------------------------------------
; Return String Length in AL
; String pointed to by DS:[SI]
;----------------------------------------------------------------------
STRLEN:
        PUSH    SI
        MOV     AH,-1
        CLD
NEXTSL:
        INC     AH
        LODSB                   ; AL=DS:[SI++]
        OR      AL,AL           ; Zero?
        JNZ     NEXTSL          ; No, continue
        MOV     AL,AH           ; Return Result in AX
        XOR     AH,AH
        POP     SI
        RET

;----------------------------------------------------------------------
; Write zero terminated string to CONOUT
; String pointed to by CS:[SI]
;----------------------------------------------------------------------
PUTS:
        PUSH    DS
        PUSH    SI
        PUSH    AX

        PUSH    AX
        MOV     AX,CS
        MOV     DS,AX
        POP     AX

        CLD
PRINT:
        LODSB                   ; AL=DS:[SI++]
        OR      AL,AL           ; Zero?
        JZ      PRINT_X         ; then exit
        CALL    TXCHAR
        JMP     PRINT           ; Next Character
PRINT_X:
        POP     AX
        POP     SI
        POP     DS
        RET

;----------------------------------------------------------------------
; Write zero terminated string to CONOUT
; String pointed to by DS:[SI]
;----------------------------------------------------------------------
PUTSD:
        PUSH    SI
        PUSH    AX
        CLD
PRINTD:
        LODSB                   ; AL=DS:[SI++]
        OR      AL,AL           ; Zero?
        JZ      PRINTD_X        ; then exit
        CALL    TXCHAR
        JMP     PRINTD          ; Next Character
PRINTD_X:
        POP     AX
        POP     SI
        RET


;----------------------------------------------------------------------
; Write string to CONOUT, length in CL
; String pointed to by DS:[SI]
;----------------------------------------------------------------------
PUTSF:
        PUSH    SI
        PUSH    CX
        PUSH    AX
        CLD
        XOR     CH,CH
PRTF:
        LODSB                   ; AL=DS:[SI++]
        CALL    TXCHAR
        LOOP    PRTF
        POP     AX
        POP     CX
        POP     SI
        RET

;----------------------------------------------------------------------
; Write newline
;----------------------------------------------------------------------
NEWLINE:
        PUSH    AX
        MOV     AL,CR
        CALL    TXCHAR
        MOV     AL,LF
        CALL    TXCHAR
        POP     AX
        RET
;----------------------------------------------------------------------
; Get Address range into BX, DX
;----------------------------------------------------------------------
GETRANGE:
        PUSH    AX
        CALL    GETHEX4
        MOV     BX,AX
        MOV     AL,'-'
        CALL    TXCHAR
        CALL    GETHEX4
        MOV     DX,AX
        POP     AX
        RET

;----------------------------------------------------------------------
; Get Hex4,2,1 Into AX, AL, AL
;----------------------------------------------------------------------
GETHEX4:
        PUSH    BX
        CALL    GETHEX2         ; Get Hex Character in AX
        MOV     BL,AL
        CALL    GETHEX2
        MOV     AH,BL
        POP     BX
        RET

GETHEX2:
        PUSH    BX
        CALL    GETHEX1         ; Get Hex character in AL
        MOV     BL,AL
        SHL     BL,1
        SHL     BL,1
        SHL     BL,1
        SHL     BL,1
        CALL    GETHEX1
        OR      AL,BL
        POP     BX
        RET

GETHEX1:
        CALL    RXCHAR          ; Get Hex character in AL
        CMP     AL,ESC
        JNE     OKCHAR
        JMP     CMD             ; Abort if ESC is pressed
OKCHAR:
        CALL    TO_UPPER
        CMP     AL,39h          ; 0-9?
        JLE     CONVDEC         ; yes, subtract 30
        SUB     AL,07h          ; A-F subtract 39
CONVDEC:
        SUB     AL,30h
        RET

;----------------------------------------------------------------------
; Display AX/AL in HEX
;----------------------------------------------------------------------
PUTHEX4:
        XCHG    AL,AH           ; Write AX in hex
        CALL    PUTHEX2
        XCHG    AL,AH
        CALL    PUTHEX2
        RET

PUTHEX2:
        PUSH    AX              ; Save the working register
        SHR     AL,1
        SHR     AL,1
        SHR     AL,1
        SHR     AL,1
        CALL    PUTHEX1         ; Output it
        POP     AX              ; Get the LSD
        CALL    PUTHEX1         ; Output
        RET

PUTHEX1:
        PUSH    AX              ; Save the working register
        AND     AL, 0FH         ; Mask off any unused bits
        CMP     AL, 0AH         ; Test for alpha or numeric
        JL      NUMERIC         ; Take the branch if numeric
        ADD     AL, 7           ; Add the adjustment for hex alpha
NUMERIC:
        ADD     AL, '0'         ; Add the numeric bias
        CALL    TXCHAR          ; Send to the console
        POP     AX
        RET

;----------------------------------------------------------------------
; Convert HEX to BCD
; 3Bh->59
;----------------------------------------------------------------------
HEX2BCD:
        PUSH    CX
        XOR     AH,AH
        MOV     CL,0Ah
        DIV     CL
        SHL     AL,1
        SHL     AL,1
        SHL     AL,1
        SHL     AL,1
        OR      AL,AH
        POP     CX
        RET

;----------------------------------------------------------------------
; Convert to Upper Case
; if (c >= 'a' && c <= 'z') c -= 32;
;----------------------------------------------------------------------
TO_UPPER:
        CMP     AL,'a'
        JGE     CHECKZ
        RET
CHECKZ:
        CMP     AL,'z'
        JLE     SUB32
        RET
SUB32:
        SUB     AL,32
        RET

;----------------------------------------------------------------------
; Transmit character in AL
;----------------------------------------------------------------------
TXCHAR:
        PUSH    DX
        PUSH    AX              ; Character in AL
        MOV     dx,uart_lsr     ; READ LINE STATUS REGISTER
WAITTX:
        IN      AL,DX
        AND     AL,20h          ; And status with user BH mask
        JZ      WAITTX          ; no, wait
        MOV     DX,uart_thr     ; point to data port
        POP     AX
        OUT     DX,AL
        POP     DX
        RET

;----------------------------------------------------------------------
; Receive character in AL, blocking
; AL Changed
;----------------------------------------------------------------------
RXCHAR:
        PUSH    DX
        MOV     DX,uart_lsr
WAITRX:
        IN      AL,DX
        AND     AL,01h
        JZ      WAITRX          ; blocking
        MOV     DX,uart_rbr
        IN      AL,DX           ; return result in al
        CALL    TXCHAR          ; Echo back
        POP     DX
        RET

;----------------------------------------------------------------------
; Receive character in AL, blocking
; AL Changed
; No Echo
;----------------------------------------------------------------------
RXCHARNE:
        PUSH    DX
        MOV     DX,uart_lsr
WAITRXNE:
        IN      AL,DX
        AND     AL,01h
        JZ      WAITRXNE        ; blocking
        MOV     DX,uart_rbr
        IN      AL,DX           ; return result in al
        POP     DX
        RET

;======================================================================
; Monitor Interrupt Handlers
;======================================================================
;----------------------------------------------------------------------
; Breakpoint/Trace Interrupt Handler
; Restore All instructions
; Display Breakpoint Number
; Update & Display Registers
; Return to monitor
;----------------------------------------------------------------------
INT1_3:
        PUSH    BP
        MOV     BP,SP           ; BP+2=IP, BP+4=CS, BP+6=Flags
        PUSH    SS
        PUSH    ES
        PUSH    DS
        PUSH    DI
        PUSH    SI
        PUSH    BP              ; Note this is the wrong value
        PUSH    SP
        PUSH    DX
        PUSH    CX
        PUSH    BX
        PUSH    AX

        MOV     ax, 0000h       ; Set DS
        MOV     DS,AX

        MOV     AX,[SS:BP+4]    ; Get user CS
        MOV     ES,AX           ; Used for restoring bp replaced opcode
        MOV     [UCS],AX        ; Save User CS

        MOV     AX,[SS:BP+2]    ; Save User IP
        MOV     [UIP],AX

        MOV     DI,SP           ; SS:SP=AX
        MOV     BX,  UAX        ; Update User registers, DI=pointing to AX
        MOV     CX,11
NEXTUREG:
        MOV     AX,[SS:DI]      ; Get register
        MOV     [BX],AX         ; Write it to user reg
        ADD     BX,2
        ADD     DI,2
        LOOP    NEXTUREG

        MOV     AX,BP           ; Save User SP
        ADD     AX,8
        MOV     [USP],AX

        MOV     AX,[SS:BP]
        MOV     [UBP],AX        ; Restore real BP value

        MOV     AX,[SS:BP+6]    ; Save Flags
        MOV     [UFL],AX
        AND     word [UFL],0FEFFh; Clear TF
;        TEST    AX,0100h        ; Check If Trace flag set then
;        JZ      CONTBPC         ; No, check which bp triggered it

        JMP     EXITINT3        ; Exit, Display regs, Cmd prompt

;CONTBPC:
;        DEC     word [UIP]      ; No, IP-1 and save;

;        MOV     SI,  BREAKP_MESS; Display "***** BreakPoint # *****

;        MOV     BX,  BPTAB      ; Check which breakpoint triggered
;        MOV     CX,8            ; and restore opcode
;INTNEXTBP:
;        MOV     AX,8
;        SUB     AL,CL

;        TEST    BYTE [BX+3],1   ; Check enable/disable flag
;        JZ      INT3RESBP

;        MOV     DI,[BX]         ; Get Breakpoint Address
;        CMP     [UIP],DI
;        JNE     INT3RES

;        ADD     AL, '0'         ; Add the numeric bias
;        MOV     [SI+18],AL      ; Save number

;INT3RES:
;        MOV     AL,BYTE [BX+2]  ; Get original Opcode
;       MOV     [ES:DI],AL      ; Write it back

;INT3RESBP:
;       ADD     BX,4            ; Next entry
;       LOOP    INTNEXTBP

;        CALL    PUTS            ; Write BP Number message

EXITINT3:
        MOV     ax, 9100h       ; Stack at top of RAM
        MOV     ss, ax
        MOV     ax, 0000h       ; Set DS
        MOV     DS,AX
        MOV     AX,  TOS        ; Top of Stack
        MOV     SP,AX           ; Restore Monitor Stack pointer
        MOV     AX,BASE_SEGMENT ; Restore Base Pointer
        MOV     ES,AX

        JMP     DISPREG         ; Jump to Display Registers

;======================================================================
; BIOS Services
;======================================================================

        %INCLUDE "int10.asm"
        %INCLUDE "int16.asm"
        %INCLUDE "int1a.asm"
        %INCLUDE "int21.asm"


;----------------------------------------------------------------------
; Unknown Service Handler
; Display Message, interrupt and service number before jumping back to the monitor
;----------------------------------------------------------------------
DISPSERI:
        MOV     BX,AX           ; Store int number (AL) and service (AH)
        MOV     ax, 0000h       ; Set DS
        MOV     DS,AX
        MOV     SI,  UNKNOWNSER_MESS; Print Error: Unknown Service
        CALL    PUTS
        MOV     AL,BL
        CALL    PUTHEX2         ; Print Interrupt Number
        MOV     AL,','
        CALL    TXCHAR
        MOV     AL,BH
        CALL    PUTHEX2         ; Write Service number
        RET

;----------------------------------------------------------------------
; Spurious Interrupt Handler
;----------------------------------------------------------------------
INTX:
        PUSH    DS
        PUSH    SI
        PUSH    AX

        MOV     SI,  UNKNOWN_MESS; Print Error: Unknown Service
        CALL    PUTS

        POP     AX
        POP     SI
        POP     DS
        IRET


;----------------------------------------------------------------------
; Text Strings
;----------------------------------------------------------------------
WELCOME_MESS:
        DB      CR,LF,LF,"MON88 8088/8086 Monitor ver 0.1"
        DB      CR,LF,"Copyright WWW.HT-LAB.COM 2005",
        DB      CR,LF,"Modified for Duodyne 80c188",
        DB      CR,LF,"All rights reserved.",CR,LF,0
PROMPT_MESS:
        DB      CR,LF,"Cmd>",0
ERRCMD_MESS:
        DB      " <- Unknown Command, type H to Display Help",0
ERRREG_MESS:
        DB      " <- Unknown Register, valid names: AX,BX,CX,DX,SP,BP,SI,DI,DS,ES,SS,CS,IP,FL",0

LOAD_MESS:
        DB      CR,LF,"Start upload now, load is terminated by :00000001FF",CR,LF,0
LD_CHKS_MESS:
        DB      CR,LF,"Error: CheckSum failure",CR,LF,0
LD_REC_MESS:
        DB      CR,LF,"Error: Unknown Record Type",CR,LF,0
LD_HEX_MESS:
        DB      CR,LF,"Error: Non Hex value received",CR,LF,0
LD_OK_MESS:
        DB      CR,LF,"Load done",CR,LF,0
TERM_MESS:
        DB      CR,LF,"Program Terminated with exit code ",0

; Mess+18=? character, change by bp number
BREAKP_MESS:
        DB      CR,LF,"**** BREAKPOINT ? ****",CR,LF,0

FLAG_MESS:
        DB      "   ODIT-SZAPC=",0
FLAG_VALID:
        DB      "XXXX......X.X.X.",0; X=Don't display flag bit, .=Display

HELP_MESS:
        DB      CR,LF,"Commands"
        DB      CR,LF,"D {from} {to}         : Dump Memory, example D 0000 0100"
        DB      CR,LF,"F {from} {to} {Byte}  : Fill Memory, example FM 0200 020F 5A"
        DB      CR,LF,"R                     : Display Registers"
        DB      CR,LF,"C {reg}               : Change Registers, example CR SP=1234"
        DB      CR,LF,"L                     : Load Intel hexfile"
        DB      CR,LF,"G  {Address}          : Execute, example G 0100"
        DB      CR,LF,"B {Word}              : Change Base Segment Address, example BS 0340"
        DB      CR,LF,"WB {Address} {Byte}   : Write Byte to address, example WB 1234 5A"
        DB      CR,LF,"WW {Address} {Word}   : Write Word to address"
        DB      CR,LF,"IB {Port}             : Read Byte from Input port, example IB 03F8"
        DB      CR,LF,"IW {Port}             : Read Word from Input port"
        DB      CR,LF,"OB {Port} {Byte}      : Write Byte to Output port, example OB 03F8 3A"
        DB      CR,LF,"OW {Port} {Word}      : Write Word to Output port, example OB 03F8 3A5A"
        DB      CR,LF,0


UNKNOWN_MESS:
        DB      CR,LF,"*** ERROR: Spurious Interrupt ",0
UNKNOWNSER_MESS:
        DB      CR,LF,"*** ERROR: Unknown Service INT,AH=",0

        %INCLUDE "startup.asm"
