
all:  	 scream.hex scram.hex


scream.hex: scream.asm ioports.inc startup.asm
	 nasm -o scream.hex -f ith -l scream.lst scream.asm
	 cp scream.hex ../bin

scram.hex: scram.asm ioports.inc startup.asm
	 nasm -o scram.hex -f ith -l scram.lst scram.asm
	 cp scram.hex ../bin

pretty:
	cp *.asm ./backup
	pretty6502 -p5 -a0 -du -mu -l ./backup/scram.asm scram.asm
	pretty6502 -p5 -a0 -du -mu -l ./backup/scream.asm scream.asm
	pretty6502 -p5 -a0 -du -mu -l ./backup/startup.asm startup.asm

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
