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

#endif  // __SIO_H
