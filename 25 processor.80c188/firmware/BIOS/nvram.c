/*************************************************************************
*  nvram.c   for the N8VEM  SBC-188
**************************************************************************
*
*   Copyright (C) 2010 John R. Coffman.  All rights reserved.
*   Provided for hobbyist use on the N8VEM SBC-188 board.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
* Modified for Duodyne SBC80188 by Dan Werner 11/2024
*************************************************************************/

#include <stdlib.h>
#include <string.h>
#include "sbc188.h"
#include "sio.h"
#include "equates.h"
#include "ds1302.h"
#include "ide.h"
#include "libc.h"


#define	DBG 3
#define FLOPPY_MAX 2
#define UART_CLOCK  1843200
#define BAUDR	     9600
#define BAUD_DIVISOR  UART_CLOCK/16/BAUDR
#define UART_DLL	0
#define UART_DLM	1
#define UART_IER	1
#define UART_FCR	2
#define	UART_LCR	3
#define	UART_MCR	4


#define BCD(x) (byte)((x)<100?(((x)/10)<<4)|((x)%10):0xFF)
#define toupper(a) ((a)>='a'&&(a)<='z'?(a)-('a'-'A'):(a))

enum {NO_disk=0, PPI_type=2, USB_type=4, DIDE1_type=6, DSD_type=8,
	V3IDE8_type=10, DISKIO_type=12, MFPIC_type=14 };

static const byte dpm0[12] = {31,30,31,30,31, 31,30,31,30,31, 31,28};
static const char * const dow[8] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "???"};
static const char * const month[12] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };

const char * const rates[8] = {"1200", "2400", "4800", "9600", "19200", "38400", "57600", "115200"};

static const word ftype_OK =	(1<<4) | (1<<3) | (1<<2) | (1<<1) | 1;

extern char unique[];			/* in copyrght.asm */


byte set_battery(byte force)
{
    byte state, diode, resistor;
    int en, rvalid, dvalid;
    char line[80], *cp;

    state = rtc_get_loc(8 | CLOCK);
    en =  (state & 0xF0) == 0xA0;
    diode = (state>>2) & 3;
    resistor = state & 3;
    en &= (diode==1 || diode==2);
    en &= (resistor!=0);
    if (en) resistor = 1<<resistor;
    else diode = 0;	/* not enabled */

    printf("Trickle charge backup is %sabled.\n", en ? "En" : "Dis");
    if (en) printf("   %d diode%s used.  A%s %dK resistor is selected.\n",
                    (int)diode, diode==1 ? " is" : "s are",
                    resistor == 8 ? "n" : "",
                    resistor);
    else state = 0;

    do {
//        printf("Diode (0,1,2) & Resistor (2,4,8) [d[+r]]: ");
	printf("NVRAM backup:  0=disable, 1=Supercap(4.3v), 2=Nicad/LiIon(3.6v) [%d]: ", (int)diode);
        GETLINE(line);
//        if (*line == 0) return 0;   /* state == 0 */
//        cp = strchr(line,'+');
//        if (cp) *cp++ = 0;
//        diode = atoi(line);
	en = 1;
	cp = line;
	while (*cp == ' ' || *cp == '\t') cp++;		/* remove white spaces */
	if (*cp != 0) diode = atoi(cp);
	if (diode == 0) state = 0;
	else if (diode == 1) state = 0xA0 | 4 | 1;	/* 1 diode, 2K resistor */
	else if (diode == 2) state = 0xA0 | 8 | 2;	/* 2 diodes, 4K resistor */
	else en = -1;

#if 0
        if (cp) resistor = atoi(cp);
        rvalid = resistor==2 || resistor==4 || resistor==8;
        dvalid = diode==1 || diode==2;
        if (rvalid && dvalid) {
            en = 1;
            resistor>>=1;
            if (resistor==4) resistor--;
            state = (diode<<2) | resistor | 0xA0;
        }
        else if (resistor==0 || diode==0) {
            state = resistor = en = diode = 0;
        }
        else en = -1;
#endif
    } while (en < 0);

    rtc_set_loc(8 | CLOCK, state);

    return state;
}

