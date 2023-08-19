;
; Duodyne basic operation test.
; Produces alternating blinking lights on ROMRAM card user LEDs
; and runs forever.
;
; Build with TASM using command line like:
;   tasm -t80 -g3 -fFF blink.asm blink.rom blink.lst
;
	.org	$0000
;
	di
;
	ld	e,$01		; starting value for rtc latch
;
loop:
	; program the rtc latch
	ld	a,e		; get latch value
	out	($94),a		; write to rtc port
;
	; wait a while
	ld	bc,0
wait1:
	dec	bc
	ld	a,b
	or	c
	jr	nz,wait1
;
	; flip latch bits
	ld	a,e		; cur latch value to A
	xor	$03		; invert bits
	ld	e,a		; save back in E
;
	; loop a very long time...
	jr	loop
;
	halt
;
	.end
	