;Eventual Feature set:
;Single step
;single step Jump over call
;step over repeat?
;breakpoint
;Block dump
;Register dump
;Alter registers
;io In
;io Out
	DOSSEG
	.MODEL	small
	.186

MAXBREAKPOINT	EQU	10		;maximum number of breakpoints
INT0		EQU	0*4		;interrupt 0 (DIV0) address
INT1		EQU	1*4		;interrupt 1 (SINGLE) address
INT3		EQU	3*4		;interrupt 3 (BREAKPT) address
INT61		EQU	61H*4		;interrupt 61 (FREDOS) address

	.CODE
	JMP	near ptr ColdBoot

	assume cs:@code,ds:@data

extrn	UNASM:NEAR
extrn	DosInt:NEAR

	public	Cmd0
	public	PrintString
	public	PrintStringCS
	public	PrintNewLine
	public	PrintHexByte
	public	BP_TRAP
	public	U_IP
	public	EnableDebug

Prompt		DB	13,10,'db>',0
BadCommand	DB	13,10,'Illegal command',0
StartAdr	db	13,'Address: ',0
RS11		db	13,10,'cs:ip=',0
RS12		db	' ax=',0
RS13		db	' bx=',0
RS14		db	' cx=',0
RS15		db	' dx=',0
RS16		db	' bp=',0
RS17		db	' flags=',0
RS20		db	13,10,'ds:si=',0
RS21		db	'  es:di=',0
RS22		db	'  ss:sp=',0

Commands	db	13,10,'Available commands: ',0
ExitMsg		db	13,10,'Exiting fred simulation',13,10,0
O_DS		DW	SEG @data
O_SP		DW	OFFSET U_AX+2
O_SS		DW	SEG STACK

	.DATA
EVEN
O_STACK		DW	256 DUP (?)
U_ES		DW	?
U_DI		DW	?
U_SI		DW	?
U_BP		DW	?
		DW	?		;our sp before pusha
U_BX		DW	?
U_DX		DW	?
U_CX		DW	?
U_AX		DW	?
U_FLAG		DW	?
U_IP		DW	?
U_CS		DW	?
U_DS		DW	?
U_SP		DW	?
U_SS	 	DW	?

SCR_OFF		DW	?	;scratch offset, segment
SCR_SEG		DW	?

trapvect	dw	?
BREAKTAB	db	5*MAXBREAKPOINT DUP (?)	;breakpoint table
BrkCount	dw	0

	.CODE

;************************************************************************
; trap vectors
;************************************************************************
DIV0_TRAP:
	push	0			;Divide by zero entry
	jmp	short saveAll
SINGLE_TRAP:
	push	1			;Single Step entry
	jmp	short saveAll
BP_TRAP:
	push	3			;Breakpoint entry
	jmp	short saveAll
saveAll:		     	
	PUSH	DS
	MOV	DS,CS:O_DS
	POP	DS:U_DS
	POP	DS:trapvect
	POP	DS:U_IP
	POP	DS:U_CS
	POP	DS:U_FLAG
	AND	DS:U_FLAG,0EFH			;clear single step flag
	MOV	DS:U_SS,SS
	MOV	DS:U_SP,SP
	MOV	SS,O_SS
	MOV	SP,O_SP
	PUSHA					;save general registers
	PUSH	ES				;save es
	STI					;enable interrupts
	CLD				;DIRETION FLAG
	MOV	BP,SP			;FRAME POINTER (TO VARIABLES)
	SUB	SP,20h			;ROOM FOR 20 LOCALS
;restore breakpoint vectors
	mov	bx,offset BREAKTAB	;breakpoint table
	mov	cx,DS:BrkCount		;number of breakpoints set
	jcxz	RBrkptEnd

RBrkpt:
	les	di,[bx]			;fetch address
	mov	al,[bx+4]		;byte to restore
	stosb
	add	bx,5
	loop	RBrkpt

RBrkptEnd:
	les	DI,DWORD PTR U_IP
	mov	SCR_OFF,DI
	mov	SCR_SEG,ES
	Jmp	near ptr ShowRegs

;************************************************************************
; restore to user
;************************************************************************
SSTEP:
	OR	DS:U_FLAG,100h		;SET SINGLE STEP TRAP

;return to user program
GoNonStop:
ReturnUser:
	mov	bx,offset BREAKTAB	;breakpoint table
	mov	cx,BrkCount		;number of breakpoints set
	jcxz	SBrkptEnd

	mov	al,0CCH			;int 3 instruction
SBrkpt:
	les	di,[bx]			;fetch address
	mov	ah,es:[di]		;get byte currently there
	mov	[bx+4],ah		;byte to restore
	stosb				;save int3 instruction
	add	bx,5
	loop	RBrkpt