int idow(int da, int mo, int yr)
{
    int leap = 0;
    int ce = yr/100;
    int y = yr%100;
    int i;
    byte dpm[12];

    for (i=0; i<12; i++) dpm[i]=dpm0[i];
/* return 99 on error */
    if (yr < 1583  ||  yr > 9999  ||  mo < 1  ||  mo > 12  ||
           da < 1  ) return 99;
/* 1582 was the year of the change to the Gregorian calendar */

    leap = ( (y%4 == 0 && y != 0) || yr%400 == 0 );
    dpm[11] += leap;
    mo = mo - 3;
    if (mo < 0) {
        mo += 12;
        yr--;
    }
    if (da > dpm[mo]) return 98;
    ce = yr/100;
    yr = yr%100;
    for (leap=0; leap<mo; ++leap) da += dpm[leap];
    da += 5*ce + yr + yr/4 + ce/4 + 2;

    return (da % 7);
}

int Date(byte *ram)
{
    byte da, mo, dw, yr, ce;
    int day, mon, year, tem;
    char line[80];
    char *cp, *tp;

    da = rtc_get_loc( 3 | CLOCK);
    mo = rtc_get_loc( 4 | CLOCK);
    dw = rtc_get_loc( 5 | CLOCK);
    yr = rtc_get_loc( 6 | CLOCK);
    ce = rtc_get_loc( 1 | RAM);
    if (dw<1 || dw >7) dw = 8;
    if (ce==0) {
    	da=mo=1;
    	dw=3;
    	yr=0x80;
    	ce=0x19;
    }
    else ram[ RAM_century ] = ce;

    printf("Date read:  %s %02x/%02x/%02x%02x\n", dow[dw-1],
                    (int)mo, (int)da, (int)ce, (int)yr );

    printf("Date [mm/dd/yyyy]: ");
    GETLINE(line);
    if (*line==0)  return 0;

    cp = strchr(line,'/');
    if (!cp) return 0;
    *cp++ = 0;
    mon = atoi(line);

    tp = strchr(cp,'/');
    if (!tp) return 0;
    *tp++ = 0;
    day = atoi(cp);
    year = atoi(tp);
    if (year<=99) {
    	if (year<80) year += 100;
    	year += 1900;
    }
    printf("Binary date:  %d/%d/%d\n", mon, day, year);
    mo = BCD(mon);
    da = BCD(day);
    tem = year/100;
    ce = BCD(tem);
    tem = year%100;
    yr = BCD(tem);
    dw = idow(day, mon, year);
    if (dw > 7) {
        printf("Invalid date entered.  (code %d)\n", (int)dw);
        return 0;
    }
    ++dw;
    printf("BCD date to be set to DS1302:  %02x/%02x/%02x%02x  dow(%x)\n",
                    (int)mo, (int)da, (int)ce, (int)yr, (int)dw );
    rtc_WP(0);
    rtc_set_loc( 3 | CLOCK, da);
    rtc_set_loc( 4 | CLOCK, mo);
    rtc_set_loc( 5 | CLOCK, dw);
    rtc_set_loc( 6 | CLOCK, yr);
    ram[ RAM_century ] = ce;
/*    rtc_set_loc( 1 | RAM, ce);   */

    return (int)ce;
}

