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
*************************************************************************/
/* nvram.c */

#include <stdlib.h>
#include <string.h>
#include "sbc188.h"
#include "sio.h"
#include "equates.h"
#include "ds1302.h"
#include "ide.h"
#include "sdcard.h"
#include "libc.h"

#define	DBG 3
#define CPM_FLOPPIES 0
#define FLOPPY_MAX 2

#define BCD(x) (byte)((x)<100?(((x)/10)<<4)|((x)%10):0xFF)
#define toupper(a) ((a)>='a'&&(a)<='z'?(a)-('a'-'A'):(a))

enum {NO_disk=0, PPI_type=2, DIDE0_type=4, DIDE1_type=6, DSD_type=8};

/* FIXED_DISK_MAX = maximum number of fixed disk drives (bda.inc) */

byte set_battery(byte force)
{
    byte state, diode, resistor;
    int en, rvalid, dvalid;
    char line[80], *cp;

    state = rtc_get_loc(8 | CLOCK);
    en =  state>>4 == 0x0A;
    diode = (state>>2) & 3;
    resistor = state & 3;
    en &= (diode==1 || diode==2);
    en &= (resistor!=0);
    if (en) resistor = 1<<resistor;

    printf("Trickle charge backup is %sabled.\n", en ? "En" : "Dis");
    if (en) printf("   %d diode%s used.  A%s %dK resistor is selected.\n",
                    (int)diode, diode==1 ? " is" : "s are",
                    resistor == 8 ? "n" : "",
                    resistor);
    else state = 0;

    do {
        printf("Diode (0,1,2) & Resistor (2,4,8) [d[+r]]: ");
        GETLINE(line);
        if (*line == 0) return 0;   /* state == 0 */
        cp = strchr(line,'+');
        if (cp) *cp++ = 0;
        diode = atoi(line);
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
    } while (en < 0);
    
    rtc_set_loc(8 | CLOCK, state);

    return state;
}

static const byte dpm0[12] = {31,30,31,30,31, 31,30,31,30,31, 31,28};
static const char * const dow[8] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "???"};
static const char * const month[12] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };


/* Day of the Week calculation:  dow is [0..6] for  [Su..Sa] */

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


const char * const rates[8] = {"1200", "2400", "4800", "9600", "19200", "38400", "57600", "115200"};

