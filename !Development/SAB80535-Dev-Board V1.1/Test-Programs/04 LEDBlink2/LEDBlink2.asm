.ORG 0000H

TOGLE:	MOV P1, #01 ;//move 00000001 to the p1 register//
	ACALL DELAY ;//execute the delay//
	MOV A, P1 ;//move p1 value to the accumulator//
	CPL A ;//complement A value //
	MOV P1, A ;//move 11111110 to the port1 register//
	ACALL DELAY ;//execute the delay//
	SJMP TOGLE

DELAY:	MOV R5, #10H ;//load register R5 with 10//
TWO:	MOV R6, #200 ;//load register R6 with 200//
ONE:	MOV R7, #200 ;//load register R7 with 200//
ZERO:	DJNZ R7, ZERO ;//decrement R7 till it is zero//
	DJNZ R6, ONE ;//decrement R6 till it is zero//
	DJNZ R5, TWO ;//decrement R5 till it is zero//
	RET ;//go back to the main program //

.END

