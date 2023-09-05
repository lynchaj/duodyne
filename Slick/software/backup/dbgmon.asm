;___Rom_Monitor_Program_____________________________________________________________________________________________________________
;
;  Original Code by:	Andrew Lynch (lynchaj@yahoo.com)	13 Feb 2007
;
;  Modified by : 	Dan Werner 03.09.2009
;
;__References________________________________________________________________________________________________________________________
; Thomas Scherrer basic hardware test assembler sources from the Z80 info page
; including original schematic concept
; http://z80.info/z80sourc.txt
; Code samples from Bruce Jones public domain ROM monitor for the SBC-200C
; http://www.retrotechnology.com/herbs_stuff/sd_bruce_code.zip
; Inspiration from Joel Owens "Z-80 Space-Time Productions Single Board Computer"
; http://www.joelowens.org/z80/z80index.html
; Great help and technical advice from Allison at ALPACA_DESIGNERS
; http://groups.yahoo.com/group/alpaca_designers
; INTEL SDK-85 ROM Debug Monitor
;
;__Hardware_Interfaces________________________________________________________________________________________________________________
;

; UART 16C550 SERIAL IS DECODED TO 58-5F
;
        UART0   =    58H        ;   DATA IN/OUT
        UART1   =    59H        ;   CHECK RX
        UART2   =    5AH        ;   INTERRUPTS
        UART3   =    5BH        ;   LINE CONTROL
        UART4   =    5CH        ;   MODEM CONTROL
        UART5   =    5DH        ;   LINE STATUS
        UART6   =    5EH        ;   MODEM STATUS
        UART7   =    5FH        ;   SCRATCH REG.
;
; MEMORY PAGE CONFIGURATION
;
        BANK00  =   $50
        BANK40  =   $51
        BANK80  =   $52
        BANKC0  =   $53
        BANK_ENABLE=$54


;
;
;        BANK00 - SETS RAM UPPER BITS A14-A21 FOR CPU PAGES 00-3F
;        BANK40 - SETS RAM UPPER BITS A14-A21 FOR CPU PAGES 40-7F
;        BANK80 - SETS RAM UPPER BITS A14-A21 FOR CPU PAGES 80-BF
;        BANKC0 - SETS RAM UPPER BITS A14-A21 FOR CPU PAGES C0-FF
;
;        BANKING ENABLED WHEN BANK_ENABLE SET TO 1
;
;        PAGES 00-1F ARE ROM
;        PAGES 20-3F ARE RAM
;
    I2C     =   $56
    I2C_S1  =   $57
;
;
;__Constants_________________________________________________________________________________________________________________________
;
        RAMTOP  =    $FFFF      ; HIGHEST ADDRESSABLE MEMORY LOCATION
        STACKSTART =    $CFFF   ; sTART OF STACK
        RAMBOTTOM =    $4000    ;
        END     =    $FF        ; Mark END OF TEXT
        CR      =    0DH        ; ASCII carriage return character
        LF      =   0AH         ; ASCII line feed character
        ESC     =    1BH        ; ASCII escape character
        BS      =    08H        ; ASCII backspace character
;
;
;
;__Main_Program_____________________________________________________________________________________________________________________
;
        ORG     0000H           ; Normal Op

;
;   SETUP MEMORY PAGES
;   ROM = 0000-3FFF ROM BANK0
;   RAM = 4000-FFFF RAM BANKS 0,1,2 OR PAGES 20,21,22
;
        LD      A,00H           ;
        OUT     (BANK00),A
        LD      A,20H           ;
        OUT     (BANK40),A
        LD      A,21H           ;
        OUT     (BANK80),A
        LD      A,22H           ;
        OUT     (BANKC0),A
;   ENABLE PAGER
        LD      A,01H           ;
        OUT     (BANK_ENABLE),A
;

        LD      SP,STACKSTART   ; Set the Stack Pointer to STACKSTART
        CALL    INITIALIZE      ; Initialize System

;__MONSTARTWARM___________________________________________________________________________________________________________________
;
;	Serial Monitor Startup
;________________________________________________________________________________________________________________________________
;

MONSTARTWARM:                   ; CALL HERE FOR SERIAL MONITOR WARM START

        XOR     A               ;ZERO OUT ACCUMULATOR (added)
        PUSH    HL              ;protect HL from overwrite
        LD      HL,TXT_READY    ;POINT AT TEXT
        CALL    MSG             ;SHOW WE'RE HERE
        POP     HL              ;protect HL from overwrite

