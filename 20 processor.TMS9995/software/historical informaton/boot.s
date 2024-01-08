	wp1    = 0xf000
	wp2    = 0xf020
	wp3    = 0xf040

	inoblk = 0x8400
	indblk = 0x8600
	datblk = 0x8800
	
	emu    = 0

	.if emu
// Header & startup code for emulator
	wp1;start;
	0;0;0;0;0;0

start:
	lwpi	0xf000
	li	sp,0xeffe
	li	r0,cfdsk0
	clr	(r0)+
	clr	(r0)+
	clr	(r0)+
	clr	(r0)+
1:	movb	@cfstat,r0
	jlt	1b
	movb	@zero,@cflba3
	li	r0,BYTEMOD
	movb	r0,@cffeat
	li	r0,SETFEAT
	movb	r0,@cfcmd

	.data
zero:	0
	.text
	.endif

// The real boot loader starts here. It has to fit in one 512 byte sector
// and the below code is 500 bytes. It loads the file "lsx" from the root
// directory of the first block device into low memory, i.e. starting
// from location 0. This boot loader therefore has to be run from higher
// in memory. The breadboard system loads it at location 0x8000.


// Unix Boot Loader

boot:	li	r0,1		// get root dir = inode 1
	mov	r0,@wp2+20
	blwp	@geti
	
	// set up directory scan
	mov	r2,r10
	mov	@6(r10),r9	// get size (assume int)
	sra	r9,4		// cnt = size / 16
	clr	r8		// lbn = 0
	li	r7,datblk
	jmp	2f

	// read directory blocks one by one
1:	mov	r8, @wp2+24	// pbn, lbn2pbn(inop, lbn)
	mov	r10,@wp2+22
	blwp	@lbn2pbn
	inc	r8		// lbn++
	mov	r7,@wp3+20	// cfread(pbn, datblk)
	mov	r2,@wp3+2
	blwp	@read

	// scan block
	mov	r7,r6		// p = &datblk
5:	li	r5,lsx		//   q = "lsx"
	li	r4,14		//   n = 14
	mov	(r6)+,r3	//   i = p->inode
4:	movb	(r6)+,r0	//     if (!*p && !*q && i) goto found
	jne	6f
	movb	(r5),r1
	jne	6f
	mov	r3,r3
	jne	found
6:	cb	r0,(r5)+	//     if (*p++!==*q++) i = 0
	jeq	3f
	clr	r3
3:	dec	r4		//     while (--n>0)
	jgt	4b
	dec	r9		//   if (--cnt<0) goto error;
	jlt	error
	ci	r6,datblk+512	// while (p < (datblk+512)) 
	jl	5b

2:	mov	r9,r9		// while (cnt>0)
	jgt	1b

error:	li	r12,0x0040	// swap in ROM
	sbz	0
	.if 1-emu
	xop	@errmsg,r14	// print generic error message
	b	@0x0142		// return to EVMBUG
	.endif
	.if emu
	limi	0
	idle
	.endif

found:	li	r12,0x0040	// swap out ROM
	sbo	0
	mov	r3,@wp2+20	// "lsx" found, fetch inode
	blwp	@geti
	mov	r2,r10
	clr	r8		// lbn = 0
2:	mov	r8,@wp2+24	// pbn = lbn2pbn(inop, lbn)
	mov	r10,@wp2+22
	blwp	@lbn2pbn
	mov	r7,@wp3+20	// cfread(pbn, datblk)
	mov	r2,@wp3+2
	blwp	@read
	mov	r8,r8		// if (lbn==0)
	jne	1f
	mov	@2(r7),r9	//   cnt = (hdr.text + hdr.data + 8 + 511) / 512
	a	@4(r7),r9
	ai	r9,8+511
	srl	r9,9
	li	r4,0		//   p = 0
	mov	r7,r5		//   q = datblk + 16
	ai	r5,16
1:	mov	(r5)+,(r4)+	// do { *p++=*q++; } while (q<datblk+512)
	ci	r5,datblk+512
	jl	1b
	inc	r8		// lbn++
	mov	r7,r5		// q = datblk
	dec	r9		// while (--cnt)
	jne	2b

	blwp	@0		// start kernel through reset vector

// get a pointer to the inode in R10 of wp2, pointer left in R2 of wp1

geti:
	wp2;getino

