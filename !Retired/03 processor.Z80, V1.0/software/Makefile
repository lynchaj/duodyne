
all:  	hdm80.bin

hdm80.bin: hdm80.asm
	z80asm -b -l -m8080 hdm80.asm  2> hdm80.err
	@rm hdm80.o



pretty:
	cp *.asm ./backup
	pretty6502 -p2 -a0 -du -mu -l ./backup/hdm80.asm hdm80.asm

clean:
	@rm -f *.o
	@rm -f *.bin
	@rm -f *.lis
	@rm -f *.err
	@rm -f *.out
	@rm -f *.com
	@rm -f *.map
	@rm -f *.lst
	@rm -f *.hex
	@rm -f *.s19
	@rm -f *.sys
	@rm -f *.s
	@rm -f *.rom

cleandust:
	@rm -f *.o
	@rm -f *.out
	@rm -f *.map
	@rm -f *.lst
