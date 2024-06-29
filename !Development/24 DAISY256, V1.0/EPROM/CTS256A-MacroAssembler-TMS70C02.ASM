         PAGE 0         ; suppress page headings in ASW listing file
            
         cpu tms70C00   ; TMS7000 family

; Source modified for TMS70C02 serial port compatibility            

         ORG  0F000H

; Main entry point
START    MOV   %3AH,B
         LDSP              ; Init stack pointer 3B-XX
         MOVD  %2000H,R45  ; R45 := $2000
         MOVP  %0AAH,P0    ; P0 = IOCNT0 := 1010 1010, Full Expansion, Clear INT1, INT2 and INT3 flags
         MOVP  %0AH,P2     ; P2 = IOCNT1 := 0000 1010 Clear INT4 and INT5 flags
         MOVP  P4,B        ; Read P4 = APORT
         AND   %07H,B      ; Get Serial mode
         CMP   %00H,B      ; Is it Parallel mode ?

         ; Jump if yes
         JZ    PARALL      ; Start in parallel mode
         AND   %7FH,R10    ; Clear R10.7, indicating serial mode
         MOVP  P4,A        ; Read P4 = APORT
         AND   %08H,A      ; Get Selectable Serial Config flag
         CMP   %00H,A      ; Is it set ?
                           ; useful ?
         ; Jump if not
         JZ    SER7N2      ; Serial fixed 7N2 config
         LDA   @1000H      ; Read serial config from $1000
         MOVP  A,P20       ; Init P20 = SMODE with seria config
         JMP   SERSEL      ; Serial selectable config

SER7N2   MOVP  %0CBH,P20   ; P20 = SMODE := Fixed Serial 7N2 config
SERSEL   MOVP  %15H,P21    ; P21 = SCTL0 := 00001 0101 Reset error flags, enable RX & TX
                           ; A := value for SCTL1 (prescaler)
         LDA   @SCT1TB(B)  ; Table of values for SCTL1
         PUSH  A
         ; A := value for T3DATA (timer3 reload)
         LDA   @T3DATB(B)  ; Table of timer3 reload values T3DATA
         POP   B
         MOVP  B,P24       ; set SCTL1
         MOVP  A,P23       ; set T3DATA
         ORP   %01H,P2     ; enable INT4
         ; proceed with RAM setup
         JMP   INIRAM      ; Init RAM config

; Table of values for SCTL1
;SCT1TB   DB  0FFH,040H,043H,040H,043H,040H,041H,040H        ;  (2)  divide-by-2 CLK option
SCT1TB   DB  0FFH,0C0H,0C3H,0C0H,0C3H,0C0H,0C1H,0C0H        ;  (2)  divide-by-2 CLK option, MSB set to enable TIMER3

; Table of timer3 reload values T3DATA
T3DATB   DB  0FFH,040H,0B1H,00FH,0B1H,020H,081H,007H       ;  (4)  for a 2.5 Mhz internal CLK

; Start in parallel mode
PARALL   OR    %80H,R10    ; Set R10.7, indicating parallel mode
         MOVD  %0200H,R47  ; R47 := $0200 parallel input mapped address
         ORP   %30H,P0     ; P0 = IOCNT0, set .4=enable INT3, .5=clear INT3
                           ; Init RAM config
INIRAM   MOVP  P4,B        ; B := P4 = APORT
         AND   %10H,B      ; test APORT.4 = RAM buffer - 0=internal - 1=external
         CMP   %00H,B      ; useful ?
         ; jump if internal
         JZ    INTRAM      ; init internal RAM pointers
         
         MOVD  %3000H,R3   ; R2:3 := base RAM address = $3000
         MOVD  R3,R41      ; R40:41 := R2:3
         PUSH  R2
         DEC   R2
         MOV   R2,R34      ; R34:35 := R2:3 - 1 ($2FFF)
         MOV   %0FFH,R35
         ADD   %02H,R2     ; R2 += 2 ($31)
         CLR   R23         ; R23 := 0 (page counter)

LF076    INC   R2          ; ++R2
         CMP   %0F0H,R2    ; R2 == $F0 ($F000 reached) ?
         ; Exit loop if yes
         JZ    LF09B
         INC   R23         ; ++R23
         CMP   %10H,R23    ; R23 == $10 (16 pages) ?
         ; exit loop if yes
         JZ    LF09B
         MOV   %5AH,A      ; A := $5A (RAM test pattern)
         STA   *R3         ; *R2:3 := A
         CLR   A           ; A := 0 (useful?)
         LDA   *R3         ; A := *R2:3
         CMP   %5AH,A      ; A == $5A (test pattern) ?
         ; exit loop if not
         JNZ   LF09B
         SWAP  A           ; A := $A5 (reverse bits)
         STA   *R3         ; *R2:3 := A
         CLR   A           ; A := 0 (useful?)
         LDA   *R3         ; A := *R2:3
         CMP   %0A5H,A     ; A == $A5 (test pattern) ?
         ; exit loop if not
         JNZ   LF09B
         ; Test next RAM page
         JMP   LF076

LF09B    MOV   R2,R38      ; R38:39 := R2:$00 (end RAM addr + 1)
         CLR   R39
         SUB   %01H,R2     ; --R2 (why not DEC R2?)
         MOVD  R3,R7       ; R6:7 := R2:3 = last RAM page addr (output buffer read ptr)
         MOVD  R7,R43      ; R42:43 := R6:R7 (output buffer start)
         SUB   %01H,R2     ; --R2 (why not DEC R2?)
         MOV   R2,R36      ; R36:37 := R2:$FF (input buffer end)
         MOV   %0FFH,R37
         POP   R2          ; R2 := $30
         MOV   %0DFH,R50   ; R50 := $DF
         JMP   INIROM      ; Init EPROM

; init internal RAM pointers
INTRAM   MOVD  %0051H,R41  ; R40:41 := $0051 (input buffer start)
         MOVD  %0065H,R37  ; R36:37 := $0065 (input buffer end)
         MOVD  %0050H,R35  ; R34:35 := $0050 (input buffer start - 1)
         MOVD  %0066H,R43  ; R42:43 := $0066 (output buffer start)
         MOVD  %0080H,R39  ; R38:39 := $0080 (end RAM addr + 1)
         MOVD  R41,R3      ; R2:R3 := $0051 (input buffer read ptr)
         MOVD  R43,R7      ; R6:R7 := $0066 (output buffer read ptr)
         MOV   %01H,R50    ; R50 := $01

; Init EPROM
INIROM   MOVD  %0000H,R19  ; R18:19 := 0
LF0DA    CLR   B           ; B := 0 (5 signature bytes counter/index)
         ADD   %10H,R18    ; ++R18 (next page, starting at $1000)
         CMP   %0F0H,R18   ; $F0 reached ? (ending at $F000)
         ; Jump if yes
         JZ    INITOK      ; Done peripherals init
LF0E3    LDA   *R19        ; Read signature byte
         ; and compare it to the 5 first letters flags $80,$48,$28,$58,$85
         CMPA  @LTFLGS(B)  ; Letter flags
         ; next page if mismatch
         JNZ   LF0DA
         INC   B           ; next test byte
         CMP   %05H,B      ; done 5 bytes
         ; Exit if yes = EPROM found
         JZ    STAROM      ; Boot in EPROM
         INC   R19         ; next EPROM byte
         JMP   LF0E3       ; loop

; Boot in EPROM
STAROM   INC   R19         ; point to 1st byte following sig bytes
         MOVD  R19,R49     ; R48:49 := R18:19 = EPROM entry point
         BR    *R49        ; Boot in EPROM

; Done peripherals init
INITOK   MOV   %00H,R48    ; R48 := 0 (EPROM not present)
         CALL  @INIPTR     ; Init buffer pointers and regs
         CALL  @SAYOK      ; Say O.K.
         JMP   LF110

;==============================================================================
         ORG   0F105H
; Polling loop
POLL     BTJO  %01H,R11,LF110 ; test R11.0 = any delimiter; jump if yes
         AND   %0EFH,R11 ; reset R11.4 (found delimiter?)

; Idle loop (wait interrupt?)
WTIDLE   BTJZ  %10H,R11,WTIDLE; Idle loop (wait R11.4)
LF110    CMP   R3,R5 ; Input buffer read ptr LSB != write ptr LSB ?
         JNZ   ENDPOL   ; Exit polling loop if yes
         CMP   R2,R4 ; Idem for MSB ?
         JNZ   ENDPOL   ; Exit polling loop if yes
         JMP   POLL  ; Polling loop

; Exit polling loop
ENDPOL   CMP   %00H,R56 ; Chars in buffer MSB
         JNZ   LF126 ; exit ENDPOL loop if != 0
         CMP   %00H,R57 ; Chars in buffer LSB
         JZ    ENDPOL   ; loop if == 0

; Exit ENDPOL loop
LF126    BTJZ  %08H,R11,LF133 ; R11.3 == 1 (output buffer full or too high)? Jump if not
         CMP   %01H,R50 ; Internal RAM ?
         ; jump if yes
         JZ    CLBUF1   ; Clear buffers if yes

; wait reset of bit 3 of R11
W11B3    BTJO  %08H,R11,W11B3 ; wait reset of bit 3 of R11 (output buffer low enough)
LF133    CALL  @ENCODE  ; Encode text to allophones
         CMP   R7,R9 ; Output buffer empty ?
         JZ    LF110 ; jump to input buffer polling loop if yes
         ORP   %01H,P0  ; enable INT1* (SP0256) to send output
         JMP   LF110 ; jump to input buffer polling loop