;
;__SERIAL_Monitor_Commands_________________________________________________________________________________________________________
;
; B Xx BOOT CPM FROM DRIVE Xx
; D XXXXH YYYYH  DUMP MEMORY FROM XXXX TO YYYY
; F XXXXH YYYYH ZZH FILL MEMORY FROM XXXX TO YYYY WITH ZZ
; H LOAD INTEL HEX FORMAT DATA
; I INPUT FROM PORT AND SHOW HEX DATA
; K ECHO KEYBOARD INPUT
; M XXXXH YYYYH ZZZZH MOVE MEMORY BLOCK XXXX TO YYYY TO ZZZZ
; O OUTPUT TO PORT HEX DATA
; P XXXXH YYH PROGRAM RAM FROM XXXXH WITH VALUE IN YYH, WILL PROMPT FOR NEXT LINES FOLLOWING UNTIL CR
; R RUN A PROGRAM FROM CURRENT LOCATION



;__Command_Parse_________________________________________________________________________________________________________________
;
;	Prompt User for commands, then parse them
;________________________________________________________________________________________________________________________________
;

SERIALCMDLOOP:
        CALL    CRLFA           ; CR,LF,>
        LD      HL,KEYBUF       ; SET POINTER TO KEYBUF AREA
        CALL    GETLN           ; GET A LINE OF INPUT FROM THE USER
        LD      HL,KEYBUF       ; RESET POINTER TO START OF KEYBUF
        LD      A,(HL)          ; LOAD FIRST CHAR INTO A (THIS SHOULD BE THE COMMAND)
        INC     HL              ; INC POINTER

        CP      'R'             ; IS IT "R" (y/n)
        JP      Z,RUN           ; IF YES GO RUN ROUTINE
        CP      'P'             ; IS IT "P" (y/n)
        JP      Z,PROGRM        ; IF YES GO PROGRAM ROUTINE
        CP      'O'             ; IS IT AN "O" (y/n)
        JP      Z,POUT          ; PORT OUTPUT
        CP      'H'             ; IS IT A "H" (y/n)
        JP      Z,HXLOAD        ; INTEL HEX FORMAT LOAD DATA
        CP      'I'             ; IS IT AN "I" (y/n)
        JP      Z,PIN           ; PORT INPUT
        CP      'D'             ; IS IT A "D" (y/n)
        JP      Z,DUMP          ; DUMP MEMORY
        CP      'K'
        JP      Z,KLOP          ; LOOP ON KEYBOARD
        CP      'M'             ; IS IT A "M" (y/n)
        JP      Z,MOVE          ; MOVE MEMORY COMMAND
        CP      'F'             ; IS IT A "F" (y/n)
        JP      Z,FILL          ; FILL MEMORY COMMAND
        LD      HL,TXT_COMMAND  ; POINT AT ERROR TEXT
        CALL    MSG             ; print command label

        JR      SERIALCMDLOOP





;__KLOP__________________________________________________________________________________________________________________________
;
;	Read from the Serial Port and Echo, Monitor Command "K"
;________________________________________________________________________________________________________________________________
;
KLOP:
        CALL    KIN             ; GET A KEY
        CALL    COUT            ; OUTPUT KEY TO SCREEN
        CP      ESC             ; IS <ESC>?
        JR      NZ,KLOP         ; NO, LOOP
        JP      SERIALCMDLOOP   ;

;__GETLN_________________________________________________________________________________________________________________________
;
;	Read a line(80) of text from the Serial Port, handle <BS>, term on <CR>.
;       Exit if too many chars.   Store result in HL.  Char count in C.
;________________________________________________________________________________________________________________________________
;
GETLN:
        LD      C,00H           ; ZERO CHAR COUNTER
        PUSH    DE              ; STORE DE
GETLNLOP:
        CALL    KIN             ; GET A KEY
        CALL    COUT            ; OUTPUT KEY TO SCREEN
        CP      CR              ; IS <CR>?
        JR      Z,GETLNDONE     ; YES, EXIT
        CP      BS              ; IS <BS>?
        JR      NZ,GETLNSTORE   ; NO, STORE CHAR
        LD      A,C             ; A=C
        CP      0               ;
        JR      Z,GETLNLOP      ; NOTHING TO BACKSPACE, IGNORE & GET NEXT KEY
        DEC     HL              ; PERFORM BACKSPACE
        DEC     C               ; LOWER CHAR COUNTER
        LD      A,0             ;
        LD      (HL),A          ; STORE NULL IN BUFFER
        LD      A,20H           ; BLANK OUT CHAR ON TERM
        CALL    COUT            ;
        LD      A,BS            ;
        CALL    COUT            ;
        JR      GETLNLOP        ; GET NEXT KEY
