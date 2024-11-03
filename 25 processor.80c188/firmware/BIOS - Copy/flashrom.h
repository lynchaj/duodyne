/* flashrom.h  */
#include "mytypes.h"

#define nSECLIST 5

/* FLASH programming algorithms are know for:
	AMD, SST, & Atmel(TBD)			*/
enum ALGORITHM { UNKal, AMDal, SSTal, ATal };

const
struct ROMDEF {
	const char *part_id;
	word chip_id;		/* chip ID returned by chip read  */
	byte lgChipSize;	/* log2 of the chip size	  */
	byte lgSectorSize;	/* log2 of the sector size	  */
	byte lgNsectors;	/* log2 of the number of sectors  */
	byte algorithm;		/* algorithm numeric (enum) index */
} romlist[]		=
	{
		{	"AM29F010",	0x0120, 17, 14,  3, AMDal },
		{	"AM29F040",	0x01A4, 19, 16,  3, AMDal },
//	*	{	"AT29C512",	0x1F5D, 16,  7,  9, ATal },
//	*	{	"AT29C010A",	0x1FD5, 17,  7, 10, ATal },
//	*	{	"AT29C020",	0x1FDA, 18,  8, 10, ATal },
//	*	{	"AT29C040A",	0x1FA4, 19,  9, 10, ATal },	
//	*	{	"AT49F040",	0x1F13, 19, 19,  0, UNKal },	/* 16K boot block @ 00000 */
		{	"M29F010B",	0x2020, 17, 14,  3, AMDal },
		{	"M29F040B",	0x20E2, 19, 16,  3, AMDal },
		{	"MX29F040",	0xC2A4, 19, 16,  3, AMDal },
		{	"SST39SF010A",	0xBFB5, 17, 12,  5, SSTal },
		{	"SST39SF020A",	0xBFB6, 18, 12,  6, SSTal },
		{	"SST39SF040",	0xBFB7, 19, 12,  7, SSTal },
		{    "Unknown",		000000, 19, 19,  0, UNKal },
	};
/* end flashrom.h  */