; Clear buffers
CLBUF1   BR @CLBUF   ; clear buffers - reinit

;==============================================================================

; Init buffer pointers and regs
INIPTR   AND   %00H,R11 ; R11 := 0 (why not CLR R11?)
         CLR   R55   ; R55 := 0 (chars to free?)
         CLR   R56   ; R56 := 0
         CLR   R57   ; R57 := 0
         ORP   %01H,P6  ; set P6.0 (DSR/BUSY)
         MOVD  R41,R3   ; R2:3 := R40:41 (input buffer start)
         MOVD  R43,R7   ; R6:7 := R42:43 (output buffer start)
         MOV   %20H,A   ; A := $20
         STA   *R3   ; *R2:3 := $20 (input buffer read ptr)
         CALL  @INCR3   ; inc R2:3 and roll to R40:41 if == R42:43
         MOVD  R3,R5 ; R4:5 := R2:3 (input buffer write ptr)
         PUSH  R3 ; save pointers
         PUSH  R7
         PUSH  R6
         DEC   R3 ; R6:7 := ( R6:7 - R2:3 + 1 ) = input buffer size
         SUB   R3,R7
         SBB   R2,R6
         MOVD  R7,R52   ; R51:52 := input buffer size - 1
         DECD  R52
         TSTA     ; = CLR C
         RRC   R6 ; R6:7 /= 2
         RRC   R7
         MOVD  R7,R31   ; R30:31 := buffer size / 2 (and clears C)
         RRC   R6 ; R6:7 /= 2
         RRC   R7
         TSTA     ; = CLR C
         RRC   R6 ; R6:7 /= 2
         RRC   R7
         MOVD  R7,R33   ; R32:33 := buffer size / 8
         POP   R6 ; restore pointers
         POP   R7
         POP   R3
         MOVD  R7,R9 ; R8:9 := R6:7 = output buffer write ptr
         MOVD  R3,R25   ; R24:25 last delimiter ptr := R2:3 input buffer read ptr
         MOVD  R39,R54  ; R53:54 := R38:39 = end RAM address + 1
         SUB   R43,R54  ; R53:54 := ( R53:54 - R42:43 ) = output buffer size
         SBB   R42,R53
         MOVP  P4,B  ; B := APORT
         AND   %80H,B   ; APORT.7 set ? (Delimiter=any)
         CMP   %00H,B   ; useful ?
         ; Jump if not
         JZ    LF1A6
         OR    %01H,R11 ; R11.0 := 1 if any delimiter
LF1A6    EINT     ; enable interrupts
         RETS

;==============================================================================

; "O-K\n"
STROK    DB  "O-K"
         DB  0DH

; Say O.K.
SAYOK    AND   %0F9H,R10 ; Clear R10.1 and R10.2: Write to input buffer
         CLR   B
LF1B0    LDA   @STROK(B); Get char
         CALL  @STINPB  ; Store char in input buffer
         INC   B  ; next char
         CMP   %04H,B   ; loop until 4 chars processed
         JNZ   LF1B0
         RETS     ; return

;==============================================================================

; INT4 handler (serial interrupt)
INT4     BTJOP %02H,P22,INT3  ; Jump if P22.1 (RXRDY) == 1
         RETI     ; else return from interrupt

; INT3 handler (parallel interrupt)
INT3     PUSH  A  ; save A from interrupt
         BTJO  %80H,R10,LF1D1 ; R10.7 (parallel mode) == 1 ? Jump if yes
         ANDP  %0FEH,P2  ; Reset P2.0 (disable serial INT4)
; wait RXBUF ready with new character
WRXRDY   BTJZP %02H,P22,WRXRDY; wait RXBUF ready with new character
         MOVP  P25,A ; get A := RXBUF incoming character
         JMP   LF1D6 ; handle incoming char in A

; Parallel mode
LF1D1    ANDP  %0EFH,P0  ; Disable P0.0 = INT3*
         LDA   *R47  ; Read char from parallel input ($0200)

; Handle incoming char
LF1D6    CALL  @STINPB  ; Store char in input buffer
         POP   A  ; restore A from interrupt
         BTJO  %20H,R11,LF1E1 ; R11.5 == 1 ? (input buffer full) skip next instr if yes
         CALL  @ENINT   ; re-enable parallel or serial interrupt
LF1E1    RETI     ; return from interrupt

;==============================================================================

; Store char in input buffer
STINPB   PUSH  B  ; Save registers
         PUSH  R10
         PUSH  R12
         PUSH  R13
         AND   %0F9H,R10 ; reset R10.1 and R10.2: write to input buffer
         CMP   %1BH,A   ; <ESC ? = clear buffers
         JNZ   NOTESC   ; Skip if not

; clear buffers - reinit
CLBUF    ANDP  %0FEH,P0  ; Disable INT1* (SP0256)
         CALL  @INIPTR  ; Init buffer pointers and regs
         MOV   %3AH,B   ; Init SP
         LDSP     ;
         MOVD  R45,R27  ; R26:27 := R44:45 (??)
         STA   *R27  ; *R26:27 := A (??)
         CALL  @ENINT   ; Enable input interrupt (parallel or serial)
         BR    @POLL ; Polling loop

; Not <ESC
NOTESC   CMP   %12H,A   ; <Ctrl-R ? = backspace until last delimiter
         JNZ   NOTCTR   ; Skip if not

; Handle <Ctrl-R
         BTJO  %01,R11,LF21E ; R11.0 == 1 (any delimiter) ? Exit if yes
         SUB   R25,R3   ; R2:3 (input buf read ptr) -= R24:25 (last delimiter)
         SBB   R24,R2   ;  (may not work correctly if rolled...)
         SUB   R3,R52   ; R51:52 (input buffer free size) -= R2:3
         SBB   R2,R51
         MOVD  R25,R3   ; R2:3 := R24:25 (last delimiter position)
         MOV   %01H,R57 ; input buffer counter LSB(why?) := 1
LF21E    BR    @XSTINP  ; exit handler

; Not <Ctrl-R
NOTCTR   CMP   %08H,A   ; <BkSp ?
         JNZ   NOTBKS   ; Skip if not

; Handle <BkSp
         CMP   R2,R4 ; Input buffer pointers equal ?
         JNZ   LF22F
         CMP   R3,R5
         JZ    XSTINP   ; If yes, exit handler
LF22F    PUSH  R3 ; Save R2:3
         PUSH  R2
         MOVD  R5,R3 ; R2:3 := R4:5 input buffer write ptr
         CALL  @DECR3   ; dec R2:3 and roll if needed
         MOVD  R3,R5 ; R4:5 := R2:3
         POP   R2 ; restore R2:3
         POP   R3
         INC   R52   ; Inc R51:52 input buffer free size
         JNC   XSTINP
         INC   R51
         JMP   XSTINP   ; exit handler

