;	$MOD52
	$NODEBUG
	$PAGEWIDTH	(120)
	$PAGELENGTH	(66)
	$TITLE          (Tiny-Basic51 - Modified for Metalink ASM51)

	$NOMOD51
	$INCLUDE (80515.MCU)

LIT_    MACRO   K
	CALL	LIT
	DB	K
	ENDM

TSTV_   MACRO   LBL
        CALL    TSTV
        JNC     LBL
        ENDM

TSTN_   MACRO   LBL
        CALL    TSTN
        JNC     LBL
        ENDM

TSTL_   MACRO   LBL
        CALL    TSTN
        JNC     LBL
        ENDM

TSTS_   MACRO   LBL
        CALL    TSTS
        JC      LBL
        ENDM

IFDONE_ MACRO   LBL
        CALL    IFDONE
        JNC     LBL
        ENDM

LINIT_  MACRO
        CALL   L_INIT
        JC      ERRENT
        ENDM

COND_   MACRO   LBL
        CALL   COND
        JNC    LBL
        ENDM

NEXT_LOOP_       MACRO   LBL
        CALL   LOOP
        JC     LBL
        ENDM

IJMP_   MACRO   LBL
        JMP     LBL
        ENDM

HOP_    MACRO   LBL
        SJMP    LBL
        ENDM

ICALL_  MACRO   LBL
        CALL    LBL
        ENDM

MLCALL_ MACRO
        CALL    MLCALL
        ANL     PSW,#11100111B
        ENDM


;$ERRORPRINT TITLE(MCS-51(TM) TINY BASIC INTERPRETER 8/26/80)
;
;	TINY BASIC INTERPRETER PROGRAM  (CREATED 3/10/80   JHW)
;	==============================
;
;	INSITE ORDER NO. BF10
;
VERS    EQU     23H
;
; Known Update History:
; Modified from 2.1 to 2.2 by lss 4 jan 1983 to fix errors in the divide routine; and the random number generator.
; Updated: Jim Lum/CompTech Systems, Inc. 04/25/92  V2.3  Converted to Metalink ASM51
;
;
;	STATUS:
;	======
;
;
;	NEW FEATURES/GIMMICKS TO BE CONSIDERED:
;
;	On power-up, system should adapt itself to whatever RAM it can
;	find off-chip.
;	Should allow for and/or identify multiple baud rates for serial link.
;	Should allow other physical devices (software serial I/O, etc.).
;
;	Amount of RAM consumed by BASIC variables should be user-alterable.
;	16-bit variable array handling should be provided when external RAM
;	is available.
;	Program buffering in internal RAM and/or line buffering in external RAM
;	(when available/not available) might be nice.
;
;	INNUM could be changed to allow line editing and expression input.
;
;	Interrupt handlers should be provided for, and supported by strapping
;	options so that CRT is not required.
;
;	Symbolically-accessable 8-bit pseudo CPU-registers, ports,
;	etc. desired to support ML debug.
;	During CALL, pseudo-registers should be loaded/saved.
;
;	Capability to load and dump programs to MDS or twin system desired.
;	Download command desired compatible with ISIS hex file format.
;	Line buffering should ignore initial line-feed to be compatible
;	with down-load or cross-load, and terminate on <cntrl-Z>.
;
;	Expression evaluation algorithm should be changed to use less stack
;	and allow more precedence levels.
;	Since EXPR recursive, hardware stack can overflow (not checked).
;
;	NEXT command should verify that a valid loop record is on the AES 
;	as opposed to GOSUB return address, and vice-versa.
;	STEP values other than +1 should be considered.
;
;	Error reporting could re-type line and indicate error point.
;	Error numbers (if retained) should make some sense.
;	Might be indices for error message strings.
;
;	TRACE mode could aid BASIC debug by typing each source line # executed.
;
;	RND number seed should be easily alterable for games, etc.
;
;$EJECT
;
;	AESTHETIC IMPROVEMENTS DESIRED:
;
;	Disallow 0 and >7FFFH line numbers.
;
;	Source modules could be re-grouped to be more readable
;	and re-ordered to minimize use of LJMPs and LCALLs.
;	Linkage jumps might be created in second 2K page to provide efficient
;	access to first 2K.
;
;	PRN could insert zeros before leading Hex digits.
;
;	IDIV uses variable storage inefficiently (TMP0-TMP4).
;	Should be modified to make use of actual stack variables.
;
;	TST could use optimized algorithm for single character token tests.
;	String tests should skip over unsearched strings more efficiently.
;
;	Program buffer searching could be speeded by giving line length 
;	before text string and computing branch over undesired lines.
;
;	Math and AES operations might be optimized by dedicating R1 as AESP
;	to be loaded and saved only on entering/leaving execution mode.
;
;	Input radix should be determined by 'H' suffix presence.
;	Otherwise labels (GOTO destinations) should always be decimal.
;
;	Space between GO and TO might be forgiven.
;
;	Certain commands might be disallowed in each operating mode:
;	No LIST in execution, no INPUT in interactive, for instance.
;	Some commands (FOR, GOTO, RETURN, etc.) must be last command in line.
;
;	GETLN could be made somewhat more abstract, so that L_INIT and READ_C
;	return characters from edited line buffer in interactive mode and
;	code buffer in execution mode.  Dual execution loops in main IL program
;	can then be combined.  (Line insertion should default when no keyword
;	tokens would be detected during parsing.)
;
;	Get rid of LIST and FNDLBL kludge which falsely sets RUNFLG to fool
;	READ_C subroutine.
;
;	Sequential string testing (command parsing, operator recognition, etc.)
;	could be made table-driven, eliminating repeated "CALL TST"s.
;
;	All data structures need to be better defined in listing.
;	It would be a wise exercize to gather each 
;	data-structure definition/declaration/accessing-routine set
;	into isolated functional modules (like objects),
;	with communication only via global variables.

;
;$EJECT
;
;	GLOBAL VARIABLE AND DATA STRUCTURE DECLARATIONS:
;	====== ======== === ==== ========= ============
;
;	Intended System Configuration Constants:
;
EXTRAM		EQU	2034H+7000H		;External program buffer begins after 26 vars.
RAMLIM		EQU	3000H+7000H		;Allowance made for 4K RAM buffer.
EXTROM		EQU	9080H+3000H		;Start of external ROM space.
TABSIZ		EQU	8			;Formatted column spacing.
AESLEN		EQU	36			;AES Length.
;
;	Working Register Definitions.
;
PNTR_L		EQU	R0			;Program buffer pointer.
DEST_L		EQU	R1			;Destination pointer for line insertion.
PNTR_H		EQU	R2			;High-order pointer byte (temp. cursor)
DEST_H		EQU	R3
CHAR		EQU	R4			;BASIC source string character being parsed.
LP_CNT		EQU	R5
TOS_L		EQU	R6
TOS_H		EQU	R7			;Variable popped from stack for math routines.
;
	DSEG

	ORG 20H
MODE:		DS	1		;Operating mode bits.
EXTVAR		BIT	MODE.0		;Set when BASIC variables in external RAM.
ROMMOD		BIT	MODE.1		;Set when BASIC programs executed from ROM.
EXTMOD		BIT	MODE.2		;Set when BASIC programs fetched externally.
RUNMOD		BIT	MODE.3		;Set when stored BASIC program is running.
HEXMOD		BIT	MODE.4		;Set when operations should use HEX radix.
;	
FLAGS:		DS	1		;Interroutine communication flags.
ZERSUP		BIT	FLAGS.0		;If set, suppress printing leading zeroes.
CHAR_FLG  	BIT	FLAGS.1		;Set when CHAR has not been processed.
SGN_FLG		BIT	FLAGS.2		;Keeps track of operand(s) sign during math.
SEQ_FLG		BIT	FLAGS.3		;
MOD_FLG		BIT	FLAGS.4		;Set if divide routine should return MOD value.
H_FLG		BIT	FLAGS.5		;Used to sense allow 'H' suffix in HEX mode.
;
	ORG	30H
;
;	Temporary variables used by IDIV routine.
;
TMP0:		DS	1
TMP1:		DS	1
TMP2:		DS	1
TMP3:		DS	1
TMP4:		DS	1
;
;	Random number key.
;
SEED_L:		DS	1
SEED_H:		DS	1
;
;
STRLEN:		DS	1			;Length of text string in L_BUF.
;
;US_VAR		User Variable (A,B,...) Array:
;
NO_VAR		EQU	12			;Allow 12 internal variables A - L.
US_VAR:		DS	2*NO_VAR	;Allocate variable storage space.
;

;AES	Arithmetic Expression Stack.
;
AESP:		DS	1			;AES Stack Pointer
AES:		DS	AESLEN		;Buffer allocation.
;
;
;	Line Buffer Variables:
L_CURS:		DS	1			;Cursor for line buffer.
;
TABCNT:		DS	1			;Column formatting count.
;
;CURSOR	Source line cursor.
CURS_L:		DS	1
CURS_H:		DS	1
C_SAVE:		DS	1			;CHAR saved during SAVE_PNTR.
;
LABL_L:		DS	1			;BASIC program source line counter.
LABL_H:		DS	1			;  "       "       "     high byte.
;
SP_BASE	EQU	7FH				;Initialization value for hardware SP.
;
CR			EQU	0DH			;ASCII CODE FOR <CARRIAGE RETURN>.
LF			EQU	0AH			;  "    "    "  <LINE FEED>.
BEL			EQU	07H			;  "    "    "  <BELL>.
;
;$EJECT
;$SAVE NOGEN
;
	CSEG
	ORG	8000H
	JMP	S_INIT		;Jump to system initialization routine.
;
;	Interrupt routine expansion hooks:
;	REMOVED

;	CONSOLE I/O ROUTINES AND DRIVERS:
;	======= === ======== === =======
;
S_INIT:	
	CLR		A
	MOV		PSW,A
	MOV		SEED_H,A
	MOV		SEED_L,A
	MOV		SP,#SP_BASE			;Re-initialize hardware stack.
	CALL	RAM_INIT			;Clear-out variable RAM.
SP_INI:	
;	JNB		RXD, RUNROM
;	CLR		TR1
;	MOV		SCON, #01011010B	;TI set indicates transmitter ready.
;	MOV		TMOD, #00100001B	;Timer 1 is set to auto-reload timer mode.
;	MOV		TH1, #0				;Assume fastest rate.
;	MOV		R0, #144
;	JB		RXD, $
BAUDID:	
;	DJNZ	R0,$
;	DEC		TH1
;	MOV		R0, #94
;	JNB		RXD, BAUDID
;	JB		RXD, $		;Hang-up here until space char. over.
;	JNB		RXD, $
;	SETB	TR1
	CALL	STROUT
	DB      CR,'MCS-51 TINY BASIC/Metalink-Compatible Source V'
	DB      ('0'+VERS/10H),'.',('0'+(VERS AND 0FH)),(CR OR 80H)
	JMP		START
;
RUNROM:	
	SETB	EXTMOD
	SETB	ROMMOD
	JMP		XEC
;
;=======
;
C_IN:
;	Console character input routine.
;	Waits for next input from console device and returns with character
;	code in accumulator.
;	If character is <CNTRL-C> process syntax error.
;	Adjust lower-case alphabetics to upper case.
;
DD005:  
	JNB     RI,$            ;Wait until character received.
	MOV     A,SBUF          ;Read input character.
	CLR		RI				;Clear reception flag.
	ANL		A,#7FH			;Mask off data bits.
	CJNE	A,#03H,C_IN_2	;Test for CNTRL-C code.
	JMP		SYN_ER			;Abort if detected.