SBrkptEnd:

	MOV	SP,BP			;DROP LOCAL VARIABLES
	POP	ES			;restore ES
	POPA				;restore general registers
	CLI				;disable interrupts
	MOV	SS,DS:U_SS		;restore user's stack
	MOV	SP,DS:U_SP
	PUSH	DS:U_FLAG		;restore 'int' stack frame
	PUSH	DS:U_CS
	PUSH	DS:U_IP
	MOV	DS,DS:U_DS		;restore ds
	IRET				;and return

;**************************************************************************
;desc:	Read a key from the keyboard
;return:
;	al - character
;	ah - scan code
;**************************************************************************
GetKey	Proc	Near
	MOV	ax,0
	int	16H
	ret
GetKey	endp

;**************************************************************************
;desc:	Read a string from the keyboard
;	ds:si - pointer to string buffer
;	ds:si[0] - maximum length of string
;return:
;	ds:si[1] - length of string returned (excluding cr)
;	ds:si[2...] - returned string
;**************************************************************************
GetString	proc	near
	push	si
	xor	bx,bx		;index to string
	mov	cl,[si]		;get maximum length
	add	si,2
	call	GetChar
	cmp	al,0dH		;end of string?
	je	GetStrEnd

GetStrEnd:
	pop	si
	mov	[si+1],bl	;return string length
	ret
GetString	endp

;**************************************************************************
;desc:	Read an address from the keyboard
;	if only an offset is given, the segment is set to the user's DS
;return:
;	dx:ax - address
;	bx,cx destroyed
;**************************************************************************
GetAddr	Proc	Near
	xor	bx,bx		;the address offset
	mov	bx,cx		;number of digits entered
	mov	dx,word ptr U_DS	;default address segment

;	call	GetKey
;	cmp	al,':'
	ret
GetAddr	endp

;**************************************************************************
;desc:	PrintHexWord/Byte/Nybble
;in:	ax/al with value to print
;return:
;	ax destroyed
;**************************************************************************
PrintHexWord	Proc	Near
	push	ax
	mov	al,ah
	call	PrintHexByte
	pop	ax
PrintHexByte:
	push	ax
	shr	al,1
	shr	al,1
	shr	al,1
	shr	al,1
	call	PrintHexNyb
	pop	ax
PrintHexNyb:
	and	al,0FH
	cmp	al,09
	jle	Pxb1
	add	al,'A'-'9'-1
Pxb1:
	add	al,'0'
	mov	ah,14
	int	10H
	ret
PrintHexWord	Endp

;*************************************************************************
;desc: Print Multiple Spaces
;input:	ax = count of spaces (ax=0 is maximum count)
;	ax destroyed
;*************************************************************************
PrintSpaces:
	push	ax
	mov	ax,0e20H
	int	10H
	pop	ax
	dec	ax
	jnz	PrintSpaces
	ret

;*************************************************************************
;desc: Print Space
;	ax destroyed
;*************************************************************************
PrintSpace:
	mov	ax,0e20H
	int	10H
	ret

;*************************************************************************
;desc: Print Character
;	ax destroyed
;*************************************************************************
PrintChar:
	mov	ah,0eH
	int	10H
	ret

;*************************************************************************
;desc: Print Colon
;	ax destroyed
;*************************************************************************
PrintColon:
	mov	ax,0e00H+':'
	int	10H
	ret

;*************************************************************************
;desc: Print NewLine
;	ax destroyed
;*************************************************************************
PrintNewLine:
	mov	ax,0e0dH
	int	10H
	mov	ax,0e0aH
	int	10H
	ret

;*************************************************************************
;desc: Print null terminated string
;in:	ds:si points to null terminated string
;*************************************************************************
PrintString	Proc	Near
	push	ax
PS1:
	lodsb
	or	al,al
	je	PSEnd
	mov	ah,14			;write tty
	int	10H
	jmp	short PS1
PSEnd:
	pop	ax
	ret
PrintString	Endp

;*************************************************************************
;desc: Print null terminated string
;in:	cs:si points to null terminated string
;*************************************************************************
PrintStringCS	Proc	Near
	push	ax
PSCS1:
	lods	byte ptr cs:[si]
	or	al,al
	je	PSCSEnd
	mov	ah,14			;write tty
	int	10H
	jmp	short PSCS1
PSCSEnd:
	pop	ax
	ret
PrintStringCS	Endp

;************************************************************************
; main debug command loop
;************************************************************************
Cmd0:
	LEA	SI,Prompt
	call	PrintStringCS
	call	GetKey
	xor	bx,bx
	mov	cx,CommandMax
