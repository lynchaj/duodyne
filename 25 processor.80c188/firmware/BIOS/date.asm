;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; date.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; string 0 is for "startup.asm" inclusion; must be 8 chars exactly
; string 1 is for RBIOS.ASM inclusion; should be very readable
;
; N.B.  version 46 is Rich Cini's version for the 2S1P board
;
; so we jump from BIOS 045 to 047, the first BIOS to support
; the Version 3.0 board (with 1024K memory on-board)
;
; Definitions for version 3.5-2:
;


%define DATE_STRING0	"04/29/21"
%define DATE_STRING1	"29-Apr-2021"

%define VERSION_MAJOR		3
%define VERSION_MINOR		5
%define VERSION_REVISION	1
%define VERSION_SUFFIX		""
%define VERSION_SEQUENCE	55

%define VERSION_STRING		"3.5-1",VERSION_SUFFIX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Revision information:
;  ver.	2.1 -- table-driven support for all IBM floppy types
;	2.2 -- Dual IDE driver; CVDU memory sizing
;	2.3 -- font_vga corrects (i grave) (n_tilde)
;	    &  Dual SDcard & Minix boot
;	2.4 -- Int 15h multiprogramming hooks: fn90, fn91 (never done)
;	3.0 -- VGA3 support
;	3.1 -- SBC-188 v.3 board support
;	3.2 -- IDE8 support on the v.3 board
;	3.3 -- add 2S1P board support (2 SIO & PPort)
;	3.4 -- floppy drives did not work
;	3.5 -- back to 3.3, sequence #51
;		change NVRAM battery backup setup to #53
;		re-install 3.4 boot fix for FreeDOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
