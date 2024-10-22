%ifndef SOFT_DEBUG
;;;%define SOFT_DEBUG 1
%endif
;========================================================================
; int10ser.asm -- Video display services implementation using serial port
;========================================================================
;
;    Compiles with NASM 2.07, might work with other versions
;
; Copyright (C) 2010 Sergey Kiselev.
;     additions and modifications for ColorVDU:
; Copyright (C) 2012 John R. Coffman.
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
; TODO:
;       Complete the WYSE character attribute emulation -- JRC
;========================================================================

%include	"config.asm"
ANY_VIDEO	equ	(CVDU_8563|VGA3_6445)

%include	"cpuregs.asm"
%include	"equates.asm"
%if CVDU_8563
%include	"ega9a.asm"
%endif

%if VGA3_6445
%define Init8563_ Init_vga3_
%define Scroll8563_ Scroll_vga3_
%define get_char_and_attribute_ vga3_get_char_and_attribute_
%define blast_characters_ vga3_blast_characters_
%define @cvdu_tty_out @vga3_tty_out
%define	set_cursor_pos_ vga3_set_cursor_pos_
%endif


offset_BP	equ	0
offset_BX	equ	offset_BP+2
offset_DS	equ	offset_BX+2
offset_IP	equ	offset_DS+2
offset_CS	equ	offset_IP+2
offset_FLAGS	equ	offset_CS+2

EOS             equ     0FFh    ; End of String

%if  WYSE
MAX_ROWS	equ	24	; Wyse terminals have 24 rows
%else
MAX_ROWS	equ	24	; terminals usually have 24 rows...
%endif


	SEGMENT _TEXT
;========================================================================
; BIOS call entry for video service functions
;	int  10h
;========================================================================
	global  BIOS_call_10h
BIOS_call_10h:			; Video service entry

	sti			; Enable interrupts
	pushm   bp,bx,ds	; Standard register save
	mov	bp,sp		; establish stack addressing

        cld                     ; do this for all functions below
	push	bios_data_seg
	popm	ds		; establish addressability
%if SOFT_DEBUG
	push	ax
	call	wout
	pop	ax
%endif

	mov     bl,ah		; set to index into dispatch table
	cmp     ah,.max/2
	jae     exit
	mov     bh,0
	shl     bx,1		; index words

    cs	jmp     near [.dispatch+bx]
.dispatch:
	dw      fn00		; Set video mode
	dw      fn01		; Set cursor shape
	dw      fn02		; Set cursor position
	dw	fn03		; Get cursor position and size
	dw	fn04		; Read light pen position
	dw	fn05		; Select active display page
	dw	fn06		; Scroll up window
	dw	fn07		; Scroll down window
	dw	fn08		; Read character and attribute at cursor position
	dw	fn09		; Write character and attribute at cursor position
	dw	fn0A		; Write character only at cursor position
	dw	fn0B		; Set background color/Set palete
	dw	fn0C		; Write graphics pixel
	dw	fn0D		; Read graphics pixel
	dw	fn0E		; Teletype output
	dw	fn0F		; Get current video mode
	dw	fn10		; N/A
	dw	fn11		; N/A
	dw	fn12		; N/A
	dw	fn13		; Write string
.max	equ     $-.dispatch
fn04:				; nobody uses a light pen
fn0B:				; no overscan color emulation
fn0C:				; no graphics
fn0D:				; no graphics
fn10:				; not implemented for CGA and MDA
fn11:				; -//-
fn12:				; -//-
exit:
	popm	bp,bx,ds
	iret

;------------------------------------------------------------------------
;----------------[Video display area]------------;
;video_mode      resb    1
;       db      ?               ; 40:49         ; Current CRT mode  (software)
;                                               ;  0 = 40 x 25 text (no color)
;                                               ;  1 = 40 x 25 text (16 color)
;                                               ;  2 = 80 x 25 text (no color)
;                                               ;  3 = 80 x 25 text (16 color)
;                                               ;  4 = 320 x 200 grafix 4 color
;                                               ;  5 = 320 x 200 grafix 0 color
;                                               ;  6 = 640 x 200 grafix 0 color
;                                               ;  7 = 80 x 25 text (mono card)
;video_columns   resw    1
;       dw      ?               ; 40:4A         ; Columns on CRT screen
;video_regen_bytes  resw 1
;       dw      ?               ; 40:4C         ; Bytes in the regen region
;video_regen_offset resw 1
;       dw      ?               ; 40:4E         ; Byte offset in regen region
;video_cursor_pos  resw  8
;       dw      8 dup(?)        ; 40:50         ; Cursor pos for up to 8 pages
;video_cursor_mode resw  1
;       dw      ?               ; 40:60         ; Current cursor mode setting
;video_page      resb    1
;       db      ?               ; 40:62         ; Current page on display
;video_base_seg  resw    1
;       dw      ?               ; 40:63         ; Base addres (B000h or B800h)
;video_hw_mode   resb    1
;       db      ?               ; 40:65         ; ic 6845 mode reg. (hardware)
;video_cga_palette resb  1


;========================================================================
; Function 00h - Set video mode
; Input:
;	AH = 00h
;	AL = desired video mode
; Output:
;	none
; XXX:
;	reimplement using a table?
;========================================================================
fn00:
	pushm	ax,cx,dx,si,di,es
	mov	ah,al		; save AL to AH
	and	al,1Fh		; limit modes to 0..1F
	cmp	al,0		; 0 = 40 x 25 text (no color)
	jne	.1
	mov	bl,40		; 40 columns
	mov	bh,2Ch		; hw mode - 40 columns, monochrome
	mov	si,0800h	; page size = 2048 bytes
	mov	dx,03D4h	; color CRT base address
	jmp	.set_mode
.1:
	cmp	al,01		; 1 = 40 x 25 text (16 color)
	jne	.2
	mov	bl,40		; 40 columns
	mov	bh,28h		; hw mode - 40 columns, color
	mov	si,0800h	; page size = 2048 bytes
	mov	dx,03D4h	; color CRT base address
	jmp	.set_mode