Cmd1:
	cmp	al,byte ptr cs:Command[bx]
	je	Cmd2
	inc	bx
	loop	Cmd1
	lea	SI,BadCommand
	Call	PrintStringCS
	Jmp	Short Cmd0

Cmd2:
	shl	bx,1
	Jmp	cs:CmdTable[bx]

DumpMem:
	lea	si,StartAdr
	call	PrintStringCS
	call	GetAddr
	les	si,DWORD PTR SCR_OFF	;load the address
	and	si,0FFF0H		;round to nearest paragraph
	mov	cx,8			;5 lines of dump
	call	PrintNewLine

DM1:	push	cx
	mov	ax,es
	call	PrintHexWord
	call	PrintColon
	mov	ax,si
	call	PrintHexWord
	call	PrintSpace
	mov	cx,16			;number of bytes to dump
	push	si
DM2:	lods	byte ptr es:[si]	;print hex value of byte
	call	PrintHexByte
	call	PrintSpace
	loop	DM2

	pop	si
	mov	cx,16
	mov	ax,3
	call	PrintSpaces
DM3:	lods	byte ptr es:[si]
	cmp	al,' '
	jge	DM4
	mov	al,'.'			;unprintable character

DM4:	call	PrintChar
	loop	DM3
	call	PrintNewLine
	pop	cx
	loop	DM1

	mov	SCR_OFF,SI		;save updated scratch register
	mov	SCR_SEG,ES

	jmp	NEAR PTR Cmd0

UnAsmBlock:
	call	PrintNewLine
	les	di,DWORD PTR SCR_OFF
	mov	cx,5
UnAsmBlk1:
	push	cx
	call	UnAsm
	pop	cx
	loop	UnAsmBlk1
	mov	SCR_OFF,DI		;save updated scratch register
	mov	SCR_SEG,ES
	jmp	near ptr Cmd0
	
ShowRegs:
	lea	si,RS11
	call	PrintStringCS
	mov	ax,U_CS
	call	PrintHexWord
	call	PrintColon
	mov	ax,U_IP
	call	PrintHexWord
	lea	si,RS12
	call	PrintStringCS
	mov	ax,U_AX
	call	PrintHexWord
	lea	si,RS13
	call	PrintStringCS
	mov	ax,U_BX
	call	PrintHexWord
	lea	si,RS14
	call	PrintStringCS
	mov	ax,U_CX
	call	PrintHexWord
	lea	si,RS15
	call	PrintStringCS
	mov	ax,U_DX
	call	PrintHexWord
	lea	si,RS16
	call	PrintStringCS
	mov	ax,U_BP
	call	PrintHexWord
	lea	si,RS17
	call	PrintStringCS
	mov	ax,U_FLAG
	call	PrintHexWord
	lea	si,RS20
	call	PrintStringCS
	mov	ax,U_DS
	call	PrintHexWord
	call	PrintColon
	mov	ax,U_SI
	call	PrintHexWord
	lea	si,RS21
	call	PrintStringCS
	mov	ax,U_ES
	call	PrintHexWord
	call	PrintColon
	mov	ax,U_DI
	call	PrintHexWord
	lea	si,RS22
	call	PrintStringCS
	mov	ax,U_SS
	call	PrintHexWord
	call	PrintColon
	mov	ax,U_SP
	call	PrintHexWord
	call	PrintNewLine

	les	di,DWORD PTR U_IP
	call	near ptr UNASM
	jmp	near ptr Cmd0

HelpMsg:
	lea	si,Commands
	call	PrintStringCS
	lea	si,Command
	call	PrintStringCS
	jmp	Near Ptr Cmd0

QUIT:
	lea	si,ExitMsg
	call	PrintStringCS
	call	DisableDebug
	MOV	ax,04c00H
	INT	21H

Command		db	'+qrdgu?',0
CommandMax	Equ	($-Command)-1
CmdTable	DW	SSTEP,QUIT,ShowRegs,DumpMem,GoNonStop,UnAsmBlock
		DW	HelpMsg


LoadFailed	db	13,'Cannot load program file',13,10,0
	.DATA
DebugOn		dw	0	;debug interrupts engaged flag
INT0_OLD	dd	?
INT1_OLD	dd	?
INT3_OLD	dd	?
INT61_OLD	dd	?
CMDLineParms	db	0,' ',0dh,125 dup (0)	;copy of command line parameters
pspseg		dw	?	;our psp
EXEC_BLOC	dw	0	;segment of environment string (inherit parent)
		dd	?	;pointer to command line
		dd	?	;pointer to FCB1
		dd	?	;pointer to FCB2

	.CODE
