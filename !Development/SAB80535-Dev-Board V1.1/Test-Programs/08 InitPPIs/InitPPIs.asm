.ORG 8000H	;execute from RAM

				;PPI0
	MOV	A,#80H		;control word (ports output)
	MOV	DPTR,#0F803H	;load control reg port addr
	MOVX	@DPTR,A		;issue control word

				;PPI1	
	MOV	A,#80H		;control word (ports output)
	MOV	DPTR,#0F903H	;load control reg port addr
	MOVX	@DPTR,A		;issue control word
	
	MOV	A,#55H		;A=55H alternating bit pattern

AGAIN:				;PPI0
	MOV	DPTR,#0F800H	;PA address
	MOVX	@DPTR,A		;toggle PA bits
	INC	DPTR		;PB address
	MOVX	@DPTR,A		;toggle PB bits
	INC	DPTR		;PC address
	MOVX	@DPTR,A		;toggle PC bits

				;PPI1
	MOV	DPTR,#0F900H	;PD address
	MOVX	@DPTR,A		;toggle PD bits
	INC	DPTR		;PE address (status LEDs)
	MOVX	@DPTR,A		;toggle PE bits
	INC	DPTR		;PF address
	MOVX	@DPTR,A		;toggle PF bits

	CPL	A		;toggle bits in reg A
	ACALL	DELAY		;wait
	SJMP	AGAIN		;continue

DELAY:	MOV R5, #10H            ;load register R5 with 10
TWO:	MOV R6, #200            ;load register R6 with 200
ONE:	MOV R7, #200            ;load register R7 with 200
ZERO:	DJNZ R7, ZERO           ;decrement R7 till it is zero
	DJNZ R6, ONE            ;decrement R6 till it is zero
	DJNZ R5, TWO            ;decrement R5 till it is zero
	RET                     ;go back to the main program

.END