.2:
	cmp	al,02		; 2 = 80 x 25 text (no color)
	jne	.3
	mov	bl,80		; 80 columns
	mov	bh,2Dh		; hw mode - 80 columns, monochrome
	mov	si,1000h	; page size = 4096 bytes
	mov	dx,03D4h	; color CRT base address
	jmp	.set_mode
.3:
	cmp	al,03		; 3 = 80 x 25 text (16 color)
	jne	.4
	mov	bl,80		; 80 columns
	mov	bh,29h		; hw mode - 80 columns, color
	mov	si,1000h	; page size = 4096 bytes
	mov	dx,03D4h	; color CRT base address
	jmp	.set_mode
.4:
	cmp	al,07		; 7 = 80 x 25 text (mono card)
	jne	.exit
	mov	bl,80		; 80 columns
	mov	bh,2Dh		; hw mode - 80 columns, monochrome
	mov	si,1000h	; page size = 4096 bytes
	mov	dx,03B4h	; monochrome CRT base address

.set_mode:
	mov	byte [video_mode],al
%if ANY_VIDEO
	pushm	ds
	push	DGROUP
	popm	ds
	extern	Init8563_	; or Init_vga3_
	call	Init8563_
	popm	ds
	mov	si,0800h	; page size = 2048 bytes
	mov	[video_cga_palette],al		; set memory size
	mov	al,0
%else
	mov	al,0
	mov	[video_cga_palette],al		; clear location
				; video_cga_palette = 0
%endif
;;	cld			; clear video part of BIOS data area
	mov	di,video_mode+1
	mov	cx,video_cga_palette-video_mode-1
	pushm	ds
	popm	es
    rep	stosb
				; video_page = 0
				; video_regen_offset = 0
				; video_cursor_pos[0..7] = 0

	mov	byte [video_hw_mode],bh
	mov	bh,0
	mov	word [video_columns],bx
	mov	word [video_regen_bytes],si
	mov	word [video_base_seg],dx
	mov	cx,0607h	; cursor start line 6, cursor end line - 7
	mov	word [video_cursor_mode],cx

	mov	bl,07h		; set default attributes to 07h
	call	set_attributes
%if SOFT_DEBUG
	push	0x11
	call	lites
%endif

	test	ah,80h		; if bit 7 of original AL set, don't clear
	jnz	.dont_clear
	call	clear_screen
%if SOFT_DEBUG
	push	0x13
	call	lites
%endif


.dont_clear:
	xor	dx,dx		; set cursor to 1,1
	call	cursor_set_pos
	call	cursor_show
	call	auto_wrap_off

.exit:
	popm	ax,cx,dx,si,di,es
	jmp	exit

;========================================================================
; Function 01h - Set cursor shape
; Input:
;	AH = 01h
;	CH = cursor start and options
;		bit 7    = 0
;		bits 6,5 = 00 normal, other invisible
;		bits 4-0 = topmost scan line
;	CL = (bits 4-0) bottom scan line containing cursor
; Output:
;	none
;========================================================================
fn01:
	push	cx
	mov	word [video_cursor_mode],cx
	test	ch,60h
	jnz	.hide		; hide cursor
	and	ch,0E0h
	cmp	ch,cl
	ja	.hide		; hide cursor
	call	cursor_show	; show cursor
	jmp	.exit

.hide:
	call	cursor_hide

.exit:
	pop	cx
	jmp	exit

;========================================================================
; Function 02h - Set cursor position
; Input:
;	AH = 02h
;	BH = page number (0-based)
;	DH = row (0-based)
;	DL = column (0-based)
; Output:
;	none
;========================================================================
fn02:
	push	dx
	mov	bl,bh
	mov	bh,0
	shl	bx,1
%if !DUMB
	mov	word [video_cursor_pos+bx],dx
%endif
	call	cursor_set_pos
	pop	dx
	jmp	exit

;========================================================================
; Function 03h - Get cursor position and size
; Input:
;	AH = 03h
;	BH = page number (0-based)
; Output:
;	CH = cursor starting scan-line
;	CL = cursor ending scan-line
;	DH = current row (0-based)
;	DL = current column (0-based)
;========================================================================
fn03:
	mov	bx,word [offset_BX+bp]
	mov	bl,bh
	mov	bh,0
	shl	bx,1
	mov	dx,word [video_cursor_pos+bx]
	mov	cx,word [video_cursor_mode]
	jmp	exit

;========================================================================
; Function 05h - Select active display page
; Input:
;	AH = 05h
;	AL = page number (0-based)
; Output:
;	none
;========================================================================
fn05:
	push	ax
	and	al,7			; allow 8 pages
	mov	byte [video_page],al
	pop	ax
	jmp	exit

;========================================================================
; Function 06h - Scroll up window
; Function 07h - Scroll down window
; Input:
;	AH = 06h/07h
;	AL = number of lines to scroll in (0=blank entire rectangle)
;	BH = video attribute to be used on blank line(s)
;	CH,CL = row,column of upper-left corner of rectangle to scroll
;	DH,DL = row,column of lower-right corner of rectangle to scroll
; Notes:
;	Due to ANSI limitations column values are ignored
;========================================================================
fn06:
fn07:
%if	ANY_VIDEO
	mov	bl,[video_page]
	xchg	bl,bh
	pushm	bx,ax,cx,dx,ds,es

	push	DGROUP
	popm	ds
	extern	Scroll8563_	;or Scroll_vga3_
	call	Scroll8563_	;

	popm	bx,ax,cx,dx,ds,es
%endif	; ANY_VIDEO

%if	ANSI
	pushm	ax,cx,dx
	mov	bx,word [offset_BX+bp]
	mov	bl,bh
	call	set_attributes

	or	al,al
	jnz	.scroll
	mov	al,dh	; AL = 0 - blank rectangle
	sub	al,ch
	inc	al