;**************************************************************************
;* set up code
;* link in trap vectors & jump to main program
;* in 186 version, this will initialize the system
;**************************************************************************
ColdBoot:
	mov	ds,cs:O_DS
	mov	pspseg,es			;save our psp segment

	xor	ax,ax				;point to trap vector
	mov	es,ax

	mov	bx,offset DosInt		;enable int61 dos replacement
	xchg	bx,word ptr es:[INT61]		;and save the old vector
	mov	word ptr [INT61_OLD],bx
	mov	bx,cs
	xchg	bx,word ptr es:[INT61+2]
	mov	word ptr [INT61_OLD+2],bx
;**************************************************************
;uncomment this next line to enable the debugger from startup.
;(i.e. Single step and Breakpoint traps)
;	call	EnableDebug

;MS dos specific meddlings
	mov	es,pspseg	;get our psp

	mov	bx,ss
	mov	ax,es
	sub	bx,ax		;compute size from psp to stack segment
	add	bx,50H		;add size of stack + caution space
	mov	ah,4aH		;resize ourselves
	INT	21H

;prepare to execute sub program
	lea	bx,EXEC_BLOC		;point to parameter block

	MOV	word ptr [bx].4,ds	;set segment values in control block
	MOV	word ptr [bx].8,es
	MOV	word ptr [bx].12,es

	mov	word ptr [bx].2,offset cs:CMDLineParms
	mov	word ptr [bx].6,5CH	;give them our FCB1
	mov	word ptr [bx].10,6CH	;    and our FCB2

	push	ds
	pop	es
	mov	ds,pspseg
	mov	cl,byte ptr ds:[80H]	;get length of parameter
	xor	ch,ch
	jcxz	BOOT0		;no name ...
	mov	dx,82H		;name of program to execute
	mov	si,dx

bt1:
	lodsb			;find end of string (to append zero)
	cmp	al,' '
	je	bt2

	cmp	al,0dH
	jne	bt1
bt2:
	mov	byte ptr -1[si],0	;zero terminate name

	mov	ax,4B00H	;load & execute program
	INT	21H

	cli
	mov	ds,cs:O_DS	;restore at least a few registers
	mov	ax,STACK	;(the most important)
	mov	ss,ax
	mov	sp,100H
	sti

	JNC	BOOT1
BOOT0:
	LEA	SI,LoadFailed	;complain
	call	PrintStringCS

BOOT1:				;restore original system vectors

	xor	ax,ax				;point to trap vector
	mov	es,ax

	mov	bx,word ptr [INT61_OLD]		;restore INT 61
	mov	word ptr es:[INT61],bx
	mov	bx,word ptr [INT61_OLD+2]
	mov	word ptr es:[INT61+2],bx

	jmp	near ptr QUIT

EnableDebug	Proc	Near
	mov	ds,cs:O_DS			;point to our data segment
	cmp	DebugOn,0
	jne	EnableEnd

	inc	DebugOn
	xor	ax,ax				;set trap vectors
	mov	es,ax
	mov	bx,offset DIV0_TRAP		;divide by zero trap
	xchg	bx,word ptr es:[INT0]
	mov	word ptr [INT0_OLD],bx
	mov	bx,cs
	xchg	bx,word ptr es:[INT0+2]
	mov	word ptr [INT0_OLD+2],bx

	mov	bx,offset SINGLE_TRAP		;single step trap
	xchg	bx,word ptr es:[INT1]
	mov	word ptr [INT1_OLD],bx
	mov	bx,cs
	xchg	bx,word ptr es:[INT1+2]
	mov	word ptr [INT1_OLD+2],bx

;	mov	bx,offset BP_TRAP		;breakpoint trap
;	xchg	bx,word ptr es:[INT3]
;	mov	word ptr [INT3_OLD],bx
;	mov	bx,cs
;	xchg	bx,word ptr es:[INT3+2]
;	mov	word ptr [INT3_OLD+2],bx

EnableEnd:
	ret

EnableDebug	Endp

DisableDebug	Proc	Near
	cmp	DebugOn,0
	je	DisableEnd

	dec	DebugOn
	xor	ax,ax			;restore trap vectors
	mov	es,ax
	mov	bx,word ptr [INT0_OLD]
	mov	word ptr es:[INT0],bx
	mov	bx,word ptr [INT0_OLD+2]
	mov	word ptr es:[INT0+2],bx

	mov	bx,word ptr [INT1_OLD]
	mov	word ptr es:[INT1],bx
	mov	bx,word ptr [INT1_OLD+2]
	mov	word ptr es:[INT1+2],bx

;	mov	bx,word ptr [INT3_OLD]
;	mov	word ptr es:[INT3],bx
;	mov	bx,word ptr [INT3_OLD+2]
;	mov	word ptr es:[INT3+2],bx

DisableEnd:
	ret

DisableDebug	Endp

	.STACK
	DW	100h DUP (?)
	END