GETLNSTORE:
        LD      (HL),A          ; STORE CHAR IN BUFFER
        INC     HL              ; INC POINTER
        INC     C               ; INC CHAR COUNTER
        LD      A,C             ; A=C
        CP      4DH             ; OUT OF BUFFER SPACE?
        JR      NZ,GETLNLOP     ; NOPE, GET NEXT CHAR
GETLNDONE:
        LD      (HL),00H        ; STORE NULL IN BUFFER
        POP     DE              ; RESTORE DE
        RET                     ;


;__KIN___________________________________________________________________________________________________________________________
;
;	Read from the Serial Port and Echo & convert input to UCASE
;________________________________________________________________________________________________________________________________
;
KIN:
        IN      A,(UART5)       ; READ Line Status Register
        db      $CB, $47           ;BIT     0,A             ; TEST IF DATA IN RECEIVE BUFFER
        JP      Z,KIN           ; LOOP UNTIL DATA IS READY
        IN      A,(UART0)       ; THEN READ THE CHAR FROM THE UART
        AND     7FH             ; STRIP HI BIT
        CP      'a'             ; KEEP NUMBERS, CONTROLS
        RET     C               ; AND UPPER CASE
        CP      7BH             ; SEE IF NOT LOWER CASE
        RET     NC              ;
        AND     5FH             ; MAKE UPPER CASE
        RET


;__COUT__________________________________________________________________________________________________________________________
;
;	Write the Value in "A" to the Serial Port
;________________________________________________________________________________________________________________________________
;
COUT:
        PUSH    AF              ; Store AF
TX_BUSYLP:
        IN      A,(UART5)       ; READ Line Status Register
        db      $CB,$6F       	; BIT	5,A			; TEST IF UART IS READY TO SEND
        JP      Z,TX_BUSYLP     ; IF NOT REPEAT
        POP     AF              ; Restore AF
        OUT     (UART0),A       ; THEN WRITE THE CHAR TO UART
        RET                     ; DONE


;__CRLF__________________________________________________________________________________________________________________________
;
;	Send CR & LF to the Serial Port
;________________________________________________________________________________________________________________________________
;
CRLF:
        PUSH    HL              ; protect HL from overwrite
        LD      HL,TCRLF        ; Load Message Pointer
        CALL    MSG             ; Sebd Message to Serial Port
        POP     HL              ; protect HL from overwrite
        RET                     ;


;__LDHL__________________________________________________________________________________________________________________________
;
;	GET ONE WORD OF HEX DATA FROM BUFFER POINTED TO BY HL SERIAL PORT, RETURN IN HL
;________________________________________________________________________________________________________________________________
;
LDHL:
        PUSH    DE              ; STORE DE
        CALL    HEXIN           ; GET K.B. AND MAKE HEX
        LD      D,A             ; THATS THE HI BYTE
        CALL    HEXIN           ; DO HEX AGAIN
        LD      L,A             ; THATS THE LOW BYTE
        LD      H,D             ; MOVE TO HL
        POP     DE              ; RESTORE BC
        RET                     ; GO BACK WITH ADDRESS


;__HEXIN__________________________________________________________________________________________________________________________
;
;	GET ONE BYTE OF HEX DATA FROM BUFFER IN HL, RETURN IN A
;________________________________________________________________________________________________________________________________
;
HEXIN:
        PUSH    BC              ;SAVE BC REGS.
        CALL    NIBL            ;DO A NIBBLE
        RLA                     ;MOVE FIRST BYTE UPPER NIBBLE
        RLA                     ;
        RLA                     ;
        RLA                     ;
        LD      B,A             ; SAVE ROTATED BYTE
        CALL    NIBL            ; DO NEXT NIBBLE
        ADD     A,B             ; COMBINE NIBBLES IN ACC.
        POP     BC              ; RESTORE BC
        RET                     ; DONE
NIBL:
        LD      A,(HL)          ; GET K.B. DATA
        INC     HL              ; INC KB POINTER
        CP      40H             ; TEST FOR ALPHA
        JR      NC,ALPH         ;
        AND     0FH             ; GET THE BITS
        RET                     ;
ALPH:
        AND     0FH             ; GET THE BITS
        ADD     A,09H           ; MAKE IT HEX A-F
        RET                     ;


