/* exe2rom.c
****************************************************************************
   Convert an EXE file into a ROM-able image

   invoked:
      exe2rom  <file> [<outfile>]

   options:
      -s <startup file>    e.g., startup.bin (appended)
      -r <romsize>         e.g., -r 64       (power of 2)
      -c <chipsize>        e.g., -c 128    (if EPROM is larger than linked ROM)


***************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include "mytypes.h"


#ifndef ROM
#define ROM 32
#endif

#ifndef CHIP
#define CHIP 128
#endif

#define BUFSIZE 4096
#define PAGESIZE 512
#define FILL 0xff

typedef
struct Header {
   char     sig[2];        /* 'MZ' signature */
   word     length;        /* length of image modulo page size */
   word     pages;         /* size of file in pages */
   word     nreloc;        /* number of relocation items */
   word     header;        /* size of header in paragraphs */
   word     minalloc;
   word     maxalloc;
   word     SP_displ;
   word     SP_offset;
   word     checksum;      /* image checksum */
   word     IP_offset;
   word     CS_displ;
   word     reloc_displ;   /* displacement of first relocation item */
   word     overlay;
} HEADER;

typedef
struct RelocItem {
   word     offset;        /* offset of relocation item */
   word     segment;       /* segment of relocation item */
} RELOCITEM;

/* Global Variables from CONFIG.ASM */
word ROMsize = ROM;
word CHIPsize = CHIP;



void usage(void)
{
   printf(  "Usage:\n"
/*          "    exe2rom [options] exefile.exe [romfile.bin]\n"   */
            "    exe2rom [options] exefile.exe romfile.bin\n"
            "        options:\n"
            "           -v (verbose output)\n"
            "           -s STARTUPFILE\n"
            "           -r NNN  (ROM size in K)\n"
            "           -e NNN  (actual EPROM chip size in K)\n"
            );
}


void error1(char *cp)
{
   printf("Unknown switch:  %s\n", cp);
   usage();
   exit(1);
}

long int filelength(int fd)
{
	struct stat st;

	if (fstat(fd, &st) != -1)
		return st.st_size;
	return -1;
}

