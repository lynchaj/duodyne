; ascii.asm
;
CTRL            equ     1Fh     ; masks a character to CTRL-x

NUL     equ     00h
BEL     equ     (CTRL & 'G')
BS      equ     08h		; ^H
HT      equ     09h		; ^I
LF	equ	0Ah		; ^J
NL      equ     LF
VT	equ	0Bh		; ^K
FWD	equ	0Ch		; ^L
CR	equ	0Dh
XON     equ     (CTRL & 'Q')
XOFF    equ     (CTRL & 'S')
DC1     equ     XON
DC3     equ     XOFF
ESC     equ	1Bh


