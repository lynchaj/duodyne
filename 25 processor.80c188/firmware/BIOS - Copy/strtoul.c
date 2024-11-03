/*************************************************************************
*  strtoul.c   for the N8VEM  SBC-188
**************************************************************************
*
*   Copyright (C) 2010 John R. Coffman.  All rights reserved.
*   Provided for hobbyist use on the N8VEM SBC-188 board.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*************************************************************************/
/* strtoul.c	String to unsigned long
 *
 *
 *	This should be part of <string.h>
 *
 *
 */
#include "sbc188.h"
#include "sio.h"
#include "debug.h"
#include "equates.h"
#include "libc.h"

#define RUB DEL
#define ULONG_MAX 0xFFFFFFFFuL

//#pragma intrinsic(inp,inpw,outp,outpw)

#define is_alpha(x) ((x)>='A'&&(x)<='Z')
#define is_separator(x) ((x)<=' ')




static
char ndigit(char ch)
{
    register char c;
    
    c = ch;
    
    if (c >= '0' && c <= '9') c -= '0';
    else if (c >= 'A' && c <= 'Z') c -= ('A'-10);
    else if (c >= 'a' && c <= 'z') c -= ('a'-10);
    else c = RUB;

//    printf("exit ndigit   c = %d\n", (int)c);    
    return c;
}

unsigned long int strtoul(char *cptr, char **endptr, int radix)
{
    signed char sign = 0;
    unsigned long int  value = 0UL;
    char *cp;
    byte digit;
    unsigned long int  max;
    byte maxdigit;
    int errno;

    cp = cptr;    
    errno = 0;
    while (*cp == SP  ||  *cp == HT) ++cp;
    
    if (*cp == '-') sign = -1, ++cp;
    else if (*cp == '+') sign = 1, ++cp;
    
    digit = ndigit(*cp);
//    printf("stage 1   digit=%d\n", (int)digit);
    if (radix == 0) {
        if (digit == 0) {
            radix = 8;
            ++cp;
            if (ndigit(*cp) == 33 /* 'X' */ ) {
                radix = 16;
                digit = ndigit(*++cp);
            }
            else --cp;
        }
        else radix = 10;
    }
    else if (radix == 16  &&  digit == 0  &&  ndigit(cp[1]) == 33) ++cp;
    
//    printf("stage 2   radix=%d\n", (int)radix);
    if (digit >= radix) {	/* invalid digit */
        cp = cptr;
        errno = 1;
    }
    else {
//        printf("stage 3\n");
#if 0
        max = ULONG_MAX / radix;
        maxdigit = ULONG_MAX % radix;
#else
	max = divLS(ULONG_MAX, radix);
	maxdigit = remLS(ULONG_MAX, radix);
#endif

//        printf("stage 4\n");
        value = digit;
        while ( (digit = ndigit(*++cp)) != RUB) {
            if (digit < radix  &&  (value < max || (value == max && digit <= maxdigit)) ) {
#if 0
                value *= radix;
#else
		value = mulLS(value, radix);
#endif
                value += digit;
            }
            else {
                errno = 1;
                value = 0;
                ++cp;
            }
        }
        --cp;
        if (sign<0) value = -(signed int)value;
    }
    if (endptr) *endptr = ++cp;    
    
    return errno ? ULONG_MAX : value;
}