;
C_IN_2:	
	CJNE	A,#'a',$+3		;Check for lower-case alphabetics.
	JC		C_IN_1
	CJNE	A,#'z'+1,$+3
	JNC		C_IN_1
	ANL		A,#11011111B	;Force upper-case code.
C_IN_1:	
	RET						;Return to calling routine.
;
;=======
;
;
NLINE:
;	Transmit <CR><LF> sequence to console device.
;
	MOV	A,#CR
C_OUT:
;	Console character output routine.
;	Outputs character received in accumulator to console output device.
;
DD006:  
	JNB     TI,$            ;Wait until transmission completed.
DD007:  
	CLR     TI              ;Clear interrupt flag.
	MOV		SBUF,A			;Write out character.
	CJNE	A,#CR,COUT_2
DD008:  
	JNB     TI,$
DD009:  
	CLR     TI
	MOV		SBUF,#LF		;Output linefeed.
	SJMP	COUT_3
;
COUT_2:	CLR	C
	DJNZ	TABCNT,COUT_1	;Monitor output field position.
COUT_3:	MOV	TABCNT,#TABSIZ	;Reload field counter.
	SETB	C
COUT_1:	RET
;
;=======
;
;
CNTRL:	
	JNB		RI,CNTRET		;Poll whether character has been typed.
	CALL	C_IN
	CJNE	A,#13H,CNTRET	;Check if char. is <CNTRL-S>.
CNTR_2:	
	CALL	C_IN			;If so, hang up...
	CJNE	A,#11H,CNTR_2	;    ...until <CNTRL-Q> received.
CNTRET:	
	RET
;
;=======
;
;
SPC:
;	Transmit one or more space characters to console to move console
;	cursor to start of next field.
;
	MOV		A,#' '			;Load ASCII code for space character.
	CALL	C_OUT
	JNC		SPC				;Repeat until at TAB boundary.
	RET
;
;===============
;
;NIBOUT
;	If low-order nibble in Acc. is non-zero or ZERSUP flag is cleared,
;	output the corresponding ASCII value and clear ZERSUP flag.
;	Otherwise return without affecting output or ZERSUP.
;
NIBOUT:	ANL	A,#0FH		;Mask out low-order bits.
	JNZ	NIBO_2		;Output ASCII code for Acc contents.
	JB	ZERSUP,NIBO_3
NIBO_2:	CLR	ZERSUP		;Mark that non-zero character encountered.
	ADD	A,#(ASCTBL-(NIBO_1+1))	;Offset to start of table.
NIBO_1:	MOVC	A,@A+PC		;Look up corresponding code.
	CALL	C_OUT		;Output character.
NIBO_3:	RET
;
ASCTBL:	DB	'0123456789ABCDEF'
;
;=======
;
;STROUT
;	Copy in-line character string to console output device.
;
STROUT:	POP	DPH		;Access in-line string.
	POP	DPL
STRO_1:	CLR	A
	MOVC	A,@A+DPTR	;Read next byte.
	INC	DPTR		;Bump pointer.
	JBC	ACC.7,STRO_2	;Escape after last character.
	CALL	C_OUT		;Output character.
	SJMP	STRO_1		;Loop until done.
;
STRO_2:	CALL	C_OUT		;Output character.
	CLR	A
	JMP	@A+DPTR		;Return to program.
;
;=======
;$EJECT
ERROUT:
;	Error handling routine common entry point. 
;	(Could retype bad line, etc.)
;
	JMP	ERRENT		;Return to executive.
;
;=======
;
;EXP_ER	Expression evaluation error.
EXP_ER:	CALL	STROUT		;Output error message.
        DB      'HOW?',(CR OR 80H)
	JMP	ERROUT		;Return to executive.
;
;=======
;
;AES_ER	Arithmetic expression stack error handling routine.
AES_ER:	CALL	STROUT		;Output error message.
        DB      'SORRY!',(CR OR 80H)
	JMP	ERROUT		;Return to executive.
;
;
;=======
;
;SYN_ER	Syntax error handling routine.
SYN_ER:	CALL	STROUT		;Output error message.
        DB      CR,'WHAT?',(CR OR 80H)
	JMP	ERROUT		;Process error.
;
;=======
;$EJECT

;
;	ARITHMETIC SUBROUTINE PACKAGE  (8/12/80)
;
;=======
;
POP_TOS:
;	Verify that stack holds at least one (16-bit) entry.
;	(Call AES_ER otherwise.)
;	Pop TOS into registers TOS_H and TOS_L,
;	update AESP,
;	and return with R1 pointing to low-order byte of previous NOS.
;	Do not affect accumulator contents.
;
	MOV	R1,AESP
	CJNE	R1,#AES+1,$+3	;Compare pointer with min. legal level.
	JC	STK_ER
	MOV	TOS_L,A
	MOV	A,@R1
	MOV	TOS_H,A
	DEC	R1
	MOV	A,@R1
	XCH	A,TOS_L		;Store byte and reload ACC.
	DEC	R1
	MOV	AESP,R1
	DEC	R1
	RET
;
;=======
;
POP_ACC:
;	Pop TOS into accumulator and update AESP.
;
	MOV	R1,AESP
	MOV	A,@R1
	DEC	AESP
	RET
;
;=======
;
PUSH_TOS:
;	Verify that the AES is not full,
;	push registers TOS_H and TOS_L onto AES,
;	and update AESP.
;
	MOV	R1,AESP
	CJNE	R1,#AES+AESLEN-2,$+3	;Compare pointer with max. legal level.
	JNC	STK_ER
	INC	R1
	MOV	A,TOS_L		;Push low-order byte.
	MOV	@R1,A
	INC	R1
	MOV	A,TOS_H		;Push high-order byte.
	MOV	@R1,A
	MOV	AESP,R1
	RET
;
STK_ER:	CALL	AES_ER
	DB	0FH
;
;=======
;
;
DUPL:
;	Verify that the AES is not full,
;	then duplicate the top element and update AESP.
;
	MOV	R1,AESP
	CJNE	R1,#AES+AESLEN-2,$+3	;Compare pointer with max. legal level.
	JNC	STK_ER
	DEC	R1
	MOV	A,@R1
	INC	R1
	MOV	B,@R1
	INC	R1
	MOV	@R1,A			;Push low-order byte.
	INC	R1
	MOV	@R1,B
	MOV	AESP,R1
	RET
;
;=======
;
;LIT	(K)
;	Report error if arithmetic expression stack is full.
;	Otherwise push the one-byte constant K onto AES.
;	Return with carry=1, since LIT marks a successful match.
;
LIT:	POP	DPH		;Get parameter address.
	POP	DPL
	CLR	A
	MOVC	A,@A+DPTR	;Read literal value.
	INC	AESP		;Reserve storage on top of AES.
	MOV	R1,AESP		;Point to free entry on stack.
	CJNE	R1,#AES+AESLEN,LIT_1
	JMP	AES_ER
;
LIT_1:	MOV	@R1,A		;Store literal.
	MOV	A,#1		;Branch over constant on return.
	SETB	C
	JMP	@A+DPTR		;Return to IL program.
;
;=======
;$EJECT
;
;	BASIC VARIABLE ACCESSING OPERATIONS  (8/20/80)
;	===== ======== ========= ==========
;
;
;	Direct address mode emulation tables:
;
SFRTBL:	DB	80H
	DB	90H
	DB	0A0H
	DB	0B0H
	DB	88H
	DB	98H
	DB	0A8H
	DB	0B8H
	DB	89H
	DB	8AH
	DB	8BH
	DB	8CH
	DB	8DH
	DB	99H
NO_SFR	EQU	$-SFRTBL
;
;===
;
STRTBL:	MOV	80H,TOS_L
	RET
	MOV	90H,TOS_L
	RET
	MOV	0A0H,TOS_L
	RET
	MOV	0B0H,TOS_L
	RET
	MOV	88H,TOS_L
	RET
	MOV	98H,TOS_L
	RET
	MOV	0A8H,TOS_L
	RET
	MOV	0B8H,TOS_L
	RET
	MOV	89H,TOS_L
	RET
	MOV	8AH,TOS_L
	RET
	MOV	8BH,TOS_L
	RET
	MOV	8CH,TOS_L
	RET
	MOV	8DH,TOS_L
	RET
	MOV	99H,TOS_L
	RET
;
;===
;
INDTBL:	MOV	A,80H
	RET
	MOV	A,90H
	RET
	MOV	A,0A0H
	RET
	MOV	A,0B0H
	RET
	MOV	A,88H
	RET
	MOV	A,98H
	RET
	MOV	A,0A8H
	RET
	MOV	A,0B8H
	RET
	MOV	A,89H
	RET
	MOV	A,8AH
	RET
	MOV	A,8BH
	RET
	MOV	A,8CH
	RET
	MOV	A,8DH
	RET
	MOV	A,99H
	RET
;
;$EJECT
SFR_ID:
;	Identify which SFR is indicated by the contents of R1.
;	Return with acc holding (Index of said register)*3.
;	Call error routine if register number not found.
;
	MOV	DPTR,#SFRTBL
	CLR	A
	MOV	LP_CNT,A
SFID_1:	MOV	A,LP_CNT
	MOVC	A,@A+DPTR
	XRL	A,R1
	JNZ	SFID_2
	MOV	A,LP_CNT
	RL	A
	ADD	A,LP_CNT
	RET
;
SFID_2:	INC	LP_CNT
	MOV	A,LP_CNT
	CJNE	A,#NO_SFR,SFID_1
ADR_ER:	JMP	EXP_ER
;
;=======
;
STRDIR:
;	Store data byte in ACC into direct on-chip RAM address held in R1.
;
	MOV	TOS_L,A
	MOV	A,R1
	JB	ACC.7,STRSFR	;Direct addresses above 7FH are SFRs.
	MOV	A,TOS_L
	MOV	@R1,A		;Store low-order byte in RAM.
	RET
;
STRSFR:	CALL	SFR_ID
	MOV	DPTR,#STRTBL
	JMP	@A+DPTR		;Jump into store sequence.
;
;=======
;
FETDIR:
;	Fetch on-chip directly addressed byte indicated by R1 into Acc. 
;	and return.
;
	MOV	A,R1
	JB	ACC.7,FETSFR
	MOV	A,@R1
	RET
;
FETSFR:	CALL	SFR_ID
	MOV	DPTR,#INDTBL
	JMP	@A+DPTR
;
;=======
;
SPLIT_DBA:
;	Called with TOS_L containing a direct on-chip bit address.
;	Return the direct &byte& address of encompassing 
;	register in R1, and load B with a mask containing a single 1 
;	corresponding to the bit's position in a field of zeroes.
;
	MOV	A,TOS_L
	ANL	A,#11111000B
	JB	ACC.7,SPLSFR
	RL	A
	SWAP	A
	ADD	A,#20H		;Address of bit-address space.
SPLSFR:	MOV	R1,A
	MOV	A,TOS_L
	ANL	A,#07H		;Mask off bit-displacement field.
	ADD	A,#MSKTBL-MSK_PC
	MOVC	A,@A+PC		;Read mask byte.
MSK_PC:
	MOV	B,A
	RET
;
MSKTBL:	DB	00000001B
	DB	00000010B
	DB	00000100B
	DB	00001000B
	DB	00010000B
	DB	00100000B
	DB	01000000B
	DB	10000000B
;
;=======
;
;
SEQ_STORE:
;	Same as STORE, below, except that index is retained
;	rather than being popped.
	SETB	SEQ_FLG
	SJMP	STOR_0
