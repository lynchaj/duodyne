/* sio.h */
#ifndef __SIO_H
#define __SIO_H 1

#define NUL 000
#define BEL 007
#define BS 010
#define HT 011
#define LF 012
#define NL 012
#define CR 015
#define CTRLU 025
#define CTRLX 030
#define SP 040
#define DEL 0177

#define is_print(x) ((x)>=SP && (x)<DEL)

extern const byte uart_echo;
void putchar(char s);
void putline(char *s);
char getchar(void);		/* only printing characters echo */
char *getline(char *buffer, int length);
#define GETLINE(b) getline(b,sizeof(b))

/* the following must be in step with the table in 'uart_det.asm' */
enum {
UART_NONE=0,	//equ	0	; no UART detected
UART_8250,	//equ	1	; no Scratch register
UART_16450,	//equ	2	; or 8250A
UART_16550,	//equ	3
UART_16550A,	//equ	4
UART_16550C,	//equ	5
UART_16650,	//equ	6
UART_16750,	//equ	7
UART_16850,	//equ	8
};

#endif  // __SIO_H
