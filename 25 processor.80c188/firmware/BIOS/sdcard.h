/* SDcard.h */
#ifndef __SDcard_H
#define __SDcard_H	1

#include "mytypes.h"

#define b(hi,lo) ((hi)<<8|(lo))

/* common to versions 1.0 and 2.0 */
#define CSD_STRUCTURE b(127,126)
#define TAAC b(119,112)
#define NSAC b(111,104)
#define TRAN_SPEED b(103,96)
#define CMD_CLASS b(95,84)
#define READ_BL_LEN b(83,80)
#define RD_BL_PARTIAL b(79,79)
#define WRITE_BLK_MISALIGN b(78,78)
#define READ_BLK_MISALIGN b(77,77)
#define DSR_IMP b(76,76)
#define ERASE_BL_EN b(46,46)
#define SECTOR_SIZE b(45,39)
#define WP_GRP_SIZE b(38,32)
#define WP_GRP_ENABLE b(31,31)
#define R2W_FACTOR b(28,26)
#define WRITE_BL_LEN b(25,22)
#define WRITE_BL_PARTIAL b(21,21)

#define FILE_FORMAT_GRP b(15,15)
#define COPY b(14,14)
#define PERM_WRITE_PROTECT b(13,13)
#define TMP_WRITE_PROTECT b(12,12)
#define FILE_FORMAT b(11,10)
#define CRC b(7,1)
#define CRC7 b(7,0)

/* version 1.0 only */
#define VDD_R_CURR_MIN b(61,59)
#define VDD_R_CURR_MAX b(58,56)
#define VDD_W_CURR_MIN b(55,53)
#define VDD_W_CURR_MAX b(52,50)
/* different in versions 1.0 and 2.0 */
#define C_SIZE b(73,62)
#define C_SIZE_MULT b(49,47)

#define C_SIZE_hi2 b(69,64)
#define C_SIZE_lo2 b(63,48)


//void __fastcall SDinit(void);
int __fastcall SDinitcard(int slot);
word __cdecl SDcsd(word what, byte *SDcsd);
int __cdecl SDread1sector(byte buffer[512], long sector, byte unit);

#endif //__SDcard_H