; Not <BkSp: Handle other chars
NOTBKS   CMP   %27H,A   ; ''' ?
         JZ    STOCHR   ; Jump if yes
         CMP   %7BH,A   ; higher than 'z' ?
         JP    DELIMT   ; Jump if yes
         CMP   %30H,A   ; '0'..'9' ?
         JN    DELIMT
         CMP   %3AH,A
         JN    STOCHR
         CMP   %41H,A   ; = 'A' ?
         JPZ   STOCHR

; Delimiter (not letter/digit/')
DELIMT   BTJO  %01H,R11,LF267 ; R11.0 set (any delimiter) ? Jump if yes
         CMP   %0DH,A   ; <CR ?
         JNZ   LF26A ; skip if not
         OR    %10H,R11 ; R11.4 := 1 (found CR = exit idle loop)
LF267    MOVD  R3,R25   ; R24:25 := R2:3 (last delimiter position)
LF26A    OR    %80H,A   ; A.7 := 1 (set high bit)
         INC   R57   ; Increment R56:57 (# of bytes in input buffer)
         JNC   STOCHR
         INC   R56

; put char in buffer
STOCHR   CALL  @RWBUFR  ; write char in buffer
         BTJZ  %20H,R11,XSTINP; R11.5 set (inp buffer full)? if not exit handler
         MOV   %8DH,A   ; A := <CR + $80
         INC   R57   ; Increment R56:57 (# of bytes in input buffer)
         JNC   LF281
         INC   R56
LF281    CALL  @RWBUFR  ; write char in buffer
; exit handler
XSTINP   POP   R13   ; Restore registers
         POP   R12
         POP   R10
         POP   B
         RETS     ; end of input char handling

;==============================================================================

; R10:7 ? (enable INT3) : (enable INT4)
ENINT    BTJZ  %80H,R10,ENINT4; enable INT4
         ORP   %10H,P0
         RETS

; enable INT4
ENINT4   ORP   %01H,P2
         RETS

;==============================================================================

      ; select input or output buffer and read/store byte in it
RWBUFR   BTJO  %02H,R10,RDBUF ; R10.1 set ? Jump if yes (read from either buffer)

      ; write to input or output buffer
         BTJO  %04H,R10,WROBUF; R10.2 set ? Jump if yes (output buffer)
         MOVD  R5,R13   ; R12:13 := R4:5 input buffer write ptr
         DECD  R52   ; Decrement # of free input buffer bytes
         JMP   WRBUF ; Store A in buffer

WROBUF   MOVD  R9,R13   ; R12:13 := R8:9 output buffer write ptr
         DECD  R54   ; Decr output buffer free size

         ; Store byte A in buffer
WRBUF    STA   *R13  ; *R12:13 := A (store byte in buffer)
         LDA   @000DH   ; A := R13 (why using LDA?)
         ADD   %01H,R13 ; Increment R12:13
         ADC   %00H,R12
         CALL  @ROLR13  ; Roll R12:13 if needed
         BTJO  %04H,R10,WOBUFX; R10.2 set ? Jump if yes (output buffer)
         MOVD  R13,R5   ; R4:5 := R12:13 (inp buffer write ptr)
WRBUFX   CALL  @CHKBUF  ; Check if inp or out buffer full or above HWM
         RETS     ; return

WOBUFX   MOVD  R13,R9   ; R8:9 := R12:13 (out buffer write ptr)
         JMP   WRBUFX   ; Check buffer and return

         ; read from input or output buffer
RDBUF    BTJO  %04H,R10,RDOBUF; R10.2 set ? jump if yes (output buffer)

         ; read from input buffer
         MOVD  R3,R13   ; R12:13 := R2:3 input buffer read ptr
         BTJO  %02H,R11,RDBUF1; R11.1 set ? Jump if yes
         INC   R55   ; inc R55 if not... (Free bytes? TODO: clarify)
         JMP   RDBUF1   ; Read byte

         ; read from output buffer
RDOBUF   MOVD  R7,R13   ; R12:13 := R6:7 out buffer read ptr
         INC   R54   ; Inc R53:54 = Out free bytes? (TODO: clarify)
         JNC   RDBUF1
         INC   R53

         ; Read DB from buffer
RDBUF1   LDA   *R13  ; Read byte
         BTJO  %04H,R10,LF2F3 ; R10.2 set ? jump if yes (out buffer)
      
         BTJZ  %80H,A,LF2F0; Is high bit set ? Jump if not
         OR    %01H,R10 ; R10.0 := A.7 = char high bit
         JMP   LF2F3

LF2F0    AND   %0FEH,R10

         ; Incr buffer read pointer
LF2F3    PUSH  A
         LDA   @000DH   ; A := R13 (why?)
         ADD   %01H,R13 ; increment R12:13
         ADC   %00H,R12
         CALL  @ROLR13  ; Roll if needed
         BTJO  %04H,R10,ROBUFX; jump if output buffer

         ; update input buffer read ptr
         MOVD  R13,R3   ; R2:3 := R12:13
         POP   A  ; restore character
         RETS     ; return

         ; update output buffer read ptr
ROBUFX   MOVD  R13,R7   ; R6:7 := R12:13
         CALL  @CKOBUF  ; Check if output buffer full or above HWM
         POP   A  ; restore allophone
         RETS

;==============================================================================
; Roll R12:R13 according to active buffer (R10.2)
; - if R10.2 set (output buffer active):
;  to R42:43 (out buffer start) if reached R38:39 (out buffer end)
; - if R10.2 not set (input buffer active):
;  to R40:41 (in buffer start)  if reached R42:43 (in buffer end)
ROLR13   BTJO  %04H,R10,ROLOUT; Roll output buffer
         ; Roll input buffer
ROLINP   CMP   R43,R13
         JNZ   LF322
         CMP   R42,R12
         JNZ   LF322
         MOVD  R41,R13
LF322    RETS

         ; Roll output buffer
ROLOUT   CMP   R39,R13
         JNZ   LF330
         CMP   R38,R12
         JNZ   LF330
         MOVD  R43,R13
LF330    RETS

;==============================================================================

         ; Check if inp or out buffer full or above HWM
CHKBUF   BTJZ  %04H,R10,CKIBUF; Send XON/XOFF if needed

         ; Check if output buffer full or above high water mark
CKOBUF   CMP   %01H,R53 ; Only 1 free bytes in output buffer ?
         JZ    LF343 ; jump if yes
         CMP   R50,R54  ; R54R50 ? (output counter = HWM ?)
         JP    LF343 ; jump if yes
         OR    %08H,R11 ; set R11.3 (output buffer full)
         RETS

LF343    AND   %0F7H,R11 ; reset R11.3 (output buffer not full)
         RETS

         ; Check if input buffer full or above high water mark
CKIBUF   CMP   %00H,R51 ; Free bytes in input buffer ?
         JP    LF356 ; jump if yes
         CMP   %01H,R52
         JP    LF356
         OR    %20H,R11 ; set R11.5 (input buffer full)
         JMP   TXOFF ; Send XOFF, clear DTR/BUSY*

         ; Input buffer not full
LF356    CMP   R30,R51  ; R50:51 inp buf free bytes < 1/2 size ?
         JN    LF362 ; Jump if yes
         JP    TXON  ; Else send XON, set DTR/BUSY*
         CMP   R31,R52
         JPZ   TXON
LF362    CMP   R32,R51  ; R50:51 inp buf free bytes < 1/8 size ?
         JP    LF384 ; Jump if not
         JN    LF36E ; Else Send XOFF, clear DTR/BUSY*
         CMP   R33,R52
         JP    LF384

LF36E    OR    %04H,R11 ; set R11.2: input buffer above HWM

         ; Send XOFF, clear DTR/BUSY*
TXOFF    ANDP  %0FEH,P6  ; clear P6.0 (DSR/BUSY=true)
         MOVP  %13H,P26 ; TXBUF := XOFF
         RETS

         ; Send XON, set DTR/BUSY*
TXON     AND   %0DBH,R11
         CALL  @ENINT   ; R10:7 = parallel mode ? (enable INT3) : (enable INT4)
         ORP   %01H,P6  ; set P6.0 (DSR/BUSY=false)
         MOVP  %11H,P26 ; TXBUF := XON
LF384    RETS     ; Return

;==============================================================================

; INT1 handler (SP0256)
INT1     ANDP  %0FEH,P0  ; Disable P0.0 = INT1*
         PUSH  A  ; save regs
         PUSH  B
         PUSH  R10
         PUSH  R12
         PUSH  R13
         OR    %06H,R10 ; select "read from output buffer"
         CALL  @RWBUFR  ; do the read
         MOVD  R45,R27  ; R26:27:= R44:45 SP0256 base address
         ADD   R0,R27   ; Add allophone code to the address
         STA   *R27  ; Write byte to that address (value doesn't care)
         POP   R13   ; restore regs
         POP   R12
         POP   R10
         POP   B
         POP   A
         CMP   R7,R9 ; Buffer empty ?
         JZ    LF3AE ; skip if yes
         ORP   %01H,P0  ; else enable P0.0 = INT1*
LF3AE    RETI     ; return from interrupt

;==============================================================================

; select rules set
SELRUL   CMP   %30H,A
         JPZ   LF3B5
         JMP   LF3DF

LF3B5    CMP   %3AH,A
         JPZ   LF3C1
         MOVD  %RULNUM,R21 ; Rules for digits
         AND   %0DFH,R10 ; Non-letters rules
         RETS

LF3C1    CMP   %41H,A
         JPZ   LF3C7
         JMP   LF3DF

LF3C7    CMP   %5BH,A
         JPZ   LF3CF
         OR    %20H,R10 ; Letters rules
         RETS

LF3CF    CMP   %61H,A
         JPZ   LF3D5
         JMP   LF3DF

LF3D5    CMP   %7BH,A
         JPZ   LF3DF
         SUB   %20H,A
         OR    %20H,R10 ; Letters rules
         RETS

LF3DF    AND   %0DFH,R10 ; Non-letters rules
         MOVD  %RLPNCT,R21 ; Rules for punctuation
         RETS

;==============================================================================

; Encode text to allophones
ENCODE   CMP   %00H,R48 ; EPROM active ?
         ; Skip if not
         JZ    LF3EE
         BR    *R49  ; Jump in EPROM

LF3EE    MOVD  R3,R17   ; R16:17 := R2:3 (backward input buffer read ptr)
         CALL  @DECR17  ; dec R16:17 and roll if needed
LF3F4    CALL  @FETCH   ; Fetch char and mask high bit
         BTJZ  %01H,R10,LF400 ; R11.7 := R10.0 (character high bit)
         OR    %80H,R11
         JMP   LF403

LF400    AND   %7FH,R11
LF403    CALL  @SELRUL  ; select rules set
         BTJZ  %20H,R10,LF41B ; R10.5 set (rules for letters) ? jump if no

         CLR   B  ; useful?
         SUB   %41H,A   ; A -= 'A'
         MPY   %02H,A   ; AB := A * 2
         ADD   %02H,B   ; B += 2
         LDA   @TABRUL(B)  ; Index of rules tables
         MOV   A,R20 ; R20 := MSB of letter rules table
         LDA   @TABRU1(B)  ; Index of rules tables LSB
         MOV   A,R21 ; R22 := LSB of letter rules table

LF41B    MOV   %01H,B   ; B := 1 (number of '[') to seek
         CALL  @RSEEKB  ; right seek 1st '['

; Compare chars between [ ]
LF420    CALL  @CMPBKT  ; compare in-brackets
         BTJO  %10H,R10,LF467 ; R10.4 set (match failed) ? Jump if yes

         ; Check patterns after ]
         MOVD  R17,R29  ; R28:29 := R16:17 (save backward input buffer read ptr)
         AND   %0BFH,R10 ; clear R10.6 (read input using R2:3)
         CALL  @CHKPAT  ; Check rule pattern
         BTJO  %10H,R10,LF467 ; R10.4 set (match failed) ? Jump if yes

         ; Check patterns before [
         CALL  @LSEEKB  ; left seek '['
         OR    %40H,R10 ; set R10.6 (read input using R16:17)
         CALL  @CHKPAT  ; Check rule pattern
         BTJO  %10H,R10,LF47A ; R10.4 set (match failed) ? Jump if yes

         ; Matching Rule found
         ADD   R55,R52  ; R51:52 += R55 (free preceding chars?)
         ADC   %00H,R51
         CLR   R55   ; no more chars to free

         ; Seek allophones to output
         AND   %0FDH,R11 ; clear R11.1 (allow to count chars to free in R55)
         MOV   %02H,B   ; B := 2 (number of '[') to seek
         CALL  @RSEEKB  ; right seek 2nd '[' = 1st allophone

         ; Write allophones
         CALL  @WRALLO  ; Write allophones

         ; Next input character
         MOVD  R15,R3   ; R2:3 := R14:15 - restore input buffer read ptr
         MOVD  R3,R17   ; R16:17 := R2:3 - copy to backward input buffer read ptr
         CALL  @DECR17  ; dec R16:17 and roll to R36:37 if == R34:35
         BTJZ  %80H,R11,LF3F4 ; High bit of char was set (final?) ? Jump if not

         ; Finalize and return
         DECD  R57   ; dec R56:57 (number of bytes in input buffer?)
         CALL  @CKIBUF  ; Check if input buffer full or above high water mark
         RETS     ; return

         ; Match failed after opening [ = seek next rule
LF467    INC   R21   ; inc R20:21 rule pointer
         JNC   LF46D
         INC   R20
LF46D    MOV   %02H,B   ; B := 2 (number of '[') to seek

         ; Seek next rule opening [
LF46F    CALL  @RSEEKB  ; right seek 2nd or 3rd '[' = next pattern '['
         MOV   %01H,R55 ; R55 := 1 (one char to free?)
         AND   %0FDH,R11 ; clear R11.1 (allow to count chars to free in R55)
         JMP   LF420 ; check next rule
      
         ; Match failed before opening [ = seek next rule
LF47A    MOV   %03H,B   ; B := 3 (number of '[') to seek
         JMP   LF46F ; right seek 3rd '[' and check next rule

;==============================================================================

         ; left seek '['
LSEEKB   LDA   *R21  ; A := *R20:21
         BTJZ  %40H,A,LF484; A.6 set ('[' found) ? jump if not
         RETS     ; else return

LF484    DECD  R21   ; dec R20:21
         JMP   LSEEKB   ; and loop

;==============================================================================

         ; right seek Bth '['
RSEEKB   CLR   R23   ; R23 := 0

LF48A    LDA   *R21  ; A := *R20:21
         BTJZ  %40H,A,LF496; A.6 set ('[' found) ? jump if not
         INC   R23   ; inc R23
         CMP   R23,B ; jump if R23 != B
         JNZ   LF496
         RETS     ; else return: found

LF496    INC   R21   ; inc R20:21
         JNC   LF49C
         INC   R20
LF49C    JMP   LF48A ; and loop

;==============================================================================

         ; Write allophones
WRALLO   CLR   R23   ; R23 := 0
         LDA   *R21  ; A := *R20:21
         CMP   %0FFH,A   ; A == $FF ?
         JZ    LF4C1 ; jump if yes
         BTJZ  %80H,A,LF4AB; A.7 set (']' found) ? jump if not
         INC   R23   ; else inc R23
LF4AB    AND   %3FH,A   ; mask A.6 and A.7
         AND   %0FDH,R10 ; clear R10.1 (write in buffer)
         OR    %04H,R10 ; set R10.2 (output buffer)
         CALL  @RWBUFR  ; write allophone in buffer
         INC   R21   ; inc R20:21
         JNC   LF4BC
         INC   R20
LF4BC    CMP   %01H,R23 ; ']' found ?
         JNZ   WRALLO   ; loop if not
LF4C1    RETS     ; else return

;==============================================================================

; compare in-brackets
CMPBKT   MOVD  R3,R19   ; R18:19 := R2:3 (input read ptr)
         AND   %0F7H,R10 ; clear R10.3
         BTJZ  %20H,R10,LF4D4 ; R10.5 letter rules? jump if not
         LDA   *R21  ; A := *R20:21
         CMP   %0FFH,A   ; A == $FF ? (single letter/end of rules)
         JNZ   LF4DD ; jump if not to letter rules
         JMP   LF502 ; else exit (success)

         ; not letter rules
LF4D4    CMP   %0FFH,A   ; A == $FF ?
         JZ    LF502 ; exit if yes (success)
         CALL  @DECR3   ; dec R2:3 and roll if needed
         DEC   R55   ; dec R55 (chars to free?)

         ; letter rules
LF4DD    CALL  @FETCH   ; Fetch char and mask high bit
         CMP   %61H,A   ; lower case ?
         JN    LF4E6 ; skip if not
         SUB   %20H,A   ; else adjust to upper case
LF4E6    SUB   %20H,A   ; adjust to range 00-3F
         MOV   A,B   ; B := A
         LDA   *R21  ; A := *R20:21
         BTJZ  %80H,A,LF4F1; A.7 set (']' found) ? Skip if not
         OR    %08H,R10 ; else set R10.3
LF4F1    AND   %3FH,A   ; mask A.6 and A.7
         CMP   R0,B  ; A == B ?
         JZ    LF4FE ; jump if yes
         OR    %10H,R10 ; set R10.4: pattern match failed
         MOVD  R19,R3   ; R2:3 := R18:19
         RETS     ; return (failed)

LF4FE    BTJZ  %08H,R10,LF50C ; R10.3 set (']' found) ? Jump if not

         ; pattern match successful
LF502    MOVD  R3,R15   ; R14:15 := R2:3 - save input buffer read ptr
         AND   %0EFH,R10 ; clear R10.4: pattern match successful
         OR    %02H,R11 ; set R11.1 - forbid to count chars to free in R55 ?
         RETS     ; return

LF50C    INC   R21   ; inc R20:21
         JNC   LF4DD
         INC   R20
         JMP   LF4DD ; and loop: check next char

;==============================================================================

; Get letter flags
GFLAGS   MOV   R22,B
         CMP   %3AH,B
         JP    GFLAGX
         CMP   %21H,B
         JN    GFLAGX
         SUB   %21H,B
         LDA   @LTFLGS(B)  ; Letter flags
         RETS

GFLAGX   CLR   A
         RETS

; Letter flags
; ------------
; 7(80): Vowel
; 6(40): Voiced consonant
; 5(20): Sibilant
; 4(10): Preceding long U
; 3(08): Consonant
; 2(04): Front vowel
; 1(02): Back vowel
; 0(01): Suffix ('E')
LTFLGS   DB  80H   ; A 1000 0000 - EPROM sig check begin
         DB  48H   ; B 0100 1000
         DB  28H   ; C 0010 1000
         DB  58H   ; D 0101 1000
         DB  85H   ; E 1000 0101 - EPROM sig check end
         DB  08H   ; F 0000 1000
         DB  68H   ; G 0110 1000
         DB  08H   ; H 0000 1000
         DB  84H   ; I 1000 0100
         DB  78H   ; J 0111 1000
         DB  08H   ; K 0000 1000
         DB  58H   ; L 0101 1000
         DB  48H   ; M 0100 1000
         DB  58H   ; N 0101 1000
         DB  82H   ; O 1000 0010
         DB  08H   ; P 0000 1000
         DB  08H   ; Q 0000 1000
         DB  58H   ; R 0101 1000
         DB  38H   ; S 0011 1000
         DB  18H   ; T 0001 1000
         DB  82H   ; U 1000 0010
         DB  48H   ; V 0100 1000
         DB  48H   ; W 0100 1000
         DB  28H   ; X 0010 1000
         DB  84H   ; Y 1000 0100
         DB  78H   ; Z 0111 1000

;==============================================================================

; Pattern jump table
PATBRT   BR @PATVOW  ; #   09 1+ vowels
         BR @PATVOC  ; .   0A voiced consonant: B D G J L M N R V W X
         BR @PATSUF  ; %   0B suffix: -ER(S) -E -ES -ED -ELY -ING -OR -MENT
         BR @PATSIB  ; &   0C sibilant: S C G Z X J CH SH
         BR @PATPLU  ; @   0D T S R D L Z N J TH CH SH preceding long U
         BR @PAT1CO  ; ^   0E 1 consonant only
         BR @PATFVO  ; +   0F front vowel: E I Y
         BR @PAT0MC  ; :   10 0+ consonants
         BR @PAT1MC  ; *   11 1+ consonants
         BR @PATBVO  ;    12 back vowel: O U
         BR @PATNLT  ; <   13 Anything other than a letter
         BR @PAT2MV  ; ?   14 2+ vowels

;==============================================================================

; Check rule pattern
CHKPAT   BTJO  %40H,R10,LF572 ; R10.6 set (scan direction left) ? jump if yes
         MOV   %40H,B   ; '[' mask
         INC   R21   ; inc R20:21 rule ptr
         JNC   LF570
         INC   R20
LF570    JMP   LF576 ; proceed

LF572    MOV   %80H,B   ; ']' mask
         DECD  R21   ; dec R20:21 rule ptr

; check if boundary has been reached
LF576    LDA   *R21  ; get rule char
         BTJZ  B,A,LF58C; is '[' or ']' ? jump if not
         BTJO  %40H,R10,LF582 ; R10.6 set (scan direction left) ? jump if yes
         DECD  R21   ; dec R20:21 rule ptr
         JMP   LF588

LF582    INC   R21   ; inc R20:21 rule ptr
         JNC   LF588
         INC   R20
LF588    AND   %0EFH,R10 ; clear R10.4 rule pattern match failed
         RETS     ; return

; check rule char
LF58C    CALL  @GNEXT   ; get next input char and move code to range 00-3F
         LDA   *R21  ; A := *R20:21 - load rule char
         CMP   %15H,A   ; A < $15 ? (pattern symbol)
         JN    LF5A4 ; jump if yes
LF595    CMP   R0,R22   ; otherwise compare input char with rule char
         JZ    CHKPAT   ; continue with next char if both chars match

; pattern match failed
PATFLD   OR    %10H,R10 ; set R10.4 - match failed
         MOVD  R19,R3   ; R2:3 := R18:19 - restore input ptr
         MOVD  R29,R17  ; R16:17 := R28:29 - restore backward input ptr
         RETS     ; return (failed)

; check rule pattern symbol
LF5A4    CMP   %07H,A   ; is a "'" ?
         JZ    LF595 ; jump if yes
; compute pattern symbol handler address
         MOV   A,B   ; B := A
         SUB   %09H,B   ; B -= 9
         MPY   %03H,B   ; B *= 3
         BR    @PATBRT(B)  ; Branch to PATBRT + B

; <   13 Anything other than a letter
PATNLT   CALL  @GFLAGS  ; Get letter flags
         CMP   %00H,A   ; Is a letter ?
         JZ    PATOK1   ; Accept if yes
         JMP   PATFLD   ; else pattern match failed

; *   11 1+ consonants
PAT1MC   CALL  @GFLAGS  ; Get letter flags
         BTJO  %08H,A,LF5C1; Is a consonant ? Jump if yes
         JMP   PATFLD   ; else pattern match failed

LF5C1    CALL  @GNEXT   ; get next char and move code to range 00-3F
         CALL  @GFLAGS  ; Get letter flags
         BTJO  %08H,A,LF5C1; Is a consonant ? Loop until not
         JMP   LF5FB ; Unget and Accept rule

; ?   14 2+ vowels
PAT2MV   CALL  @GFLAGS  ; Get letter flags
         BTJO  %80H,A,LF5D4; Vowel flag ? Jump if yes
         JMP   PATFLD   ; pattern match failed
      
LF5D4    CALL  @GNEXT   ; get next char and move code to range 00-3F
         CALL  @GFLAGS  ; Get letter flags
         BTJO  %80H,A,LF5DF; Vowel flag ? Jump if yes
         JMP   PATFLD   ; pattern match failed

LF5DF    CALL  @GNEXT   ; get next char and move code to range 00-3F
         CALL  @GFLAGS  ; Get letter flags
         BTJO  %80H,A,LF5DF; Vowel flag ? Loop until not
         JMP   LF5FB ; Unget and accept rule

; :   10 0+ consonants
PAT0MC   CALL  @GFLAGS  ; Get letter flags
         BTJO  %08H,A,LF5F2; Consonant ? Jump if yes
         JMP   LF5FB ; else unget and accept rule

LF5F2    CALL  @GNEXT   ; get next char and move code to range 00-3F
         CALL  @GFLAGS  ; Get letter flags
         BTJO  %08H,A,LF5F2; Is a consonant ? Loop until not

; Unget and accept rule
LF5FB    CALL  @UNGET   ; Unget last input character

; pattern match ok
PATOK1   BR  @CHKPAT  ; Check next rule pattern

; %   0B suffix: -ER(S) -E -ES -ED -ELY -ING -OR -MENT
PATSUF   CALL  @GFLAGS  ; Get letter flags
         BTJO  %01H,A,LF657; Suffix flag ('E') ? Jump if yes
         CMP   %29H,R22 ; 'I' ?
         JZ    LF63C ; Jump if yes
         CMP   %2DH,R22 ; 'M' ?
         JZ    LF618 ; Jump if yes
         CMP   %2FH,R22 ; 'O' ?
         JZ    LF633 ; jump if yes
         JMP   PATFL1   ; pattern match failed

; found 'M'
LF618    CALL  @FETCH   ; Fetch char and mask high bit
         CMP   %45H,A   ; 'E' ?
         JZ    LF621 ; jump if yes
         JMP   PATFL1   ; pattern match failed

; found 'ME'
LF621    CALL  @FETCH   ; Fetch char and mask high bit
         CMP   %4EH,A   ; 'N' ?
         JZ    LF62A ; jump if yes
         JMP   PATFL1   ; pattern match failed

; found 'MEN'
LF62A    CALL  @FETCH   ; Fetch char and mask high bit
         CMP   %54H,A   ; 'T'
         JZ    LF64E ; jump if yes, suffix -MENT found
         JMP   PATFL1   ; pattern match failed

; Found 'O'
LF633    CALL  @FETCH   ; Fetch char and mask high bit
         CMP   %52H,A   ; 'R' ?
         JZ    LF64E ; jump if yes, suffix -OR found
         JMP   PATFL1   ; pattern match failed

; Found 'I'
LF63C    CALL  @FETCH   ; Fetch char and mask high bit
         CMP   %4EH,A   ; 'N' ?
         JZ    LF645 ; jump if yes
         JMP   PATFL1   ; pattern match failed

; found 'IN'
LF645    CALL  @FETCH   ; Fetch char and mask high bit
         CMP   %47H,A   ; 'G' ?
         JZ    LF64E ; jump if yes, suffix -ING found
         JMP   PATFL1   ; pattern match failed

; Suffix found
LF64E    CALL  @CHKLTR  ; Check if next input char is a letter
         BTJO  %20H,R10,PATFL1; pattern match failed
         JMP   PATOK2   ; Accept rule

; found 'E'
LF657    CALL  @FETCH   ; Fetch char and mask high bit
         CMP   %52H,A   ; 'R' ?
         JNZ   LF66A ; jump if not
         CALL  @FETCH   ; Fetch char and mask high bit
         CMP   %53H,A   ; 'S' ? (optional plural)
         JZ    LF64E ; jump if yes, suffix -ERS found
         CALL  @DECR3   ; dec R2:3 and roll if needed
         JMP   LF64E ; suffix -ER found

LF66A    CMP   %53H,A   ; 'S'
         JZ    LF64E ; jump if yes, suffix -ES found
         CMP   %44H,A   ; 'D'
         JZ    LF64E ; jump if yes, suffix -ED found
         CMP   %4CH,A   ; 'L'
         JZ    LF682 ; jump if yes
         CALL  @DECR3   ; dec R2:3 and roll if needed
         ; suffix -E found
         CALL  @CHKLTR  ; Check if next input char is a letter
         BTJZ  %20H,R10,PATOK2; Jump if R10.5 unset (not a letter = OK)
         JMP   PATFL1   ; pattern match failed

; found 'EL'
LF682    CALL  @FETCH   ; Fetch char and mask high bit
         CMP   %59H,A   ; 'Y' ?
         JZ    LF64E ; jump if yes, suffix -ELY found

; pattern match failed
PATFL1   BR    @PATFLD  ; pattern match failed

; Test if next input char is a letter, R10.5=1 if yes
CHKLTR   CALL  @FETCH   ; Fetch char and mask high bit
         PUSH  R21   ; save R20:21
         PUSH  R20
         CALL  @SELRUL  ; select rules set, test if letter rule
         POP   R20   ; restore R20:21
         POP   R21
         CALL  @DECR3   ; dec R2:3 and roll if needed
         RETS     ; return R10.5=1 if letter

; #   09 1+ vowels
PATVOW   CALL  @GFLAGS  ; Get letter flags
         BTJO  %80H,A,LF6A6; Vowel flag ? Jump if yes
         JMP   PATFL1   ; pattern match failed

LF6A6    CALL  @GNEXT   ; get next char and move code to range 00-3F
         CALL  @GFLAGS  ; Get letter flags
         BTJO  %80H,A,LF6A6; Vowel flag ? Loop until not
         CALL  @UNGET   ; Unget input character
         JMP   PATOK2   ; Accept rule

; .   0A voiced consonant: B D G J L M N R V W X
PATVOC   CALL  @GFLAGS  ; Get letter flags
         BTJO  %40H,A,PATOK2  ; Voiced consonant flag ? Accept if yes
         JMP   PATFL1   ; pattern match failed
      
PATOK2   BR @CHKPAT  ; Check rule pattern

; ^   0E 1 consonant only
PAT1CO   CALL  @GFLAGS  ; Get letter flags
         BTJO  %08H,A,PATOK2  ; Consonant flag ? Accept if yes
         JMP   PATFL1   ; pattern match failed

; +   0F front vowel: E I Y
PATFVO   CALL  @GFLAGS  ; Get letter flags
         BTJO  %04H,A,PATOK2  ; Front vowel flag ? Accept if yes
         JMP   PATFL1   ; pattern match failed

;    12 back vowel: O U
PATBVO   CALL  @GFLAGS  ; Get letter flags
         BTJO  %02H,A,PATOK2  ; Back vowel flag ? Accept if yes
         JMP   PATFL1   ; pattern match failed

; &   0C sibilant: S C G Z X J CH SH
PATSIB   CALL  @GFLAGS  ; Get letter flags
         BTJO  %20H,A,PATOK2  ; Sibilant flag ? Accept if yes
         CALL  @GNEXT   ; get next char and move code to range 00-3F
         JMP   LF6F0

; @   0D T S R D L Z N J TH CH SH preceding long U
PATPLU   CALL  @GFLAGS  ; Get letter flags
         BTJO  %10H,A,PATOK2  ; Letter influencing long U flag ? Accept if yes
         ; (Could have checked for 'H' here...)
         CALL  @GNEXT   ; get next char and move code to range 00-3F
         CMP   %34H,R22 ; 'T' ?
         JZ    LF6FC ; jump if yes
LF6F0    CMP   %23H,R22 ; 'C' ?
         JZ    LF6FC ; jump if yes
         CMP   %33H,R22 ; 'S' ?
         JZ    LF6FC ; jump if yes
         JMP   PATFL1   ; pattern match failed

; check for TH, SH or SH
LF6FC    MOVD  R17,R3   ; R2:3 := R16:17
         CALL  @INCR3   ; inc R2:3 and roll if needed
         CALL  @INCR3   ; inc R2:3 and roll if needed
         CALL  @FETCH   ; Fetch char and mask high bit
         CMP   %48H,A   ; 'H'
         JZ    PATOK2   ; Accept if yes
         BR    @PATFLD  ; pattern match failed

;==============================================================================

; Fetch char and mask high bit
FETCH    OR    %02H,R10    ; R10.1 = 1 - sel buffer read mode
         AND   %0FBH,R10 ; R10.2 = 0 - sel input buffer
         CALL  @RWBUFR  ; read in input buffer
         AND   %7FH,A   ; mask high bit of char
         RETS           ; return

;==============================================================================

; inc R16:17 and roll if needed
INCR17   INC   R17      ; inc R16:17
         JNC   LF721
         INC   R16
LF721    MOVD  R17,R13  ; R12:13 := R16:17
         CALL  @ROLINP  ; Roll input buffer R12:13
         MOVD  R13,R17  ; R16:17 := R12:13
         RETS

;==============================================================================

; inc R2:3 and roll if needed
INCR3    INC   R3 ; inc R2:3
         JNC   LF731
         INC   R2
LF731    MOVD  R3,R13   ; R12:13 := R2:3
         CALL  @ROLINP  ; Roll input buffer R12:13
         MOVD  R13,R3   ; R2:3 := R12:13
         RETS

;==============================================================================

; dec R2:3 and roll if needed
DECR3    DECD  R3 ; dec R2:3
         CMP   R35,R3   ; before input buffer start ?
         JNZ   LF74A
         CMP   R34,R2
         JNZ   LF74A ; jump if not
         MOVD  R37,R3   ; roll to input buffer end
LF74A    RETS     ; return

;==============================================================================

; dec R16:17 and roll if needed
DECR17   DECD  R17   ; dec R16:17
         CMP   R35,R17  ; before input buffer start ?
         JNZ   LF75A
         CMP   R34,R16
         JNZ   LF75A ; jump if not
         MOVD  R37,R17  ; roll to input buffer end
LF75A    RETS     ; return

;==============================================================================

; get next char and move code to range 00-3F
GNEXT    BTJZ  %40H,R10,LF766 ; R10.6 set ? jump if not
         PUSH  R3 ; else save R2:3
         PUSH  R2
         MOVD  R17,R3   ; and move R16:17 to R2:3
LF766    CALL  @FETCH   ; Fetch char and mask high bit
         BTJZ  %40H,R10,LF774 ; R10.6 set ? jump if not
         CALL  @DECR17  ; else dec R16:17 and roll if needed
         POP   R2 ; and restore R2:3
         POP   R3
LF774    CMP   %61H,A   ; lower case ?
         JN    LF77A ; jump if not
         SUB   %20H,A   ; change to upper case
LF77A    SUB   %20H,A   ; shift to range 00-3F
         MOV   A,R22 ; store in R22
         RETS     ; return

;==============================================================================

; Unget last input character
UNGET    BTJO  %40H,R10,LF787 ; R10.6 set ? jump if yes
         CALL  @DECR3   ; dec R2:3 (input buffer read ptr) and roll if needed
         RETS

LF787    CALL  @INCR17  ; inc R16:17 (backward input buffer read ptr) and roll if needed
         RETS


;==============================================================================

         DB  0FFH   ; boundary

; Rules for punctuation
RLPNCT   DB  0CDH,0C0H,00AH,047H,0B3H,0EBH,009H,010H
         DB  00AH,025H,047H,0B3H,0EBH,009H,047H,0B3H
         DB  0EBH,047H,0B3H,0F7H,0C7H,0FFH,0CCH,0C3H
         DB  0DBH,0C3H,0C0H,0C1H,0CEH,044H,084H,0C1H
         DB  044H,084H,0DFH,044H,084H,0DAH,0C4H,0C5H
         DB  049H,034H,037H,037H,007H,00BH,00DH,080H
         DB  0C4H,061H,018H,02DH,033H,02BH,080H,0C3H
         DB  078H,00FH,010H,01CH,033H,080H,0FFH,0C2H
; Rules for 'A'
RULESA   DB  013H,0FFH,013H,0D4H,063H,028H,0A5H,054H
         DB  002H,0A9H,0FFH,013H,0CFH,013H,072H,0A5H
         DB  013H,0FBH,00EH,0F3H,009H,054H,0B7H,013H
         DB  0F2H,02FH,04FH,0A7H,013H,0FFH,00EH,032H
         DB  0CFH,0F2H,009H,0EFH,013H,010H,06EH,0B9H
         DB  047H,00BH,093H,067H,021H,029H,0AEH,04FH
         DB  001H,024H,007H,007H,08BH,0FFH,037H,021H
         DB  0CFH,0F7H,057H,097H,013H,010H,0FFH,00EH
         DB  00FH,013H,0D4H,013H,0FFH,00EH,009H,0CFH
         DB  0FFH,00EH,00FH,009H,0D4H,009H,010H,06CH
         DB  02CH,0B9H,04FH,02DH,093H,013H,0ECH,009H
         DB  04FH,0ADH,009H,010H,0E7H,025H,04CH,001H
         DB  08AH,0FFH,00EH,00BH,0D4H,0FFH,00EH,00FH
         DB  010H,009H,0DAH,013H,072H,0B2H,04FH,0A7H
         DB  072H,0B2H,05AH,0A7H,013H,010H,0F2H,013H
         DB  0FBH,0F2H,013H,0F3H,0F2H,0FBH,069H,0B2H
         DB  047H,0AFH,0E9H,0D4H,0F9H,0D4H,0F5H,0D7H
         DB  009H,010H,0ECH,013H,0FEH,009H,010H,06CH
         DB  0B3H,013H,07EH,0ABH,06CH,0ABH,057H,002H
         DB  0A9H,0FFH,02CH,00EH,0D7H,013H,010H,062H
         DB  02CH,0A5H,054H,001H,03FH,0BEH,062H,02CH
         DB  0A5H,04FH,001H,03FH,0BEH,06EH,0A7H,00FH
         DB  054H,00BH,001H,08AH,0FFH,0DAH
; Rules for 'B'
RULESB   DB  013H,0FFH,013H,041H,03FH,093H,02DH,021H
         DB  039H,0E5H,07FH,093H,013H,0E5H,00EH,009H
         DB  041H,03FH,093H,013H,065H,025H,0AEH,013H
         DB  07FH,00CH,08BH,013H,06FH,034H,0A8H,013H
         DB  041H,03FH,035H,09DH,013H,075H,0B3H,009H
         DB  041H,03FH,00CH,0ABH,075H,029H,0ACH,041H
         DB  03FH,00CH,00CH,0ADH,0FFH,022H,0FFH,0FFH
         DB  013H,041H,09CH,0FFH,033H,041H,09CH,0F4H
         DB  042H,08DH,013H,0FFH,00EH,041H,09CH,0FFH
         DB  041H,0BFH
; Rules for 'C'
RULESC   DB  013H,0FFH,013H,077H,037H,093H,013H,0E8H
         DB  00EH,042H,0AAH,00EH,025H,0E8H,042H,0AAH
         DB  0E8H,042H,0B2H,033H,0E9H,009H,077H,037H
         DB  086H,0E9H,009H,0E5H,0E9H,02FH,0E5H,0E9H
         DB  025H,02EH,0E5H,0FFH,00FH,077H,0B7H,023H
         DB  0FFH,0FFH,0EBH,009H,042H,0AAH,0EBH,042H
         DB  0A9H,06FH,0ADH,00BH,042H,008H,00FH,090H
         DB  0E3H,00FH,042H,02AH,037H,0B7H,0FFH,013H
         DB  042H,0A9H,0FFH,033H,042H,0A9H,0FFH,012H
         DB  042H,088H,0FFH,042H,0AAH
; Rules for 'D'
RULESD   DB  013H,0FFH,013H,041H,021H,093H,0FFH,024H
         DB  0FFH,009H,010H,065H,0A4H,013H,041H,021H
         DB  00CH,001H,095H,00AH,025H,0FFH,013H,041H
         DB  095H,009H,011H,025H,0FFH,013H,042H,08DH
         DB  013H,0E5H,00EH,009H,041H,021H,08CH,013H
         DB  0EFH,013H,041H,021H,09FH,013H,06FH,025H
         DB  0B3H,041H,021H,00FH,0ABH,013H,06FH,029H
         DB  02EH,0A7H,041H,021H,01FH,00CH,0ACH,013H
         DB  06FH,0B7H,041H,021H,0A0H,009H,0F5H,010H
         DB  021H,041H,00AH,096H,0E7H,041H,08AH,0EAH
         DB  041H,08AH,0FFH,013H,041H,095H,0FFH,033H
         DB  041H,095H,0FFH,041H,0A1H
; Rules for 'E'
RULESE   DB  013H,0FFH,013H,0D3H,009H,010H,0FFH,013H
         DB  0FFH,007H,011H,0FFH,013H,0FFH,011H,0FFH
         DB  013H,0D3H,009H,0E4H,013H,041H,095H,009H
         DB  010H,0FFH,024H,013H,0FFH,0F6H,025H,032H
         DB  047H,0A3H,009H,011H,0ECH,0FEH,072H,0A9H
         DB  009H,07CH,093H,009H,010H,0F2H,009H,0F3H
         DB  0FFH,00EH,00BH,0D3H,072H,0A9H,047H,007H
         DB  00EH,08CH,0F2H,009H,047H,0AFH,0F2H,0F3H
         DB  013H,076H,025H,0AEH,013H,053H,023H,00CH
         DB  08BH,013H,076H,025H,0AEH,053H,023H,007H
         DB  007H,08BH,009H,010H,0F7H,071H,09FH,00DH
         DB  0F7H,0DFH,0F7H,071H,09FH,0FFH,02FH,0D3H
         DB  009H,010H,00CH,0F3H,013H,04CH,0ABH,009H
         DB  010H,0FFH,033H,013H,0FFH,009H,010H,06CH
         DB  0B9H,013H,06DH,093H,009H,010H,06DH,025H
         DB  02EH,0B4H,050H,00CH,00BH,002H,08DH,066H
         DB  035H,0ACH,068H,01EH,0ADH,065H,0B2H,0FCH
         DB  0E5H,0D3H,061H,032H,0AEH,074H,08BH,013H
         DB  061H,0B2H,00EH,0F4H,011H,061H,0B2H,0FCH
         DB  061H,0A4H,047H,007H,001H,095H,009H,010H
         DB  0E1H,013H,053H,08FH,0E1H,033H,035H,0C7H
         DB  0E1H,0D3H,069H,027H,0A8H,0D4H,0E9H,0D3H
         DB  013H,079H,0A5H,0C6H,0F9H,0D3H,0F5H,0D6H
         DB  0FFH,0C7H
; Rules for 'F'
RULESF   DB  013H,0FFH,013H,047H,007H,0A8H,0F5H,02CH
         DB  068H,09EH,0FFH,026H,0FFH,06FH,035H,0B2H
         DB  068H,0BAH,0FFH,0E8H
; Rules for 'G'
RULESG   DB  013H,0FFH,013H,041H,00AH,093H,069H,0B6H
         DB  041H,024H,00CH,0A3H,013H,0FFH,029H,00EH
         DB  041H,0A4H,0E5H,034H,041H,024H,087H,033H
         DB  035H,067H,025H,0B3H,041H,03DH,001H,00AH
         DB  007H,007H,0B7H,0E7H,041H,0A4H,072H,025H
         DB  021H,0B4H,041H,022H,027H,014H,08DH,0FFH
         DB  013H,041H,0A2H,013H,022H,009H,0FFH,041H
         DB  0BDH,0FFH,00FH,041H,08AH,009H,0E8H,0E8H
         DB  0E8H,041H,0BDH,0FFH,041H,0BDH
; Rules for 'H'
RULESH   DB  013H,0FFH,013H,054H,002H,0B2H,013H,061H
         DB  0B6H,05BH,01AH,0A3H,013H,065H,032H,0A5H
         DB  05BH,0BCH,013H,06FH,035H,0B2H,060H,0B3H
         DB  06FH,0B7H,05BH,0A0H,079H,0B0H,05BH,00CH
         DB  002H,089H,0FFH,012H,0F9H,0FFH,009H,0DBH
         DB  0FFH,0FFH
; Rules for 'I'
RULESI   DB  013H,0EEH,04CH,08BH,02EH,0FFH,02EH,025H
         DB  0C6H,0FFH,013H,0C6H,0EEH,024H,046H,08BH
         DB  013H,010H,0FFH,00BH,0C6H,013H,010H,065H
         DB  0A4H,013H,046H,001H,095H,009H,011H,065H
         DB  0A4H,013H,053H,001H,095H,026H,032H,0E5H
         DB  02EH,024H,0C7H,065H,0AEH,053H,00CH,08BH
         DB  0E5H,034H,046H,08CH,065H,0B2H,053H,0B3H
         DB  0FFH,00BH,0D3H,0E5H,0D3H,0EEH,00BH,053H
         DB  08BH,0F2H,009H,046H,0B3H,0FFH,00EH,00BH
         DB  0C6H,0FFH,00EH,00FH,010H,009H,0CCH,0FAH
         DB  00BH,046H,0ABH,0F3H,00BH,046H,0ABH,0FFH
         DB  01FH,00BH,0C6H,00FH,00EH,0FFH,00EH,00FH
         DB  0CCH,0FFH,034H,00BH,0C6H,009H,011H,0FFH
         DB  00EH,00FH,0CCH,0F2H,0F4H,011H,0FFH,02FH
         DB  02EH,0F1H,067H,0A8H,0C6H,06CH,0A4H,046H
         DB  03EH,001H,095H,067H,0AEH,046H,08BH,067H
         DB  0AEH,00EH,046H,08BH,067H,0AEH,00BH,046H
         DB  08BH,071H,035H,0A5H,053H,002H,0A9H,0FFH
         DB  021H,0C6H,02DH,0FFH,023H,0C6H,0FFH,0CCH
; Rules for 'J'
RULESJ   DB  013H,0FFH,013H,041H,00AH,094H,0FFH,041H
         DB  08AH
; Rules for 'K'
RULESK   DB  013H,0FFH,013H,042H,02AH,094H,013H,0FFH
         DB  02EH,0FFH,0FFH,013H,042H,0A9H,0FFH,042H
         DB  0AAH
; Rules for 'L'
RULESL   DB  013H,0FFH,013H,047H,007H,0ADH,0EFH,023H
         DB  009H,06DH,0B5H,0FFH,02CH,0FFH,0FFH,00BH
         DB  0FEH,065H,021H,0A4H,06DH,013H,001H,095H
         DB  061H,035H,027H,0A8H,06DH,01AH,0A8H,0FFH
         DB  0EDH
; Rules for 'M'
RULESM   DB  0E2H,0D0H,013H,0FFH,013H,047H,007H,090H
         DB  06FH,0B6H,050H,01FH,0A3H,0FFH,02DH,0FFH
         DB  0FFH,0D0H
; Rules for 'N'
RULESN   DB  013H,0FFH,013H,047H,007H,08BH,025H,0E7H
         DB  00FH,04BH,001H,08AH,0E7H,032H,06CH,001H
         DB  0A4H,0E7H,009H,06CH,001H,0A4H,067H,0ACH
         DB  00BH,06CH,001H,024H,0BEH,0E7H,0ECH,0EBH
         DB  013H,06CH,002H,0A9H,0EBH,033H,06CH,002H
         DB  0A9H,0EBH,06CH,002H,0AAH,013H,06FH,0B7H
         DB  013H,078H,0A0H,0FFH,02EH,0FFH,009H,010H
         DB  0F5H,04BH,031H,096H,013H,0FFH,0F8H,047H
         DB  0B4H,04BH,002H,08DH,0FFH,0CBH
; Rules for 'O'
RULESO   DB  013H,0FFH,013H,0F5H,0E6H,013H,04FH,0A3H
         DB  072H,02FH,035H,027H,0A8H,04FH,00FH,027H
         DB  0B5H,009H,010H,0F2H,013H,0F3H,009H,010H
         DB  072H,0B3H,013H,073H,0ABH,0F2H,0FAH,013H
         DB  06EH,0A5H,06EH,00FH,08BH,00FH,06EH,0A5H
         DB  06EH,00FH,08BH,011H,0F7H,02EH,0E0H,0F7H
         DB  0F5H,013H,076H,025H,0B2H,075H,023H,0B3H
         DB  0F6H,04FH,0A3H,0FFH,00EH,00BH,0F5H,0FFH
         DB  00EH,025H,02EH,0F5H,0FFH,00EH,029H,009H
         DB  0F5H,0ECH,024H,075H,0ADH,075H,027H,028H
         DB  0B4H,057H,017H,002H,08DH,075H,027H,0A8H
         DB  04FH,00FH,0A8H,00CH,075H,0B2H,0FAH,010H
         DB  075H,0B2H,060H,0B3H,013H,0F5H,0E0H,010H
         DB  0F5H,033H,009H,0E0H,075H,0B3H,04FH,0B7H
         DB  075H,02CH,0A4H,05EH,001H,095H,00EH,0F5H
         DB  00EH,02CH,0CFH,075H,0B0H,05FH,002H,089H
         DB  0F5H,0E0H,0F9H,0C5H,069H,02EH,0A7H,075H
         DB  00CH,0ACH,0E9H,0C5H,06FH,0B2H,0FAH,06FH
         DB  0ABH,013H,05EH,002H,0A9H,06FH,0ABH,033H
         DB  05EH,002H,0A9H,06FH,0ABH,05EH,002H,0AAH
         DB  06FH,0A4H,013H,05EH,001H,095H,0EFH,024H
         DB  0DEH,0EFH,0DFH,0FFH,025H,0F5H,0FFH,013H
         DB  0F5H,061H,0B2H,0FAH,0E1H,0F5H,013H,06EH
         DB  02CH,0B9H,075H,00BH,02DH,093H,013H,06EH
         DB  023H,0A5H,06EH,00FH,00BH,0B7H,06EH,007H
         DB  0B4H,075H,00BH,002H,08DH,023H,0FFH,02EH
         DB  0CFH,0FFH,02EH,027H,0D7H,013H,011H,0FFH
         DB  02EH,0CFH,029H,0EEH,04FH,08BH,009H,010H
         DB  0EEH,013H,04FH,08BH,0FFH,033H,034H,013H
         DB  0F5H,0E6H,00EH,057H,0A8H,074H,028H,025H
         DB  0B2H,04FH,036H,0B3H,073H,0B3H,013H,057H
         DB  017H,037H,0B7H,009H,011H,0EDH,04FH,090H
         DB  0FFH,0D8H
; Rules for 'P'
RULESP   DB  073H,039H,023H,0A8H,077H,037H,006H,001H
         DB  0AAH,013H,0FFH,013H,042H,009H,093H,0E8H
         DB  0E8H,065H,02FH,0B0H,042H,009H,013H,002H
         DB  089H,06FH,0B7H,042H,009H,0A0H,075H,0B4H
         DB  013H,042H,009H,01EH,002H,08DH,0FFH,030H
         DB  0FFH,0FFH,042H,089H
; Rules for 'Q'
RULESQ   DB  013H,0FFH,013H,042H,02AH,031H,09FH,075H
         DB  021H,0B2H,042H,008H,030H,098H,075H,0A5H
         DB  013H,042H,02AH,031H,09FH,0F5H,042H,008H
         DB  0B0H,0FFH,042H,088H
; Rules for 'R'
RULESR   DB  013H,0FFH,013H,0FBH,013H,0E5H,00EH,009H
         DB  04EH,093H,0E8H,0CEH,0FFH,032H,0FFH,011H
         DB  0FFH,0E7H,0FFH,0CEH
; Rules for 'S'
RULESS   DB  013H,0FFH,013H,047H,007H,037H,0B7H,0E8H
         DB  0E5H,009H,069H,02FH,0AEH,066H,00FH,08BH
         DB  06FH,02DH,0A5H,077H,00FH,090H,009H,075H
         DB  0B2H,009H,066H,0B3H,075H,0B2H,009H,065H
         DB  0B3H,009H,0F5H,009H,066H,096H,009H,073H
         DB  0B5H,009H,065H,096H,009H,065H,0A4H,013H
         DB  06BH,001H,095H,009H,0FFH,009H,0EBH,061H
         DB  029H,0A4H,077H,037H,007H,007H,001H,095H
         DB  00EH,069H,02FH,0AEH,065H,00FH,08BH,0FFH
         DB  033H,0FFH,00AH,0FFH,013H,0EBH,009H,010H
         DB  00AH,025H,0FFH,013H,0EBH,009H,011H,014H
         DB  0FFH,013H,0EBH,009H,011H,009H,0FFH,013H
         DB  0F7H,035H,0FFH,013H,0F7H,013H,010H,009H
         DB  0FFH,013H,0EBH,013H,063H,0A8H,077H,037H
         DB  002H,0A9H,0FFH,023H,00FH,0FFH,009H,0EDH
         DB  06BH,090H,009H,0FFH,02EH,007H,0EBH,0FFH
         DB  013H,0F7H,0FFH,077H,0B7H
; Rules for 'T'
RULEST   DB  0FFH,007H,033H,042H,091H,063H,0A8H,042H
         DB  0B2H,013H,0FFH,013H,042H,00DH,093H,013H
         DB  068H,0A5H,013H,009H,052H,093H,013H,068H
         DB  0A5H,013H,052H,08FH,0EFH,013H,042H,00DH
         DB  09FH,06FH,024H,021H,0B9H,042H,00DH,01FH
         DB  021H,094H,068H,0A1H,00EH,013H,052H,09AH
         DB  013H,068H,029H,0B3H,013H,052H,00CH,037H
         DB  0B7H,013H,068H,025H,0B9H,052H,094H,013H
         DB  068H,025H,032H,0A5H,052H,0AFH,013H,068H
         DB  025H,0B2H,05DH,0B3H,068H,025H,0B2H,076H
         DB  0B3H,068H,025H,029H,0B2H,052H,0AFH,013H
         DB  068H,025H,0ADH,010H,052H,007H,090H,068H
         DB  025H,033H,0A5H,013H,052H,013H,0ABH,013H
         DB  068H,025H,0AEH,052H,007H,08BH,068H,032H
         DB  02FH,035H,027H,0A8H,013H,05DH,027H,09FH
         DB  068H,02FH,033H,0A5H,052H,035H,0B7H,068H
         DB  02FH,035H,027H,0A8H,013H,052H,0B5H,013H
         DB  068H,035H,0B3H,052H,00FH,037H,0B7H,068H
         DB  0A5H,013H,0D2H,0E8H,0DDH,009H,010H,065H
         DB  0A4H,013H,042H,00DH,00CH,001H,095H,033H
         DB  0E9H,009H,02EH,042H,0B2H,0E9H,02FH,0E5H
         DB  0E9H,021H,0E5H,069H,025H,0AEH,065H,00FH
         DB  08BH,075H,0B2H,009H,042H,032H,0B3H,0F5H
         DB  021H,042H,032H,096H,013H,077H,0AFH,042H
         DB  00DH,09FH,0FFH,034H,0FFH,0FFH,033H,042H
         DB  091H,0FFH,042H,08DH
; Rules for 'U'
RULESU   DB  013H,0FFH,013H,071H,09FH,0EEH,029H,059H
         DB  016H,08BH,013H,0EEH,04FH,08BH,013H,070H
         DB  02FH,0AEH,04FH,002H,009H,018H,08BH,00DH
         DB  0F2H,009H,056H,0B3H,0F2H,009H,071H,016H
         DB  0B3H,0F2H,011H,0F3H,0FFH,00EH,013H,0CFH
         DB  0FFH,00EH,00EH,0CFH,0F9H,0C6H,013H,027H
         DB  0FFH,009H,0FFH,027H,0FFH,00BH,0FFH,027H
         DB  0FFH,009H,0EEH,00DH,0FFH,0DFH,0FFH,071H
         DB  096H
; Rules for 'V'
RULESV   DB  013H,0FFH,013H,063H,093H,069H,025H,0B7H
         DB  063H,031H,09FH,0FFH,0E3H
; Rules for 'W'
RULESW   DB  013H,0FFH,013H,041H,021H,00FH,001H,03FH
         DB  03EH,031H,096H,013H,065H,032H,0A5H,06EH
         DB  0B4H,013H,061H,0B3H,013H,06EH,00FH,0ABH
         DB  0E1H,033H,06EH,098H,0E1H,034H,06EH,017H
         DB  097H,061H,0AEH,06EH,018H,08BH,068H,025H
         DB  032H,0A5H,070H,0AFH,068H,021H,0B4H,070H
         DB  018H,002H,08DH,068H,02FH,0ACH,079H,035H
         DB  0ADH,068H,0AFH,079H,09FH,0EFH,02DH,06EH
         DB  08FH,0E8H,0F0H,061H,0B2H,06EH,0BAH,06FH
         DB  0B2H,00EH,06EH,0B3H,0F2H,0CEH,0FFH,0EEH
; Rules for 'X'
RULESX   DB  013H,0FFH,013H,047H,002H,029H,0B7H,013H
         DB  0FFH,0EBH,0FFH,042H,029H,0B7H
; Rules for 'Y'
RULESY   DB  06FH,035H,0B2H,059H,0BAH,013H,0FFH,013H
         DB  06EH,086H,06FH,035H,02EH,0A7H,059H,00FH
         DB  0ACH,013H,06FH,0B5H,059H,09FH,065H,021H
         DB  0B2H,010H,059H,0BCH,013H,065H,0B3H,059H
         DB  007H,037H,0B7H,013H,0FFH,0D9H,009H,011H
         DB  0FFH,013H,0D3H,009H,011H,0FFH,029H,0D3H
         DB  013H,010H,0FFH,013H,0C6H,013H,010H,0FFH
         DB  009H,0C6H,013H,010H,0FFH,00EH,00FH,010H
         DB  009H,0CCH,013H,010H,0FFH,00EH,009H,0C6H
         DB  0FFH,0CCH
; Rules for 'Z'
RULESZ   DB  013H,0FFH,013H,06BH,093H,0FFH,03AH,0FFH
         DB  0FFH,0EBH
; Rules for digits
RULNUM   DB  0D0H,06BH,03CH,0B5H,0D1H,06EH,00FH,00FH
         DB  08BH,0D2H,042H,00DH,09FH,0D3H,05DH,00EH
         DB  093H,0D4H,068H,0BAH,0D5H,068H,006H,0A3H
         DB  0D6H,077H,037H,00CH,002H,029H,0B7H,0D7H
         DB  077H,037H,007H,023H,00CH,08BH,0D8H,054H
         DB  002H,08DH,0D9H,078H,006H,08BH
      
;==============================================================================

; Index of rules tables
TABRUL   DW  RLPNCT
TABRU1   EQU   $-1
         DW  RULESA,RULESB,RULESC,RULESD
         DW  RULESE,RULESF,RULESG,RULESH
         DW  RULESI,RULESJ,RULESK,RULESL
         DW  RULESM,RULESN,RULESO,RULESP
         DW  RULESQ,RULESR,RULESS,RULEST
         DW  RULESU,RULESV,RULESW,RULESX
         DW  RULESY,RULESZ,RULNUM,LFFFF

;==============================================================================
; Interrupt vectors
         ORG 0FFF6H
         DW  INT4             ; serial interrupt
         DW  INT3             ; SP0256
         DW  LFFFF            ; timer 1 interrupt
         DW  INT1             ; parallel port
         DW  START            ; reset
LFFFF    EQU   $-1

;==============================================================================

         END   START

;==============================================================================