void Time(void)
{
    char line[80];
    char *cp, *tp;
    word hr, min, sec;

    sec = rtc_get_loc(0 | CLOCK);
    min = rtc_get_loc(1 | CLOCK);
    hr  = rtc_get_loc(2 | CLOCK);

    if (sec & 0x80) printf("The clock is stopped.\n");
    else printf("Time read:  %02x:%02x:%02x\n", hr, min, sec);

        do {
            printf("Time [hh:mm[:ss]]: ");
            GETLINE(line);
            if (*line == 0) return;

            cp = strchr(line,':');
            if (!cp) continue;
            *cp++ = 0;
            hr = atoi(line);
            tp = strchr(cp,':');
            if (!tp) sec = 0;
            else *tp++ = 0;
            min = atoi(cp);
            if (tp) sec = atoi(tp);
        } while (hr>23 || min>59 || sec>59);
        printf("Read in %d:%02d:%02d\n", hr, min, sec);
        sec = BCD(sec);
        rtc_set_loc( 0 | CLOCK, (byte)(sec | 0x80));  	/* stop the clock */
        rtc_set_loc( 1 | CLOCK, BCD(min));
        rtc_set_loc( 2 | CLOCK, BCD(hr));
        rtc_set_loc( 0 | CLOCK, (byte)sec);		/* start the clock */

    return;
}

byte setup_serial (byte rate)
{
	byte line[10];
	int i;

	while (1) {
		printf ("Serial console port speed (bits/sec) [%s]:", rates[rate]);
		GETLINE(line);
		if (line[0] == '\0')
			break;
		for (i = 0; i < 8; i++) {
			if (!strcmp (line, rates[i])) {
				rate = i;
				break;
			}
		}
		if (i != 8)
			break;
		else {
			printf ("Invalid selection, supported values are:");
			for (i = 0; i < 8; i++)
				printf (" %s", rates[i]);
			printf ("\n");
		}
	}
	return rate;
}



int floppy_ask(byte *ram, int i)
{
   byte line[20];
   int okay;
   char ch, letter;
   byte ftype;

   ram += RAM_floppy + i;
   letter = 'A'+i;
   do {
      ftype = *ram & 15;
      printf("Drive %c: disk type [%d]: ", letter, ftype);
      GETLINE(line);
      if (line[0]) ftype = atoi(line);
      okay = !!(ftype_OK & (1<<ftype));
   } while (!okay);
   *ram = ftype;
	if (ftype==0 && i==0) *(ram+1) = 0;  /* no B: drive without an A: drive */

   return ftype;
}

void Floppy(byte *ram)
{
   int i, ftype;
   word units = 0;

   printf("Floppy Types are:\n"
          "    0 = not present\n"
          "    1 = 360K 5.25\"\n"
          "    2 = 1.2M 5.25\"\n"
          "    3 =  720K 3.5\"\n"
          "    4 = 1.44M 3.5\"\n"
			 	);
   ftype = 1;
   for (i=0; ftype && i<FLOPPY_MAX; i++) {
      units += !!(ftype = floppy_ask(ram,i));
   }
   if (units>1) printf("*** With two floppies, an IBM cable with at twist is MANDATORY. ***\n");
   else if (units) printf("Connect a single floppy with a cable with no twist.\n");
}

int __fastcall nvram_check(void)
{
		int i;
	byte checksum = 0;

	for (i = 0; i < RAM_length; i++)
		checksum += rtc_get_loc(i | RAM);
	return checksum == NVRAM_MAGIC ? 0 : 1;
}


int setup_ppide(int nfixed)
{
#if PPIDE_driver
   char line[20];
   int okay;

   do {
      printf("Number (0..2) of Duodyne DiskIO PPIDE fixed disks [%d]: ", nfixed);
      GETLINE(line);
      if (line[0]) nfixed = atoi(line);
      okay = (nfixed >= 0  &&  nfixed <= 2);
   } while (!okay);

   return nfixed;
#else
	return 0;
#endif
}

int setup_usb(int nfixed)
{
#if USB_driver
   char line[20];
   int okay;

   do {
      printf("Number (0..2) of Duodyne USB fixed disks [%d]: ", nfixed);
      GETLINE(line);
      if (line[0]) nfixed = atoi(line);
      okay = (nfixed >= 0  &&  nfixed <= 2);
   } while (!okay);

   return nfixed;
#else
	return 0;
#endif
}


