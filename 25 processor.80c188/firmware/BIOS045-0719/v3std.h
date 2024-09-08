/* v3std.h */
#ifndef __V3STD_H
#define __V3STD_H 1
#include "mytypes.h"

#ifdef CPM68
#ifdef KISS
#define IOBASE  0xFFFFFF00
#define VGA_MEML  (byte *)(0xFFFB0000L)
#define VGA_MEM	  (byte *)(0xFFFB8000L)
#else /* MINI68 */
#define IOBASE  0xFFFFFF00
#define VGA_MEML  (byte *)(0x370000L)
#define VGA_MEM	  (byte *)(0x378000L)
#endif /* KISS */
#define FAR
#include "io68k.h"
#include "cprintf.h"

#else 
#ifdef SBC188
#define IOBASE	0x0400
#define FAR __far
#define VGA_MEML  (byte far *)(0xB0000000L)	/* $B000:0000 */
#define VGA_MEM	  (byte far *)(0xB8000000L)	/* $B800:0000 */
/*#include <conio.h>*/
#else
#define IOBASE  0
#define FAR
#ifdef UNA
#include "una_io.h"
#include "cprintf.h"
#endif
#endif
#endif
#define V3STRAP	0x00E0


#define V3DEV	(IOBASE+V3STRAP)

/* THESE TWO SHOULD BE RENAMED:		*/
#define V3KBD0	(V3DEV+0)
#define V3KBD1	(V3DEV+1)

#define V3CRTC_ADDR	(V3DEV+2)
#define V3CRTC_DATA	(V3DEV+3)
#define V3CFG	(V3DEV+4)
/* for when memory mapping is not available */
#define V3ADDH	(V3DEV+5)
#define V3ADDL	(V3DEV+6)
#define V3DATA	(V3DEV+7)


/******************************************/
/* configuration register bit definitions */

#define CFG_B8B0	0x80	/* memory address B800:0 or B000:0 */
#define CFG_PAGE	0x70	/* page select bits (3) */
#define CFG_FONT512	0x08	/* font 512 or 256  (1, 0) */
#define CFG_VID_EN	0x04	/* video enable */
#define CFG_unused2	0x02	/* unused -- reserved for OSC select */
#define CFG_CHAR8	0x01	/* 1 ==> 8 bit char; 0 ==> 9 pit char */



/************************************************/
/* CRTC register numbers			*/

#define CURSOR1_START	10	/* raster line, with B & P bits (6, 5) */
#define CURSOR1_END	11	/* raster line			*/
#define SCREEN1_START_HI 12	/* memory address */
#define SCREEN1_START_LO 13	/*   ditto        */
#define CURSOR1_HI	14	/* address (character index) */
#define CURSOR1_LO	15	/*      ditto                */



#endif /* __V3STD_H */
