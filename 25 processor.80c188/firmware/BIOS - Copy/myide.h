/*  myide.h  */
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
#ifndef _MYIDE_H
#define _MYIDE_H 1
#include "mytypes.h"

#define MAX_DISK 8			/* allow up to 8 disks on the system */


enum BOARD_TYPE { B_NONE, B_PPIDE, B_DIDE, B_DISKIO };

enum DISK_TYPE {D_NONE, D_FLOPPY_1200=2, D_FLOPPY_720, D_FLOPPY_1440,
					D_PPIDE=8, D_DIDE, D_DISKIO, D_DIDE_8 };
enum IDE_MS {MASTER=0, SLAVE=0x10};

typedef
struct GEOMETRY {
	word	cylinders;		/* number of cylinders   [0 .. c-1]		*/
	byte	heads;			/* number of heads/tracks  [0 .. h-1]	*/
	byte	sectors;			/* number of sectors/track  [1 .. s]	*/
} T_geometry;


typedef
struct DISK {
	struct OPERATION const *op;		/* pointer to operation vectors */
	
	dword	lba_cyls;		/* LBA number of cylinders */

	byte	disk_type;		/* from the ENUM above */
	byte	port;				/* word for MSDOS */
	byte	slave;			/* IDE subtype information */
	byte	status;			/* last error status */

	T_geometry geom;		/* geometry information */
} T_disk;

typedef
struct OPERATION {
	int (*reset) (struct DISK *i);
	int (*info) (struct DISK *i);
	int (*read) (struct DISK *i, dword sector, byte *buffer);
	int (*write) (struct DISK *i, dword sector, byte *buffer);
	int (*verify) (struct DISK *i, dword sector);
	int (*format) (struct DISK *i, byte *interleave);
} T_operation;



T_disk *disk_table[MAX_DISK];		/* master table of disk drives */



/*
		Declarations of the disk I/O procedures
*/

int any_diskop(
		int diskno, 		/* D1 */
		int lba_sector, 	/* D2 */
		int nsects,			/* D3 */
		byte *buffer		/* A0 */
		);

int floppy_reset  (struct DISK *i);
int floppy_info   (struct DISK *i);
int floppy_read   (struct DISK *i, dword sector, byte *buffer);
int floppy_write  (struct DISK *i, dword sector, byte *buffer);
int floppy_verify (struct DISK *i, dword sector);
int floppy_format (struct DISK *i, byte *interleave);

int ppide_reset  (struct DISK *i);
int ppide_info   (struct DISK *i);
int ppide_read   (struct DISK *i, dword sector, byte *buffer);
int ppide_write  (struct DISK *i, dword sector, byte *buffer);
int ppide_verify (struct DISK *i, dword sector);
int ppide_format (struct DISK *i, byte *interleave);

int dide_reset  (struct DISK *i);
int dide_info   (struct DISK *i);
int dide_read   (struct DISK *i, dword sector, byte *buffer);
int dide_write  (struct DISK *i, dword sector, byte *buffer);
int dide_verify (struct DISK *i, dword sector);
int dide_format (struct DISK *i, byte *interleave);

#endif	//  _MYIDE_H

