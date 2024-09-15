#ifndef __MYTYPES_H
#define __MYTYPES_H 1

typedef unsigned char  byte;
typedef unsigned short word;
typedef unsigned long dword;

#define nelem(x) (sizeof(x)/sizeof(x[0]))

#ifndef __TIMESTAMP__
#define __TIMESTAMP__ "Tue Jan 29 14:40:56 2013"
#endif

#endif  /* __MYTYPES_H */
