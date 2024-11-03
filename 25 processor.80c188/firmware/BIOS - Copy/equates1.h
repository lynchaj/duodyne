#ifndef __EQUATES_H
#define __EQUATES_H
#include "mytypes.h"

#ifndef NULL
#define NULL ((void*)0UL)
#endif

#pragma pack(1)

typedef
struct EquipmentFlag {
   word  has_floppy  : 1;     /* has 1..4 floppies */
   word  has_187     : 1;     /* Has Emulator ??? */
   word  has_pointer : 1;     /* PS/2       (bit 2)*/
   word  unused      : 1;     /* bits 2-3 were RAM size on the PC */
   word  video_mode  : 2;     /* Initial Video Mode */
   word  floppies    : 2;     /* 0..3 means 1..4 floppies if 'has_floppy' set */
   word  reserved    : 1;
   word  com_ports   : 3;     /* number of COM ports (we got 0) */
   word  game_adapter: 1;     /* has a game adapter */
   word  modem_ser_pr: 1;     /* modem or serial printer */
   word  printers    : 2;     /* number of printer ports (we got 0) */
} EQFL;

#define FDC_DRIVE_PRESENT  1
#define FDC_DRIVE_READY    2



typedef
struct EDD_disk {
   word  log_cylinders;    /* logical cylinders (max 1024) */
   byte  log_heads;        /* logical heads (0==>max of 256) */
   byte  signature;        /* A0h means translated geometry */
   byte  phys_sectors;     /* physical sectors per track (max 63) */
   word  LBA_high;         /* [precomp] high word of LBA max, or 0 */
   byte  reserved7;        /* reserved, for the moment */

/* the following bitfields form the high byte of the IDE Head register
   byte  reserved8_03 : 4; // Must Be Zero 
   byte  master_slave : 1; // 0 = master, 1 = slave 
   byte  one5         : 1; // Must Be One 
   byte  lba_flag     : 1; // 1 = LBA okay, 0 = only CHS 
   byte  one7         : 1; // Must Be One */

   byte  drive_control;    /* bitfields as above:  A0 = CHS master, F0 = LBA slave */

   word  phys_cylinders;   /* physical cylinders, (0==>max of 65536) */
   byte  phys_heads;       /* physical heads (max 16) */
   word  LBA_low;          /* [land zone] low word of LBA max, or 0 */
   byte  log_sectors;      /* logical sectors per track (max 63) */
   byte  checksum;         /* sum of 16 bytes must be zero */
} EDD_DISK;

/* the drive_control bit definitions */
#define DC_ONES   0xA0
#define DC_LBA    0x40
#define DC_MASTER 0x00
#define DC_SLAVE  0x10

typedef
union {
	word w;
	struct {
		byte	x,y;
	} b;
	struct {
		byte lo,hi;
	} reg;
} T_CURSOR_POSITION;

