;This example program asks for a word to be entered, and then
;it prints it in large letters, as defined in the bitmap data below.


;this line must be set so that the program is assembled
;to be run from a place in memory where there is RAM.

;.org	0x2000
.org	0x8000


;these equ lines allow us to call functions within PAULMON2
;by their names.

.equ	cout, 0x0030		;print Acc to Serial Port
.equ    Cin, 0x0032             ;Get Acc from serial port
.equ    pHex, 0x0034            ;Print Hex value of Acc
.equ    pHex16, 0x0036          ;Print Hex value of DPTR
.equ    pStr, 0x0038         ;Print string pointed to by DPTR,
                                ;must be terminated by 0 or a high bit set
                                ;pressing ESC will stop the printing
.equ    gHex, 0x003A            ;Get Hex input into Acc
                                ;Carry set if ESC has been pressed
.equ    gHex16, 0x003C          ;Get Hex input into DPTR
                                ;Carry set if ESC has been pressed
.equ    ESC, 0x003E             ;Check for ESC key
                                ;Carry set if ESC has been pressed
.equ    Upper, 0x0040           ;Convert Acc to uppercase
                                ;Non-ASCII values are unchanged
.equ    Init, 0x0042            ;Initialize serial port
.equ    newline, 0x0048         ;print CR/LF (13 and 10)
.equ    lenstr, 0x004A          ;return the length of a string @DPTR (in R0)
.equ    pint8u, 0x004D          ;print Acc at an integer, 0 to 255
.equ    pint8, 0x0050           ;print Acc at an integer, -128 to 127
.equ    pint16u, 0x0053         ;print DPTR as an integer, 0 to 65535


;here's some internal RAM we'll use:

	.equ	string, 0x20
	.equ	num, 0x2A


begin:
	lcall	newline
	mov	dptr, #mesg1
	lcall	pstr
	mov	num, #0

get_string:
	;get a character
	lcall	cin
	lcall	upper
	cjne	a, #13, not_cr
	sjmp	got_string	;stop looking if carriage return
not_cr:	mov	b, a		;keep the input character in B
	;is this character one of the ones we know about (in chars string)
	mov	dptr, #chars-1
search_next:
	inc	dptr
	clr	a
	movc	a, @a+dptr
	jz	get_string	;if end of list, ignore and get another char
	cjne	a, b, search_next
	;if we get here, the user's input character is ok
	lcall	cout
	mov	a, #string
	add	a, num		;where to store the character
	mov	r0, a		;r0 points to location to store character
	mov	@r0, b
	inc	num
	mov	a, num
	cjne	a, #9, get_string
	sjmp	got_string

	;when we get to here, we've got a string from the user
	;in internal memory, at "string", length is in "num"
got_string:
	mov	a, num
	jz	begin		;don't allow null string

	lcall	newline
	;mov	a, num
	;lcall	phex
        lcall   newline
        lcall   newline



	mov	r5, #0		;r5 counts line
line_loop:

	mov	r3, #0		;r3 counts character
char_loop:

	mov	a, #string
	add	a, r3
	mov	r0, a
	mov	b, @r0
	;mov	a, b
	;lcall	cout
	;find which character within the string we have
	mov	dptr, #chars-1
	mov	r4, #255
csearch:
	inc	r4
	inc	dptr
	clr	a
	movc	a, @a+dptr
	cjne	a, b, csearch
	;mov	a, r4
	;lcall	phex
	;now r4 has the index of this character
	mov	a, r4
	mov	b, #9
	mul	ab
	mov	dptr, #data
	add	a, dpl
	mov	dpl, a
	mov	a, b
	addc	a, dph
	mov	dph, a
	;now dptr points to the address of this character's bitmap
	mov	a, r5
	add	a, dpl
	mov	dpl, a
	mov	a, dph
	addc	a, #0
	mov	dph, a
	;now dptr points to the byte we need to print
	clr	a
	movc	a, @a+dptr
	mov	r0, #8
bit_loop:
	rlc	a
	push	acc
	mov	a, #' '
	jnc	btlp2
	mov	a, #'#'
btlp2:	lcall	cout
	pop	acc
	djnz	r0, bit_loop	;print all 8 characters

	mov	a, #' '
	lcall	cout

	inc	r3
	mov	a, r3
	cjne	a, num, char_loop

	lcall	newline
	inc	r5
	mov	a, r5
	cjne	a, #9, line_loop
	
	lcall	newline
	lcall	newline

	mov	dptr, #mesg2
	lcall	pstr
	lcall	cin
	lcall	newline
	ret

mesg1:	.db	"Please type a word (9 char max): ",0
mesg2:	.db	"Press any key",0

chars:	.db	" ABCDEFGHIJKLMNOPQRSTUVWXYZ?",0