;__HEXINS_________________________________________________________________________________________________________________________
;
;	GET ONE BYTE OF HEX DATA FROM SERIAL PORT, RETURN IN A
;________________________________________________________________________________________________________________________________
;
HEXINS:
        PUSH    BC              ;SAVE BC REGS.
        CALL    NIBLS           ;DO A NIBBLE
        RLA                     ;MOVE FIRST BYTE UPPER NIBBLE
        RLA                     ;
        RLA                     ;
        RLA                     ;
        LD      B,A             ; SAVE ROTATED BYTE
        CALL    NIBLS           ; DO NEXT NIBBLE
        ADD     A,B             ; COMBINE NIBBLES IN ACC.
        POP     BC              ; RESTORE BC
        RET                     ; DONE
NIBLS:
        CALL    KIN             ; GET K.B. DATA
        INC     HL              ; INC KB POINTER
        CP      40H             ; TEST FOR ALPHA
        JR      NC,ALPH         ;
        AND     0FH             ; GET THE BITS
        RET                     ;


;__HXOUT_________________________________________________________________________________________________________________________
;
;	PRINT THE ACCUMULATOR CONTENTS AS HEX DATA ON THE SERIAL PORT
;________________________________________________________________________________________________________________________________
;
HXOUT:
        PUSH    BC              ; SAVE BC
        LD      B,A             ;
        RLA                     ; DO HIGH NIBBLE FIRST
        RLA                     ;
        RLA                     ;
        RLA                     ;
        AND     0FH             ; ONLY THIS NOW
        ADD     A,30H           ; TRY A NUMBER
        CP      3AH             ; TEST IT
        JR      C,OUT1          ; IF CY SET PRINT 'NUMBER'
        ADD     A,07H           ; MAKE IT AN ALPHA
OUT1:
        CALL    COUT            ; SCREEN IT
        LD      A,B             ; NEXT NIBBLE
        AND     0FH             ; JUST THIS
        ADD     A,30H           ; TRY A NUMBER
        CP      3AH             ; TEST IT
        JR      C,OUT2          ; PRINT 'NUMBER'
        ADD     A,07H           ; MAKE IT ALPHA
OUT2:
        CALL    COUT            ; SCREEN IT
        POP     BC              ; RESTORE BC
        RET                     ;


;__SPACE_________________________________________________________________________________________________________________________
;
;	PRINT A SPACE CHARACTER ON THE SERIAL PORT
;________________________________________________________________________________________________________________________________
;
SPACE:
        PUSH    AF              ; Store AF
        LD      A,20H           ; LOAD A "SPACE"
        CALL    COUT            ; SCREEN IT
        POP     AF              ; RESTORE AF
        RET                     ; DONE

;__PHL_________________________________________________________________________________________________________________________
;
;	PRINT THE HL REG ON THE SERIAL PORT
;________________________________________________________________________________________________________________________________
;
PHL:
        LD      A,H             ; GET HI BYTE
        CALL    HXOUT           ; DO HEX OUT ROUTINE
        LD      A,L             ; GET LOW BYTE
        CALL    HXOUT           ; HEX IT
        CALL    SPACE           ;
        RET                     ; DONE

;__POUT__________________________________________________________________________________________________________________________
;
;	Output to an I/O Port, Monitor Command "O"
;________________________________________________________________________________________________________________________________
;
POUT:
POUT1:
        INC     HL              ;
        CALL    HEXIN           ; GET PORT
        LD      C,A             ; SAVE PORT POINTER
        INC     HL              ;
        CALL    HEXIN           ; GET DATA
OUTIT:
        DB      $ED,$79         ;OUT	(C),A			; OUTPUT VALUE TO PORT STORED IN "C"
        JP      SERIALCMDLOOP   ;


;__PIN___________________________________________________________________________________________________________________________
;
;	Input From an I/O Port, Monitor Command "I"
;________________________________________________________________________________________________________________________________
;
PIN:
        INC     HL              ;
        CALL    HEXIN           ; GET PORT
        LD      C,A             ; SAVE PORT POINTER
        CALL    CRLF            ;
        DB      $ED,$78       	; IN	A,(C)			; GET DATA
        CALL    HXOUT           ; SHOW IT
        JP      SERIALCMDLOOP   ;




;__CRLFA_________________________________________________________________________________________________________________________
;
;	Print Command Prompt to the serial port
;________________________________________________________________________________________________________________________________
;
CRLFA:
        PUSH    HL              ; protect HL from overwrite
        LD      HL,PROMPT       ;
        CALL    MSG             ;
        POP     HL              ; protect HL from overwrite
        RET                     ; DONE


;__MSG___________________________________________________________________________________________________________________________
;
;	Print a String  to the serial port
;________________________________________________________________________________________________________________________________
;
MSG:

TX_SERLP:
        LD      A,(HL)          ; GET CHARACTER TO A
        CP      END             ; TEST FOR END BYTE
        JP      Z,TX_END        ; JUMP IF END BYTE IS FOUND
        CALL    COUT            ;
        INC     HL              ; INC POINTER, TO NEXT CHAR
        JP      TX_SERLP        ; TRANSMIT LOOP
TX_END:
        RET                     ;ELSE DONE

;__RUN___________________________________________________________________________________________________________________________
;
;	TRANSFER OUT OF MONITOR, User option "R"
;________________________________________________________________________________________________________________________________
;
RUN:
        INC     HL              ; SHOW READY
        CALL    LDHL            ; GET START ADDRESS
        JP      (HL)            ;


;__PROGRM________________________________________________________________________________________________________________________
;
;	Program RAM locations, User option "P"
;________________________________________________________________________________________________________________________________
;
PROGRM:
        INC     HL              ; SHOW READY
        PUSH    HL              ; STORE HL
        CALL    LDHL            ; GET START ADDRESS
        LD      D,H             ;
        LD      E,L             ; DE POINTS TO ADDRESS TO PROGRAM
        POP     HL              ;
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
PROGRMLP:
        CALL    HEXIN           ; GET NEXT HEX NUMBER
        LD      (DE),A          ; STORE IT
        INC     DE              ; NEXT ADDRESS;
        CALL    CRLFA           ; CR,LF,>
        LD      A,'P'           ;
        CALL    COUT            ;
        CALL    SPACE           ;
        LD      H,D             ;
        LD      L,E             ;
        CALL    PHL             ;
        LD      HL,KEYBUF       ; SET POINTER TO KEYBUF AREA
        CALL    GETLN           ; GET A LINE OF INPUT FROM THE USER
        LD      HL,KEYBUF       ; RESET POINTER TO START OF KEYBUF
        LD      A,(HL)          ; LOAD FIRST CHAR INTO A
        CP      00H             ; END OF LINE?
        JP      Z,PROGRMEXIT    ; YES, EXIT
        JP      PROGRMLP        ; NO, LOOP
PROGRMEXIT:
        JP      SERIALCMDLOOP







;__DUMP__________________________________________________________________________________________________________________________
;
;	Print a Memory Dump, User option "D"
;________________________________________________________________________________________________________________________________
;
DUMP:
        INC     HL              ; SHOW READY
        PUSH    HL              ; STORE HL
        CALL    LDHL            ; GET START ADDRESS
        LD      D,H             ;
        LD      E,L             ;
        POP     HL              ;
        PUSH    DE              ; SAVE START
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
        CALL    LDHL            ; GET END ADDRESS
        INC     HL              ; ADD ONE MORE FOR LATER COMPARE
        EX      DE,HL           ; PUT END ADDRESS IN DE
        POP     HL              ; GET BACK START
GDATA:
        CALL    CRLF            ;
BLKRD:
        CALL    PHL             ; PRINT START LOCATION
        LD      C,16            ; SET FOR 16 LOCS
        PUSH    HL              ; SAVE STARTING HL
NXTONE:
        DB      $D9             ; EXX                     ;
        LD      C,E             ;
        DB      $ED,$78       	; IN	A,(C)			; GET DATA
        DB      $D9             ; EXX                     ;
        AND     7FH             ;
        CP      ESC             ;
        JP      Z,SERIALCMDLOOP ;
        CP      19              ;
        JR      Z,NXTONE        ;
        LD      A,(HL)          ; GET BYTE
        CALL    HXOUT           ; PRINT IT
        CALL    SPACE           ;
UPDH:
        INC     HL              ; POINT NEXT
        DEC     C               ; DEC. LOC COUNT
        JR      NZ,NXTONE       ; IF LINE NOT DONE
; NOW PRINT 'DECODED' DATA TO RIGHT OF DUMP
PCRLF:
        CALL    SPACE           ; SPACE IT
        LD      C,16            ; SET FOR 16 CHARS
        POP     HL              ; GET BACK START
PCRLF0:
        LD      A,(HL)          ; GET BYTE
        AND     060H            ; SEE IF A 'DOT'
        LD      A,(HL)          ; O.K. TO GET
        JR      NZ,PDOT         ;
DOT:
        LD      A,2EH           ; LOAD A DOT
PDOT:
        CALL    COUT            ; PRINT IT
        INC     HL              ;
        LD      A,D             ;
        CP      H               ;
        JR      NZ,UPDH1        ;
        LD      A,E             ;
        CP      L               ;
        JP      Z,SERIALCMDLOOP ;
;
;IF BLOCK NOT DUMPED, DO NEXT CHARACTER OR LINE
UPDH1:
        DEC     C               ; DEC. CHAR COUNT
        JR      NZ,PCRLF0       ; DO NEXT
