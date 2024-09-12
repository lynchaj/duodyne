/* libc.h */
#ifndef _LIBC_H
#define _LIBC_H 1

unsigned int strlen(const char *s);
char *strchr(const char *s, int c);
int atoi(const char *s);
int log2(unsigned long value);
void _small_code(void);

#endif