int setup_fixed_boot(byte ram[])
{
    int ndisks, diskno;
    int i;
    char line[20];

    diskno = ram[RAM_fx_boot];
    ndisks = 0;
    for (i = RAM_fixed; i < RAM_fx_boot; i++)
        ndisks += ram[i];
    i = 1;
    if (ndisks > 4) ndisks = 4;
    else if (ndisks <= 1) {
    	diskno = ndisks;
    	i = 0;
    }

    if (diskno > ndisks || diskno == 0) diskno = 1;

    while (i) {
    	printf("Make disk [1..%d] the C: drive [%d]: ", ndisks, diskno);
    	GETLINE(line);
    	if (line[0]) {
    	    diskno = atoi(line);
    	    if (diskno > 0 && diskno <= ndisks) i = 0;
    	} else i = 0;
    }

    return diskno;
}

int setup_boot_sig_check(int bits)
{
   char line[20];
   unsigned int check;

   check = !(bits & RAM_bits_AA55);
   do {
      printf("Check DOS boot signature [%s]: ", check ? "Y/n" : "N/y");
      GETLINE(line);
      if (line[0]) {
         switch(line[0]) {
         case 'y':
         case 'Y':
         case '1':
            check = 1;
            break;
         case 'n':
         case 'N':
         case '0':
            check = 0;
            break;
         default:
            check = 2;
         }
      }
   } while (check > 1);

   if (check==0) bits |= RAM_bits_AA55;   /* suppress the boot sig. check */
   else bits &= ~RAM_bits_AA55;           /* enable the boot sig. check */

   return bits;
}

void putstring(byte *cp, int length)
{
    int i;
    byte *tp;
    char str[127];

    tp = (char*)str;
// swap all of the bytes in the 16-bit words
    for (i=0; i<length; i+=2) {
       *tp++ = *++cp;
       *tp++ = cp[-1];
       cp++;
    }
    *tp = 0;
// remove blanks from the end of the string
    while (tp > str  &&  tp[-1] <= ' ') *--tp = 0;

    tp = (char*)str;
// remove blanks from the start of the string
    while (*tp && *tp <= ' ') ++tp;

    printf("%s", tp);
}


#define PRINT(s) putstring(s,nelem(s))


int __cdecl PPIDE_READ_ID(byte * far buffer, byte slave);
/* PPIDE must be set in config.asm until this routine is moved to ppide.asm */
int __cdecl USB_READ_ID(byte * far buffer, byte unit);

EDD_DISK *p_bda_fx(byte code)
{
	dword vector;
	EDD_DISK *fx;

   fx = &(bios_data_area_ptr->fx80);
	if (code==0x80)	vector = 4*0x41;
   else if (code==0x81)	vector = 4*0x46;
	else vector = 0;
	fx += (code & 0x0F);
   if (vector)  *((EDD_DISK**)vector) = fx;

	return fx;
}

