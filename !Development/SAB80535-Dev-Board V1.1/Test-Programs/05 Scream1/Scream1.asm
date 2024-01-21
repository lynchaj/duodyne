; Scream for SAB80535 dev board
; assumes 6.0000 MHz clock
; 1200,8N1

.ORG 0000H

	MOV	TMOD,#20H	;Timer 1, mode 2 (auto-reload)
	MOV	TH1,#0F3H	;1200 baud rate
	MOV	SCON,#50H	;8-bit, 1 stop, REN enabled
	SETB	TR1		;start Timer 1
AGAIN:	MOV	SBUF,#'A'	;letter "A" to be transferred
HERE:	JNB	TI,HERE		;wait for the last bit
	CLR	TI		;clear TI for the next char
	SJMP	AGAIN		;keep sending A

.END

