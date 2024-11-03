#ifndef __EQUATES_H
#define __EQUATES_H
#include "mytypes.h"

#ifndef NULL
#define NULL ((void*)0UL)
#endif

#pragma pack(1)

typedef
struct EquipmentFlag {
   word  has_floppy  : 1;     /* has 1..4 floppies */
   word  has_187     : 1;     /* Has Emulator ??? */
   word  has_pointer : 1;     /* PS/2       (bit 2)*/
   word  unused      : 1;     /* bits 2-3 were RAM size on the PC */
   word  video_mode  : 2;     /* Initial Video Mode */
   word  floppies    : 2;     /* 0..3 means 1..4 floppies if 'has_floppy' set */
   word  reserved    : 1;
   word  com_ports   : 3;     /* number of COM ports (we got 0) */
   word  game_adapter: 1;     /* has a game adapter */
   word  modem_ser_pr: 1;     /* modem or serial printer */
   word  printers    : 2;     /* number of printer ports (we got 0) */
} EQFL;

#define FDC_DRIVE_PRESENT  1
#define FDC_DRIVE_READY    2



typedef
struct EDD_disk {
   word  log_cylinders;    /* logical cylinders (max 1024) */
   byte  log_heads;        /* logical heads (0==>max of 256) */
   byte  signature;        /* A0h means translated geometry */
   byte  phys_sectors;     /* physical sectors per track (max 63) */
   word  LBA_high;         /* [precomp] high word of LBA max, or 0 */
   byte  reserved7;        /* reserved, for the moment */

/* the following bitfields form the high byte of the IDE Head register
   byte  reserved8_03 : 4; // Must Be Zero 
   byte  master_slave : 1; // 0 = master, 1 = slave 
   byte  one5         : 1; // Must Be One 
   byte  lba_flag     : 1; // 1 = LBA okay, 0 = only CHS 
   byte  one7         : 1; // Must Be One */

   byte  drive_control;    /* bitfields as above:  A0 = CHS master, F0 = LBA slave */

   word  phys_cylinders;   /* physical cylinders, (0==>max of 65536) */
   byte  phys_heads;       /* physical heads (max 16) */
   word  LBA_low;          /* [land zone] low word of LBA max, or 0 */
   byte  log_sectors;      /* logical sectors per track (max 63) */
   byte  checksum;         /* sum of 16 bytes must be zero */
} EDD_DISK;

typedef
struct FDC_fd {
      byte  disk_type;        // 0, 2, or 4, probably
      byte  unused_now;       // delete in the future
      byte  status_sw;        // general status information (S/W)
      byte  present_cylinder; // Current Cylinder no.      
      byte  status_hw[4];     // hardware status bytes
   } FDC_FD;

/* the drive_control bit definitions */
#define DC_ONES   0xA0
#define DC_LBA    0x40
#define DC_MASTER 0x00
#define DC_SLAVE  0x10

typedef
union {
	word w;
	struct {
		byte	x,y;
	} b;
	struct {
		byte lo,hi;
	} reg;
} T_CURSOR_POSITION;


/* Start of the Bios Data Area  */

#include "bda.inc"

} *bios_data_area_ptr;

/* this must be the same in EQUATES.ASM */
#if SOFT_DEBUG
#define NBREAK  8
#endif



#endif   // __EQUATES_H
