/*************************************************************************
*  libc.c   for the N8VEM  SBC-188
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
#include <string.h>

unsigned int strlen(const char *s)
{
	int i = 0;
	
	while (*s != '\0') i++, ++s;
	return i;
}

char *strchr(const char *s, int c)
{
	char *p = (char*)s;

	while (*p != '\0') {
		if (*p == c) return p;
		p++;
	}
	return 0;
}

#if 0
int strcmp(char *a, char *b)
{
	int eq = 0;
	while (!eq && (*a || *b) ) {
		if (*a < *b) eq = -1;
		if (*a > *b) eq = 1;
		a++;
		b++;
	}
	return eq;
}
#endif

int atoi(const char *s)
{
	int n = 0, i;
	char c;

	for (c = *s; c >= '0' && c <= '9'; c = *++s)
		n = n * 10 + c - '0';
	return n;
}

/* log2(0x100) -> 8      log2(0x060C)==log2(0x0800) -> 11 
	return log of 'value' rounded up to the next power of 2 */
int log2(unsigned long value)
{
	int log;

	if ( (value & (value-1)) == 0 ) --value;
	log = 0;
	while (value) {
		++log;
		value >>= 1;
	}
	return log;
}

/* make Watcom C happy */
void _small_code(void)
{
}


