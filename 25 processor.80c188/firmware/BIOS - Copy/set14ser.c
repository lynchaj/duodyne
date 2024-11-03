/*************************************************************************
*  set14ser.c   setup Serial interfaces for the SBC-188
**************************************************************************
*
*   Copyright (C) 2020 John R. Coffman.  All rights reserved.
*   Provided for hobbyist use on the RetroBrew SBC-188 board.
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
/* ser14set.c */

#include <stdlib.h>
#include <string.h>
#include "sbc188.h"
#include "sio.h"
#include "equates.h"
#include "ds1302.h"
#include "ide.h"
#include "sdcard.h"
#include "libc.h"

#define	DBG 3
#define CPM_FLOPPIES 0
#define FLOPPY_MAX 2

#define BCD(x) (byte)((x)<100?(((x)/10)<<4)|((x)%10):0xFF)
#define toupper(a) ((a)>='a'&&(a)<='z'?(a)-('a'-'A'):(a))

enum {NO_disk=0, PPI_type=2, DIDE0_type=4, DIDE1_type=6, DSD_type=8,
	V3IDE8_type=10, DISKIO_type=12, MFPIC_type=14 };

/* FIXED_DISK_MAX = maximum number of fixed disk drives (bda.inc) */





int setup_uart_comm_ports(void)
{
}

