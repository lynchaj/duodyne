# Makefile for the Duodyne relocatable BIOS
#  Use Open Watcom WMAKE to make
#  Use Open Watcom C 1.9 or 2.0
#  Use NASM version 0.98.39 (real mode DOS)
#   or NASM version 2.11 (cwsdpmi needed, or WINNT)
#
# On Linux, you will have to set up the following environment:
#  EXPORT WATCOM=/usr/bin/watcom
#  EXPORT INCLUDE=$WATCOM/h
#
# On WINNT, the installation of the Open Watcom suite will
# set these up for you.
#
# Minimum (BIOS-ROM) CHIP size is 64K as of Jan 2013, release 2.0
#  CHIP sizes of 128K and 256K are also generated.
#
#
SBC188 = 1
ROM = 32
ETC = tbasic.hex -d26K  -d18k em187.hex
CHIP = 64
FAST = -DHAS_FASTCALL=1
V=$(SBC188)


CC = wcl -c
#COPT = /Gs2 /Zp1 /Ois /DSBC188=$(SBC188) /Fl
# Open Watcom C Compiler options:
# -mc   compact memory model
# -zdp  DS == DGROUP
# -zu   SS != DGROUP
# -s    remove stack overflow checks
# -zp1  set struct packing alignment to 1
# -oi   inline intrinsic functions
# -os   optimize for space
# -1    generate code for 186 or higher
# -fpi87 use 8087 instructions
# -q	quiet compile
COPT = -q -mc -zdp -zu -s -zp1 -oi -os -1 -fpi87 -DSBC188=$(SBC188)
CLIST = wdis -l -s $*.obj
SIZE = -DROM=$(ROM) -DCHIP=$(CHIP) $(RED)
#
# The newer version of NASM provides the __DATE__ & __TIME__
#NASM = nasm
#NASM = nasm208
# use 'nasm' version 2.11.08 on Ubuntu
NASM = nasm
#
NOPT = $(RED) $(FAST) -O9 -DSBC188=$(SBC188) $(TRC) $(ANSI) $(TESTS)
LINK = wcl
# Open Watcom liner options:
# -lr   create a DOS real-mode program
LOPT = -lr -q

RM=rm -f
EXE2ROM=tools/exe2rom
HEX2BIN=tools/hex2bin
BIN2HEX=tools/bin2hex
CP=cp
CAT=cat
OUT= >
PLUS=
NULL=/dev/null
ZIP=zip
SEP=/

INCLUDES = config.asm cpuregs.asm equates.asm date.asm segdef.asm ascii.asm bda.inc disk.inc macros.inc

OBJECT1 = floppy.obj int10ser.obj int16.obj misc15.obj ide.obj
OBJECT2 = timers.obj inttrace.obj tests.obj ppide.obj usb.obj
OBJECT3 = idelib.obj int14ser.obj int17par.obj
OBJECT4 = fpem/em187.obj
OBJECTC1 = cprintf.obj sio.obj nvram.obj strtoul.obj libc.obj debug.obj
OBJECTC2 = kbd.obj

OBJECTA = $(OBJECT1) $(OBJECT2) $(OBJECT3) $(OBJECT4)
OBJECTC = $(OBJECTC1) $(OBJECTC2)

OBJECTS = rbios.obj $(OBJECTA) $(OBJECTC) copyrght.obj


ROMS = bios064.bin bios128.bin bios256.bin
MISC = COPYING config.asm abios.lib cbios.lib

.EXTENSIONS:
.EXTENSIONS: .bin .obj .exe .asm .c .h

.asm.bin:
	$(NASM) $(NOPT) $(SIZE) -f bin -o $@ -l $*.lst  $*.asm
.asm.obj:
	$(NASM) $(NOPT) $(SIZE) -f obj -o $@ -l $*.lst  $*.asm
.c.obj:
	$(CC) $(COPT) $(SIZE) -fo=$@ $*.c
	$(CLIST)

all:	config.asm  $(ROMS) .SYMBOLIC

test:	1Ah_time.obj

help:	.SYMBOLIC
	echo Copy one of the *.CFG files to CONFIG.ASM to start

burn:	bios128.bin  amd		# was sst
# JRC uses this to burn the SST39SF010A flash chip
sst:	.SYMBOLIC
	minipro -p SST39SF010A -w bios128.bin
# JRC uses this to burn the AMD AM29F010 flash chip
amd:	.SYMBOLIC
	minipro -p AM29F010@DIP32 -w bios128.bin

distro: spotless .SYMBOLIC
	$(CP) wvga3.cfg config.asm
	wmake clean
	wmake v$(V)wvga3.zip
	$(CP) vga3.cfg config.asm
	wmake clean
	wmake v$(V)vga3.zip
	$(CP) wcvdu.cfg config.asm
	wmake clean
	wmake v$(V)wcvdu.zip
	$(CP) cvdu.cfg config.asm
	wmake clean
	wmake v$(V)cvdu.zip
	$(CP) wyse.cfg config.asm
	wmake clean
	wmake v$(V)wyse.zip
	$(CP) ansi.cfg config.asm
	wmake clean
	wmake v$(V)ansi.zip

