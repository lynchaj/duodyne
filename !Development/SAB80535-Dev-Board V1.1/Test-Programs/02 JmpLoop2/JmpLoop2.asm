.ORG 0000H

SELF:	MOV P1, #255 ;//move 11111111 to the p1 register//
	MOV P1, #000 ;//move 00000000 to the p1 register//
	SJMP SELF

.END