;
;
STORE:
;	When STORE is called, AES contains
;	(TOS:)	2 byte VALUE to be stored,
;		2 byte INDEX of destination variable,
;		1 byte TYPE code for variable space.
;			(0=BASIC variable,
;			 1=DBYTE,
;			 2=RBIT,
;			 3=XBYTE,
;			 4=CBYTE.)
;	Store (VAR_1) into appropriate variable memory at location of (INDEX).
;
	CLR	SEQ_FLG
STOR_0:	CALL	POP_TOS
	MOV	TMP0,TOS_L
	MOV	TMP1,TOS_H
	CALL	POP_TOS
	CALL	POP_ACC		;Load TYPE code.
	JNB	SEQ_FLG,STOR_1	;Jump forward if simple store.
	INC	AESP
	INC	AESP
	INC	AESP
STOR_1:	MOV	DPTR,#STRJTB
	MOVC	A,@A+DPTR
	JMP	@A+DPTR
;
STRJTB:	DB	STRVAR-STRJTB
	DB	STRDBY-STRJTB
	DB	STRRBI-STRJTB
	DB	STRXBY-STRJTB
	DB	STRCBY-STRJTB
;
;=======
;
;	All of the following routines are called with 
;	TOS_L holding the low-order address of the destination,
;	TOS_H holding the high-order address (if necessary),
;	and <TMP1><TMP0> holding the 8- or 16-bit data to be stored.
;
STRVAR:	MOV	A,TOS_L
	RL	A		;Multiply by two for 2 byte variables.
	JB	EXTVAR,STREXT	;Branch if vars in external RAM.
	ADD	A,#US_VAR	;Offset for variable array.
	MOV	R1,A
	ADD	A,#-(US_VAR+2*NO_VAR-1)	;Compare with maximum legal address.
	JC	ADR_ER
	MOV	@R1,TMP0
	INC	R1
	MOV	@R1,TMP1
	RET
;
STREXT:	MOV	R1,A
DD001:  MOV     P2,#HIGH(EXTRAM)
        MOV     A,TMP0
	MOVX	@R1,A
	INC	R1		;Bump pointers.
	MOV	A,TMP1		;Move high-order byte into variable array.
	MOVX	@R1,A
	RET
;
;===
;
STRDBY:	MOV	A,TOS_L		;Load acc. with low-order dest. addr.
	MOV	R1,A
	MOV	A,TMP0
	JMP	STRDIR
;
;===
;
STRRBI:	CALL	SPLIT_DBA
	CALL	FETDIR
	MOV	TOS_L,A
	MOV	A,TMP0
	JB	ACC.0,SETRBI
;
;	Clear RBIT.
;
	MOV	A,B
	CPL	A
	ANL	A,TOS_L
	JMP	STRDIR
;
SETRBI:	MOV	A,B
	ORL	A,TOS_L
	JMP	STRDIR
;
;===
;
STRXBY:
STRCBY:	MOV	P2,TOS_H
	MOV	A,TOS_L
	MOV	R1,A
	MOV	A,TMP0
	MOVX	@R1,A
	RET
;
;===============
;
;
SEQ_FETCH:
;	Same as FETCH, below, except that index is retained
;	rather than being popped.
	SETB	SEQ_FLG
	SJMP	FET_0
;
;
FETCH:
;	When FETCH is called, AES contains
;	(TOS:)	2 byte INDEX of source variable,
;		1 byte TYPE code for variable space.
;			(0=BASIC variable,
;			 1=DBYTE,
;			 2=RBIT,
;			 3=XBYTE,
;			 4=CBYTE.)
;	Read 8- or 16-bit variable from the appropriate variable 
;	memory at location of (INDEX) and return on AES.
;
	CLR	SEQ_FLG
FET_0:	CALL	POP_TOS
	CALL	POP_ACC
	JNB	SEQ_FLG,FET_1	;Jump forward if simple store.
	INC	AESP
	INC	AESP
	INC	AESP
FET_1:	MOV	DPTR,#FETJTB
	MOVC	A,@A+DPTR
	JMP	@A+DPTR
;
FETJTB:	DB	FETVAR-FETJTB
	DB	FETDBY-FETJTB
	DB	FETRBI-FETJTB
	DB	FETXBY-FETJTB
	DB	FETCBY-FETJTB
;
;=======
;
;	All of the following routines are called with 
;	TOS_L holding the low-order index of the desired variable,
;	and TOS_H holding the high-order index (if necessary).
;
FETVAR:	MOV	A,TOS_L
	RL	A		;Correct for double-byte entries.
	JB	EXTVAR,FETEXT
	ADD	A,#US_VAR	;Offset for variable array.
	MOV	R1,A		;Index to variable storage array.
	ADD	A,#-(US_VAR+2*NO_VAR-1)
	JC	FETERR
	MOV	A,@R1		;Load low-order byte of variable.
	MOV	TOS_L,A		;And store on AES.
	INC	R1		;Bump pointer.
	MOV	A,@R1		;Transfer high-order byte of variable.
	MOV	TOS_H,A
	JMP	PUSH_TOS
;
;===
;
FETEXT:	MOV	R1,A		;Index to variable storage array.
DD002:  MOV     P2,#HIGH(EXTRAM)
        MOVX    A,@R1           ;Load low-order byte of variable.
	MOV	TOS_L,A		;And store on AES.
	INC	R1		;Bump pointers.
	MOVX	A,@R1		;Transfer high-order byte of variable.
	MOV	TOS_H,A
	JMP	PUSH_TOS
;
FETERR:	JMP	ADR_ER
;
;===
;
FETDBY:	MOV	A,TOS_L
	MOV	R1,A
	CALL	FETDIR
	SJMP	FETBDN		;Byte fetch done.
;
;===
;
FETRBI:	CALL	SPLIT_DBA
	CALL	FETDIR
	ANL	A,B
	ADD	A,#0FFH
	CLR	A
	RLC	A
	SJMP	FETBDN
;
;===
;
FETXBY:	MOV	P2,TOS_H
	MOV	A,TOS_L
	MOV	R1,A
	MOVX	A,@R1
	SJMP	FETBDN
;
;===
;
FETCBY:	MOV	DPH,TOS_H
	MOV	DPL,TOS_L
	CLR	A
	MOVC	A,@A+DPTR
FETBDN:	MOV	TOS_H,#00H	;FETCH sequence for Bytes Done.
	MOV	TOS_L,A		;FETCH sequence for words done.
	JMP	PUSH_TOS
;
;=======
;$EJECT
;
;CREATE
;	Test the contents of Acc.
;	If CHAR holds the ASCII code for a legitimate decimal digit,
;	create a two-byte entry in <TOS_H><TOS_L> holding low-order ACC nibble
;	and return with CY set.
;	Otherwise, return with CY cleared.
;
CREATE:	ADD	A,#-'0'		;Correct for ASCII digit offset.
	CJNE	A,#10,$+3	;Compare to maximum legal digit.
	JNC	CREA_1		;Abort if first char is not decimal digit.
	MOV	TOS_L,A		;Save initial digit read.
	MOV	TOS_H,#0	;Clear high-order bits.
	CLR	H_FLG
CREA_1:	RET
;
;===============
;
;APPEND
;	Test ASCII code in Acc.
;	If it is a legal digit in the current radix,
;	modify <TOS_H><TOS_L> to include this digit and return with CY set.
;	Otherwise leave AES and CHAR unchanged and return with CY cleared.
;	Operating mode determined by HEXMOD flag (1=Hex).
;
APPEND:	JB	H_FLG,APND_2	;Nothing allowed after trailing 'H' received.
	ADD	A,#-'0'		;Correct for ASCII offset.
	CJNE	A,#10,$+3	;Verify whether legal digit.
	JC	APND_1		;Insert decimal digit as is.
	JNB	HEXMOD,APND_2	;If in decimal mode, character isn't legal.
	ADD	A,#'0'-'A'	;Acc now equals 0 if 'A' received.
	CJNE	A,#6,$+3
	JC	APND_4		;Process Hex digit.
;
;	Char was not hexidecimal digit, but if it was the first 'H', that's OK.
;
	CJNE	A,#'H'-'A',APND_2	;Compare original input with 'H'.
	SETB	H_FLG		;Mark that 'H' was detected but don't process.
	SETB	C
	RET
;
APND_4:	ADD	A,#10		;Value of lowest hex digit.
APND_1:	XCH	A,TOS_L		;Save nibble to be appended.
	MOV	B,#10		;(Assuming radix=decimal.)
	JNB	HEXMOD,XRAD_1	;Skip ahead if assumption correct.
	MOV	B,#16		;If mode is actually hex.
XRAD_1:	PUSH	B		;Save for re-use.
	MUL	AB		;Multiply by radix.
	ADD	A,TOS_L		;Append new digit.
	MOV	TOS_L,A		;Save low-order shifted value.
	CLR	A
	ADDC	A,B		;Incremented high-order product if carry.
	XCH	A,TOS_H
	POP	B
	MUL	AB
	ADD	A,TOS_H
	MOV	TOS_H,A
	ORL	C,ACC.7		;Detect if most significant bit set.
	MOV	A,B
	ADDC	A,#0FFH		;Simulate "ORL	C,NZ" instruction.
	ANL	C,/HEXMOD	;Overflow only relevent in decimal mode.
	JC	APN_ER		;Error if bit 7 overflow occurred.
	SETB	C		;CHAR processed as legal character.
	RET
;
APND_2:	CLR	C
	RET
;
;
APN_ER:	CALL	EXP_ER		;Indicate illegal entry.
	DB	2
;
;$EJECT
;
OV_TST:
;	If OV is set and operation is BCD mode then call EXP_ER routine.
;
	MOV	C,OV
	ANL	C,/HEXMOD
	JC	EXP_OV
	RET
;
EXP_OV:	CALL	EXP_ER
	DB	6
;
;=======
;
ADD_16:	MOV	A,@R1		;Add low-order bytes.
	ADD	A,TOS_L
	MOV	@R1,A		;Save sum.
	INC	R1
	MOV	A,@R1		;Add high-order bytes.
	ADDC	A,TOS_H
	MOV	@R1,A		;Save sum.
	RET
;
;=======
;
;
IADD:
;	Pop VAR from AES (two bytes).
;	TOS <= TOS + VAR
;
	CALL	POP_TOS
	CALL	ADD_16
	JMP	OV_TST
;
;===============
;
;ISUB
;	Pop VAR from AES (two bytes).
;	TOS <= TOS - VAR
;
;
ISUB:	ACALL	POP_TOS
	CLR	C		;Set up for subtraction with borrow.
	MOV	A,@R1		;Subtract low-order bytes.
	SUBB	A,TOS_L
	MOV	@R1,A		;Save difference.
	INC	R1		;Bump pointers.
	MOV	A,@R1		;Subtract high-order bytes.
	SUBB	A,TOS_H
	MOV	@R1,A		;Save difference.
	JMP	OV_TST
;
;=======
;
;
IAND:
;	Pop VAR from AES (two bytes).
;	TOS <= TOS AND VAR
;
	CALL	POP_TOS
	MOV	A,@R1		;AND low-order bytes.
	ANL	A,TOS_L
	MOV	@R1,A		;Save result.
	INC	R1
	MOV	A,@R1		;AND high-order bytes.
	ANL	A,TOS_H
	MOV	@R1,A		;Save result.
	RET
;
;=======
;
;
IOR:
;	Pop VAR from AES (two bytes).
;	TOS <= TOS OR VAR
;
	CALL	POP_TOS
	MOV	A,@R1		;OR low-order bytes.
	ORL	A,TOS_L
	MOV	@R1,A		;Save result.
	INC	R1
	MOV	A,@R1		;OR high-order bytes.
	ORL	A,TOS_H
	MOV	@R1,A		;Save result.
	RET