void __fastcall setup_fixed_disk(char letter, byte code, byte type, byte slave)
{
   byte ms, *fp, trans;
   int i;
   EDD_DISK *fx;
   word heads, sectors;
   dword vector, cylinders, lba_sectors;
   IDENTIFY_DEVICE_DATA id;
   byte *dbg;

   ms = slave << 4;
     printf("   %s fixed disk %c:    (0x%x)\n",
			type==PPI_type ? "PPIDE" : type==USB_type ? "USB" : "UNKNOWN",
			letter, (int)code);
	if (type==PPI_type)
   {
	   PPIDE_READ_ID((void*)&id, ms);
   }

   if (type==USB_type)
   {
      USB_READ_ID((void*)&id, ms);
   }

   printf("Model: "); PRINT(id.ModelNumber);
   printf("\nSerial: "); PRINT(id.SerialNumber);
   printf("\nFirmware: "); PRINT(id.FirmwareRevision);

   printf("\nGeometry:  %u:%u:%u   with%s LBA support\n", id.NumCylinders, id.NumHeads,
         id.NumSectorsPerTrack, id.Capabilities.LbaSupported?"":"out");
   printf("Current:   %u:%u:%u   capacity:  %lu\n", id.NumberOfCurrentCylinders, id.NumberOfCurrentHeads,
         id.CurrentSectorsPerTrack, id.CurrentSectorCapacity);
   printf("LBA Sectors:  %lu", id.UserAddressableSectors);
   printf("   (48-bit):  0x%lx%08lx\n", id.Max48BitLBA[1], id.Max48BitLBA[0]);

	fx = p_bda_fx(code);

   fx->phys_cylinders = cylinders = id.NumCylinders;
   fx->phys_heads = heads = id.NumHeads;
   fx->phys_sectors = sectors = id.NumSectorsPerTrack;
   fx->drive_control = DC_ONES | (ms ? DC_SLAVE : DC_MASTER) | type;
   if (id.Capabilities.LbaSupported) {
      fx->LBA_low  = (word)id.UserAddressableSectors;
      fx->LBA_high = (word)(id.UserAddressableSectors>>16) & 0x0FFF;
      fx->reserved7 = (word)(id.UserAddressableSectors>>28);
      fx->drive_control |= DC_LBA;
   }
   else {
      fx->LBA_low  = (word)id.CurrentSectorCapacity;
      fx->LBA_high = (word)(id.CurrentSectorCapacity>>16) & 0x0FFF;
   }
/* set up for translated geometry if cylinders>1024 */
   trans = 0;     /* no translation */
   if (cylinders == 0) cylinders = 65536UL;
/***lba_sectors = cylinders * heads * sectors; ***/
   lba_sectors = mulLS( mulLS(cylinders, heads), sectors);
   while (cylinders > 1024 && heads < 255) {
      heads *= 2;
      if (heads > 255) heads = 255;
/***  cylinders = lba_sectors / sectors / heads; ***/
      cylinders = divLS( divLS(lba_sectors, sectors), heads);
      trans = DC_ONES;  /* flag translation will occur */
   }
   if (cylinders > 1024 && sectors < 63) {
      sectors = 63;
/***  cylinders = lba_sectors / sectors / heads; ***/
      cylinders = divLS( divLS(lba_sectors, sectors), heads);
      trans = DC_ONES;  /* flag translation will occur */
   }
   if (cylinders > 1024) cylinders = 1024;
   fx->log_cylinders = cylinders;
   fx->log_heads = heads;     /* 256 heads will truncate to 00 */
   fx->log_sectors = sectors;
   fx->signature = trans;     /* 00 if no translation, A0h if translated geometry */
   if (trans == DC_ONES) {
      lba_sectors = mulLS( mulLS(cylinders, heads), sectors);
      printf("Translated geometry:  %u:%u:%u   capacity:  %ld\n",
                                 (word)cylinders, heads, sectors, lba_sectors);
   }
/* compute the checksum of the EDD_DISK table */
   fp = (byte*)fx;
   ms = 0;
   for (i=0; i < sizeof(EDD_DISK)-1; i++) ms += *fp++;
   fx->checksum = -ms;

   printf("\n");
}


void put_char_array(byte *cp, byte n)
{
	while (n--) uart_putchar(*cp++);
}

