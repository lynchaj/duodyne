     1                                  ;**********************************************************************
     2                                  ;
     3                                  ; MON88 (c) HT-LAB
     4                                  ;
     5                                  ; - Simple Monitor for 8088/86
     6                                  ; - Some bios calls
     7                                  ; - Disassembler based on David Moore's "disasm.c - x86 Disassembler v 0.1"
     8                                  ; - Requires roughly 14K, default segment registers set to 0380h
     9                                  ; - Assembled using A86 assembler
    10                                  ;
    11                                  ;----------------------------------------------------------------------
    12                                  ;
    13                                  ; Copyright (C) 2005 Hans Tiggeler - http://www.ht-lab.com
    14                                  ; Send comments and bugs to : cpu86@ht-lab.com
    15                                  ;
    16                                  ; This program is free software; you can redistribute it and/or modify
    17                                  ; it under the terms of the GNU General Public License as published by
    18                                  ; the Free Software Foundation; either version 2 of the License, or
    19                                  ; (at your option) any later version.
    20                                  ;
    21                                  ; This program is distributed in the hope that it will be useful, but
    22                                  ; WITHOUT ANY WARRANTY; without even the implied warranty of
    23                                  ; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    24                                  ; General Public License for more details.
    25                                  ;
    26                                  ; You should have received a copy of the GNU General Public License
    27                                  ; along with this program; if not, write to the Free Software Foundation,
    28                                  ; Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
    29                                  ;----------------------------------------------------------------------
    30                                  ;
    31                                  ; Ver 0.1     30 July 2005  H.Tiggeler  WWW.HT-LAB.COM
    32                                  ;**********************************************************************
    33
    34                                  LF              EQU 0Ah
    35                                  CR              EQU 0Dh
    36                                  ESC             EQU 01Bh
    37
    38                                  ;----------------------------------------------------------------------
    39                                  ; UART settings, COM1
    40                                  ;----------------------------------------------------------------------
    41                                  COM1            EQU 03F8h
    42                                  COM2            EQU 02F8h
    43                                  COMPORT         EQU COM1        ; Select Console I/O Port
    44
    45                                  DATAREG         EQU 0
    46                                  STATUS          EQU 1
    47                                  DIVIDER         EQU 2
    48                                  TX_EMPTY        EQU 02
    49                                  RX_AVAIL        EQU 01
    50                                  FRAME_ERR       EQU 04
    51
    52                                  ;----------------------------------------------------------------------
    53                                  ; Used for Load Hex file command
    54                                  ;----------------------------------------------------------------------
    55                                  EOF_REC         EQU 01          ; End of file record
    56                                  DATA_REC        EQU 00          ; Load data record
    57                                  EAD_REC         EQU 02          ; Extended Address Record, use to set CS
    58                                  SSA_REC         EQU 03          ; Execute Address
    59
    60                                  ;----------------------------------------------------------------------
    61                                  ; PIO Base Address
    62                                  ;----------------------------------------------------------------------
    63                                  PIO             EQU 0398h
    64
    65                                  ;----------------------------------------------------------------------
    66                                  ; Real Time Clock
    67                                  ;----------------------------------------------------------------------
    68                                  RTC_BASE        EQU 0070h
    69                                  RTC_DATA        EQU 0071h
    70
    71                                  ;----------------------------------------------------------------------
    72                                  ; Hardware Single Step Monitor, CPU86 IP Core only!
    73                                  ; Single Step Registers
    74                                  ;
    75                                  ; bit3 bit2 bit1 bit0   HWM_CONFIG
    76                                  ;  |    |    |     \--- '1' =Enable Single Step
    77                                  ;  |    |     \-------- '1' =Select TXMON output for UARTx
    78                                  ;  \-----\------------- '00'=No Step
    79                                  ;                       '01'=Step
    80                                  ;                       '10'=select step_sw input
    81                                  ;                       '11'=select not(step_sw) input
    82                                  ;----------------------------------------------------------------------
    83                                  ;HWM_CONFIG  EQU    0360h
    84                                  ;HWM_BITLOW  EQU    0362h                       ; 10 bits divider
    85                                  ;HWM_BITHIGH EQU    0363h                       ; bps=clk/HWM_BIT(9 downto 0)
    86
    87                                  ;------------------------------------------------------------------------------------
    88                                  ; Default Base Segment Pointer
    89                                  ; All MON88 commands operate on the BASE_SEGMENT:xxxx address.
    90                                  ; The base_segment value can be changed by the BS command
    91                                  ;------------------------------------------------------------------------------------
    92                                  BASE_SEGMENT    EQU 0380h
    93
    94
    95                                          %IMACRO WRSPACE  0      ; Write space character
    96                                          MOV     AL,' '
    97                                          CALL    TXCHAR
    98                                          %ENDM
    99
   100                                          %IMACRO WREQUAL  0      ; Write = character
   101                                          MOV     AL,'='
   102                                          CALL    TXCHAR
   103                                          %ENDM
   104
   105                                          ORG     0400h           ; First 1024 bytes used for int vectors
   106
   107                                  INITMON:
   108 00000000 8CC8                            MOV     AX,CS           ; Cold entry point
   109 00000002 8ED8                            MOV     DS,AX           ;
   110
   111 00000004 8ED0                            MOV     SS,AX
   112 00000006 B8[7617]                        MOV     AX,  TOS        ; Top of Stack
   113 00000009 89C4                            MOV     SP,AX           ; Set Stack pointer
   114
   115                                  ;----------------------------------------------------------------------
   116                                  ; Set baudrate for Hardware Monitor
   117                                  ; 10 bits divider
   118                                  ; Actel Board 9.8214/38400 -> BIT_LOW=255
   119                                  ; 192 for 7.3864MHz
   120                                  ;----------------------------------------------------------------------
   121                                  ;           MOV     DX,HWM_BITLOW
   122                                  ;           MOV     AL,255                      ; Set for Actel Board 9.8214
   123                                  ;           OUT     DX,AL           ; 38400 bps
   124                                  ;
   125                                  ;           MOV     DX,HWM_BITHIGH
   126                                  ;           MOV     AL,00
   127                                  ;           OUT     DX,AL
   128
   129                                  ;----------------------------------------------------------------------
   130                                  ; Install Interrupt Vectors
   131                                  ; INT1 & INT3 used for single stepping and breakpoints
   132                                  ; INT# * 4     =
   133                                  ; INT# * 4 + 2 = Segment
   134                                  ;----------------------------------------------------------------------
   135
   136 0000000B 31C0                            XOR     AX,AX           ; Segment=0000
   137 0000000D 8EC0                            MOV     ES,AX
   138
   139                                  ; Point all vectors to unknown handler!
   140 0000000F 31DB                            XOR     BX,BX           ; 256 vectors * 4 bytes
   141                                  NEXTINTS:
   142 00000011 26C707[7B12]                    MOV     WORD [ES:BX],   INTX; Spurious Interrupt Handler
   143 00000016 26C747020000                    MOV     WORD [ES:BX+2], 0
   144 0000001C 83C304                          ADD     BX,4
   145 0000001F 81FB0004                        CMP     BX,0400h
   146 00000023 75EC                            JNE     NEXTINTS
   147
   148 00000025 26C7060400[D20F]                MOV     WORD [ES:04],   INT1_3; INT1 Single Step handler
   149 0000002C 26C7060C00[D20F]                MOV     WORD [ES:12],   INT1_3; INT3 Breakpoint handler
   150 00000033 26C7064000[7010]                MOV     WORD [ES:64],   INT10; INT10h
   151 0000003A 26C7065800[8310]                MOV     WORD [ES:88],   INT16; INT16h
   152 00000041 26C7066800[BD10]                MOV     WORD [ES:104],  INT1A; INT1A, Timer functions
   153 00000048 26C7068400[CB11]                MOV     WORD [ES:132],  INT21; INT21h
   154
   155                                  ;----------------------------------------------------------------------
   156                                  ; Entry point, Display welcome message
   157                                  ;----------------------------------------------------------------------
   158                                  START:
   159 0000004F FC                              CLD
   160 00000050 BE[540F]                        MOV     SI,  WELCOME_MESS;   -> SI
   161 00000053 E8870E                          CALL    PUTS            ; String pointed to by DS:[SI]
   162
   163 00000056 B88003                          MOV     AX,BASE_SEGMENT ; Get Default Base segment
   164 00000059 8EC0                            MOV     ES,AX
   165
   166                                  ;----------------------------------------------------------------------
   167                                  ; Process commands
   168                                  ;----------------------------------------------------------------------
   169                                  CMD:
   170 0000005B BE[AE0F]                        MOV     SI,  PROMPT_MESS; Display prompt >
   171 0000005E E87C0E                          CALL    PUTS
   172
   173 00000061 E84D0F                          CALL    RXCHAR          ; Get Command First Byte
   174 00000064 E82C0F                          CALL    TO_UPPER
   175 00000067 88C6                            MOV     DH,AL
   176
   177 00000069 BB[AD00]                        MOV     BX,  CMDTAB1    ; Single Command?
   178                                  CMPCMD1:
   179 0000006C 8A07                            MOV     AL,[BX]
   180 0000006E 38F0                            CMP     AL,DH
   181 00000070 7508                            JNE     NEXTCMD1
   182                                          WRSPACE
    96 00000072 B020                <1>  MOV AL,' '
    97 00000074 E8290F              <1>  CALL TXCHAR
   183 00000077 FF6702                          JMP     [BX+2]          ; Execute Command
   184
   185                                  NEXTCMD1:
   186 0000007A 83C304                          ADD     BX,4
   187 0000007D 81FB[D500]                      CMP     BX,  ENDTAB1
   188 00000081 75E9                            JNE     CMPCMD1         ; Continue looking
   189
   190 00000083 E82B0F                          CALL    RXCHAR          ; Get Second Command Byte, DX=command
   191 00000086 E80A0F                          CALL    TO_UPPER
   192 00000089 88C2                            MOV     DL,AL
   193
   194 0000008B BB[D700]                        MOV     BX,  CMDTAB2
   195                                  CMPCMD2:
   196 0000008E 8B07                            MOV     AX,[BX]
   197 00000090 39D0                            CMP     AX,DX
   198 00000092 7508                            JNE     NEXTCMD2
   199                                          WRSPACE
    96 00000094 B020                <1>  MOV AL,' '
    97 00000096 E8070F              <1>  CALL TXCHAR
   200 00000099 FF6702                          JMP     [BX+2]          ; Execute Command
   201
   202                                  NEXTCMD2:
   203 0000009C 83C304                          ADD     BX,4
   204 0000009F 81FB[0B01]                      CMP     BX,  ENDTAB2
   205 000000A3 75E9                            JNE     CMPCMD2         ; Continue looking
   206
   207 000000A5 BE[B50F]                        MOV     SI,  ERRCMD_MESS; Display Unknown Command, followed by usage message
   208 000000A8 E8320E                          CALL    PUTS
   209 000000AB EBAE                            JMP     CMD             ; Try again
   210
   211                                  CMDTAB1:
   212 000000AD 4C00[6005]                      DW      'L',LOADHEX     ; Single char Command Jump Table
   213 000000B1 5200[8404]                      DW      'R',DISPREG
   214 000000B5 4700[F402]                      DW      'G',EXECPROG
   215 000000B9 4E00[DE02]                      DW      'N',TRACENEXT
   216 000000BD 5400[E902]                      DW      'T',TRACEPROG
   217 000000C1 5500[A101]                      DW      'U',DISASSEM
   218 000000C5 4800[BF0E]                      DW      'H',DISPHELP
   219 000000C9 3F00[BF0E]                      DW      '?',DISPHELP
   220 000000CD 5100[C80E]                      DW      'Q',EXITMON
   221 000000D1 0D00[5B00]                      DW      CR ,CMD
   222                                  ENDTAB1:
   223 000000D5 2000                            DW      ' '
   224
   225                                  CMDTAB2:
   226 000000D7 464D[6304]                      DW      'FM',FILLMEM    ; Double char Command Jump Table
   227 000000DB 444D[A303]                      DW      'DM',DUMPMEM
   228 000000DF 4250[0D01]                      DW      'BP',SETBREAKP  ; Set Breakpoint
   229 000000E3 4342[3501]                      DW      'CB',CLRBREAKP  ; Clear Breakpoint
   230 000000E7 4442[4B01]                      DW      'DB',DISPBREAKP ; Display Breakpoint
   231 000000EB 4352[4F02]                      DW      'CR',CHANGEREG  ; Change Register
   232 000000EF 4F42[5E03]                      DW      'OB',OUTPORTB
   233 000000F3 4253[CC02]                      DW      'BS',CHANGEBS   ; Change Base Segment Address
   234 000000F7 4F57[6F03]                      DW      'OW',OUTPORTW
   235 000000FB 4942[8003]                      DW      'IB',INPORTB
   236 000000FF 4957[9103]                      DW      'IW',INPORTW
   237 00000103 5742[1302]                      DW      'WB',WRMEMB     ; Write Byte to Memory
   238 00000107 5757[3102]                      DW      'WW',WRMEMW     ; Write Word to Memory
   239                                  ENDTAB2:
   240 0000010B 3F3F                            DW      '??'
   241
   242                                  ;----------------------------------------------------------------------
   243                                  ; Set Breakpoint
   244                                  ;----------------------------------------------------------------------
   245                                  SETBREAKP:
   246 0000010D BB[8101]                        MOV     BX,  BPTAB      ; BX point to Breakpoint table
   247 00000110 E82B0E                          CALL    GETHEX1         ; Set Breakpoint, first get BP number
   248 00000113 2407                            AND     AL,07h          ; Allow 8 breakpoints
   249 00000115 30E4                            XOR     AH,AH
   250 00000117 D0E0                            SHL     AL,1            ; *4 to get
   251 00000119 D0E0                            SHL     AL,1
   252 0000011B 01C3                            ADD     BX,AX           ; point to table entry
   253 0000011D C6470301                        MOV     BYTE [BX+3],1   ; Enable Breakpoint
   254                                          WRSPACE
    96 00000121 B020                <1>  MOV AL,' '
    97 00000123 E87A0E              <1>  CALL TXCHAR
   255 00000126 E8F30D                          CALL    GETHEX4         ; Get Address
   256 00000129 8907                            MOV     [BX],AX         ; Save Address
   257
   258 0000012B 89C7                            MOV     DI,AX
   259 0000012D 268A05                          MOV     AL,[ES:DI]      ; Get the opcode
   260 00000130 884702                          MOV     [BX+2],AL       ; Store in table
   261
   262 00000133 EB16                            JMP     DISPBREAKP      ; Display Enabled Breakpoints
   263
   264                                  ;----------------------------------------------------------------------
   265                                  ; Clear Breakpoint
   266                                  ;----------------------------------------------------------------------
   267                                  CLRBREAKP:
   268 00000135 BB[8101]                        MOV     BX,  BPTAB      ; BX point to Breakpoint table
   269 00000138 E8030E                          CALL    GETHEX1         ; first get BP number
   270 0000013B 2407                            AND     AL,07h          ; Only allow 8 breakpoints
   271 0000013D 30E4                            XOR     AH,AH
   272 0000013F D0E0                            SHL     AL,1            ; *4 to get
   273 00000141 D0E0                            SHL     AL,1
   274 00000143 01C3                            ADD     BX,AX           ; point to table entry
   275 00000145 C6470300                        MOV     BYTE [BX+3],0   ; Clear Breakpoint
   276
   277 00000149 EB00                            JMP     DISPBREAKP      ; Display Remaining Breakpoints
   278
   279                                  ;----------------------------------------------------------------------
   280                                  ; Display all enabled Breakpoints
   281                                  ; # Addr
   282                                  ; 0 1234
   283                                  ;----------------------------------------------------------------------
   284                                  DISPBREAKP:
   285 0000014B E8AF0D                          CALL    NEWLINE
   286 0000014E BB[8101]                        MOV     BX,  BPTAB
   287 00000151 B90800                          MOV     CX,8
   288
   289                                  NEXTCBP:
   290 00000154 B80800                          MOV     AX,8
   291 00000157 28C8                            SUB     AL,CL
   292
   293 00000159 F6470301                        TEST    BYTE [BX+3],1   ; Check enable/disable flag
   294 0000015D 741A                            JZ      NEXTDBP
   295
   296 0000015F E80E0E                          CALL    PUTHEX1         ; Display Breakpoint Number
   297                                          WRSPACE
    96 00000162 B020                <1>  MOV AL,' '
    97 00000164 E8390E              <1>  CALL TXCHAR
   298 00000167 8B07                            MOV     AX,[BX]         ; Get Address
   299 00000169 E8E80D                          CALL    PUTHEX4         ; Display it
   300                                          WRSPACE
    96 0000016C B020                <1>  MOV AL,' '
    97 0000016E E82F0E              <1>  CALL TXCHAR
   301
   302 00000171 8B07                            MOV     AX,[BX]         ; Get Address
   303 00000173 E86C00                          CALL    DISASM_AX       ; Disassemble instruction & Display it
   304 00000176 E8840D                          CALL    NEWLINE
   305
   306                                  NEXTDBP:
   307 00000179 83C304                          ADD     BX,4            ; Next entry
   308 0000017C E2D6                            LOOP    NEXTCBP
   309 0000017E E9DAFE                          JMP     CMD             ; Next Command
   310
   311                                  ;----------------------------------------------------------------------
   312                                  ; Breakpoint Table, Address(2), Opcode(1), flag(1) enable=1, disable=0
   313                                  ;----------------------------------------------------------------------
   314                                  BPTAB:
   315 00000181 00000000                        DB      4 DUP 0
   316 00000185 00000000                        DB      4 DUP 0
   317 00000189 00000000                        DB      4 DUP 0
   318 0000018D 00000000                        DB      4 DUP 0
   319 00000191 00000000                        DB      4 DUP 0
   320 00000195 00000000                        DB      4 DUP 0
   321 00000199 00000000                        DB      4 DUP 0
   322 0000019D 00000000                        DB      4 DUP 0
   323
   324                                  ;----------------------------------------------------------------------
   325                                  ; Disassemble Range
   326                                  ;----------------------------------------------------------------------
   327                                  DISASSEM:
   328 000001A1 E8660D                          CALL    GETRANGE        ; Range from BX to DX
   329 000001A4 E8560D                          CALL    NEWLINE
   330
   331                                  LOOPDIS1:
   332 000001A7 52                              PUSH    DX
   333
   334 000001A8 89D8                            MOV     AX,BX           ; Address in AX
   335 000001AA E8A70D                          CALL    PUTHEX4         ; Display it
   336
   337 000001AD 8D1E[2A16]                      LEA     BX,DISASM_CODE  ; Pointer to code storage
   338 000001B1 8D16[FA15]                      LEA     DX,DISASM_INST  ; Pointer to instr string
   339 000001B5 E8AA05                          CALL    disasm_         ; Disassemble Opcode
   340 000001B8 89C3                            MOV     BX,AX           ;
   341
   342 000001BA 50                              PUSH    AX              ; New address returned in AX
   343                                          WRSPACE
    96 000001BB B020                <1>  MOV AL,' '
    97 000001BD E8E00D              <1>  CALL TXCHAR
   344 000001C0 BE[2A16]                        MOV     SI,  DISASM_CODE
   345 000001C3 E8170D                          CALL    PUTS
   346 000001C6 E8030D                          CALL    STRLEN          ; String in SI, Length in AL
   347 000001C9 B40F                            MOV     AH,15
   348 000001CB 28C4                            SUB     AH,AL
   349 000001CD E87F02                          CALL    WRNSPACE        ; Write AH spaces
   350 000001D0 BE[FA15]                        MOV     SI,  DISASM_INST
   351 000001D3 E8070D                          CALL    PUTS
   352 000001D6 E8240D                          CALL    NEWLINE
   353 000001D9 58                              POP     AX
   354
   355 000001DA 5A                              POP     DX
   356 000001DB 39DA                            CMP     DX,BX
   357 000001DD 73C8                            JNB     LOOPDIS1
   358
   359                                  EXITDIS:
   360 000001DF E979FE                          JMP     CMD             ; Next Command
   361
   362                                  ;----------------------------------------------------------------------
   363                                  ; Disassemble Instruction at AX and Display it
   364                                  ; Return updated address in AX
   365                                  ;----------------------------------------------------------------------
   366                                  DISASM_AX:
   367 000001E2 06                              PUSH    ES              ; Disassemble Instruction
   368 000001E3 56                              PUSH    SI
   369 000001E4 52                              PUSH    DX
   370 000001E5 53                              PUSH    BX
   371 000001E6 50                              PUSH    AX
   372
   373 000001E7 A1[6016]                        MOV     AX,[UCS]        ; Get Code Base segment
   374 000001EA 8EC0                            MOV     ES,AX           ;
   375 000001EC 8D1E[2A16]                      LEA     BX,DISASM_CODE  ; Pointer to code storage
   376 000001F0 8D16[FA15]                      LEA     DX,DISASM_INST  ; Pointer to instr string
   377 000001F4 58                              POP     AX              ; Address in AX
   378 000001F5 E86A05                          CALL    disasm_         ; Disassemble Opcode
   379
   380 000001F8 BE[2A16]                        MOV     SI,  DISASM_CODE
   381 000001FB E8DF0C                          CALL    PUTS
   382 000001FE E8CB0C                          CALL    STRLEN          ; String in SI, Length in AL
   383 00000201 B40F                            MOV     AH,15
   384 00000203 28C4                            SUB     AH,AL
   385 00000205 E84702                          CALL    WRNSPACE        ; Write AH spaces
   386 00000208 BE[FA15]                        MOV     SI,  DISASM_INST
   387 0000020B E8CF0C                          CALL    PUTS
   388
   389 0000020E 5B                              POP     BX
   390 0000020F 5A                              POP     DX
   391 00000210 5E                              POP     SI
   392 00000211 07                              POP     ES
   393 00000212 C3                              RET
   394
   395                                  ;----------------------------------------------------------------------
   396                                  ; Write Byte to Memory
   397                                  ;----------------------------------------------------------------------
   398                                  WRMEMB:
   399 00000213 E8060D                          CALL    GETHEX4         ; Get Address
   400 00000216 89C3                            MOV     BX,AX           ; Store Address
   401                                          WRSPACE
    96 00000218 B020                <1>  MOV AL,' '
    97 0000021A E8830D              <1>  CALL TXCHAR
   402
   403 0000021D 268A07                          MOV     AL,[ES:BX]      ; Get current value and display it
   404 00000220 E83C0D                          CALL    PUTHEX2
   405                                          WREQUAL
   101 00000223 B03D                <1>  MOV AL,'='
   102 00000225 E8780D              <1>  CALL TXCHAR
   406 00000228 E8FE0C                          CALL    GETHEX2         ; Get new value
   407 0000022B 268807                          MOV     [ES:BX],AL      ; and write it
   408
   409 0000022E E92AFE                          JMP     CMD             ; Next Command
   410
   411                                  ;----------------------------------------------------------------------
   412                                  ; Write Word to Memory
   413                                  ;----------------------------------------------------------------------
   414                                  WRMEMW:
   415 00000231 E8E80C                          CALL    GETHEX4         ; Get Address
   416 00000234 89C3                            MOV     BX,AX
   417                                          WRSPACE
    96 00000236 B020                <1>  MOV AL,' '
    97 00000238 E8650D              <1>  CALL TXCHAR
   418
   419 0000023B 268B07                          MOV     AX,[ES:BX]      ; Get current value and display it
   420 0000023E E8130D                          CALL    PUTHEX4
   421                                          WREQUAL
   101 00000241 B03D                <1>  MOV AL,'='
   102 00000243 E85A0D              <1>  CALL TXCHAR
   422 00000246 E8D30C                          CALL    GETHEX4         ; Get new value
   423 00000249 268907                          MOV     [ES:BX],AX      ; and write it
   424
   425 0000024C E90CFE                          JMP     CMD             ; Next Command
   426
   427                                  ;----------------------------------------------------------------------
   428                                  ; Change Register
   429                                  ; Valid register names: AX,BX,CX,DX,SP,BP,SI,DI,DS,ES,SS,CS,IP,FL (flag)
   430                                  ;----------------------------------------------------------------------
   431                                  CHANGEREG:
   432 0000024F E85F0D                          CALL    RXCHAR          ; Get Command First Register character
   433 00000252 E83E0D                          CALL    TO_UPPER
   434 00000255 88C6                            MOV     DH,AL
   435 00000257 E8570D                          CALL    RXCHAR          ; Get Second Register character, DX=register
   436 0000025A E8360D                          CALL    TO_UPPER
   437 0000025D 88C2                            MOV     DL,AL
   438
   439 0000025F BB[9202]                        MOV     BX,  REGTAB
   440                                  CMPREG:
   441 00000262 8B07                            MOV     AX,[BX]
   442 00000264 39D0                            CMP     AX,DX           ; Compare register string with user input
   443 00000266 7518                            JNE     NEXTREG         ; No, continue search
   444
   445                                          WREQUAL
   101 00000268 B03D                <1>  MOV AL,'='
   102 0000026A E8330D              <1>  CALL TXCHAR
   446 0000026D E8AC0C                          CALL    GETHEX4         ; Get new value
   447 00000270 89C1                            MOV     CX,AX           ; CX=New reg value
   448
   449 00000272 8D3E[4A16]                      LEA     DI,UAX          ; Point to User Register Storage
   450 00000276 8A5F02                          MOV     BL,[BX+2]       ; Get
   451 00000279 30FF                            XOR     BH,BH
   452 0000027B 8909                            MOV     [DI+BX],CX
   453 0000027D E90402                          JMP     DISPREG         ; Display All registers
   454
   455                                  NEXTREG:
   456 00000280 83C304                          ADD     BX,4
   457 00000283 81FB[CA02]                      CMP     BX,  ENDREG
   458 00000287 75D9                            JNE     CMPREG          ; Continue looking
   459
   460 00000289 BE[E10F]                        MOV     SI,  ERRREG_MESS; Display Unknown Register Name
   461 0000028C E84E0C                          CALL    PUTS
   462
   463 0000028F E9C9FD                          JMP     CMD             ; Try Again
   464
   465                                  REGTAB:
   466 00000292 41580000                        DW      'AX',0          ; register name,
   467 00000296 42580200                        DW      'BX',2
   468 0000029A 43580400                        DW      'CX',4
   469 0000029E 44580600                        DW      'DX',6
   470 000002A2 53500800                        DW      'SP',8
   471 000002A6 42500A00                        DW      'BP',10
   472 000002AA 53490C00                        DW      'SI',12
   473 000002AE 44490E00                        DW      'DI',14
   474 000002B2 44531000                        DW      'DS',16
   475 000002B6 45531200                        DW      'ES',18
   476 000002BA 53531400                        DW      'SS',20
   477 000002BE 43531600                        DW      'CS',22
   478 000002C2 49501800                        DW      'IP',24
   479 000002C6 464C1A00                        DW      'FL',26
   480                                  ENDREG:
   481 000002CA 3F3F                            DW      '??'
   482
   483
   484                                  ;----------------------------------------------------------------------
   485                                  ; Change Base Segment pointer
   486                                  ; Dump/Fill/Load operate on BASE_SEGMENT:[USER INPUT ADDRESS]
   487                                  ; Note: CB command will not update the User Registers!
   488                                  ;----------------------------------------------------------------------
   489                                  CHANGEBS:
   490 000002CC 8CC0                            MOV     AX,ES           ; WORD BASE_SEGMENT
   491 000002CE E8830C                          CALL    PUTHEX4         ; Display current value
   492                                          WRSPACE
    96 000002D1 B020                <1>  MOV AL,' '
    97 000002D3 E8CA0C              <1>  CALL TXCHAR
   493 000002D6 E8430C                          CALL    GETHEX4
   494 000002D9 50                              PUSH    AX
   495 000002DA 07                              POP     ES
   496 000002DB E97DFD                          JMP     CMD             ; Next Command
   497
   498
   499                                  ;----------------------------------------------------------------------
   500                                  ; Trace Next
   501                                  ;----------------------------------------------------------------------
   502                                  TRACENEXT:
   503 000002DE A1[6416]                        MOV     AX,[UFL]        ; Get User flags
   504 000002E1 0D0001                          OR      AX,0100h        ; set TF
   505 000002E4 A3[6416]                        MOV     [UFL],AX
   506 000002E7 EB3C                            JMP     TRACNENTRY
   507
   508                                  ;----------------------------------------------------------------------
   509                                  ; Trace Program from Address
   510                                  ;----------------------------------------------------------------------
   511                                  TRACEPROG:
   512 000002E9 A1[6416]                        MOV     AX,[UFL]        ; Get User flags
   513 000002EC 0D0001                          OR      AX,0100h        ; set TF
   514 000002EF A3[6416]                        MOV     [UFL],AX
   515 000002F2 EB1C                            JMP     TRACENTRY       ; get execute address, save user registers etc
   516
   517                                  ;----------------------------------------------------------------------
   518                                  ; Execute program
   519                                  ; 1) Enable all Breakpoints (replace opcode with INT3 CC)
   520                                  ; 2) Restore User registers
   521                                  ; 3) Jump to BASE_SEGMENT:USER_
   522                                  ;----------------------------------------------------------------------
   523                                  EXECPROG:
   524 000002F4 BB[8101]                        MOV     BX,  BPTAB      ; Enable All breakpoints
   525 000002F7 B90800                          MOV     CX,8
   526
   527                                  NEXTENBP:
   528 000002FA B80800                          MOV     AX,8
   529 000002FD 28C8                            SUB     AL,CL
   530 000002FF F6470301                        TEST    BYTE [BX+3],1   ; Check enable/disable flag
   531 00000303 7406                            JZ      NEXTEXBP
   532 00000305 8B3F                            MOV     DI,[BX]         ; Get Breakpoint Address
   533 00000307 26C605CC                        MOV     BYTE [ES:DI],0CCh; Write INT3 instruction to address
   534
   535                                  NEXTEXBP:
   536 0000030B 83C304                          ADD     BX,4            ; Next entry
   537 0000030E E2EA                            LOOP    NEXTENBP
   538
   539                                  TRACENTRY:
   540 00000310 8CC0                            MOV     AX,ES           ; Display Segment Address
   541 00000312 E83F0C                          CALL    PUTHEX4
   542 00000315 B03A                            MOV     AL,':'
   543 00000317 E8860C                          CALL    TXCHAR
   544 0000031A E8FF0B                          CALL    GETHEX4         ; Get new IP
   545 0000031D A3[6216]                        MOV     [UIP],AX        ; Update User IP
   546 00000320 8CC0                            MOV     AX,ES
   547 00000322 A3[6016]                        MOV     [UCS],AX
   548
   549                                  ; Single Step Registers
   550                                  ; bit3 bit2 bit1 bit0
   551                                  ;  |    |    |     \--- '1' =Enable Single Step
   552                                  ;  |    |     \-------- '1' =Select TXMON output for UARTx
   553                                  ;  \-----\------------- '00'=No Step
   554                                  ;                       '01'=Step
   555                                  ;                       '10'=select step_sw input
   556                                  ;                       '11'=select not(step_sw) input
   557                                  ;           MOV     DX,HWM_CONFIG
   558                                  ;           MOV     AL,07h                      ; xxxx-0111 step=1
   559                                  ;           OUT     DX,AL                       ; Enable Trace
   560
   561                                  TRACNENTRY:
   562 00000325 A1[4A16]                        MOV     AX,[UAX]        ; Restore User Registers
   563 00000328 8B1E[4C16]                      MOV     BX,[UBX]
   564 0000032C 8B0E[4E16]                      MOV     CX,[UCX]
   565 00000330 8B16[5016]                      MOV     DX,[UDX]
   566 00000334 8B2E[5416]                      MOV     BP,[UBP]
   567 00000338 8B36[5616]                      MOV     SI,[USI]
   568 0000033C 8B3E[5816]                      MOV     DI,[UDI]
   569
   570 00000340 8E06[5C16]                      MOV     ES,[UES]
   571 00000344 FA                              CLI                     ; User User Stack!!
   572 00000345 8E16[5E16]                      MOV     SS,[USS]
   573 00000349 8B26[5216]                      MOV     SP,[USP]
   574
   575 0000034D FF36[6416]                      PUSH    word [UFL]
   576 00000351 FF36[6016]                      PUSH    word [UCS]      ; Push CS (Base Segment)
   577 00000355 FF36[6216]                      PUSH    word [UIP]
   578 00000359 8E1E[5A16]                      MOV     DS,[UDS]
   579 0000035D CF                              IRET                    ; Execute!
   580
   581                                  ;----------------------------------------------------------------------
   582                                  ; Write Byte to Output port
   583                                  ;----------------------------------------------------------------------
   584                                  OUTPORTB:
   585 0000035E E8BB0B                          CALL    GETHEX4         ; Get Port address
   586 00000361 89C2                            MOV     DX,AX
   587                                          WREQUAL
   101 00000363 B03D                <1>  MOV AL,'='
   102 00000365 E8380C              <1>  CALL TXCHAR
   588 00000368 E8BE0B                          CALL    GETHEX2         ; Get Port value
   589 0000036B EE                              OUT     DX,AL
   590 0000036C E9ECFC                          JMP     CMD             ; Next Command
   591
   592                                  ;----------------------------------------------------------------------
   593                                  ; Write Word to Output port
   594                                  ;----------------------------------------------------------------------
   595                                  OUTPORTW:
   596 0000036F E8AA0B                          CALL    GETHEX4         ; Get Port address
   597 00000372 89C2                            MOV     DX,AX
   598                                          WREQUAL
   101 00000374 B03D                <1>  MOV AL,'='
   102 00000376 E8270C              <1>  CALL TXCHAR
   599 00000379 E8A00B                          CALL    GETHEX4         ; Get Port value
   600 0000037C EF                              OUT     DX,AX
   601 0000037D E9DBFC                          JMP     CMD             ; Next Command
   602
   603                                  ;----------------------------------------------------------------------
   604                                  ; Read Byte from Input port
   605                                  ;----------------------------------------------------------------------
   606                                  INPORTB:
   607 00000380 E8990B                          CALL    GETHEX4         ; Get Port address
   608 00000383 89C2                            MOV     DX,AX
   609                                          WREQUAL
   101 00000385 B03D                <1>  MOV AL,'='
   102 00000387 E8160C              <1>  CALL TXCHAR
   610 0000038A EC                              IN      AL,DX
   611 0000038B E8D10B                          CALL    PUTHEX2
   612 0000038E E9CAFC                          JMP     CMD             ; Next Command
   613
   614                                  ;----------------------------------------------------------------------
   615                                  ; Read Word from Input port
   616                                  ;----------------------------------------------------------------------
   617                                  INPORTW:
   618 00000391 E8880B                          CALL    GETHEX4         ; Get Port address
   619                                          WREQUAL
   101 00000394 B03D                <1>  MOV AL,'='
   102 00000396 E8070C              <1>  CALL TXCHAR
   620 00000399 E8040C                          CALL    TXCHAR
   621 0000039C ED                              IN      AX,DX
   622 0000039D E8B40B                          CALL    PUTHEX4
   623 000003A0 E9B8FC                          JMP     CMD             ; Next Command
   624
   625                                  ;----------------------------------------------------------------------
   626                                  ; Display Memory
   627                                  ;----------------------------------------------------------------------
   628                                  DUMPMEM:
   629 000003A3 E8640B                          CALL    GETRANGE        ; Range from BX to DX
   630                                  NEXTDMP:
   631 000003A6 BE[6616]                        MOV     SI,  DUMPMEMS   ; Store ASCII values
   632
   633 000003A9 E8510B                          CALL    NEWLINE
   634 000003AC 8CC0                            MOV     AX,ES
   635 000003AE E8A30B                          CALL    PUTHEX4
   636 000003B1 B03A                            MOV     AL,':'
   637 000003B3 E8EA0B                          CALL    TXCHAR
   638 000003B6 89D8                            MOV     AX,BX
   639 000003B8 83E0F0                          AND     AX,0FFF0h
   640 000003BB E8960B                          CALL    PUTHEX4
   641                                          WRSPACE                 ; Write Space
    96 000003BE B020                <1>  MOV AL,' '
    97 000003C0 E8DD0B              <1>  CALL TXCHAR
   642                                          WRSPACE                 ; Write Space
    96 000003C3 B020                <1>  MOV AL,' '
    97 000003C5 E8D80B              <1>  CALL TXCHAR
   643
   644 000003C8 88DC                            MOV     AH,BL           ; Save lsb
   645 000003CA 80E40F                          AND     AH,0Fh          ; 16 byte boundary
   646
   647 000003CD E87F00                          CALL    WRNSPACE        ; Write AH spaces
   648 000003D0 E87C00                          CALL    WRNSPACE        ; Write AH spaces
   649 000003D3 E87900                          CALL    WRNSPACE        ; Write AH spaces
   650
   651                                  DISPBYTE:
   652 000003D6 B91000                          MOV     CX,16
   653 000003D9 28E1                            SUB     CL,AH
   654
   655                                  LOOPDMP1:
   656 000003DB 268A07                          MOV     AL,[ES:BX]      ; Get Byte and display it in HEX
   657 000003DE 3E8804                          MOV     DS:[SI],AL      ; Save it
   658 000003E1 E87B0B                          CALL    PUTHEX2
   659                                          WRSPACE                 ; Write Space
    96 000003E4 B020                <1>  MOV AL,' '
    97 000003E6 E8B70B              <1>  CALL TXCHAR
   660 000003E9 43                              INC     BX
   661 000003EA 46                              INC     SI
   662 000003EB 39D3                            CMP     BX,DX
   663 000003ED 7309                            JNC     SHOWREM         ; show remaining
   664 000003EF E2EA                            LOOP    LOOPDMP1
   665
   666 000003F1 E83300                          CALL    PUTSDMP         ; Display it
   667
   668 000003F4 39DA                            CMP     DX,BX           ; End of memory range?
   669 000003F6 73AE                            JNC     NEXTDMP         ; No, continue with next 16 bytes
   670
   671                                  SHOWREM:
   672 000003F8 BE[6616]                        MOV     SI,  DUMPMEMS   ; Stored ASCII values
   673 000003FB 89D8                            MOV     AX,BX
   674 000003FD 83E00F                          AND     AX,0000Fh
   675 00000400 84C0                            TEST    AL,AL
   676 00000402 741B                            JZ      SKIPCLR
   677 00000404 01C6                            ADD     SI,AX           ;
   678 00000406 B410                            MOV     AH,16
   679 00000408 28C4                            SUB     AH,AL
   680 0000040A 88E1                            MOV     CL,AH
   681 0000040C 30ED                            XOR     CH,CH
   682 0000040E B020                            MOV     AL,' '          ; Clear non displayed values
   683                                  NEXTCLR:
   684 00000410 3E8804                          MOV     DS:[SI],AL      ; Save it
   685 00000413 46                              INC     SI
   686 00000414 E2FA                            LOOP    NEXTCLR
   687 00000416 E83600                          CALL    WRNSPACE        ; Write AH spaces
   688 00000419 E83300                          CALL    WRNSPACE        ; Write AH spaces
   689 0000041C E83000                          CALL    WRNSPACE        ; Write AH spaces
   690                                  SKIPCLR:
   691 0000041F 30E4                            XOR     AH,AH
   692 00000421 E80300                          CALL    PUTSDMP
   693
   694                                  EXITDMP:
   695 00000424 E934FC                          JMP     CMD             ; Next Command
   696
   697                                  PUTSDMP:
   698 00000427 BE[6616]                        MOV     SI,  DUMPMEMS   ; Stored ASCII values
   699                                          WRSPACE                 ; Add 2 spaces
    96 0000042A B020                <1>  MOV AL,' '
    97 0000042C E8710B              <1>  CALL TXCHAR
   700                                          WRSPACE
    96 0000042F B020                <1>  MOV AL,' '
    97 00000431 E86C0B              <1>  CALL TXCHAR
   701 00000434 E81800                          CALL    WRNSPACE        ; Write AH spaces
   702 00000437 B91000                          MOV     CX,16
   703 0000043A 28E1                            SUB     CL,AH           ; Adjust if not started at xxx0
   704                                  NEXTCH:
   705 0000043C AC                              LODSB                   ; Get character AL=DS:[SI++]
   706 0000043D 3C1F                            CMP     AL,01Fh         ; 20..7E printable
   707 0000043F 7606                            JBE     PRINTDOT
   708 00000441 3C7F                            CMP     AL,07Fh
   709 00000443 7302                            JAE     PRINTDOT
   710 00000445 EB02                            JMP     PRINTCH
   711                                  PRINTDOT:
   712 00000447 B02E                            MOV     AL,'.'
   713                                  PRINTCH:
   714 00000449 E8540B                          CALL    TXCHAR
   715 0000044C E2EE                            LOOP    NEXTCH          ; Next Character
   716 0000044E C3                              RET
   717
   718                                  WRNSPACE:
   719 0000044F 50                              PUSH    AX              ; Write AH space, skip if 0
   720 00000450 51                              PUSH    CX
   721 00000451 84E4                            TEST    AH,AH
   722 00000453 740B                            JZ      EXITWRNP
   723 00000455 30ED                            XOR     CH,CH           ; Write AH spaces
   724 00000457 88E1                            MOV     CL,AH
   725 00000459 B020                            MOV     AL,' '
   726                                  NEXTDTX:
   727 0000045B E8420B                          CALL    TXCHAR
   728 0000045E E2FB                            LOOP    NEXTDTX
   729                                  EXITWRNP:
   730 00000460 59                              POP     CX
   731 00000461 58                              POP     AX
   732 00000462 C3                              RET
   733
   734                                  ;----------------------------------------------------------------------
   735                                  ; Fill Memory
   736                                  ;----------------------------------------------------------------------
   737                                  FILLMEM:
   738 00000463 E8A40A                          CALL    GETRANGE        ; First get range BX to DX
   739                                          WRSPACE
    96 00000466 B020                <1>  MOV AL,' '
    97 00000468 E8350B              <1>  CALL TXCHAR
   740 0000046B E8BB0A                          CALL    GETHEX2
   741 0000046E 50                              PUSH    AX              ; Store fill character
   742 0000046F E88B0A                          CALL    NEWLINE
   743
   744 00000472 39DA                            CMP     DX,BX
   745 00000474 720B                            JB      EXITFILL
   746                                  DOFILL:
   747 00000476 29DA                            SUB     DX,BX
   748 00000478 89D1                            MOV     CX,DX
   749 0000047A 89DF                            MOV     DI,BX           ; [ES:DI]
   750 0000047C 58                              POP     AX              ; Restore fill char
   751                                  NEXTFILL:
   752 0000047D AA                              STOSB
   753 0000047E E2FD                            LOOP    NEXTFILL
   754 00000480 AA                              STOSB                   ; Last byte
   755                                  EXITFILL:
   756 00000481 E9D7FB                          JMP     CMD             ; Next Command
   757
   758                                  ;----------------------------------------------------------------------
   759                                  ; Display Registers
   760                                  ;
   761                                  ; AX=0001 BX=0002 CX=0003 DX=0004 SP=0005 BP=0006 SI=0007 DI=0008
   762                                  ; DS=0009 ES=000A SS=000B CS=000C IP=0100   ODIT-SZAPC=0000-00000
   763                                  ;----------------------------------------------------------------------
   764                                  DISPREG:
   765 00000484 E8760A                          CALL    NEWLINE
   766 00000487 BE[1F05]                        MOV     SI,  REG_MESS   ;   -> SI
   767 0000048A 8D3E[4A16]                      LEA     DI,UAX
   768
   769 0000048E B90800                          MOV     CX,8
   770                                  NEXTDR1:
   771 00000491 E8490A                          CALL    PUTS            ; Point to first "AX=" string
   772 00000494 8B05                            MOV     AX,[DI]         ; DI points to AX value
   773 00000496 E8BB0A                          CALL    PUTHEX4         ; Display AX value
   774 00000499 83C605                          ADD     SI,5            ; point to "BX=" string
   775 0000049C 83C702                          ADD     DI,2            ; Point to BX value
   776 0000049F E2F0                            LOOP    NEXTDR1         ; etc
   777
   778 000004A1 E8590A                          CALL    NEWLINE
   779 000004A4 B90500                          MOV     CX,5
   780                                  NEXTDR2:
   781 000004A7 E8330A                          CALL    PUTS            ; Point to first "DS=" string
   782 000004AA 8B05                            MOV     AX,[DI]         ; DI points to DS value
   783 000004AC E8A50A                          CALL    PUTHEX4         ; Display DS value
   784 000004AF 83C605                          ADD     SI,5            ; point to "ES=" string
   785 000004B2 83C702                          ADD     DI,2            ; Point to ES value
   786 000004B5 E2F0                            LOOP    NEXTDR2         ; etc
   787
   788 000004B7 BE[1111]                        MOV     SI,  FLAG_MESS
   789 000004BA E8200A                          CALL    PUTS
   790 000004BD BE[2011]                        MOV     SI,  FLAG_VALID ; String indicating which bits to display
   791 000004C0 8B1D                            MOV     BX,[DI]         ; get flag value in BX
   792
   793 000004C2 B90800                          MOV     CX,8            ; Display first 4 bits
   794                                  NEXTBIT1:
   795 000004C5 AC                              LODSB                   ; Get display/notdisplay flag AL=DS:[SI++]
   796 000004C6 3C58                            CMP     AL,'X'          ; Display?
   797 000004C8 7504                            JNE     SHFTCAR         ; Yes, shift bit into carry and display it
   798 000004CA D1E3                            SAL     BX,1            ; no, ignore bit
   799 000004CC EB0D                            JMP     EXITDISP1
   800                                  SHFTCAR:
   801 000004CE D1E3                            SAL     BX,1
   802 000004D0 7204                            JC      DISP1
   803 000004D2 B030                            MOV     AL,'0'
   804 000004D4 EB02                            JMP     DISPBIT
   805                                  DISP1:
   806 000004D6 B031                            MOV     AL,'1'
   807                                  DISPBIT:
   808 000004D8 E8C50A                          CALL    TXCHAR
   809                                  EXITDISP1:
   810 000004DB E2E8                            LOOP    NEXTBIT1
   811
   812 000004DD B02D                            MOV     AL,'-'          ; Display seperator 0000-00000
   813 000004DF E8BE0A                          CALL    TXCHAR
   814
   815 000004E2 B90800                          MOV     CX,8            ; Display remaining 5 bits
   816                                  NEXTBIT2:
   817 000004E5 AC                              LODSB                   ; Get display/notdisplay flag AL=DS:[SI++]
   818 000004E6 3C58                            CMP     AL,'X'          ; Display?
   819 000004E8 7504                            JNE     SHFTCAR2        ; Yes, shift bit into carry and display it
   820 000004EA D1E3                            SAL     BX,1            ; no, ignore bit
   821 000004EC EB0D                            JMP     EXITDISP2
   822                                  SHFTCAR2:
   823 000004EE D1E3                            SAL     BX,1
   824 000004F0 7204                            JC      DISP2
   825 000004F2 B030                            MOV     AL,'0'
   826 000004F4 EB02                            JMP     DISPBIT2
   827                                  DISP2:
   828 000004F6 B031                            MOV     AL,'1'
   829                                  DISPBIT2:
   830 000004F8 E8A50A                          CALL    TXCHAR
   831                                  EXITDISP2:
   832 000004FB E2E8                            LOOP    NEXTBIT2
   833
   834 000004FD E8FD09                          CALL    NEWLINE         ; Display CS:IP Instr
   835 00000500 A1[6016]                        MOV     AX,[UCS]
   836 00000503 E84E0A                          CALL    PUTHEX4
   837 00000506 B03A                            MOV     AL,':'
   838 00000508 E8950A                          CALL    TXCHAR
   839 0000050B A1[6216]                        MOV     AX,[UIP]
   840 0000050E E8430A                          CALL    PUTHEX4
   841                                          WRSPACE
    96 00000511 B020                <1>  MOV AL,' '
    97 00000513 E88A0A              <1>  CALL TXCHAR
   842
   843 00000516 A1[6216]                        MOV     AX,[UIP]        ; Address in AX
   844 00000519 E8C6FC                          CALL    DISASM_AX       ; Disassemble Instruction & Display
   845
   846 0000051C E93CFB                          JMP     CMD             ; Next Command
   847
   848                                  REG_MESS:
   849 0000051F 41583D0000                      DB      "AX=",0,0       ; Display Register names table
   850 00000524 2042583D00                      DB      " BX=",0
   851 00000529 2043583D00                      DB      " CX=",0
   852 0000052E 2044583D00                      DB      " DX=",0
   853 00000533 2053503D00                      DB      " SP=",0
   854 00000538 2042503D00                      DB      " BP=",0
   855 0000053D 2053493D00                      DB      " SI=",0
   856 00000542 2044493D00                      DB      " DI=",0
   857
   858 00000547 44533D0000                      DB      "DS=",0,0
   859 0000054C 2045533D00                      DB      " ES=",0
   860 00000551 2053533D00                      DB      " SS=",0
   861 00000556 2043533D00                      DB      " CS=",0
   862 0000055B 2049503D00                      DB      " IP=",0
   863
   864                                  ;----------------------------------------------------------------------
   865                                  ; Load Hex, terminate when ":00000001FF" is received
   866                                  ; Mon88 may hang if this string is not received
   867                                  ; Print '.' for each valid received frame, exit upon error
   868                                  ; Bytes are loaded at Segment=ES
   869                                  ;----------------------------------------------------------------------
   870                                  LOADHEX:
   871 00000560 BE[2E10]                        MOV     SI,  LOAD_MESS  ; Display Ready to receive upload
   872 00000563 E87709                          CALL    PUTS
   873
   874 00000566 B03E                            MOV     AL,'>'
   875 00000568 EB33                            JMP     DISPCH
   876
   877                                  RXBYTE:
   878 0000056A 86FC                            XCHG    BH,AH           ; save AH register
   879 0000056C E81400                          CALL    RXNIB
   880 0000056F 88C4                            MOV     AH,AL
   881 00000571 D0E4                            SHL     AH,1            ; Can't use CL
   882 00000573 D0E4                            SHL     AH,1
   883 00000575 D0E4                            SHL     AH,1
   884 00000577 D0E4                            SHL     AH,1
   885 00000579 E80700                          CALL    RXNIB
   886 0000057C 08E0                            OR      AL,AH
   887 0000057E 00C3                            ADD     BL,AL           ; Add to check sum
   888 00000580 86FC                            XCHG    BH,AH           ; Restore AH register
   889 00000582 C3                              RET
   890
   891                                  RXNIB:
   892 00000583 E83D0A                          CALL    RXCHARNE        ; Get Hex Character in AL
   893 00000586 3C30                            CMP     AL,'0'          ; Check to make sure 0-9,A-F
   894 00000588 7211                            JB      ERROR           ;ERRHEX
   895 0000058A 3C46                            CMP     AL,'F'
   896 0000058C 770D                            JA      ERROR           ;ERRHEX
   897 0000058E 3C39                            CMP     AL,'9'
   898 00000590 7606                            JBE     SUB0
   899 00000592 3C41                            CMP     AL,'A'
   900 00000594 7205                            JB      ERROR           ; ERRHEX
   901 00000596 2C07                            SUB     AL,07h          ; Convert to hex
   902                                  SUB0:
   903 00000598 2C30                            SUB     AL,'0'          ; Convert to hex
   904 0000059A C3                              RET
   905
   906
   907                                  ERROR:
   908 0000059B B045                            MOV     AL,'E'
   909                                  DISPCH:
   910 0000059D E8000A                          CALL    TXCHAR
   911
   912                                  WAITLDS:
   913 000005A0 E8200A                          CALL    RXCHARNE        ; Wait for ':'
   914 000005A3 3C3A                            CMP     AL,':'
   915 000005A5 75F9                            JNE     WAITLDS
   916
   917 000005A7 31C9                            XOR     CX,CX           ; CL=Byte count
   918 000005A9 31DB                            XOR     BX,BX           ; BL=Checksum
   919
   920 000005AB E8BCFF                          CALL    RXBYTE          ; Get length in CX
   921 000005AE 88C1                            MOV     CL,AL
   922
   923 000005B0 E8B7FF                          CALL    RXBYTE          ; Get Address HIGH
   924 000005B3 88C4                            MOV     AH,AL
   925 000005B5 E8B2FF                          CALL    RXBYTE          ; Get Address LOW
   926 000005B8 89C7                            MOV     DI,AX           ; DI=Store Address
   927
   928 000005BA E8ADFF                          CALL    RXBYTE          ; Get Record Type
   929 000005BD 3C01                            CMP     AL,EOF_REC      ; End Of File Record
   930 000005BF 742A                            JE      GOENDLD
   931 000005C1 3C00                            CMP     AL,DATA_REC     ; Data Record?
   932 000005C3 7446                            JE      GOLOAD
   933 000005C5 3C02                            CMP     AL,EAD_REC      ; Extended Address Record?
   934 000005C7 744A                            JE      GOEAD
   935 000005C9 3C03                            CMP     AL,SSA_REC      ; Start Segment Address Record?
   936 000005CB 7402                            JE      GOSSA
   937 000005CD EBCC                            JMP     ERROR           ;ERRREC
   938
   939                                  GOSSA:
   940 000005CF B90200                          MOV     CX,2            ; Get 2 word
   941                                  NEXTW:
   942 000005D2 E895FF                          CALL    RXBYTE
   943 000005D5 88C4                            MOV     AH,AL
   944 000005D7 E890FF                          CALL    RXBYTE
   945 000005DA 50                              PUSH    AX              ; Push CS, IP
   946 000005DB E2F5                            LOOP    NEXTW
   947 000005DD E88AFF                          CALL    RXBYTE          ; Get Checksum
   948 000005E0 28C3                            SUB     BL,AL           ; Remove checksum from checksum
   949 000005E2 F6D0                            NOT     AL              ; Two's complement
   950 000005E4 0401                            ADD     AL,1
   951 000005E6 38D8                            CMP     AL,BL           ; Checksum held in BL
   952 000005E8 75B1                            JNE     ERROR           ;ERRCHKS
   953 000005EA CB                              RETF                    ; Execute loaded file
   954
   955                                  GOENDLD:
   956 000005EB E87CFF                          CALL    RXBYTE
   957 000005EE 28C3                            SUB     BL,AL           ; Remove checksum from checksum
   958 000005F0 F6D0                            NOT     AL              ; Two's complement
   959 000005F2 0401                            ADD     AL,1
   960 000005F4 38D8                            CMP     AL,BL           ; Checksum held in BL
   961 000005F6 75A3                            JNE     ERROR           ;ERRCHKS
   962 000005F8 EB25                            JMP     LOADOK
   963
   964                                  GOCHECK:
   965 000005FA E86DFF                          CALL    RXBYTE
   966 000005FD 28C3                            SUB     BL,AL           ; Remove checksum from checksum
   967 000005FF F6D0                            NOT     AL              ; Two's complement
   968 00000601 0401                            ADD     AL,1
   969 00000603 38D8                            CMP     AL,BL           ; Checksum held in BL
   970 00000605 7594                            JNE     ERROR           ;ERRCHKS
   971 00000607 B02E                            MOV     AL,'.'          ; After each successful record print a '.'
   972 00000609 EB92                            JMP     DISPCH
   973
   974                                  GOLOAD:
   975 0000060B E85CFF                          CALL    RXBYTE          ; Read Bytes
   976 0000060E AA                              STOSB                   ; ES:DI <= AL
   977 0000060F E2FA                            LOOP    GOLOAD
   978 00000611 EBE7                            JMP     GOCHECK
   979
   980                                  GOEAD:
   981 00000613 E854FF                          CALL    RXBYTE
   982 00000616 88C4                            MOV     AH,AL
   983 00000618 E84FFF                          CALL    RXBYTE
   984 0000061B 8EC0                            MOV     ES,AX           ; Set Segment address (ES)
   985 0000061D EBDB                            JMP     GOCHECK
   986
   987                                  ;ERRCHKS:    MOV     SI,  LD_CHKS_MESS      ; Display Checksum error
   988                                  ;            JMP     EXITLD                      ; Exit Load Command
   989                                  ;ERRREC:     MOV     SI,  LD_REC_MESS       ; Display unknown record type
   990                                  ;            JMP     EXITLD                      ; Exit Load Command
   991                                  LOADOK:
   992 0000061F BE[C310]                        MOV     SI,  LD_OK_MESS ; Display Load OK
   993                                  ;            JMP     EXITLD
   994                                  ;ERRHEX:     MOV     SI,  LD_HEX_MESS       ; Display Error hex value
   995                                  EXITLD:
   996 00000622 E8B808                          CALL    PUTS
   997 00000625 E933FA                          JMP     CMD             ; Exit Load Command
   998
   999                                  ;----------------------------------------------------------------------
  1000                                  ; Disassembler
  1001                                  ; Compiled, Disassembled from disasm.c
  1002                                  ; wcl -c -0 -fpc -mt -s -d0 -os -l=COM disasm.c
  1003                                  ; wdis -a -s=disasm.c -l=disasm.lst disasm.obj
  1004                                  ;----------------------------------------------------------------------
  1005                                  get_byte_:
  1006 00000628 56                              PUSH    si
  1007 00000629 57                              PUSH    di
  1008 0000062A 55                              PUSH    bp
  1009 0000062B 89E5                            MOV     bp,sp
  1010 0000062D 50                              PUSH    ax
  1011 0000062E 89C6                            MOV     si,ax
  1012 00000630 8956FE                          MOV     word -2[bp],dx
  1013 00000633 89D8                            MOV     ax,bx
  1014 00000635 89CB                            MOV     bx,cx
  1015 00000637 8B3C                            MOV     di, word [si]
  1016 00000639 268A15                          MOV     dl,byte [ES:di]
  1017 0000063C 8B7EFE                          MOV     di, word -2[bp]
  1018 0000063F 8815                            MOV     byte [di],dl
  1019 00000641 FF04                            INC     word [si]
  1020 00000643 85C0                            TEST    ax,ax
  1021 00000645 7418                            JE      L$2
  1022 00000647 85C9                            TEST    cx,cx
  1023 00000649 7414                            JE      L$2
  1024 0000064B 8A15                            MOV     dl,byte [di]
  1025 0000064D 30F6                            XOR     dh,dh
  1026 0000064F 52                              PUSH    dx
  1027 00000650 BA[5C19]                        MOV     dx,  L$450
  1028 00000653 52                              PUSH    dx
  1029 00000654 0307                            ADD     ax, word [bx]
  1030 00000656 50                              PUSH    ax
  1031 00000657 E84708                          CALL    near esprintf_
  1032 0000065A 83C406                          ADD     sp,6
  1033 0000065D 0107                            ADD     word [bx],ax
  1034                                  L$2:
  1035 0000065F 89EC                            MOV     sp,bp
  1036 00000661 5D                              POP     bp
  1037 00000662 5F                              POP     di
  1038 00000663 5E                              POP     si
  1039 00000664 C3                              RET
  1040
  1041                                  get_bytes_:
  1042 00000665 56                              PUSH    si
  1043 00000666 57                              PUSH    di
  1044 00000667 55                              PUSH    bp
  1045 00000668 89E5                            MOV     bp,sp
  1046 0000066A 83EC06                          SUB     sp,6
  1047 0000066D 89C7                            MOV     di,ax
  1048 0000066F 8956FC                          MOV     word -4[bp],dx
  1049 00000672 895EFA                          MOV     word -6[bp],bx
  1050 00000675 894EFE                          MOV     word -2[bp],cx
  1051 00000678 31F6                            XOR     si,si
  1052                                  L$3:
  1053 0000067A 3B7608                          CMP     si, word 8[bp]
  1054 0000067D 7D13                            JGE     L$4
  1055 0000067F 8B56FC                          MOV     dx, word -4[bp]
  1056 00000682 01F2                            ADD     dx,si
  1057 00000684 8B4EFE                          MOV     cx, word -2[bp]
  1058 00000687 8B5EFA                          MOV     bx, word -6[bp]
  1059 0000068A 89F8                            MOV     ax,di
  1060 0000068C E899FF                          CALL    near get_byte_
  1061 0000068F 46                              INC     si
  1062 00000690 EBE8                            JMP     L$3
  1063                                  L$4:
  1064 00000692 89EC                            MOV     sp,bp
  1065 00000694 5D                              POP     bp
  1066 00000695 5F                              POP     di
  1067 00000696 5E                              POP     si
  1068 00000697 C20200                          RET     2
  1069                                  L$5:
  1070 0000069A [0208]                          DW      L$16
  1071 0000069C [1208]                          DW      L$18
  1072 0000069E [8807]                          DW      L$7
  1073 000006A0 [8807]                          DW      L$7
  1074 000006A2 [8807]                          DW      L$7
  1075 000006A4 [8807]                          DW      L$7
  1076 000006A6 [8807]                          DW      L$7
  1077 000006A8 [8807]                          DW      L$7
  1078 000006AA [A607]                          DW      L$8
  1079 000006AC [1208]                          DW      L$18
  1080 000006AE [B807]                          DW      L$11
  1081 000006B0 [FD07]                          DW      L$15
  1082 000006B2 [1208]                          DW      L$18
  1083 000006B4 [1208]                          DW      L$18
  1084 000006B6 [1208]                          DW      L$18
  1085 000006B8 [1208]                          DW      L$18
  1086 000006BA [1208]                          DW      L$18
  1087 000006BC [1208]                          DW      L$18
  1088 000006BE [1208]                          DW      L$18
  1089 000006C0 [1208]                          DW      L$18
  1090 000006C2 [1708]                          DW      L$19
  1091 000006C4 [1708]                          DW      L$19
  1092 000006C6 [1708]                          DW      L$19
  1093 000006C8 [1708]                          DW      L$19
  1094 000006CA [1708]                          DW      L$19
  1095 000006CC [1708]                          DW      L$19
  1096 000006CE [1708]                          DW      L$19
  1097 000006D0 [1708]                          DW      L$19
  1098 000006D2 [1708]                          DW      L$19
  1099 000006D4 [1708]                          DW      L$19
  1100 000006D6 [1708]                          DW      L$19
  1101 000006D8 [1708]                          DW      L$19
  1102 000006DA [1708]                          DW      L$19
  1103 000006DC [1708]                          DW      L$19
  1104 000006DE [1708]                          DW      L$19
  1105 000006E0 [1708]                          DW      L$19
  1106 000006E2 [1708]                          DW      L$19
  1107 000006E4 [1708]                          DW      L$19
  1108                                  L$6:
  1109 000006E6 [CF08]                          DW      L$26
  1110 000006E8 [310B]                          DW      L$62
  1111 000006EA [EF08]                          DW      L$29
  1112 000006EC [0009]                          DW      L$30
  1113 000006EE [1C09]                          DW      L$31
  1114 000006F0 [3609]                          DW      L$35
  1115 000006F2 [3609]                          DW      L$35
  1116 000006F4 [2409]                          DW      L$33
  1117 000006F6 [2409]                          DW      L$33
  1118 000006F8 [4509]                          DW      L$36
  1119 000006FA [6309]                          DW      L$39
  1120 000006FC [8209]                          DW      L$40
  1121 000006FE [310B]                          DW      L$62
  1122 00000700 [310B]                          DW      L$62
  1123 00000702 [310B]                          DW      L$62
  1124 00000704 [FC09]                          DW      L$43
  1125 00000706 [050A]                          DW      L$45
  1126 00000708 [0A0A]                          DW      L$46
  1127 0000070A [0A0A]                          DW      L$46
  1128 0000070C [0A0A]                          DW      L$46
  1129 0000070E [0A0A]                          DW      L$46
  1130 00000710 [0A0A]                          DW      L$46
  1131 00000712 [0A0A]                          DW      L$46
  1132 00000714 [0A0A]                          DW      L$46
  1133 00000716 [0A0A]                          DW      L$46
  1134 00000718 [0A0A]                          DW      L$46
  1135 0000071A [0A0A]                          DW      L$46
  1136 0000071C [0A0A]                          DW      L$46
  1137 0000071E [0A0A]                          DW      L$46
  1138 00000720 [0A0A]                          DW      L$46
  1139 00000722 [0A0A]                          DW      L$46
  1140 00000724 [0A0A]                          DW      L$46
  1141 00000726 [290A]                          DW      L$49
  1142 00000728 [290A]                          DW      L$49
  1143 0000072A [290A]                          DW      L$49
  1144 0000072C [290A]                          DW      L$49
  1145 0000072E [290A]                          DW      L$49
  1146 00000730 [290A]                          DW      L$49
  1147 00000732 [290A]                          DW      L$49
  1148 00000734 [290A]                          DW      L$49
  1149 00000736 [310B]                          DW      L$62
  1150 00000738 [310B]                          DW      L$62
  1151 0000073A [310B]                          DW      L$62
  1152 0000073C [310B]                          DW      L$62
  1153 0000073E [310B]                          DW      L$62
  1154 00000740 [310B]                          DW      L$62
  1155 00000742 [3A0A]                          DW      L$50
  1156 00000744 [530A]                          DW      L$51
  1157 00000746 [6E0A]                          DW      L$52
  1158 00000748 [3A0A]                          DW      L$50
  1159 0000074A [880A]                          DW      L$53
  1160 0000074C [9F0A]                          DW      L$54
  1161 0000074E [3A0A]                          DW      L$50
  1162 00000750 [310B]                          DW      L$62
  1163 00000752 [B60A]                          DW      L$55
  1164 00000754 [B60A]                          DW      L$55
  1165 00000756 [310B]                          DW      L$62
  1166 00000758 [D70A]                          DW      L$58
  1167 0000075A [6E0A]                          DW      L$52
  1168 0000075C [EC0A]                          DW      L$59
  1169 0000075E [030B]                          DW      L$60
  1170 00000760 [1A0B]                          DW      L$61
  1171                                  disasm_:
  1172 00000762 51                              PUSH    cx
  1173 00000763 56                              PUSH    si
  1174 00000764 57                              PUSH    di
  1175 00000765 55                              PUSH    bp
  1176 00000766 89E5                            MOV     bp,sp
  1177 00000768 83EC3A                          SUB     sp,3aH
  1178 0000076B 52                              PUSH    dx
  1179 0000076C 53                              PUSH    bx
  1180 0000076D 31FF                            XOR     di,di
  1181 0000076F 897EE6                          MOV     word -1aH[bp],di
  1182 00000772 897EEE                          MOV     word -12H[bp],di
  1183 00000775 897EF2                          MOV     word -0eH[bp],di
  1184 00000778 8946E8                          MOV     word -18H[bp],ax
  1185 0000077B C746F0[4402]                    MOV     word -10H[bp],  _opcode1
  1186 00000780 897EFA                          MOV     word -6[bp],di
  1187 00000783 897EF8                          MOV     word -8[bp],di
  1188 00000786 EB3D                            JMP     L$14
  1189                                  L$7:
  1190 00000788 8A04                            MOV     al,byte [si]
  1191 0000078A 30E4                            XOR     ah,ah
  1192 0000078C 89C3                            MOV     bx,ax
  1193 0000078E D1E3                            SHL     bx,1
  1194 00000790 FFB7[C00E]                      PUSH    word _seg_regs-4[bx]
  1195 00000794 B8[6119]                        MOV     ax,  L$451
  1196 00000797 50                              PUSH    ax
  1197 00000798 8B46C4                          MOV     ax, word -3cH[bp]
  1198 0000079B 01F8                            ADD     ax,di
  1199 0000079D 50                              PUSH    ax
  1200 0000079E E80007                          CALL    near esprintf_
  1201 000007A1 83C406                          ADD     sp,6
  1202 000007A4 EB1D                            JMP     L$13
  1203                                  L$8:
  1204 000007A6 837EF800                        CMP     word -8[bp],0
  1205 000007AA 7505                            JNE     L$9
  1206 000007AC B80100                          MOV     ax,1
  1207 000007AF EB02                            JMP     L$10
  1208                                  L$9:
  1209 000007B1 31C0                            XOR     ax,ax
  1210                                  L$10:
  1211 000007B3 8946F8                          MOV     word -8[bp],ax
  1212 000007B6 EB0D                            JMP     L$14
  1213                                  L$11:
  1214 000007B8 BA[6519]                        MOV     dx,  L$452
  1215                                  L$12:
  1216 000007BB 52                              PUSH    dx
  1217 000007BC 50                              PUSH    ax
  1218 000007BD E8E106                          CALL    near esprintf_
  1219 000007C0 83C404                          ADD     sp,4
  1220                                  L$13:
  1221 000007C3 01C7                            ADD     di,ax
  1222                                  L$14:
  1223 000007C5 8D4EE6                          LEA     cx,-1aH[bp]
  1224 000007C8 8B5EC2                          MOV     bx, word -3eH[bp]
  1225 000007CB 8D56FC                          LEA     dx,-4[bp]
  1226 000007CE 8D46E8                          LEA     ax,-18H[bp]
  1227 000007D1 E854FE                          CALL    near get_byte_
  1228 000007D4 8A46FC                          MOV     al,byte -4[bp]
  1229 000007D7 30E4                            XOR     ah,ah
  1230 000007D9 B103                            MOV     cl,3
  1231 000007DB D3E0                            SHL     ax,cl
  1232 000007DD 8B76F0                          MOV     si, word -10H[bp]
  1233 000007E0 01C6                            ADD     si,ax
  1234 000007E2 F6440780                        TEST    byte 7[si],80H
  1235 000007E6 7434                            JE      L$20
  1236 000007E8 8A04                            MOV     al,byte [si]
  1237 000007EA 3C25                            CMP     al,25H
  1238 000007EC 7724                            JA      L$18
  1239 000007EE 30E4                            XOR     ah,ah
  1240 000007F0 89C3                            MOV     bx,ax
  1241 000007F2 D1E3                            SHL     bx,1
  1242 000007F4 8B46C4                          MOV     ax, word -3cH[bp]
  1243 000007F7 01F8                            ADD     ax,di
  1244 000007F9 FFA7[9A06]                      JMP     [L$5 + bx]
  1245                                  L$15:
  1246 000007FD BA[6C19]                        MOV     dx,  L$453
  1247 00000800 EBB9                            JMP     L$12
  1248                                  L$16:
  1249 00000802 B8[7119]                        MOV     ax,  L$454
  1250                                  L$17:
  1251 00000805 50                              PUSH    ax
  1252 00000806 FF76C4                          PUSH    word -3cH[bp]
  1253 00000809 E89506                          CALL    near esprintf_
  1254 0000080C 83C404                          ADD     sp,4
  1255 0000080F E93503                          JMP     near L$63
  1256                                  L$18:
  1257 00000812 B8[8519]                        MOV     ax,  L$455
  1258 00000815 EBEE                            JMP     L$17
  1259                                  L$19:
  1260 00000817 C746EE0100                      MOV     word -12H[bp],1
  1261                                  L$20:
  1262 0000081C F6440710                        TEST    byte 7[si],10H
  1263 00000820 7436                            JE      L$21
  1264 00000822 8D4EE6                          LEA     cx,-1aH[bp]
  1265 00000825 8B5EC2                          MOV     bx, word -3eH[bp]
  1266 00000828 8D56FE                          LEA     dx,-2[bp]
  1267 0000082B 8D46E8                          LEA     ax,-18H[bp]
  1268 0000082E E8F7FD                          CALL    near get_byte_
  1269 00000831 837EEE00                        CMP     word -12H[bp],0
  1270 00000835 7421                            JE      L$21
  1271 00000837 8A04                            MOV     al,byte [si]
  1272 00000839 30E4                            XOR     ah,ah
  1273 0000083B B106                            MOV     cl,6
  1274 0000083D D3E0                            SHL     ax,cl
  1275 0000083F 2D0005                          SUB     ax,500H
  1276 00000842 BE[440A]                        MOV     si,  _opcodeg
  1277 00000845 01C6                            ADD     si,ax
  1278 00000847 8A46FE                          MOV     al,byte -2[bp]
  1279 0000084A 30E4                            XOR     ah,ah
  1280 0000084C B103                            MOV     cl,3
  1281 0000084E D3F8                            SAR     ax,cl
  1282 00000850 30E4                            XOR     ah,ah
  1283 00000852 2407                            AND     al,7
  1284 00000854 D3E0                            SHL     ax,cl
  1285 00000856 01C6                            ADD     si,ax
  1286                                  L$21:
  1287 00000858 F6440740                        TEST    byte 7[si],40H
  1288 0000085C 740B                            JE      L$22
  1289 0000085E 837EF800                        CMP     word -8[bp],0
  1290 00000862 7405                            JE      L$22
  1291 00000864 C746F20100                      MOV     word -0eH[bp],1
  1292                                  L$22:
  1293 00000869 8A04                            MOV     al,byte [si]
  1294 0000086B 30E4                            XOR     ah,ah
  1295 0000086D 89C3                            MOV     bx,ax
  1296 0000086F 035EF2                          ADD     bx, word -0eH[bp]
  1297 00000872 D1E3                            SHL     bx,1
  1298 00000874 FFB7[0000]                      PUSH    word _opnames[bx]
  1299 00000878 B8[9C19]                        MOV     ax,  L$456
  1300 0000087B 50                              PUSH    ax
  1301 0000087C 8B46C4                          MOV     ax, word -3cH[bp]
  1302 0000087F 01F8                            ADD     ax,di
  1303 00000881 50                              PUSH    ax
  1304 00000882 E81C06                          CALL    near esprintf_
  1305 00000885 83C406                          ADD     sp,6
  1306 00000888 01C7                            ADD     di,ax
  1307                                  L$23:
  1308 0000088A 8B5EC4                          MOV     bx, word -3cH[bp]
  1309 0000088D 01FB                            ADD     bx,di
  1310 0000088F 83FF07                          CMP     di,7
  1311 00000892 7D06                            JGE     L$24
  1312 00000894 C60720                          MOV     byte [bx],20H
  1313 00000897 47                              INC     di
  1314 00000898 EBF0                            JMP     L$23
  1315                                  L$24:
  1316 0000089A C60700                          MOV     byte [bx],0
  1317 0000089D 8D5C02                          LEA     bx,2[si]
  1318 000008A0 895EF6                          MOV     word -0aH[bp],bx
  1319 000008A3 C746F40000                      MOV     word -0cH[bp],0
  1320                                  L$25:
  1321 000008A8 8A4401                          MOV     al,byte 1[si]
  1322 000008AB 30E4                            XOR     ah,ah
  1323 000008AD 3B46F4                          CMP     ax, word -0cH[bp]
  1324 000008B0 7E6F                            JLE     L$32
  1325 000008B2 C746EA0000                      MOV     word -16H[bp],0
  1326 000008B7 C746EC0000                      MOV     word -14H[bp],0
  1327 000008BC 8B5EF6                          MOV     bx, word -0aH[bp]
  1328 000008BF 8A07                            MOV     al,byte [bx]
  1329 000008C1 FEC8                            DEC     al
  1330 000008C3 3C3D                            CMP     al,3dH
  1331 000008C5 776C                            JA      L$34
  1332 000008C7 89C3                            MOV     bx,ax
  1333 000008C9 D1E3                            SHL     bx,1
  1334 000008CB FFA7[E606]                      JMP     [bx+L$6]
  1335                                  L$26:
  1336 000008CF 8B46FA                          MOV     ax, word -6[bp]
  1337 000008D2 D1E0                            SHL     ax,1
  1338 000008D4 40                              INC     ax
  1339 000008D5 40                              INC     ax
  1340                                  L$27:
  1341 000008D6 50                              PUSH    ax
  1342 000008D7 8D4EE6                          LEA     cx,-1aH[bp]
  1343 000008DA 8B5EC2                          MOV     bx, word -3eH[bp]
  1344 000008DD 8D56EA                          LEA     dx,-16H[bp]
  1345 000008E0 8D46E8                          LEA     ax,-18H[bp]
  1346 000008E3 E87FFD                          CALL    near get_bytes_
  1347                                  L$28:
  1348 000008E6 FF76EA                          PUSH    word -16H[bp]
  1349 000008E9 B8[A019]                        MOV     ax,  L$457
  1350 000008EC E92D01                          JMP     near L$48
  1351                                  L$29:
  1352 000008EF 8D4EE6                          LEA     cx,-1aH[bp]
  1353 000008F2 8B5EC2                          MOV     bx, word -3eH[bp]
  1354 000008F5 8D56EA                          LEA     dx,-16H[bp]
  1355 000008F8 8D46E8                          LEA     ax,-18H[bp]
  1356 000008FB E82AFD                          CALL    near get_byte_
  1357 000008FE EBE6                            JMP     L$28
  1358                                  L$30:
  1359 00000900 8B46F8                          MOV     ax, word -8[bp]
  1360 00000903 D1E0                            SHL     ax,1
  1361 00000905 40                              INC     ax
  1362 00000906 40                              INC     ax
  1363 00000907 50                              PUSH    ax
  1364 00000908 8D4EE6                          LEA     cx,-1aH[bp]
  1365 0000090B 8B5EC2                          MOV     bx, word -3eH[bp]
  1366 0000090E 8D56EA                          LEA     dx,-16H[bp]
  1367 00000911 8D46E8                          LEA     ax,-18H[bp]
  1368 00000914 E84EFD                          CALL    near get_bytes_
  1369 00000917 FF76EA                          PUSH    word -16H[bp]
  1370 0000091A EB41                            JMP     L$38
  1371                                  L$31:
  1372 0000091C B80200                          MOV     ax,2
  1373 0000091F EBB5                            JMP     L$27
  1374                                  L$32:
  1375 00000921 E92302                          JMP     near L$63
  1376                                  L$33:
  1377 00000924 8B5EFA                          MOV     bx, word -6[bp]
  1378 00000927 D1E3                            SHL     bx,1
  1379 00000929 FFB7[4E0F]                      PUSH    word _dssi_regs[bx]
  1380 0000092D B8[A819]                        MOV     ax,  L$459
  1381 00000930 E9E900                          JMP     near L$48
  1382                                  L$34:
  1383 00000933 E9FB01                          JMP     near L$62
  1384                                  L$35:
  1385 00000936 8B5EFA                          MOV     bx, word -6[bp]
  1386 00000939 D1E3                            SHL     bx,1
  1387 0000093B FFB7[4A0F]                      PUSH    word _esdi_regs[bx]
  1388 0000093F B8[AE19]                        MOV     ax,  L$460
  1389 00000942 E9D700                          JMP     near L$48
  1390                                  L$36:
  1391 00000945 8D4EE6                          LEA     cx,-1aH[bp]
  1392 00000948 8B5EC2                          MOV     bx, word -3eH[bp]
  1393 0000094B 8D56EA                          LEA     dx,-16H[bp]
  1394 0000094E 8D46E8                          LEA     ax,-18H[bp]
  1395 00000951 E8D4FC                          CALL    near get_byte_
  1396 00000954 8A46EA                          MOV     al,byte -16H[bp]
  1397 00000957 30E4                            XOR     ah,ah
  1398 00000959 0346E8                          ADD     ax, word -18H[bp]
  1399                                  L$37:
  1400 0000095C 50                              PUSH    ax
  1401                                  L$38:
  1402 0000095D B8[A319]                        MOV     ax,  L$458
  1403 00000960 E9B900                          JMP     near L$48
  1404                                  L$39:
  1405 00000963 8B46F8                          MOV     ax, word -8[bp]
  1406 00000966 D1E0                            SHL     ax,1
  1407 00000968 40                              INC     ax
  1408 00000969 40                              INC     ax
  1409 0000096A 50                              PUSH    ax
  1410 0000096B 8D4EE6                          LEA     cx,-1aH[bp]
  1411 0000096E 8B5EC2                          MOV     bx, word -3eH[bp]
  1412 00000971 8D56EA                          LEA     dx,-16H[bp]
  1413 00000974 8D46E8                          LEA     ax,-18H[bp]
  1414 00000977 E8EBFC                          CALL    near get_bytes_
  1415 0000097A 8B46E8                          MOV     ax, word -18H[bp]
  1416 0000097D 0346EA                          ADD     ax, word -16H[bp]
  1417 00000980 EBDA                            JMP     L$37
  1418                                  L$40:
  1419 00000982 8B46F8                          MOV     ax, word -8[bp]
  1420 00000985 D1E0                            SHL     ax,1
  1421 00000987 40                              INC     ax
  1422 00000988 40                              INC     ax
  1423 00000989 50                              PUSH    ax
  1424 0000098A 8D4EE6                          LEA     cx,-1aH[bp]
  1425 0000098D 8B5EC2                          MOV     bx, word -3eH[bp]
  1426 00000990 8D56EA                          LEA     dx,-16H[bp]
  1427 00000993 8D46E8                          LEA     ax,-18H[bp]
  1428 00000996 E8CCFC                          CALL    near get_bytes_
  1429 00000999 B80200                          MOV     ax,2
  1430 0000099C 50                              PUSH    ax
  1431 0000099D 8D4EE6                          LEA     cx,-1aH[bp]
  1432 000009A0 8B5EC2                          MOV     bx, word -3eH[bp]
  1433 000009A3 8D56EC                          LEA     dx,-14H[bp]
  1434 000009A6 8D46E8                          LEA     ax,-18H[bp]
  1435 000009A9 E8B9FC                          CALL    near get_bytes_
  1436 000009AC FF76EA                          PUSH    word -16H[bp]
  1437 000009AF FF76EC                          PUSH    word -14H[bp]
  1438 000009B2 B8[B419]                        MOV     ax,  L$461
  1439 000009B5 50                              PUSH    ax
  1440 000009B6 8D46C6                          LEA     ax,-3aH[bp]
  1441 000009B9 50                              PUSH    ax
  1442 000009BA E8E404                          CALL    near esprintf_
  1443 000009BD 83C408                          ADD     sp,8
  1444                                  L$41:
  1445 000009C0 8D46C6                          LEA     ax,-3aH[bp]
  1446 000009C3 50                              PUSH    ax
  1447 000009C4 B8[C119]                        MOV     ax,  L$463
  1448 000009C7 50                              PUSH    ax
  1449 000009C8 8B46C4                          MOV     ax, word -3cH[bp]
  1450 000009CB 01F8                            ADD     ax,di
  1451 000009CD 50                              PUSH    ax
  1452 000009CE E8D004                          CALL    near esprintf_
  1453 000009D1 83C406                          ADD     sp,6
  1454 000009D4 01C7                            ADD     di,ax
  1455 000009D6 8A4401                          MOV     al,byte 1[si]
  1456 000009D9 30E4                            XOR     ah,ah
  1457 000009DB 48                              DEC     ax
  1458 000009DC 3B46F4                          CMP     ax, word -0cH[bp]
  1459 000009DF 7E12                            JLE     L$42
  1460 000009E1 B8[DD19]                        MOV     ax,  L$465
  1461 000009E4 50                              PUSH    ax
  1462 000009E5 8B46C4                          MOV     ax, word -3cH[bp]
  1463 000009E8 01F8                            ADD     ax,di
  1464 000009EA 50                              PUSH    ax
  1465 000009EB E8B304                          CALL    near esprintf_
  1466 000009EE 83C404                          ADD     sp,4
  1467 000009F1 01C7                            ADD     di,ax
  1468                                  L$42:
  1469 000009F3 FF46F4                          INC     word -0cH[bp]
  1470 000009F6 FF46F6                          INC     word -0aH[bp]
  1471 000009F9 E9ACFE                          JMP     near L$25
  1472                                  L$43:
  1473 000009FC B80100                          MOV     ax,1
  1474                                  L$44:
  1475 000009FF 50                              PUSH    ax
  1476 00000A00 B8[BE19]                        MOV     ax,  L$462
  1477 00000A03 EB17                            JMP     L$48
  1478                                  L$45:
  1479 00000A05 B80300                          MOV     ax,3
  1480 00000A08 EBF5                            JMP     L$44
  1481                                  L$46:
  1482 00000A0A 8B5EF6                          MOV     bx, word -0aH[bp]
  1483 00000A0D 8A07                            MOV     al,byte [bx]
  1484 00000A0F 30E4                            XOR     ah,ah
  1485 00000A11 89C3                            MOV     bx,ax
  1486 00000A13 D1E3                            SHL     bx,1
  1487 00000A15 FFB7[E80E]                      PUSH    word _direct_regs-24H[bx]
  1488                                  L$47:
  1489 00000A19 B8[C119]                        MOV     ax,  L$463
  1490                                  L$48:
  1491 00000A1C 50                              PUSH    ax
  1492 00000A1D 8D46C6                          LEA     ax,-3aH[bp]
  1493 00000A20 50                              PUSH    ax
  1494 00000A21 E87D04                          CALL    near esprintf_
  1495 00000A24 83C406                          ADD     sp,6
  1496 00000A27 EB97                            JMP     L$41
  1497                                  L$49:
  1498 00000A29 8B5EF6                          MOV     bx, word -0aH[bp]
  1499 00000A2C 8A07                            MOV     al,byte [bx]
  1500 00000A2E 30E4                            XOR     ah,ah
  1501 00000A30 89C3                            MOV     bx,ax
  1502 00000A32 D1E3                            SHL     bx,1
  1503 00000A34 FFB7[BA0E]                      PUSH    word _ea_regs-32H[bx]
  1504 00000A38 EBDF                            JMP     L$47
  1505                                  L$50:
  1506 00000A3A 8D46C6                          LEA     ax,-3aH[bp]
  1507 00000A3D 50                              PUSH    ax
  1508 00000A3E 8D46E6                          LEA     ax,-1aH[bp]
  1509 00000A41 50                              PUSH    ax
  1510 00000A42 FF76C2                          PUSH    word -3eH[bp]
  1511 00000A45 8A46FE                          MOV     al,byte -2[bp]
  1512 00000A48 30E4                            XOR     ah,ah
  1513 00000A4A 8D4EE8                          LEA     cx,-18H[bp]
  1514 00000A4D 89C3                            MOV     bx,ax
  1515 00000A4F 31D2                            XOR     dx,dx
  1516 00000A51 EB7B                            JMP     L$57
  1517                                  L$51:
  1518 00000A53 8D46C6                          LEA     ax,-3aH[bp]
  1519 00000A56 50                              PUSH    ax
  1520 00000A57 8D46E6                          LEA     ax,-1aH[bp]
  1521 00000A5A 50                              PUSH    ax
  1522 00000A5B FF76C2                          PUSH    word -3eH[bp]
  1523 00000A5E 8A46FE                          MOV     al,byte -2[bp]
  1524 00000A61 30E4                            XOR     ah,ah
  1525 00000A63 8B56F8                          MOV     dx, word -8[bp]
  1526 00000A66 42                              INC     dx
  1527 00000A67 8D4EE8                          LEA     cx,-18H[bp]
  1528 00000A6A 89C3                            MOV     bx,ax
  1529 00000A6C EB60                            JMP     L$57
  1530                                  L$52:
  1531 00000A6E 8D46C6                          LEA     ax,-3aH[bp]
  1532 00000A71 50                              PUSH    ax
  1533 00000A72 8D46E6                          LEA     ax,-1aH[bp]
  1534 00000A75 50                              PUSH    ax
  1535 00000A76 FF76C2                          PUSH    word -3eH[bp]
  1536 00000A79 8A46FE                          MOV     al,byte -2[bp]
  1537 00000A7C 30E4                            XOR     ah,ah
  1538 00000A7E 8D4EE8                          LEA     cx,-18H[bp]
  1539 00000A81 89C3                            MOV     bx,ax
  1540 00000A83 BA0100                          MOV     dx,1
  1541 00000A86 EB46                            JMP     L$57
  1542                                  L$53:
  1543 00000A88 8A46FE                          MOV     al,byte -2[bp]
  1544 00000A8B B103                            MOV     cl,3
  1545 00000A8D 89C3                            MOV     bx,ax
  1546 00000A8F D3FB                            SAR     bx,cl
  1547 00000A91 30FF                            XOR     bh,bh
  1548 00000A93 80E307                          AND     bl,7
  1549 00000A96 D1E3                            SHL     bx,1
  1550 00000A98 FFB7[EC0E]                      PUSH    word _ea_regs[bx]
  1551 00000A9C E97AFF                          JMP     near L$47
  1552                                  L$54:
  1553 00000A9F 8A46FE                          MOV     al,byte -2[bp]
  1554 00000AA2 B103                            MOV     cl,3
  1555 00000AA4 89C3                            MOV     bx,ax
  1556 00000AA6 D3FB                            SAR     bx,cl
  1557 00000AA8 30FF                            XOR     bh,bh
  1558 00000AAA 80E307                          AND     bl,7
  1559 00000AAD D1E3                            SHL     bx,1
  1560 00000AAF FFB7[FC0E]                      PUSH    word _ea_regs+10H[bx]
  1561 00000AB3 E963FF                          JMP     near L$47
  1562                                  L$55:
  1563 00000AB6 8D46C6                          LEA     ax,-3aH[bp]
  1564 00000AB9 50                              PUSH    ax
  1565 00000ABA 8D46E6                          LEA     ax,-1aH[bp]
  1566 00000ABD 50                              PUSH    ax
  1567 00000ABE FF76C2                          PUSH    word -3eH[bp]
  1568 00000AC1 8A46FE                          MOV     al,byte -2[bp]
  1569 00000AC4 30E4                            XOR     ah,ah
  1570 00000AC6 8D4EE8                          LEA     cx,-18H[bp]
  1571 00000AC9 89C3                            MOV     bx,ax
  1572                                  L$56:
  1573 00000ACB BA0200                          MOV     dx,2
  1574                                  L$57:
  1575 00000ACE 8B46FA                          MOV     ax, word -6[bp]
  1576 00000AD1 E87F00                          CALL    near dec_modrm_
  1577 00000AD4 E9E9FE                          JMP     near L$41
  1578                                  L$58:
  1579 00000AD7 8D46C6                          LEA     ax,-3aH[bp]
  1580 00000ADA 50                              PUSH    ax
  1581 00000ADB 8D46E6                          LEA     ax,-1aH[bp]
  1582 00000ADE 50                              PUSH    ax
  1583 00000ADF FF76C2                          PUSH    word -3eH[bp]
  1584 00000AE2 8A5EFE                          MOV     bl,byte -2[bp]
  1585 00000AE5 30FF                            XOR     bh,bh
  1586 00000AE7 8D4EE8                          LEA     cx,-18H[bp]
  1587 00000AEA EBDF                            JMP     L$56
  1588                                  L$59:
  1589 00000AEC 8A46FE                          MOV     al,byte -2[bp]
  1590 00000AEF B103                            MOV     cl,3
  1591 00000AF1 89C3                            MOV     bx,ax
  1592 00000AF3 D3FB                            SAR     bx,cl
  1593 00000AF5 30FF                            XOR     bh,bh
  1594 00000AF7 80E307                          AND     bl,7
  1595 00000AFA D1E3                            SHL     bx,1
  1596 00000AFC FFB7[C40E]                      PUSH    word _seg_regs[bx]
  1597 00000B00 E916FF                          JMP     near L$47
  1598                                  L$60:
  1599 00000B03 8A46FE                          MOV     al,byte -2[bp]
  1600 00000B06 B103                            MOV     cl,3
  1601 00000B08 89C3                            MOV     bx,ax
  1602 00000B0A D3FB                            SAR     bx,cl
  1603 00000B0C 30FF                            XOR     bh,bh
  1604 00000B0E 80E307                          AND     bl,7
  1605 00000B11 D1E3                            SHL     bx,1
  1606 00000B13 FFB7[2A0F]                      PUSH    word _cntrl_regs[bx]
  1607 00000B17 E9FFFE                          JMP     near L$47
  1608                                  L$61:
  1609 00000B1A 8A46FE                          MOV     al,byte -2[bp]
  1610 00000B1D B103                            MOV     cl,3
  1611 00000B1F 89C3                            MOV     bx,ax
  1612 00000B21 D3FB                            SAR     bx,cl
  1613 00000B23 30FF                            XOR     bh,bh
  1614 00000B25 80E307                          AND     bl,7
  1615 00000B28 D1E3                            SHL     bx,1
  1616 00000B2A FFB7[3A0F]                      PUSH    word _debug_regs[bx]
  1617 00000B2E E9E8FE                          JMP     near L$47
  1618                                  L$62:
  1619 00000B31 8B5EF6                          MOV     bx, word -0aH[bp]
  1620 00000B34 8A07                            MOV     al,byte [bx]
  1621 00000B36 30E4                            XOR     ah,ah
  1622 00000B38 50                              PUSH    ax
  1623 00000B39 B8[C419]                        MOV     ax,  L$464
  1624 00000B3C 50                              PUSH    ax
  1625 00000B3D 037EC4                          ADD     di, word -3cH[bp]
  1626 00000B40 57                              PUSH    di
  1627 00000B41 E85D03                          CALL    near esprintf_
  1628 00000B44 83C406                          ADD     sp,6
  1629                                  L$63:
  1630 00000B47 8B4EE8                          MOV     cx, word -18H[bp]
  1631 00000B4A 89C8                            MOV     ax,cx
  1632                                  L$64:
  1633 00000B4C 89EC                            MOV     sp,bp
  1634 00000B4E 5D                              POP     bp
  1635 00000B4F 5F                              POP     di
  1636 00000B50 5E                              POP     si
  1637 00000B51 59                              POP     cx
  1638 00000B52 C3                              RET
  1639
  1640                                  dec_modrm_:
  1641 00000B53 56                              PUSH    si
  1642 00000B54 57                              PUSH    di
  1643 00000B55 55                              PUSH    bp
  1644 00000B56 89E5                            MOV     bp,sp
  1645 00000B58 83EC22                          SUB     sp,22H
  1646 00000B5B 52                              PUSH    DX
  1647 00000B5C 89CE                            MOV     si,cx
  1648 00000B5E 8B7E0A                          MOV     di, word 0aH[bp]
  1649 00000B61 88D8                            MOV     al,bl
  1650 00000B63 30E4                            XOR     ah,ah
  1651 00000B65 B106                            MOV     cl,6
  1652 00000B67 D3F8                            SAR     ax,cl
  1653 00000B69 30E4                            XOR     ah,ah
  1654 00000B6B 88C2                            MOV     dl,al
  1655 00000B6D 80E203                          AND     dl,3
  1656 00000B70 88DE                            MOV     dh,bl
  1657 00000B72 80E607                          AND     dh,7
  1658 00000B75 C746FE0000                      MOV     word -2[bp],0
  1659 00000B7A 88F0                            MOV     al,dh
  1660 00000B7C 89C3                            MOV     bx,ax
  1661 00000B7E D1E3                            SHL     bx,1
  1662 00000B80 FFB7[DC0E]                      PUSH    word _ea_modes[bx]
  1663 00000B84 B8[E019]                        MOV     ax,  L$466
  1664 00000B87 50                              PUSH    ax
  1665 00000B88 8D46DE                          LEA     ax,-22H[bp]
  1666 00000B8B 50                              PUSH    ax
  1667 00000B8C E81203                          CALL    near esprintf_
  1668 00000B8F 83C406                          ADD     sp,6
  1669 00000B92 80FA03                          CMP     dl,3
  1670 00000B95 751C                            JNE     L$67
  1671
  1672 00000B97 B104                            MOV     cl,4
  1673 00000B99 8B46DC                          MOV     ax, word -24H[bp]
  1674 00000B9C D3E0                            SHL     ax,cl
  1675 00000B9E 01C3                            ADD     bx,ax
  1676
  1677 00000BA0 FFB7[EC0E]                      PUSH    word _ea_regs[bx]
  1678                                  L$65:
  1679 00000BA4 B8[C119]                        MOV     ax,  L$463
  1680                                  L$66:
  1681 00000BA7 50                              PUSH    ax
  1682 00000BA8 FF760C                          PUSH    word 0cH[bp]
  1683 00000BAB E8F302                          CALL    near esprintf_
  1684 00000BAE 83C406                          ADD     sp,6
  1685 00000BB1 EB56                            JMP     L$71
  1686                                  L$67:
  1687 00000BB3 84D2                            TEST    dl,dl
  1688 00000BB5 752C                            JNE     L$69
  1689 00000BB7 38CE                            CMP     dh,cl
  1690 00000BB9 7522                            JNE     L$68
  1691 00000BBB 89F9                            MOV     cx,di
  1692 00000BBD 8B5E08                          MOV     bx, word 8[bp]
  1693 00000BC0 8D56FE                          LEA     dx,-2[bp]
  1694 00000BC3 89F0                            MOV     ax,si
  1695 00000BC5 E860FA                          CALL    near get_byte_
  1696 00000BC8 89F9                            MOV     cx,di
  1697 00000BCA 8B5E08                          MOV     bx, word 8[bp]
  1698 00000BCD 8D56FF                          LEA     dx,-1[bp]
  1699 00000BD0 89F0                            MOV     ax,si
  1700 00000BD2 E853FA                          CALL    near get_byte_
  1701 00000BD5 FF76FE                          PUSH    word -2[bp]
  1702 00000BD8 B8[E519]                        MOV     ax,  L$467
  1703 00000BDB EBCA                            JMP     L$66
  1704                                  L$68:
  1705 00000BDD 8D46DE                          LEA     ax,-22H[bp]
  1706 00000BE0 50                              PUSH    ax
  1707 00000BE1 EBC1                            JMP     L$65
  1708                                  L$69:
  1709 00000BE3 80FA01                          CMP     dl,1
  1710 00000BE6 7525                            JNE     L$72
  1711 00000BE8 89F9                            MOV     cx,di
  1712 00000BEA 8B5E08                          MOV     bx, word 8[bp]
  1713 00000BED 8D56FE                          LEA     dx,-2[bp]
  1714                                  L$70:
  1715 00000BF0 89F0                            MOV     ax,si
  1716 00000BF2 E833FA                          CALL    near get_byte_
  1717 00000BF5 FF76FE                          PUSH    word -2[bp]
  1718 00000BF8 8D46DE                          LEA     ax,-22H[bp]
  1719 00000BFB 50                              PUSH    ax
  1720 00000BFC B8[EA19]                        MOV     ax,  L$468
  1721 00000BFF 50                              PUSH    ax
  1722 00000C00 FF760C                          PUSH    word 0cH[bp]
  1723 00000C03 E89B02                          CALL    near esprintf_
  1724 00000C06 83C408                          ADD     sp,8
  1725                                  L$71:
  1726 00000C09 31C0                            XOR     ax,ax
  1727 00000C0B EB1F                            JMP     L$74
  1728                                  L$72:
  1729 00000C0D 80FA02                          CMP     dl,2
  1730 00000C10 7517                            JNE     L$73
  1731 00000C12 89F9                            MOV     cx,di
  1732 00000C14 8B5E08                          MOV     bx, word 8[bp]
  1733 00000C17 8D56FE                          LEA     dx,-2[bp]
  1734 00000C1A 89F0                            MOV     ax,si
  1735 00000C1C E809FA                          CALL    near get_byte_
  1736 00000C1F 89F9                            MOV     cx,di
  1737 00000C21 8B5E08                          MOV     bx, word 8[bp]
  1738 00000C24 8D56FF                          LEA     dx,-1[bp]
  1739 00000C27 EBC7                            JMP     L$70
  1740                                  L$73:
  1741 00000C29 B8FFFF                          MOV     ax,0ffffH
  1742                                  L$74:
  1743 00000C2C 89EC                            MOV     sp,bp
  1744 00000C2E 5D                              POP     bp
  1745 00000C2F 5F                              POP     di
  1746 00000C30 5E                              POP     si
  1747 00000C31 C20600                          RET     6
  1748                                  printchar_:
  1749 00000C34 53                              PUSH    bx
  1750 00000C35 56                              PUSH    si
  1751 00000C36 89C3                            MOV     bx,ax
  1752 00000C38 89D0                            MOV     ax,dx
  1753 00000C3A 85DB                            TEST    bx,bx
  1754 00000C3C 7409                            JE      L$75
  1755 00000C3E 8B37                            MOV     si, word [bx]
  1756 00000C40 8814                            MOV     byte [si],dl
  1757 00000C42 FF07                            INC     word [bx]
  1758 00000C44 5E                              POP     si
  1759 00000C45 5B                              POP     bx
  1760 00000C46 C3                              RET
  1761                                  L$75:
  1762 00000C47 E85603                          CALL    TXCHAR
  1763 00000C4A 5E                              POP     si
  1764 00000C4B 5B                              POP     bx
  1765 00000C4C C3                              RET
  1766                                  prints_:
  1767 00000C4D 56                              PUSH    si
  1768 00000C4E 57                              PUSH    di
  1769 00000C4F 55                              PUSH    bp
  1770 00000C50 89E5                            MOV     bp,sp
  1771 00000C52 50                              PUSH    ax
  1772 00000C53 50                              PUSH    ax
  1773 00000C54 89D6                            MOV     si,dx
  1774 00000C56 89CA                            MOV     dx,cx
  1775 00000C58 31C9                            XOR     cx,cx
  1776 00000C5A C746FE2000                      MOV     word -2[bp],20H
  1777 00000C5F 85DB                            TEST    bx,bx
  1778 00000C61 7E21                            JLE     L$80
  1779 00000C63 31C0                            XOR     ax,ax
  1780 00000C65 89F7                            MOV     di,si
  1781                                  L$76:
  1782 00000C67 803D00                          CMP     byte [di],0
  1783 00000C6A 7404                            JE      L$77
  1784 00000C6C 40                              INC     ax
  1785 00000C6D 47                              INC     di
  1786 00000C6E EBF7                            JMP     L$76
  1787                                  L$77:
  1788 00000C70 39D8                            CMP     ax,bx
  1789 00000C72 7C04                            JL      L$78
  1790 00000C74 31DB                            XOR     bx,bx
  1791 00000C76 EB02                            JMP     L$79
  1792                                  L$78:
  1793 00000C78 29C3                            SUB     bx,ax
  1794                                  L$79:
  1795 00000C7A F6C202                          TEST    dl,2
  1796 00000C7D 7405                            JE      L$80
  1797 00000C7F C746FE3000                      MOV     word -2[bp],30H
  1798                                  L$80:
  1799 00000C84 F6C201                          TEST    dl,1
  1800 00000C87 7511                            JNE     L$82
  1801                                  L$81:
  1802 00000C89 85DB                            TEST    bx,bx
  1803 00000C8B 7E0D                            JLE     L$82
  1804 00000C8D 8B56FE                          MOV     dx, word -2[bp]
  1805 00000C90 8B46FC                          MOV     ax, word -4[bp]
  1806 00000C93 E89EFF                          CALL    near printchar_
  1807 00000C96 41                              INC     cx
  1808 00000C97 4B                              DEC     bx
  1809 00000C98 EBEF                            JMP     L$81
  1810                                  L$82:
  1811 00000C9A 803C00                          CMP     byte [si],0
  1812 00000C9D 7410                            JE      L$83
  1813 00000C9F 8A04                            MOV     al,byte [si]
  1814 00000CA1 30E4                            XOR     ah,ah
  1815 00000CA3 89C2                            MOV     dx,ax
  1816 00000CA5 8B46FC                          MOV     ax, word -4[bp]
  1817 00000CA8 E889FF                          CALL    near printchar_
  1818 00000CAB 41                              INC     cx
  1819 00000CAC 46                              INC     si
  1820 00000CAD EBEB                            JMP     L$82
  1821                                  L$83:
  1822 00000CAF 85DB                            TEST    bx,bx
  1823 00000CB1 7E0D                            JLE     L$84
  1824 00000CB3 8B56FE                          MOV     dx, word -2[bp]
  1825 00000CB6 8B46FC                          MOV     ax, word -4[bp]
  1826 00000CB9 E878FF                          CALL    near printchar_
  1827 00000CBC 41                              INC     cx
  1828 00000CBD 4B                              DEC     bx
  1829 00000CBE EBEF                            JMP     L$83
  1830                                  L$84:
  1831 00000CC0 89C8                            MOV     ax,cx
  1832 00000CC2 E99AF9                          JMP     near L$2
  1833                                  printi_:
  1834 00000CC5 56                              PUSH    si
  1835 00000CC6 57                              PUSH    di
  1836 00000CC7 55                              PUSH    bp
  1837 00000CC8 89E5                            MOV     bp,sp
  1838 00000CCA 83EC12                          SUB     sp,12H
  1839 00000CCD 89C7                            MOV     di,ax
  1840 00000CCF 895EFA                          MOV     word -6[bp],bx
  1841 00000CD2 C746FC0000                      MOV     word -4[bp],0
  1842 00000CD7 C746FE0000                      MOV     word -2[bp],0
  1843 00000CDC 89D3                            MOV     bx,dx
  1844 00000CDE 85D2                            TEST    dx,dx
  1845 00000CE0 7514                            JNE     L$85
  1846 00000CE2 C746EE3000                      MOV     word -12H[bp],30H
  1847 00000CE7 8B4E0A                          MOV     cx, word 0aH[bp]
  1848 00000CEA 8B5E08                          MOV     bx, word 8[bp]
  1849 00000CED 8D56EE                          LEA     dx,-12H[bp]
  1850 00000CF0 E85AFF                          CALL    near prints_
  1851 00000CF3 E936FF                          JMP     near L$74
  1852                                  L$85:
  1853 00000CF6 85C9                            TEST    cx,cx
  1854 00000CF8 7411                            JE      L$86
  1855 00000CFA 837EFA0A                        CMP     word -6[bp],0aH
  1856 00000CFE 750B                            JNE     L$86
  1857 00000D00 85D2                            TEST    dx,dx
  1858 00000D02 7D07                            JGE     L$86
  1859 00000D04 C746FC0100                      MOV     word -4[bp],1
  1860 00000D09 F7DB                            NEG     bx
  1861                                  L$86:
  1862 00000D0B 8D76F9                          LEA     si,-7[bp]
  1863 00000D0E C646F900                        MOV     byte -7[bp],0
  1864                                  L$87:
  1865 00000D12 85DB                            TEST    bx,bx
  1866 00000D14 7426                            JE      L$89
  1867 00000D16 89D8                            MOV     ax,bx
  1868 00000D18 31D2                            XOR     dx,dx
  1869 00000D1A F776FA                          DIV     word -6[bp]
  1870 00000D1D 83FA0A                          CMP     dx,0aH
  1871 00000D20 7C08                            JL      L$88
  1872 00000D22 8B460C                          MOV     ax, word 0cH[bp]
  1873 00000D25 83E83A                          SUB     ax,3aH
  1874 00000D28 01C2                            ADD     dx,ax
  1875                                  L$88:
  1876 00000D2A 88D0                            MOV     al,dl
  1877 00000D2C 0430                            ADD     al,30H
  1878 00000D2E 4E                              DEC     si
  1879 00000D2F 8804                            MOV     byte [si],al
  1880 00000D31 89D8                            MOV     ax,bx
  1881 00000D33 31D2                            XOR     dx,dx
  1882 00000D35 F776FA                          DIV     word -6[bp]
  1883 00000D38 89C3                            MOV     bx,ax
  1884 00000D3A EBD6                            JMP     L$87
  1885                                  L$89:
  1886 00000D3C 837EFC00                        CMP     word -4[bp],0
  1887 00000D40 7420                            JE      L$91
  1888 00000D42 837E0800                        CMP     word 8[bp],0
  1889 00000D46 7416                            JE      L$90
  1890 00000D48 F6460A02                        TEST    byte 0aH[bp],2
  1891 00000D4C 7410                            JE      L$90
  1892 00000D4E BA2D00                          MOV     dx,2dH
  1893 00000D51 89F8                            MOV     ax,di
  1894 00000D53 E8DEFE                          CALL    near printchar_
  1895 00000D56 FF46FE                          INC     word -2[bp]
  1896 00000D59 FF4E08                          DEC     word 8[bp]
  1897 00000D5C EB04                            JMP     L$91
  1898                                  L$90:
  1899 00000D5E 4E                              DEC     si
  1900 00000D5F C6042D                          MOV     byte [si],2dH
  1901                                  L$91:
  1902 00000D62 8B4E0A                          MOV     cx, word 0aH[bp]
  1903 00000D65 8B5E08                          MOV     bx, word 8[bp]
  1904 00000D68 89F2                            MOV     dx,si
  1905 00000D6A 89F8                            MOV     ax,di
  1906 00000D6C E8DEFE                          CALL    near prints_
  1907 00000D6F 0346FE                          ADD     ax, word -2[bp]
  1908 00000D72 E9B7FE                          JMP     near L$74
  1909                                  print_:
  1910 00000D75 51                              PUSH    cx
  1911 00000D76 56                              PUSH    si
  1912 00000D77 57                              PUSH    di
  1913 00000D78 55                              PUSH    bp
  1914 00000D79 89E5                            MOV     bp,sp
  1915 00000D7B 50                              PUSH    ax
  1916 00000D7C 50                              PUSH    ax
  1917 00000D7D 50                              PUSH    ax
  1918 00000D7E 89D6                            MOV     si,dx
  1919 00000D80 89DF                            MOV     di,bx
  1920 00000D82 C746FE0000                      MOV     word -2[bp],0
  1921                                  L$92:
  1922 00000D87 803C00                          CMP     byte [si],0
  1923 00000D8A 745F                            JE      L$96
  1924 00000D8C 803C25                          CMP     byte [si],25H
  1925 00000D8F 755D                            JNE     L$97
  1926 00000D91 31C9                            XOR     cx,cx
  1927 00000D93 31D2                            XOR     dx,dx
  1928 00000D95 46                              INC     si
  1929 00000D96 803C00                          CMP     byte [si],0
  1930 00000D99 7450                            JE      L$96
  1931 00000D9B 803C25                          CMP     byte [si],25H
  1932 00000D9E 744E                            JE      L$97
  1933 00000DA0 803C2D                          CMP     byte [si],2dH
  1934 00000DA3 7505                            JNE     L$93
  1935 00000DA5 B90100                          MOV     cx,1
  1936 00000DA8 01CE                            ADD     si,cx
  1937                                  L$93:
  1938 00000DAA 803C30                          CMP     byte [si],30H
  1939 00000DAD 7506                            JNE     L$94
  1940 00000DAF 80C902                          OR      cl,2
  1941 00000DB2 46                              INC     si
  1942 00000DB3 EBF5                            JMP     L$93
  1943                                  L$94:
  1944 00000DB5 803C30                          CMP     byte [si],30H
  1945 00000DB8 721A                            JB      L$95
  1946 00000DBA 803C39                          CMP     byte [si],39H
  1947 00000DBD 7715                            JA      L$95
  1948 00000DBF 89D0                            MOV     ax,dx
  1949 00000DC1 BA0A00                          MOV     dx,0aH
  1950 00000DC4 F7EA                            IMUL    dx
  1951 00000DC6 89C2                            MOV     dx,ax
  1952 00000DC8 8A1C                            MOV     bl,byte [si]
  1953 00000DCA 30FF                            XOR     bh,bh
  1954 00000DCC 83EB30                          SUB     bx,30H
  1955 00000DCF 01DA                            ADD     dx,bx
  1956 00000DD1 46                              INC     si
  1957 00000DD2 EBE1                            JMP     L$94
  1958                                  L$95:
  1959 00000DD4 803C73                          CMP     byte [si],73H
  1960 00000DD7 7527                            JNE     L$101
  1961 00000DD9 830502                          ADD     word [di],2
  1962 00000DDC 8B1D                            MOV     bx, word [di]
  1963 00000DDE 8B47FE                          MOV     ax, word -2[bx]
  1964 00000DE1 89D3                            MOV     bx,dx
  1965 00000DE3 85C0                            TEST    ax,ax
  1966 00000DE5 740A                            JE      L$98
  1967 00000DE7 89C2                            MOV     dx,ax
  1968 00000DE9 EB09                            JMP     L$99
  1969                                  L$96:
  1970 00000DEB E99B00                          JMP     near L$111
  1971                                  L$97:
  1972 00000DEE E98700                          JMP     near L$109
  1973                                  L$98:
  1974 00000DF1 BA[F019]                        MOV     dx,  L$469
  1975                                  L$99:
  1976 00000DF4 8B46FA                          MOV     ax, word -6[bp]
  1977 00000DF7 E853FE                          CALL    near prints_
  1978                                  L$100:
  1979 00000DFA 0146FE                          ADD     word -2[bp],ax
  1980 00000DFD E98500                          JMP     near L$110
  1981                                  L$101:
  1982 00000E00 803C64                          CMP     byte [si],64H
  1983 00000E03 751C                            JNE     L$104
  1984 00000E05 B86100                          MOV     ax,61H
  1985 00000E08 50                              PUSH    ax
  1986 00000E09 51                              PUSH    cx
  1987 00000E0A 52                              PUSH    dx
  1988 00000E0B 830502                          ADD     word [di],2
  1989 00000E0E 8B1D                            MOV     bx, word [di]
  1990 00000E10 8B57FE                          MOV     dx, word -2[bx]
  1991 00000E13 B90100                          MOV     cx,1
  1992                                  L$102:
  1993 00000E16 BB0A00                          MOV     bx,0aH
  1994                                  L$103:
  1995 00000E19 8B46FA                          MOV     ax, word -6[bp]
  1996 00000E1C E8A6FE                          CALL    near printi_
  1997 00000E1F EBD9                            JMP     L$100
  1998                                  L$104:
  1999 00000E21 803C78                          CMP     byte [si],78H
  2000 00000E24 7515                            JNE     L$106
  2001 00000E26 B86100                          MOV     ax,61H
  2002                                  L$105:
  2003 00000E29 50                              PUSH    ax
  2004 00000E2A 51                              PUSH    cx
  2005 00000E2B 52                              PUSH    dx
  2006 00000E2C 830502                          ADD     word [di],2
  2007 00000E2F 8B1D                            MOV     bx, word [di]
  2008 00000E31 8B57FE                          MOV     dx, word -2[bx]
  2009 00000E34 31C9                            XOR     cx,cx
  2010 00000E36 BB1000                          MOV     bx,10H
  2011 00000E39 EBDE                            JMP     L$103
  2012                                  L$106:
  2013 00000E3B 803C58                          CMP     byte [si],58H
  2014 00000E3E 7505                            JNE     L$107
  2015 00000E40 B84100                          MOV     ax,41H
  2016 00000E43 EBE4                            JMP     L$105
  2017                                  L$107:
  2018 00000E45 803C75                          CMP     byte [si],75H
  2019 00000E48 7512                            JNE     L$108
  2020 00000E4A B86100                          MOV     ax,61H
  2021 00000E4D 50                              PUSH    ax
  2022 00000E4E 51                              PUSH    cx
  2023 00000E4F 52                              PUSH    dx
  2024 00000E50 830502                          ADD     word [di],2
  2025 00000E53 8B1D                            MOV     bx, word [di]
  2026 00000E55 8B57FE                          MOV     dx, word -2[bx]
  2027 00000E58 31C9                            XOR     cx,cx
  2028 00000E5A EBBA                            JMP     L$102
  2029                                  L$108:
  2030 00000E5C 803C63                          CMP     byte [si],63H
  2031 00000E5F 7524                            JNE     L$110
  2032 00000E61 830502                          ADD     word [di],2
  2033 00000E64 8B1D                            MOV     bx, word [di]
  2034 00000E66 8A47FE                          MOV     al,byte -2[bx]
  2035 00000E69 8846FC                          MOV     byte -4[bp],al
  2036 00000E6C C646FD00                        MOV     byte -3[bp],0
  2037 00000E70 89D3                            MOV     bx,dx
  2038 00000E72 8D56FC                          LEA     dx,-4[bp]
  2039 00000E75 E97CFF                          JMP     near L$99
  2040                                  L$109:
  2041 00000E78 8A14                            MOV     dl,byte [si]
  2042 00000E7A 30F6                            XOR     dh,dh
  2043 00000E7C 8B46FA                          MOV     ax, word -6[bp]
  2044 00000E7F E8B2FD                          CALL    near printchar_
  2045 00000E82 FF46FE                          INC     word -2[bp]
  2046                                  L$110:
  2047 00000E85 46                              INC     si
  2048 00000E86 E9FEFE                          JMP     near L$92
  2049                                  L$111:
  2050 00000E89 837EFA00                        CMP     word -6[bp],0
  2051 00000E8D 7408                            JE      L$112
  2052 00000E8F 8B5EFA                          MOV     bx, word -6[bp]
  2053 00000E92 8B1F                            MOV     bx, word [bx]
  2054 00000E94 C60700                          MOV     byte [bx],0
  2055                                  L$112:
  2056 00000E97 C7050000                        MOV     word [di],0
  2057 00000E9B 8B46FE                          MOV     ax, word -2[bp]
  2058 00000E9E E9ABFC                          JMP     near L$64
  2059                                  esprintf_:
  2060 00000EA1 53                              PUSH    bx
  2061 00000EA2 52                              PUSH    dx
  2062 00000EA3 55                              PUSH    bp
  2063 00000EA4 89E5                            MOV     bp,sp
  2064 00000EA6 50                              PUSH    ax
  2065 00000EA7 8D460C                          LEA     ax,0cH[bp]
  2066 00000EAA 8946FE                          MOV     word -2[bp],ax
  2067 00000EAD 8D5EFE                          LEA     bx,-2[bp]
  2068 00000EB0 8B560A                          MOV     dx, word 0aH[bp]
  2069 00000EB3 8D4608                          LEA     ax,8[bp]
  2070 00000EB6 E8BCFE                          CALL    near print_
  2071 00000EB9 89EC                            MOV     sp,bp
  2072 00000EBB 5D                              POP     bp
  2073 00000EBC 5A                              POP     dx
  2074 00000EBD 5B                              POP     bx
  2075 00000EBE C3                              RET
  2076
  2077                                  ;----------------------------------------------------------------------
  2078                                  ; Display Help Menu
  2079                                  ;----------------------------------------------------------------------
  2080                                  DISPHELP:
  2081 00000EBF BE[3111]                        MOV     SI,  HELP_MESS  ;   -> SI
  2082 00000EC2 E81800                          CALL    PUTS            ; String pointed to by DS:[SI]
  2083                                  EXITDH:
  2084 00000EC5 E993F1                          JMP     CMD             ; Next Command
  2085
  2086                                  ;----------------------------------------------------------------------
  2087                                  ; Quite Monitor
  2088                                  ;----------------------------------------------------------------------
  2089                                  EXITMON:
  2090 00000EC8 B44C                            MOV     AH,4Ch          ; Exit MON88
  2091 00000ECA CD21                            INT     21h
  2092
  2093                                  ;======================================================================
  2094                                  ; Monitor routines
  2095                                  ;======================================================================
  2096                                  ;----------------------------------------------------------------------
  2097                                  ; Return String Length in AL
  2098                                  ; String pointed to by DS:[SI]
  2099                                  ;----------------------------------------------------------------------
  2100                                  STRLEN:
  2101 00000ECC 56                              PUSH    SI
  2102 00000ECD B4FF                            MOV     AH,-1
  2103 00000ECF FC                              CLD
  2104                                  NEXTSL:
  2105 00000ED0 FEC4                            INC     AH
  2106 00000ED2 AC                              LODSB                   ; AL=DS:[SI++]
  2107 00000ED3 08C0                            OR      AL,AL           ; Zero?
  2108 00000ED5 75F9                            JNZ     NEXTSL          ; No, continue
  2109 00000ED7 88E0                            MOV     AL,AH           ; Return Result in AX
  2110 00000ED9 30E4                            XOR     AH,AH
  2111 00000EDB 5E                              POP     SI
  2112 00000EDC C3                              RET
  2113
  2114                                  ;----------------------------------------------------------------------
  2115                                  ; Write zero terminated string to CONOUT
  2116                                  ; String pointed to by DS:[SI]
  2117                                  ;----------------------------------------------------------------------
  2118                                  PUTS:
  2119 00000EDD 56                              PUSH    SI
  2120 00000EDE 50                              PUSH    AX
  2121 00000EDF FC                              CLD
  2122                                  PRINT:
  2123 00000EE0 AC                              LODSB                   ; AL=DS:[SI++]
  2124 00000EE1 08C0                            OR      AL,AL           ; Zero?
  2125 00000EE3 7405                            JZ      PRINT_X         ; then exit
  2126 00000EE5 E8B800                          CALL    TXCHAR
  2127 00000EE8 EBF6                            JMP     PRINT           ; Next Character
  2128                                  PRINT_X:
  2129 00000EEA 58                              POP     AX
  2130 00000EEB 5E                              POP     SI
  2131 00000EEC C3                              RET
  2132
  2133                                  ;----------------------------------------------------------------------
  2134                                  ; Write string to CONOUT, length in CL
  2135                                  ; String pointed to by DS:[SI]
  2136                                  ;----------------------------------------------------------------------
  2137                                  PUTSF:
  2138 00000EED 56                              PUSH    SI
  2139 00000EEE 51                              PUSH    CX
  2140 00000EEF 50                              PUSH    AX
  2141 00000EF0 FC                              CLD
  2142 00000EF1 30ED                            XOR     CH,CH
  2143                                  PRTF:
  2144 00000EF3 AC                              LODSB                   ; AL=DS:[SI++]
  2145 00000EF4 E8A900                          CALL    TXCHAR
  2146 00000EF7 E2FA                            LOOP    PRTF
  2147 00000EF9 58                              POP     AX
  2148 00000EFA 59                              POP     CX
  2149 00000EFB 5E                              POP     SI
  2150 00000EFC C3                              RET
  2151
  2152                                  ;----------------------------------------------------------------------
  2153                                  ; Write newline
  2154                                  ;----------------------------------------------------------------------
  2155                                  NEWLINE:
  2156 00000EFD 50                              PUSH    AX
  2157 00000EFE B00D                            MOV     AL,CR
  2158 00000F00 E89D00                          CALL    TXCHAR
  2159 00000F03 B00A                            MOV     AL,LF
  2160 00000F05 E89800                          CALL    TXCHAR
  2161 00000F08 58                              POP     AX
  2162 00000F09 C3                              RET
  2163                                  ;----------------------------------------------------------------------
  2164                                  ; Get Address range into BX, DX
  2165                                  ;----------------------------------------------------------------------
  2166                                  GETRANGE:
  2167 00000F0A 50                              PUSH    AX
  2168 00000F0B E80E00                          CALL    GETHEX4
  2169 00000F0E 89C3                            MOV     BX,AX
  2170 00000F10 B02D                            MOV     AL,'-'
  2171 00000F12 E88B00                          CALL    TXCHAR
  2172 00000F15 E80400                          CALL    GETHEX4
  2173 00000F18 89C2                            MOV     DX,AX
  2174 00000F1A 58                              POP     AX
  2175 00000F1B C3                              RET
  2176
  2177                                  ;----------------------------------------------------------------------
  2178                                  ; Get Hex4,2,1 Into AX, AL, AL
  2179                                  ;----------------------------------------------------------------------
  2180                                  GETHEX4:
  2181 00000F1C 53                              PUSH    BX
  2182 00000F1D E80900                          CALL    GETHEX2         ; Get Hex Character in AX
  2183 00000F20 88C3                            MOV     BL,AL
  2184 00000F22 E80400                          CALL    GETHEX2
  2185 00000F25 88DC                            MOV     AH,BL
  2186 00000F27 5B                              POP     BX
  2187 00000F28 C3                              RET
  2188
  2189                                  GETHEX2:
  2190 00000F29 53                              PUSH    BX
  2191 00000F2A E81100                          CALL    GETHEX1         ; Get Hex character in AL
  2192 00000F2D 88C3                            MOV     BL,AL
  2193 00000F2F D0E3                            SHL     BL,1
  2194 00000F31 D0E3                            SHL     BL,1
  2195 00000F33 D0E3                            SHL     BL,1
  2196 00000F35 D0E3                            SHL     BL,1
  2197 00000F37 E80400                          CALL    GETHEX1
  2198 00000F3A 08D8                            OR      AL,BL
  2199 00000F3C 5B                              POP     BX
  2200 00000F3D C3                              RET
  2201
  2202                                  GETHEX1:
  2203 00000F3E E87000                          CALL    RXCHAR          ; Get Hex character in AL
  2204 00000F41 3C1B                            CMP     AL,ESC
  2205 00000F43 7503                            JNE     OKCHAR
  2206 00000F45 E913F1                          JMP     CMD             ; Abort if ESC is pressed
  2207                                  OKCHAR:
  2208 00000F48 E84800                          CALL    TO_UPPER
  2209 00000F4B 3C39                            CMP     AL,39h          ; 0-9?
  2210 00000F4D 7E02                            JLE     CONVDEC         ; yes, subtract 30
  2211 00000F4F 2C07                            SUB     AL,07h          ; A-F subtract 39
  2212                                  CONVDEC:
  2213 00000F51 2C30                            SUB     AL,30h
  2214 00000F53 C3                              RET
  2215
  2216                                  ;----------------------------------------------------------------------
  2217                                  ; Display AX/AL in HEX
  2218                                  ;----------------------------------------------------------------------
  2219                                  PUTHEX4:
  2220 00000F54 86C4                            XCHG    AL,AH           ; Write AX in hex
  2221 00000F56 E80600                          CALL    PUTHEX2
  2222 00000F59 86C4                            XCHG    AL,AH
  2223 00000F5B E80100                          CALL    PUTHEX2
  2224 00000F5E C3                              RET
  2225
  2226                                  PUTHEX2:
  2227 00000F5F 50                              PUSH    AX              ; Save the working register
  2228 00000F60 D0E8                            SHR     AL,1
  2229 00000F62 D0E8                            SHR     AL,1
  2230 00000F64 D0E8                            SHR     AL,1
  2231 00000F66 D0E8                            SHR     AL,1
  2232 00000F68 E80500                          CALL    PUTHEX1         ; Output it
  2233 00000F6B 58                              POP     AX              ; Get the LSD
  2234 00000F6C E80100                          CALL    PUTHEX1         ; Output
  2235 00000F6F C3                              RET
  2236
  2237                                  PUTHEX1:
  2238 00000F70 50                              PUSH    AX              ; Save the working register
  2239 00000F71 240F                            AND     AL, 0FH         ; Mask off any unused bits
  2240 00000F73 3C0A                            CMP     AL, 0AH         ; Test for alpha or numeric
  2241 00000F75 7C02                            JL      NUMERIC         ; Take the branch if numeric
  2242 00000F77 0407                            ADD     AL, 7           ; Add the adjustment for hex alpha
  2243                                  NUMERIC:
  2244 00000F79 0430                            ADD     AL, '0'         ; Add the numeric bias
  2245 00000F7B E82200                          CALL    TXCHAR          ; Send to the console
  2246 00000F7E 58                              POP     AX
  2247 00000F7F C3                              RET
  2248
  2249                                  ;----------------------------------------------------------------------
  2250                                  ; Convert HEX to BCD
  2251                                  ; 3Bh->59
  2252                                  ;----------------------------------------------------------------------
  2253                                  HEX2BCD:
  2254 00000F80 51                              PUSH    CX
  2255 00000F81 30E4                            XOR     AH,AH
  2256 00000F83 B10A                            MOV     CL,0Ah
  2257 00000F85 F6F1                            DIV     CL
  2258 00000F87 D0E0                            SHL     AL,1
  2259 00000F89 D0E0                            SHL     AL,1
  2260 00000F8B D0E0                            SHL     AL,1
  2261 00000F8D D0E0                            SHL     AL,1
  2262 00000F8F 08E0                            OR      AL,AH
  2263 00000F91 59                              POP     CX
  2264 00000F92 C3                              RET
  2265
  2266                                  ;----------------------------------------------------------------------
  2267                                  ; Convert to Upper Case
  2268                                  ; if (c >= 'a' && c <= 'z') c -= 32;
  2269                                  ;----------------------------------------------------------------------
  2270                                  TO_UPPER:
  2271 00000F93 3C61                            CMP     AL,'a'
  2272 00000F95 7D01                            JGE     CHECKZ
  2273 00000F97 C3                              RET
  2274                                  CHECKZ:
  2275 00000F98 3C7A                            CMP     AL,'z'
  2276 00000F9A 7E01                            JLE     SUB32
  2277 00000F9C C3                              RET
  2278                                  SUB32:
  2279 00000F9D 2C20                            SUB     AL,32
  2280 00000F9F C3                              RET
  2281
  2282                                  ;----------------------------------------------------------------------
  2283                                  ; Transmit character in AL
  2284                                  ;----------------------------------------------------------------------
  2285                                  TXCHAR:
  2286 00000FA0 52                              PUSH    DX
  2287 00000FA1 50                              PUSH    AX              ; Character in AL
  2288 00000FA2 BAF903                          MOV     DX,COMPORT+STATUS
  2289                                  WAITTX:
  2290 00000FA5 EC                              IN      AL,DX           ; read status
  2291 00000FA6 2402                            AND     AL,TX_EMPTY     ; Transmit Register Empty?
  2292 00000FA8 74FB                            JZ      WAITTX          ; no, wait
  2293 00000FAA BAF803                          MOV     DX,COMPORT+DATAREG; point to data port
  2294 00000FAD 58                              POP     AX
  2295 00000FAE EE                              OUT     DX,AL
  2296 00000FAF 5A                              POP     DX
  2297 00000FB0 C3                              RET
  2298
  2299                                  ;----------------------------------------------------------------------
  2300                                  ; Receive character in AL, blocking
  2301                                  ; AL Changed
  2302                                  ;----------------------------------------------------------------------
  2303                                  RXCHAR:
  2304 00000FB1 52                              PUSH    DX
  2305 00000FB2 BAF903                          MOV     DX,COMPORT+STATUS
  2306                                  WAITRX:
  2307 00000FB5 EC                              IN      AL,DX
  2308 00000FB6 2401                            AND     AL,RX_AVAIL
  2309 00000FB8 74FB                            JZ      WAITRX          ; blocking
  2310 00000FBA BAF803                          MOV     DX,COMPORT+DATAREG
  2311 00000FBD EC                              IN      AL,DX           ; return result in al
  2312 00000FBE E8DFFF                          CALL    TXCHAR          ; Echo back
  2313 00000FC1 5A                              POP     DX
  2314 00000FC2 C3                              RET
  2315
  2316                                  ;----------------------------------------------------------------------
  2317                                  ; Receive character in AL, blocking
  2318                                  ; AL Changed
  2319                                  ; No Echo
  2320                                  ;----------------------------------------------------------------------
  2321                                  RXCHARNE:
  2322 00000FC3 52                              PUSH    DX
  2323 00000FC4 BAF903                          MOV     DX,COMPORT+STATUS
  2324                                  WAITRXNE:
  2325 00000FC7 EC                              IN      AL,DX
  2326 00000FC8 2401                            AND     AL,RX_AVAIL
  2327 00000FCA 74FB                            JZ      WAITRXNE        ; blocking
  2328 00000FCC BAF803                          MOV     DX,COMPORT+DATAREG
  2329 00000FCF EC                              IN      AL,DX           ; return result in al
  2330 00000FD0 5A                              POP     DX
  2331 00000FD1 C3                              RET
  2332
  2333                                  ;======================================================================
  2334                                  ; Monitor Interrupt Handlers
  2335                                  ;======================================================================
  2336                                  ;----------------------------------------------------------------------
  2337                                  ; Breakpoint/Trace Interrupt Handler
  2338                                  ; Restore All instructions
  2339                                  ; Display Breakpoint Number
  2340                                  ; Update & Display Registers
  2341                                  ; Return to monitor
  2342                                  ;----------------------------------------------------------------------
  2343                                  INT1_3:
  2344 00000FD2 55                              PUSH    BP
  2345 00000FD3 89E5                            MOV     BP,SP           ; BP+2=IP, BP+4=CS, BP+6=Flags
  2346 00000FD5 16                              PUSH    SS
  2347 00000FD6 06                              PUSH    ES
  2348 00000FD7 1E                              PUSH    DS
  2349 00000FD8 57                              PUSH    DI
  2350 00000FD9 56                              PUSH    SI
  2351 00000FDA 55                              PUSH    BP              ; Note this is the wrong value
  2352 00000FDB 54                              PUSH    SP
  2353 00000FDC 52                              PUSH    DX
  2354 00000FDD 51                              PUSH    CX
  2355 00000FDE 53                              PUSH    BX
  2356 00000FDF 50                              PUSH    AX
  2357
  2358 00000FE0 8CC8                            MOV     AX,CS           ; Restore Monitor's Data segment
  2359 00000FE2 8ED8                            MOV     DS,AX
  2360
  2361 00000FE4 368B4604                        MOV     AX,SS:[BP+4]    ; Get user CS
  2362 00000FE8 8EC0                            MOV     ES,AX           ; Used for restoring bp replaced opcode
  2363 00000FEA A3[6016]                        MOV     [UCS],AX        ; Save User CS
  2364
  2365 00000FED 368B4602                        MOV     AX,SS:[BP+2]    ; Save User IP
  2366 00000FF1 A3[6216]                        MOV     [UIP],AX
  2367
  2368 00000FF4 89E7                            MOV     DI,SP           ; SS:SP=AX
  2369 00000FF6 BB[4A16]                        MOV     BX,  UAX        ; Update User registers, DI=pointing to AX
  2370 00000FF9 B90B00                          MOV     CX,11
  2371                                  NEXTUREG:
  2372 00000FFC 368B05                          MOV     AX,SS:[DI]      ; Get register
  2373 00000FFF 8907                            MOV     [BX],AX         ; Write it to user reg
  2374 00001001 83C302                          ADD     BX,2
  2375 00001004 83C702                          ADD     DI,2
  2376 00001007 E2F3                            LOOP    NEXTUREG
  2377
  2378 00001009 89E8                            MOV     AX,BP           ; Save User SP
  2379 0000100B 83C008                          ADD     AX,8
  2380 0000100E A3[5216]                        MOV     [USP],AX
  2381
  2382 00001011 368B4600                        MOV     AX,SS:[BP]
  2383 00001015 A3[5416]                        MOV     [UBP],AX        ; Restore real BP value
  2384
  2385 00001018 368B4606                        MOV     AX,SS:[BP+6]    ; Save Flags
  2386 0000101C A3[6416]                        MOV     [UFL],AX
  2387 0000101F 8126[6416]FFFE                  AND     word [UFL],0FEFFh; Clear TF
  2388 00001025 A90001                          TEST    AX,0100h        ; Check If Trace flag set then
  2389 00001028 7402                            JZ      CONTBPC         ; No, check which bp triggered it
  2390
  2391 0000102A EB33                            JMP     EXITINT3        ; Exit, Display regs, Cmd prompt
  2392
  2393                                  CONTBPC:
  2394 0000102C FF0E[6216]                      DEC     word [UIP]      ; No, IP-1 and save
  2395
  2396 00001030 BE[F610]                        MOV     SI,  BREAKP_MESS; Display "***** BreakPoint # *****
  2397
  2398 00001033 BB[8101]                        MOV     BX,  BPTAB      ; Check which breakpoint triggered
  2399 00001036 B90800                          MOV     CX,8            ; and restore opcode
  2400                                  INTNEXTBP:
  2401 00001039 B80800                          MOV     AX,8
  2402 0000103C 28C8                            SUB     AL,CL
  2403
  2404 0000103E F6470301                        TEST    BYTE [BX+3],1   ; Check enable/disable flag
  2405 00001042 7413                            JZ      INT3RESBP
  2406
  2407 00001044 8B3F                            MOV     DI,[BX]         ; Get Breakpoint Address
  2408 00001046 393E[6216]                      CMP     [UIP],DI
  2409 0000104A 7505                            JNE     INT3RES
  2410
  2411 0000104C 0430                            ADD     AL, '0'         ; Add the numeric bias
  2412 0000104E 884412                          MOV     [SI+18],AL      ; Save number
  2413
  2414                                  INT3RES:
  2415 00001051 8A4702                          MOV     AL,BYTE [BX+2]  ; Get original Opcode
  2416 00001054 268805                          MOV     [ES:DI],AL      ; Write it back
  2417
  2418                                  INT3RESBP:
  2419 00001057 83C304                          ADD     BX,4            ; Next entry
  2420 0000105A E2DD                            LOOP    INTNEXTBP
  2421
  2422 0000105C E87EFE                          CALL    PUTS            ; Write BP Number message
  2423
  2424                                  EXITINT3:
  2425 0000105F 8CC8                            MOV     AX,CS           ; Restore Monitor settings
  2426 00001061 8ED0                            MOV     SS,AX
  2427                                  ;            MOV     DS,AX
  2428 00001063 B8[7617]                        MOV     AX,  TOS        ; Top of Stack
  2429 00001066 89C4                            MOV     SP,AX           ; Restore Monitor Stack pointer
  2430 00001068 B88003                          MOV     AX,BASE_SEGMENT ; Restore Base Pointer
  2431 0000106B 8EC0                            MOV     ES,AX
  2432
  2433 0000106D E914F4                          JMP     DISPREG         ; Jump to Display Registers
  2434
  2435                                  ;======================================================================
  2436                                  ; BIOS Services
  2437                                  ;======================================================================
  2438
  2439                                  ;----------------------------------------------------------------------
  2440                                  ; Interrupt 10H, video function
  2441                                  ; Service   0E   Teletype Output
  2442                                  ; Input     AL   Character, BL and BH are ignored
  2443                                  ; Output
  2444                                  ; Changed
  2445                                  ;----------------------------------------------------------------------
  2446                                  INT10:
  2447 00001070 80FC0E                          CMP     AH,0Eh
  2448 00001073 7505                            JNE     ISR10_X
  2449
  2450 00001075 E828FF                          CALL    TXCHAR          ; Transmit character
  2451 00001078 EB08                            JMP     ISR10_RET
  2452
  2453                                  ;----------------------------------------------------------------------
  2454                                  ; Service Unkown service, display message int and ah value, return to monitor
  2455                                  ;----------------------------------------------------------------------
  2456                                  ISR10_X:
  2457 0000107A B010                            MOV     AL,10h
  2458 0000107C E8E001                          CALL    DISPSERI        ; Display Int and service number
  2459 0000107F E97EEF                          JMP     INITMON         ; Jump back to monitor
  2460
  2461                                  ISR10_RET:
  2462 00001082 CF                              IRET
  2463
  2464
  2465                                  ;----------------------------------------------------------------------
  2466                                  ; Interrupt 16H, I/O function
  2467                                  ; Service   00   Wait for keystroke
  2468                                  ; Input
  2469                                  ; Output    AL   Character, AH=ScanCode=0
  2470                                  ; Changed   AX
  2471                                  ;----------------------------------------------------------------------
  2472                                  INT16:
  2473 00001083 52                              PUSH    DX
  2474 00001084 55                              PUSH    BP
  2475 00001085 89E5                            MOV     BP,SP
  2476
  2477                                  ISR16_00:
  2478 00001087 80FC00                          CMP     AH,00h
  2479 0000108A 7507                            JNE     ISR16_01
  2480
  2481 0000108C E822FF                          CALL    RXCHAR
  2482 0000108F 30E4                            XOR     AH,AH
  2483
  2484 00001091 EB27                            JMP     ISR16_RET
  2485
  2486                                  ;----------------------------------------------------------------------
  2487                                  ; Interrupt 16H, I/O function
  2488                                  ; Service   01   Check for keystroke (kbhit)
  2489                                  ; Input
  2490                                  ; Output    AL   Character, AH=ScanCode=0 ZF=0 when keystoke available
  2491                                  ; Changed   AX
  2492                                  ;----------------------------------------------------------------------
  2493                                  ISR16_01:
  2494 00001093 80FC01                          CMP     AH,01h
  2495 00001096 751A                            JNE     ISR16_X
  2496
  2497 00001098 30E4                            XOR     AH,AH           ; Clear ScanCode
  2498 0000109A 36834E0840                      OR      WORD SS:[BP+8],0040h; SET ZF in stack stored flag
  2499
  2500 0000109F BAF903                          MOV     DX,COMPORT+STATUS
  2501 000010A2 EC                              IN      AL,DX           ; Get Status
  2502 000010A3 2401                            AND     AL,RX_AVAIL
  2503 000010A5 7413                            JZ      ISR16_RET       ; No keystoke
  2504
  2505 000010A7 BAF803                          MOV     DX,COMPORT+DATAREG
  2506 000010AA EC                              IN      AL,DX           ; return result in al
  2507 000010AB 36836608BF                      AND     WORD SS:[BP+8],0FFBFh; Clear ZF in stack stored flag
  2508
  2509 000010B0 EB08                            JMP     ISR16_RET
  2510
  2511                                  ;----------------------------------------------------------------------
  2512                                  ; Service Unkown service, display message int and ah value, return to monitor
  2513                                  ;----------------------------------------------------------------------
  2514                                  ISR16_X:
  2515 000010B2 B016                            MOV     AL,16h
  2516 000010B4 E8A801                          CALL    DISPSERI        ; Display Int and service number
  2517 000010B7 E946EF                          JMP     INITMON         ; Jump back to monitor
  2518
  2519                                  ISR16_RET:
  2520 000010BA 5D                              POP     BP
  2521 000010BB 5A                              POP     DX
  2522 000010BC CF                              IRET
  2523
  2524
  2525                                  ;----------------------------------------------------------------------
  2526                                  ;  INT 1AH, timer function
  2527                                  ;  AX is not saved!
  2528                                  ;        Addr    Function
  2529                                  ;====    =========================================;
  2530                                  ; 00     current second for real-time clock
  2531                                  ; 02     current minute
  2532                                  ; 04     current hour
  2533                                  ; 07     current date of month
  2534                                  ; 08     current month
  2535                                  ; 09     current year  (final two digits; eg, 93)
  2536                                  ; 0A     Status Register A - Read/Write except UIP
  2537                                  ;----------------------------------------------------------------------
  2538                                  INT1A:
  2539 000010BD 1E                              PUSH    DS
  2540 000010BE 55                              PUSH    BP
  2541 000010BF 89E5                            MOV     BP,SP
  2542
  2543                                  ;----------------------------------------------------------------------
  2544                                  ; Interrupt 1AH, Time function
  2545                                  ; Service   00   Get System Time in ticks
  2546                                  ; Input
  2547                                  ; Output    CX:DX ticks since midnight
  2548                                  ;----------------------------------------------------------------------
  2549                                  ISR1A_00:
  2550 000010C1 31D2                            XOR     DX,DX
  2551 000010C3 31C9                            XOR     CX,CX
  2552 000010C5 E9FB00                          JMP     ISR1A_RET       ; exit
  2553
  2554
  2555                                  ;----------------------------------------------------------------------
  2556                                  ; Interrupt 1AH, Time function
  2557                                  ; Service   01   Set System Time from ticks
  2558                                  ; Input     CX:DX ticks since midnight
  2559                                  ; Output
  2560                                  ;----------------------------------------------------------------------
  2561                                  ISR1A_01:
  2562 000010C8 80FC01                          CMP     AH,01h
  2563 000010CB 7543                            JNE     ISR1A_02
  2564
  2565 000010CD 53                              PUSH    BX
  2566 000010CE 51                              PUSH    CX
  2567 000010CF 52                              PUSH    DX
  2568
  2569 000010D0 B00A                            MOV     AL,0Ah
  2570 000010D2 E670                            OUT     RTC_BASE,AL
  2571                                  ISR1A_01W:
  2572 000010D4 E471                            IN      AL,RTC_DATA     ; Check Update In Progress Flag
  2573 000010D6 2480                            AND     AL,80h
  2574 000010D8 75FA                            JNZ     ISR1A_01W       ; if so then wait
  2575
  2576 000010DA B004                            MOV     AL,04h          ; Hours
  2577 000010DC E670                            OUT     RTC_BASE,AL
  2578
  2579 000010DE BBF0FF                          MOV     BX,65520        ; 60*60*18.2
  2580 000010E1 52                              PUSH    DX
  2581 000010E2 58                              POP     AX
  2582 000010E3 51                              PUSH    CX
  2583 000010E4 5A                              POP     DX              ; DX:AX <-CX:DX
  2584
  2585 000010E5 F7F3                            DIV     BX              ; DX:AX/65520-> AL=Hours,AH=0 DX=remainder
  2586 000010E7 E671                            OUT     RTC_DATA,AL
  2587
  2588 000010E9 B002                            MOV     AL,02h          ; Minutes
  2589 000010EB E670                            OUT     RTC_BASE,AL
  2590
  2591 000010ED BB4404                          MOV     BX,1092
  2592 000010F0 52                              PUSH    DX
  2593 000010F1 58                              POP     AX
  2594 000010F2 31D2                            XOR     DX,DX
  2595 000010F4 F7F3                            DIV     BX              ; 00:DX/1092->AL=Minutes AH=0, DX=remainder
  2596 000010F6 E671                            OUT     RTC_DATA,AL
  2597
  2598 000010F8 B000                            MOV     AL,00h          ; Seconds
  2599 000010FA E670                            OUT     RTC_BASE,AL
  2600 000010FC B90A00                          MOV     CX,10
  2601 000010FF 89D0                            MOV     AX,DX
  2602 00001101 F7E1                            MUL     CX
  2603 00001103 BBB600                          MOV     BX,182          ;
  2604 00001106 F7F3                            DIV     BX              ; AL/BL-> AL=seconds
  2605 00001108 E671                            OUT     RTC_DATA,AL
  2606
  2607 0000110A 5A                              POP     DX
  2608 0000110B 59                              POP     CX
  2609 0000110C 5B                              POP     BX
  2610 0000110D E9B300                          JMP     ISR1A_RET       ; exit
  2611
  2612
  2613                                  ;----------------------------------------------------------------------
  2614                                  ; Interrupt 1AH, Time function
  2615                                  ; Service   02   Get RTC time
  2616                                  ;   exit :  CF clear if successful, set on error ***NOT YET ADDED***
  2617                                  ;           CH = hour (BCD)
  2618                                  ;           CL = minutes (BCD)
  2619                                  ;           DH = seconds (BCD)
  2620                                  ;           DL = daylight savings flag  (!! NOT IMPLEMENTED !!)
  2621                                  ;                (00h standard time, 01h daylight time)
  2622                                  ;----------------------------------------------------------------------
  2623                                  ISR1A_02:
  2624 00001110 80FC02                          CMP     AH,02h
  2625 00001113 752A                            JNE     ISR1A_03
  2626
  2627 00001115 E80300                          CALL    READRTC
  2628 00001118 E9A800                          JMP     ISR1A_RET       ; exit
  2629
  2630                                  READRTC:
  2631 0000111B B000                            MOV     AL,00h          ; Seconds
  2632 0000111D E670                            OUT     RTC_BASE,AL
  2633 0000111F E471                            IN      AL,RTC_DATA
  2634 00001121 E85CFE                          CALL    HEX2BCD
  2635 00001124 88C6                            MOV     DH,AL
  2636
  2637 00001126 B002                            MOV     AL,02h          ; Minutes
  2638 00001128 E670                            OUT     RTC_BASE,AL
  2639 0000112A E471                            IN      AL,RTC_DATA
  2640 0000112C E851FE                          CALL    HEX2BCD
  2641 0000112F 88C1                            MOV     CL,AL
  2642
  2643 00001131 B004                            MOV     AL,04h          ; Hours
  2644 00001133 E670                            OUT     RTC_BASE,AL
  2645 00001135 E471                            IN      AL,RTC_DATA
  2646 00001137 E846FE                          CALL    HEX2BCD
  2647 0000113A 88C5                            MOV     CH,AL
  2648
  2649 0000113C 30D2                            XOR     DL,DL           ; Set to standard time
  2650 0000113E C3                              RET
  2651
  2652                                  ;----------------------------------------------------------------------
  2653                                  ; Int 1Ah function 03h - Set RTC time
  2654                                  ;   entry:  AH = 03h
  2655                                  ;           CH = hour (BCD)
  2656                                  ;           CL = minutes (BCD)
  2657                                  ;           DH = seconds (BCD)
  2658                                  ;           DL = daylight savings flag (as above)
  2659                                  ;   exit:   none
  2660                                  ;----------------------------------------------------------------------
  2661                                  ISR1A_03:
  2662 0000113F 80FC03                          CMP     AH,03h
  2663 00001142 7524                            JNE     ISR1A_04
  2664
  2665 00001144 B00A                            MOV     AL,0Ah
  2666 00001146 E670                            OUT     RTC_BASE,AL
  2667                                  ISR1A_03W:
  2668 00001148 E471                            IN      AL,RTC_DATA     ; Check Update In Progress Flag
  2669 0000114A 2480                            AND     AL,80h
  2670 0000114C 75FA                            JNZ     ISR1A_03W       ; if so then wait
  2671
  2672 0000114E B000                            MOV     AL,00h          ; Seconds
  2673 00001150 E670                            OUT     RTC_BASE,AL
  2674 00001152 88F0                            MOV     AL,DH
  2675 00001154 E671                            OUT     RTC_DATA,AL
  2676
  2677 00001156 B002                            MOV     AL,02h          ; Minutes
  2678 00001158 E670                            OUT     RTC_BASE,AL
  2679 0000115A 88C8                            MOV     AL,CL
  2680 0000115C E671                            OUT     RTC_DATA,AL
  2681
  2682 0000115E B004                            MOV     AL,04h          ; Hours
  2683 00001160 E670                            OUT     RTC_BASE,AL
  2684 00001162 88E8                            MOV     AL,CH
  2685 00001164 E671                            OUT     RTC_DATA,AL
  2686
  2687 00001166 EB5B                            JMP     ISR1A_RET
  2688
  2689                                  ;----------------------------------------------------------------------
  2690                                  ; Int 1Ah function 04h - Get RTC date
  2691                                  ;   entry:  AH = 04h
  2692                                  ;   exit:   CF clear if successful, set on error
  2693                                  ;           CH = century (BCD)
  2694                                  ;           CL = year (BCD)
  2695                                  ;           DH = month (BCD)
  2696                                  ;           DL = day (BCD)
  2697                                  ;----------------------------------------------------------------------
  2698                                  ISR1A_04:
  2699 00001168 80FC04                          CMP     AH,04h
  2700 0000116B 7525                            JNE     ISR1A_05
  2701
  2702 0000116D B007                            MOV     AL,07h          ; Day
  2703 0000116F E670                            OUT     RTC_BASE,AL
  2704 00001171 E471                            IN      AL,RTC_DATA
  2705 00001173 E80AFE                          CALL    HEX2BCD
  2706 00001176 88C2                            MOV     DL,AL
  2707
  2708 00001178 B008                            MOV     AL,08h          ; Month
  2709 0000117A E670                            OUT     RTC_BASE,AL
  2710 0000117C E471                            IN      AL,RTC_DATA
  2711 0000117E E8FFFD                          CALL    HEX2BCD
  2712 00001181 88C6                            MOV     DH,AL
  2713
  2714 00001183 B009                            MOV     AL,09h          ; Year
  2715 00001185 E670                            OUT     RTC_BASE,AL
  2716 00001187 E471                            IN      AL,RTC_DATA
  2717 00001189 E8F4FD                          CALL    HEX2BCD
  2718 0000118C 88C1                            MOV     CL,AL
  2719 0000118E B520                            MOV     CH,20h
  2720
  2721 00001190 EB31                            JMP     ISR1A_RET
  2722
  2723                                  ;----------------------------------------------------------------------
  2724                                  ; Int 1Ah function 05h - Set RTC date
  2725                                  ;   entry:  AH = 05h
  2726                                  ;           CH = century (BCD)
  2727                                  ;           CL = year (BCD)
  2728                                  ;           DH = month (BCD)
  2729                                  ;           DL = day (BCD)
  2730                                  ;   exit:   none
  2731                                  ;----------------------------------------------------------------------
  2732                                  ISR1A_05:
  2733 00001192 80FC05                          CMP     AH,05h
  2734 00001195 7524                            JNE     ISR1A_X
  2735
  2736 00001197 B00A                            MOV     AL,0Ah
  2737 00001199 E670                            OUT     RTC_BASE,AL
  2738                                  ISR1A_05W:
  2739 0000119B E471                            IN      AL,RTC_DATA     ; Check Update In Progress Flag
  2740 0000119D 2480                            AND     AL,80h
  2741 0000119F 75FA                            JNZ     ISR1A_05W       ; if so then wait
  2742
  2743 000011A1 B007                            MOV     AL,07h          ; Day
  2744 000011A3 E670                            OUT     RTC_BASE,AL
  2745 000011A5 88D0                            MOV     AL,DL
  2746 000011A7 E671                            OUT     RTC_DATA,AL
  2747
  2748 000011A9 B008                            MOV     AL,08h          ; Month
  2749 000011AB E670                            OUT     RTC_BASE,AL
  2750 000011AD 88F0                            MOV     AL,DH
  2751 000011AF E671                            OUT     RTC_DATA,AL
  2752
  2753 000011B1 B009                            MOV     AL,09h          ; Year
  2754 000011B3 E670                            OUT     RTC_BASE,AL
  2755 000011B5 88C8                            MOV     AL,CL
  2756 000011B7 E671                            OUT     RTC_DATA,AL
  2757
  2758 000011B9 EB08                            JMP     ISR1A_RET
  2759
  2760                                  ;----------------------------------------------------------------------
  2761                                  ; Interrupt 1Ah
  2762                                  ; Service   xx   Unknown service, print message, jump to monitor
  2763                                  ;----------------------------------------------------------------------
  2764                                  ISR1A_X:
  2765 000011BB B01A                            MOV     AL,1Ah
  2766 000011BD E89F00                          CALL    DISPSERI        ; Display Int and service number
  2767 000011C0 E93DEE                          JMP     INITMON         ; Jump back to monitor
  2768
  2769                                  ISR1A_RET:
  2770 000011C3 36836608FE                      AND     WORD SS:[BP+8],0FFFEh; Clear Carry to indicate no error
  2771 000011C8 5D                              POP     BP
  2772 000011C9 1F                              POP     DS
  2773 000011CA CF                              IRET
  2774
  2775                                  ;----------------------------------------------------------------------
  2776                                  ; INT 21H, basic I/O functions
  2777                                  ; AX REGISTER NOT SAVED
  2778                                  ;----------------------------------------------------------------------
  2779                                  INT21:
  2780 000011CB 1E                              PUSH    DS              ; DS used for service 25h
  2781 000011CC 06                              PUSH    ES
  2782 000011CD 56                              PUSH    SI
  2783
  2784 000011CE FB                              STI                     ; INT21 is reentrant!
  2785
  2786                                  ;----------------------------------------------------------------------
  2787                                  ; Interrupt 21h
  2788                                  ; Service   01   get character from UART
  2789                                  ; Input
  2790                                  ; Output    AL   character read
  2791                                  ; Changed   AX
  2792                                  ;----------------------------------------------------------------------
  2793                                  ISR21_1:
  2794 000011CF 80FC01                          CMP     AH,01
  2795 000011D2 7506                            JNE     ISR21_2
  2796
  2797 000011D4 E8DAFD                          CALL    RXCHAR          ; Return result in AL
  2798 000011D7 E98100                          JMP     ISR21_RET       ; return to caller
  2799
  2800                                  ;----------------------------------------------------------------------
  2801                                  ; Interrupt 21h
  2802                                  ; Service   02   write character to UART
  2803                                  ; Input     DL   character
  2804                                  ; Output
  2805                                  ; Changed   AX
  2806                                  ;----------------------------------------------------------------------
  2807                                  ISR21_2:
  2808 000011DA 80FC02                          CMP     AH,02
  2809 000011DD 7507                            JNE     ISR21_8
  2810
  2811 000011DF 88D0                            MOV     AL,DL
  2812 000011E1 E8BCFD                          CALL    TXCHAR
  2813
  2814 000011E4 EB75                            JMP     ISR21_RET       ; return to caller
  2815
  2816                                  ;----------------------------------------------------------------------
  2817                                  ; Interrupt 21h
  2818                                  ; Service   08   Console input without an echo
  2819                                  ; Input
  2820                                  ; Output
  2821                                  ; Changed   AX
  2822                                  ;----------------------------------------------------------------------
  2823                                  ISR21_8:
  2824 000011E6 80FC08                          CMP     AH,08
  2825 000011E9 7505                            JNE     ISR21_9
  2826
  2827 000011EB E8C3FD                          CALL    RXCHAR          ; Return result in AL
  2828 000011EE EB6B                            JMP     ISR21_RET       ; return to caller
  2829
  2830                                  ;----------------------------------------------------------------------
  2831                                  ; Interrupt 21h
  2832                                  ; Service   09   write 0 terminated string to UART  (change to $ terminated ??)
  2833                                  ; Input     DX     to string
  2834                                  ; Output
  2835                                  ; Changed   AX
  2836                                  ;----------------------------------------------------------------------
  2837                                  ISR21_9:
  2838 000011F0 80FC09                          CMP     AH,09
  2839 000011F3 7507                            JNE     ISR21_25
  2840
  2841 000011F5 89D6                            MOV     SI,DX
  2842 000011F7 E8E3FC                          CALL    PUTS            ; Display string DS[SI]
  2843
  2844 000011FA EB5F                            JMP     ISR21_RET       ; return to caller
  2845
  2846                                  ;----------------------------------------------------------------------
  2847                                  ; Interrupt 21h
  2848                                  ; Service   25   Set Interrupt Vector
  2849                                  ; Input     AL   Interrupt Number, DS:DX -> new interrupt handler
  2850                                  ; Output
  2851                                  ; Changed   AX
  2852                                  ;----------------------------------------------------------------------
  2853                                  ISR21_25:
  2854 000011FC 80FC25                          CMP     AH,25h
  2855 000011FF 7517                            JNE     ISR21_0B
  2856
  2857 00001201 FA                              CLI                     ; Disable Interrupts
  2858 00001202 30E4                            XOR     AH,AH
  2859 00001204 89C6                            MOV     SI,AX
  2860 00001206 D1EE                            SHR     SI,1
  2861 00001208 D1EE                            SHR     SI,1            ; Int number * 4
  2862
  2863 0000120A 31C0                            XOR     AX,AX
  2864 0000120C 8EC0                            MOV     ES,AX           ; Int table segment=0000
  2865
  2866 0000120E 268914                          MOV     [ES:SI],DX      ; Set
  2867 00001211 46                              INC     SI
  2868 00001212 46                              INC     SI              ; SI POINT TO INT CS
  2869 00001213 268C1C                          MOV     [ES:SI],DS      ; Set segment
  2870
  2871
  2872 00001216 EB43                            JMP     ISR21_RET       ; return to caller
  2873
  2874                                  ;----------------------------------------------------------------------
  2875                                  ; Interrupt 21h
  2876                                  ; Service   48   Allocate memory
  2877                                  ; Input
  2878                                  ; Output
  2879                                  ; Changed   AX
  2880                                  ;----------------------------------------------------------------------
  2881                                  ;ISR21_48:CMP       AH,48h
  2882                                  ;        JNE    ISR21_4C
  2883                                  ;        JMP    ISR21_RET                       ; return to caller
  2884
  2885
  2886                                  ;----------------------------------------------------------------------
  2887                                  ; Interrupt 21h
  2888                                  ; Service   0Bh  Check for character waiting (kbhit)
  2889                                  ; Input
  2890                                  ; Output    AL   kbhit status !=0 if key pressed
  2891                                  ; Changed   AL
  2892                                  ;----------------------------------------------------------------------
  2893                                  ISR21_0B:
  2894 00001218 80FC0B                          CMP     AH,0Bh
  2895 0000121B 750A                            JNE     ISR21_2C
  2896
  2897 0000121D 30E4                            XOR     AH,AH
  2898 0000121F BAF903                          MOV     DX,COMPORT+STATUS; get UART RX status
  2899 00001222 EC                              IN      AL,DX
  2900 00001223 2401                            AND     AL,RX_AVAIL
  2901
  2902 00001225 EB34                            JMP     ISR21_RET
  2903
  2904                                  ;----------------------------------------------------------------------
  2905                                  ; Interrupt 21h
  2906                                  ; Service   2Ch  Get System Time
  2907                                  ;           CH = hour (BCD)
  2908                                  ;           CL = minutes (BCD)
  2909                                  ;           DH = seconds (BCD)
  2910                                  ;           DL = 0
  2911                                  ;----------------------------------------------------------------------
  2912                                  ISR21_2C:
  2913 00001227 80FC2C                          CMP     AH,02Ch
  2914 0000122A 7505                            JNE     ISR21_30
  2915
  2916                                  ;            MOV        AH,02h
  2917                                  ;            INT        1Ah
  2918                                  ;            XOR        DL,DL                       ; Ignore 1/100 seconds value
  2919 0000122C E8ECFE                          CALL    READRTC         ; Get System Time
  2920 0000122F EB2A                            JMP     ISR21_RET
  2921
  2922                                  ;----------------------------------------------------------------------
  2923                                  ; Interrupt 21h
  2924                                  ; Service   30h  Get DOS version, return 2
  2925                                  ;----------------------------------------------------------------------
  2926                                  ISR21_30:
  2927 00001231 80FC30                          CMP     AH,030h
  2928 00001234 7504                            JNE     ISR21_4C
  2929
  2930 00001236 B002                            MOV     AL,02           ; DOS=2.0
  2931
  2932 00001238 EB21                            JMP     ISR21_RET
  2933
  2934                                  ;----------------------------------------------------------------------
  2935                                  ; Interrupt 21h
  2936                                  ; Service   4Ch  exit to bootloader
  2937                                  ;----------------------------------------------------------------------
  2938                                  ISR21_4C:
  2939 0000123A 80FC4C                          CMP     AH,04CH
  2940 0000123D 7514                            JNE     ISR21_x
  2941 0000123F 88C3                            MOV     BL,AL           ; Save exit code
  2942
  2943 00001241 8CC8                            MOV     AX,CS
  2944 00001243 8ED8                            MOV     DS,AX
  2945 00001245 BE[D110]                        MOV     SI,  TERM_MESS
  2946 00001248 E892FC                          CALL    PUTS
  2947 0000124B 88D8                            MOV     AL,BL
  2948 0000124D E80FFD                          CALL    PUTHEX2
  2949
  2950 00001250 E9ADED                          JMP     INITMON         ; Re-start MON88
  2951
  2952                                  ;----------------------------------------------------------------------
  2953                                  ; Interrupt 21h
  2954                                  ; Service   xx   Unkown service, display message int and ah value, return to monitor
  2955                                  ;----------------------------------------------------------------------
  2956                                  ISR21_x:
  2957 00001253 B021                            MOV     AL,21h
  2958 00001255 E80700                          CALL    DISPSERI        ; Display Int and service number
  2959 00001258 E9A5ED                          JMP     INITMON         ; Jump back to monitor
  2960
  2961                                  ISR21_RET:
  2962 0000125B 5E                              POP     SI
  2963 0000125C 07                              POP     ES
  2964 0000125D 1F                              POP     DS
  2965 0000125E CF                              IRET
  2966
  2967                                  ;----------------------------------------------------------------------
  2968                                  ; Unknown Service Handler
  2969                                  ; Display Message, interrupt and service number before jumping back to the monitor
  2970                                  ;----------------------------------------------------------------------
  2971                                  DISPSERI:
  2972 0000125F 89C3                            MOV     BX,AX           ; Store int number (AL) and service (AH)
  2973 00001261 8CC8                            MOV     AX,CS
  2974 00001263 8ED8                            MOV     DS,AX
  2975 00001265 BE[D515]                        MOV     SI,  UNKNOWNSER_MESS; Print Error: Unknown Service
  2976 00001268 E872FC                          CALL    PUTS
  2977 0000126B 88D8                            MOV     AL,BL
  2978 0000126D E8EFFC                          CALL    PUTHEX2         ; Print Interrupt Number
  2979 00001270 B02C                            MOV     AL,','
  2980 00001272 E82BFD                          CALL    TXCHAR
  2981 00001275 88F8                            MOV     AL,BH
  2982 00001277 E8E5FC                          CALL    PUTHEX2         ; Write Service number
  2983 0000127A C3                              RET
  2984
  2985                                  ;----------------------------------------------------------------------
  2986                                  ; Spurious Interrupt Handler
  2987                                  ;----------------------------------------------------------------------
  2988                                  INTX:
  2989 0000127B 1E                              PUSH    DS
  2990 0000127C 56                              PUSH    SI
  2991 0000127D 50                              PUSH    AX
  2992
  2993 0000127E 8CC8                            MOV     AX,CS           ; If AH/=0 print message and exit
  2994 00001280 8ED8                            MOV     DS,AX
  2995 00001282 BE[B415]                        MOV     SI,  UNKNOWN_MESS; Print Error: Unknown Service
  2996 00001285 E855FC                          CALL    PUTS
  2997
  2998 00001288 58                              POP     AX
  2999 00001289 5E                              POP     SI
  3000 0000128A 1F                              POP     DS
  3001 0000128B CF                              IRET
  3002
  3003
  3004                                  ;----------------------------------------------------------------------
  3005                                  ; Disassembler Tables
  3006                                  ; Watcom C compiler generated
  3007                                  ;----------------------------------------------------------------------
  3008                                  L$113:
  3009 0000128C 00                              DB      0
  3010                                  L$114:
  3011 0000128D 41414100                        DB      41H, 41H, 41H, 0
  3012                                  L$115:
  3013 00001291 41414400                        DB      41H, 41H, 44H, 0
  3014                                  L$116:
  3015 00001295 41414D00                        DB      41H, 41H, 4dH, 0
  3016                                  L$117:
  3017 00001299 41415300                        DB      41H, 41H, 53H, 0
  3018                                  L$118:
  3019 0000129D 41444300                        DB      41H, 44H, 43H, 0
  3020                                  L$119:
  3021 000012A1 41444400                        DB      41H, 44H, 44H, 0
  3022                                  L$120:
  3023 000012A5 414E4400                        DB      41H, 4eH, 44H, 0
  3024                                  L$121:
  3025 000012A9 4152504C00                      DB      41H, 52H, 50H, 4cH, 0
  3026                                  L$122:
  3027 000012AE 424F554E4400                    DB      42H, 4fH, 55H, 4eH, 44H, 0
  3028                                  L$123:
  3029 000012B4 42534600                        DB      42H, 53H, 46H, 0
  3030                                  L$124:
  3031 000012B8 42535200                        DB      42H, 53H, 52H, 0
  3032                                  L$125:
  3033 000012BC 425400                          DB      42H, 54H, 0
  3034                                  L$126:
  3035 000012BF 42544300                        DB      42H, 54H, 43H, 0
  3036                                  L$127:
  3037 000012C3 42545200                        DB      42H, 54H, 52H, 0
  3038                                  L$128:
  3039 000012C7 42545300                        DB      42H, 54H, 53H, 0
  3040                                  L$129:
  3041 000012CB 43414C4C00                      DB      43H, 41H, 4cH, 4cH, 0
  3042                                  L$130:
  3043 000012D0 43425700                        DB      43H, 42H, 57H, 0
  3044                                  L$131:
  3045 000012D4 4357444500                      DB      43H, 57H, 44H, 45H, 0
  3046                                  L$132:
  3047 000012D9 434C4300                        DB      43H, 4cH, 43H, 0
  3048                                  L$133:
  3049 000012DD 434C4400                        DB      43H, 4cH, 44H, 0
  3050                                  L$134:
  3051 000012E1 434C4900                        DB      43H, 4cH, 49H, 0
  3052                                  L$135:
  3053 000012E5 434C545300                      DB      43H, 4cH, 54H, 53H, 0
  3054                                  L$136:
  3055 000012EA 434D4300                        DB      43H, 4dH, 43H, 0
  3056                                  L$137:
  3057 000012EE 434D5000                        DB      43H, 4dH, 50H, 0
  3058                                  L$138:
  3059 000012F2 434D505300                      DB      43H, 4dH, 50H, 53H, 0
  3060                                  L$139:
  3061 000012F7 434D50534200                    DB      43H, 4dH, 50H, 53H, 42H, 0
  3062                                  L$140:
  3063 000012FD 434D50535700                    DB      43H, 4dH, 50H, 53H, 57H, 0
  3064                                  L$141:
  3065 00001303 434D50534400                    DB      43H, 4dH, 50H, 53H, 44H, 0
  3066                                  L$142:
  3067 00001309 43574400                        DB      43H, 57H, 44H, 0
  3068                                  L$143:
  3069 0000130D 43445100                        DB      43H, 44H, 51H, 0
  3070                                  L$144:
  3071 00001311 44414100                        DB      44H, 41H, 41H, 0
  3072                                  L$145:
  3073 00001315 44415300                        DB      44H, 41H, 53H, 0
  3074                                  L$146:
  3075 00001319 44454300                        DB      44H, 45H, 43H, 0
  3076                                  L$147:
  3077 0000131D 44495600                        DB      44H, 49H, 56H, 0
  3078                                  L$148:
  3079 00001321 454E54455200                    DB      45H, 4eH, 54H, 45H, 52H, 0
  3080                                  L$149:
  3081 00001327 484C5400                        DB      48H, 4cH, 54H, 0
  3082                                  L$150:
  3083 0000132B 4944495600                      DB      49H, 44H, 49H, 56H, 0
  3084                                  L$151:
  3085 00001330 494D554C00                      DB      49H, 4dH, 55H, 4cH, 0
  3086                                  L$152:
  3087 00001335 494E00                          DB      49H, 4eH, 0
  3088                                  L$153:
  3089 00001338 494E4300                        DB      49H, 4eH, 43H, 0
  3090                                  L$154:
  3091 0000133C 494E5300                        DB      49H, 4eH, 53H, 0
  3092                                  L$155:
  3093 00001340 494E534200                      DB      49H, 4eH, 53H, 42H, 0
  3094                                  L$156:
  3095 00001345 494E535700                      DB      49H, 4eH, 53H, 57H, 0
  3096                                  L$157:
  3097 0000134A 494E534400                      DB      49H, 4eH, 53H, 44H, 0
  3098                                  L$158:
  3099 0000134F 494E5400                        DB      49H, 4eH, 54H, 0
  3100                                  L$159:
  3101 00001353 494E544F00                      DB      49H, 4eH, 54H, 4fH, 0
  3102                                  L$160:
  3103 00001358 4952455400                      DB      49H, 52H, 45H, 54H, 0
  3104                                  L$161:
  3105 0000135D 495245544400                    DB      49H, 52H, 45H, 54H, 44H, 0
  3106                                  L$162:
  3107 00001363 4A4F00                          DB      4aH, 4fH, 0
  3108                                  L$163:
  3109 00001366 4A4E4F00                        DB      4aH, 4eH, 4fH, 0
  3110                                  L$164:
  3111 0000136A 4A4200                          DB      4aH, 42H, 0
  3112                                  L$165:
  3113 0000136D 4A4E4200                        DB      4aH, 4eH, 42H, 0
  3114                                  L$166:
  3115 00001371 4A5A00                          DB      4aH, 5aH, 0
  3116                                  L$167:
  3117 00001374 4A4E5A00                        DB      4aH, 4eH, 5aH, 0
  3118                                  L$168:
  3119 00001378 4A424500                        DB      4aH, 42H, 45H, 0
  3120                                  L$169:
  3121 0000137C 4A4E424500                      DB      4aH, 4eH, 42H, 45H, 0
  3122                                  L$170:
  3123 00001381 4A5300                          DB      4aH, 53H, 0
  3124                                  L$171:
  3125 00001384 4A4E5300                        DB      4aH, 4eH, 53H, 0
  3126                                  L$172:
  3127 00001388 4A5000                          DB      4aH, 50H, 0
  3128                                  L$173:
  3129 0000138B 4A4E5000                        DB      4aH, 4eH, 50H, 0
  3130                                  L$174:
  3131 0000138F 4A4C00                          DB      4aH, 4cH, 0
  3132                                  L$175:
  3133 00001392 4A4E4C00                        DB      4aH, 4eH, 4cH, 0
  3134                                  L$176:
  3135 00001396 4A4C4500                        DB      4aH, 4cH, 45H, 0
  3136                                  L$177:
  3137 0000139A 4A4E4C4500                      DB      4aH, 4eH, 4cH, 45H, 0
  3138                                  L$178:
  3139 0000139F 4A4D5000                        DB      4aH, 4dH, 50H, 0
  3140                                  L$179:
  3141 000013A3 4C41484600                      DB      4cH, 41H, 48H, 46H, 0
  3142                                  L$180:
  3143 000013A8 4C415200                        DB      4cH, 41H, 52H, 0
  3144                                  L$181:
  3145 000013AC 4C454100                        DB      4cH, 45H, 41H, 0
  3146                                  L$182:
  3147 000013B0 4C4541564500                    DB      4cH, 45H, 41H, 56H, 45H, 0
  3148                                  L$183:
  3149 000013B6 4C47445400                      DB      4cH, 47H, 44H, 54H, 0
  3150                                  L$184:
  3151 000013BB 4C49445400                      DB      4cH, 49H, 44H, 54H, 0
  3152                                  L$185:
  3153 000013C0 4C475300                        DB      4cH, 47H, 53H, 0
  3154                                  L$186:
  3155 000013C4 4C535300                        DB      4cH, 53H, 53H, 0
  3156                                  L$187:
  3157 000013C8 4C445300                        DB      4cH, 44H, 53H, 0
  3158                                  L$188:
  3159 000013CC 4C455300                        DB      4cH, 45H, 53H, 0
  3160                                  L$189:
  3161 000013D0 4C465300                        DB      4cH, 46H, 53H, 0
  3162                                  L$190:
  3163 000013D4 4C4C445400                      DB      4cH, 4cH, 44H, 54H, 0
  3164                                  L$191:
  3165 000013D9 4C4D535700                      DB      4cH, 4dH, 53H, 57H, 0
  3166                                  L$192:
  3167 000013DE 4C4F434B00                      DB      4cH, 4fH, 43H, 4bH, 0
  3168                                  L$193:
  3169 000013E3 4C4F445300                      DB      4cH, 4fH, 44H, 53H, 0
  3170                                  L$194:
  3171 000013E8 4C4F44534200                    DB      4cH, 4fH, 44H, 53H, 42H, 0
  3172                                  L$195:
  3173 000013EE 4C4F44535700                    DB      4cH, 4fH, 44H, 53H, 57H, 0
  3174                                  L$196:
  3175 000013F4 4C4F44534400                    DB      4cH, 4fH, 44H, 53H, 44H, 0
  3176                                  L$197:
  3177 000013FA 4C4F4F5000                      DB      4cH, 4fH, 4fH, 50H, 0
  3178                                  L$198:
  3179 000013FF 4C4F4F504500                    DB      4cH, 4fH, 4fH, 50H, 45H, 0
  3180                                  L$199:
  3181 00001405 4C4F4F505A00                    DB      4cH, 4fH, 4fH, 50H, 5aH, 0
  3182                                  L$200:
  3183 0000140B 4C4F4F504E4500                  DB      4cH, 4fH, 4fH, 50H, 4eH, 45H, 0
  3184                                  L$201:
  3185 00001412 4C4F4F504E5A00                  DB      4cH, 4fH, 4fH, 50H, 4eH, 5aH, 0
  3186                                  L$202:
  3187 00001419 4C534C00                        DB      4cH, 53H, 4cH, 0
  3188                                  L$203:
  3189 0000141D 4C545200                        DB      4cH, 54H, 52H, 0
  3190                                  L$204:
  3191 00001421 4D4F5600                        DB      4dH, 4fH, 56H, 0
  3192                                  L$205:
  3193 00001425 4D4F565300                      DB      4dH, 4fH, 56H, 53H, 0
  3194                                  L$206:
  3195 0000142A 4D4F56534200                    DB      4dH, 4fH, 56H, 53H, 42H, 0
  3196                                  L$207:
  3197 00001430 4D4F56535700                    DB      4dH, 4fH, 56H, 53H, 57H, 0
  3198                                  L$208:
  3199 00001436 4D4F56534400                    DB      4dH, 4fH, 56H, 53H, 44H, 0
  3200                                  L$209:
  3201 0000143C 4D4F56535800                    DB      4dH, 4fH, 56H, 53H, 58H, 0
  3202                                  L$210:
  3203 00001442 4D4F565A5800                    DB      4dH, 4fH, 56H, 5aH, 58H, 0
  3204                                  L$211:
  3205 00001448 4D554C00                        DB      4dH, 55H, 4cH, 0
  3206                                  L$212:
  3207 0000144C 4E454700                        DB      4eH, 45H, 47H, 0
  3208                                  L$213:
  3209 00001450 4E4F5000                        DB      4eH, 4fH, 50H, 0
  3210                                  L$214:
  3211 00001454 4E4F5400                        DB      4eH, 4fH, 54H, 0
  3212                                  L$215:
  3213 00001458 4F5200                          DB      4fH, 52H, 0
  3214                                  L$216:
  3215 0000145B 4F555400                        DB      4fH, 55H, 54H, 0
  3216                                  L$217:
  3217 0000145F 4F55545300                      DB      4fH, 55H, 54H, 53H, 0
  3218                                  L$218:
  3219 00001464 4F5554534200                    DB      4fH, 55H, 54H, 53H, 42H, 0
  3220                                  L$219:
  3221 0000146A 4F5554535700                    DB      4fH, 55H, 54H, 53H, 57H, 0
  3222                                  L$220:
  3223 00001470 4F5554534400                    DB      4fH, 55H, 54H, 53H, 44H, 0
  3224                                  L$221:
  3225 00001476 504F5000                        DB      50H, 4fH, 50H, 0
  3226                                  L$222:
  3227 0000147A 504F504100                      DB      50H, 4fH, 50H, 41H, 0
  3228                                  L$223:
  3229 0000147F 504F50414400                    DB      50H, 4fH, 50H, 41H, 44H, 0
  3230                                  L$224:
  3231 00001485 504F504600                      DB      50H, 4fH, 50H, 46H, 0
  3232                                  L$225:
  3233 0000148A 504F50464400                    DB      50H, 4fH, 50H, 46H, 44H, 0
  3234                                  L$226:
  3235 00001490 5055534800                      DB      50H, 55H, 53H, 48H, 0
  3236                                  L$227:
  3237 00001495 505553484100                    DB      50H, 55H, 53H, 48H, 41H, 0
  3238                                  L$228:
  3239 0000149B 50555348414400                  DB      50H, 55H, 53H, 48H, 41H, 44H, 0
  3240                                  L$229:
  3241 000014A2 505553484600                    DB      50H, 55H, 53H, 48H, 46H, 0
  3242                                  L$230:
  3243 000014A8 50555348464400                  DB      50H, 55H, 53H, 48H, 46H, 44H, 0
  3244                                  L$231:
  3245 000014AF 52434C00                        DB      52H, 43H, 4cH, 0
  3246                                  L$232:
  3247 000014B3 52435200                        DB      52H, 43H, 52H, 0
  3248                                  L$233:
  3249 000014B7 524F4C00                        DB      52H, 4fH, 4cH, 0
  3250                                  L$234:
  3251 000014BB 524F5200                        DB      52H, 4fH, 52H, 0
  3252                                  L$235:
  3253 000014BF 52455000                        DB      52H, 45H, 50H, 0
  3254                                  L$236:
  3255 000014C3 5245504500                      DB      52H, 45H, 50H, 45H, 0
  3256                                  L$237:
  3257 000014C8 5245505A00                      DB      52H, 45H, 50H, 5aH, 0
  3258                                  L$238:
  3259 000014CD 5245504E4500                    DB      52H, 45H, 50H, 4eH, 45H, 0
  3260                                  L$239:
  3261 000014D3 5245504E5A00                    DB      52H, 45H, 50H, 4eH, 5aH, 0
  3262                                  L$240:
  3263 000014D9 52455400                        DB      52H, 45H, 54H, 0
  3264                                  L$241:
  3265 000014DD 5341484600                      DB      53H, 41H, 48H, 46H, 0
  3266                                  L$242:
  3267 000014E2 53414C00                        DB      53H, 41H, 4cH, 0
  3268                                  L$243:
  3269 000014E6 53415200                        DB      53H, 41H, 52H, 0
  3270                                  L$244:
  3271 000014EA 53484C00                        DB      53H, 48H, 4cH, 0
  3272                                  L$245:
  3273 000014EE 53485200                        DB      53H, 48H, 52H, 0
  3274                                  L$246:
  3275 000014F2 53424200                        DB      53H, 42H, 42H, 0
  3276                                  L$247:
  3277 000014F6 5343415300                      DB      53H, 43H, 41H, 53H, 0
  3278                                  L$248:
  3279 000014FB 534341534200                    DB      53H, 43H, 41H, 53H, 42H, 0
  3280                                  L$249:
  3281 00001501 534341535700                    DB      53H, 43H, 41H, 53H, 57H, 0
  3282                                  L$250:
  3283 00001507 534341534400                    DB      53H, 43H, 41H, 53H, 44H, 0
  3284                                  L$251:
  3285 0000150D 53455400                        DB      53H, 45H, 54H, 0
  3286                                  L$252:
  3287 00001511 5347445400                      DB      53H, 47H, 44H, 54H, 0
  3288                                  L$253:
  3289 00001516 5349445400                      DB      53H, 49H, 44H, 54H, 0
  3290                                  L$254:
  3291 0000151B 53484C4400                      DB      53H, 48H, 4cH, 44H, 0
  3292                                  L$255:
  3293 00001520 5348524400                      DB      53H, 48H, 52H, 44H, 0
  3294                                  L$256:
  3295 00001525 534C445400                      DB      53H, 4cH, 44H, 54H, 0
  3296                                  L$257:
  3297 0000152A 534D535700                      DB      53H, 4dH, 53H, 57H, 0
  3298                                  L$258:
  3299 0000152F 53544300                        DB      53H, 54H, 43H, 0
  3300                                  L$259:
  3301 00001533 53544400                        DB      53H, 54H, 44H, 0
  3302                                  L$260:
  3303 00001537 53544900                        DB      53H, 54H, 49H, 0
  3304                                  L$261:
  3305 0000153B 53544F5300                      DB      53H, 54H, 4fH, 53H, 0
  3306                                  L$262:
  3307 00001540 53544F534200                    DB      53H, 54H, 4fH, 53H, 42H, 0
  3308                                  L$263:
  3309 00001546 53544F535700                    DB      53H, 54H, 4fH, 53H, 57H, 0
  3310                                  L$264:
  3311 0000154C 53544F534400                    DB      53H, 54H, 4fH, 53H, 44H, 0
  3312                                  L$265:
  3313 00001552 53545200                        DB      53H, 54H, 52H, 0
  3314                                  L$266:
  3315 00001556 53554200                        DB      53H, 55H, 42H, 0
  3316                                  L$267:
  3317 0000155A 5445535400                      DB      54H, 45H, 53H, 54H, 0
  3318                                  L$268:
  3319 0000155F 5645525200                      DB      56H, 45H, 52H, 52H, 0
  3320                                  L$269:
  3321 00001564 5645525700                      DB      56H, 45H, 52H, 57H, 0
  3322                                  L$270:
  3323 00001569 5741495400                      DB      57H, 41H, 49H, 54H, 0
  3324                                  L$271:
  3325 0000156E 5843484700                      DB      58H, 43H, 48H, 47H, 0
  3326                                  L$272:
  3327 00001573 584C415400                      DB      58H, 4cH, 41H, 54H, 0
  3328                                  L$273:
  3329 00001578 584C41544200                    DB      58H, 4cH, 41H, 54H, 42H, 0
  3330                                  L$274:
  3331 0000157E 584F5200                        DB      58H, 4fH, 52H, 0
  3332                                  L$275:
  3333 00001582 4A43585A00                      DB      4aH, 43H, 58H, 5aH, 0
  3334                                  L$276:
  3335 00001587 4C4F4144414C4C00                DB      4cH, 4fH, 41H, 44H, 41H, 4cH, 4cH, 0
  3336                                  L$277:
  3337 0000158F 494E564400                      DB      49H, 4eH, 56H, 44H, 0
  3338                                  L$278:
  3339 00001594 5742494E564400                  DB      57H, 42H, 49H, 4eH, 56H, 44H, 0
  3340                                  L$279:
  3341 0000159B 5345544F00                      DB      53H, 45H, 54H, 4fH, 0
  3342                                  L$280:
  3343 000015A0 5345544E4F00                    DB      53H, 45H, 54H, 4eH, 4fH, 0
  3344                                  L$281:
  3345 000015A6 5345544200                      DB      53H, 45H, 54H, 42H, 0
  3346                                  L$282:
  3347 000015AB 5345544E4200                    DB      53H, 45H, 54H, 4eH, 42H, 0
  3348                                  L$283:
  3349 000015B1 5345545A00                      DB      53H, 45H, 54H, 5aH, 0
  3350                                  L$284:
  3351 000015B6 5345544E5A00                    DB      53H, 45H, 54H, 4eH, 5aH, 0
  3352                                  L$285:
  3353 000015BC 534554424500                    DB      53H, 45H, 54H, 42H, 45H, 0
  3354                                  L$286:
  3355 000015C2 5345544E424500                  DB      53H, 45H, 54H, 4eH, 42H, 45H, 0
  3356                                  L$287:
  3357 000015C9 5345545300                      DB      53H, 45H, 54H, 53H, 0
  3358                                  L$288:
  3359 000015CE 5345544E5300                    DB      53H, 45H, 54H, 4eH, 53H, 0
  3360                                  L$289:
  3361 000015D4 5345545000                      DB      53H, 45H, 54H, 50H, 0
  3362                                  L$290:
  3363 000015D9 5345544E5000                    DB      53H, 45H, 54H, 4eH, 50H, 0
  3364                                  L$291:
  3365 000015DF 5345544C00                      DB      53H, 45H, 54H, 4cH, 0
  3366                                  L$292:
  3367 000015E4 5345544E4C00                    DB      53H, 45H, 54H, 4eH, 4cH, 0
  3368                                  L$293:
  3369 000015EA 5345544C4500                    DB      53H, 45H, 54H, 4cH, 45H, 0
  3370                                  L$294:
  3371 000015F0 5345544E4C4500                  DB      53H, 45H, 54H, 4eH, 4cH, 45H, 0
  3372                                  L$295:
  3373 000015F7 57524D535200                    DB      57H, 52H, 4dH, 53H, 52H, 0
  3374                                  L$296:
  3375 000015FD 524454534300                    DB      52H, 44H, 54H, 53H, 43H, 0
  3376                                  L$297:
  3377 00001603 52444D535200                    DB      52H, 44H, 4dH, 53H, 52H, 0
  3378                                  L$298:
  3379 00001609 435055494400                    DB      43H, 50H, 55H, 49H, 44H, 0
  3380                                  L$299:
  3381 0000160F 52534D00                        DB      52H, 53H, 4dH, 0
  3382                                  L$300:
  3383 00001613 434D505843484700                DB      43H, 4dH, 50H, 58H, 43H, 48H, 47H, 0
  3384                                  L$301:
  3385 0000161B 5841444400                      DB      58H, 41H, 44H, 44H, 0
  3386                                  L$302:
  3387 00001620 425357415000                    DB      42H, 53H, 57H, 41H, 50H, 0
  3388                                  L$303:
  3389 00001626 494E564C504700                  DB      49H, 4eH, 56H, 4cH, 50H, 47H, 0
  3390                                  L$304:
  3391 0000162D 434D505843484738                DB      43H, 4dH, 50H, 58H, 43H, 48H, 47H, 38H
  3392 00001635 4200                            DB      42H, 0
  3393                                  L$305:
  3394 00001637 4A4D502046415200                DB      4aH, 4dH, 50H, 20H, 46H, 41H, 52H, 0
  3395                                  L$306:
  3396 0000163F 5245544600                      DB      52H, 45H, 54H, 46H, 0
  3397                                  L$307:
  3398 00001644 5244504D4300                    DB      52H, 44H, 50H, 4dH, 43H, 0
  3399                                  L$308:
  3400 0000164A 55443200                        DB      55H, 44H, 32H, 0
  3401                                  L$309:
  3402 0000164E 434D4F564F00                    DB      43H, 4dH, 4fH, 56H, 4fH, 0
  3403                                  L$310:
  3404 00001654 434D4F564E4F00                  DB      43H, 4dH, 4fH, 56H, 4eH, 4fH, 0
  3405                                  L$311:
  3406 0000165B 434D4F564200                    DB      43H, 4dH, 4fH, 56H, 42H, 0
  3407                                  L$312:
  3408 00001661 434D4F56414500                  DB      43H, 4dH, 4fH, 56H, 41H, 45H, 0
  3409                                  L$313:
  3410 00001668 434D4F564500                    DB      43H, 4dH, 4fH, 56H, 45H, 0
  3411                                  L$314:
  3412 0000166E 434D4F564E4500                  DB      43H, 4dH, 4fH, 56H, 4eH, 45H, 0
  3413                                  L$315:
  3414 00001675 434D4F56424500                  DB      43H, 4dH, 4fH, 56H, 42H, 45H, 0
  3415                                  L$316:
  3416 0000167C 434D4F564100                    DB      43H, 4dH, 4fH, 56H, 41H, 0
  3417                                  L$317:
  3418 00001682 434D4F565300                    DB      43H, 4dH, 4fH, 56H, 53H, 0
  3419                                  L$318:
  3420 00001688 434D4F564E5300                  DB      43H, 4dH, 4fH, 56H, 4eH, 53H, 0
  3421                                  L$319:
  3422 0000168F 434D4F565000                    DB      43H, 4dH, 4fH, 56H, 50H, 0
  3423                                  L$320:
  3424 00001695 434D4F564E5000                  DB      43H, 4dH, 4fH, 56H, 4eH, 50H, 0
  3425                                  L$321:
  3426 0000169C 434D4F564C00                    DB      43H, 4dH, 4fH, 56H, 4cH, 0
  3427                                  L$322:
  3428 000016A2 434D4F564E4C00                  DB      43H, 4dH, 4fH, 56H, 4eH, 4cH, 0
  3429                                  L$323:
  3430 000016A9 434D4F564C4500                  DB      43H, 4dH, 4fH, 56H, 4cH, 45H, 0
  3431                                  L$324:
  3432 000016B0 434D4F564E4C4500                DB      43H, 4dH, 4fH, 56H, 4eH, 4cH, 45H, 0
  3433                                  L$325:
  3434 000016B8 5052454645544348                DB      50H, 52H, 45H, 46H, 45H, 54H, 43H, 48H
  3435 000016C0 4E544100                        DB      4eH, 54H, 41H, 0
  3436                                  L$326:
  3437 000016C4 5052454645544348                DB      50H, 52H, 45H, 46H, 45H, 54H, 43H, 48H
  3438 000016CC 543000                          DB      54H, 30H, 0
  3439                                  L$327:
  3440 000016CF 5052454645544348                DB      50H, 52H, 45H, 46H, 45H, 54H, 43H, 48H
  3441 000016D7 543100                          DB      54H, 31H, 0
  3442                                  L$328:
  3443 000016DA 5052454645544348                DB      50H, 52H, 45H, 46H, 45H, 54H, 43H, 48H
  3444 000016E2 543200                          DB      54H, 32H, 0
  3445                                  L$329:
  3446 000016E5 4632584D3100                    DB      46H, 32H, 58H, 4dH, 31H, 0
  3447                                  L$330:
  3448 000016EB 4641425300                      DB      46H, 41H, 42H, 53H, 0
  3449                                  L$331:
  3450 000016F0 4641444400                      DB      46H, 41H, 44H, 44H, 0
  3451                                  L$332:
  3452 000016F5 464144445000                    DB      46H, 41H, 44H, 44H, 50H, 0
  3453                                  L$333:
  3454 000016FB 46424C4400                      DB      46H, 42H, 4cH, 44H, 0
  3455                                  L$334:
  3456 00001700 464253545000                    DB      46H, 42H, 53H, 54H, 50H, 0
  3457                                  L$335:
  3458 00001706 4643485300                      DB      46H, 43H, 48H, 53H, 0
  3459                                  L$336:
  3460 0000170B 46434C455800                    DB      46H, 43H, 4cH, 45H, 58H, 0
  3461                                  L$337:
  3462 00001711 46434F4D00                      DB      46H, 43H, 4fH, 4dH, 0
  3463                                  L$338:
  3464 00001716 46434F4D5000                    DB      46H, 43H, 4fH, 4dH, 50H, 0
  3465                                  L$339:
  3466 0000171C 46434F4D505000                  DB      46H, 43H, 4fH, 4dH, 50H, 50H, 0
  3467                                  L$340:
  3468 00001723 46434F5300                      DB      46H, 43H, 4fH, 53H, 0
  3469                                  L$341:
  3470 00001728 4644454353545000                DB      46H, 44H, 45H, 43H, 53H, 54H, 50H, 0
  3471                                  L$342:
  3472 00001730 4644495600                      DB      46H, 44H, 49H, 56H, 0
  3473                                  L$343:
  3474 00001735 464449565000                    DB      46H, 44H, 49H, 56H, 50H, 0
  3475                                  L$344:
  3476 0000173B 464449565200                    DB      46H, 44H, 49H, 56H, 52H, 0
  3477                                  L$345:
  3478 00001741 46444956525000                  DB      46H, 44H, 49H, 56H, 52H, 50H, 0
  3479                                  L$346:
  3480 00001748 464652454500                    DB      46H, 46H, 52H, 45H, 45H, 0
  3481                                  L$347:
  3482 0000174E 464941444400                    DB      46H, 49H, 41H, 44H, 44H, 0
  3483                                  L$348:
  3484 00001754 4649434F4D00                    DB      46H, 49H, 43H, 4fH, 4dH, 0
  3485                                  L$349:
  3486 0000175A 4649434F4D5000                  DB      46H, 49H, 43H, 4fH, 4dH, 50H, 0
  3487                                  L$350:
  3488 00001761 464944495600                    DB      46H, 49H, 44H, 49H, 56H, 0
  3489                                  L$351:
  3490 00001767 46494449565200                  DB      46H, 49H, 44H, 49H, 56H, 52H, 0
  3491                                  L$352:
  3492 0000176E 46494C4400                      DB      46H, 49H, 4cH, 44H, 0
  3493                                  L$353:
  3494 00001773 46494D554C00                    DB      46H, 49H, 4dH, 55H, 4cH, 0
  3495                                  L$354:
  3496 00001779 46494E4353545000                DB      46H, 49H, 4eH, 43H, 53H, 54H, 50H, 0
  3497                                  L$355:
  3498 00001781 46494E495400                    DB      46H, 49H, 4eH, 49H, 54H, 0
  3499                                  L$356:
  3500 00001787 4649535400                      DB      46H, 49H, 53H, 54H, 0
  3501                                  L$357:
  3502 0000178C 464953545000                    DB      46H, 49H, 53H, 54H, 50H, 0
  3503                                  L$358:
  3504 00001792 464953554200                    DB      46H, 49H, 53H, 55H, 42H, 0
  3505                                  L$359:
  3506 00001798 46495355425200                  DB      46H, 49H, 53H, 55H, 42H, 52H, 0
  3507                                  L$360:
  3508 0000179F 464C4400                        DB      46H, 4cH, 44H, 0
  3509                                  L$361:
  3510 000017A3 464C443100                      DB      46H, 4cH, 44H, 31H, 0
  3511                                  L$362:
  3512 000017A8 464C44435700                    DB      46H, 4cH, 44H, 43H, 57H, 0
  3513                                  L$363:
  3514 000017AE 464C44454E5600                  DB      46H, 4cH, 44H, 45H, 4eH, 56H, 0
  3515                                  L$364:
  3516 000017B5 464C444C324500                  DB      46H, 4cH, 44H, 4cH, 32H, 45H, 0
  3517                                  L$365:
  3518 000017BC 464C444C325400                  DB      46H, 4cH, 44H, 4cH, 32H, 54H, 0
  3519                                  L$366:
  3520 000017C3 464C444C473200                  DB      46H, 4cH, 44H, 4cH, 47H, 32H, 0
  3521                                  L$367:
  3522 000017CA 464C444C4E3200                  DB      46H, 4cH, 44H, 4cH, 4eH, 32H, 0
  3523                                  L$368:
  3524 000017D1 464C44504900                    DB      46H, 4cH, 44H, 50H, 49H, 0
  3525                                  L$369:
  3526 000017D7 464C445A00                      DB      46H, 4cH, 44H, 5aH, 0
  3527                                  L$370:
  3528 000017DC 464D554C00                      DB      46H, 4dH, 55H, 4cH, 0
  3529                                  L$371:
  3530 000017E1 464D554C5000                    DB      46H, 4dH, 55H, 4cH, 50H, 0
  3531                                  L$372:
  3532 000017E7 464E4F5000                      DB      46H, 4eH, 4fH, 50H, 0
  3533                                  L$373:
  3534 000017EC 46504154414E00                  DB      46H, 50H, 41H, 54H, 41H, 4eH, 0
  3535                                  L$374:
  3536 000017F3 465052454D00                    DB      46H, 50H, 52H, 45H, 4dH, 0
  3537                                  L$375:
  3538 000017F9 465052454D3100                  DB      46H, 50H, 52H, 45H, 4dH, 31H, 0
  3539                                  L$376:
  3540 00001800 465054414E00                    DB      46H, 50H, 54H, 41H, 4eH, 0
  3541                                  L$377:
  3542 00001806 46524E44494E5400                DB      46H, 52H, 4eH, 44H, 49H, 4eH, 54H, 0
  3543                                  L$378:
  3544 0000180E 465253544F5200                  DB      46H, 52H, 53H, 54H, 4fH, 52H, 0
  3545                                  L$379:
  3546 00001815 465341564500                    DB      46H, 53H, 41H, 56H, 45H, 0
  3547                                  L$380:
  3548 0000181B 465343414C4500                  DB      46H, 53H, 43H, 41H, 4cH, 45H, 0
  3549                                  L$381:
  3550 00001822 4653494E00                      DB      46H, 53H, 49H, 4eH, 0
  3551                                  L$382:
  3552 00001827 4653494E434F5300                DB      46H, 53H, 49H, 4eH, 43H, 4fH, 53H, 0
  3553                                  L$383:
  3554 0000182F 465351525400                    DB      46H, 53H, 51H, 52H, 54H, 0
  3555                                  L$384:
  3556 00001835 46535400                        DB      46H, 53H, 54H, 0
  3557                                  L$385:
  3558 00001839 465354435700                    DB      46H, 53H, 54H, 43H, 57H, 0
  3559                                  L$386:
  3560 0000183F 465354454E5600                  DB      46H, 53H, 54H, 45H, 4eH, 56H, 0
  3561                                  L$387:
  3562 00001846 4653545000                      DB      46H, 53H, 54H, 50H, 0
  3563                                  L$388:
  3564 0000184B 465354535700                    DB      46H, 53H, 54H, 53H, 57H, 0
  3565                                  L$389:
  3566 00001851 4653554200                      DB      46H, 53H, 55H, 42H, 0
  3567                                  L$390:
  3568 00001856 465355425000                    DB      46H, 53H, 55H, 42H, 50H, 0
  3569                                  L$391:
  3570 0000185C 465355425200                    DB      46H, 53H, 55H, 42H, 52H, 0
  3571                                  L$392:
  3572 00001862 46535542525000                  DB      46H, 53H, 55H, 42H, 52H, 50H, 0
  3573                                  L$393:
  3574 00001869 4654535400                      DB      46H, 54H, 53H, 54H, 0
  3575                                  L$394:
  3576 0000186E 4655434F4D00                    DB      46H, 55H, 43H, 4fH, 4dH, 0
  3577                                  L$395:
  3578 00001874 4655434F4D5000                  DB      46H, 55H, 43H, 4fH, 4dH, 50H, 0
  3579                                  L$396:
  3580 0000187B 4655434F4D505000                DB      46H, 55H, 43H, 4fH, 4dH, 50H, 50H, 0
  3581                                  L$397:
  3582 00001883 4658414D00                      DB      46H, 58H, 41H, 4dH, 0
  3583                                  L$398:
  3584 00001888 4658434800                      DB      46H, 58H, 43H, 48H, 0
  3585                                  L$399:
  3586 0000188D 4658545241435400                DB      46H, 58H, 54H, 52H, 41H, 43H, 54H, 0
  3587                                  L$400:
  3588 00001895 46594C325800                    DB      46H, 59H, 4cH, 32H, 58H, 0
  3589                                  L$401:
  3590 0000189B 46594C3258503100                DB      46H, 59H, 4cH, 32H, 58H, 50H, 31H, 0
  3591                                  L$402:
  3592 000018A3 455300                          DB      45H, 53H, 0
  3593                                  L$403:
  3594 000018A6 435300                          DB      43H, 53H, 0
  3595                                  L$404:
  3596 000018A9 535300                          DB      53H, 53H, 0
  3597                                  L$405:
  3598 000018AC 445300                          DB      44H, 53H, 0
  3599                                  L$406:
  3600 000018AF 465300                          DB      46H, 53H, 0
  3601                                  L$407:
  3602 000018B2 475300                          DB      47H, 53H, 0
  3603                                  L$408:
  3604 000018B5 3F00                            DB      3fH, 0
  3605                                  L$409:
  3606 000018B7 2A3200                          DB      2aH, 32H, 0
  3607                                  L$410:
  3608 000018BA 2A3400                          DB      2aH, 34H, 0
  3609                                  L$411:
  3610 000018BD 2A3800                          DB      2aH, 38H, 0
  3611                                  L$412:
  3612 000018C0 42582B534900                    DB      42H, 58H, 2bH, 53H, 49H, 0
  3613                                  L$413:
  3614 000018C6 42582B444900                    DB      42H, 58H, 2bH, 44H, 49H, 0
  3615                                  L$414:
  3616 000018CC 42502B534900                    DB      42H, 50H, 2bH, 53H, 49H, 0
  3617                                  L$415:
  3618 000018D2 42502B444900                    DB      42H, 50H, 2bH, 44H, 49H, 0
  3619                                  L$416:
  3620 000018D8 534900                          DB      53H, 49H, 0
  3621                                  L$417:
  3622 000018DB 444900                          DB      44H, 49H, 0
  3623                                  L$418:
  3624 000018DE 425000                          DB      42H, 50H, 0
  3625                                  L$419:
  3626 000018E1 425800                          DB      42H, 58H, 0
  3627                                  L$420:
  3628 000018E4 414C00                          DB      41H, 4cH, 0
  3629                                  L$421:
  3630 000018E7 434C00                          DB      43H, 4cH, 0
  3631                                  L$422:
  3632 000018EA 444C00                          DB      44H, 4cH, 0
  3633                                  L$423:
  3634 000018ED 424C00                          DB      42H, 4cH, 0
  3635                                  L$424:
  3636 000018F0 414800                          DB      41H, 48H, 0
  3637                                  L$425:
  3638 000018F3 434800                          DB      43H, 48H, 0
  3639                                  L$426:
  3640 000018F6 444800                          DB      44H, 48H, 0
  3641                                  L$427:
  3642 000018F9 424800                          DB      42H, 48H, 0
  3643                                  L$428:
  3644 000018FC 415800                          DB      41H, 58H, 0
  3645                                  L$429:
  3646 000018FF 435800                          DB      43H, 58H, 0
  3647                                  L$430:
  3648 00001902 445800                          DB      44H, 58H, 0
  3649                                  L$431:
  3650 00001905 535000                          DB      53H, 50H, 0
  3651                                  L$432:
  3652 00001908 43523000                        DB      43H, 52H, 30H, 0
  3653                                  L$433:
  3654 0000190C 43523100                        DB      43H, 52H, 31H, 0
  3655                                  L$434:
  3656 00001910 43523200                        DB      43H, 52H, 32H, 0
  3657                                  L$435:
  3658 00001914 43523300                        DB      43H, 52H, 33H, 0
  3659                                  L$436:
  3660 00001918 43523400                        DB      43H, 52H, 34H, 0
  3661                                  L$437:
  3662 0000191C 44523000                        DB      44H, 52H, 30H, 0
  3663                                  L$438:
  3664 00001920 44523100                        DB      44H, 52H, 31H, 0
  3665                                  L$439:
  3666 00001924 44523200                        DB      44H, 52H, 32H, 0
  3667                                  L$440:
  3668 00001928 44523300                        DB      44H, 52H, 33H, 0
  3669                                  L$441:
  3670 0000192C 44523400                        DB      44H, 52H, 34H, 0
  3671                                  L$442:
  3672 00001930 44523500                        DB      44H, 52H, 35H, 0
  3673                                  L$443:
  3674 00001934 44523600                        DB      44H, 52H, 36H, 0
  3675                                  L$444:
  3676 00001938 44523700                        DB      44H, 52H, 37H, 0
  3677                                  L$445:
  3678 0000193C 5B44495D00                      DB      5bH, 44H, 49H, 5dH, 0
  3679                                  L$446:
  3680 00001941 5B4544495D00                    DB      5bH, 45H, 44H, 49H, 5dH, 0
  3681                                  L$447:
  3682 00001947 5B53495D00                      DB      5bH, 53H, 49H, 5dH, 0
  3683                                  L$448:
  3684 0000194C 5B4553495D00                    DB      5bH, 45H, 53H, 49H, 5dH, 0
  3685                                  L$449:
  3686 00001952 252D313273202573                DB      25H, 2dH, 31H, 32H, 73H, 20H, 25H, 73H
  3687 0000195A 0A00                            DB      0aH, 0
  3688                                  L$450:
  3689 0000195C 2530325800                      DB      25H, 30H, 32H, 58H, 0
  3690                                  L$451:
  3691 00001961 25733A00                        DB      25H, 73H, 3aH, 0
  3692                                  L$452:
  3693 00001965 5245504E5A2000                  DB      52H, 45H, 50H, 4eH, 5aH, 20H, 0
  3694                                  L$453:
  3695 0000196C 5245502000                      DB      52H, 45H, 50H, 20H, 0
  3696                                  L$454:
  3697 00001971 496C6C6567616C20                DB      49H, 6cH, 6cH, 65H, 67H, 61H, 6cH, 20H
  3698 00001979 696E737472756374                DB      69H, 6eH, 73H, 74H, 72H, 75H, 63H, 74H
  3699 00001981 696F6E00                        DB      69H, 6fH, 6eH, 0
  3700                                  L$455:
  3701 00001985 507265666978206E                DB      50H, 72H, 65H, 66H, 69H, 78H, 20H, 6eH
  3702 0000198D 6F7420696D706C65                DB      6fH, 74H, 20H, 69H, 6dH, 70H, 6cH, 65H
  3703 00001995 6D656E74656400                  DB      6dH, 65H, 6eH, 74H, 65H, 64H, 0
  3704                                  L$456:
  3705 0000199C 25732000                        DB      25H, 73H, 20H, 0
  3706                                  L$457:
  3707 000019A0 255800                          DB      25H, 58H, 0
  3708                                  L$458:
  3709 000019A3 2530345800                      DB      25H, 30H, 34H, 58H, 0
  3710                                  L$459:
  3711 000019A8 44533A257300                    DB      44H, 53H, 3aH, 25H, 73H, 0
  3712                                  L$460:
  3713 000019AE 45533A257300                    DB      45H, 53H, 3aH, 25H, 73H, 0
  3714                                  L$461:
  3715 000019B4 253034583A253038                DB      25H, 30H, 34H, 58H, 3aH, 25H, 30H, 38H
  3716 000019BC 5800                            DB      58H, 0
  3717                                  L$462:
  3718 000019BE 256400                          DB      25H, 64H, 0
  3719                                  L$463:
  3720 000019C1 257300                          DB      25H, 73H, 0
  3721                                  L$464:
  3722 000019C4 556E696D706C656D                DB      55H, 6eH, 69H, 6dH, 70H, 6cH, 65H, 6dH
  3723 000019CC 656E746564206F70                DB      65H, 6eH, 74H, 65H, 64H, 20H, 6fH, 70H
  3724 000019D4 6572616E64202558                DB      65H, 72H, 61H, 6eH, 64H, 20H, 25H, 58H
  3725 000019DC 00                              DB      0
  3726                                  L$465:
  3727 000019DD 2C2000                          DB      2cH, 20H, 0
  3728                                  L$466:
  3729 000019E0 5B25735D00                      DB      5bH, 25H, 73H, 5dH, 0
  3730                                  L$467:
  3731 000019E5 5B25585D00                      DB      5bH, 25H, 58H, 5dH, 0
  3732                                  L$468:
  3733 000019EA 25732B255800                    DB      25H, 73H, 2bH, 25H, 58H, 0
  3734                                  L$469:
  3735 000019F0 286E756C6C2900                  DB      28H, 6eH, 75H, 6cH, 6cH, 29H, 0
  3736
  3737
  3738                                  ;CONST2:
  3739                                  ;        SEGMENT WORD ;PUBLIC USE16 'DATA'
  3740
  3741                                  _DATA:
  3742                                          SEGMENT WORD            ;PUBLIC USE16 'DATA'
  3743
  3744
  3745
  3746                                  _opnames:
  3747 00000000 [8C12]                          DW      L$113
  3748 00000002 [8D12]                          DW      L$114
  3749 00000004 [9112]                          DW      L$115
  3750 00000006 [9512]                          DW      L$116
  3751 00000008 [9912]                          DW      L$117
  3752 0000000A [9D12]                          DW      L$118
  3753 0000000C [A112]                          DW      L$119
  3754 0000000E [A512]                          DW      L$120
  3755 00000010 [A912]                          DW      L$121
  3756 00000012 [AE12]                          DW      L$122
  3757 00000014 [B412]                          DW      L$123
  3758 00000016 [B812]                          DW      L$124
  3759 00000018 [BC12]                          DW      L$125
  3760 0000001A [BF12]                          DW      L$126
  3761 0000001C [C312]                          DW      L$127
  3762 0000001E [C712]                          DW      L$128
  3763 00000020 [CB12]                          DW      L$129
  3764 00000022 [D012]                          DW      L$130
  3765 00000024 [D412]                          DW      L$131
  3766 00000026 [D912]                          DW      L$132
  3767 00000028 [DD12]                          DW      L$133
  3768 0000002A [E112]                          DW      L$134
  3769 0000002C [E512]                          DW      L$135
  3770 0000002E [EA12]                          DW      L$136
  3771 00000030 [EE12]                          DW      L$137
  3772 00000032 [F212]                          DW      L$138
  3773 00000034 [F712]                          DW      L$139
  3774 00000036 [FD12]                          DW      L$140
  3775 00000038 [0313]                          DW      L$141
  3776 0000003A [0913]                          DW      L$142
  3777 0000003C [0D13]                          DW      L$143
  3778 0000003E [1113]                          DW      L$144
  3779 00000040 [1513]                          DW      L$145
  3780 00000042 [1913]                          DW      L$146
  3781 00000044 [1D13]                          DW      L$147
  3782 00000046 [2113]                          DW      L$148
  3783 00000048 [2713]                          DW      L$149
  3784 0000004A [2B13]                          DW      L$150
  3785 0000004C [3013]                          DW      L$151
  3786 0000004E [3513]                          DW      L$152
  3787 00000050 [3813]                          DW      L$153
  3788 00000052 [3C13]                          DW      L$154
  3789 00000054 [4013]                          DW      L$155
  3790 00000056 [4513]                          DW      L$156
  3791 00000058 [4A13]                          DW      L$157
  3792 0000005A [4F13]                          DW      L$158
  3793 0000005C [5313]                          DW      L$159
  3794 0000005E [5813]                          DW      L$160
  3795 00000060 [5D13]                          DW      L$161
  3796 00000062 [6313]                          DW      L$162
  3797 00000064 [6613]                          DW      L$163
  3798 00000066 [6A13]                          DW      L$164
  3799 00000068 [6D13]                          DW      L$165
  3800 0000006A [7113]                          DW      L$166
  3801 0000006C [7413]                          DW      L$167
  3802 0000006E [7813]                          DW      L$168
  3803 00000070 [7C13]                          DW      L$169
  3804 00000072 [8113]                          DW      L$170
  3805 00000074 [8413]                          DW      L$171
  3806 00000076 [8813]                          DW      L$172
  3807 00000078 [8B13]                          DW      L$173
  3808 0000007A [8F13]                          DW      L$174
  3809 0000007C [9213]                          DW      L$175
  3810 0000007E [9613]                          DW      L$176
  3811 00000080 [9A13]                          DW      L$177
  3812 00000082 [9F13]                          DW      L$178
  3813 00000084 [A313]                          DW      L$179
  3814 00000086 [A813]                          DW      L$180
  3815 00000088 [AC13]                          DW      L$181
  3816 0000008A [B013]                          DW      L$182
  3817 0000008C [B613]                          DW      L$183
  3818 0000008E [BB13]                          DW      L$184
  3819 00000090 [C013]                          DW      L$185
  3820 00000092 [C413]                          DW      L$186
  3821 00000094 [C813]                          DW      L$187
  3822 00000096 [CC13]                          DW      L$188
  3823 00000098 [D013]                          DW      L$189
  3824 0000009A [D413]                          DW      L$190
  3825 0000009C [D913]                          DW      L$191
  3826 0000009E [DE13]                          DW      L$192
  3827 000000A0 [E313]                          DW      L$193
  3828 000000A2 [E813]                          DW      L$194
  3829 000000A4 [EE13]                          DW      L$195
  3830 000000A6 [F413]                          DW      L$196
  3831 000000A8 [FA13]                          DW      L$197
  3832 000000AA [FF13]                          DW      L$198
  3833 000000AC [0514]                          DW      L$199
  3834 000000AE [0B14]                          DW      L$200
  3835 000000B0 [1214]                          DW      L$201
  3836 000000B2 [1914]                          DW      L$202
  3837 000000B4 [1D14]                          DW      L$203
  3838 000000B6 [2114]                          DW      L$204
  3839 000000B8 [2514]                          DW      L$205
  3840 000000BA [2A14]                          DW      L$206
  3841 000000BC [3014]                          DW      L$207
  3842 000000BE [3614]                          DW      L$208
  3843 000000C0 [3C14]                          DW      L$209
  3844 000000C2 [4214]                          DW      L$210
  3845 000000C4 [4814]                          DW      L$211
  3846 000000C6 [4C14]                          DW      L$212
  3847 000000C8 [5014]                          DW      L$213
  3848 000000CA [5414]                          DW      L$214
  3849 000000CC [5814]                          DW      L$215
  3850 000000CE [5B14]                          DW      L$216
  3851 000000D0 [5F14]                          DW      L$217
  3852 000000D2 [6414]                          DW      L$218
  3853 000000D4 [6A14]                          DW      L$219
  3854 000000D6 [7014]                          DW      L$220
  3855 000000D8 [7614]                          DW      L$221
  3856 000000DA [7A14]                          DW      L$222
  3857 000000DC [7F14]                          DW      L$223
  3858 000000DE [8514]                          DW      L$224
  3859 000000E0 [8A14]                          DW      L$225
  3860 000000E2 [9014]                          DW      L$226
  3861 000000E4 [9514]                          DW      L$227
  3862 000000E6 [9B14]                          DW      L$228
  3863 000000E8 [A214]                          DW      L$229
  3864 000000EA [A814]                          DW      L$230
  3865 000000EC [AF14]                          DW      L$231
  3866 000000EE [B314]                          DW      L$232
  3867 000000F0 [B714]                          DW      L$233
  3868 000000F2 [BB14]                          DW      L$234
  3869 000000F4 [BF14]                          DW      L$235
  3870 000000F6 [C314]                          DW      L$236
  3871 000000F8 [C814]                          DW      L$237
  3872 000000FA [CD14]                          DW      L$238
  3873 000000FC [D314]                          DW      L$239
  3874 000000FE [D914]                          DW      L$240
  3875 00000100 [DD14]                          DW      L$241
  3876 00000102 [E214]                          DW      L$242
  3877 00000104 [E614]                          DW      L$243
  3878 00000106 [EA14]                          DW      L$244
  3879 00000108 [EE14]                          DW      L$245
  3880 0000010A [F214]                          DW      L$246
  3881 0000010C [F614]                          DW      L$247
  3882 0000010E [FB14]                          DW      L$248
  3883 00000110 [0115]                          DW      L$249
  3884 00000112 [0715]                          DW      L$250
  3885 00000114 [0D15]                          DW      L$251
  3886 00000116 [1115]                          DW      L$252
  3887 00000118 [1615]                          DW      L$253
  3888 0000011A [1B15]                          DW      L$254
  3889 0000011C [2015]                          DW      L$255
  3890 0000011E [2515]                          DW      L$256
  3891 00000120 [2A15]                          DW      L$257
  3892 00000122 [2F15]                          DW      L$258
  3893 00000124 [3315]                          DW      L$259
  3894 00000126 [3715]                          DW      L$260
  3895 00000128 [3B15]                          DW      L$261
  3896 0000012A [4015]                          DW      L$262
  3897 0000012C [4615]                          DW      L$263
  3898 0000012E [4C15]                          DW      L$264
  3899 00000130 [5215]                          DW      L$265
  3900 00000132 [5615]                          DW      L$266
  3901 00000134 [5A15]                          DW      L$267
  3902 00000136 [5F15]                          DW      L$268
  3903 00000138 [6415]                          DW      L$269
  3904 0000013A [6915]                          DW      L$270
  3905 0000013C [6E15]                          DW      L$271
  3906 0000013E [7315]                          DW      L$272
  3907 00000140 [7815]                          DW      L$273
  3908 00000142 [7E15]                          DW      L$274
  3909 00000144 [8215]                          DW      L$275
  3910 00000146 [8715]                          DW      L$276
  3911 00000148 [8F15]                          DW      L$277
  3912 0000014A [9415]                          DW      L$278
  3913 0000014C [9B15]                          DW      L$279
  3914 0000014E [A015]                          DW      L$280
  3915 00000150 [A615]                          DW      L$281
  3916 00000152 [AB15]                          DW      L$282
  3917 00000154 [B115]                          DW      L$283
  3918 00000156 [B615]                          DW      L$284
  3919 00000158 [BC15]                          DW      L$285
  3920 0000015A [C215]                          DW      L$286
  3921 0000015C [C915]                          DW      L$287
  3922 0000015E [CE15]                          DW      L$288
  3923 00000160 [D415]                          DW      L$289
  3924 00000162 [D915]                          DW      L$290
  3925 00000164 [DF15]                          DW      L$291
  3926 00000166 [E415]                          DW      L$292
  3927 00000168 [EA15]                          DW      L$293
  3928 0000016A [F015]                          DW      L$294
  3929 0000016C [F715]                          DW      L$295
  3930 0000016E [FD15]                          DW      L$296
  3931 00000170 [0316]                          DW      L$297
  3932 00000172 [0916]                          DW      L$298
  3933 00000174 [0F16]                          DW      L$299
  3934 00000176 [1316]                          DW      L$300
  3935 00000178 [1B16]                          DW      L$301
  3936 0000017A [2016]                          DW      L$302
  3937 0000017C [2616]                          DW      L$303
  3938 0000017E [2D16]                          DW      L$304
  3939 00000180 [3716]                          DW      L$305
  3940 00000182 [3F16]                          DW      L$306
  3941 00000184 [4416]                          DW      L$307
  3942 00000186 [4A16]                          DW      L$308
  3943 00000188 [4E16]                          DW      L$309
  3944 0000018A [5416]                          DW      L$310
  3945 0000018C [5B16]                          DW      L$311
  3946 0000018E [6116]                          DW      L$312
  3947 00000190 [6816]                          DW      L$313
  3948 00000192 [6E16]                          DW      L$314
  3949 00000194 [7516]                          DW      L$315
  3950 00000196 [7C16]                          DW      L$316
  3951 00000198 [8216]                          DW      L$317
  3952 0000019A [8816]                          DW      L$318
  3953 0000019C [8F16]                          DW      L$319
  3954 0000019E [9516]                          DW      L$320
  3955 000001A0 [9C16]                          DW      L$321
  3956 000001A2 [A216]                          DW      L$322
  3957 000001A4 [A916]                          DW      L$323
  3958 000001A6 [B016]                          DW      L$324
  3959 000001A8 [B816]                          DW      L$325
  3960 000001AA [C416]                          DW      L$326
  3961 000001AC [CF16]                          DW      L$327
  3962 000001AE [DA16]                          DW      L$328
  3963                                  _coproc_names:
  3964 000001B0 [8C12]                          DW      L$113
  3965 000001B2 [E516]                          DW      L$329
  3966 000001B4 [EB16]                          DW      L$330
  3967 000001B6 [F016]                          DW      L$331
  3968 000001B8 [F516]                          DW      L$332
  3969 000001BA [FB16]                          DW      L$333
  3970 000001BC [0017]                          DW      L$334
  3971 000001BE [0617]                          DW      L$335
  3972 000001C0 [0B17]                          DW      L$336
  3973 000001C2 [1117]                          DW      L$337
  3974 000001C4 [1617]                          DW      L$338
  3975 000001C6 [1C17]                          DW      L$339
  3976 000001C8 [2317]                          DW      L$340
  3977 000001CA [2817]                          DW      L$341
  3978 000001CC [3017]                          DW      L$342
  3979 000001CE [3517]                          DW      L$343
  3980 000001D0 [3B17]                          DW      L$344
  3981 000001D2 [4117]                          DW      L$345
  3982 000001D4 [4817]                          DW      L$346
  3983 000001D6 [4E17]                          DW      L$347
  3984 000001D8 [5417]                          DW      L$348
  3985 000001DA [5A17]                          DW      L$349
  3986 000001DC [6117]                          DW      L$350
  3987 000001DE [6717]                          DW      L$351
  3988 000001E0 [6E17]                          DW      L$352
  3989 000001E2 [7317]                          DW      L$353
  3990 000001E4 [7917]                          DW      L$354
  3991 000001E6 [8117]                          DW      L$355
  3992 000001E8 [8717]                          DW      L$356
  3993 000001EA [8C17]                          DW      L$357
  3994 000001EC [9217]                          DW      L$358
  3995 000001EE [9817]                          DW      L$359
  3996 000001F0 [9F17]                          DW      L$360
  3997 000001F2 [A317]                          DW      L$361
  3998 000001F4 [A817]                          DW      L$362
  3999 000001F6 [AE17]                          DW      L$363
  4000 000001F8 [B517]                          DW      L$364
  4001 000001FA [BC17]                          DW      L$365
  4002 000001FC [C317]                          DW      L$366
  4003 000001FE [CA17]                          DW      L$367
  4004 00000200 [D117]                          DW      L$368
  4005 00000202 [D717]                          DW      L$369
  4006 00000204 [DC17]                          DW      L$370
  4007 00000206 [E117]                          DW      L$371
  4008 00000208 [E717]                          DW      L$372
  4009 0000020A [EC17]                          DW      L$373
  4010 0000020C [F317]                          DW      L$374
  4011 0000020E [F917]                          DW      L$375
  4012 00000210 [0018]                          DW      L$376
  4013 00000212 [0618]                          DW      L$377
  4014 00000214 [0E18]                          DW      L$378
  4015 00000216 [1518]                          DW      L$379
  4016 00000218 [1B18]                          DW      L$380
  4017 0000021A [2218]                          DW      L$381
  4018 0000021C [2718]                          DW      L$382
  4019 0000021E [2F18]                          DW      L$383
  4020 00000220 [3518]                          DW      L$384
  4021 00000222 [3918]                          DW      L$385
  4022 00000224 [3F18]                          DW      L$386
  4023 00000226 [4618]                          DW      L$387
  4024 00000228 [4B18]                          DW      L$388
  4025 0000022A [5118]                          DW      L$389
  4026 0000022C [5618]                          DW      L$390
  4027 0000022E [5C18]                          DW      L$391
  4028 00000230 [6218]                          DW      L$392
  4029 00000232 [6918]                          DW      L$393
  4030 00000234 [6E18]                          DW      L$394
  4031 00000236 [7418]                          DW      L$395
  4032 00000238 [7B18]                          DW      L$396
  4033 0000023A [8318]                          DW      L$397
  4034 0000023C [8818]                          DW      L$398
  4035 0000023E [8D18]                          DW      L$399
  4036 00000240 [9518]                          DW      L$400
  4037 00000242 [9B18]                          DW      L$401
  4038                                  _opcode1:
  4039 00000244 06022F3300000010                DB      6, 2, 2fH, 33H, 0, 0, 0, 10H
  4040 0000024C 0602303400000010                DB      6, 2, 30H, 34H, 0, 0, 0, 10H
  4041 00000254 0602332F00000010                DB      6, 2, 33H, 2fH, 0, 0, 0, 10H
  4042 0000025C 0602343000000010                DB      6, 2, 34H, 30H, 0, 0, 0, 10H
  4043 00000264 0602130300000000                DB      6, 2, 13H, 3, 0, 0, 0, 0
  4044 0000026C 0602210400000000                DB      6, 2, 21H, 4, 0, 0, 0, 0
  4045 00000274 71011D0000000000                DB      71H, 1, 1dH, 0, 0, 0, 0, 0
  4046 0000027C 6C011D0000000000                DB      6cH, 1, 1dH, 0, 0, 0, 0, 0
  4047 00000284 66022F3300000010                DB      66H, 2, 2fH, 33H, 0, 0, 0, 10H
  4048 0000028C 6602303400000010                DB      66H, 2, 30H, 34H, 0, 0, 0, 10H
  4049 00000294 6602332F00000010                DB      66H, 2, 33H, 2fH, 0, 0, 0, 10H
  4050 0000029C 6602343000000010                DB      66H, 2, 34H, 30H, 0, 0, 0, 10H
  4051 000002A4 6602130300000000                DB      66H, 2, 13H, 3, 0, 0, 0, 0
  4052 000002AC 6602210400000000                DB      66H, 2, 21H, 4, 0, 0, 0, 0
  4053 000002B4 71011B0000000000                DB      71H, 1, 1bH, 0, 0, 0, 0, 0
  4054 000002BC 0100000000000080                DB      1, 0, 0, 0, 0, 0, 0, 80H
  4055 000002C4 05022F3300000010                DB      5, 2, 2fH, 33H, 0, 0, 0, 10H
  4056 000002CC 0502303400000010                DB      5, 2, 30H, 34H, 0, 0, 0, 10H
  4057 000002D4 0502332F00000010                DB      5, 2, 33H, 2fH, 0, 0, 0, 10H
  4058 000002DC 0502343000000010                DB      5, 2, 34H, 30H, 0, 0, 0, 10H
  4059 000002E4 0502130300000000                DB      5, 2, 13H, 3, 0, 0, 0, 0
  4060 000002EC 0502210400000000                DB      5, 2, 21H, 4, 0, 0, 0, 0
  4061 000002F4 71011E0000000000                DB      71H, 1, 1eH, 0, 0, 0, 0, 0
  4062 000002FC 6C011E0000000000                DB      6cH, 1, 1eH, 0, 0, 0, 0, 0
  4063 00000304 85022F3300000010                DB      85H, 2, 2fH, 33H, 0, 0, 0, 10H
  4064 0000030C 8502303400000010                DB      85H, 2, 30H, 34H, 0, 0, 0, 10H
  4065 00000314 8502332F00000010                DB      85H, 2, 33H, 2fH, 0, 0, 0, 10H
  4066 0000031C 8502343000000010                DB      85H, 2, 34H, 30H, 0, 0, 0, 10H
  4067 00000324 8502130300000000                DB      85H, 2, 13H, 3, 0, 0, 0, 0
  4068 0000032C 8502210400000000                DB      85H, 2, 21H, 4, 0, 0, 0, 0
  4069 00000334 71011C0000000000                DB      71H, 1, 1cH, 0, 0, 0, 0, 0
  4070 0000033C 6C011C0000000000                DB      6cH, 1, 1cH, 0, 0, 0, 0, 0
  4071 00000344 07022F3300000010                DB      7, 2, 2fH, 33H, 0, 0, 0, 10H
  4072 0000034C 0702303400000010                DB      7, 2, 30H, 34H, 0, 0, 0, 10H
  4073 00000354 0702332F00000010                DB      7, 2, 33H, 2fH, 0, 0, 0, 10H
  4074 0000035C 0702343000000010                DB      7, 2, 34H, 30H, 0, 0, 0, 10H
  4075 00000364 0702130300000000                DB      7, 2, 13H, 3, 0, 0, 0, 0
  4076 0000036C 0702210400000000                DB      7, 2, 21H, 4, 0, 0, 0, 0
  4077 00000374 0200000000000080                DB      2, 0, 0, 0, 0, 0, 0, 80H
  4078 0000037C 1F00000000000000                DB      1fH, 0, 0, 0, 0, 0, 0, 0
  4079 00000384 99022F3300000010                DB      99H, 2, 2fH, 33H, 0, 0, 0, 10H
  4080 0000038C 9902303400000010                DB      99H, 2, 30H, 34H, 0, 0, 0, 10H
  4081 00000394 9902332F00000010                DB      99H, 2, 33H, 2fH, 0, 0, 0, 10H
  4082 0000039C 9902343000000010                DB      99H, 2, 34H, 30H, 0, 0, 0, 10H
  4083 000003A4 9902130300000000                DB      99H, 2, 13H, 3, 0, 0, 0, 0
  4084 000003AC 9902210400000000                DB      99H, 2, 21H, 4, 0, 0, 0, 0
  4085 000003B4 0300000000000080                DB      3, 0, 0, 0, 0, 0, 0, 80H
  4086 000003BC 2000000000000000                DB      20H, 0, 0, 0, 0, 0, 0, 0
  4087 000003C4 A1022F3300000010                DB      0a1H, 2, 2fH, 33H, 0, 0, 0, 10H
  4088 000003CC A102303400000010                DB      0a1H, 2, 30H, 34H, 0, 0, 0, 10H
  4089 000003D4 A102332F00000010                DB      0a1H, 2, 33H, 2fH, 0, 0, 0, 10H
  4090 000003DC A102343000000010                DB      0a1H, 2, 34H, 30H, 0, 0, 0, 10H
  4091 000003E4 A102130300000000                DB      0a1H, 2, 13H, 3, 0, 0, 0, 0
  4092 000003EC A102210400000000                DB      0a1H, 2, 21H, 4, 0, 0, 0, 0
  4093 000003F4 0400000000000080                DB      4, 0, 0, 0, 0, 0, 0, 80H
  4094 000003FC 0100000000000000                DB      1, 0, 0, 0, 0, 0, 0, 0
  4095 00000404 18022F3300000010                DB      18H, 2, 2fH, 33H, 0, 0, 0, 10H
  4096 0000040C 1802303400000010                DB      18H, 2, 30H, 34H, 0, 0, 0, 10H
  4097 00000414 1802332F00000010                DB      18H, 2, 33H, 2fH, 0, 0, 0, 10H
  4098 0000041C 1802343000000010                DB      18H, 2, 34H, 30H, 0, 0, 0, 10H
  4099 00000424 1802130300000000                DB      18H, 2, 13H, 3, 0, 0, 0, 0
  4100 0000042C 1802210400000000                DB      18H, 2, 21H, 4, 0, 0, 0, 0
  4101 00000434 0500000000000080                DB      5, 0, 0, 0, 0, 0, 0, 80H
  4102 0000043C 0400000000000000                DB      4, 0, 0, 0, 0, 0, 0, 0
  4103 00000444 2801210000000000                DB      28H, 1, 21H, 0, 0, 0, 0, 0
  4104 0000044C 2801220000000000                DB      28H, 1, 22H, 0, 0, 0, 0, 0
  4105 00000454 2801230000000000                DB      28H, 1, 23H, 0, 0, 0, 0, 0
  4106 0000045C 2801240000000000                DB      28H, 1, 24H, 0, 0, 0, 0, 0
  4107 00000464 2801250000000000                DB      28H, 1, 25H, 0, 0, 0, 0, 0
  4108 0000046C 2801260000000000                DB      28H, 1, 26H, 0, 0, 0, 0, 0
  4109 00000474 2801270000000000                DB      28H, 1, 27H, 0, 0, 0, 0, 0
  4110 0000047C 2801280000000000                DB      28H, 1, 28H, 0, 0, 0, 0, 0
  4111 00000484 2101210000000000                DB      21H, 1, 21H, 0, 0, 0, 0, 0
  4112 0000048C 2101220000000000                DB      21H, 1, 22H, 0, 0, 0, 0, 0
  4113 00000494 2101230000000000                DB      21H, 1, 23H, 0, 0, 0, 0, 0
  4114 0000049C 2101240000000000                DB      21H, 1, 24H, 0, 0, 0, 0, 0
  4115 000004A4 2101250000000000                DB      21H, 1, 25H, 0, 0, 0, 0, 0
  4116 000004AC 2101260000000000                DB      21H, 1, 26H, 0, 0, 0, 0, 0
  4117 000004B4 2101270000000000                DB      21H, 1, 27H, 0, 0, 0, 0, 0
  4118 000004BC 2101280000000000                DB      21H, 1, 28H, 0, 0, 0, 0, 0
  4119 000004C4 7101210000000000                DB      71H, 1, 21H, 0, 0, 0, 0, 0
  4120 000004CC 7101220000000000                DB      71H, 1, 22H, 0, 0, 0, 0, 0
  4121 000004D4 7101230000000000                DB      71H, 1, 23H, 0, 0, 0, 0, 0
  4122 000004DC 7101240000000000                DB      71H, 1, 24H, 0, 0, 0, 0, 0
  4123 000004E4 7101250000000000                DB      71H, 1, 25H, 0, 0, 0, 0, 0
  4124 000004EC 7101260000000000                DB      71H, 1, 26H, 0, 0, 0, 0, 0
  4125 000004F4 7101270000000000                DB      71H, 1, 27H, 0, 0, 0, 0, 0
  4126 000004FC 7101280000000000                DB      71H, 1, 28H, 0, 0, 0, 0, 0
  4127 00000504 6C01210000000000                DB      6cH, 1, 21H, 0, 0, 0, 0, 0
  4128 0000050C 6C01220000000000                DB      6cH, 1, 22H, 0, 0, 0, 0, 0
  4129 00000514 6C01230000000000                DB      6cH, 1, 23H, 0, 0, 0, 0, 0
  4130 0000051C 6C01240000000000                DB      6cH, 1, 24H, 0, 0, 0, 0, 0
  4131 00000524 6C01250000000000                DB      6cH, 1, 25H, 0, 0, 0, 0, 0
  4132 0000052C 6C01260000000000                DB      6cH, 1, 26H, 0, 0, 0, 0, 0
  4133 00000534 6C01270000000000                DB      6cH, 1, 27H, 0, 0, 0, 0, 0
  4134 0000053C 6C01280000000000                DB      6cH, 1, 28H, 0, 0, 0, 0, 0
  4135 00000544 7200000000000040                DB      72H, 0, 0, 0, 0, 0, 0, 40H
  4136 0000054C 6D00000000000040                DB      6dH, 0, 0, 0, 0, 0, 0, 40H
  4137 00000554 0902343600000010                DB      9, 2, 34H, 36H, 0, 0, 0, 10H
  4138 0000055C 0802313B00000010                DB      8, 2, 31H, 3bH, 0, 0, 0, 10H
  4139 00000564 0600000000000080                DB      6, 0, 0, 0, 0, 0, 0, 80H
  4140 0000056C 0700000000000080                DB      7, 0, 0, 0, 0, 0, 0, 80H
  4141 00000574 0800000000000080                DB      8, 0, 0, 0, 0, 0, 0, 80H
  4142 0000057C 0900000000000080                DB      9, 0, 0, 0, 0, 0, 0, 80H
  4143 00000584 7101040000000000                DB      71H, 1, 4, 0, 0, 0, 0, 0
  4144 0000058C 2602343004000010                DB      26H, 2, 34H, 30H, 4, 0, 0, 10H
  4145 00000594 7101030000000000                DB      71H, 1, 3, 0, 0, 0, 0, 0
  4146 0000059C 2603343003000010                DB      26H, 3, 34H, 30H, 3, 0, 0, 10H
  4147 000005A4 2A02061200000003                DB      2aH, 2, 6, 12H, 0, 0, 0, 3
  4148 000005AC 2B02071200000043                DB      2bH, 2, 7, 12H, 0, 0, 0, 43H
  4149 000005B4 6902120800000003                DB      69H, 2, 12H, 8, 0, 0, 0, 3
  4150 000005BC 6A02120900000043                DB      6aH, 2, 12H, 9, 0, 0, 0, 43H
  4151 000005C4 31010A0000000002                DB      31H, 1, 0aH, 0, 0, 0, 0, 2
  4152 000005CC 32010A0000000002                DB      32H, 1, 0aH, 0, 0, 0, 0, 2
  4153 000005D4 33010A0000000002                DB      33H, 1, 0aH, 0, 0, 0, 0, 2
  4154 000005DC 34010A0000000002                DB      34H, 1, 0aH, 0, 0, 0, 0, 2
  4155 000005E4 35010A0000000002                DB      35H, 1, 0aH, 0, 0, 0, 0, 2
  4156 000005EC 36010A0000000002                DB      36H, 1, 0aH, 0, 0, 0, 0, 2
  4157 000005F4 37010A0000000002                DB      37H, 1, 0aH, 0, 0, 0, 0, 2
  4158 000005FC 38010A0000000002                DB      38H, 1, 0aH, 0, 0, 0, 0, 2
  4159 00000604 39010A0000000002                DB      39H, 1, 0aH, 0, 0, 0, 0, 2
  4160 0000060C 3A010A0000000002                DB      3aH, 1, 0aH, 0, 0, 0, 0, 2
  4161 00000614 3B010A0000000002                DB      3bH, 1, 0aH, 0, 0, 0, 0, 2
  4162 0000061C 3C010A0000000002                DB      3cH, 1, 0aH, 0, 0, 0, 0, 2
  4163 00000624 3D010A0000000002                DB      3dH, 1, 0aH, 0, 0, 0, 0, 2
  4164 0000062C 3E010A0000000002                DB      3eH, 1, 0aH, 0, 0, 0, 0, 2
  4165 00000634 3F010A0000000002                DB      3fH, 1, 0aH, 0, 0, 0, 0, 2
  4166 0000063C 40010A0000000002                DB      40H, 1, 0aH, 0, 0, 0, 0, 2
  4167 00000644 14022F0300000090                DB      14H, 2, 2fH, 3, 0, 0, 0, 90H
  4168 0000064C 1502300400000090                DB      15H, 2, 30H, 4, 0, 0, 0, 90H
  4169 00000654 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4170 0000065C 1602300300000090                DB      16H, 2, 30H, 3, 0, 0, 0, 90H
  4171 00000664 9A022F3300000010                DB      9aH, 2, 2fH, 33H, 0, 0, 0, 10H
  4172 0000066C 9A02303400000010                DB      9aH, 2, 30H, 34H, 0, 0, 0, 10H
  4173 00000674 9E022F3300000010                DB      9eH, 2, 2fH, 33H, 0, 0, 0, 10H
  4174 0000067C 9E02303400002310                DB      9eH, 2, 30H, 34H, 0, 0, 23H, 10H
  4175 00000684 5B022F3300004110                DB      5bH, 2, 2fH, 33H, 0, 0, 41H, 10H
  4176 0000068C 5B02303400004210                DB      5bH, 2, 30H, 34H, 0, 0, 42H, 10H
  4177 00000694 5B02332F00008110                DB      5bH, 2, 33H, 2fH, 0, 0, 81H, 10H
  4178 0000069C 5B02343000000010                DB      5bH, 2, 34H, 30H, 0, 0, 0, 10H
  4179 000006A4 5B02313C00000010                DB      5bH, 2, 31H, 3cH, 0, 0, 0, 10H
  4180 000006AC 4402343500000010                DB      44H, 2, 34H, 35H, 0, 0, 0, 10H
  4181 000006B4 5B023C3100000014                DB      5bH, 2, 3cH, 31H, 0, 0, 0, 14H
  4182 000006BC 6C01300000000010                DB      6cH, 1, 30H, 0, 0, 0, 0, 10H
  4183 000006C4 6400000000000000                DB      64H, 0, 0, 0, 0, 0, 0, 0
  4184 000006CC 9E02222100000000                DB      9eH, 2, 22H, 21H, 0, 0, 0, 0
  4185 000006D4 9E02232100000000                DB      9eH, 2, 23H, 21H, 0, 0, 0, 0
  4186 000006DC 9E02242100000000                DB      9eH, 2, 24H, 21H, 0, 0, 0, 0
  4187 000006E4 9E02252100000000                DB      9eH, 2, 25H, 21H, 0, 0, 0, 0
  4188 000006EC 9E02262100000000                DB      9eH, 2, 26H, 21H, 0, 0, 0, 0
  4189 000006F4 9E02272100000000                DB      9eH, 2, 27H, 21H, 0, 0, 0, 0
  4190 000006FC 9E02282100000000                DB      9eH, 2, 28H, 21H, 0, 0, 0, 0
  4191 00000704 1100000000000040                DB      11H, 0, 0, 0, 0, 0, 0, 40H
  4192 0000070C 1D00000000000040                DB      1dH, 0, 0, 0, 0, 0, 0, 40H
  4193 00000714 10010C0000000005                DB      10H, 1, 0cH, 0, 0, 0, 0, 5
  4194 0000071C 9D00000000000000                DB      9dH, 0, 0, 0, 0, 0, 0, 0
  4195 00000724 7400000000000043                DB      74H, 0, 0, 0, 0, 0, 0, 43H
  4196 0000072C 6F00000000000043                DB      6fH, 0, 0, 0, 0, 0, 0, 43H
  4197 00000734 8000000000000000                DB      80H, 0, 0, 0, 0, 0, 0, 0
  4198 0000073C 4200000000000000                DB      42H, 0, 0, 0, 0, 0, 0, 0
  4199 00000744 5B02130100000000                DB      5bH, 2, 13H, 1, 0, 0, 0, 0
  4200 0000074C 5B02210100008300                DB      5bH, 2, 21H, 1, 0, 0, 83H, 0
  4201 00000754 5B02011300000000                DB      5bH, 2, 1, 13H, 0, 0, 0, 0
  4202 0000075C 5B02012100004300                DB      5bH, 2, 1, 21H, 0, 0, 43H, 0
  4203 00000764 5D02060800000000                DB      5dH, 2, 6, 8, 0, 0, 0, 0
  4204 0000076C 5E02070900000040                DB      5eH, 2, 7, 9, 0, 0, 0, 40H
  4205 00000774 1A02080600000000                DB      1aH, 2, 8, 6, 0, 0, 0, 0
  4206 0000077C 1B02090700000040                DB      1bH, 2, 9, 7, 0, 0, 0, 40H
  4207 00000784 9A02130300000000                DB      9aH, 2, 13H, 3, 0, 0, 0, 0
  4208 0000078C 9A02210400000000                DB      9aH, 2, 21H, 4, 0, 0, 0, 0
  4209 00000794 9502061300000000                DB      95H, 2, 6, 13H, 0, 0, 0, 0
  4210 0000079C 9602062100000040                DB      96H, 2, 6, 21H, 0, 0, 0, 40H
  4211 000007A4 5102130800008100                DB      51H, 2, 13H, 8, 0, 0, 81H, 0
  4212 000007AC 5202210900008340                DB      52H, 2, 21H, 9, 0, 0, 83H, 40H
  4213 000007B4 8702130800000000                DB      87H, 2, 13H, 8, 0, 0, 0, 0
  4214 000007BC 8802210900000040                DB      88H, 2, 21H, 9, 0, 0, 0, 40H
  4215 000007C4 5B02130300000000                DB      5bH, 2, 13H, 3, 0, 0, 0, 0
  4216 000007CC 5B02170300000000                DB      5bH, 2, 17H, 3, 0, 0, 0, 0
  4217 000007D4 5B02190300000000                DB      5bH, 2, 19H, 3, 0, 0, 0, 0
  4218 000007DC 5B02150300000000                DB      5bH, 2, 15H, 3, 0, 0, 0, 0
  4219 000007E4 5B02140300000000                DB      5bH, 2, 14H, 3, 0, 0, 0, 0
  4220 000007EC 5B02180300000000                DB      5bH, 2, 18H, 3, 0, 0, 0, 0
  4221 000007F4 5B021A0300000000                DB      5bH, 2, 1aH, 3, 0, 0, 0, 0
  4222 000007FC 5B02160300000000                DB      5bH, 2, 16H, 3, 0, 0, 0, 0
  4223 00000804 5B02210400000000                DB      5bH, 2, 21H, 4, 0, 0, 0, 0
  4224 0000080C 5B02220400000000                DB      5bH, 2, 22H, 4, 0, 0, 0, 0
  4225 00000814 5B02230400000000                DB      5bH, 2, 23H, 4, 0, 0, 0, 0
  4226 0000081C 5B02240400000000                DB      5bH, 2, 24H, 4, 0, 0, 0, 0
  4227 00000824 5B02250400000000                DB      5bH, 2, 25H, 4, 0, 0, 0, 0
  4228 0000082C 5B02260400000000                DB      5bH, 2, 26H, 4, 0, 0, 0, 0
  4229 00000834 5B02270400000000                DB      5bH, 2, 27H, 4, 0, 0, 0, 0
  4230 0000083C 5B02280400000000                DB      5bH, 2, 28H, 4, 0, 0, 0, 0
  4231 00000844 17022F0300000090                DB      17H, 2, 2fH, 3, 0, 0, 0, 90H
  4232 0000084C 1802300300000090                DB      18H, 2, 30H, 3, 0, 0, 0, 90H
  4233 00000854 7F01050000000005                DB      7fH, 1, 5, 0, 0, 0, 0, 5
  4234 0000085C 7F00000000000005                DB      7fH, 0, 0, 0, 0, 0, 0, 5
  4235 00000864 4B02343700000014                DB      4bH, 2, 34H, 37H, 0, 0, 0, 14H
  4236 0000086C 4A02343700000014                DB      4aH, 2, 34H, 37H, 0, 0, 0, 14H
  4237 00000874 5B022F0300000010                DB      5bH, 2, 2fH, 3, 0, 0, 0, 10H
  4238 0000087C 5B02300400000010                DB      5bH, 2, 30H, 4, 0, 0, 0, 10H
  4239 00000884 2302050300000000                DB      23H, 2, 5, 3, 0, 0, 0, 0
  4240 0000088C 4500000000000000                DB      45H, 0, 0, 0, 0, 0, 0, 0
  4241 00000894 C101050000000005                DB      0c1H, 1, 5, 0, 0, 0, 0, 5
  4242 0000089C C100000000000005                DB      0c1H, 0, 0, 0, 0, 0, 0, 5
  4243 000008A4 2D01110000000000                DB      2dH, 1, 11H, 0, 0, 0, 0, 0
  4244 000008AC 2D01030000000003                DB      2dH, 1, 3, 0, 0, 0, 0, 3
  4245 000008B4 2E00000000000003                DB      2eH, 0, 0, 0, 0, 0, 0, 3
  4246 000008BC 2F00000000000003                DB      2fH, 0, 0, 0, 0, 0, 0, 3
  4247 000008C4 19022F1000000090                DB      19H, 2, 2fH, 10H, 0, 0, 0, 90H
  4248 000008CC 1A02301000000090                DB      1aH, 2, 30H, 10H, 0, 0, 0, 90H
  4249 000008D4 1B022F1700000090                DB      1bH, 2, 2fH, 17H, 0, 0, 0, 90H
  4250 000008DC 1C02301700000090                DB      1cH, 2, 30H, 17H, 0, 0, 0, 90H
  4251 000008E4 0301030000000000                DB      3, 1, 3, 0, 0, 0, 0, 0
  4252 000008EC 0201030000000000                DB      2, 1, 3, 0, 0, 0, 0, 0
  4253 000008F4 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4254 000008FC 9F00000000000000                DB      9fH, 0, 0, 0, 0, 0, 0, 0
  4255 00000904 0C00000000000080                DB      0cH, 0, 0, 0, 0, 0, 0, 80H
  4256 0000090C 0D00000000000080                DB      0dH, 0, 0, 0, 0, 0, 0, 80H
  4257 00000914 0E00000000000080                DB      0eH, 0, 0, 0, 0, 0, 0, 80H
  4258 0000091C 0F00000000000080                DB      0fH, 0, 0, 0, 0, 0, 0, 80H
  4259 00000924 1000000000000080                DB      10H, 0, 0, 0, 0, 0, 0, 80H
  4260 0000092C 1100000000000080                DB      11H, 0, 0, 0, 0, 0, 0, 80H
  4261 00000934 1200000000000080                DB      12H, 0, 0, 0, 0, 0, 0, 80H
  4262 0000093C 1300000000000080                DB      13H, 0, 0, 0, 0, 0, 0, 80H
  4263 00000944 57010A0000000002                DB      57H, 1, 0aH, 0, 0, 0, 0, 2
  4264 0000094C 55010A0000000002                DB      55H, 1, 0aH, 0, 0, 0, 0, 2
  4265 00000954 54010A0000000002                DB      54H, 1, 0aH, 0, 0, 0, 0, 2
  4266 0000095C A2010A0000000002                DB      0a2H, 1, 0aH, 0, 0, 0, 0, 2
  4267 00000964 2702130300000003                DB      27H, 2, 13H, 3, 0, 0, 0, 3
  4268 0000096C 2702210300000003                DB      27H, 2, 21H, 3, 0, 0, 0, 3
  4269 00000974 6702031300000003                DB      67H, 2, 3, 13H, 0, 0, 0, 3
  4270 0000097C 6702032100000003                DB      67H, 2, 3, 21H, 0, 0, 0, 3
  4271 00000984 10010B0000000002                DB      10H, 1, 0bH, 0, 0, 0, 0, 2
  4272 0000098C 41010B0000000001                DB      41H, 1, 0bH, 0, 0, 0, 0, 1
  4273 00000994 C0010C0000000003                DB      0c0H, 1, 0cH, 0, 0, 0, 0, 3
  4274 0000099C 41010A0000000001                DB      41H, 1, 0aH, 0, 0, 0, 0, 1
  4275 000009A4 2702131200000003                DB      27H, 2, 13H, 12H, 0, 0, 0, 3
  4276 000009AC 2702211200000003                DB      27H, 2, 21H, 12H, 0, 0, 0, 3
  4277 000009B4 6702121300000003                DB      67H, 2, 12H, 13H, 0, 0, 0, 3
  4278 000009BC 6702122100000003                DB      67H, 2, 12H, 21H, 0, 0, 0, 3
  4279 000009C4 4F00000000000000                DB      4fH, 0, 0, 0, 0, 0, 0, 0
  4280 000009CC 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4281 000009D4 0A00000000000080                DB      0aH, 0, 0, 0, 0, 0, 0, 80H
  4282 000009DC 0B00000000000080                DB      0bH, 0, 0, 0, 0, 0, 0, 80H
  4283 000009E4 2400000000000003                DB      24H, 0, 0, 0, 0, 0, 0, 3
  4284 000009EC 1700000000000000                DB      17H, 0, 0, 0, 0, 0, 0, 0
  4285 000009F4 1D012F0000000090                DB      1dH, 1, 2fH, 0, 0, 0, 0, 90H
  4286 000009FC 1E01300000000090                DB      1eH, 1, 30H, 0, 0, 0, 0, 90H
  4287 00000A04 1300000000000000                DB      13H, 0, 0, 0, 0, 0, 0, 0
  4288 00000A0C 9100000000000000                DB      91H, 0, 0, 0, 0, 0, 0, 0
  4289 00000A14 1500000000000003                DB      15H, 0, 0, 0, 0, 0, 0, 3
  4290 00000A1C 9300000000000003                DB      93H, 0, 0, 0, 0, 0, 0, 3
  4291 00000A24 1400000000000000                DB      14H, 0, 0, 0, 0, 0, 0, 0
  4292 00000A2C 9200000000000000                DB      92H, 0, 0, 0, 0, 0, 0, 0
  4293 00000A34 1F00000000000090                DB      1fH, 0, 0, 0, 0, 0, 0, 90H
  4294 00000A3C 2000000000000090                DB      20H, 0, 0, 0, 0, 0, 0, 90H
  4295                                  _opcodeg:
  4296 00000A44 06022F0300000000                DB      6, 2, 2fH, 3, 0, 0, 0, 0
  4297 00000A4C 66022F0300000000                DB      66H, 2, 2fH, 3, 0, 0, 0, 0
  4298 00000A54 05022F0300000000                DB      5, 2, 2fH, 3, 0, 0, 0, 0
  4299 00000A5C 85022F0300000000                DB      85H, 2, 2fH, 3, 0, 0, 0, 0
  4300 00000A64 07022F0300000000                DB      7, 2, 2fH, 3, 0, 0, 0, 0
  4301 00000A6C 99022F0300000000                DB      99H, 2, 2fH, 3, 0, 0, 0, 0
  4302 00000A74 A1022F0300000000                DB      0a1H, 2, 2fH, 3, 0, 0, 0, 0
  4303 00000A7C 18022F0300000000                DB      18H, 2, 2fH, 3, 0, 0, 0, 0
  4304 00000A84 0602300400000000                DB      6, 2, 30H, 4, 0, 0, 0, 0
  4305 00000A8C 6602300400000000                DB      66H, 2, 30H, 4, 0, 0, 0, 0
  4306 00000A94 0502300400000000                DB      5, 2, 30H, 4, 0, 0, 0, 0
  4307 00000A9C 8502300400000000                DB      85H, 2, 30H, 4, 0, 0, 0, 0
  4308 00000AA4 0702300400000000                DB      7, 2, 30H, 4, 0, 0, 0, 0
  4309 00000AAC 9902300400000000                DB      99H, 2, 30H, 4, 0, 0, 0, 0
  4310 00000AB4 A102300400000000                DB      0a1H, 2, 30H, 4, 0, 0, 0, 0
  4311 00000ABC 1802300400000000                DB      18H, 2, 30H, 4, 0, 0, 0, 0
  4312 00000AC4 0602300300000000                DB      6, 2, 30H, 3, 0, 0, 0, 0
  4313 00000ACC 6602300300000000                DB      66H, 2, 30H, 3, 0, 0, 0, 0
  4314 00000AD4 0502300300000000                DB      5, 2, 30H, 3, 0, 0, 0, 0
  4315 00000ADC 8502300300000000                DB      85H, 2, 30H, 3, 0, 0, 0, 0
  4316 00000AE4 0702300300000000                DB      7, 2, 30H, 3, 0, 0, 0, 0
  4317 00000AEC 9902300300000000                DB      99H, 2, 30H, 3, 0, 0, 0, 0
  4318 00000AF4 A102300300000000                DB      0a1H, 2, 30H, 3, 0, 0, 0, 0
  4319 00000AFC 1802300300000000                DB      18H, 2, 30H, 3, 0, 0, 0, 0
  4320 00000B04 78022F0300000000                DB      78H, 2, 2fH, 3, 0, 0, 0, 0
  4321 00000B0C 79022F0300000000                DB      79H, 2, 2fH, 3, 0, 0, 0, 0
  4322 00000B14 76022F0300000000                DB      76H, 2, 2fH, 3, 0, 0, 0, 0
  4323 00000B1C 77022F0300000000                DB      77H, 2, 2fH, 3, 0, 0, 0, 0
  4324 00000B24 81022F0300000000                DB      81H, 2, 2fH, 3, 0, 0, 0, 0
  4325 00000B2C 84022F0300000000                DB      84H, 2, 2fH, 3, 0, 0, 0, 0
  4326 00000B34 83022F0300000000                DB      83H, 2, 2fH, 3, 0, 0, 0, 0
  4327 00000B3C 82022F0300000000                DB      82H, 2, 2fH, 3, 0, 0, 0, 0
  4328 00000B44 7802300300000000                DB      78H, 2, 30H, 3, 0, 0, 0, 0
  4329 00000B4C 7902300300000000                DB      79H, 2, 30H, 3, 0, 0, 0, 0
  4330 00000B54 7602300300000000                DB      76H, 2, 30H, 3, 0, 0, 0, 0
  4331 00000B5C 7702300300000000                DB      77H, 2, 30H, 3, 0, 0, 0, 0
  4332 00000B64 8102300300000000                DB      81H, 2, 30H, 3, 0, 0, 0, 0
  4333 00000B6C 8402300300000000                DB      84H, 2, 30H, 3, 0, 0, 0, 0
  4334 00000B74 8302300300000000                DB      83H, 2, 30H, 3, 0, 0, 0, 0
  4335 00000B7C 8202300300000000                DB      82H, 2, 30H, 3, 0, 0, 0, 0
  4336 00000B84 78022F1000000000                DB      78H, 2, 2fH, 10H, 0, 0, 0, 0
  4337 00000B8C 79022F1000000000                DB      79H, 2, 2fH, 10H, 0, 0, 0, 0
  4338 00000B94 76022F1000000000                DB      76H, 2, 2fH, 10H, 0, 0, 0, 0
  4339 00000B9C 77022F1000000000                DB      77H, 2, 2fH, 10H, 0, 0, 0, 0
  4340 00000BA4 81022F1000000000                DB      81H, 2, 2fH, 10H, 0, 0, 0, 0
  4341 00000BAC 84022F1000000000                DB      84H, 2, 2fH, 10H, 0, 0, 0, 0
  4342 00000BB4 83022F1000000000                DB      83H, 2, 2fH, 10H, 0, 0, 0, 0
  4343 00000BBC 82022F1000000000                DB      82H, 2, 2fH, 10H, 0, 0, 0, 0
  4344 00000BC4 7802301000000000                DB      78H, 2, 30H, 10H, 0, 0, 0, 0
  4345 00000BCC 7902301000000000                DB      79H, 2, 30H, 10H, 0, 0, 0, 0
  4346 00000BD4 7602301000000000                DB      76H, 2, 30H, 10H, 0, 0, 0, 0
  4347 00000BDC 7702301000000000                DB      77H, 2, 30H, 10H, 0, 0, 0, 0
  4348 00000BE4 8102301000000000                DB      81H, 2, 30H, 10H, 0, 0, 0, 0
  4349 00000BEC 8402301000000000                DB      84H, 2, 30H, 10H, 0, 0, 0, 0
  4350 00000BF4 8302301000000000                DB      83H, 2, 30H, 10H, 0, 0, 0, 0
  4351 00000BFC 8202301000000000                DB      82H, 2, 30H, 10H, 0, 0, 0, 0
  4352 00000C04 78022F1700000000                DB      78H, 2, 2fH, 17H, 0, 0, 0, 0
  4353 00000C0C 79022F1700000000                DB      79H, 2, 2fH, 17H, 0, 0, 0, 0
  4354 00000C14 76022F1700000000                DB      76H, 2, 2fH, 17H, 0, 0, 0, 0
  4355 00000C1C 77022F1700000000                DB      77H, 2, 2fH, 17H, 0, 0, 0, 0
  4356 00000C24 81022F1700000000                DB      81H, 2, 2fH, 17H, 0, 0, 0, 0
  4357 00000C2C 84022F1700000000                DB      84H, 2, 2fH, 17H, 0, 0, 0, 0
  4358 00000C34 83022F1700000000                DB      83H, 2, 2fH, 17H, 0, 0, 0, 0
  4359 00000C3C 82022F1700000000                DB      82H, 2, 2fH, 17H, 0, 0, 0, 0
  4360 00000C44 7802301700000000                DB      78H, 2, 30H, 17H, 0, 0, 0, 0
  4361 00000C4C 7902301700000000                DB      79H, 2, 30H, 17H, 0, 0, 0, 0
  4362 00000C54 7602301700000000                DB      76H, 2, 30H, 17H, 0, 0, 0, 0
  4363 00000C5C 7702301700000000                DB      77H, 2, 30H, 17H, 0, 0, 0, 0
  4364 00000C64 8102301700000000                DB      81H, 2, 30H, 17H, 0, 0, 0, 0
  4365 00000C6C 8402301700000000                DB      84H, 2, 30H, 17H, 0, 0, 0, 0
  4366 00000C74 8302301700000000                DB      83H, 2, 30H, 17H, 0, 0, 0, 0
  4367 00000C7C 8202301700000000                DB      82H, 2, 30H, 17H, 0, 0, 0, 0
  4368 00000C84 9A022F0300000000                DB      9aH, 2, 2fH, 3, 0, 0, 0, 0
  4369 00000C8C 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4370 00000C94 65012F0000000000                DB      65H, 1, 2fH, 0, 0, 0, 0, 0
  4371 00000C9C 63012F0000000000                DB      63H, 1, 2fH, 0, 0, 0, 0, 0
  4372 00000CA4 62012F0000000000                DB      62H, 1, 2fH, 0, 0, 0, 0, 0
  4373 00000CAC 26012F0000000000                DB      26H, 1, 2fH, 0, 0, 0, 0, 0
  4374 00000CB4 22012F0000000000                DB      22H, 1, 2fH, 0, 0, 0, 0, 0
  4375 00000CBC 25012F0000000000                DB      25H, 1, 2fH, 0, 0, 0, 0, 0
  4376 00000CC4 9A02300400000000                DB      9aH, 2, 30H, 4, 0, 0, 0, 0
  4377 00000CCC 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4378 00000CD4 6501300000000000                DB      65H, 1, 30H, 0, 0, 0, 0, 0
  4379 00000CDC 6301300000000000                DB      63H, 1, 30H, 0, 0, 0, 0, 0
  4380 00000CE4 6201300000000000                DB      62H, 1, 30H, 0, 0, 0, 0, 0
  4381 00000CEC 2601300000000000                DB      26H, 1, 30H, 0, 0, 0, 0, 0
  4382 00000CF4 2201300000000000                DB      22H, 1, 30H, 0, 0, 0, 0, 0
  4383 00000CFC 2501300000000000                DB      25H, 1, 30H, 0, 0, 0, 0, 0
  4384 00000D04 28012F0000000000                DB      28H, 1, 2fH, 0, 0, 0, 0, 0
  4385 00000D0C 21012F0000000000                DB      21H, 1, 2fH, 0, 0, 0, 0, 0
  4386 00000D14 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4387 00000D1C 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4388 00000D24 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4389 00000D2C 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4390 00000D34 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4391 00000D3C 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4392 00000D44 2801300000000000                DB      28H, 1, 30H, 0, 0, 0, 0, 0
  4393 00000D4C 2101300000000000                DB      21H, 1, 30H, 0, 0, 0, 0, 0
  4394 00000D54 1001300000000005                DB      10H, 1, 30H, 0, 0, 0, 0, 5
  4395 00000D5C 1001320000000005                DB      10H, 1, 32H, 0, 0, 0, 0, 5
  4396 00000D64 4101300000000005                DB      41H, 1, 30H, 0, 0, 0, 0, 5
  4397 00000D6C 4101320000000005                DB      41H, 1, 32H, 0, 0, 0, 0, 5
  4398 00000D74 7101300000000000                DB      71H, 1, 30H, 0, 0, 0, 0, 0
  4399 00000D7C 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4400 00000D84 8F01310000000003                DB      8fH, 1, 31H, 0, 0, 0, 0, 3
  4401 00000D8C 9801310000000003                DB      98H, 1, 31H, 0, 0, 0, 0, 3
  4402 00000D94 4D01310000000003                DB      4dH, 1, 31H, 0, 0, 0, 0, 3
  4403 00000D9C 5A01310000000003                DB      5aH, 1, 31H, 0, 0, 0, 0, 3
  4404 00000DA4 9B01310000000000                DB      9bH, 1, 31H, 0, 0, 0, 0, 0
  4405 00000DAC 9C01310000000000                DB      9cH, 1, 31H, 0, 0, 0, 0, 0
  4406 00000DB4 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4407 00000DBC 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4408 00000DC4 8B01380000000003                DB      8bH, 1, 38H, 0, 0, 0, 0, 3
  4409 00000DCC 8C01380000000003                DB      8cH, 1, 38H, 0, 0, 0, 0, 3
  4410 00000DD4 4601380000000003                DB      46H, 1, 38H, 0, 0, 0, 0, 3
  4411 00000DDC 4701380000000003                DB      47H, 1, 38H, 0, 0, 0, 0, 3
  4412 00000DE4 9001310000000003                DB      90H, 1, 31H, 0, 0, 0, 0, 3
  4413 00000DEC 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4414 00000DF4 4E01310000000003                DB      4eH, 1, 31H, 0, 0, 0, 0, 3
  4415 00000DFC BE01350000000003                DB      0beH, 1, 35H, 0, 0, 0, 0, 3
  4416 00000E04 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4417 00000E0C 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4418 00000E14 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4419 00000E1C 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4420 00000E24 0C02300300000000                DB      0cH, 2, 30H, 3, 0, 0, 0, 0
  4421 00000E2C 0F02300300000000                DB      0fH, 2, 30H, 3, 0, 0, 0, 0
  4422 00000E34 0E02300300000000                DB      0eH, 2, 30H, 3, 0, 0, 0, 0
  4423 00000E3C 0D02300300000000                DB      0dH, 2, 30H, 3, 0, 0, 0, 0
  4424 00000E44 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4425 00000E4C BF01390000000000                DB      0bfH, 1, 39H, 0, 0, 0, 0, 0
  4426 00000E54 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4427 00000E5C 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4428 00000E64 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4429 00000E6C 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4430 00000E74 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4431 00000E7C 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4432 00000E84 D401350000000000                DB      0d4H, 1, 35H, 0, 0, 0, 0, 0
  4433 00000E8C D501350000000000                DB      0d5H, 1, 35H, 0, 0, 0, 0, 0
  4434 00000E94 D601350000000000                DB      0d6H, 1, 35H, 0, 0, 0, 0, 0
  4435 00000E9C D701350000000000                DB      0d7H, 1, 35H, 0, 0, 0, 0, 0
  4436 00000EA4 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4437 00000EAC 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4438 00000EB4 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4439 00000EBC 0000000000000080                DB      0, 0, 0, 0, 0, 0, 0, 80H
  4440                                  _seg_regs:
  4441 00000EC4 [A318]                          DW      L$402
  4442 00000EC6 [A618]                          DW      L$403
  4443 00000EC8 [A918]                          DW      L$404
  4444 00000ECA [AC18]                          DW      L$405
  4445 00000ECC [AF18]                          DW      L$406
  4446 00000ECE [B218]                          DW      L$407
  4447 00000ED0 [B518]                          DW      L$408
  4448 00000ED2 [B518]                          DW      L$408
  4449                                  _ea_scale:
  4450 00000ED4 [8C12]                          DW      L$113
  4451 00000ED6 [B718]                          DW      L$409
  4452 00000ED8 [BA18]                          DW      L$410
  4453 00000EDA [BD18]                          DW      L$411
  4454                                  _ea_modes:
  4455 00000EDC [C018]                          DW      L$412
  4456 00000EDE [C618]                          DW      L$413
  4457 00000EE0 [CC18]                          DW      L$414
  4458 00000EE2 [D218]                          DW      L$415
  4459 00000EE4 [D818]                          DW      L$416
  4460 00000EE6 [DB18]                          DW      L$417
  4461 00000EE8 [DE18]                          DW      L$418
  4462 00000EEA [E118]                          DW      L$419
  4463                                  _ea_regs:
  4464 00000EEC [E418]                          DW      L$420
  4465 00000EEE [E718]                          DW      L$421
  4466 00000EF0 [EA18]                          DW      L$422
  4467 00000EF2 [ED18]                          DW      L$423
  4468 00000EF4 [F018]                          DW      L$424
  4469 00000EF6 [F318]                          DW      L$425
  4470 00000EF8 [F618]                          DW      L$426
  4471 00000EFA [F918]                          DW      L$427
  4472 00000EFC [FC18]                          DW      L$428
  4473 00000EFE [FF18]                          DW      L$429
  4474 00000F00 [0219]                          DW      L$430
  4475 00000F02 [E118]                          DW      L$419
  4476 00000F04 [0519]                          DW      L$431
  4477 00000F06 [DE18]                          DW      L$418
  4478 00000F08 [D818]                          DW      L$416
  4479 00000F0A [DB18]                          DW      L$417
  4480                                  _direct_regs:
  4481 00000F0C [0219]                          DW      L$430
  4482 00000F0E [E418]                          DW      L$420
  4483 00000F10 [F018]                          DW      L$424
  4484 00000F12 [ED18]                          DW      L$423
  4485 00000F14 [F918]                          DW      L$427
  4486 00000F16 [E718]                          DW      L$421
  4487 00000F18 [F318]                          DW      L$425
  4488 00000F1A [EA18]                          DW      L$422
  4489 00000F1C [F618]                          DW      L$426
  4490 00000F1E [A618]                          DW      L$403
  4491 00000F20 [AC18]                          DW      L$405
  4492 00000F22 [A318]                          DW      L$402
  4493 00000F24 [A918]                          DW      L$404
  4494 00000F26 [AF18]                          DW      L$406
  4495 00000F28 [B218]                          DW      L$407
  4496                                  _cntrl_regs:
  4497 00000F2A [0819]                          DW      L$432
  4498 00000F2C [0C19]                          DW      L$433
  4499 00000F2E [1019]                          DW      L$434
  4500 00000F30 [1419]                          DW      L$435
  4501 00000F32 [1819]                          DW      L$436
  4502 00000F34 [B518]                          DW      L$408
  4503 00000F36 [B518]                          DW      L$408
  4504 00000F38 [B518]                          DW      L$408
  4505                                  _debug_regs:
  4506 00000F3A [1C19]                          DW      L$437
  4507 00000F3C [2019]                          DW      L$438
  4508 00000F3E [2419]                          DW      L$439
  4509 00000F40 [2819]                          DW      L$440
  4510 00000F42 [2C19]                          DW      L$441
  4511 00000F44 [3019]                          DW      L$442
  4512 00000F46 [3419]                          DW      L$443
  4513 00000F48 [3819]                          DW      L$444
  4514                                  _esdi_regs:
  4515 00000F4A [3C19]                          DW      L$445
  4516 00000F4C [4119]                          DW      L$446
  4517                                  _dssi_regs:
  4518 00000F4E [4719]                          DW      L$447
  4519 00000F50 [4C19]                          DW      L$448
  4520                                  _inpfp:
  4521 00000F52 0000                            DB      0, 0
  4522
  4523                                  ;----------------------------------------------------------------------
  4524                                  ; Text Strings
  4525                                  ;----------------------------------------------------------------------
  4526                                  WELCOME_MESS:
  4527 00000F54 0D0A0A4D4F4E383820-             DB      CR,LF,LF,"MON88 8088/8086 Monitor ver 0.1"
  4527 00000F5D 383038382F38303836-
  4527 00000F66 204D6F6E69746F7220-
  4527 00000F6F 76657220302E31
  4528 00000F76 0D0A436F7079726967-             DB      CR,LF,"Copyright WWW.HT-LAB.COM 2005",
  4528 00000F7F 6874205757572E4854-
  4528 00000F88 2D4C41422E434F4D20-
  4528 00000F91 32303035
  4529 00000F95 0D0A416C6C20726967-             DB      CR,LF,"All rights reserved.",CR,LF,0
  4529 00000F9E 687473207265736572-
  4529 00000FA7 7665642E0D0A00
  4530                                  PROMPT_MESS:
  4531 00000FAE 0D0A436D643E00                  DB      CR,LF,"Cmd>",0
  4532                                  ERRCMD_MESS:
  4533 00000FB5 203C2D20556E6B6E6F-             DB      " <- Unknown Command, type H to Display Help",0
  4533 00000FBE 776E20436F6D6D616E-
  4533 00000FC7 642C20747970652048-
  4533 00000FD0 20746F20446973706C-
  4533 00000FD9 61792048656C7000
  4534                                  ERRREG_MESS:
  4535 00000FE1 203C2D20556E6B6E6F-             DB      " <- Unknown Register, valid names: AX,BX,CX,DX,SP,BP,SI,DI,DS,ES,SS,CS,IP,FL",0
  4535 00000FEA 776E20526567697374-
  4535 00000FF3 65722C2076616C6964-
  4535 00000FFC 206E616D65733A2041-
  4535 00001005 582C42582C43582C44-
  4535 0000100E 582C53502C42502C53-
  4535 00001017 492C44492C44532C45-
  4535 00001020 532C53532C43532C49-
  4535 00001029 502C464C00
  4536
  4537                                  LOAD_MESS:
  4538 0000102E 0D0A53746172742075-             DB      CR,LF,"Start upload now, load is terminated by :00000001FF",CR,LF,0
  4538 00001037 706C6F6164206E6F77-
  4538 00001040 2C206C6F6164206973-
  4538 00001049 207465726D696E6174-
  4538 00001052 6564206279203A3030-
  4538 0000105B 30303030303146460D-
  4538 00001064 0A00
  4539                                  LD_CHKS_MESS:
  4540 00001066 0D0A4572726F723A20-             DB      CR,LF,"Error: CheckSum failure",CR,LF,0
  4540 0000106F 436865636B53756D20-
  4540 00001078 6661696C7572650D0A-
  4540 00001081 00
  4541                                  LD_REC_MESS:
  4542 00001082 0D0A4572726F723A20-             DB      CR,LF,"Error: Unknown Record Type",CR,LF,0
  4542 0000108B 556E6B6E6F776E2052-
  4542 00001094 65636F726420547970-
  4542 0000109D 650D0A00
  4543                                  LD_HEX_MESS:
  4544 000010A1 0D0A4572726F723A20-             DB      CR,LF,"Error: Non Hex value received",CR,LF,0
  4544 000010AA 4E6F6E204865782076-
  4544 000010B3 616C75652072656365-
  4544 000010BC 697665640D0A00
  4545                                  LD_OK_MESS:
  4546 000010C3 0D0A4C6F616420646F-             DB      CR,LF,"Load done",CR,LF,0
  4546 000010CC 6E650D0A00
  4547                                  TERM_MESS:
  4548 000010D1 0D0A50726F6772616D-             DB      CR,LF,"Program Terminated with exit code ",0
  4548 000010DA 205465726D696E6174-
  4548 000010E3 656420776974682065-
  4548 000010EC 78697420636F646520-
  4548 000010F5 00
  4549
  4550                                  ; Mess+18=? character, change by bp number
  4551                                  BREAKP_MESS:
  4552 000010F6 0D0A2A2A2A2A204252-             DB      CR,LF,"**** BREAKPOINT ? ****",CR,LF,0
  4552 000010FF 45414B504F494E5420-
  4552 00001108 3F202A2A2A2A0D0A00
  4553
  4554                                  FLAG_MESS:
  4555 00001111 2020204F4449542D53-             DB      "   ODIT-SZAPC=",0
  4555 0000111A 5A4150433D00
  4556                                  FLAG_VALID:
  4557 00001120 585858582E2E2E2E2E-             DB      "XXXX......X.X.X.",0; X=Don't display flag bit, .=Display
  4557 00001129 2E582E582E582E00
  4558
  4559                                  HELP_MESS:
  4560 00001131 0D0A436F6D6D616E64-             DB      CR,LF,"Commands"
  4560 0000113A 73
  4561 0000113B 0D0A444D207B66726F-             DB      CR,LF,"DM {from} {to}        : Dump Memory, example D 0000 0100"
  4561 00001144 6D7D207B746F7D2020-
  4561 0000114D 2020202020203A2044-
  4561 00001156 756D70204D656D6F72-
  4561 0000115F 792C206578616D706C-
  4561 00001168 652044203030303020-
  4561 00001171 30313030
  4562 00001175 0D0A464D207B66726F-             DB      CR,LF,"FM {from} {to} {Byte} : Fill Memory, example FM 0200 020F 5A"
  4562 0000117E 6D7D207B746F7D207B-
  4562 00001187 427974657D203A2046-
  4562 00001190 696C6C204D656D6F72-
  4562 00001199 792C206578616D706C-
  4562 000011A2 6520464D2030323030-
  4562 000011AB 2030323046203541
  4563 000011B3 0D0A52202020202020-             DB      CR,LF,"R                     : Display Registers"
  4563 000011BC 202020202020202020-
  4563 000011C5 2020202020203A2044-
  4563 000011CE 6973706C6179205265-
  4563 000011D7 67697374657273
  4564 000011DE 0D0A4352207B726567-             DB      CR,LF,"CR {reg}              : Change Registers, example CR SP=1234"
  4564 000011E7 7D2020202020202020-
  4564 000011F0 2020202020203A2043-
  4564 000011F9 68616E676520526567-
  4564 00001202 6973746572732C2065-
  4564 0000120B 78616D706C65204352-
  4564 00001214 2053503D31323334
  4565 0000121C 0D0A4C202020202020-             DB      CR,LF,"L                     : Load Intel hexfile"
  4565 00001225 202020202020202020-
  4565 0000122E 2020202020203A204C-
  4565 00001237 6F616420496E74656C-
  4565 00001240 2068657866696C65
  4566 00001248 0D0A5520207B66726F-             DB      CR,LF,"U  {from} {to}        : Un(dis)assemble range, example U 0120 0128"
  4566 00001251 6D7D207B746F7D2020-
  4566 0000125A 2020202020203A2055-
  4566 00001263 6E2864697329617373-
  4566 0000126C 656D626C652072616E-
  4566 00001275 67652C206578616D70-
  4566 0000127E 6C6520552030313230-
  4566 00001287 2030313238
  4567 0000128C 0D0A4720207B416464-             DB      CR,LF,"G  {Address}          : Execute, example G 0100"
  4567 00001295 726573737D20202020-
  4567 0000129E 2020202020203A2045-
  4567 000012A7 7865637574652C2065-
  4567 000012B0 78616D706C65204720-
  4567 000012B9 30313030
  4568 000012BD 0D0A5420207B416464-             DB      CR,LF,"T  {Address}          : Trace from address, example T 0100"
  4568 000012C6 726573737D20202020-
  4568 000012CF 2020202020203A2054-
  4568 000012D8 726163652066726F6D-
  4568 000012E1 20616464726573732C-
  4568 000012EA 206578616D706C6520-
  4568 000012F3 542030313030
  4569 000012F9 0D0A4E202020202020-             DB      CR,LF,"N                     : Trace Next"
  4569 00001302 202020202020202020-
  4569 0000130B 2020202020203A2054-
  4569 00001314 72616365204E657874
  4570 0000131D 0D0A4250207B62707D-             DB      CR,LF,"BP {bp} {Address}     : Set BreakPoint, bp=0..7, example BP 0 2344"
  4570 00001326 207B41646472657373-
  4570 0000132F 7D20202020203A2053-
  4570 00001338 657420427265616B50-
  4570 00001341 6F696E742C2062703D-
  4570 0000134A 302E2E372C20657861-
  4570 00001353 6D706C652042502030-
  4570 0000135C 2032333434
  4571 00001361 0D0A4342207B62707D-             DB      CR,LF,"CB {bp}               : Clear Breakpoint, example BS 7 8732"
  4571 0000136A 202020202020202020-
  4571 00001373 2020202020203A2043-
  4571 0000137C 6C6561722042726561-
  4571 00001385 6B706F696E742C2065-
  4571 0000138E 78616D706C65204253-
  4571 00001397 20372038373332
  4572 0000139E 0D0A44422020202020-             DB      CR,LF,"DB                    : Display Breakpoints"
  4572 000013A7 202020202020202020-
  4572 000013B0 2020202020203A2044-
  4572 000013B9 6973706C6179204272-
  4572 000013C2 65616B706F696E7473
  4573 000013CB 0D0A4253207B576F72-             DB      CR,LF,"BS {Word}             : Change Base Segment Address, example BS 0340"
  4573 000013D4 647D20202020202020-
  4573 000013DD 2020202020203A2043-
  4573 000013E6 68616E676520426173-
  4573 000013EF 65205365676D656E74-
  4573 000013F8 20416464726573732C-
  4573 00001401 206578616D706C6520-
  4573 0000140A 42532030333430
  4574 00001411 0D0A5742207B416464-             DB      CR,LF,"WB {Address} {Byte}   : Write Byte to address, example WB 1234 5A"
  4574 0000141A 726573737D207B4279-
  4574 00001423 74657D2020203A2057-
  4574 0000142C 726974652042797465-
  4574 00001435 20746F206164647265-
  4574 0000143E 73732C206578616D70-
  4574 00001447 6C6520574220313233-
  4574 00001450 34203541
  4575 00001454 0D0A5757207B416464-             DB      CR,LF,"WW {Address} {Word}   : Write Word to address"
  4575 0000145D 726573737D207B576F-
  4575 00001466 72647D2020203A2057-
  4575 0000146F 7269746520576F7264-
  4575 00001478 20746F206164647265-
  4575 00001481 7373
  4576 00001483 0D0A4942207B506F72-             DB      CR,LF,"IB {Port}             : Read Byte from Input port, example IB 03F8"
  4576 0000148C 747D20202020202020-
  4576 00001495 2020202020203A2052-
  4576 0000149E 656164204279746520-
  4576 000014A7 66726F6D20496E7075-
  4576 000014B0 7420706F72742C2065-
  4576 000014B9 78616D706C65204942-
  4576 000014C2 2030334638
  4577 000014C7 0D0A4957207B506F72-             DB      CR,LF,"IW {Port}             : Read Word from Input port"
  4577 000014D0 747D20202020202020-
  4577 000014D9 2020202020203A2052-
  4577 000014E2 65616420576F726420-
  4577 000014EB 66726F6D20496E7075-
  4577 000014F4 7420706F7274
  4578 000014FA 0D0A4F42207B506F72-             DB      CR,LF,"OB {Port} {Byte}      : Write Byte to Output port, example OB 03F8 3A"
  4578 00001503 747D207B427974657D-
  4578 0000150C 2020202020203A2057-
  4578 00001515 726974652042797465-
  4578 0000151E 20746F204F75747075-
  4578 00001527 7420706F72742C2065-
  4578 00001530 78616D706C65204F42-
  4578 00001539 2030334638203341
  4579 00001541 0D0A4F57207B506F72-             DB      CR,LF,"OW {Port} {Word}      : Write Word to Output port, example OB 03F8 3A5A"
  4579 0000154A 747D207B576F72647D-
  4579 00001553 2020202020203A2057-
  4579 0000155C 7269746520576F7264-
  4579 00001565 20746F204F75747075-
  4579 0000156E 7420706F72742C2065-
  4579 00001577 78616D706C65204F42-
  4579 00001580 203033463820334135-
  4579 00001589 41
  4580 0000158A 0D0A51202020202020-             DB      CR,LF,"Q                     : Restart Monitor",0
  4580 00001593 202020202020202020-
  4580 0000159C 2020202020203A2052-
  4580 000015A5 657374617274204D6F-
  4580 000015AE 6E69746F7200
  4581
  4582
  4583                                  UNKNOWN_MESS:
  4584 000015B4 0D0A2A2A2A20455252-             DB      CR,LF,"*** ERROR: Spurious Interrupt ",0
  4584 000015BD 4F523A205370757269-
  4584 000015C6 6F757320496E746572-
  4584 000015CF 727570742000
  4585                                  UNKNOWNSER_MESS:
  4586 000015D5 0D0A2A2A2A20455252-             DB      CR,LF,"*** ERROR: Unknown Service INT,AH=",0
  4586 000015DE 4F523A20556E6B6E6F-
  4586 000015E7 776E20536572766963-
  4586 000015F0 6520494E542C41483D-
  4586 000015F9 00
  4587
  4588                                  ;----------------------------------------------------------------------
  4589                                  ; Disassembler string storage
  4590                                  ;----------------------------------------------------------------------
  4591                                  DISASM_INST:
  4592 000015FA 3F<rep 30h>                     TIMES   48  DB '?'      ; Stored Disassemble string
  4593                                  DISASM_CODE:
  4594 0000162A 3F<rep 20h>                     TIMES   32  DB '?'      ; Stored Disassemble Opcode
  4595
  4596                                  ;----------------------------------------------------------------------
  4597                                  ; Save Register values
  4598                                  ;----------------------------------------------------------------------
  4599                                  UAX:
  4600 0000164A 0000                            DW      00h             ; AX
  4601                                  UBX:
  4602 0000164C 0100                            DW      01h             ; BX
  4603                                  UCX:
  4604 0000164E 0200                            DW      02h             ; CX
  4605                                  UDX:
  4606 00001650 0300                            DW      03h             ; DX
  4607                                  USP:
  4608 00001652 0001                            DW      0100h           ; SP
  4609                                  UBP:
  4610 00001654 0500                            DW      05h             ; BP
  4611                                  USI:
  4612 00001656 0600                            DW      06h             ; SI
  4613                                  UDI:
  4614 00001658 0700                            DW      07h             ; DI
  4615                                  UDS:
  4616 0000165A 8003                            DW      BASE_SEGMENT    ; DS
  4617                                  UES:
  4618 0000165C 8003                            DW      BASE_SEGMENT    ; ES
  4619                                  USS:
  4620 0000165E 8003                            DW      BASE_SEGMENT    ; SS
  4621                                  UCS:
  4622 00001660 8003                            DW      BASE_SEGMENT    ; CS
  4623                                  UIP:
  4624 00001662 0001                            DW      0100h           ; IP
  4625                                  UFL:
  4626 00001664 3AF0                            DW      0F03Ah          ; flags
  4627
  4628                                  DUMPMEMS:
  4629 00001666 3F<rep 10h>                     TIMES   16  DB      '?' ; Stored memdump read values
  4630
  4631 00001676 3F<rep 100h>                    TIMES   256 DB      '?' ; Reserve 256 bytes for the stack
  4632                                  TOS:
  4633 00001776 3F00                            DW      '?'             ; Top of stack