;
;=======
;
;
IXOR:
;	Pop VAR from AES (two bytes).
;	TOS <= TOS XOR VAR
;
	CALL	POP_TOS
	MOV	A,@R1		;XOR low-order bytes.
	XRL	A,TOS_L
	MOV	@R1,A		;Save result.
	INC	R1
	MOV	A,@R1		;XOR high-order bytes.
	XRL	A,TOS_H
	MOV	@R1,A		;Save result.
	RET
;
;===============
;
;
NEG:
;	TOS <= -TOS
;
	CLR	C
	CPL	SGN_FLG
NEG_0:	MOV	R1,AESP		;Compute variable address.
	DEC	R1		;Index for low-order byte of VAR_1.
	CLR	A		;Subtract VAR_1 from 0000H.
	SUBB	A,@R1
	MOV	@R1,A		;Save difference.
	INC	R1		;Bump pointer.
	CLR	A
	SUBB	A,@R1		;Subtract high-order byte.
	MOV	@R1,A		;Save difference.
	JMP	OV_TST
;
;=======
;
;
ICPL:
;	TOS <= /TOS  (ones complement)
	SETB	C
	SJMP	NEG_0
;
;===============
;
;
IABS:
;	If in decimal mode and TOS < 0 
;	then complement SGN_FLG and negate TOS.
;
	MOV	R1,AESP
	MOV	A,@R1
	MOV	C,ACC.7
	ANL	C,/HEXMOD
	JC	NEG
	RET
;
;=======
;
NEG_IF_NEG:
;	If SGN_FLG is set then negate TOS and complement SGN_FLG,
;	else return with TOS unchanged.
	JB	SGN_FLG,NEG
	RET
;
;=======
;
;
IINC:
;	TOS <= TOS+1
;
	MOV	R1,AESP		;Compute variable address.
	DEC	R1		;Index for low-order byte of VAR_1.
	INC	@R1
	CJNE	@R1,#00,IINC_1
	INC	R1		;Bump pointer.
	INC	@R1
IINC_1:	RET
;
;=======
;
MUL_16:
;	Multiply unsigned 16-bit quantity in <TOS_H><TOS_L> by entry
;	on top of stack, and return with product on stack.
;	If product exceeds 16-bits, set OV flag.
;
	CLR	F0		;Initialize overflow flag.
	MOV	R1,AESP		;Point to MSB of NOS.
	MOV	A,@R1
	JZ	IMUL_1		;High-order byte of either param. must be 0.
	MOV	A,TOS_H
	JZ	IMUL_1
	SETB	F0		;Mark that both parameters exceed 255.
IMUL_1:	DEC	R1		;Index low-order NOS.
	MOV	A,@R1
	MOV	B,TOS_H
	MUL	AB		;Low-order product.
	JNB	OV,IMUL_2
	SETB	F0
IMUL_2:	INC	R1
	XCH	A,@R1		;Save low-order prod. and load high-order NOS.
	MOV	B,TOS_L
	MUL	AB
	JNB	OV,IMUL_3	;Mark if overflow.
	SETB	F0
IMUL_3:	ADD	A,@R1
	MOV	@R1,A		;Save high-order sum.
	ORL	C,F0
	MOV	F0,C
	DEC	R1		;Address low-order NOS.
	MOV	A,@R1
	MOV	B,TOS_L
	MUL	AB
	MOV	@R1,A
	MOV	A,B
	INC	R1
	ADD	A,@R1
	MOV	@R1,A		;Save high-order product.
	ORL	C,F0		;Check if carry or sign-bit set.
	ORL	C,ACC.7		;Check if sign-bit set.
	MOV	OV,C
	RET
;
;=======
;
;
IMUL:
;	Pop VAR from AES (two bytes).
;	TOS <= TOS * VAR
;
	CLR	SGN_FLG		;Initialize sign monitor flag.
	CALL	IABS		;Take absolute value of TOS.
	CALL	POP_TOS		;Pop top entry.
	CALL	IABS		;Take absolute value of NOS.
	CALL	MUL_16
	CALL	OV_TST		;Check if OV relevent.
	CALL	NEG_IF_NEG
	RET
;
;===============
;
;
IMOD:	SETB	MOD_FLG		;Indicate modulo entry point.
	SJMP	IDIV_0
;
;=======
;
;
IDIV:
;	Pop VAR from AES (two bytes).
;	TOS <= TOS / VAR
;	If divide-by-zero attempted report error.
;
	CLR	MOD_FLG		;Indicate division entry point.
IDIV_0:	SETB	SGN_FLG		;Initialize sign monitor flag.
	CALL	IABS
	CALL	NEG
	CALL	POP_TOS
;???
; The next line of code added by lss 21-dec-1982
;???
	mov	a,tos_l
	ORL	A,TOS_H
	JZ	DIV_NG
	MOV	C,SGN_FLG
	ANL	C,/MOD_FLG	;Clear SGN_FLG if MOD funtion being done.
	MOV	SGN_FLG,C
	CALL	IABS
	MOV	TMP1,A
	DEC	R1
	MOV	A,@R1
	MOV	TMP0,A
	CLR	A
	MOV	TMP3,A
	MOV	TMP2,A
	MOV	LP_CNT,#17
	CLR	C
	SJMP	DIV_RP
;
DIV_LP:	MOV	A,TMP2
	RLC	A
	MOV	TMP2,A
	XCH	A,TMP3
	RLC	A
	XCH	A,TMP3
	ADD	A,TOS_L
	MOV	TMP4,A
	MOV	A,TMP3
	ADDC	A,TOS_H
	JNC	DIV_RP
	MOV	TMP2,TMP4
	MOV	TMP3,A
DIV_RP:	MOV	A,TMP0
	RLC	A
	MOV	TMP0,A
	MOV	A,TMP1
	RLC	A
	MOV	TMP1,A
	DJNZ	LP_CNT,DIV_LP
	JB	MOD_FLG,DIV_1
	MOV	@R1,TMP0
	INC	R1
	MOV	@R1,TMP1
	SJMP	DIV_2
;
DIV_1:	MOV	@R1,TMP2
	INC	R1
	MOV	@R1,TMP3
DIV_2:	CALL	NEG_IF_NEG
	RET
;
DIV_NG:	AJMP	EXP_OV		;Report expression overflow.
;
;===============
;
;$EJECT
;
;
RND:
;	Generate a new 16-bit random number from RND_KEY,
;	and push onto the AES.
	MOV	TOS_L,SEED_L
	MOV	TOS_H,SEED_H
	CALL	PUSH_TOS
        MOV     TOS_L,#LOW(25173)
        MOV     TOS_H,#HIGH(25173)
	CALL	MUL_16
        MOV     TOS_L,#LOW(13849)
        MOV     TOS_H,#HIGH(13849)
	MOV	R1,AESP
	DEC	R1
	CALL	ADD_16
	CALL	POP_TOS
;
;???
; The code from here to label no_problem added by lss 21 dec 1982
; to cure a extraneous overflow if seed=8000h.
;???
;
	cjne	tos_l,#0,no_problem
	cjne	tos_h,#80h,no_problem
big_problem:				   ; tos=8000h will generate an overflow
	mov	tos_l,#low(12586)          ; when control gets to iabs.
	mov	tos_h,#high(12586)         ; Load the precalculated seed.
no_problem:
	MOV	SEED_L,TOS_L
	MOV	SEED_H,TOS_H
	CALL	PUSH_TOS
	RET
;
;===============
;
;
CMPR:
;	When CMPR is called, AES contains:
;	(TOS:)	VAR_2 (two bytes),
;		C_CODE (one byte),
;		VAR_1 (two bytes).
;	Pop all 5 bytes from stack and test relation between VAR_1 and VAR_2.
;	    If C_CODE=010 then test whether (VAR_1) =  (VAR_2)
;	    If C_CODE=100 then test whether (VAR_1) <  (VAR_2)
;	    If C_CODE=110 then test whether (VAR_1) <= (VAR_2)
;	    If C_CODE=101 then test whether (VAR_1) <> (VAR_2)
;	    If C_CODE=001 then test whether (VAR_1) >  (VAR_2)
;	    If C_CODE=011 then test whether (VAR_1) >= (VAR_2)
;	If true then return 0001H on AES;
;	otherwise return 0000H.
;
	CALL	POP_TOS
	CALL	POP_ACC
	MOV	B,A
	MOV	R1,AESP
	DEC	R1
	CLR	C		;...in preparation for string subtract.
	MOV	A,@R1		;Compare low-order parameter bytes.
	SUBB	A,TOS_L
	INC	R1		;Bump pointer.
	XCH	A,@R1		;Save difference.
	JB	HEXMOD,CMPR_4
	XRL	A,#80H		;Offset variable by 80H for unsigned compare.
	XCH	A,TOS_H
	XRL	A,#80H
	XCH	A,TOS_H
CMPR_4:	SUBB	A,TOS_H
	ORL	A,@R1		;Add any non-zero high-order bits to acc.
	JNZ	CMPR_1		;Jump ahead VAR_1 <> VAR_2.
;
;	VAR_1 = VAR_2:
;
	MOV	C,B.1		;Load VAR_1 = VAR_2 test flag.
	SJMP	PUSH_C
;
CMPR_1:	JC	CMPR_2		;Jump ahead if VAR_1 < VAR_2.
;
;	VAR_1 > VAR_2:
;
	MOV	C,B.0		;Load VAR_1 > VAR_2 test flag.
	SJMP	PUSH_C
;
;	VAR_1 < VAR_2:
;
CMPR_2:	MOV	C,B.2		;Load VAR_1 < VAR_2 test flag.
PUSH_C:	CLR	A
	MOV	@R1,A
	RLC	A
	DEC	R1
	MOV	@R1,A
	RET
;
;$EJECT

;	BASIC SOURCE PROGRAM LINE ACCESSING ROUTINES:
;	===== ====== ======= ==== ======= ==========
;
;	The general methodology of the various parsing routines is as follows:
;	The POINTER (PNTR_L, PNTR_H) is used to indicate the next BASIC
;	source character or string to be parsed
;	by routines TST, TSTV, TSTN, TSTL, and TSTS.
;	GET_C reads the indicated character from the appropriate
;	program buffer space into acc. and returns.
;	READ_CHAR reads the character into CHAR as well as acc. and 
;	increments the 16-bit pointer.
;	When done, each routine calls D_BLANK to remove any trailing spaces,
;	and leaves READ_CHAR ready to fetch the next non-blank character.
;
;=======
;
;REWIND
;	Reset Cursor to start of current program buffer space.
;
REWIND:	CLR	CHAR_FLG
	JB	ROMMOD,REWROM
        MOV     PNTR_H,#HIGH(EXTRAM)
        MOV     PNTR_L,#LOW(EXTRAM)
	RET
;
REWROM:	JB	EXTMOD,RWXROM
        MOV     PNTR_H,#HIGH(INTROM)
        MOV     PNTR_L,#LOW(INTROM)
	RET
;
RWXROM: MOV     PNTR_H,#HIGH(EXTROM)
        MOV     PNTR_L,#LOW(EXTROM)
	RET
;
;=======
;
SAVE_PNTR:
;	Save PNTR variables in cursor.
;
	MOV	CURS_L,PNTR_L
	MOV	CURS_H,PNTR_H
	MOV	C_SAVE,CHAR
	RET
;
;=======
;
LOAD_PNTR:
;	Reload pointer with value saved earlier by SAVE_PNTR.
;
	MOV	PNTR_H,CURS_H
	MOV	PNTR_L,CURS_L
	MOV	CHAR,C_SAVE
	RET
;
;=======
;
GET_C:
;	Read character from logical buffer space into A and return.
;
	JB	RUNMOD,GET_BUF
	MOV	A,@PNTR_L
	RET
