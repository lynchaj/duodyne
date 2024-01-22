; Typewriter for SAB80535 dev board
; assumes 6.0000 MHz clock
; 1200,8N1

.ORG 0000H
				;initialize serial port
	MOV	TMOD,#20H	;Timer 1, mode 2 (auto-reload)
	MOV	TH1,#0F3H	;1200 baud rate
	MOV	SCON,#50H	;8-bit, 1 stop, REN enabled
	SETB	TR1		;start Timer 1
	
				;receive a character from serial port
RECV:	JNB	RI,RECV		;wait for char to come in
	MOV	A,SBUF		;save incoming byte in A
	CLR	RI		;get ready to receive next byte
		
	MOV	SBUF,A		;transmit character stored in A
TRANS:	JNB	TI,TRANS	;wait for the last bit
	CLR	TI		;clear TI for the next char
	SJMP	RECV		;get another character and do again

.END