#if 0
#include "bda.inc"
#else
extern struct BiosDataArea // data	SEGMENT at 40h
{
   word serial_ports[4];
// 	dw	4 dup(?)	; 40:00 	; RS232 com. ports - up to four
   word parallel_ports[4];
// 	dw	4 dup(?)	; 40:08 	; Printer ports    - up to four
   EQFL equipment_flag;
// 	dw	?		; 40:10 	; Equipment present word
// 						;  = (1 iff floppies) *     1.
//                   ;  + (1 iff 187     ) *     2.
// 						;  + (#+1 64K sys ram) *    4.
// 						;  + (init crt mode ) *    16.
// 						;  + (# of floppies ) *    64.
// 						;  + (# serial ports) *   512.
// 						;  + (1 iff toy port) *  4096.
//                   ;  + (1 iff modem   ) *  8192.
// 						;  + (# parallel LPT) * 16384.
   byte mfg_test_flags;
// 	db	?		; 40:12 	; MFG test flags, unused by us
   word memory_size;
// 	dw	?		; 40:13 	; Memory size, kilobytes
   byte IPL_errors;
// 	db	?		; 40:15 	; IPL errors<-table/scratchpad
   byte unused_01;
// 	db	?				;  ...unused
// ;---------------[Keyboard data area]------------;
//   byte keyboard_flags_0;
   word keyboard_flags_0;
//   byte keyboard_flags_1;
// 	db	?,?		; 40:17 	; Shift/Alt/etc. keyboard flags
   byte keypad_char;
// 	db	?		; 40:19 	; Alt-KEYPAD char. goes here
   word kbd_buffer_head;
// 	dw	?		; 40:1A 	;  --> keyboard buffer head
   word kbd_buffer_tail;
// 	dw	?		; 40:1C 	;  --> keyboard buffer tail
   word kbd_buffer[16];
// 	dw	16 dup(?)	; 40:1E 	; Keyboard Buffer (Scan,Value)
// ;---------------[Diskette data area]------------;
   byte fdc_drv_calib;
// 	db	?		; 40:3E 	; Drive Calibration bits 0 - 3
   byte fdc_motor_on;
// 	db	?		; 40:3F 	; Drive Motor(s) on 0-3,7=write
   byte fdc_motor_ticks;
// 	db	?		; 40:40 	; Ticks (18/sec) til motor off
   byte fdc_status;
// 	db	?		; 40:41 	; Floppy return code stat byte
// 						;  1 = bad ic 765 command req.
// 						;  2 = address mark not found
// 						;  3 = write to protected disk
// 						;  4 = sector not found
// 						;  8 = data late (DMA overrun)
// 						;  9 = DMA failed 64K page end
// 						; 16 = bad CRC on floppy read
// 						; 32 = bad NEC 765 controller
// 						; 64 = seek operation failed
// 						;128 = disk drive timed out
   byte fdc_ctrl_status[7];
// 	db	7 dup(?)	; 40:42 	; Status bytes from NEC 765
// ;---------------[Video display area]------------;
   byte video_mode;
// 	db	?		; 40:49 	; Current CRT mode  (software)
// 						;  0 = 40 x 25 text (no color)
// 						;  1 = 40 x 25 text (16 color)
// 						;  2 = 80 x 25 text (no color)
// 						;  3 = 80 x 25 text (16 color)
// 						;  4 = 320 x 200 grafix 4 color
// 						;  5 = 320 x 200 grafix 0 color
// 						;  6 = 640 x 200 grafix 0 color
// 						;  7 = 80 x 25 text (mono card)
   word video_columns;
// 	dw	?		; 40:4A 	; Columns on CRT screen
   word video_regen_bytes;
// 	dw	?		; 40:4C 	; Bytes in the regen region
   word video_regen_offset;
// 	dw	?		; 40:4E 	; Byte offset in regen region
   T_CURSOR_POSITION video_cursor_pos[8];
// 	dw	8 dup(?)	; 40:50 	; Cursor pos for up to 8 pages
   word video_cursor_mode;
// 	dw	?		; 40:60 	; Current cursor mode setting
   byte video_page;
// 	db	?		; 40:62 	; Current page on display
   word video_base_seg;
// 	dw	?		; 40:63 	; Base addres (B000h or B800h)
   byte video_hw_mode;
// 	db	?		; 40:65 	; ic 6845 mode reg. (hardware)
   byte video_cga_palette;
// 	db	?		; 40:66 	; Current CGA palette
// ;---------------[Used to setup ROM]-------------;
   dword eprom_address;
// 	dw	?,?		; 40:67 	; Eprom base Offset,Segment
   byte spurious_irq;
// 	db	?		; 40:6B 	; Last spurious interrupt IRQ
// ;---------------[Timer data area]---------------;
   dword timer_ticks;
// 	dw	?		; 40:6C 	; Ticks since midnite (lo)
// 	dw	?		; 40:6E 	; Ticks since midnite (hi)
   byte timer_new_day;
// 	db	?		; 40:70 	; Non-zero if new day
// ;---------------[System data area]--------------;
   byte break_flag;
// 	db	?		; 40:71 	; Sign bit set iff break
   word warm_boot;
// 	dw	?		; 40:72 	; Warm boot iff 1234h value
// ;---------------[Hard disk scratchpad]----------;
   dword hdd_scratch;
// 	dw	?,?		; 40:74 	;
// ;---------------[Timout areas/PRT/LPT]----------;
   byte lpt_timeout[4];
// 	db	4 dup(?)	; 40:78 	; Ticks for LPT 1-4 timeouts
   byte com_timeout[4];
// 	db	4 dup(?)	; 40:7C 	; Ticks for COM 1-4 timeouts
// ;---------------[Keyboard buf start/end]--------;
//   word kbd_buffer_start;
// 	dw	?		; 40:80 	; Contains 1Eh, buffer start
//   word kbd_buffer_end;
// ;
	dword unused_spacer;
   byte EGA_data[64];   //                      ; unspecified


//
   byte EMS_start;      //  Start EMS allocation from here (0==not present)
//
   EDD_DISK fx81;       //  Fixed Disk parameter area 2
   EDD_DISK fx80;       //  Fixed Disk parameter area 1
//
   byte n_fixed_disks;  //  Number of fixed disks (0, 1, 2)
//
   word  FPEM_segment;        // FPEM data segment
// 
   word  EBDA_paragraph;      //     lowest EBDA paragraph 
//
   word  dma_cw[2];     //       control word at end of DMA
//
   struct FDC_fd {
//      word  offset_Disk_Type; // CS:offset to Disk Type table
      byte  disk_type;        // 0, 2, or 4, probably
      byte  unused_now;       // delete in the future
      byte  status_sw;        // general status information (S/W)
      byte  present_cylinder; // Current Cylinder no.      
      byte  status_hw[4];     // hardware status bytes
   } fdc_fd[2];

// LDOR software copy
   byte  fdc_ldor_soft;       // copy of the WD LDOR register
//
   byte cpu_xtal;       //       CPU crystal frequency in Mhz
                        //       CPU clock is half of this
//                 endstruc
#ifdef SOFT_DEBUG
#define NBREAK 8
   struct Breakpoint breakpoint[NBREAK+1];
#endif
#endif
} *bios_data_area_ptr;


#endif   // __EQUATES_H