CONTD:
        CALL    CRLF            ;
        JP      BLKRD           ;


;__HXLOAD__________________________________________________________________________________________________________________________
;
;	LOAD INTEL HEX FORMAT FILE FROM THE SERIAL PORT, User option "H"
;
;	 [INTEL HEX FORMAT IS:
;	 1) COLON (FRAME 0)
;	 2) RECORD LENGTH FIELD (FRAMES 1 AND 2)
;	 3) LOAD ADDRESS FIELD (FRAMES 3,4,5,6)
;	 4) RECORD TYPE FIELD (FRAMES 7 AND 8)
;	 5) DATA FIELD (FRAMES 9 TO 9+2*(RECORD LENGTH)-1
;	 6) CHECKSUM FIELD - SUM OF ALL BYTE VALUES FROM RECORD LENGTH TO AND
;	   INCLUDING CHECKSUM FIELD = 0 ]
;
; EXAMPLE OF INTEL HEX FORMAT FILE
; EACH LINE CONTAINS A CARRIAGE RETURN AS THE LAST CHARACTER
; :18F900002048454C4C4F20574F524C4420FF0D0AFF0D0A3EFF0D0A54BF
; :18F918006573742050726F746F7479706520524F4D204D6F6E69746FF1
; :18F9300072205265616479200D0AFF0D0A434F4D4D414E4420524543F2
; :18F948004549564544203AFF0D0A434845434B53554D204552524F52CD
; :16F96000FF0A0D20202D454E442D4F462D46494C452D20200A0DA4
; :00000001FF
;________________________________________________________________________________________________________________________________
HXLOAD:
        CALL    CRLF            ; SHOW READY
HXLOAD0:
        CALL    KIN             ; GET THE FIRST CHARACTER, EXPECTING A ':'
HXLOAD1:
        CP      $3A             ; IS IT COLON ':'? START OF LINE OF INTEL HEX FILE
        JR      NZ,HXLOADERR    ; IF NOT, MUST BE ERROR, ABORT ROUTINE
        LD      E,0             ; FIRST TWO CHARACTERS IS THE RECORD LENGTH FIELD
        CALL    HEXINS          ; GET US TWO CHARACTERS INTO BC, CONVERT IT TO A BYTE <A>
        CALL    HXCHKSUM        ; UPDATE HEX CHECK SUM
        LD      D,A             ; LOAD RECORD LENGTH COUNT INTO D
        CALL    HEXINS          ; GET NEXT TWO CHARACTERS, MEMORY LOAD ADDRESS <H>
        CALL    HXCHKSUM        ; UPDATE HEX CHECK SUM
        LD      H,A             ; PUT VALUE IN H REGISTER.
        CALL    HEXINS          ; GET NEXT TWO CHARACTERS, MEMORY LOAD ADDRESS <L>
        CALL    HXCHKSUM        ; UPDATE HEX CHECK SUM
        LD      L,A             ; PUT VALUE IN L REGISTER.
        CALL    HEXINS          ; GET NEXT TWO CHARACTERS, RECORD FIELD TYPE
        CALL    HXCHKSUM        ; UPDATE HEX CHECK SUM
        CP      $01             ; RECORD FIELD TYPE 00 IS DATA, 01 IS END OF FILE
        JR      NZ,HXLOAD2      ; MUST BE THE END OF THAT FILE
        CALL    HEXINS          ; GET NEXT TWO CHARACTERS, ASSEMBLE INTO BYTE
        CALL    HXCHKSUM        ; UPDATE HEX CHECK SUM
        LD      A,E             ; RECALL THE CHECKSUM BYTE
        AND     A               ; IS IT ZERO?
        JP      Z,HXLOADEXIT    ; MUST BE O.K., GO BACK FOR SOME MORE, ELSE
        JR      HXLOADERR       ; CHECKSUMS DON'T ADD UP, ERROR OUT
HXLOAD2:
        LD      A,D             ; RETRIEVE LINE CHARACTER COUNTER
        AND     A               ; ARE WE DONE WITH THIS LINE?
        JR      Z,HXLOAD3       ; GET TWO MORE ASCII CHARACTERS, BUILD A BYTE AND CHECKSUM
        CALL    HEXINS          ; GET NEXT TWO CHARS, CONVERT TO BYTE IN A, CHECKSUM IT
        CALL    HXCHKSUM        ; UPDATE HEX CHECK SUM
        LD      (HL),A          ; CHECKSUM OK, MOVE CONVERTED BYTE IN A TO MEMORY LOCATION
        INC     HL              ; INCREMENT POINTER TO NEXT MEMORY LOCATION
        DEC     D               ; DECREMENT LINE CHARACTER COUNTER
        JR      HXLOAD2         ; AND KEEP LOADING INTO MEMORY UNTIL LINE IS COMPLETE
