//
// Boot loader for MDEX on the 9995 breadboard with a CF Card
//

//
// SYMBOLIC NAMES
//

// defines for the CF card registers
	cfregs = 0xfe00
	cfdata = cfregs + 0
	cferr  = cfregs + 1		// rd
	cffeat = cfregs + 1		// wr
	cfcnt  = cfregs + 2
	cflba0 = cfregs + 3
	cflba1 = cfregs + 4
	cflba2 = cfregs + 5
	cflba3 = cfregs + 6
	cfstat = cfregs + 7		// rd
	cfcmd  = cfregs + 7		// wr

// defines for CF card commands in upper byte
	SETFEAT = 0xef00		// set feature
	RDSECT  = 0x2000		// read sector
	WRSECT  = 0x3000		// write sector
	IDENT   = 0xec00		// identify drive
	BYTEMOD = 0x0100		// 8 bit access mode

// offsets in partition table records
	ptype	= 4			// type offset
	start   = 8			// start sector offset

//
// DATA CONSTANTS
//

	.data
fd0img:		"MDEX_FD0DSK"		// FAT filename of FD0
fd1img:		"MDEX_FD1DSK"		// FAT filename of FD1
bootsav:	"BOOT$.SAV   "		// MDEX filename of MDEX kernel
errmsg:		"Unrecoverable error booting MDEX\r\0"

	.even
zero:		0			// convenience zero
enddir:		0xffff			// end-of-dir marker

//
// VARIABLES
//
		secbuf = 0x9000		// sector read buffer
		tmp = 0xff80		// temp var
		cluslba = 0xff82	// LBA of FAT cluster #2

//
// BOOT LOADER START
//
	.text
begin:
	lwpi	0xf000
	b	@main

// Get a (possibly unaligned) word value and flip endian
// r2 points to value, return in r0
//
get16:
1:	movb	(r2)+,r0
	swpb	r0
	movb	(r2),r0
	b	(r11)

// Get a (possibly unaligned) double word and flip endian
// r2 points to value, return in r0,r1
//
get32:
	movb	(r2)+,r1
	swpb	r1
	movb	(r2)+,r1
	jmp	1b

// Read a sector into the buffer, LBA sector # in r0,r1
// r0,r1 are destroyed
//
cfread:
1:	movb	@cfstat,@tmp		// wait for card ready
	jlt	1b
	movb	r1,@cflba1		// write the LBA address
	swpb	r1
	movb	r1,@cflba0
	andi	r0,0x0fff
	ori	r0,0xe000
	movb	r0,@cflba3
	swpb	r0
	movb	r0,@cflba2
	li	r0,0x0100		// set sector count to 1
	movb	r0,@cfcnt
	li	r0,RDSECT		// read sector
	movb	r0,@cfcmd
1:	movb	@cfstat,r0		// wait for card ready
	jlt	1b
	li	r0,secbuf		// read data into secbuf
	li	r1,512
1:	movb	@cfdata,(r0)+
	dec	r1
	jne	1b
	b	(r11)			// done

// Convert a FAT32 cluster number in r0,r1 to an LBA sector number in r0,r1
// r2 is destroyed
//
clus2lba:
	dect	r1			// clus = clus - 2
	joc	1f
	dec	r0
1:	li	r2,3			// sec = clus * 8
2:	sla	r0,1
	sla	r1,1
	jnc	1f
	inc	r0
1:	dec	r2
	jne	2b
	a	@cluslba,r0		// lba = sec + cluslba
	a	@cluslba+2,r1
	jnc	1f
	inc	r0
1:	b	(r11)

// Does this FAT32 directory entry match? If so, fetch start sector#
// r2 points to entry, r3 points to 8.3 filename
// if it is a match, LBA of file is in r0,r1 and EQ is set
// r2-r4,r12 are destroyed in all cases
// on no match, EQ is reset and r0,r1 are unchanged
//
FATtest:
	mov	r11,r12
	clr	r4			// attribute is 0x00 or 0x20?
	movb	@11(r2),r4
	jeq	1f
	ci	r4,0x2000
	jne	3f			// no
1:	li	r4,11			// yes; does name match?
2:	cb	(r2)+,(r3)+
	jne	3f			// no
	dec	r4
	jne	2b
	// we have a match
	ai	r2,15			// move to clus_lo field
	bl	@get16
	mov	r0,r1
	ai	r2,-7			// move to clus_hi field
	bl	@get16
	bl	@clus2lba		// cluster => sector
	c	r0,r0			// set EQ flag
3:	b	(r12)

// Does this MDEX directory entry match 'BOOT$.SAV'? If so fetch start sector#
// r2 points to entry
// if it is a match, MDEX sector # is in r3 and EQ is set
// r2-r4 are destroyed in all cases, and EQ is reset on failure
//
isboot:
	li	r4,12			// 12 characters in mdex file name
	li	r3,bootsav		// 'BOOT$.SAV   '
1:	cb	(r2)+,(r3)+
	jne	2f
	dec	r4
	jne	1b
	mov	(r2),r3			// found 'BOOT$.SAV', get first sector#
	c	r0,r0			// set EQ flag
2:	b	(r11)

// Read a sector from mdex FD0 image
// r1 holds the mdex sector number
// r0-r1 are destroyed
rd_mdex:
	mov	@0xff00,r0		// add in the LBA of FD0 sector 0
	a	@0xff02,r1
	jnc	1f
	inc	r0
1:	b	@cfread			// read the sector

// Report a fatal error
//
error:
	xop	@errmsg,14		// print error message
	b	@0x0142			// return to EVMBUG

progress:
	0xf020; bar

bar:
	li	r0,'>'*256
	xop	r0,12
	rtwp