;
GET_BUF:
;	Read character from active program buffer space into A and return.
	JB	ROMMOD,GETROM
DD003:  MOV     P2,PNTR_H               ;Select variable storage page.
        MOVX    A,@PNTR_L               ;Read from external address space.
	RET
;
GETROM:	MOV	A,PNTR_L
	XCH	A,DPL
	XCH	A,PNTR_H
	XCH	A,DPH
	MOV	PNTR_L,A
	CLR	A
	MOVC	A,@A+DPTR
	XCH	A,PNTR_L		;Save char. and load old DPH.
	XCH	A,DPH
	XCH	A,PNTR_H
	XCH	A,DPL
	XCH	A,PNTR_L		;Store DPL and reload byte read.
	RET
;
;=======
;
READ_CHAR:
;	READ_CHAR first tests the state of CHAR_FLG.
;	If it is still cleared, the character most recently read from the line
;	buffer or program buffer has been processed, so read the next
;	character, bump the buffer pointer, and return with the character
;	in both Acc. and CHAR and the CHAR_FLG cleared.
;	If CHAR_FLG has been set by the parsing routines,
;	then CHAR still holds a previously read character which has
;	not yet been processed.  Read this character into Acc. and return
;	with CHAR_FLG again cleared.
;
	JBC	CHAR_FLG,REREAD
	CALL	GET_C
	MOV	CHAR,A
	INC	PNTR_L
	CJNE	PNTR_L,#00,RDCHDN
	INC	PNTR_H
RDCHDN:	RET
;
REREAD:	MOV	A,CHAR
	RET
;
;=======
;
PUT_BUF:
;	Put the contents of the acc. into program buffer space
;	currently active at the address held in <DEST_H><DEST_L>.
;
	JB	ROMMOD,PUTROM
DD004:  MOV     P2,DEST_H
        MOVX    @DEST_L,A
	RET
;
PUTROM:	JMP	EXP_ER
;
;=======
;
WRITE_CHAR:
;	Converse of READ_CHAR.
;	Write contents of acc. into appropriate memory space (@DEST),
;	increment DEST, and return.
;
	CALL	PUT_BUF
	INC	DEST_L
	CJNE	DEST_L,#00H,WRCH_1
	INC	DEST_H
WRCH_1:	RET
;
;=======
;
D_BLNK:
;	Remove leading blanks from BASIC source line, update cursor,
;	load first non-blank character into CHAR,
;	and leave pointer loaded with its address.
;	(This routine is jumped to by parsing routines when successful,
;	so set C before returning to original routines.)
;
	CALL	READ_CHAR
	XRL	A,#' '		;Verify that it is non-blank.
	JZ	D_BLNK		;Loop until non-blank leading character.
	SETB	CHAR_FLG
	SETB	C
	RET			;Return to scanning code.
;
;=======
;
;SKPLIN
;	Skip Cursor over entire BASIC source line, leaving
;	cursor pointing to character after terminating <CR>.
;SKPTXT
;	Skip remainder of line in progress, assuming line number 
;	has already been passed over.
;	(Note that either byte of binary line number could be
;	mis-interpreted as a CR.)
;
;
SKPLIN:	CALL	READ_CHAR
	CALL	READ_CHAR
SKPTXT:	CALL	READ_CHAR
	CJNE	A,#CR,SKPTXT	;Verify that it is non-<CR>.
	RET			;Return to scanning code.
;
;=======
;$EJECT
;
;	Token recognition and processing routines.
;
;
TST:
;	If "TEMPLATE" matches the BASIC character string read by 
;	READ_CHAR then move pointer over string and any trailing blanks
;	and continue with the following IL instruction.
;	Otherwise leave pointer unchanged and branch to IL instruction at LBL.
;
	POP	DPH		;Get in-line parameter base address from stack.
	POP	DPL
	CALL	READ_CHAR
	CALL	SAVE_PNTR
TST_1:	CLR	A
	MOVC	A,@A+DPTR	;Read next character from template string.
	MOV	C,ACC.7		;Save terminator bit.
	ANL	A,#7FH		;Mask off terminator.
	XRL	A,CHAR		;Compare with template.
	JNZ	T_BAD		;Abort if first characters miscompare.
	INC	DPTR		;Pass over template character just checked.
	JC	T_GOOD		;Done if template character bit 7 set.
	CALL	READ_CHAR	;Fetch next character for test.
	CJNE	CHAR,#'.',TST_1	;Done if input string abbreviated at this point
TST_2:	CLR	A		;Fetch template characters until end of string
	MOVC	A,@A+DPTR
	INC	DPTR
	JNB	ACC.7,TST_2	;Loop until last character detected.
T_GOOD:	CALL	D_BLNK
	CLR	A
	JMP	@A+DPTR		;Return to next IL instruction
;
;	Strings do not match.  Leave cursor at start of string.
;
T_BAD:	CLR	A
	MOVC	A,@A+DPTR	;Search for final template character.
	INC	DPTR
	JNB	ACC.7,T_BAD	;Loop until terminator found.
	CALL	LOAD_PNTR
	SETB	CHAR_FLG
	CLR	C		;Mark string not found.
	CLR	A
	JMP	@A+DPTR		;Return to mismatch branch instruction.
;
;===============
;
;TSTV	(LBL)
;
;
TSTV:
;	Test if first non-blank string is a legal variable symbol.
;	If so, move cursor over string and any trailing blanks,
;	compute variable index value,
;	push onto arithmetic expression stack,
;	and continue with following IL instruction.
;	Otherwise branch to IL instruction at LBL with cursor unaffected.
;
	CALL	READ_CHAR
	ADD	A,#-'A'		;Subtract offset for base variable.
	MOV	TOS_L,A		;Save index in case needed later.
	ADD	A,#-26
	JNC	ALPHAB		;First character is alphabetic if C=0.
	SETB	CHAR_FLG
	CLR	C
	RET
;
ALPHAB:	CALL	SAVE_PNTR	;In case variable name not found.
	CALL	READ_CHAR	;Verify that next character is not alphabetic.
	ADD	A,#-'A'		;Alphabetic characters now <= 25.
	ADD	A,#-26		;Non-alphabetics cause overflow.
	JNC	NOTVAR		;Alphabetic character means illegal var. name.
	CJNE	CHAR,#'.',TSTV_1	;Period indicates abbreviated keyword.
NOTVAR:	CALL	LOAD_PNTR
	SETB	CHAR_FLG
;*        %TST    (TSTRBI,DBYTE)  ;Test if direct byte token.
        call   tst
        db      'DBYT',('E' OR 80H)
        jnc     tstrbi
        LIT_    1
	SJMP	INDEX
;
;*TSTRBI: %TST    (TSTXBY,RBIT)
tstrbi: call   tst
        db      'RBI',('T' OR 80H)
        jnc     tstxby
        LIT_    2
	SJMP	INDEX
;
;*TSTXBY: %TST    (TSTCBY,XBYTE)  ;Test if expansion RAM byte token.
tstxby: call   tst
        db      'XBYT',('E' OR 80H)
        jnc     tstcby
        LIT_    3
	SJMP	INDEX
;
;*TSTCBY: %TST    (NOTSYM,CBYTE)  ;Test if program memory byte token.
tstcby: call   tst
        db      'CBYT',('E' OR 80H)
        jnc     notsym
        LIT_    4
INDEX:	CALL	VAR
	SETB	C
	RET
;
NOTSYM:	CLR	C		;Indicate that condition tested wasn't true.
	RET
;
;	BASIC Variable name is legitimate (A-Z).
;
TSTV_1:	LIT_	0
	MOV	TOS_H,#0
	CALL	PUSH_TOS
	SETB	CHAR_FLG
	JMP	D_BLNK		;Remove leading blanks from source line.
;
;===============
;
;TSTN	(LBL)
;	Test if indicated string is an unsigned number.
;	If so, move cursor over string and trailing blanks,
;	compute number's binary value,
;	push onto arithmetic expression stack, and continue with
;	following IL instruction.
;	Otherwise restore cursor and branch to IL instruction at LBL.
;
;
TSTN:	CALL	READ_CHAR
	CALL	CREATE		;Create entry on AES if legit. digit.
	JC	TSTN_1		;Abort if CHAR is not decimal digit.
	SETB	CHAR_FLG
	RET
;
TSTN_1:	CALL	READ_CHAR	;Move over matched character.
	CALL	APPEND		;Append new digit to entry on TOS.
	JC	TSTN_1		;Continue processing while legal characters.
	CALL	PUSH_TOS
	SETB	CHAR_FLG
	JMP	D_BLNK		;Remove leading blank characters.
;
;===============
;
;TSTL	(LBL)
;	Test if first non-blank string is a BASIC source line number.
;	If so, move cursor over string and following blanks,
;	compute number's binary value,
;	push onto arithmetic expression stack, 
;	and continue with next IL instruction.
;	If invalid source line number report syntax error.
;	If line number not present restore cursor
;	and branch to IL instruction at LBL.
;
;
;===============
;
;TSTS	(LBL)
;	Test if first character is a quote.
;	If so, print characters from the BASIC source program to the console
;	until a (closing) quote is encountered,
;	pass over any trailing blanks,
;	leave source cursor pointing to first non-blank character,
;	and branch to IL instruction at location (LBL).
;	(Report syntax error if <CR> encountered before quote.)
;	If first character is not a quote, return to next
;	sequential IL instruction with cursor unchanged.
;
;
TSTS:	CALL	READ_CHAR
	MOV	TMP0,A
	XRL	A,#'"'
	JZ	TSTS_1
	XRL	A,#'''' XOR '"'
	JZ	TSTS_1
	CLR	C
	SETB	CHAR_FLG
	RET
;
TSTS_1:	CALL	READ_CHAR	;Read next string character.
	CJNE	A,TMP0,TSTS_2
	JMP	D_BLNK
;
TSTS_2:	CALL	C_OUT		;Call output routine.
	CJNE	A,#CR,TSTS_1	;<CR> before closing quote is illegal.
	JMP	SYN_ER		;Transmit error message.
;
;===============
;
;DONE
;	Delete leading blanks from the BASIC source line.
;	Return with the cursor positioned over the first non-blank
;	character, which must be a colon or <CR> in the source line.
;	If any other characters are encountered report a syntax error.
;
;
;
DONE:	CALL	READ_CHAR
	CJNE	CHAR,#':',DONE_1	;Colon indicates resume interpretation.
	RET			;Return to IL.
;
LNDONE:	CALL	READ_CHAR
DONE_1:	CJNE	CHAR,#CR,DONE_2	;Any non-colon, non-CR characters are illegal.
	RET
;
DONE_2:	SETB	CHAR_FLG
	JMP	SYN_ER		;Process syntax error if so.
;
;=======
;
;IFDONE	(LBL)
;	If the first non-blank character is a colon or <CR> in the source line
;	then branch to the IL instruction specified by (LBL).
;	If any other characters are encountered
;	then continue with next IL instruction.
;
;
IFDONE:	CALL	READ_CHAR
	CJNE	CHAR,#':',IFDN_1	;Colon indicates resume interpretation.
	RET			;Return to IL.
;
IFDN_1:	CJNE	CHAR,#CR,IFDN_2	;Any non-colon, non-CR characters are illegal.
	RET
;
IFDN_2:	SETB	CHAR_FLG
	SETB	C
	RET
;
;=======

;$EJECT
READ_LABEL:
;	Read next two characters from program buffer into <LABL_H><LABL_L>.
;	Return with carry set if bit 15 of LABL is set (indicating EOF).
;
	CALL	READ_CHAR
	MOV	LABL_H,A
	CALL	READ_CHAR
	MOV	LABL_L,A
	MOV	A,LABL_H
	MOV	C,ACC.7
	RET