getino:
	mov	r10,r2
	ai	r10,31
	sla	r10,5
	mov	r10,r9
	srl	r9,9
	mov	r10,r8
	andi	r8,511
	c	r2,@lstino
	bjeq	L9
	li	r0,inoblk
	mov	r0,@wp3+20
	mov	r9,@wp3+2
	blwp	@read
L9:
	mov	r2,@lstino
	ai	r8,inoblk
	mov	r8,@wp1+4
	rtwp

// convert file logical block no. to physical block no.
// lbn = r12, inop = r11

	FLARGE = 0x1000

lbn2pbn:
	wp2;l2p

l2p:
	// check inode sanity
	ci	r12,0x7fff
	bjh	error

	mov	r11,r2		// if (inop->flags & FLARGE) goto large;
	mov	(r2),r2
	andi	r2,FLARGE
	bjne	large

small:	mov	r12,r2		// if (blkno>7) goto error;
	ci	r2,7
	bjh	error
	sla	r2,1		// return (inop->addr[2*blkno]);
	a	r11,r2
	mov	@8(r2),@wp1+4
	rtwp

large:	mov	r12,r2		// ind = (inop->addr[2*blkno/256]);
	srl	r2,8
	sla	r2,1
	a	r11,r2
	mov	@8(r2),r10
	bjeq	error

	// fetch indirect block as needed
	c	r10,@lstind	// if (ind!=lstind)
	bjeq	1f
	li	r0,indblk	//    read(ind,indblk)
	mov	r0,@wp3+20
	mov	r10,@wp3+2
	blwp	@read
	mov	r10,@lstind	// lstind = ind

	// fetch physical block number from indirect block
1:	mov	r12,r9			// offs = (blkno & 0xff) *2
	andi	r9,0xff
	sla	r9,1
	mov	@indblk(r9),@wp1+4	// R2 = indblk[offs]
	rtwp

// Driver for the CF Card on the breadboard

// defines for the CF card registers
	cfregs = 0xfe00
	cfdata = cfregs + 0
	cferr  = cfregs + 1	// rd
	cffeat = cfregs + 1	// wr
	cfcnt  = cfregs + 2
	cflba0 = cfregs + 3
	cflba1 = cfregs + 4
	cflba2 = cfregs + 5
	cflba3 = cfregs + 6
	cfstat = cfregs + 7	// rd
	cfcmd  = cfregs + 7	// wr

// defines for CF card commands in upper byte
	SETFEAT = 0xef00	// set feature
	RDSECT  = 0x2000	// read sector
	WRSECT  = 0x3000	// write sector
	IDENT   = 0xec00	// identify drive
	BYTEMOD = 0x0100	// 8 bit access mode
	
// defines for status bits
	ERR     = 0x0100	// error condition
	DRQ     = 0x0800	// data request

// image vectors left behind by boot loader
	cfdsk0	= 0xff00	// base sector of DSK0 image (32 bit)
	cfdsk1  = 0xff04	// base sector of DSK1 image (32 bit)

read:
	wp3; cfread

// read 256 words starting at blok no. R1 to addr R10
cfread:
	// seek
	li	r2,cfdsk0	// starting sector of dsk0 image
	mov	(r2)+,r0	// add start to requested to get
	a	(r2),r1		//   32 bit LBA of req. sector
	jnc     1f
	inc	r0
1:	movb	r1,@cflba1	// move the LBA to the CF Card
	swpb	r1		//    registers and set transfer
	movb	r1,@cflba0	//    length to 1 sector
	andi	r0,0x0fff
	ori	r0,0xe000
	movb	r0,@cflba3
	swpb	r0
	movb	r0,@cflba2
	li	r0,0x0100
	movb	r0,@cfcnt
	// read block
1:	movb	@cfstat,r0	// wait card ready
	jlt	1b
	li	r0,RDSECT	// issue read command
	movb	r0,@cfcmd
1:	movb	@cfstat,r0	// wait card ready
	movb	r0,r1
	jlt	1b
	andi	r0,DRQ		// and data ready
	jeq	1b
	andi	r1,ERR		// check for error
	bjne	error
	li	r1,512
1:	movb	@cfdata,(r10)+
	dec	r1
	jne	1b
	rtwp

lsx:	"unix\0"			// name of kernel
errmsg: "kernel not found\n\0"	// printed on any error
	.even

	.data
lstino:	0
lstind:	-1
	.text