//
// Here is the start of the main program. It has three phases:
// 1. Init the CF card
// 2. Read the FAT32 file system and find the location of the FD0 and FD1 images
// 3. In the FD0 image, find 'BOOT$.SAV' in the MDEX file system and load it
//

// Init CF card, set 8-bit mode
main:
1:	movb	@cfstat,r0		// wait for card ready
	jlt	1b
	movb	@zero,@cflba3		// set 8 bit access mode
	li	r0,BYTEMOD
	movb	r0,@cffeat
	li	r0,SETFEAT
	movb	r0,@cfcmd

	blwp	@progress		// >

// Read the Master Boot Record (contains the Partition Table)
//
	clr	r0			// read sector 0, the MBR
	clr	r1
	bl	@cfread
	li	r2,secbuf+0x1be		// point r2 at partition table
	li	r3,4			// four entries	
	clr	r0
1:	movb	@ptype(r2),r0
	ci	r0,11*256		// FAT32 is type 11 or 12
	jeq	1f
	ci	r0,12*256
	jeq	1f
	dec	r3			// next partition of 4
	jeq	error
	ai	r2,16
	jmp	1b
1:	ai	r2, start		// found FAT32 partition, read start
	bl	@get32			//  sector

	blwp	@progress		// >>
	
// Read the FAT32 boot block
//
	mov	r0,@cluslba		// save base sector #
	mov	r1,@cluslba+2
	bl	@cfread			// read boot block
	li	r2,secbuf+14
	bl	@get16			// add reserved sectors to base
	a	r0,@cluslba+2
	jnc	1f
	inc	@cluslba
1:	clr	r0			// assert that there are 2 FAT copies
	movb	@secbuf+16,r0
	ci	r0,0x0200
	jne	error
	li	r2,secbuf+36		// get FAT table length in sectors
	bl	@get32
	sla	r0,1			// multiply by 2
	sla	r1,1
	jnc	1f
	inc	r0
1:	a	r0,@cluslba		// add FAT length * 2 to base
	a	r1,@cluslba+2
	jnc	1f
	inc	@cluslba
1:	clr	r0			// fetch sectors per cluster
	movb	@secbuf+13,r0
	ci	r0,0x0800		// assert 8 sectors/cluster
	jne	error
	li	r2,secbuf+44
	bl	@get32			// fetch root dir start cluster

	blwp	@progress		// >>>

// Read the first sector of the FAT32 root directory
//
	bl	@clus2lba		// convert to sector lba
	bl	@cfread			// read root dir first sector
	li	r6,16			// 16 entries
	clr	r7			// no matches yet
	li	r5,secbuf		// point to first entry
1:	mov	r5,r2
	li	r3,fd0img
	bl	@FATtest
	jne	2f
	mov	r0,@0xff00		// found 'MDEX_FD0.DSK' image
	mov	r1,@0xff02
	jmp	3f
2:	mov	r5,r2
	li	r3,fd1img
	bl	@FATtest
	jne	4f
	mov	r0,@0xff04		// found 'MDEX_FD1.DSK' image
	mov	r1,@0xff06
3:	inc	r7
	ci	r7,2			// have we found both?
	jeq	read_mdex		// yes, now read FD0 contents
4:	ai	r5,32			// no, move to next dir entry
	ci	r5,secbuf+512		// past end?
	jlt	1b			// no
	b	@0x0142
	b	@error			// yes, signal an error (todo: read full dir)

// Now read the directory of MDEX_FD0 and find the BOOT$.SAV file location
//
read_mdex:
	blwp	@progress		// >>>>

	clr	r4			// start at image sector 0
1:	mov	r4,r1			// read sector
	bl	@rd_mdex
	li	r5,7			// 7 entries per 128 byte sector
	li	r6,secbuf
2:	mov	r6,r2
	c	(r2),@enddir		// 0xffff marker? => not bootable
	bjeq	error
	bl	@isboot			// is this 'boot$.sav'?
	jeq	loadsys			// yes, load the file
	dec	r5			// more entries in this sector?
	jeq	3f			// no, read next sector
	ai	r6,18			// yes, look at next entry
	jmp	2b
3:	inc	r4			// increment image sector number
	jmp	1b			// go back and load/scan next sector

// Finally, read the BOOT$.SAV file and transfer control to the MDEX kernel
//
loadsys:
	blwp	@progress		// >>>>>

	mov	r3,r1			// load first sector of 'boot$.sav'
	bl	@rd_mdex
	li	r2,secbuf
	mov	@6(r2),r9		// load address
	mov	@8(r2),r10		// program length in bytes
	ai	r10,127			// round up & convert to sector length
	sra	r10,7

	mov	@10(r2),r13		// prepare initial WS/PC/ST
	jne	1f
	li	r13,0xf000
1:	mov	@12(r2),r14
	clr	r15

2:	inc	r3			// now load the actual binary
	mov	r3,r1			// load a sector
	bl	@rd_mdex
	li	r2,64			// move 128 bytes into place (64 words)
	li	r1,secbuf
1:	mov	(r1)+,(r9)+
	dec	r2
	jne	1b
	dec	r10			// more sectors to load?
	jne	2b

	blwp	@progress		// >>>>>>
	li	r12,0x0d00		// '\r'
	xop	r12,12

// For a ROM'ed boot loader we cannot swap out the ROM whilst using it:
// place the last few instructions in the WS and execute from there.
//
	li	r0,0x020c		// li r12,0x0040
	li	r1,0x0040
	li	r2,0x1d00		// sbo 0: swap out ROM
	li	r3,0x0380		// rwtp: jump into mdex kernel
	b	r0