;
;=======
;
;
L_INIT:
;	Initialize for execution of new BASIC source line.
;	If none present, or if not in sequential execution mode, 
;	then return to line collection operation.
;
	JNB	RUNMOD,LINI_1	;Determine operating mode.
	JMP	READ_LABEL
;
LINI_1:	SETB	C
	RET
;
;=======
;
;
;
NL_NXT:
;	Output a <CR><LF> and continue with NXT routine.
;
	CALL	NLINE
;
NXT:
;	A colon or carriage return has been previously READ_CHARed.
;	If CHAR holds a colon,
;	continue interpretation of source line in current mode
;	from IL program instruction "TOKEN".
;	Otherwise CHAR is a <CR>, and line has been completed.
;	Resume execution from IL instruction "STMT".
;
	CJNE	CHAR,#':',NXT_1	;Skip ahead unless colon detected.
	CALL	D_BLNK
	JMP	TOKEN		;Continue with interpretation.
;
NXT_1:	JMP	STMT
;
;=======
;
;$EJECT
;
;
GETLN:
;	Input a line from console input device and put in line buffer
;	in internal RAM.
;
	MOV	A,AESP
	ADD	A,#4
	MOV	TMP0,A
GETL_0:	MOV	R0,TMP0		;Point to beginning of line buffer.
	CALL	STROUT
        DB      ('>' OR 80H)
GETL_1:	CALL	C_IN		;Get next character from console.
	CJNE	A,#12H,GETL_5	;Re-type line on <CNTRL-R>.
	CALL	STROUT
        DB      (CR OR 80H)     ;Newline.
	MOV	CURS_L,R0	;Save old value of cursor.
	MOV	R0,TMP0		;Start at beginning of line buffer.
GETL_6:	MOV	A,R0		;Check if re-write done.
	XRL	A,CURS_L
	JZ	GETL_1		;Continue with line input.
	MOV	A,@R0		;Load character to re-write.
	CALL	C_OUT
	INC	R0
	SJMP	GETL_6		;Continue until done.
;
GETL_5:	CJNE	A,#18H,GETL_7	;Cancel whole line on <CNTRL-X>.
	CALL	STROUT
        DB      '#',(CR OR 80H) ;Advance to next line.
	SJMP	GETL_0
;
GETL_7:	CJNE	A,#7FH,GETL_3
	MOV	A,R0
	CJNE	A,TMP0,GETL_4	;Delete previous character (if any).
	CALL	STROUT
        DB      (BEL OR 80H)    ;Echo <BEL>.
	SJMP	GETL_1		;Ignore rubouts at beginning of line
;
GETL_4:	CALL	STROUT
	DB	08H,' ',88H	;BKSP,SPC,BKSP
	DEC	R0		;Wipeout last char.
	SJMP	GETL_1
;
GETL_3:	CJNE	R0,#AES+AESLEN-1,GETL_2	;Test if buffer full.
	CALL	STROUT		;Echo <BEL>.
        DB      (BEL OR 80H)
	SJMP	GETL_1		;If so, override character received.
;
GETL_2:	MOV	@R0,A		;Store into line buffer.
	CALL	C_OUT		;Echo character.
	INC	R0		;Bump pointer.
	CJNE	A,#CR,GETL_1	;Repeat for next character.
	MOV	PNTR_L,TMP0	;Point cursor to beginning of line buffer.
	CLR	CHAR_FLG
	RET
;
;===============
;
;
PRN:
;	Pop top of arithmetic expression stack (AES), 
;	convert to decimal number,
;	and print to console output device, suppressing leading zeroes.
;
	CLR	SGN_FLG
	CALL	IABS
	CALL	POP_TOS
PRNTOS:	SETB	ZERSUP		;Set zero suppression flag.
	CLR	A
	MOV	TMP0,A
	MOV	LP_CNT,#16	;Conversion precision.
	JB	HEXMOD,PRNHEX
	JNB	SGN_FLG,PRN_1	;Skip ahead if positive number.
	CALL	STROUT		;Output minus sign if negative.
        DB      ('-' OR 80H)
PRN_1:	XCH	A,TOS_L
	RLC	A
	XCH	A,TOS_L
	XCH	A,TOS_H
	RLC	A
	XCH	A,TOS_H
	XCH	A,TMP0
	ADDC	A,ACC
	DA	A
	XCH	A,TMP0
	ADDC	A,ACC
	DA	A
	DJNZ	LP_CNT,PRN_1
	MOV	TOS_H,A
	MOV	A,TOS_L
	RLC	A
	MOV	TOS_L,TMP0
PRNHEX:	CALL	NIBOUT
	MOV	A,TOS_H
	SWAP	A
	CALL	NIBOUT		;Print second digit.
	MOV	A,TOS_H
	CALL	NIBOUT		;Print third digit.
	JNB	HEXMOD,PRNH_1
	CLR	ZERSUP		;Print out last two chars. (at least) in hex.
PRNH_1:	MOV	A,TOS_L		;Read into Acc.
	SWAP	A		;Interchange nibbles.
	CALL	NIBOUT		;Print fourth digit.
	CLR	ZERSUP
	MOV	A,TOS_L		;Reload byte.
	CALL	NIBOUT		;Print last digit.
	JNB	HEXMOD,PRNRET
	CALL	STROUT		;Print trailing "H".
        DB      ('H' OR 80H)
PRNRET:	RET
;
;===============
;
LSTLIN:
;	Check Label of Program line pointed to by Cursor.
;	If legal, print line number, source line, and <CR><LF> to console,
;	adjust Cursor to start of next line, 
;	and return with carry set.
;	Else return with carry cleared.
;
	CALL	READ_LABEL
	JC	LSTL_1
	MOV	TOS_H,LABL_H
	MOV	TOS_L,LABL_L
	CLR	SGN_FLG
	CALL	PRNTOS
	CALL	STROUT		;Insert space before user's source line.
        DB      (' ' OR 80H)
LSTL_2:	CALL	READ_CHAR
	CALL	C_OUT
	CJNE	A,#CR,LSTL_2
LSTL_1:	RET
;
;===============
;
;LST
;	List the contents of the program memory area.
;
;
LST:	SETB	RUNMOD
	CALL	REWIND		;Point to first char of external buffer.
LST_1:	CALL	CNTRL
	JC	LSTRET
	CALL	LSTLIN		;Print out current line if present.
	JNC	LST_1		;Repeat if successful.
LSTRET:	CLR	RUNMOD
	RET
;
;===============
;
;
INNUM:
;	Read a numeric character string from the console input device.
;	Convert to binary value and push onto arithmetic expression stack.
;	Report error if illegal characters read.
;
	CLR	SGN_FLG		;Assume number will be positive.
	CALL	STROUT
        DB      ':',(' ' OR 80H);Print input prompt.
INUM_0:	CALL	C_IN
	CALL	C_OUT		;Echo input
	CJNE	A,#' ',INUM_3
	SJMP	INUM_0
;
INUM_3:	CJNE	A,#'+',INUM_4
	SJMP	INUM_0
;
INUM_4:	CJNE	A,#'-',INUM_5
	CPL	SGN_FLG
	SJMP	INUM_0
;
INUM_5:	CALL	CREATE		;Create value on stack if legal decimal digit.
	JNC	INUM_2		;Abort if first character received not legal.
INUM_1:	CALL	C_IN		;Get additional characters.
	CALL	C_OUT		;Echo input.
	CJNE	A,#7FH,INUM_6	;Start over if delete char detected.
INUM_2:	CALL	STROUT
        DB      '#',(CR OR 80H)
	SJMP	INNUM
;
INUM_6:	CALL	APPEND		;Incorporate into stack entry.
	JC	INUM_1		;Loop while legal characters arrive.
	CALL	PUSH_TOS
	JMP	NEG_IF_NEG
;
;===============
;$EJECT
RAM_INIT:
	CLR	A		;Many bytes to be cleared...
	MOV	MODE,A		;Interactive mode, decimal radix.
	MOV	FLAGS,A		;Interroutine flags.
DD010:  MOV     P2,#HIGH(EXTRAM);Select first External RAM page.
        MOV     R0,A
	MOV	A,#5AH		;Random bit pattern.
	MOVX	@R0,A
	MOVX	A,@R0
	XRL	A,#5AH
	JZ	EXTINI
	CLR	A
	MOV	R0,#US_VAR	;Clear variable array.
INIT_1:	MOV	@R0,A
	INC	R0
	CJNE	R0,#US_VAR+2*NO_VAR,INIT_1	;Loop until all vars cleared.
	SJMP	INIT_3
;
EXTINI:	SETB	EXTVAR
	CLR	A
	MOV	R0,A		;Clear variable array.
INIT_2:	MOVX	@R0,A
	INC	R0
	CJNE	R0,#2*26,INIT_2	;Loop until all vars cleared.
INIT_3:	RET
;
;========
;
;INIT
;	Perform global initialization:
;	Clear program memory, empty all I/O buffers, reset all stack
;	pointers, etc.
;
;
INIT:	CALL	RAM_INIT
        MOV     R0,#LOW(EXTRAM)
	MOV	A,#0FFH
	MOVX	@R0,A
	RET
;
;===============
;
;$EJECT
;
;	BASIC PROGRAM LINE SEQUENCE CONTROL MACROS:
;	===== ======= ==== ======== ======= ======
;
;XINIT
;	Perform initialization needed before starting sequential execution.
;	Empty stacks, set BASIC line number to 1, etc.
;
;
XINIT:	MOV	AESP,#AES-1	;Initialize AE Stack.
	CALL	REWIND
	SETB	RUNMOD
	RET			;Begin execution.
;
;===============
;
FNDLBL:
;	Search program buffer for line with label passed on AES (Pop AES).
;	If found, return with CURSOR pointing to start of line (before label)
;	and carry cleared.
;	If not found return with carry set and pointer at start of first
;	line with a greater label value (possible EOF).
;
	SETB	RUNMOD		;Kludge to make GET_C fetch from prog. buffer.
	CALL	REWIND
	CALL	POP_TOS
FND_1:	CALL	SAVE_PNTR	;Store position of beginning of line.
	CALL	READ_LABEL
	JC	FNDDON
	MOV	A,TOS_L
	SUBB	A,LABL_L
	MOV	LABL_L,A	;Save non-zero bits.
	MOV	A,TOS_H
	SUBB	A,LABL_H
	ORL	A,LABL_L	;Test for non-zero bits.
	JZ	FNDDON
	JC	FNDDON		;Carry=1 if a greater label value found.
	CALL	SKPTXT		;Skip over remaining text portion of line.
	SJMP	FND_1
;
FNDDON:	JMP	LOAD_PNTR
;
;=======
;
KILL_L:
;	Kill (delete) line from code buffer indicated by pointer.
;	When called, CURSOR and POINTER hold the address of first LABEL byte of
;	line to be deleted.
;
	MOV	DEST_L,CURS_L
	MOV	DEST_H,CURS_H
	CALL	SKPLIN		;Pass pointer over full text line.
;
;	Pointer now indicates first label byte of following line.
;	Cursor and DEST still indicate first label byte of obsolete line.
;
KILL_2:	CALL	READ_CHAR	;Copy down first label byte.
	CALL	WRITE_CHAR	;Transfer first byte of label number.
	JB	ACC.7,KILL_9	;Quit when End of Code sentinel reached.
	CALL	READ_CHAR	;Copy down second label byte.
	CALL	WRITE_CHAR	;Store second byte of label number.
