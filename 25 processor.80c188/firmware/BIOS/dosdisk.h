/*  dosdisk.h  */
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
#ifndef __DOSDISK_H
#define __DOSDISK_H 1
#include "mytypes.h"


/* DOS Bios Parameter Block */


/* this is the actual DOS definition, assuming packing to 1 */
#pragma pack 1
typedef struct BPB {
    word	bps;	/* bytes per sector = 0x200 */
    byte	spc;	/* sectors per cluster, often 2 */
    word	rsvd;	/* number of reserved sectors starting at 0 */
    byte	nfat;	/* number of FATs, 2 for floppies */
    word	nrde;	/* number of root directory entries, often 112 */
    word	tsec;	/* total number of sectors, if 0, see below */
    byte	md;	/* media descriptor */
    word	spf;	/* sectors per FAT */
    word	spt;	/* sectors per track 9, 18, ... */
    word	nhd;	/* number of heads, 2 for DS floppies */
    dword	hid;	/* number of hidden sectors */
    dword	tsec2;	/* total number of sectors if 'tsec' is 0 */
    byte	res[2];	/* reserved bytes 2 */
	 byte		vers;	/* BPB version number */
    dword	id;	/* volume ID or Zero */
} T_bpb;		/* size should be 32 (per book) or 31 (actual disk) */
#define FMT_BPB "wbwbwwbwwwddwbd"


typedef struct BOOT_BLK {
	 byte jump[2];	/* Intel short jump */
	 byte nop[1];	/* Intel 90 == NOP */
	 byte sysid[8];	/* System ID, often garbage */
/* the BIOS parameter block */
    byte	bps[2];	/* bytes per sector = 0x200 */
    byte	spc[1];	/* sectors per cluster, often 2 */
    byte	rsvd[2];	/* number of reserved sectors starting at 0 */
    byte	nfat[1];	/* number of FATs, 2 for floppies */
    byte	nrde[2];	/* number of root directory entries, often 112 */
    byte	tsec[2];	/* total number of sectors, if 0, see below */
    byte	md[1];	/* media descriptor */
    byte	spf[2];	/* sectors per FAT */
    byte	spt[2];	/* sectors per track 9, 18, ... */
    byte	nhd[2];	/* number of heads, 2 for DS floppies */
    byte	hid[4];	/* number of hidden sectors */
    byte	tsec2[4];	/* total number of sectors if 'tsec' is 0 */
    byte	res[2];	/* reserved bytes 2 */
	 byte	vers[1];	/* BPB version number */
    byte	id[4];	/* partition ID or Zero */
/* extension for DOS 4.1 */
	 byte volnm[11];	/* partition Name */
	 byte ftype[8];	/* FAT12, FAT16, NTFS, ... */
} T_bootblk;



/* DOS Directory Entry */

typedef struct DIRENT {
    char	filename[8];	/* filename */
    char	extension[3];	/* filename.extension */
    byte	attrib;		/* file attributes */
    byte	res[10];	/* reserved */
    word	t_upd;		/* time of last update */
    word	d_upd;		/* date of last update */
    word	clust;		/* first cluster # */
    dword	fsize;		/* file size in bytes */
} T_dirent;
#define FMT_DIRENT "ccccccccccccwwwwwwwwd"

/* special meaning of filename byte 0 */
#define FN_nul	0x00		/* entry never used, no entries follow */
#define FN_e5	0x05		/* first char of Filename is 0xE5 */
#define FN_dot	0x2E		/* '.' -- alias for current or parent directory */
                                /* '..' */
#define FN_gone 0xE5		/* file has been erased */

/* file attribute bits */
#define ATTR_R	0x01		/* read only file */
#define ATTR_H	0x02		/* hidden file */
#define ATTR_S	0x04		/* system file */
#define ATTR_V	0x08		/* volume label */
#define ATTR_D	0x10		/* subdirectory */
#define ATTR_A	0x20		/* archive -- file has been written */
                                /*
*define ATTR_U  0x40		   unused
*define ATTR_UU 0x80		   unused
                                */
/* DOS partition table entry */

typedef struct PARTENT {
	 byte active;						/* active flag */
	 byte	st_hd, st_sec, st_cyl;	/* starting head, sector, cylinder */
	 byte ptype;						/* partition type */
	 byte en_hd, en_sec, en_cyl;	/* ending head, sector, cylinder */
	 dword sector_start;				/* starting sector */
	 dword sector_count; 			/* total sector count */
} T_partent;
#define FMT_PARTENT "ccccccccdd"


/* DOS hard disk boot sector zero */

typedef struct BOOTSECTOR {
	byte code[0x1B6];
	word unused1;
	dword volume_id;
	word creator;
	struct PARTENT partition[4];
	word flag;							/* 0x55, 0xAA -- Intel 0xAA55 */
} T_bootsector;


#endif /* __DOSDISK_H */
