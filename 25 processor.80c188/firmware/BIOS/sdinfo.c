/* SDinfo.c

		Print out information about an SD card.

 */
#include <stdlib.h>
#include <stdio.h>

#include "SDcard.h"
#include "dosdisk.h"
#define SLOT 0

void myexit(byte code)
{
	if (code) printf("Exit with code = %d\n", (word)code);
	exit(code);
}

void main(int argc, char *argv[])
{
	int slot = SLOT;
	byte code;
	word temp, rblk, wblk, class;
	long size, tsec;
	byte vers;
	union Block {
		byte buffer[512];
		struct BOOTSECTOR boot;
		struct BOOT_BLK superblock;
	} block;

	SDinit();
	code = SDinitcard(slot);
	if (code) myexit(code);

	vers = SDcsd(CSD_STRUCTURE);
	printf("CSD version %d.0\n", vers+1);

	class = SDcsd(CMD_CLASS);
	printf("Command Classes:  0x%03X (%05o)\n", class, class);

	rblk = SDcsd(READ_BL_LEN);
	wblk = SDcsd(WRITE_BL_LEN);
	printf("Read and Write block length (max):  %u/%u bytes\n", 1<<rblk, 1<<wblk);

	if (vers) {	/* version 2.0 */
		size = SDcsd(C_SIZE_lo2);
		temp = SDcsd(C_SIZE_hi2);
		size += (long)temp << 16;
		size <<= 10;
	}
	else { /* version 1.0 */
		temp = SDcsd(C_SIZE_MULT);
		size = (SDcsd(C_SIZE) + 1L) << (temp+2 + rblk-9);
	}
	printf("Card capacity = %ld sectors  (%lX)\n", size, size);

/* read the partition table */
	code = SDread1sector(block.buffer, 0, (byte)slot);
	if (code) {
		printf("Error %d reading sector 0\n", (int)code);
		myexit(code);
	}
#define pt0 block.boot.partition[0]
	temp = (word)(pt0.st_sec) << 2;
	temp &= ~255;
	temp |= pt0.st_cyl;
	printf(" %c Start: %d:%d:%d  ",
		pt0.active ? 'A' : ' ', temp, pt0.st_hd, pt0.st_sec & 63);
	temp = (word)(pt0.en_sec) << 2;
	temp &= ~255;
	temp |= pt0.en_cyl;
	printf("End: %d:%d:%d  Type: %x",
		temp, pt0.en_hd, pt0.en_sec & 63, (int)(pt0.ptype));
	printf("   LBA start: %lu  LBA sectors: %lu\n",
		pt0.sector_start, pt0.sector_count);

	code = SDread1sector(block.buffer, pt0.sector_start, (byte)slot);
	if (code) {
		printf("Error %d reading sector 0 of partition 1\n", (int)code);
		myexit(code);
	}
#define bpb ((T_bpb*)block.superblock.bps)
	printf("bytes/sector : %hd\n", bpb->bps);
	printf("sectors/cluster : %hd\n", (word)(bpb->spc));
	printf("reserved sectors : %hd\n", bpb->rsvd);
	printf("number of FATs : %hd\n", (word)(bpb->nfat));
	printf("root dir entries : %hd\n", bpb->nrde);
	printf("sectors per FAT : %hd\n", bpb->spf);
	printf("sectors per track : %hd\n", bpb->spt);
	printf("number of heads : %hd\n", bpb->nhd);
	printf("hidden sectors : %lu\n", bpb->hid);
	tsec = bpb->tsec ? bpb->tsec : bpb->tsec2;
	printf("total sectors : %lu\n", tsec);
	size = bpb->nfat * bpb->spf  +  bpb->rsvd;
	printf("offset to directory = %lu\n", size);
	size += (bpb->nrde * 32 + bpb->bps - 1) / bpb->bps;
	printf("offset to data = %lu\n", size);
	tsec -= size;
	printf("number of clusters = %lu\n", tsec / bpb->spc);

	myexit(code);
}