KILL_3:	CALL	READ_CHAR	;Transfer text character.
	CALL	WRITE_CHAR
	CJNE	A,#CR,KILL_3	;Loop until full line moved.
	SJMP	KILL_2		;Continue until all code moved forward.
;
KILL_9:	RET			;Full line now deleted.
;
;=======
;
OPEN_L:
;	Open space for new line in code buffer starting at Cursor.
;
	CALL	LOAD_PNTR	;Load address of point for insertion.
	CLR	CHAR_FLG
OPEN_3:	CALL	READ_CHAR	;Test first label byte of following line.
	JB	ACC.7,OPEN_4
	CALL	READ_CHAR	;Pass over next LABEL byte.
OPEN_5:	CALL	READ_CHAR
	CJNE	A,#CR,OPEN_5
	SJMP	OPEN_3
;
;	Pointer now indicates end-of-buffer sentinel.
;
OPEN_4:	MOV	A,STRLEN	;Number of bytes needed for BASIC text.
	ADD	A,#3		;Space needed for for label and <CR>.
	ADD	A,R0		;Low-order byte of old pointer.
	MOV	DEST_L,A
	CLR	A
	ADDC	A,PNTR_H
	MOV	DEST_H,A
        CJNE    A,#HIGH(RAMLIM),OPEN_1
	JMP	AES_ER
;
;	Transfer characters from source back to destination
;	until pointer at original CURSOR value.
;
OPEN_1:	CALL	GET_BUF		;Move back next character.
	CALL	PUT_BUF
	MOV	A,PNTR_L
	CJNE	A,CURS_L,OPEN_2
	MOV	A,PNTR_H
	CJNE	A,CURS_H,OPEN_2
;
;	All bytes have been moved back.
;
	RET
;
OPEN_2:
;	Decrement src. and dest. pointers and repeat.
;
	DEC	PNTR_L
	CJNE	PNTR_L,#0FFH,OPEN_6
	DEC	PNTR_H
OPEN_6:	DEC	DEST_L
	CJNE	DEST_L,#0FFH,OPEN_1
	DEC	DEST_H
	SJMP	OPEN_1		;Repeat for next character.
;
;=======
;
INSR_L:
;	Insert program line label (still held in <TOS_H><TOS_L> from earlier
;	call to FNDLBL)
;	and character string in line buffer (pointed at by L_CURS)
;	into program buffer gap created by OPEN_L routine
;	(still pointed at by CURSOR).
;
	MOV	DEST_L,CURS_L
	MOV	DEST_H,CURS_H
	MOV	A,TOS_H
	CALL	WRITE_CHAR
	MOV	A,TOS_L
	CALL	WRITE_CHAR
	MOV	PNTR_L,L_CURS
INSL_1:	MOV	A,@PNTR_L
	CALL	WRITE_CHAR
	INC	PNTR_L
	CJNE	A,#CR,INSL_1
	RET
;
;=======
;
;
INSRT:
;	Pop line number from top of arithmetic expression stack.
;	Search BASIC source program for corresponding line number.
;	If found, delete old line.
;	Otherwise position cursor before next sequential line number.
;	If line buffer is not empty then insert line number, contents of
;	line buffer, and line terminator.
;
	DEC	PNTR_L		;Since previous D_BLNK passed over first char.
	MOV	L_CURS,PNTR_L
	CALL	FNDLBL
	JC	INSR_1
	CALL	KILL_L		;Delete line iff label found in buffer.
INSR_1:	MOV	R1,L_CURS
	DEC	R1
INSR_2:	INC	R1
	MOV	A,@R1
	CJNE	A,#CR,INSR_2
	MOV	A,R1
	CLR	C
	SUBB	A,L_CURS
	MOV	STRLEN,A
	JZ	INSR_4
	CALL	OPEN_L
	CALL	INSR_L
INSR_4:	CLR	RUNMOD
	RET
;
;===============
;
;
COND:	CALL	POP_TOS
	MOV	A,TOS_L
	RRC	A
	RET
;
;=======
;
;XFER
;	Pop the value from the top of the arithmetic expression stack (AES).
;	Position cursor at beginning of the BASIC source program line
;	with that label and begin source interpretation.
;	(Report error if corresponding source line not found.)
;
;
XFER:	CALL	FNDLBL
	JC	XFERNG
	JMP	STMT		;Begin execution of source line.
;
XFERNG:	JMP	EXP_ER
;
;===============
;
;
SAV:
;	Push BASIC line number of current source line onto AES.
;
	MOV	TOS_H,LABL_H
	MOV	TOS_L,LABL_L
	JMP	PUSH_TOS
;
;===============
;
;
RSTR:
;	If AES is empty report a nesting error.
;	Otherwise, pop AES into current BASIC souce program line number.
;
	CALL	FNDLBL
	CALL	SKPLIN		;Pass over statement initiating transfer.
	JMP	STMT
;
;===============
;
;
LOOP:
;	LOOP is called with the AES holding:
;	(TOS:)	2 byte VALUE of variable after being incremented,
;		2 byte INDEX of variable being incremented,
;		1 byte TYPE of variable code,
;		2 byte LABEL of line initiating FOR loop,
;		2 byte LIMIT specified by FOR statement,
;		2 byte INDEX of variable used by FOR loop,
;		1 byte TYPE of variable code.
;	If indices disagree, then generate syntax error.
;	Otherwise, store incremented value in variable popping both from AES.
;	If the incremented value <= LIMIT then return with carry set.
;	If incr. val. > LIMIT looping is done, so return with carry not set.
;
;	Compare all three bytes of variable index.
	MOV	A,R0
	PUSH	ACC
	MOV	A,AESP
	ADD	A,#-2
	MOV	R1,A
	ADD	A,#-7
	MOV	R0,A
	MOV	LP_CNT,#3	;Set to test three bytes.
LOOP_0:	MOV	A,@R1
	XRL	A,@R0
	JNZ	LOOP_1
	DEC	R0
	DEC	R1
	DJNZ	LP_CNT,LOOP_0
;
;	All three bytes of variable code match.
	POP	ACC
	MOV	R0,A
	CALL	STORE
	MOV	A,AESP
	ADD	A,#-3
	MOV	R1,A
	CLR	C
	MOV	A,@R1
	SUBB	A,TMP0
	INC	R1
	MOV	A,@R1
	JB	HEXMOD,LOOP_2	;Branch forward if unsigned compare correct.
	XRL	A,#80H		;Adjust sign bits so signed compare valid.
	XRL	TMP1,#80H
LOOP_2:	SUBB	A,TMP1
	RET
;
;	Indices don't match.
;
LOOP_1:	POP	ACC
	MOV	R0,A
	JMP	SYN_ER
;
;=======
;
;FIN
;	Return to line collection routine.
;
;
FIN:	CLR	RUNMOD
	JMP	CONT		;Return to line collection mode.
;
;===============
;
;$EJECT
;
;	IL SEQUENCE CONTROL INSTRUCTIONS:
;	== ======== ======= ============
;
;IJMP	(LBL)
;	Jump to the (potentially distant) IL instruction at location LBL.
;Note:	In this implementation IL addresses are equivalent to machine
;	language addresses, so IJMP performs a generic JMP.
;
;
;===============
;
;HOP	(LBL)
;	Perform a branch to the IL instruction at (nearby) location LBL.
;Note:	In this implementation IL addresses are equivalent to machine
;	language addresses, so HOP performs a simple relative SJMP.
;
;
;===============
;
;ICALL	(LBL)
;	Call the IL subroutine starting at instruction LBL.
;	Save the location of the next IL instruction on the control stack.
;Note:	In this implementation, IL addresses are identical with 
;	machine language addresses, and are saved on the MCS-51 hardware stack.
;
;
;===============
;
;IRET
;	Return from IL subroutine to location on top of control stack.
;Note:	In this implementation, IL addresses are identical with machine 
;	language addresses, which are saved on the hardware stack.
;
;
;===============
;
;MLCALL
;	Call the ML subroutine starting at the address on top of AES.
;
;
MLCALL:	MOV	R1,AESP
	MOV	B,@R1
	DEC	R1
	MOV	A,@R1
	DEC	R1
	MOV	AESP,R1
	PUSH	ACC
	PUSH	B
	ORL	PSW,#00011000B	;Select RB3.
	RET			;Branch to user routine.
;
;=======
;$EJECT
;$RESTORE
;
;	STATEMENT EXECUTOR WRITTEN IN IL (INTERPRETIVE LANGUAGE)
;	OPERATIONS IMPLEMENTED BY ASM51 MPL MACRO PROCESSING LANGUAGE
;			(8/11/80)
;
CMD_NG:	JMP	SYN_ER
;
START:  CALL    INIT
ERRENT:	CLR	RUNMOD
	MOV	SP,#SP_BASE	;Re-initialize hardware stack.
	MOV	AESP,#AES-1	;Initialize AES pointer.
CONT:	CALL	STROUT
        DB      'OK',(CR OR 80H)
CONT_1: CALL    GETLN          ;Receive interactive command line.
	CALL	D_BLNK
        TSTL_   TOKEN
        CALL    INSRT
        HOP_    CONT_1
;
;=======
;
XEC:    CALL    XINIT          ;Initialize for sequential execution.
STMT:   LINIT_          ;Initialize for line execution.
TOKEN:	CALL	CNTRL
	CALL	D_BLNK
        TSTV_   S0            ;Parse implied LET command.
;*        %TST    (SE4,=)
        call   tst
        db      ('=' OR 80H)
        jnc     se4
        HOP_    SE3
;
;*S0:     %TST    (S1,LET)                ;Parse explicit LET command.
s0:     call   tst
        db      'LE',('T' OR 80H)
        jnc     s1
        TSTV_   CMD_NG
;*        %TST    (CMD_NG,=)
        call   tst
        db      ('=' OR 80H)
        jnc     cmd_ng
SE3:    ICALL_  EXPR
;*        %TST    (SE3A,%1,)
        call   tst
        db      (',' OR 80H)            ;to match tb51.lst
        jnc     se3a
        CALL    SEQ_STORE
	CALL	IINC
        HOP_    SE3
;
SE3A:   CALL    DONE
	CALL	STORE
        JMP     NXT
;
SE4:    CALL    DONE           ;Process implied PRINT command.
	CALL	FETCH
        CALL    PRN
        JMP     NL_NXT
;
;=======
;
;*S1:     %TST    (S2,GOTO)               ;Parse GOTO command.
s1:     call   tst
        db      'GOT',('O' OR 80H)
        jnc     s2
        ICALL_  EXPR
        CALL    LNDONE
        JMP     XFER
;
;=======
;
;*S2:     %TST    (S3,GOSUB)              ;Parse GOSUB command.
s2:     call   tst
        db      'GOSU',('B' OR 80H)
        jnc     s3
        CALL    SAV
        ICALL_  EXPR
        CALL    LNDONE
        JMP     XFER
;
;=======
;
;*S3:     %TST    (S8,PRINT)              ;Parse PRINT command.
s3:     call   tst
        db      'PRIN',('T' OR 80H)
        jnc     s8
        IFDONE_ S6B
;*S3A:    %TST    (S3B,;)
s3a:    call   tst
        db      (';' OR 80H)
        jnc     s3b
        HOP_    S3A
;
;*S3B:    %TST    (S3C,%1,)
s3b:    call   tst
        db      (',' OR 80H)            ;to match TB51.LST
        jnc     s3c
        CALL    SPC
        HOP_    S3A
;
S3C:    IFDONE_ S6A
        TSTS_   S5
        ICALL_  EXPR
        CALL    PRN
;*S5:     %TST    (S5A,%1,)
s5:     call   tst
        db      (',' OR 80H)            ;to match TB51.LST
        jnc     s5a
        CALL    SPC
        HOP_    S3A