data:
	.db	00000000b
	.db	00000000b
	.db	00000000b
	.db	00000000b
	.db	00000000b
	.db	00000000b
	.db	00000000b
	.db	00000000b
	.db	00000000b

        .db     00010000b
        .db     00111000b
        .db     00111000b
        .db     01101100b
        .db     01101100b
        .db     01111100b
        .db     11111110b
        .db     11000110b
        .db     11000110b

        .db     11111100b
        .db     11111110b
        .db     11000110b
        .db     11000110b
        .db     11111100b
        .db     11000110b
        .db     11000110b
        .db     11111110b
        .db     11111100b

        .db     01111100b
        .db     11111110b
        .db     11000110b
        .db     11000000b
        .db     11000000b
        .db     11000000b
        .db     11000110b
        .db     11111110b
        .db     01111100b

        .db     11111100b
        .db     11111110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11111110b
        .db     11111100b

        .db     11111110b
        .db     11111110b
        .db     11000000b
        .db     11000000b
        .db     11111100b
        .db     11000000b
        .db     11000000b
        .db     11111110b
        .db     11111110b

        .db     11111110b
        .db     11111110b
        .db     11000000b
        .db     11000000b
        .db     11111100b
        .db     11111100b
        .db     11000000b
        .db     11000000b
        .db     11000000b

        .db     01111100b
        .db     11111110b
        .db     11000110b
        .db     11000000b
        .db     11001110b
        .db     11001110b
        .db     11000110b
        .db     11111110b
        .db     01111110b

        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11111110b
        .db     11111110b
        .db     11000110b
        .db     11000110b
        .db     11000110b

        .db     11111110b
        .db     11111110b
        .db     00011000b
        .db     00011000b
        .db     00011000b
        .db     00011000b
        .db     00011000b
        .db     11111110b
        .db     11111110b

        .db     11111110b
        .db     11111110b
        .db     00001100b
        .db     00001100b
        .db     00001100b
        .db     01001100b
        .db     11001100b
        .db     11111100b
        .db     01111100b

        .db     11000110b
        .db     11000110b
        .db     11001100b
        .db     11001100b
        .db     11111000b
        .db     11001100b
        .db     11001100b
        .db     11000110b
        .db     11000110b

        .db     11000000b
        .db     11000000b
        .db     11000000b
        .db     11000000b
        .db     11000000b
        .db     11000000b
        .db     11000000b
        .db     11111110b
        .db     11111110b

        .db     11000110b
        .db     11101110b
        .db     11111110b
        .db     11010110b
        .db     11010110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b

        .db     11000110b
        .db     11100110b
        .db     11100110b
        .db     11110110b
        .db     11010110b
        .db     11011110b
        .db     11001110b
        .db     11000110b
        .db     11000110b

        .db     01111100b
        .db     11111110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11111110b
        .db     01111100b

        .db     11111100b
        .db     11111110b
        .db     11000110b
        .db     11000110b
        .db     11111110b
        .db     11111100b
        .db     11000000b
        .db     11000000b
        .db     11000000b

        .db     01111100b
        .db     11111110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11111100b
        .db     01111010b

        .db     11111100b
        .db     11111110b
        .db     11000110b
        .db     11000110b
        .db     11111110b
        .db     11111100b
        .db     11001100b
        .db     11000110b
        .db     11000110b

        .db     01111110b
        .db     11111110b
        .db     11000000b
        .db     11000000b
        .db     01111100b
        .db     00000110b
        .db     00000110b
        .db     11111110b
        .db     11111100b

        .db     11111110b
        .db     11111110b
        .db     00011000b
        .db     00011000b
        .db     00011000b
        .db     00011000b
        .db     00011000b
        .db     00011000b
        .db     00011000b

        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11111110b
        .db     01111100b

        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     01111100b
        .db     00111000b
        .db     00010000b

        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     11010110b
        .db     11010110b
        .db     11111110b
        .db     11101110b
        .db     11000110b

        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     01101100b
        .db     00111000b
        .db     01101100b
        .db     11000110b
        .db     11000110b
        .db     11000110b

        .db     11000110b
        .db     11000110b
        .db     11000110b
        .db     01101100b
        .db     01101100b
        .db     00111000b
        .db     00010000b
        .db     00010000b
        .db     00010000b

        .db     11111110b
        .db     11111110b
        .db     00001100b
        .db     00001100b
        .db     00111000b
        .db     01100000b
        .db     01100000b
        .db     11111110b
        .db     11111110b

        .db     01111100b
        .db     11111110b
        .db     11000110b
        .db     00000110b
        .db     00001100b
        .db     00011000b
        .db     00000000b
        .db     00011000b
        .db     00011000b