byte setup_serial (byte rate)
{
	byte line[10];
	int i;

	while (1) {
		printf ("Serial port baud rate (Kbit/sec) [%s]:", rates[rate]);
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


static const word ftype_OK = 
#if CPM_FLOPPIES
				(1<<10) | (1<<9) | (1<<8) |
#endif
						(1<<4) | (1<<3) | (1<<2) | (1<<1) | 1;

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
#if CPM_FLOPPIES
			 "  (future) CP/M 77track, 128byte/sector:\n"
          "    8 = 512k on 1.2M 5.25\"\n"
          "    9 = 256k on  720K 3.5\"\n"
          "   10 = 512k on 1.44M 3.5\"\n"
#endif
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

int setup_fixed(int nfixed)
{
#if PPIDE_driver
   char line[20];
   int okay;

   do {
      printf("Number (0..2) of [SBC-188] PPIDE fixed disks [%d]: ", nfixed);
      GETLINE(line);
      if (line[0]) nfixed = atoi(line);
      okay = (nfixed >= 0  &&  nfixed <= 2);
   } while (!okay);

   return nfixed;
#else
	return 0;
#endif
}

int setup_dide(int ndide, int secondary)
{
#if DIDE_driver
   char line[20];
   int okay;

   do {
      printf("Number (0..2) of Connector-%s Dual-IDE fixed disks [%d]: ", 
			!secondary ? "A" : "B", ndide);
      GETLINE(line);
      if (line[0]) ndide = atoi(line);
      okay = (ndide >= 0  &&  ndide <= 2);
   } while (!okay);

   return ndide;
#else
	return 0;
#endif
}

int setup_SDcard(int nslot)
{
#if DSD_driver
   char line[20];
   int okay;

   do {
      printf("Number (0..2) of dual SDcard slots [%d]: ", nslot);
      GETLINE(line);
      if (line[0]) nslot = atoi(line);
      okay = (nslot >= 0  &&  nslot <= 2);
   } while (!okay);

   return nslot;
#else
	return 0;
#endif
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
int __cdecl DIDE_READ_ID(byte * far buffer, byte slave, byte secondary);

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

   ms = slave << 4;
   printf("   %s fixed disk %c:    (0x%x)\n", 
			type==PPI_type ? "PPIDE" : type==DIDE0_type ? "DIDE0" : "DIDE1",
			letter, (int)code);
	if (type==PPI_type)
	   PPIDE_READ_ID((void*)&id, ms);
	else
		DIDE_READ_ID((void*)&id, ms, (type - DIDE0_type)/2 );

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

//int __fastcall uart_putchar(int character);
//int __fastcall SDinitcard(int unit);
int __cdecl DSDgetInfo(int unit, byte buffer[36]);

void put_char_array(byte *cp, byte n)
{
	while (n--) uart_putchar(*cp++);
}

int sd_info(int unit, byte code)
{
	dword nsec, serial;
	EDD_DISK *fx;
	byte buffer[40];
	byte *bp = buffer;
	byte *csd, *cid;
	byte i, ms;
	word yr, mo;
	int err, err2, vers, class;
	int lsec, lcyl, lhd, lsectors, tmp;

	err = SDinitcard(unit);
//	printf("SDinitcard = 0x%x\n", err);
	err2 = DSDgetInfo(unit, buffer);
//	printf("SDgetInfo = 0x%x\n", err2);

	csd = buffer+4;
	cid = csd+16;

	printf("SD card[%d]:  ", unit);
	if (err == -4) {
		printf("no card\n\n");
		return err;
	}
	put_char_array(cid+1, 2);
	printf("  ");
	put_char_array(cid+3, 5);
	vers = SDcsd(CSD_STRUCTURE, csd) + 1;
	printf("\nCSD version %d.0   ", vers);

	class = SDcsd(CMD_CLASS, csd);
	printf("Command Classes:  0x%03X (%05o)\n", class, class);

	if (vers==2) { 	/* CSD is version 2 */
#if 0
		nsec = csd[5] & 0x3F;
		nsec = (nsec<<8) + csd[6];
		nsec = (nsec<<8) + csd[7];
#else
		nsec = ((dword)SDcsd(C_SIZE_hi2, csd) << 16) + SDcsd(C_SIZE_lo2, csd);
#endif
		nsec = (nsec+1) << 10;
	}
	else { 			/* CSD is version 1 */
		nsec = SDcsd(C_SIZE, csd);
		nsec <<= SDcsd(C_SIZE_MULT, csd) + 2;
	}
/* now fill in the BDA fx structure */
	fx = p_bda_fx(code);
	{
		lsectors = log2(nsec);		/* log of the number of sectors */
		if (lsectors > 28) {
			lsectors = 28;  /* max disk is 128Gb (2**28 sectors) */
			nsec =  0x0FFFFFFFuL;
		}
		tmp = lsectors - 10;			/* up to 1024 cylinders */
		if (tmp > 12) tmp = 12;		/* hd=128, sec=32  (7+5) is the limit */
		else if (tmp < 8) tmp = 8;	  /* hd=16, sec=16 (4+4) is low limit */
		lcyl = lsectors - tmp;
		lsec = tmp / 2;
		if (lsec > 5) lsec = 5;		/* max(lsed) == 5 */
		lhd = tmp - lsec;				/* max(lhd) == 7 */
	}
	fx->LBA_low = (word)nsec;
	fx->LBA_high = (word)(nsec>>16);	/* limit to 28 bits */
	fx->log_sectors = fx->phys_sectors = 1<<lsec;
	fx->log_heads = fx->phys_heads = 1<<lhd;
	fx->log_cylinders = fx->phys_cylinders = (word)(nsec>>tmp);
	fx->drive_control = DC_ONES | DC_LBA | (unit ? DC_SLAVE : DC_MASTER);

	serial = 0;
	bp = cid+9;
	for (i=0; i<4; i++) serial = (serial<<8) | *bp++;
	yr = (cid[13]<<4) | (cid[14]>>4);
	mo =  cid[14] & 15;

	printf("s/n:%20ld   fmw:  %d.%d   d/c:  %d-%02d\n", serial,
				(int)(cid[8]>>4), (int)(cid[8]&15), yr+2000, mo);
	printf("LBASupported    UserAddressableSectors %ld\n", nsec);

#if 1
	printf("   C=%d   H=%d   S=%d\n", (int)fx->log_cylinders,
		(int)fx->log_heads, (int)fx->log_sectors);
#endif

#if 0
	if (unit > maxunit) maxunit = unit;
#endif

/* compute the checksum of the EDD_DISK table */
   bp = (byte*)fx;
   ms = 0;
   for (i=0; i < sizeof(EDD_DISK)-1; i++) ms += *bp++;
   fx->checksum = -ms;

	printf("\n");
	return err;
}

void __fastcall setup_SD_card(char letter, byte code, byte type, byte slave)
{

   printf("   %s fixed disk %c:    (0x%x)\n", "SDcard",
			letter, (int)code);
	sd_info(slave, code);
}


//extern const byte IDE_precedence;
void __fastcall nvram_apply(void)
{
	int i, j, units = 0;
	byte ftype;
	word n_ppi, n_dide0, n_dide1, n_dsd;
	union {
		struct {
			word ppide : 2;
			word dide0 : 2;
			word dide1 : 2;
			word dsd	  : 2;
			word unused : 8;
		} bits;
		word bdisk;
	} num_disk;

	for (i = 0; i < FLOPPY_MAX; i++) {
		ftype = rtc_get_loc(RAM_floppy + i | RAM);
		if (ftype==4) ftype |= 0x30;		/* type 3 (720K) also possible */
		bios_data_area_ptr->fdc_type[i] = ftype;
		if (ftype) {
/***			bios_data_area_ptr->fdc_fd[i].status_sw = 1;  ***/
			printf("Floppy %c: type %d\n", i + 'A', ftype & 0x0F);
			units++;
#if 0
		} else {
			bios_data_area_ptr->fdc_fd[i].status_sw = 0;
#endif
		}
	}
	bios_data_area_ptr->equipment_flag.has_floppy = units ? 1 : 0;
	bios_data_area_ptr->equipment_flag.floppies = units ? units - 1 : 0;

/* the fixed disk setup */
	num_disk.bdisk = 0;
   units = rtc_get_loc(RAM_fx_dide | RAM);  /* get number of DIDE fixed disks */
	n_dide0 = units & 3;
	n_dide1 = (units>>4) & 3;
	num_disk.bits.dide0 = n_dide0;
	num_disk.bits.dide1 = n_dide1;
   n_ppi = rtc_get_loc(RAM_fixed | RAM);  /* get number of PPIDE fixed disks */
	n_ppi &= 3;
	num_disk.bits.ppide = n_ppi;
   n_dsd = rtc_get_loc(RAM_fx_dsd | RAM);  /* get number of SDcard slots */
	num_disk.bits.dsd = n_dsd;

   bios_data_area_ptr->n_fixed_disks = (byte)num_disk.bdisk;
   bios_data_area_ptr->equipment_flag.printers = n_ppi ? 0 : 1;

	units = n_ppi + n_dide0 + n_dide1 + n_dsd;

	printf("\nPPI=%d  DIDE0=%d  DIDE1=%d  DSD=%d  Units=%d   bdisk=%02x\n",
		n_ppi, n_dide0, n_dide1, n_dsd, units, num_disk.bdisk);

   printf("\n");

	if (units>FIXED_DISK_MAX) units=FIXED_DISK_MAX;

	i = 0;
	for (j=0; j<n_ppi && i<units; j++, i++)
		bios_data_area_ptr->fixed_disk_tab[i] = PPI_type | j;
	for (j=0; j<n_dide0 && i<units; j++, i++)
		bios_data_area_ptr->fixed_disk_tab[i] = DIDE0_type | j;
	for (j=0; j<n_dide1 && i<units; j++, i++)
		bios_data_area_ptr->fixed_disk_tab[i] = DIDE1_type | j;
	for (j=0; j<n_dsd && i<units; j++, i++)
		bios_data_area_ptr->fixed_disk_tab[i] = DSD_type | j;
	for (; i<FIXED_DISK_MAX; i++)
		bios_data_area_ptr->fixed_disk_tab[i] = NO_disk;

	i = 0;
/* set up the PPIDE disks first, if they have highest precedence */
	for (j=0; j<n_ppi && i<units; j++, i++)
     	setup_fixed_disk('C'+i, 0x80+i, PPI_type, j);		

/* set up the DIDE disks   */
	for (j=0; j<n_dide0 && i<units; j++, i++)
      	setup_fixed_disk('C'+i, 0x80+i, DIDE0_type, j);

	for (j=0; j<n_dide1 && i<units; j++, i++)
      	setup_fixed_disk('C'+i, 0x80+i, DIDE1_type, j);

/* set up the Dual SDcard slots */
	for (j=0; j<n_dsd && i<units; j++, i++)
      	setup_SD_card('C'+i, 0x80+i, DIDE1_type, j);

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
    ram[RAM_fixed] = setup_fixed(ram[RAM_fixed]);
	 i = setup_dide(ram[RAM_fx_dide] & 0x0F, 0);
	 ram[RAM_fx_dide] = i |	setup_dide(ram[RAM_fx_dide]>>4, 1) << 4;
	 ram[RAM_fx_dsd] = setup_SDcard(ram[RAM_fx_dsd]);
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