int main(int argc, char *argv[])
{
   int i;
   char *startupfile = "startup.bin";
   char *exefile = NULL;
   char *binfile = NULL;
   char *cp, *tp;
   FILE *ifile, *ofile, *sfile;
   word lth, temp;
   dword startuplength, filler, rombegin, romlength, codelength;
   HEADER header;
   RELOCITEM reloc;
   byte *bp, buffer[BUFSIZE];
   int verbose = 0;


/*  Process the command line arguments */

   for (i=1; i<argc; i++) {
      cp = argv[i];
      if (*cp == '-') {
         tp = ++cp + 1;
         switch (*cp) {
         case 's':      /* startup binary file specification */
            if (!*tp && ++i<argc) tp = argv[i];
            else if (!*tp) error1(argv[i]);
            startupfile = tp;
            break;
         case 'r':      /* numeric ROM code size selector, usually 32 or 64 */
            if (!*tp && ++i<argc) tp = argv[i];
            else if (!*tp) error1(argv[i]);
            ROMsize = atoi(tp);
            break;
         case 'e':      /* numeric EPROM physical size >= ROM code */
            if (!*tp && ++i<argc) tp = argv[i];
            else if (!*tp) error1(argv[i]);
            CHIPsize = atoi(tp);
            break;
         case 'h':      /* ask for Help */
            usage();
            exit(0);
         case 'v':      /* get more verbose output */
            verbose = 1;
            break;
         default:
            error1(argv[i]);
         } /* switch */
      } /* if '-' */
      else {
         if (!exefile) exefile = cp;
         else if (!binfile) binfile = cp;
         else {
            printf("Unknown 3rd argument:  %s\n", cp);
            usage();
            exit(1);
         }
      }
   } /* for */


/*   Now display the parameters as we interpreted them */

   printf("ROM=%d  EPROM=%d  StartUpFile=\"%s\"\n", ROMsize, CHIPsize, startupfile);
   if (ROMsize&(ROMsize-1) || CHIPsize&(CHIPsize-1) || ROMsize>CHIPsize ||
         CHIPsize>256 || ROMsize<32) {
      printf("\nROM or EPROM size specification error.\n");
      exit(1);
   }
   if (!exefile) {
      printf("No input file specified.\n");
      usage();
      exit(1);
   }
   if (!binfile) {
      printf("No output file specified.\n");
      usage();
      exit(1);
   }
   printf("EXEfile=\"%s\"   EPROMfile=\"%s\"\n", exefile, binfile);


/*   Do the actual file opens */

   ifile = fopen(exefile, "rb");
   if (!ifile) {
      printf("Unable to open EXEfile \"%s\"\n", exefile);
      exit(1);
   }
   sfile = fopen(startupfile, "rb");
   if (!sfile) {
      printf("Unable to open STARTUPfile \"%s\"\n", startupfile);
      exit(1);
   }
/*   Make sure the output file is fresh by deleting any old one */
   remove(binfile);
   ofile = fopen(binfile, "w+b");
   if (!ofile) {
      printf("Unable to open ROMfile \"%s\"\n", binfile);
      exit(1);
   }

/*   Determine the length of the startup code (must be <= 1K for 80188 */

   startuplength = filelength(fileno(sfile));
   if (startuplength > 1024u || startuplength&(startuplength-1)) 
      printf("STARTUPfile length error.\n"), exit(1);


/*   Read the EXE header from the linked EXE file */

   lth = fread(&header, sizeof(header), 1, ifile);
   if (lth!=1) printf("EXEfile: header read error.\n"), exit(1);


/*  Since the EPROM may be larger than the actual ROM code,
      pre-pend the appropriate amount of filler bytes */

   rombegin = romlength =
   filler = (CHIPsize - ROMsize) * 1024uL;
   if (filler) {
      for (bp=buffer, i=0; i<sizeof(buffer); i++) *bp++ = FILL;
      while (filler) {
         lth = fwrite(buffer, sizeof(buffer), 1, ofile);
         if (lth!=1) printf("EPROMfile: filler write error.\n");
         filler -= sizeof(buffer);
      }
   }


/*   Seek over the EXE header to the actual linked code */

   filler = (dword)header.header * 16uL;
   if (fseek(ifile, filler, SEEK_SET))
      printf("EXEfile seek error 1.\n"), exit(1);

/*   Copy all of the executable code and data from the EXE file to 
         the EPROM file  */

   /* caclulate the length of the code section */
   codelength = header.pages * PAGESIZE;
   if (header.length != 0)
	codelength = codelength - PAGESIZE + header.length;
   codelength = codelength - header.header * 16;

   /* round to nearest page */
   if (codelength % PAGESIZE != 0)
	codelength = (codelength / PAGESIZE + 1) * PAGESIZE;

   romlength += codelength;

   /* copy code data from EXE file to EPROM file */
   for (i = codelength / PAGESIZE; i > 0; i--) {
	if ((lth = fread(buffer, 1, PAGESIZE, ifile)) == 0) {
		printf("EXEfile read error 1.\n");
		exit(1);
	}
	if (lth != PAGESIZE)	/* fill the reminder of the last page with FILL */
		for (; lth < PAGESIZE; lth++) buffer[lth] = FILL;
	if (fwrite(buffer, 1, PAGESIZE, ofile) != PAGESIZE) {
		printf("EPROMfile write error 1.\n");
		exit(1);
	}
   }
		

/*   Calculate if we have enough room in the EPROM for the EXE file
      code and data plus the startup block.  */

   if (romlength + startuplength > (dword)CHIPsize * 1024uL)
      printf("EXEfile + STARTUPfile too big for EPROMfile.\n"), exit(1);
   for (bp=buffer, i=0; i<sizeof(buffer); i++) *bp++ = FILL;


/*   There is enough room, fill out the EPROM down to the beginning
        of the startup block */

   filler = (dword)CHIPsize * 1024uL - romlength - startuplength;
   while (filler) {
      temp = filler < sizeof(buffer) ? filler : sizeof(buffer);
      lth = fwrite(buffer, 1, temp, ofile);
      if (lth != temp) printf("EPROMfile write error 3.\n"), exit(1);
      filler -= lth;
      romlength += lth;
   }


/*   The rest of the EPROM is filled with the startup block */

   lth = fread(buffer, 1, (word)startuplength, sfile);
   if (lth != startuplength) printf("STARTUPfile read error.\n"), exit(1);
   temp = fwrite(buffer, 1, lth, ofile);
   if (lth != temp) printf("EPROMfile write error 4.\n"), exit(1);


/*   Seek the EXE file back to the start of the relocation table */

   if (fseek(ifile, (dword)header.reloc_displ, SEEK_SET))
      printf("EXEfile seek error 2.\n"), exit(1);

   temp = 0xFFFF - (ROMsize*64) + 1;
   printf("Relocation constant  0%04Xh\n", temp);


/*   Read the relocation records one at a time, read the segment value
        from the EPROM, relocate it, and write it back to the EPROM. */

   i = header.nreloc;
   while (i) {
      fread((byte*)&reloc, 1, sizeof(reloc), ifile);
      filler = (dword)reloc.segment * 16uL + reloc.offset;
      filler += rombegin;
      fseek(ofile, filler, SEEK_SET);
      fread((byte*)&lth, 1, sizeof(lth), ofile);
      if (verbose)
         printf(" %04X:%04X: %04X -> ", reloc.segment, reloc.offset, lth);
      lth += temp;
      if (verbose) printf("%04X\n", lth);
      fseek(ofile, filler, SEEK_SET);
      fwrite((byte*)&lth, 1, sizeof(lth), ofile);
      i--;
   }

/*   We are done  */

   fclose(ofile);
   fclose(ifile);
   fclose(sfile);

   return 0;
}