# ANSI should be last, leaving 'config.asm' == 'ansi.cfg'

v$(V)wvga3.zip:	$(MISC) $(ROMS)
	$(ZIP) $@ $<

v$(V)vga3.zip:	$(MISC) $(ROMS)
	$(ZIP) $@ $<

v$(V)wcvdu.zip:	$(MISC) $(ROMS)
	$(ZIP) $@ $<

v$(V)cvdu.zip:	$(MISC) $(ROMS)
	$(ZIP) $@ $<

v$(V)wyse.zip:	$(MISC) $(ROMS)
	$(ZIP) $@ $<

v$(V)ansi.zip:	$(MISC) $(ROMS)
	$(ZIP) $@ $<




# copy of 1985 PC/AT bios data area
dseg:	dseg.asm	.SYMBOLIC
	masm /X dseg.asm,nul,dseg.lst;
sizer:	sizer.exe sizer2.exe	.SYMBOLIC
uart:	uart_id.exe


roms:   startup.bin rbios.exe makefile .SYMBOLIC
	$(EXE2ROM) rbios.exe bios256.bin -r $(ROM) -e 256 -s startup.bin
	$(EXE2ROM) rbios.exe bios128.bin -r $(ROM) -e 128 -s startup.bin
	$(EXE2ROM) rbios.exe bios_64.bin -r $(ROM) -e 64  -s startup.bin

check:  startup.bin rbios.exe makefile .SYMBOLIC
	$(EXE2ROM) rbios.exe check.bin -s startup.bin -v -e $(CHIP) -r $(ROM) >foo
	@echo .
	@echo Output listing is in FOO

# Strictly for testing
fdc:	wd37c65.obj fdc8272.obj	.SYMBOLIC

bios064.bin:	rbios.hex tbasic.hex em187.hex
	$(HEX2BIN) -o bios064.bin -R64K rbios.hex $(ETC)
	$(CP) bios064.bin ../../bin/bios064.bin
bios128.bin:	space64.bin bios064.bin
	$(CAT) space64.bin $(PLUS) bios064.bin $(OUT) bios128.bin
	$(CP) bios128.bin ../../bin/bios128.bin
bios256.bin:	space64.bin bios128.bin
	$(CAT) space64.bin $(PLUS) space64.bin $(PLUS) bios128.bin $(OUT) bios256.bin
	$(CP) bios256.bin ../../bin/bios256.bin

rbios.hex:	rbios.bin
	$(BIN2HEX) -o rbios.hex rbios.bin

rbios.bin:      rbios.exe startup.bin makefile
	$(EXE2ROM) rbios.exe rbios.bin -s startup.bin -r $(ROM) -e $(CHIP)

rbios.exe:     copyrght.obj rbios.obj abios.lib cbios.lib
	$(LINK) $(LOPT) -k1024 -fe=$@ -fm=$*.map $<


tbasic.hex:	tbasic.bin
	$(BIN2HEX) -o tbasic.hex tbasic.bin

tbasic.bin:	tbasic.asm $(INCLUDES)

config.obj:     config.asm
	$(NASM) $(NOPT) -f obj -DMAKE_OBJECT_FILE config.asm

em187.exe:	fpem/em187.obj
	$(LINK) $(LOPT) -k1024 -fe=$@ -fm=$*.map $<
em187.bin:	em187.exe
	$(EXE2ROM) em187.exe em187.bin -s $(NULL) -r 32K -e 32K
em187.hex:	em187.bin
	$(BIN2HEX) -o em187.hex em187.bin

fpem/em187.obj:	 fpem/makefile
	cd      fpem
	wmake   em187.obj
	cd      ..

ppide_sa.obj:      ppide.asm $(INCLUDES)
	$(NASM) $(NOPT) -DSTANDALONE -f obj -o $@ -l ppide_sa.lst ppide.asm

usb_sa.obj:      usb.asm $(INCLUDES)
	$(NASM) $(NOPT) -DSTANDALONE -f obj -o $@ -l usb_sa.lst usb.asm


wbios.lib:      $(OBJECTS)
	wlib -q -n wbios.lib +int10ser.obj +int14ser.obj +int16.obj +int17par.obj +timers.obj +ppide.obj +usb.obj
	wlib -q wbios.lib +sio.obj +nvram.obj +floppy.obj +misc15.obj +diskio.obj
	wlib -q wbios.lib +cprintf.obj +libc.obj +fpem/em187.obj
	wlib -q wbios.lib +debug.obj +strtoul.obj  +inttrace.obj +tests.obj
	wlib -q wbios.lib +kbd.obj


