
all:  	 monitor.hex



monitor.hex: mon88.asm ioports.inc startup.asm int10.asm int16.asm int1a.asm
	 nasm -o monitor.hex -f ith -l monitor.lst mon88.asm
	 cp monitor.hex ../../bin

pretty:
	cp *.asm ./backup
	pretty6502 -p5 -a0 -du -mu -l ./backup/mon88.asm mon88.asm
	pretty6502 -p5 -a0 -du -mu -l ./backup/startup.asm startup.asm
	pretty6502 -p5 -a0 -du -mu -l ./backup/int10.asm int10.asm
	pretty6502 -p5 -a0 -du -mu -l ./backup/int16.asm int16.asm
	pretty6502 -p5 -a0 -du -mu -l ./backup/int1a.asm int1a.asm


clean:
	@rm -f *.o
	@rm -f *.bin
	@rm -f *.lis
	@rm -f *.err
	@rm -f *.out
	@rm -f *.com
	@rm -f *.co6
	@rm -f *.map
	@rm -f *.lst
	@rm -f *.hex
	@rm -f *.s19
	@rm -f *.s19a
	@rm -f *.sys
	@rm -f *.s

cleandust:
	@rm -f *.o
	@rm -f *.out
	@rm -f *.map
	@rm -f *.lst
