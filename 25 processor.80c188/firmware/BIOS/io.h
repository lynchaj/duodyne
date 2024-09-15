/* io.h -- I/O procedures */
/*
	Copyright (C) 2011 John R. Coffman.
	Licensed for hobbyist use on the N8VEM baby M68k CPU board.
***********************************************************************

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    in the file COPYING in the distribution directory along with this
    program.  If not, see <http://www.gnu.org/licenses/>.

**********************************************************************/
#ifndef __IO_H
#define __IO_H 1

#include "mytypes.h"

typedef word T_port;

#if M68000
#include "mfpic.h"
#define inp(p) (babyM68k_IO[p])
#define outp(p,d) (babyM68k_IO[p]=(d))

void usec20(void);
void usec16(void);
void usec12(void);
void usec10(void);
void usec09(void);

#endif

#if SBC188
#include "sbc188.h"
#define usec12() microsecond(12)
#define usec16() microsecond(16)
#endif


#endif /* __IO_H */

