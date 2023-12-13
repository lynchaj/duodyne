; Assembly language example code for accessing a LCD using the PJRC
; 8051 development board: http://www.pjrc.com/tech/8051/board4


; The location in memory where this example program is built.  See this
; page for details: http://www.pjrc.com/tech/8051/board4/memory_map.html
;.equ    locat, 0x2000           ;Location for this program
.equ    locat, 0x8000           ;Location for this program

; Constants to define the display size.  These are needed by the lcd_set_xy
; routine to turn X-Y coordinates into addresses within the display's
; buffer.  These settings work with the 16x2 display available from
; PJRC.COM, at: http://www.pjrc.com/store/dev_display_16x2.html
.equ	lcd_horiz_size, 16
.equ	lcd_vert_size, 2
.equ	lcd_bytes_per_line, (128 / lcd_vert_size)

; Misc constants to define commands give to the display.
.equ	lcd_clear_cmd, 0x01		;clears display
.equ	lcd_home_cmd, 0x02		;put cursor at home position
.equ	lcd_on_cmd, 0x0C		;turn on display (cursor off)
.equ	lcd_shift_cmd, 0x10
.equ	lcd_config_cmd, 0x38		;config 8 bit, 2 lines, 5x7

; Memory mapped locations to accessing the LCD.
.equ	lcd_command_wr, 0xFE00
.equ	lcd_status_rd, 0xFE01
.equ	lcd_data_wr, 0xFE02
.equ	lcd_data_rd, 0xFE03

; Routines within PAULMON2 for interacting with the serial port.
.equ	cout, 0x0030
.equ	cin, 0x0032
.equ	phex, 0x0034
.equ	phex16, 0x0036
.equ	pstr, 0x0038
.equ	newline, 0x0048


; Program header, so this program will show up in PAULMON2's menus
.org    locat
.db     0xA5,0xE5,0xE0,0xA5     ;signiture bytes
.db     35,255,0,0              ;id (35=prog)
.db     0,0,0,0                 ;prompt code vector
.db     0,0,0,0                 ;reserved
.db     0,0,0,0                 ;reserved
.db     0,0,0,0                 ;reserved
.db     0,0,0,0                 ;user defined
.db     255,255,255,255         ;length and checksum (255=unused)
.db     "LCD Test",0            ;max 31 characters, plus the zero
.org    locat+64                ;executable code begins here


; Finally, the main program.  This simple program prints a couple
; welcome messages and then enters a loop where everything the
; user types is displayed on the LCD.  A pair of registers track
; the cursor position and the code repositions the cursor when it
; reaches the right side or bottom edge of the display, so that
; the user's characters will keep displaying somewhere on the LCD.

begin:
	mov	dptr, #mesg_start	;print a message for the user
	lcall	pstr
	acall	lcd_init
	acall	lcd_clear		;setup the LCD
	acall	lcd_home
	mov	r4, #0			;r4/r5 will remember cursor position
	mov	r5, #1
	mov	dptr, #mesg_start_lcd
	acall	lcd_pstr		;print a message on the LCD top line
	sjmp	reposition_cursor	;start the cursor on second line
main_loop:
	lcall	cin			;get a user keystroke
	cjne	a, #27, main2
	ljmp	0			;quit if they pressed ESC
main2:	acall	lcd_cout
	inc	r4			;keep up with cursor position
	cjne	r4, #lcd_horiz_size, main_loop
	mov	r4, #0			;if right edge, return to left side
	inc	r5
	cjne	r5, #lcd_vert_size, reposition_cursor
	mov	r5, #0			;if bottom edge, return to top line
reposition_cursor:
	mov	a, r4
	mov	r2, a
	mov	a, r5
	mov	r3, a
	acall	lcd_set_xy		;set the cursor back onto screen
	sjmp	main_loop



mesg_start:
	.db	"Type text to show on the display",13,10
	.db	"and press ESC to quit",13,10,0

mesg_start_lcd:
	.db	"Type Something",0


;----------------------------------------------------------------
;         General purpose routines for accessing the LCD
;----------------------------------------------------------------



; Print a single character in Acc to the display.

lcd_cout:
	push	dpl
	push	dph
	push	acc
	acall	lcd_busy
	mov	dptr, #lcd_data_wr
	pop	acc
	movx	@dptr, a
	pop	dph
	pop	dpl
	ret


; Print a string @DPTR to the display.

lcd_pstr:
	clr	a
	movc	a, @a+dptr
	inc	dptr
	jz	lcd_pstr_end
	acall	lcd_cout
	sjmp	lcd_pstr
lcd_pstr_end:
	ret


; Wait for the display to be ready for a command or data.

lcd_busy:
	mov	dptr, #lcd_status_rd
lcd_busy_wait:
	movx	a, @dptr
	jb	acc.7, lcd_busy_wait
	ret


; Set the display's cursor position.
; R2 = X position (0 to 15), R3 = Y position (0 to 1)

lcd_set_xy:
	;check X is within display size
	mov	a, r2
	add	a, #256 - lcd_horiz_size
	jnc	lcd_set_xok
	mov	r2, #lcd_horiz_size - 1
lcd_set_xok:
	;check Y is within display size
	mov	a, r3
	add	a, #256 - lcd_vert_size
	jnc	lcd_set_yok
	mov	r3, #lcd_vert_size - 1
lcd_set_yok:
	acall	lcd_busy
	;compute address within data display ram in LCD controller chip
	mov	a, r3
	mov	b, #lcd_bytes_per_line
	mul	ab
	add	a, r2
	orl	a, #0x80	;msb set for set DD RAM address
	mov	dptr, #lcd_command_wr
	movx	@dptr, a
	ret


; Initialize the display for use.

lcd_init:
	lcall	lcd_busy
	mov	dptr, #lcd_command_wr
	mov	a, #lcd_config_cmd
	movx	@dptr, a
	lcall	lcd_busy
	mov	dptr, #lcd_command_wr
	mov	a, #lcd_on_cmd
	movx	@dptr, a
	lcall	lcd_busy
	mov	dptr, #lcd_command_wr
	mov	a, #lcd_shift_cmd
	movx	@dptr, a
	ret

; Clear the screen.

lcd_clear:
	lcall	lcd_busy
	mov	dptr, #lcd_command_wr
	mov	a, #lcd_clear_cmd
	movx	@dptr, a
	ret

; Return the cursor to the home position.

lcd_home:
	lcall	lcd_busy
	mov	dptr, #lcd_command_wr
	mov	a, #lcd_home_cmd
	movx	@dptr, a
	ret
