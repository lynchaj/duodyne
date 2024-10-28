/*************************************************************************
*  sio.c   for the N8VEM  SBC-188
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
/* sio.c */

#include "sbc188.h"
#include "sio.h"

const byte uart_echo = 1;


void putchar(char s)
{
   if (s == NL) uart_putchar(CR);
   uart_putchar(s);
}

void putline(char *s)
{
   char ch;
   while ( (ch = *s++) ) {
      putchar(ch);
   }
}

char getchar(void)		/* only printing characters echo */
{
   int ch;

   ch = 0;
   while (!ch) {
      ch = uart_getchar();	/* wait for a character to arrive */
      if (ch==CR) ch = NL;
   }
   if (uart_echo && is_print(ch)) putchar((char)ch);

   return ch;
}

char *getline(char *buffer, int length)
{  /* length is size of buffer; string returned will be length-1 or less */
   int n = 0;
   int ch = SP;

   length--;	/* account for terminating NUL */
   while (n < length) {
      ch = getchar();
      if (is_print(ch)) buffer[n++] = ch;
      else {
         switch (ch) {
         case NL:
            putchar((char)ch);
            buffer[n++] = 0;
            return buffer;
         case DEL:
         case BS:
            if (n > 0) {
               putline("\010\040\010");
               --n;
            }
            break;
         case HT:
            putchar(SP);
            buffer[n++] = SP;
            break;
         case CTRLU:
         case CTRLX:
            while (n) {
               putline("\010\040\010");
               --n;
            }
            break;
         default:
            putchar(BEL);
         }
      }
      if (n == length) {
         putchar(BEL);
         putchar(BS);
         --n;
      }
   }
   return buffer;
}
