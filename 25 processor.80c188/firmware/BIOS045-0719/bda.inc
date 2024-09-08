;/*======================================================================
; bda.inc -- BIOS data area definitions
;========================================================================
;   for the N8VEM SBC-188
;
;   This version is for assembly by  NASM 0.98.39 or later
;
; Copyright (C) 2013 John R. Coffman.  All rights reserved.
; Provided for hobbyist use on the N8VEM SBC-188 board.
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;========================================================================

			;*/ extern				/*
	ABSOLUTE  0	;*/ struct BDA {			/*
serial_ports    resw    4	;*/	word	serial_ports[4];	/*
parallel_ports  resw    4	;*/	word	parallel_ports[4];	/*
equipment_flag  resw    1	;*/	EQFL	equipment_flag;		/*
;	dw	?		; 40:10 	; Equipment present word
;  						;  = (1 iff floppies) *     1.
;                                               ;  + (1 iff 187     ) *     2.
;  						;  + (#+1 64K sys ram) *    4.
;  						;  + (init crt mode ) *    16.
;  						;  + (# of floppies ) *    64.
;  						;  + (# serial ports) *   512.
;  						;  + (1 iff toy port) *  4096.
;                                               ;  + (1 iff modem   ) *  8192.
;  						;  + (# parallel LPT) * 16384.
mfg_test_flags  resb    1	;*/	byte	mfg_test_flags;	/* 40:12 unused by us
memory_size     resw    1	;*/	word	memory_size;	/* 40:13 kilobytes
uart_kbd_ctrl_R	equ	$	;*/				/*** JRC: count of ctrl-R's for reboot
IPL_errors      resb    1	;*/	byte	IPL_errors;	/* 40:15 IPL errors<-table/scratchpad
unused_01       resb    1	;*/	byte	unused_01;	/*
;;---------------[Keyboard data area]------------;
keyboard_flags_0 resw   1	;*/	word	keyboard_flags_0;  /* 40:17 Shift/Alt/etc. keyboard flags
keyboard_flags_1 equ	$-1	;     2nd byte	keyboard_flags_1;  
keypad_char	resb	1	;*/	byte	keypad_char;	/* 40:19 Alt-KEYPAD char. goes here
kbd_buffer_head resw    1	;*/	word	kbd_buffer_head;   /* 40:1A --> keyboard buffer head
kbd_buffer_tail resw    1	;*/	word	kbd_buffer_tail;   /* 40:1C --> keyboard buffer tail
kbd_buffer      resw    16	;*/	word	kbd_buffer[16];	/* 40:1E Keyboard Buffer (Scan,Value)
kbd_buffer_last	equ	$	;*/				/*
;;---------------[Diskette data area]------------;
fdc_drv_calib   resb    1	;*/	byte	fdc_drive_calib;   /* 40:3E
fdc_motor_LDOR  resb    1	;*/	byte	fdc_motor_LDOR;	   /* 40:3F Motor, DMA, select control
fdc_motor_ticks resb    1	;*/	byte	fdc_motor_ticks;   /* 40:40 ticks til motor off
fdc_status      resb    1	;*/	byte	fdc_status;	   /* 40:41
;				Floppy return code stat byte
;				;  1 = bad ic 765 command req.
;				;  2 = address mark not found
;				;  3 = write to protected disk
;				;  4 = sector not found
;				;  8 = data late (DMA overrun)
;				;  9 = DMA failed 64K page end
;				; 16 = bad CRC on floppy read
;				; 32 = bad NEC 765 controller
;				; 64 = seek operation failed
;				;128 = disk drive timed out
fdc_ctrl_status resb    7	;*/	byte	fdc_ctrl_status[7];  /* 40:42 Status bytes from NEC 765
;;---------------[Video display area]------------;
video_mode      resb    1	;*/	byte	video_mode;	/* 40:49
;			 	; Current CRT mode  (software)
;				;  0 = 40 x 25 text (no color)
;				;  1 = 40 x 25 text (16 color)
;				;  2 = 80 x 25 text (no color)
;				;  3 = 80 x 25 text (16 color)
;				;  4 = 320 x 200 grafix 4 color
;				;  5 = 320 x 200 grafix 0 color
;				;  6 = 640 x 200 grafix 0 color
;				;  7 = 80 x 25 text (mono card)
video_columns   resw    1	;*/	word video_columns;	/* 40:4A Columns on CRT screen
video_regen_bytes  resw 1	;*/	word video_regen_bytes;	/* 40:4C Bytes in the regen region
video_regen_offset resw 1	;*/	word video_regen_offset;/* 40:4E Byte offset in regen region
video_cursor_pos  resw  8	;*/	word video_cursor_pos[8];  /* 40:50 Cursor pos for up to 8 pages
video_cursor_mode resw  1	;*/	word video_cursor_mode;	/* 40:60 Current cursor mode setting
video_page      resb    1	;*/	byte video_page;	/* 40:62 Current page on display
video_base_seg  resw    1	;*/	word video_base_seg;	/* 40:63 Base address (B000h or B800h)
video_hw_mode   resb    1	;*/	byte video_hw_mode;	/* 40:65 ic 6845 mode reg. (hardware)
video_cga_palette resb  1	;*/	byte video_cga_palette;	/* 40:66 Current CGA palette
;;---------------[Used to setup ROM]-------------;
eprom_address   resd    1	;*/	dword eprom_address;	/* 40:67 Eprom base Offset,Segment
spurious_irq    resb    1	;*/	byte spurious_irq;	/* 40:6B Last spurious interrupt IRQ
;;---------------[Timer data area]---------------;
timer_ticks     resd    1	;*/	dword timer_ticks;	/* 40:6C Ticks since midnight (lo,hi)
timer_new_day   resb    1	;*/	byte timer_new_day;	/* 40:70 Non-zero if new day
;;---------------[System data area]--------------;
break_flag      resb    1	;*/	byte break_flag;	/* 40:71 Sign bit set iff break
warm_boot       resw    1	;*/	word warm_boot;		/* 40:72 Warm boot iff==1234h
;;---------------[Hard disk scratchpad]----------;
hdd_scratch     resd    1	;*/	word hdd_scratch[2];	/* 40:74
;;---------------[Timout areas/PRT/LPT]----------;
lpt_timeout     resb    4	;*/	byte lpt_timeout[4];	/* 40:78 Ticks for LPT 1-4 timeouts
com_timeout     resb    4	;*/	byte com_timeout[4];	/* 40:7C Ticks for COM 1-4 timeouts
;;---obsolete----[Keyboard buf start/end]---jrc--;
kbd_buffer_start resw   1	;*/	word kbd_buffer_start;	/* 40:80 KBD buffer head (PC/AT)
kbd_buffer_end  resw    1	;*/	word kbd_buffer_end;	/* 40:82 KBD buffer tail (PC/AT)
;;---------------[EGA stuff]---------------------;
EGA_stuff	resb	7	;*/	byte EGA_stuff[7];	/* 40:84 Unspecified EGA data
;;---------------[Floppy/Fixed Media Info]-------------;
fdc_last_rate	resb	1	;*/	byte fdc_last_rate;	/* 40:8B Last floppy step rate/data rate?
fx_misc_unused	resb	4	;*/	byte fx_misc_unused[4];	/* 40:8C Fixed disk miscellaneous ???
fdc_disk_state	resb	2	;*/	byte fdc_disk_state[2];	/* 40:90 Floppy disk state
fdc_op_start	resb	2	;*/	byte fdc_op_start[2];	/* 40:92 Floppy operation start state machine
fdc_cylinder	resb	2	;*/	byte fdc_cylinder[2];	/* 40:94 Floppy present cylinder
;;---------------[Additional KBD flags]----------------;
kbd_flag_3	resb	1	;*/	byte kbd_flag_3;	/* 40:96 kbd ???
kbd_flag_2	resb	1	;*/	byte kbd_flag_2;	/* 40:97 kbd ???
;;---------------[RTC/timer1 data]---------------------;
user_semaphore	resw	2	;*/	byte *user_semaphore;	/* 40:98 User semaphore in (bit 7)
rtc_count	resd	1	;*/	dword rtc_count;	/* 40:9C RTC tick counter
rtc_wait_active	resb	1	;*/	byte rtc_wait_active;	/* 40:A0 Busy=01, Posted=80h, 
;;---------------[Cassette I/O stuff]------------------;
last_val	resb	1	;*/	byte last_val;		/* 40:A1 Last byte read value
crc_reg		resw	1	;*/	word crc_reg;		/* 40:A2 CRC accumulation area
;									Post Acknowleged=00;
EGA_data	resb	1	;*/	byte EGA_data;		/* 40:A4 Various usage
SDstatus	resb	2	;*/	byte SDstatus[2];	/* 40:A5 Status byte from command
SDcardtype	resb	2	;*/	byte SDcardtype[2];	/* 40:A7 SDcard type SDSC=2, HC=3, ...
;
fixed_disk_tab	resb	4	;*/	byte fixed_disk_tab[4];	/* dispatch table to fixed disk drivers
wait12_count	resb	1	;*/	byte wait12_count;	/* 40:AD 12usec CX count
lock_count	resb	1	;*/	byte lock_count;	/* 40:AE lock level counter
EMS_start       resb    1	;*/	byte EMS_start;		/* start EMS allocation from here
fx80		equ	$	;*/	struct EDD_disk fx80;	/* fixed disk parameter area 0
fx_log_cylinders resw   1	;	word fx_log_cylinders;	 logical number of cylinders
fx_log_heads    resb    1	;	byte fx_log_heads;	 logical number of heads
fx_signature	resb	1	;	byte fx_signature;	 A0h signature = translated geom
fx_phys_sectors	resb    1       ;	byte fx_phys_sectors;	 physical number of sectors per track
fx_LBA_high     resw    1       ;	word fx_LBA_high;	 high word of LBA28 number of sectors
fx_reserved7    resb	1	;	byte fx_reserved;	 MBZ
fx_drive_control resb   1       ;	byte fx_drive_control;	 flag bits for IDE head register
fx_phys_cylinders resw	1	;	word fx_phys_cylinders;	 physical number of cylinders
fx_phys_heads	resb	1	;	byte fx_phys_heads;	 physical number of heads
fx_LBA_low	resw	1	;	word fx_LBA_low;	 low word of LBA28 number of sectors
fx_log_sectors	resb	1	;	byte fx_log_sectors;	 logical number of sectors per track
fx_checksum	resb	1	;	byte fx_checksum;	 checksum, dunno how to compute
fx81            resb    16	;*/	struct EDD_disk fx81;	/* fixed disk parameter area 1
fx82            resb    16	;*/	struct EDD_disk fx82;	/* fixed disk parameter area 2
fx83            resb    16	;*/	struct EDD_disk fx83;	/* fixed disk parameter area 3
;
;

FPEM_segment    resw    1       ;*/	word FPEM_segment;	/* FPEM data segment

EBDA_paragraph  resw    1       ;*/	word EBDA_paragraph;	/* lowest EBDA paragraph

dma0_cw         resw    1       ;*/	word dma0_cw;		/* end of dma control word
dma1_cw         resw    1       ;*/	word dma1_cw;		/*   ditto

fdc_type	resb	2	;*/	byte fdc_type[2];	/* disk type in low nibble, alternate in hi nib 

debug_static_ptr  resw	2	;*/	void *debug_static_ptr;	/* pointer to debug static area

n_fixed_disks   resb    1       ;*/	byte n_fixed_disks;	/* number of fixed disks

cpu_xtal        resb    1       ;*/	byte cpu_xtal;		/* CPU crystal frequency in Mhz 
;								   CPU clock is half of this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  System configuration stuff below
;	c.f., CONFIG.ASM (ANSI.CFG, CVDU.CFG, etc.), User configuration stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%if 0				;*/
#define FIXED_DISK_MAX 4		/*
%else
%define FIXED_DISK_MAX 4
%endif
%if 0				;*/
#define PPIDE_driver 1		/*
%else
%define PPIDE_driver 1
%endif
%if 0				;*/
#define DIDE_driver 1		/*
%else
%define DIDE_driver 1
%endif
%if 0				;*/
#define DSD_driver 1		/*
%else
%define DSD_driver 1
%endif
				;*/