.scroll:
	mov	dl,dh		; DL = lower row
	mov	dh,ch		; DH = upper row
	mov	cx,ax		; save AX in CX
	mov	al,ESC		; set scroll region ESC[<row_up>;<row_down]r
	call	uart_out
	mov	al,'['
	call	uart_out
	call	coords_out
	mov	al,'r'
	call	uart_out

	mov	al,ESC		; use ESC[<num_rows>S or ESC[<num_rows>T
	call	uart_out	; to scroll the region up or down
	mov	al,'['
	call	uart_out

	mov	dx,300Ah	; '0' to DH - used for ASCII conversion
				; 10 to DL for 10-base conversion
	mov	al,cl		; convert to ASCII and output row number
	mov	ah,0
	div	dl
	add	al,dh		; al + '0' - convert to ASCII
	call	uart_out
	mov	al,ah
	add	al,dh		; al + '0' - convert to ASCII
	call	uart_out

	cmp	ch,07h
	je	.scroll_down
	mov	al,'S'
	call	uart_out	; scroll up
	jmp	.reset_scroll

.scroll_down:
	mov	al,'T'
	call	uart_out	; scroll down

.reset_scroll:
	mov	al,ESC
	call	uart_out
	mov	al,'['
	call	uart_out
	mov	al,'r'
	call	uart_out

.exit:
	popm	ax,cx,dx
%elif  WYSE
	pushm	ax,cx,dx
        cmp     dh,MAX_ROWS
        jb      .0
        mov     dh,MAX_ROWS-1
.0:
%if 0
        mov	bx,word [offset_BX+bp]
	mov	bl,bh
	call	set_attributes
%endif
        or      al,al
        jnz     .1
        mov     al,dh
        sub     al,ch
        inc     al
.1:     mov     dx,cx
        xchg    ax,cx
        call    cursor_set_pos
.4:     test    ch,1            ; former AH
        jnz     .down
        call    uart_send
        db      ESC, 'R', EOS
        jmp     .5
.down:  call    uart_send
        db      ESC, 'E', EOS
.5      dec     cl
        jnz     .4
        popm    ax,cx,dx
%endif	; ANSI | WYSE
	jmp	exit

;========================================================================
; Function 08h - Read character and attribute at cursor position
; Input:
;	AH = 08h
;	BH = page number (0-based)
; Output:
;	AL = character read
;	BH = video attribute
; Notes:
;	Impossible to emulate, returns AL = 20h, BH = 07h
;========================================================================
fn08:
%if ANY_VIDEO
	pushm	es		; BP,BX,DS already saved

	pushm	ds
	push	DGROUP
	popm	ds
	mov	ax,word [offset_BX+bp]
	extern	get_char_and_attribute_		; or vga3_get_char_and_attribute_
	call	get_char_and_attribute_		; saves BX,CX,DX (SI,DI not used)
	popm	ds

	popm	es
%else
	mov	al,20h
	mov	bx,word [offset_BX+bp]
	mov	bh,07h
	mov	word [offset_BX+bp],bx
%endif
	jmp	exit

;========================================================================
; Function 09h - Write character and attribute at cursor position
; Function 0Ah - Write character only at cursor position
; Input:
;	AH = 09h/0Ah
;	AL = character to write
;	BH = page number (0-based)
;	BL = video attribute (AH = 09h only)
;	CX = repeat count
; Output:
;	none
;========================================================================
fn09:
fn0A:
%if ANY_VIDEO
	pushm	ax,dx,ds,es

	push	DGROUP
	popm	ds
    	mov	dx,word [offset_BX+bp]
	mov	bx,cx
	extern	blast_characters_	; or vga3_blast_characters_
	call	blast_characters_

	popm	ax,dx,ds,es
%endif
%if UART
	pushm	ax,cx,dx
	cmp	al,20h
	jb	.exit		; non-printable character
	cmp	al,7Fh
	je	.exit		; non-printable character
    	mov	bx,word [offset_BX+bp]
	cmp	ah,0Ah
	je	.no_attributes
	call	set_attributes
.no_attributes:
	mov	bl,bh
	mov	bh,0
	shl	bx,1
	mov	dx,word [video_cursor_pos+bx]

.loop:
	call	uart_out

	inc	dl		; increment column
	cmp	dl,byte [video_columns]
	jae	.next_line
	loop	.loop
	jmp	.exit_loop

.next_line:
	mov	dl,0
	inc	dh		; increment row
	cmp	dh,MAX_ROWS	; on the last row? (assume 25 rows)
	jae	.exit_loop
	call	cursor_set_pos
	loop	.loop

.exit_loop:
	mov	bl,byte [video_page]
	mov	bh,0
	shl	bx,1
%if !DUMB
	mov	dx,word [video_cursor_pos+bx]
%endif
	call	cursor_set_pos
.exit:
	popm	ax,cx,dx
%endif
	jmp	exit

;========================================================================
; Function 0Eh - Teletype output
; Input:
;	AH = 0Eh
;	AL = character to write
;	BH = page number (0-based)
;	BL = foreground color (graphics modes only, ignored)
; Output:
;	none
;========================================================================
fn0E:
	pushm	ax,dx		; preserve AX, too

%if ANY_VIDEO
	pushm	cx,ds,es
	mov	dx,word [offset_BX+bp]
	push	DGROUP
	popm	ds
	extern	@cvdu_tty_out	; or @vga3_tty_out
	call	@cvdu_tty_out	; AX set, DX set, BX set
; cvdu/vga3_tty_out is responsible for updating the cursor position
	popm	cx,ds,es
%endif

	mov	bx,word [offset_BX+bp]
	mov	bl,bh
	mov	bh,0
	shl	bx,1
	mov	dx,word [video_cursor_pos+bx]
%if UART
	cmp	al,07h
	je	.bell		; BEL code
	cmp	al,08h
	je	.bs		; BS code
	cmp	al,0Ah
	je	.lf		; Line feed code
	cmp	al,0Dh
	je	.cr		; Carriage return
	cmp	al,20h
	jb	.exit		; some other control character - ignore
	cmp	al,7Fh
	je	.exit		; DEL code - ignore

	call	uart_out	; we've got a regular character
	inc	dl		; move cursor to the next column
	cmp	dl,byte [video_columns]
	jb	.exit

	mov	al,0Dh
	call	uart_out
	mov	al,0Ah
	call	uart_out
	mov	dl,0		; set cursor to the beggining of the next line
	cmp	dh,MAX_ROWS
	jae	.exit		; already on 25th row, no need to move further
	inc	dh		; move cursor to the next line
	jmp	.exit

.bell:
	call	uart_out	; just output it
	jmp 	.exit		; no need to change cursor position

.bs:
	or	dl,dl		; already on the first column?
	jz	.exit
	call	uart_out
	dec	dl		; move cursor to the previous column
	jmp	.exit

.lf:
	call	uart_out
	cmp	dh,24		; assume 25 rows
	jae	.exit
	inc	dh
	jmp	.exit

.cr:
	call	uart_out
	mov	dl,0		; set cursor to the first column

.exit:
%if ANY_VIDEO==0
	mov	word [video_cursor_pos+bx],dx
%endif
%endif
	popm	ax,dx		; restore AX also
	jmp	exit

;========================================================================
; Function 0Fh - Get current video mode
; Input:
;	AH = 0Fh
; Output:
;	AH = number of character columns
;	AL = video mode
;	BH = active page
;========================================================================
fn0F:
	mov	al,byte [video_page]
	mov	byte [bp+offset_BX+1],al	; set BH for return
	mov	ah,byte [video_columns]		; set AH
	mov	al,byte [video_mode]		; set AL
	jmp	exit

;========================================================================
; Function 13h - Write string
; Input:
;	AH = 13h
;	AL = 00h - use video attribute in BL, don't move cursor
;	AL = 01h - use video attribute in BL, update cursor
;		BL = video attribute
;	AL = 02h - use video attribute from string, don't move cursor
;	AL = 03h - use video attribute from string, update cursor
;	BH = page number (0-based)
;	CX = length of the string
;	DH = row (0-based)
;	DL = column (0-based)
;	ES:BP = pointer to the string
; Output:
;	none
; XXX:
;	When printing the last character on the screen cursor will be moved
;	to the first column of the last line
;========================================================================
fn13:
	pushm	cx,dx
	pushm	ax,bp
	mov	bp,word [offset_BP+bp]
	call	cursor_set_pos
	test	al,02h
	jnz	fn13_2		; read attribute from the string implementation
	call	set_attributes
.loop:
    es	mov	al,byte [bp]
	inc	bp
	cmp	al,07h
	je	.bell
	cmp	al,0Ah
	je	.lf
	cmp	al,0Dh
	je	.cr
	cmp	al,20h
	jb	.next		; control character
	cmp	al,7Fh
	je	.next		; DEL

	call	uart_out

	inc	dl		; increment column
	cmp	dl,byte [video_columns]
	jae	.next_line
	loop	.loop
	jmp	fn13_exit

.next_line:
	mov	dl,0
	inc	dh		; increment row
	cmp	dh,MAX_ROWS
	jae	fn13_exit
	mov	al,0Dh
	call	uart_out
	mov	al,0Ah
	call	uart_out
	loop	.loop
	jmp	fn13_exit

.bell:
	call	uart_out
	loop	.loop
	jmp	fn13_exit

.lf:
	cmp	dh,24
	jae	fn13_exit
	inc	dh
	call	uart_out
	loop	.loop
	jmp	fn13_exit

.cr:
	mov	dl,0
	call	uart_out
	loop	.loop
	jmp	fn13_exit

.next:
	loop	.loop
	jmp	fn13_exit

fn13_2:
	mov	bh,byte [video_columns]
.loop:
    es	mov	al,byte [bp]
	inc	bp
	cmp	al,07h
	je	.bell
	cmp	al,0Ah
	je	.lf
	cmp	al,0Dh
	je	.cr
	cmp	al,20h
	jb	.next		; control character
	cmp	al,7Fh
	je	.next		; DEL

    es	mov	bl,byte [bp]
	inc	bp
	call	set_attributes

	call	uart_out

	inc	dl		; increment column
	cmp	dl,bh		; bh = video columns
	jae	.next_line
	loop	.loop
	jmp	fn13_exit

.next_line:
	mov	dl,0
	inc	dh		; increment row
	cmp	dh,MAX_ROWS
	jae	fn13_exit
;	call	cursor_set_pos
	mov	al,0Dh
	call	uart_out
	mov	al,0Ah
	call	uart_out
	loop	.loop
	jmp	fn13_exit

.bell:
	call	uart_out
	loop	.loop
	jmp	fn13_exit

.lf:
	cmp	dh,24
	jae	fn13_exit
	inc	dh
	call	uart_out
	loop	.loop
	jmp	fn13_exit

.cr:
	mov	dl,0
	call	uart_out
	loop	.loop
	jmp	fn13_exit

.next:
	inc	bp		; skip the attribute
	loop	.loop

fn13_exit:
	popm	ax,bp
	mov	bx,word [offset_BX+bp]
	mov	bl,bh
	mov	bh,0
	shl	bx,1		; bx = page number * 2
	test	al,01h		; AL, bit 0 = 1 - update cursor
	jne	.update_cursor
	mov	dx,word [video_cursor_pos+bx]
	call	cursor_set_pos
	jmp	.exit

.update_cursor:
	mov	word [video_cursor_pos+bx],dx

.exit:
	popm	cx,dx
	jmp	exit

;========================================================================
; coords_out - Output coordinates in ANSI format X;Y
;              Output coordinates in WYSE format:  SP+row SP+col
; Input:
;	DH = X coordinate
;	DL = Y coordinate
; Output:
;	AX is trashed
;	none
;========================================================================
coords_out:
%if	ANSI
	pushm	cx,dx
	add	dx,0101h
	mov	cx,300Ah	; '0' to CH - used for ASCII conversion
				; 10 to CL for 10-base conversion
	mov	al,dh		; convert to ASCII and output row number
	mov	ah,0
	div	cl
	add	al,ch		; al + '0' - convert to ASCII
	call	uart_out
	mov	al,ah
	add	al,ch		; al + '0' - convert to ASCII
	call	uart_out

	mov	al,';'		; output ';' delimiter
	call	uart_out

	mov	al,dl		; convert to ASCII and output column number
	mov	ah,0
	div	cl
	add	al,ch		; al + '0' - convert to ASCII
	call	uart_out
	mov	al,ah
	add	al,ch		; al + '0' - convert to ASCII
	call	uart_out
	popm	cx,dx
%elif WYSE
        pushm   dx
        add     dx,2020h        ; SPACE || SPACE
        mov     al,dh           ; row
	call	uart_out
        mov     al,dl           ; column
	call	uart_out
        popm    dx
%endif	; ANSI | WYSE
	ret

;========================================================================
; cursor_set_pos - move cursor to specified position
; Input:
;	DH = row (0-based)
;	DL = column (0-based)
; Output:
;	none
; Notes:
;	Uses ESC[<row>;<column>H ANSI sequence, row and column are 0-based
;========================================================================
cursor_set_pos:
%if ANY_VIDEO
	pushm	ax,dx
	mov	ax,dx
	pushm	ds
	pushm	DGROUP
	popm	ds
	extern	set_cursor_pos_		; or vga3_set_cursor_pos_
	call	set_cursor_pos_
	popm	ds
	popm	ax,dx
%endif
%if	ANSI
	push	ax
	mov	al,ESC		; output CSI sequence
	call	uart_out
	mov	al,'['
	call	uart_out
	call	coords_out
	mov	al,'H'		; output 'H' command
	call	uart_out
	pop	ax
%elif  WYSE
        pushm   ax
        mov     al,ESC
	call	uart_out
        mov     al,'='          ; ESC '=' r  c
	call	uart_out
        call	coords_out
        popm    ax
%elif	DUMB
; setting the cursor position back on the same line can be done
; by emitting the correct number of BS (backspace) characters
	xchg	dx,[video_cursor_pos + 0]	; page 0 always
	sub	dl,[video_cursor_pos]		; - delta
	jz	.5
	mov	ax,0x0100+FWD		; forward space is ^L
	js	.1
	mov	ax,0xFF00+BS		;
.1:	call	uart_out
	add	dl,ah
	jnz	.1

.5:	sub	dh,[video_cursor_pos+1]
	jz	.9
	mov	ax,0x0100+LF		;line feed (down)
	js	.7
	mov	ax,0xFF00+VT		;line feed (up)
.7:	call	uart_out
	add	dh,ah
	jnz	.7
.9:
%endif	; ANSI | WYSE
	ret

;========================================================================
; auto_wrap_off - disable auto wraparound mode
; Input:
;	none
; Output:
;	none
; Notes:
;	Uses ESC[?7l ANSI sequence
;========================================================================
auto_wrap_off:
%if	ANSI
	push	ax
	mov	al,ESC
	call	uart_out
	mov	al,'['
	call	uart_out
	mov	al,'?'
	call	uart_out
	mov	al,'7'
	call	uart_out
	mov	al,'l'
	call	uart_out
	pop	ax
%elif  WYSE
;   Function is not available
%endif	; ANSI | WYSE
	ret

;========================================================================
; cursor_hide - hide cursor
; Input:
;	none
; Output:
;	none
; Notes:
;	Uses ESC[?25l ANSI sequence
;========================================================================
cursor_hide:
%if	ANSI
	push	ax
	mov	al,ESC
	call	uart_out
	mov	al,'['
	call	uart_out
	mov	al,'?'
	call	uart_out
	mov	al,'2'
	call	uart_out
	mov	al,'5'
	call	uart_out
	mov	al,'l'
	call	uart_out
	pop	ax
%elif  WYSE
        pushm   ax
	mov	al,ESC
	call	uart_out
        mov     al, '`'
	call	uart_out
        mov     al,'0'
	call	uart_out
        popm    ax
%endif	; ANSI | WYSE
	ret

;========================================================================
; cursor_show - show cursor
; Input:
;	none
; Output:
;	none
; Notes:
;	Uses ESC[?25h ANSI sequence
;========================================================================
cursor_show:
%if	ANSI
	push	ax
	mov	al,ESC
	call	uart_out
	mov	al,'['
	call	uart_out
	mov	al,'?'
	call	uart_out
	mov	al,'2'
	call	uart_out
	mov	al,'5'
	call	uart_out
	mov	al,'h'
	call	uart_out
	pop	ax
%elif  WYSE
        pushm   ax
	mov	al,ESC
	call	uart_out
        mov     al, '`'
	call	uart_out
        mov     ax,[video_cursor_mode]
        and     ax,1F1Fh
        sub     al,ah
        cmp     al,3
        jb      .line
; blinking block cursor
        mov     al,'5'
        jmp     .3
.line:  ; blinking line cursor
        mov     al,'3'
.3:     call    uart_out

	mov	al,ESC
	call	uart_out
        mov     al, '`'
	call	uart_out
        mov     al,'1'
	call	uart_out
        popm    ax
%endif	; ANSI | WYSE
	ret

;========================================================================
; clear_screen
; Input:
;	none
; Output:
;	AL is trashed
;========================================================================
clear_screen:
%if   ANSI
	mov	al,ESC		; clear screen - ESC[2J
	call	uart_out
	mov	al,'['
	call	uart_out
	mov	al,'2'
	call	uart_out
	mov	al,'J'
	call	uart_out
%elif WYSE
        call    uart_send
        db      ESC, '+'        ; home cursor; clr to spaces; turn off
                                ; protect and write protect modes
        db      ESC, "A00"      ; data area attribute NORMAL
        db      ESC, "A1p"      ; label area DIM (bottom line)
        db      ESC, "A3x"      ; terminal message field dim underline
        db      ESC, "A2t"      ; computer message field dim reverse
        db      ESC, '"'        ; unlock keyboard
        db      EOS
%endif  ; ANSI | WYSE
	ret

;========================================================================
; set_attributes - set specified background/foreground color
; Input:
;	BL = attributes
;		color mode:
;			bit 7 	 = 1 - blinking
;			bits 6-4 = background color
;			bits 3-0 = foreground color
;		color mode with high intensity background
;			bits 7-4 = background color
;			bits 3-0 = foreground color
;		monochrome mode
;			01h = underline
;			07h = normal
;			09h = bright underline
;			0Fh = bold
;			70h = reverse (black on white)
;			81h = blinking underline
;			87h = blinking normal
;			89h = blinking bright underline
;			8Fh = blinking bold
; Output:
;	none
; XXX:
;	Add attribute cache, so we won't spend time setting the same attribute again
;========================================================================
set_attributes:
%if	ANSI
	push	ax

	mov	al,ESC
	call	uart_out
	mov	al,'['
	call	uart_out

	test	bl,08h	; bold?
	jnz	.bold
	mov	al,'2'		; set normal mode - ESC[22m
	call	uart_out
	call	uart_out
	jmp	.check_mode

.bold:
	mov	al,'1'		; set bold attribute - ESC[1m
	call	uart_out

.check_mode:
	mov	al,byte [video_mode]
	cmp	al,7
	jne	.color

	mov	al,';'
	call	uart_out
				; monochrome - set underline attribute
	mov	al,bl
	and	al,7		; get foreground attribute part
	cmp	al,1		; underlined
	je	.underline
	mov	al,'2'		; set not underlined attribute - ESC[24m
	call	uart_out
	mov	al,'4'
	call	uart_out
	jmp	.mono_to_color

.underline:
	mov	al,'4'		; set underlined attribute - ESC[4m
	call	uart_out

.mono_to_color:
	mov	al,bl
	and	al,07h
	jz	.mono_bg	; black foreground
	or	bl,07h		; anything else is white
.mono_bg:
	mov	al,bl
	and	al,70h
	jz	.color		; black background
	or	bl,70h		; anything else is white
.color:
	mov	al,';'
	call	uart_out

	mov	al,bl		; need to exchange bit 0 with 2
	and	bl,0AAh		; and bit 4 with bit 6
	test	al,01h
	jz	.no_blue_fg
	or	bl,04h
.no_blue_fg:
	test	al,04h
	jz	.no_red_fg
	or	bl,01h
.no_red_fg:
	test	al,10h
	jz	.no_blue_bg
	or	bl,40h
.no_blue_bg:
	test	al,40h
	jz	.no_red_bg
	or	bl,10h
.no_red_bg:
	mov	al,'3'		; set foreground color - ESC[3<0..7>m
	call	uart_out
	mov	al,bl
	and	al,07h
	add	al,'0'
	call	uart_out

	mov	al,';'
	call	uart_out

	test	bl,80h
	jz	.normal_bg	; normal background
	mov	al,byte [video_hw_mode]
	test	al,20h		; intense colors
	jnz	.normal_bg	; normal background, blinking

	mov	al,'1'		; set intense background color - ESC[10<0..7>m
	call	uart_out	; note - this is not supported everywhere
	mov	al,'0'
	call	uart_out
	mov	al,bl
	and	al,70h
	shr	al,4
	add	al,'0'
	call	uart_out
	jmp	.exit

.normal_bg:
	mov	al,'4'		; set background color - ESC[4<0..7>m
	call	uart_out
	mov	al,bl
	and	al,70h
	shr	al,4
	add	al,'0'
	call	uart_out

	mov	al,';'
	call	uart_out

	test	bl,80h
	jnz	.blink
	mov	al,'2'		; set not blinking attribute - ESC[25m
	call	uart_out
	mov	al,'5'
	call	uart_out
	jmp	.exit

.blink:
	mov	al,'5'		; set blinking attribute - ESC[5m
	call	uart_out

.exit:
	mov	al,'m'
	call	uart_out

	pop	ax
%elif WYSE & 0
;*** this needs to be implemented correctly

	push	ax

	mov	al,ESC
	call	uart_out
	mov	al,'['
	call	uart_out

	test	bl,08h	; bold?
	jnz	.bold
	mov	al,'2'		; set normal mode - ESC[22m
	call	uart_out
	call	uart_out
	jmp	.check_mode

.bold:
	mov	al,'1'		; set bold attribute - ESC[1m
	call	uart_out

.check_mode:
	mov	al,byte [video_mode]
	cmp	al,7
	jne	.color

	mov	al,';'
	call	uart_out
				; monochrome - set underline attribute
	mov	al,bl
	and	al,7		; get foreground attribute part
	cmp	al,1		; underlined
	je	.underline
	mov	al,'2'		; set not underlined attribute - ESC[24m
	call	uart_out
	mov	al,'4'
	call	uart_out
	jmp	.mono_to_color

.underline:
	mov	al,'4'		; set underlined attribute - ESC[4m
	call	uart_out

.mono_to_color:
	mov	al,bl
	and	al,07h
	jz	.mono_bg	; black foreground
	or	bl,07h		; anything else is white
.mono_bg:
	mov	al,bl
	and	al,70h
	jz	.color		; black background
	or	bl,70h		; anything else is white
.color:
	mov	al,';'
	call	uart_out

	mov	al,bl		; need to exchange bit 0 with 2
	and	bl,0AAh		; and bit 4 with bit 6
	test	al,01h
	jz	.no_blue_fg
	or	bl,04h
.no_blue_fg:
	test	al,04h
	jz	.no_red_fg
	or	bl,01h
.no_red_fg:
	test	al,10h
	jz	.no_blue_bg
	or	bl,40h
.no_blue_bg:
	test	al,40h
	jz	.no_red_bg
	or	bl,10h
.no_red_bg:
	mov	al,'3'		; set foreground color - ESC[3<0..7>m
	call	uart_out
	mov	al,bl
	and	al,07h
	add	al,'0'
	call	uart_out

	mov	al,';'
	call	uart_out

	test	bl,80h
	jz	.normal_bg	; normal background
	mov	al,byte [video_hw_mode]
	test	al,20h		; intense colors
	jnz	.normal_bg	; normal background, blinking

	mov	al,'1'		; set intense background color - ESC[10<0..7>m
	call	uart_out	; note - this is not supported everywhere
	mov	al,'0'
	call	uart_out
	mov	al,bl
	and	al,70h
	shr	al,4
	add	al,'0'
	call	uart_out
	jmp	.exit

.normal_bg:
	mov	al,'4'		; set background color - ESC[4<0..7>m
	call	uart_out
	mov	al,bl
	and	al,70h
        shr     al,4
	add	al,'0'
	call	uart_out

	mov	al,';'
	call	uart_out

	test	bl,80h
	jnz	.blink
	mov	al,'2'		; set not blinking attribute - ESC[25m
	call	uart_out
	mov	al,'5'
	call	uart_out
	jmp	.exit

.blink:
	mov	al,'5'		; set blinking attribute - ESC[5m
	call	uart_out

.exit:
	mov	al,'m'
	call	uart_out

	pop	ax
%endif	; ANSI | WYSE
	ret

;========================================================================
; uart_out - write character to serial port
; Input:
;	AL = character to write
; Output:
;	none
;========================================================================
uart_out:
%if UART_MODE3_SUPPRESS
	push	ds
	push	bios_data_seg
	popm	ds
	cmp	byte [video_mode],3
	popm	ds
	je	.9		; skip output in mode 3 (color)
%endif
;;;	global	uart_out_	; used in debugging mode (C-callable)
;;;uart_out_:			; **** label .9 cannot reach if un-commented
	push	dx
	push	ax
%if UART_DSR_PROTOCOL
 %if SBC188<3
        extern  microsecond
.wait_dsr:
        mov     dx,uart_msr
BIT_DSR         equ     1<<5
        in      al,dx           ; read the Modem Status Register
        test    al,BIT_DSR      ; Data Set Ready
        jnz     .nowait
        push    cx
        mov     cx,100
        call    microsecond
        pop     cx
        jmp     .wait_dsr
.nowait:
 %endif
%endif
.1:
	mov	dx,uart_lsr
	in	al,dx
	test	al,20h		; THRE is empty
	jz	.1
	pop	ax
	mov	dx,uart_thr
	out	dx,al		; write character
	pop	dx
.9:
	ret

%if  WYSE
;========================================================================
; uart_send - write an in-line EOS terminated string to serial port
; Input:
;	in the instruction stream
; Output:
;	destroys AX
;========================================================================
uart_send:
        pop     ax              ; pointer to character string
        xchg    ax,si
	pushm	ax		; save SI

.next:
    cs	lodsb			; load byte at CS:SI
        inc     al
        jz      .done           ; EOS is 0FFh, so this is easy test
        dec     al
        call    uart_out
        jmp     .next
.done:
	popm	ax		; restore SI
        xchg    ax,si		; **
        jmp     ax		; RETURN
%endif ; WYSE

;========================================================================
; video_init - initialize video service
; Input:
;	AL = baud rate
;	DS = DGROUP
; Output:
;	none
;========================================================================
	global	video_init
video_init:
		; XXX - move interrupt registration code here
	push	ax
	call	uart_init
	mov	dx,uart_base
	call	uart_detect
	push	ax
%if SOFT_DEBUG
	extern	lites
	or	al,0C0h
	push	ax
	call	lites
	extern	crlf,boutsp,wout,bout,cout
%if 1
	pop	ax
	push	ax
	call	boutsp
	call	crlf
	pushm	dx,cx
	mov	cx,uart_sr-uart_iir+1
	mov	dx,uart_iir
.234:	in	al,dx
	call	boutsp
	inc	dl
	loop	.234
	popm	dx,cx
%endif
%endif
%if CVDU|VGA3
	mov	ax,0003h
%else
	mov	ax,0007h
%endif
	int	10h
	pop	ax
%if SOFT_DEBUG
	push	ax
	call	boutsp
	pop	ax
%endif
	push	cs
	cmp	al,UART_16550A
	jb	.no_fifo
	push	.enabled
	jmp	.print_uart
.no_fifo:
	push	.disabled
.print_uart:
	push	cs
	cmp	al,UART_8250
	jne	.check_16450
	push	.uart_8250
	jmp	.print_hi
.check_16450:
	cmp	al,UART_16450
	jne	.check_16550
	push	.uart_16450
	jmp	.print_hi
.check_16550:
	cmp	al,UART_16550
	jne	.check_16550A
	push	.uart_16550
	jmp	.print_hi
.check_16550A:
	cmp	al,UART_16550A
	jne	.check_16550C
	push	.uart_16550A
	jmp	.print_hi
.check_16550C:
	cmp	al,UART_16550C
	jne	.check_16650
	push	.uart_16550C
	jmp	.print_hi
.check_16650:
	cmp	al,UART_16650
	jne	.check_16750
	push	.uart_16650
	jmp	.print_hi
.check_16750:
	cmp	al,UART_16750
	jne	.check_16850
	push	.uart_16750
	jmp	.print_hi
.check_16850:
	cmp	al,UART_16850
	jne	.unknown
	push	.uart_16850
	jmp	.print_hi
.unknown:
	push	.uart_unknown
.print_hi:
	push	cs
	push	.hi
	extern	_cprintf
	call	_cprintf	; _cprintf uses int10 0Eh
	add	sp,12

	pop	ax
%if SOFT_DEBUG
;;;	hlt
%endif
	ret

.hi:
%if ANY_VIDEO
%if CVDU_8563
	db	'ColorVDU BIOS (c) 2013 John R. Coffman', NL
%endif
%if VGA3_6445
	db	'VGA3 Video BIOS (c) 2017 John R. Coffman', NL
%endif

%if UART
	db	'Serial I/O BIOS (c) 2010 Sergey Kiselev', NL
	db	'Detected %s UART, FIFO is %sabled', NL
%endif
%else
	db	'Video BIOS (C) 2010 Sergey Kiselev', NL
	db	'Detected %s UART, FIFO is %sabled', NL
%endif
	db	0

.uart_8250:
	db	'8250', 0
.uart_16450:
	db	'8250A/16450', 0
.uart_16550:
	db	'16550', 0
.uart_16550A:
	db	'16550A', 0
.uart_16550C:
	db	'16550C', 0
.uart_16650:
	db	'16650', 0
.uart_16750:
	db	'16750', 0
.uart_16850:
	db	'16850', 0
.uart_unknown:
	db	'unknown', 0
.enabled:
	db	'en', 0
.disabled:
	db	'dis', 0

;========================================================================
; uart_init - initialize UART
; Input:
;	AL = baud rate
; Output:
;	none
;========================================================================
uart_init:
	pushm	ax,bx,dx
	mov	ah,0
	shl	al,1
	mov	bx,ax		; Index in the .divisors table
   cs	mov	bx,word[.divisors+bx]
	; Divisor Latch Access bit set, no parity, one stop bit, 8 data bits
	mov	al,83h
	mov	dx,uart_lcr
	out	dx,al
	; Lookup table for baud rates
	mov	al,bl		; low byte
	mov	dx,uart_dll
	out	dx,al
	mov	al,bh		; high byte
	mov	dx,uart_dlm
	out	dx,al
	; no parity, one stop bit, 8 data bits
	mov	al,03h
	mov	dx,uart_lcr
	out	dx,al
	; XXX?
	mov	dx,uart_mcr
	in	al,dx				; for SBC3
	or	al,7
	out	dx,al
	; disable interrupts for now
	mov	al,0		; AL = 0
	mov	dx,uart_ier
	out	dx,al
	; disable FIFO for now
	; note - AL = 0
	mov	dx,uart_fcr
	out	dx,al
	popm	ax,bx,dx
	ret

.divisors:
	dw	UART_OSC/16/1200	; 1200 Kbit/sec
	dw	UART_OSC/16/2400	; 2400 Kbit/sec
	dw	UART_OSC/16/4800	; 4800 Kbit/sec
	dw	UART_OSC/16/9600	; 9600 Kbit/sec
	dw	UART_OSC/16/19200	; 19200 Kbit/sec
	dw	UART_OSC/16/38400	; 38400 Kbit/sec
	dw	UART_OSC/16/57600	; 57600 Kbit/sec
	dw	UART_OSC/16/115200	; 115200 Kbit/sec

%if 0
;========================================================================
; uart_detect - detect UART type, enable FIFO if present
; Input:
;	none
; Output:
;	AL = UART type
;
; UART detection code from
; http://en.wikibooks.org/wiki/Serial_Programming/8250_UART_Programming
;========================================================================
UART_8250	equ	1
UART_16450	equ	2
UART_16550	equ	3
UART_16550A	equ	4
UART_16550C	equ	5
UART_16650	equ	6
UART_16750	equ	7
UART_16850	equ	8

uart_detect:
	push	dx
	; Set the value "0xE7" to the FCR to test the status of the FIFO flags
	mov	al,0E7h
	mov	dx,uart_fcr
	out	dx,al
	; Read the value of the IIR to test for what flags actually got set
	mov	dx,uart_iir
	in	al,dx
	test	al,40h
	jz	.no_fifo
	test	al,80h
	jz	.uart_16550
	test	al,20h
	jz	.uart_16550A
	mov	al,UART_16750
	jmp	.exit
.uart_16550A:
	mov	al,UART_16550A
	jmp	.exit
.uart_16550:
	; Disable FIFO on 16550 (FIFO is broken)
	mov	al,0
	mov	dx,uart_fcr
	out	dx,al
	mov	al,UART_16550
	jmp	.exit
.no_fifo:
	; Chip doesn't use FIFO, so we need to check the scratch register
	; Set some arbitrary value like 0x2A to the Scratch Register
	mov	al,2Ah
	mov	dx,uart_sr
	out	dx,al
	; Read the value of the Scratch Register
	in	al,dx
	cmp	al,2Ah
	jnz	.uart_8250
	; If the arbitrary value comes back identical
	mov	al,UART_16450
	jmp	.exit
.uart_8250:
	mov	al,UART_8250
.exit:
	pop	dx
	ret
%else
%include "uart_det.asm"
%endif

;========================================================================
; uart_putchar - write the character in teletype mode
; Input:
;	AL = character
;========================================================================
        global  @uart_putchar
@uart_putchar:
        push    ax
        push    bx
        mov     ah,0Eh
        mov     bx,0007h        ; page 0, normal attributes
        int     10h
        pop     bx
        pop     ax
        ret

;========================================================================
; CVDU_putchar - write the character in teletype mode
; Input:
;	AL = character
;	DL = attribute (IBM-PC)
;  C-declaration:
;	void __fastcall CVDU_putchar(int char, int attribute);
;========================================================================
        global  @VIDEO_putchar
@VIDEO_putchar:
	push	ax
	mov	ah,0Fh		; get page in BH
	int	10h
	mov	bl,dl		; get attribute in BL
	pop	ax
	mov	ah,0Eh		; write char
	int	10h
	ret

%if VGA3_6445
;========================================================================
; mv_word - move words using video index
; Input:
;	AX = destination character index
;	DX = source character index
;	BX = count of words to move
;========================================================================
	global mv_word_
mv_word_:
	pushm	si,di,cx,ds
	mov	di,ax			; destination
	shl	di,1			; it is a word pointer
	mov	si,dx			; source
	shl	si,1			; word pointer
	mov	cx,bx			; count to CX
	extern	video_buffer_ptr_
	call	video_buffer_ptr_	; DX:AX is set
	mov	es,dx			; set up segment registers
	mov	ds,dx			;  **
	add	di,ax			; AX is 0 for page 0
	add	si,ax			;  **

	rep	movsw			; do the fast move

	popm	si,di,cx,ds
	ret
%endif




;========================================================================
