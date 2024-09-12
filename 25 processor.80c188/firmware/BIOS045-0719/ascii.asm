; ascii.asm
;
CTRL            equ     1Fh     ; masks a character to CTRL-x

NUL     equ     00h
BEL     equ     (CTRL & 'G')
BS      equ     08h
HT      equ     09h
LF	equ	0Ah
NL      equ     LF
CR	equ	0Dh
XON     equ     (CTRL & 'Q')
XOFF    equ     (CTRL & 'S')
DC1     equ     XON
DC3     equ     XOFF
ESC     equ	1Bh