//extern const byte IDE_precedence;
void __fastcall nvram_apply(void)
{
	int i, j, units = 0;
	byte ftype;
	word n_ppi, n_usb;
	union {
		struct {
			word ppide : 2;
			word usb : 2;
			word unused : 12;
		} bits;
		word bdisk;
	} num_disk;

	for (i = 0; i < FLOPPY_MAX; i++) {
		ftype = rtc_get_loc(RAM_floppy + i | RAM);
		if (ftype==4) ftype |= 0x30;		/* type 3 (720K) also possible */
		bios_data_area_ptr->fdc_type[i] = ftype;
		if (ftype) {
			printf("Floppy %c: type %d\n", i + 'A', ftype & 0x0F);
			units++;
		}
	}

	bios_data_area_ptr->equipment_flag.has_floppy = units ? 1 : 0;
	bios_data_area_ptr->equipment_flag.floppies = units ? units - 1 : 0;

/* the fixed disk setup */
	num_disk.bdisk = 0;
   units = rtc_get_loc(RAM_fx_usb | RAM);  /* get number of usb fixed disks */
	n_usb = units & 3;
	num_disk.bits.usb = n_usb;
   n_ppi = rtc_get_loc(RAM_fixed | RAM);  /* get number of PPIDE fixed disks */
	n_ppi &= 3;
	num_disk.bits.ppide = n_ppi;

   bios_data_area_ptr->n_fixed_disks = (byte)num_disk.bdisk;
   bios_data_area_ptr->equipment_flag.printers = n_ppi ? 0 : 1;

	units = n_ppi + n_usb;

	printf("\nPPI=%d  USB=%d  Units=%d   bdisk=%02x\n",
		n_ppi, n_usb, units, num_disk.bdisk);

   printf("\n");

	if (units>FIXED_DISK_MAX) units=FIXED_DISK_MAX;

	i = 0;
	for (j=0; j<n_ppi && i<units; j++, i++)
		bios_data_area_ptr->fixed_disk_tab[i] = PPI_type | j;
	for (j=0; j<n_usb && i<units; j++, i++)
		bios_data_area_ptr->fixed_disk_tab[i] = USB_type | j;
	for (; i<FIXED_DISK_MAX; i++)
		bios_data_area_ptr->fixed_disk_tab[i] = NO_disk;

	i = 0;
/* set up the PPIDE disks first, if they have highest precedence */
	for (j=0; j<n_ppi && i<units; j++, i++)
     	setup_fixed_disk('C'+i, 0x80+i, PPI_type, j);

/* set up the USB disks   */
	for (j=0; j<n_usb && i<units; j++, i++)
      	setup_fixed_disk('C'+i, 0x80+i, USB_type, j);

#if DBG>=3
	printf("\nFixed_Disk_Tab: ");
	for (i=0; i<FIXED_DISK_MAX; i++) printf(" %02x",
					(int)(bios_data_area_ptr->fixed_disk_tab[i]) );
	printf("\n\n");
#endif

}

void __fastcall nvram_setup(void)
{
	byte ram[RAM_length];
	int i;
	byte stopped;
	byte checksum = 0;

 	if (nvram_check()) {
		printf ("NVRAM checksum is invalid\n");
		for (i=0; i<31; ++i)
			ram[i] = 0;
		ram[RAM_serial] = 3;	/* default to 3 = 9600 Kbit/sec */
	} else {
		printf ("NVRAM checksum is valid\n");
		for (i=0; i<RAM_length; ++i)
 			ram[i] = rtc_get_loc(i | RAM);
	}

    stopped = rtc_get_loc(0 | CLOCK) & 0x80;
    if (stopped) printf("The clock is stopped.\n");
    else printf("The clock is running.\n");

    rtc_WP(0);
    Date(ram);		/* RAM[1] is the century in BCD; e.g., 0x19 or 0x20 */
    Time();		/* show/set the time */

    Floppy(ram);
    ram[RAM_trickle] = set_battery(0);	/* RAM[0] is the state of the trickle charger */

	 printf("   Fixed Disk Setup\n");
   ram[RAM_fixed] = setup_ppide(ram[RAM_fixed]);
   ram[RAM_fx_usb] = setup_usb(ram[RAM_fx_usb]);
    ram[RAM_bits] = setup_boot_sig_check(ram[RAM_bits]);

    ram[RAM_serial] = setup_serial(ram[RAM_serial]);

    for (checksum=i=0; i<30; ++i) checksum -= ram[i];
    ram[ RAM_checksum ] = checksum + NVRAM_MAGIC;
    for (i=0; i<31; ++i) rtc_set_loc( i | RAM, ram[i]);

    rtc_WP(1);

}
int __fastcall nvram_get_video(int default_rate)
{
	int rate;
	if (nvram_check())
		/* NVRAM checksum is invalid - return the default */
		rate = default_rate;
	else
		/* read the UART rate from NVRAM */
		rate = rtc_get_loc(RAM_serial | RAM);

	if (rate > 7)
		/* invalid value, set to the default */
		rate = default_rate;

	return rate;
}