HXLOAD3:
        CALL    HEXINS          ; GET TWO CHARS, BUILD BYTE AND CHECKSUM
        CALL    HXCHKSUM        ; UPDATE HEX CHECK SUM
        LD      A,E             ; CHECK THE CHECKSUM VALUE
        AND     A               ; IS IT ZERO?
        JR      Z,HXLOADAGAIN   ; IF THE CHECKSUM IS STILL OK, CONTINUE ON, ELSE
HXLOADERR:
        LD      HL,TXT_CKSUMERR ; GET "CHECKSUM ERROR" MESSAGE
        CALL    MSG             ; PRINT MESSAGE FROM (HL) AND TERMINATE THE LOAD
        JP      HXLOADEXIT      ; RETURN TO PROMPT
HXCHKSUM:
        LD      C,A             ; BUILD THE CHECKSUM
        LD      A,E             ;
        SUB     C               ; THE CHECKSUM SHOULD ALWAYS EQUAL ZERO WHEN CHECKED
        LD      E,A             ; SAVE THE CHECKSUM BACK WHERE IT CAME FROM
        LD      A,C             ; RETRIEVE THE BYTE AND GO BACK
        RET                     ; BACK TO CALLER
HXLOADAGAIN:
        CALL    KIN             ; CATCH THE TRAILING CARRIAGE RETURN
        JP      HXLOAD0         ; LOAD ANOTHER LINE OF DATA
HXLOADEXIT:
        CALL    KIN             ; CATCH ANY STRAY TRAILING CHARACTERS
        JP      SERIALCMDLOOP   ; RETURN TO PROMPT


;__MOVE__________________________________________________________________________________________________________________________
;
;	Move Memory, User option "M"
;________________________________________________________________________________________________________________________________
;
MOVE:
        LD      C,03
; start GETNM replacement
; get source starting memory location
        INC     HL              ; SHOW EXAMINE READY
        PUSH    HL              ;
        CALL    LDHL            ; LOAD IN HL REGS.
        LD      D,H             ;
        LD      E,L             ;
        POP     HL              ;
        PUSH    DE              ; push memory address on stack
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
        INC     HL              ; print space separator
        PUSH    HL              ;
        CALL    LDHL            ; LOAD IN HL REGS.
        LD      D,H             ;
        LD      E,L             ;
        POP     HL              ;
        PUSH    DE              ; push memory address on stack
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
        INC     HL              ; print space separator
        CALL    LDHL            ; LOAD IN HL REGS.
        PUSH    HL              ; push memory address on stack
; end GETNM replacement
        POP     DE              ; DEST
        POP     BC              ; SOURCE END
        POP     HL              ; SOURCE
        PUSH    HL              ;
        LD      A,L             ;
        CPL                     ;
        LD      L,A             ;
        LD      A,H             ;
        CPL                     ;
        LD      H,A             ;
        INC     HL              ;
        ADD     HL,BC           ;
        LD      C,L             ;
        LD      B,H             ;
        POP     HL              ;
        CALL    MOVE_LOOP       ;
        JP      SERIALCMDLOOP   ; EXIT MOVE COMMAND ROUTINE
MOVE_LOOP:
        LD      A,(HL)          ; FETCH
        LD      (DE),A          ; DEPOSIT
        INC     HL              ; BUMP  SOURCE
        INC     DE              ; BUMP DEST
        DEC     BC              ; DEC COUNT
        LD      A,C             ;
        OR      B               ;
        JP      NZ,MOVE_LOOP    ; TIL COUNT=0
        RET                     ;

;__FILL__________________________________________________________________________________________________________________________
;
;	Fill Memory, User option "M"
;________________________________________________________________________________________________________________________________
;
FILL:
        LD      C,03            ;
; start GETNM replacement
; get fill starting memory location
        INC     HL              ; SHOW EXAMINE READY
        PUSH    HL              ;
        CALL    LDHL            ; LOAD IN HL REGS.
        LD      D,H             ;
        LD      E,L             ;
        POP     HL              ;
        PUSH    DE              ; push memory address on stack
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
        INC     HL              ; print space separator
; get fill ending memory location
        PUSH    HL              ;
        CALL    LDHL            ; LOAD IN HL REGS.
        LD      D,H             ;
        LD      E,L             ;
        POP     HL              ;
        PUSH    DE              ; push memory address on stack
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
        INC     HL              ;
        INC     HL              ; print space separator
