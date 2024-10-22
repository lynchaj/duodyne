# make the full Floating Point Emulator
#
NASM=nasm
#NASM=nasm208

ASMFILES1=em187a.asm em187b.asm em187c.asm em187d.asm em187e.asm
ASMFILES2=em187f.asm em187g.asm em187h.asm
INCLUDES= ../config.asm ../bda.inc


all:	em187.obj

em187.obj:  em187.asm $(INCLUDES) $(ASMFILES1) $(ASMFILES2)
    $(NASM) -s -DLONG -f obj -O6+ -l em187.lst -o em187.obj  em187.asm

em187.bin:  em187.asm $(INCLUDES) $(ASMFILES1) $(ASMFILES2)
    $(NASM) -s -DLONG -f bin -O6+ -l em187.ls2 -o em187.bin  em187.asm


clean:		.SYMBOLIC
        rm *.obj
        rm *.ls?
	rm *.bin


