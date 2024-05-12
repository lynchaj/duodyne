# SPDX-License-Identifier: GPL-2.0-or-later

all: DACTONE.COM

DACTONE.COM: main.c wave.c sio.c interrupt.asm hbios.asm hbios.h buffer.h Makefile
	zcc +cpm --list -m -o dactone --math32 -create-app main.c wave.c sio.c hbios.asm interrupt.asm 
	@rm dactone

clean:
	rm -f dactone dactone.com *.map *.lis
