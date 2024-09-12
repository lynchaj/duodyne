;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; date.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; string 0 is for "startup.asm" inclusion; must be 8 chars exactly
; string 1 is for RBIOS.ASM inclusion; should be very readable

%define DATE_STRING0	"06/18/17"
%define DATE_STRING1	"18-Jun-2017"

%define VERSION_MAJOR		3
%define VERSION_MINOR		0
%define VERSION_REVISION	45
%define VERSION_SUFFIX		"-beta"
%define VERSION_STRING		"3.0-45",VERSION_SUFFIX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Revision information:
;  ver.	2.1 -- table-driven support for all IBM floppy types
;	2.2 -- Dual IDE driver; CVDU memory sizing
;	2.3 -- font_vga corrects (i grave) (n_tilde)
;	    &  Dual SDcard & Minix boot
;	2.4 -- Int 15h multiprogramming hooks: fn90, fn91 (never done)
;	3.0 -- VGA3 support
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
