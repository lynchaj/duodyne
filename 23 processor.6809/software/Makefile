all:  	scream.com monitor.com mon09.hex


scream.com: scream.asm
	lwasm --6809 scream.asm -s --list=scream.lst --map=scream.map --output=scream.s --format=srec
	srec_cat  scream.s -exclude 0x0000 0xF000 -offset -0xE000 -o  scream.hex  -intel -address-length=2
	srec_cat  scream.s -offset -0xEFE0 -o scream.com -binary
	@rm scream.s
	truncate scream.com -s 4130

monitor.com: monitor.asm
	lwasm --6809 monitor.asm -s --list=monitor.lst --map=monitor.map --output=monitor.s --format=srec
	srec_cat  monitor.s -exclude 0x0000 0xF000 -offset -0xE000 -o  monitor.hex  -intel -address-length=2
	srec_cat  monitor.s -offset -0xEFE0 -o monitor.com -binary
	@rm monitor.s
	truncate monitor.com -s 4130

mon09.hex: mon09.asm
	lwasm --6809 mon09.asm -s --list=mon09.lst --map=mon09.map --output=mon09.s --format=srec
	srec_cat  mon09.s -exclude 0x0000 0xE000 -offset -0xE000 -o  mon09.hex  -intel -address-length=2
	@rm mon09.s

pretty:
	cp *.asm ./backup
	pretty6502 -p1 -a0 -du -mu -c50 -l ./backup/scream.asm scream.asm
	pretty6502 -p1 -a0 -du -mu -c50 -l ./backup/monitor.asm monitor.asm
	pretty6502 -p1 -a0 -du -mu -c50 -l ./backup/mon09.asm mon09.asm


clean:
	@rm -f *.o
	@rm -f *.out
	@rm -f *.com
	@rm -f *.co6
	@rm -f *.map
	@rm -f *.lst
	@rm -f *.hex
	@rm -f *.s19
	@rm -f *.s

cleandust:
	@rm -f *.o
	@rm -f *.out
	@rm -f *.map
	@rm -f *.lst