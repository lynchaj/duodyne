# TMS9995 CPU Card

This is a Duodyne implimentation of Stuart Conner's Mini-Cortex system.  The Mini-Cortex system is a further development of his TMS 9995 breadboard project to produce a system similar to a Powertran Cortex, but using more modern components. The system is based around a TMS 9995 running at 3 MHz, with 32K byte EEPROM, and will use 512K bytes of RAM from a Duodyne ROMRAM carf accessed through a memory mapper. An on-board serial port and IDE interface exists on the card.

The main EEPROM image provides a boot menu which enables the user to select between the EVMBUG system monitor from TI's TMS 9995 Evaluation Module, a port of the Powertran Cortex Power BASIC made for a TM 990 computer, the Marinchip Disk Executive (MDEX) operating system, and an implementation of V6 Unix including a C compiler.

[Much more information can be found at Stuart's site](https://www.stuartconner.me.uk/mini_cortex/mini_cortex.htm)

## Memory Map
The memory map is shown in the table below.

```
Memory Address	Mapped To
>0000 - >7FFF	ROM when enabled, otherwise RAM
>8000 - >EFFF	RAM
>F000 - >F0FB	TMS 9995 internal RAM
>F0FC - >FDFF	RAM
>FE00 - >FE3F	CF card ATA registers (FIX INCOMPLETE DECODING WITH NEXT REVISION)
>FE40 - >FE7F	Memory mapper registers 0-15 (>FE40 - >FE4F, repeats at >FE50 etc. . .  FIX INCOMPLETE DECODING WITH NEXT REVISION)
>FE80 - >FEBF	Offboard IO (ports $80-$FF)
>FFF0 - >FFF9	RAM
>FFFA - >FFFF	TMS 9995 internal RAM

CRU Address	Mapped To
>0000 - >003F	TMS 9902 registers
>0040 - >007F	Control signal latch (further details here)
 	(Plus processor internal CRU bits)
    
(Note that in TI Speak ">" means Hexidecimal, so for the rest of us >FFFA is the same as $FFFA or 0xFFFA or FFFAH)
```
[for more information see Stuart's site](https://www.stuartconner.me.uk/mini_cortex/mini_cortex.htm)

## Creating CF card Image for MDEX and Unix

The CF card has to be newly formatted with an MBR (master boot record), a single partition formatted as FAT32, and a cluster size of 4096 bytes - the CF card needs to be at least 256 MB to support this. Not all brands/sizes of CF card seem to work - you may have more success with an older, low capacity card. A SanDisk 2.0GB card with a "SDCFB" marking on the back works well.

It can be problematic formatting a new card using Windows 10 as it does not always seem to write an MBR to the card. I use a formatting utility called Rufus [details and download here](https://rufus.ie/en/) with Boot selection==Non bootable, Partition Scheme==MBR, File System=FAT32, and Cluster Size= 4096 Bytes. Once the card is correctly formatted, use Windows to write the four files from the software folder ZIP filedirectly to the card.
[for more information see Stuart's site](https://www.stuartconner.me.uk/mini_cortex/mini_cortex.htm)

## Jumper Settings
```
JP1- CPU Signal Pullups - Jumpers should be installed if this is the only CPU card in the system, otherwise leave unjumpered
JP2 - Reset Selection - 1&2 closed for External bus Reset in 2&3 closed for CPU to assert reset to the bus
JP4 - Jumper to enable on board LED for IDE or connect external LED for IDE Activity
JP5 - 2&3 for power on IDE connector 

J4 - Enable Serial Interrupts (required for Unix and MDEX)
J6 - TTL Serial +5v enable
J7 - External User flag bits (CRU 0046-004C)

J2 - 1&2 for Stand Alone Operation, 2&3 for secondary CPU
J3 - 1&2 for Stand Alone Operation, 2&3 for secondary CPU
J8 - 2&3 for Stand Alone Operation, 1&2 for secondary CPU
```
## Powering up
The serial port on the TMS9995 board is configured for 9600 Baud, 7 data bits, even parity, one stop bit, no flow control.

The EVMBUG monitor and Cortex BASIC software applications, and the boot loaders for MDEX and Unix, are stored on a single 32K byte EEPROM. The required application is selected from a boot menu. To display the boot menu, connect the board to a configured serial port on a PC, apply power then press any key.

You should then see:
```
TMS 9995 BREADBOARD SYSTEM
BY STUART CONNER
PRESS 1 FOR EVMBUG MONITOR
PRESS 2 FOR CORTEX BASIC
PRESS 3 FOR MDEX
PRESS 4 FOR UNIX
```
To select a software application from the menu, press the corresponding numeric key.

## Useful Links
MDEX documentation is available on the site http://www.powertrancortex.com/documentation.html. The documentation and MDEX disks were recovered and made available by Dave Hunter, the owner of the www.powertrancortex.com site. Porting of the MDEX files to the Mini-Cortex was by Paul Ruizendaal. On the Mini-Cortex, the files are stored in two emulated disks on the CF card.

The first version of Unix ported was LSX Unix (https://www.mailcom.com/lsx/), which was designed to run with 40K byte RAM and two 256K byte floppies. LSX Unix was adapted from Unix V6 by Dr. Heinz Lycklama (https://www.60bits.net/msu/mycomp/terak/termubel.htm). This port has been further ported to the TI 990 minicomputer by Dave Pitts, who has also made improvements to the code build system.



[EVMBUG documentation](https://www.stuartconner.me.uk/tibug_evmbug/tibug_evmbug.htm#evmbug)


## Bugs/To Do
* Add Xmodem to Unix
* Add Vi to Unix
* CF card ATA registers have INCOMPLETE DECODING 
* Memory mapper have INCOMPLETE DECODING
* Add Serial port drivers for off board Duodyne hardware
* Add Mass storage drivers for off board Duodyne hardware

## Troubleshooting

The first test image tests just the processor (TMS9995_test_1_eprom_image), the EPROM and the EPROM chip select logic. Program and fit the EPROM, power on, press the reset switch.  The CPU should execute a loop from ROM., then use the logic probe to check for a series of pulses on pin 20 of the EPROM every 2 seconds or so. 

If the first test passes, repeat with the second test image (TMS9995_test_2_eprom_image), which also tests the RAM and the RAM chip select logic. With the second test, a series of pulses should be seen on pin 20 of the EPROM every 6 seconds or so.

The third test image has two versions.   The first version configures the serial port to 9600 Baud, 7 bits/character, even parity, 2 stops bits, no flow control, and then loops continually sending the ASCII characters >21 ("!") to >7E .  This version tests most of the system including ROM and RAM.   The second version is a ROM only version. It also configures the serial port to 9600 Baud, 7 bits/character, even parity, 2 stops bits, no flow control, and then loops continually sending the ASCII characters >21 ("!") to >7E , but does not use any external RAM.

## BOM
Qty|Reference(s)|Value
--- | ----------- | -----
22|C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15, C16, C17, C19, C21, C23, C25, C27|0.1uf
5|C18, C20, C22, C24, C42|10uf Electrolytic
1|C26|22uf Electrolytic
1|C28|47uf Electrolytic
2|C40, C41|15pf
3|D1,D2,D3,D5,D6|LED
1|D4|1N4148
1|J1|Pin Header 02x08 Male
1|J2|Pin Header 01x03 Male
1|J3|Pin Header 01x03 Male
1|J4|Pin Header 01x02 Male
1|J5|Pin Header 01x06 Male
1|J6|Pin Header 01x02 Male
1|J7|Pin Header 01x06 Male
1|J8|Pin Header 01x03_Male
1|JP1|Pin Header 02x04 Male
1|JP2|Pin Header 01x03 Male
1|JP4|Pin Header 01x02 Male
1|JP5|Pin Header 01x03 Male
3|P1, P2, P3|Pin Header 02X25 Male
1|P4|Pin Header 02x20 Male
5|R1, R3, R7, R12, R13|470 ohm
5|R2, R4, R9, R14, R15|10K ohm
1|R8|10 ohm
1|R10|470 ohm
1|R11|1K ohm
2|RN1, RN2|4700 8 Resistor Network
1|RN3|1K 8 Resistor Network
1|RN4|10K  8 Resistor Network
1|SW1|Switch:SW_Push
1|U1|74LS14
1|U2|74LS07
1|U3|TMS9995
1|U4|74LS04
2|U5, U7|74LS74
1|U6|74LS112
1|U8|GAL22V10
5|U9, U10, U11, U13, U14|74LS244
1|U12|74LS245
1|U15|74LS138
1|U16|74LS32
2|U17, U20|74LS688
1|U18|27C256
1|U19|DS1233
1|U21|TMS9902A
1|U22|74LS259
1|U23|74LS612
1|U24|74LS08
1|Y1|12MHz Crystal