;
;*S5A:    %TST    (S6,;)
s5a:    call   tst
        db      (';' OR 80H)
        jnc     s6
        HOP_    S3A
;
S6:     CALL    DONE
S6B:    JMP     NL_NXT
;
S6A:    JMP     NXT
;
;=======
;
;*S8:     %TST    (S9,IF)         ;Parse IF command.
s8:     call   tst
        db      'I',('F' OR 80H)
        jnc     s9
        ICALL_  EXPR
;*        %TST    (S8A,THEN)
        call   tst
        db      'THE',('N' OR 80H)
        jnc     s8a
S8A:    COND_   S8B
        IJMP_   TOKEN         ;Continue parsing command.
;
S8B:    CALL    SKPTXT
        IJMP_   STMT
;
;=======
;
;*S9:     %TST    (S12,INPUT)             ;Parse INPUT command.
s9:     call   tst
        db      'INPU',('T' OR 80H)
        jnc     s12
S10:    TSTS_   S10B
        TSTV_   S10D
        CALL    INNUM
	CALL	STORE
;*S10B:   %TST    (S10C,;)
s10b:   call   tst
        db      (';' OR 80H)
        jnc     s10c
        HOP_    S10
;
;*S10C:   %TST    (S11,%1,)
s10c:   call   tst
        db      (',' OR 80H)            ;to match TB51.LST
        jnc     s11
        CALL    SPC
        HOP_    S10
;
S10D:   IJMP_   SYN_NG
;
S11:    CALL    DONE
        JMP     NL_NXT
;
;=======
;
;*S12:    %TST    (S13,RETURN)            ;Parse RETURN command.
s12:    call   tst
        db      'RETUR',('N' OR 80H)
        jnc     s13
        CALL    LNDONE
        JMP     RSTR
;
;=======
;
;*S13:    %TST    (S13A,CALL)             ;Machine language CALL.
s13:    call   tst
        db      'CAL',('L' OR 80H)
        jnc     s13a
        ICALL_  EXPR
        CALL    LNDONE
        MLCALL_
        JMP     NXT
;
;=======
;
;*S13A:   %TST    (S13B,FOR)
s13a:   call   tst
        db      'FO',('R' OR 80H)
        jnc     s13b
        TSTV_   FOR_ER
;*        %TST    (FOR_ER,=)
        call   tst
        db      ('=' OR 80H)
        jnc     for_er
        ICALL_  EXPR
	CALL	SEQ_STORE
;*        %TST    (FOR_ER,TO)
        call   tst
        db      'T',('O' OR 80H)
        jnc     for_er
        ICALL_  EXPR
        CALL    LNDONE
        CALL    SAV
        JMP     NXT
;
;=======
;
;*S13B:   %TST    (S13C,NEXT)
s13b:   call   tst
        db      'NEX',('T' OR 80H)
        jnc     s13c
        TSTV_   FOR_ER
        CALL    DONE
	CALL	SEQ_FETCH
	CALL	IINC
        NEXT_LOOP_      FORDON
	CALL	DUPL
        JMP     RSTR
;
FORDON:	CALL	POP_TOS
	CALL	POP_TOS
	CALL	POP_TOS
	CALL	POP_ACC
        JMP     NXT
;
;=======
;
FOR_ER: IJMP_   CMD_NG
;
;=======
;
;*S13C:   %TST    (S14,END)               ;Parse END command.
s13c:   call   tst
        db      'EN',('D' OR 80H)
        jnc     s14
        CALL    LNDONE
        JMP     FIN
;
;=======
;
;*S14:    %TST    (S15,LIST)              ;Parse LIST command.
s14:    call   tst
        db      'LIS',('T' OR 80H)
        jnc     s15
        IFDONE_ S14B
        ICALL_  EXPR
	CALL	FNDLBL
	CALL	LST_1
        IJMP_   CONT
;
S14B:   CALL    LST
        IJMP_   CONT
;
;=======
;
;*S15:    %TST    (S16,RUN)               ;Parse LIST command.
s15:    call   tst
        db      'RU',('N' OR 80H)
        jnc     s16
        CALL    LNDONE
        IJMP_   XEC
;
;=======
;
;*S16:    %TST    (S16A,NEW)
s16:    call   tst
        db      'NE',('W' OR 80H)
        jnc     s16a
        CALL    DONE
        IJMP_   START
;
;=======
;*S16A:   %TST    (S17,RESET)
s16a:   call   tst
        db      'RESE',('T' OR 80H)
        jnc     s17
        CALL    DONE
	JMP	0000H
;
;=======
;
;*S17:    %TST    (S17A,ROM)
s17:    call   tst
        db      'RO',('M' OR 80H)
        jnc     s17a
        CALL    DONE
	SETB	ROMMOD
	CLR	EXTMOD
        JMP     NXT
;
;*S17A:   %TST    (S17B,RAM)
s17a:   call   tst
        db      'RA',('M' OR 80H)
        jnc     s17b
        CALL    DONE
	CLR	ROMMOD
        JMP     NXT
;
;*S17B:   %TST    (S17C,PROM)
s17b:   call   tst
        db      'PRO',('M' OR 80H)
        jnc     s17c
        CALL    DONE
	SETB	ROMMOD
	SETB	EXTMOD
        JMP     NXT
;
;*S17C:   %TST    (S18,HEX)
s17c:   call   tst
        db      'HE',('X' OR 80H)
        jnc     s18
        CALL    DONE
	SETB	HEXMOD
        JMP     NXT
;
;*S18:    %TST    (S19,DECIMAL)
s18:    call   tst
        db      'DECIMA',('L' OR 80H)
        jnc     s19
        CALL    DONE
	CLR	HEXMOD
        JMP     NXT
;
;*S19:    %TST    (S20,REM)
s19:    call   tst
        db      'RE',('M' OR 80H)
        jnc     s20
        CALL    SKPTXT
        IJMP_   STMT
;
S20:    IJMP_   CMD_NG
;
;$EJECT
;
;	INTERPRETIVE LANGUAGE SUBROUTINES:
;	============ ======== ===========
;
EXPR:   ICALL_  AR_EXP
E0:     ICALL_  RELOP
	JNC	E5
        ICALL_  AR_EXP
        CALL    CMPR
        HOP_    E0
;
AR_EXP: ICALL_  TERM
;*E1:     %TST    (E2,+)
e1:     call   tst
        db      ('+' OR 80H)
        jnc     e2
        ICALL_  TERM
	CALL	IADD
        HOP_    E1
;
;*E2:     %TST    (E3,-)
e2:     call   tst
        db      ('-' OR 80H)
        jnc     e3
        ICALL_  TERM
	CALL	ISUB
        HOP_    E1
;
;*E3:     %TST    (E4,OR)
e3:     call   tst
        db      'O',('R' OR 80H)
        jnc     e4
        ICALL_  TERM
	CALL	IOR
        HOP_    E1
;
;*E4:     %TST    (E5,XOR)
e4:     call   tst
        db      'XO',('R' OR 80H)
        jnc     e5
        ICALL_  TERM
	CALL	IXOR
        HOP_    E1
;
E5:     RET
;
;=======
;
TERM:   ICALL_  FACT
;*TERM_0: %TST    (TERM_1,*)
term_0: call   tst
        db      ('*' OR 80H)
        jnc     term_1
        ICALL_  FACT
	CALL	IMUL
        HOP_    TERM_0
;
;*TERM_1: %TST    (TERM_2,/)
term_1: call   tst
        db      ('/' OR 80H)
        jnc     term_2
        ICALL_  FACT
	CALL	IDIV
        HOP_    TERM_0
;
;*TERM_2: %TST    (TERM_3,AND)
term_2: call   tst
        db      'AN',('D' OR 80H)
        jnc     term_3
        ICALL_  FACT
	CALL	IAND
        HOP_    TERM_0
;
;*TERM_3: %TST    (TERM_4,MOD)
term_3: call   tst
        db      'MO',('D' OR 80H)
        jnc     term_4
        ICALL_  FACT
	CALL	IMOD
        HOP_    TERM_0
;
TERM_4: RET
;
;=======
;
;*FACT:   %TST    (FACT_1,-)
fact:   call   tst
        db      ('-' OR 80H)
        jnc     fact_1
        ICALL_  VAR
	CALL	NEG
        RET
;
;*FACT_1: %TST    (VAR,NOT)
fact_1: call   tst
        db      'NO',('T' OR 80H)
        jnc     var
        ICALL_  VAR
	CALL	ICPL
        RET
;
;
;=======
;
VAR:    TSTV_   VAR_0
	CALL	FETCH
        RET
;
VAR_0:  TSTN_   VAR_1
        RET
;
;*VAR_1:  %TST    (VAR_1A,RND)
var_1:  call   tst
        db      'RN',('D' OR 80H)
        jnc     var_1a
        CALL    RND
        ICALL_  VAR_2
	CALL	IMOD
	CALL	IABS
	CALL	IINC
        RET
;
;*VAR_1A: %TST    (VAR_2,ABS)
var_1a: call   tst
        db      'AB',('S' OR 80H)
        jnc     var_2
        ICALL_  VAR_2
	CALL	IABS
        RET
;
;*VAR_2:  %TST    (SYN_NG,%1()
var_2:  call   tst
        db      ('(' OR 80H)            ;to match TB51.LST
        jnc     syn_ng
        ICALL_  EXPR
;*        %TST    (SYN_NG,%1))
        call   tst
        db      (')' OR 80H)            ;to match TB51.LST
        jnc     syn_ng
        RET
;
;=======
;
SYN_NG: IJMP_   CMD_NG
;
;$EJECT
;
RELOP:
;	Search for relational operator in text string.
;	If found, push appropriate operator code on AES and return with
;	carry set.
;	Otherwise restore cursor and return with carry=0.
;
;*        %TST    (REL_1,=)
        call   tst
        db      ('=' OR 80H)
        jnc     rel_1
        LIT_    010B            ;Test for _=_
        RET
;
;*REL_1:  %TST    (REL_2,<=)
rel_1:  call   tst
        db      '<',('=' OR 80H)
        jnc     rel_2
        LIT_    110B            ;Test for <=_
        RET
;
;*REL_2:  %TST    (REL_3,<>)
rel_2:  call   tst
        db      '<',('>' OR 80H)
        jnc     rel_3
        LIT_    101B            ;Test for <_>
        RET
;
;*REL_3:  %TST    (REL_4,<)
rel_3:  call   tst
        db      ('<' OR 80H)
        jnc     rel_4
        LIT_    100B            ;Test for <__
        RET
;
;*REL_4:  %TST    (REL_5,>=)
rel_4:  call   tst
        db      '>',('=' OR 80H)
        jnc     rel_5
        LIT_    011B            ;Test for _=>
        RET
;
;*REL_5:  %TST    (REL_6,>)
rel_5:  call   tst
        db      ('>' OR 80H)
        jnc     rel_6
        LIT_    001B            ;Test for __>
        RET
;
REL_6:	CLR	C
        RET
;
;=======
;
;$EJECT
;$LIST
;
	INC	R7		;Dummy ML program.
	MOV	P1,R7
	RET
;
INTROM:				;Start of ROM program buffer.
;$INCLUDE(TBACEY.SRC)
        dw      2101
        db      'PR."Hello"',CR
        dw      2102
        db      'PR."This is being run under Tiny Basic V2.3"',CR
        dw      3040
        db      'PR.:IN."TYPE anything TO END PROGRAM",D',CR
        dw      3050
        db      'PR."Have fun!!.....J Lum  4/25/92"',CR
        dw      3060
        db      'END',CR
	DB	80H		;Marks end of program.
;
	END

