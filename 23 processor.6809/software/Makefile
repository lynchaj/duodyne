
all:  	 scrm816.hex rom816.hex #testbus.s19 testfp.s19

rom816.out: rom816.asm
	ca65   rom816.asm -l rom816.lst -o rom816.o
	ld65 rom816.o -m rom816.map -C rom816.cfg -o rom816.out

scrm816.out: scrm816.asm
	ca65   scrm816.asm -l scrm816.lst -o scrm816.o
	ld65 scrm816.o -m scrm816.map -C rom816.cfg -o scrm816.out

testfp.out: testfp.asm
	ca65   testfp.asm -l testfp.lst -o testfp.o
	ld65 testfp.o -m testfp.map -C rom816.cfg -o testfp.out

testbus.out: testbus.asm
	ca65   testbus.asm -l testbus.lst -o testbus.o
	ld65 testbus.o -m testbus.map -C rom816.cfg -o testbus.out

rom816.hex: rom816.out
	srec_cat  rom816.out -binary -offset 0x0200 -exclude 0x0000 0xE000 -o  rom816.s19  -data-only
	srec_cat  rom816.out -binary -offset 0x0200 -exclude 0x0000 0xE000 -o  rom816.hex  -intel -address-length=2
	sed -i -e '$$aS9' rom816.s19

scrm816.hex: scrm816.out
	srec_cat  scrm816.out -binary -offset 0x0200 -exclude 0x0000 0xE000 -o  scrm816.s19  -data-only
	srec_cat  scrm816.out -binary -offset 0x0200 -exclude 0x0000 0xE000 -o  scrm816.hex  -intel -address-length=2
	sed -i -e '$$aS9' scrm816.s19

testbus.s19: testbus.out
	srec_cat  testbus.out -binary -offset 0x0200 -o  testbus.s19  -data-only
	sed -i -e '$$aS9' testbus.s19

testfp.s19: testfp.out
	srec_cat  testfp.out -binary -offset 0x0200 -o  testfp.s19  -data-only
	sed -i -e '$$aS9' testfp.s19


pretty:
	cp *.asm ./backup
	pretty6502 -p1 -a0 -du -mu -l ./backup/testfp.asm testfp.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/testbus.asm testbus.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/scrm816.asm scrm816.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/rom816.asm rom816.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/supermon816.asm supermon816.asm

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
	@rm -f *.sys
	@rm -f *.s

cleandust:
	@rm -f *.o
	@rm -f *.out
	@rm -f *.map
	@rm -f *.lst
