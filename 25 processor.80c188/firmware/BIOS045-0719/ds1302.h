/* ds1302.h */

#include "sbc188.h"



#define RAM 0x8000
#define CLOCK 0x0000

/* definitions of the CMOS RAM locations */
#define RAM_trickle		0
#define RAM_century		1
#define RAM_floppy      2
#define RAM_floppy0     2
#define RAM_floppy1     3
#define RAM_bits        4
#define RAM_bits_DST    01    /* DST flag */
#define RAM_bits_AA55   02    /* skip DOS boot signature check if set */
#define RAM_serial	5	/* serial console baud rate */
#define RAM_fixed       6     /* number of PPIDE fixed disks */
#define RAM_fx_dide	   7		/* number of DIDE0 (lo nibble) and DIDE1 (hi nibble) disks */
#define RAM_fx_dsd	   8		/* number of dual SDcard slots */

#define RAM_checksum	30
#define RAM_length	31

#define NVRAM_MAGIC	0x5A	/* checksum should be equal to this number */

#define rtc_WP(on) rtc_set_loc(7|CLOCK,(on?0x80:0))


void rtc_reset(void);
void rtc_reset_off(void);
void __fastcall rtc_write(byte datum);
byte __fastcall rtc_get_loc(word item);
void __fastcall rtc_set_loc(word item, byte datum);