; get target starting memory location
        CALL    HEXIN           ; GET K.B. AND MAKE HEX
        LD      C,A             ; put fill value in F so it is saved for later
        PUSH    BC              ; push fill value byte on stack
; end GETNM replacement
        POP     BC              ; BYTE
        POP     DE              ; END
        POP     HL              ; START
        LD      (HL),C          ;
FILL_LOOP:
        LD      (HL),C          ;
        INC     HL              ;
        LD      A,E             ;
        SUB     L               ;
        LD      B,A             ;
        LD      A,D             ;
        SUB     H               ;
        OR      B               ;
        JP      NZ,FILL_LOOP    ;
        JP      SERIALCMDLOOP   ;

;
;__Init_UART_____________________________________________________________________________________________________________________
;
;	Initialize UART
;	Params:	SER_BAUD Needs to be set to Baud Rate
;	1200:	96	 = 1,843,200 / ( 16 x 1200 )
;	2400:	48	 = 1,843,200 / ( 16 x 2400 )
;	4800:	24	 = 1,843,200 / ( 16 x 4800 )
;	9600:	12	 = 1,843,200 / ( 16 x 9600 )
;	19K2:	06	 = 1,843,200 / ( 16 x 19,200 )
;	38K4:	03
;	57K6:	02
;	115K2:	01
;
;_________________________________________________________________________________________________________________________________
;
INIT_UART:
        LD      A,80H           ;
        OUT     (UART3),A       ; SET DLAB FLAG
        LD      A,(SER_BAUD)    ;
        OUT     (UART0),A       ;
        LD      A,00H           ;
        OUT     (UART1),A       ;
        LD      A,03H           ;
        OUT     (UART3),A       ; Set 8 bit data, 1 stopbit
        RET


;
;__FILL_MEM_______________________________________________________________________________________________________________________
;
;	Function	: fill memory with a value
;	Input		: HL = start address block
;			: BC = length of block
;			: A = value to fill with
;	Uses		: DE, BC
;	Output		:
;	calls		:
;	tested		: 13 Feb 2007
;_________________________________________________________________________________________________________________________________
;
FILL_MEM:
        LD      e,l             ;
        LD      d,h             ;
        INC     de              ;
        LD      (hl),A          ; initialise first byte of block with data byte in A
        LDIR                    ; fill memory
        RET                     ; return to caller

;
;__Initialize_____________________________________________________________________________________________________________________
;
;	Initialize System
;_________________________________________________________________________________________________________________________________
;
INITIALIZE:
        LD      A,12            ; specify baud rate 9600 bps (9600,8,None,1)
        LD      (SER_BAUD),A    ;
        CALL    INIT_UART       ; INIT the UART
        RET                     ; ADDED FOR TESTING (as .COM)
;



;
;__Work_Area___________________________________________________________________________________________________________________
;
;	Reserved Ram For Monitor working area
;_____________________________________________________________________________________________________________________________
;
SER_BAUD:
        DS      1               ; specify desired UART com rate in bps
KEYBUF:
        DB      "                                                                                "
DISPLAYBUF:
        DB      00,00,00,00,00,00,00,00
IDEDEVICE:
        DB      1               ; IDE DRIVE SELECT FLAG (00H=PRIAMRY, 10H = SECONDARY)
IDE_SECTOR_BUFFER:
        DS      $0200




;
;__Text_Strings_________________________________________________________________________________________________________________
;
;	System Text Strings
;_____________________________________________________________________________________________________________________________
;
TCRLF:
        DB      CR,LF,END

PROMPT:
        DB      CR,LF,'>',END

TXT_READY:
        DB      "      _                 _                   ",CR,LF
        DB      "   __| |_   _  ___   __| |_   _ _ __   ___  ",CR,LF
        DB      "  / _` | | | |/ _ \ / _` | | | | '_ \ / _ \ ",CR,LF
        DB      " | (_| | |_| | (_) | (_| | |_| | | | |  __/ ",CR,LF
        DB      "  \__,_|\__,_|\___/ \__,_|\__, |_| |_|\___| ",CR,LF
        DB      "                          |___/             ",CR,LF,CR,LF
        DB      CR,LF
        DB      "Monitor Ready "
        DB      CR,LF,END

TXT_COMMAND:
        DB      CR,LF
        DB      "UNKNOWN COMMAND."
        DB      END

TXT_CKSUMERR:
        DB      CR,LF
        DB      "CHECKSUM ERROR."
        DB      END
