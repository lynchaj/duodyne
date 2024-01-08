// Breadboard ROM boot menu
//
bmenu:	xop @logon,14	// print boot logon message and options.

1:	xop r1,13	// read character into msb of r1.
        ci r1,'1'*256	// EVMBUG option selected?
	jne 2f		// no, test BASIC option
	xop @0x00ad,14	// yes, print evmbug logon message.
	b @0x0142	// branch to evmbug.

2:	ci r1,'2'*256	// BASIC option selected?
	jne 3f		// no, test MDEX option
	li r1,0x1600	// yes, copy basic from EPROM to RAM.
	li r2,0x8000
	li r3,0x5eba
9:	mov (r1)+,(r2)+
	dect r3
	jne 9b
	b @0x8036	// branch to BASIC.

3:	ci r1,'3'*256	// MDEX option selected?
	jne 4f		// no, loop round and wait for another character.
	b @0x7800	// branch to MDEX boot loader.

4:	ci r1,'4'*256	// UNIX option selected?
	jne 1b		// no, loop round and wait for another character.
	b @0x7b00	// branch to UNIX boot loader.

// logon message
logon:  "\r\n"
	"TMS 9995 BREADBOARD SYSTEM\r\n"
        "BY STUART CONNER\r\n"
        "PRESS 1 FOR EVMBUG MONITOR\r\n"
        "PRESS 2 FOR CORTEX BASIC\r\n"
	"PRESS 3 FOR MDEX\r\n"
	"PRESS 4 FOR UNIX\r\n\0"