abios.lib:	$(OBJECTA)
	wlib -q -n abios.lib +floppy.obj +int10ser.obj +int14ser.obj +int16.obj +int17par.obj +misc15.obj +ide.obj
	wlib -q    abios.lib +timers.obj +inttrace.obj +tests.obj +ppide.obj  +usb.obj
	wlib -q    abios.lib  +idelib.obj  +fpem/em187.obj

cbios.lib:	$(OBJECTC)
	wlib -q -n cbios.lib +cprintf.obj +sio.obj +nvram.obj +libc.obj +strtoul.obj +debug.obj +kbd.obj


uart_det.obj:	uart_det.asm $(INCLUDES)
	$(NASM) $(NOPT) -DSTANDALONE=1 -f obj -o $@ -l $*.lst  $*.asm

uart_id.exe:	uart_id.obj uart_det.obj
	$(LINK) $(LOPT) -k1024 -fe=$@ -fm=$*.map $<

sizer.obj:      sizer.c equates.h
sizer.exe:      sizer.obj
	$(LINK) $(LOPT)  $<

sizer2.obj:      sizer2.c equates1.h bda.inc
sizer2.exe:      sizer2.obj
	$(LINK) $(LOPT)  $<

serial:	ser_util.c
	wcl386 -DSTANDALONE=1 $<
	mv ser_util serial


space64.bin:
	$(HEX2BIN) -R 64K -o $@

# Maintenance

tidy:	.SYMBOLIC
	echo foo >foo.err
	echo foo >foo.lst
	echo foo >fpem/foo.lst
	echo foo >foo.map
	$(RM) *.lst
	$(RM) *.map
	$(RM) *.err
	$(RM) fpem$(SEP)*.lst

clean:	tidy .SYMBOLIC
	echo foo >foo.bin
	echo foo >foo.obj
	echo foo >fpem$(SEP)foo.obj
	echo foo >foo.exe
	echo foo >foo.sys
	echo foo >foo.hex
	echo foo >xbios.lib
	$(RM) *.bin
	$(RM) *.obj
	$(RM) fpem$(SEP)*.obj
	$(RM) *.exe
	$(RM) *.sys
	$(RM) ?bios.lib
	$(RM) *.hex

spotless: clean .SYMBOLIC
	echo foo >foo.lib
	echo foo >foo.bak
	echo foo >foo.bk0
	echo foo >foo.foo
	echo foo >goo.foo
	echo foo >config.asm
	$(RM) *.lib
	$(RM) *.bak
	$(RM) *.bk?
	$(RM) foo*.*
	$(RM) goo*.*
	$(RM) config.asm

# Dependencies
sbc188.h:       mytypes.h

copyrght.obj:	copyrght.asm $(INCLUDES)
rbios.obj:      rbios.asm $(INCLUDES) memory.asm ds1302.asm makefile
startup.bin:    startup.asm $(INCLUDES) date.asm post.asm makefile
timers.obj:     timers.asm $(INCLUDES)
floppy.obj:     floppy.asm $(INCLUDES)
int16.obj:      int16.asm $(INCLUDES)
int10ser.obj:   int10ser.asm $(INCLUDES) uart_det.asm
int14ser.obj:	int14ser.asm $(INCLUDES)
int17par.obj:	int17par.asm $(INCLUDES)
inttrace.obj:	inttrace.asm $(INCLUDES)
misc15.obj:     misc15.asm $(INCLUDES) cassette.asm
ide.obj:	ide.asm $(INCLUDES)
ppide.obj:      ppide.asm $(INCLUDES)
usb.obj:        usb.asm $(INCLUDES)
idelib.obj:	idelib.asm $(INCLUDES)
1Ah_time.obj:	1Ah_time.asm $(INCLUDES)

cprintf.obj:    cprintf.c sbc188.h
sio.obj:	sio.c sbc188.h sio.h
nvram.obj:      nvram.c sbc188.h ds1302.h sio.h equates.h ide.h bda.inc libc.h
libc.obj:	libc.c libc.h
strtoul.obj:	strtoul.c sbc188.h mytypes.h libc.h
debug.obj:      debug.c mytypes.h equates.h sio.h debug.h bda.inc
kbd.obj:	kbd.c mytypes.h sbc188.h equates.h kbd_pc.h kbd_stat.h config.asm
fdc8272.obj:	fdc8272.c mytypes.h sbc188.h io.h fdc8272.h wd37c65.h
wd37c65.obj:	wd37c65.c mytypes.h sbc188.h io.h wd37c65.h
ser_util.obj:	ser_util.c mytypes.h
test.obj:	test.c mytypes.h bda.inc


int16.as1:     int16.asm $(INCLUDES)
	$(NASM) -E $(NOPT) $(SIZE)  -f obj $*.asm >$*.as1
int10ser.as1:     int10ser.asm $(INCLUDES) uart_det.asm
	$(NASM) -E $(NOPT) $(SIZE)  -f obj $*.asm >$*.as1


dprintf.obj:	dprintf.c sbc188.h
uart_id.obj:	uart_id.c
post.bin:	post.asm	#for testing
