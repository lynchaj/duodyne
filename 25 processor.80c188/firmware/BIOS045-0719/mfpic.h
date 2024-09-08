/*  mfpic.h  */
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
#ifndef _mfpic_h
#define _mfpic_h 1

/* Z80 base port for MF/PIC board (required) */
#define MF_PIC		0x40


/* babyM68k I/O address base	*/
#define babyM68k_IO ((byte*)0xFFFF8000)

/* board base address:		*/
#define mfpic_base (babyM68k_IO + MF_PIC)

#define mf_sio (mfpic_base + 8)
#define mf_ppi (mfpic_base + 4)
#define mf_rtc (mfpic_base + 3)
#define mf_cfg (mfpic_base + 2)
#define mf_202 (mfpic_base + 0)


#endif

