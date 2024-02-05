.ORG 0000H

TOGLE:	MOV P2, #0FFH ;//move 11111111 to the p2 register//
	ACALL DELAY ;//execute the delay//
	MOV A, P2 ;//move p2 value to the accumulator//
	CPL A ;//complement A value //
	MOV P2, A ;//move 00000000 to the port2 register//
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

