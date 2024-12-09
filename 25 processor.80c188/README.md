# Duodyne 80c188 Card
80c188 processor board (hardware and software) for the Duodyne computer system.

Based on the Retrobew Computer SBC-188 board by John Coffman

## Firmware

### BIOS
 The firmware in the BIOS folder is a subset of the SBC-188 firmware.   It currently runs MS-DOS 3.3 and supports PPIDE drives on the Duodyne Disk IO card and USB drives on the Multi IO card.  It requires a RAMROM card and can be used as a primary or secondary CPU.   The RAMROM RTC is supported.
 
 UART must be jumpered for EIRQ0
 
#### BIOS ToDo:
* DiskIO Floppy Drive Support
* Missing Disk-io SD Support
* Missing Disk-io Network Support
* BIOS Support for the PCF 8584
* Better Front Panel Support
* Test multi-io serial support 
* Support for other DuoDyne Hardware
 1.Voice
 1.DualESP
 1.MappedVideo
* Support for Xenix 86
* Support for CPM 86

### Monitor
This is a simple monitor "Mon88" originally by Hans Tiggeler - http://www.ht-lab.com

### Test Programs
There are also two test roms provided.  
* Scream -- this program outputs a constant stream of "A" at 9600-n-8-1 via the on-board uart.
* Scram -- this program outputs an incrimenting character from a RAM address at 9600-n-8-1 via the on-board uart.


## Bugs 
### Hardware
   1. V 0.70
   * To get RAM access -- A21 needs to be high, and it is not. Also A20 should not be left floating.   
      1.  Connect P2 Pin 26 to U17 Pin 18.
      1.  Connect P2 Pin 28 to U17 Pin 16.
      1.  Connect RN1 Pin 3 to U17 Pin 2.
      1.  Connect RN1 Pin 5 to U17 Pin 4.
      1.  Cut Trace between U17 Pin 1 and Pin 19 (bottom of board)
      1.  Connect U17 Pin 1 U6 Pin 19

### BIOS
* Missing multi-io Mouse Support (no plans to support)
* Missing multi-io SD Support (no plans to support)

      
 
## Jumper Settings (V.90)

      JP1  - Allow RES_IN to generate board Reset
      
      JP4 - Pullups for IORQ,MREQ,WR,RD.   
            All Open for Secondary CPU
            All Shorted for only CPU

      

      J1 - Activation Address Port
        
      J2  - CPU Control
                1&2 Only CPU
                2&3 Secondary CPU
      
      J3  - Reset Control
                1&2 Only CPU
                2&3 Secondary CPU                
      
      J4 - Reset Switch Input
        
      J5 - Bus IRQ Enable (0-3)
                1&2 Enable Bus EIRQ3 to Int3
                3&4 Enable Bus EIRQ2 to Int2
                5&6 Enable Bus EIRQ1 to Int1
                7&8 Enable Bus EIRQ0 to Int0

      J7 i2c IRQ Selection
        
      J8 UART IRQ Selection
            (BIOS Requires INT0 - tbd)

      
      J13 Rom Type Selection
            1&2 32 pin Flash or CMOS 
            2&3 28 pin Flash or CMOS 
        
      J14 Rom Type Selection
            1&2 Flash (not Write Protected)
            2&3 CMOS (512K)

      
## BOM (V0.90)      
Qty|Reference(s)|Value
--- | ----------- | -----
33|C2, C3, C4, C5, C6, C8, C9, C10, C11, C12, C13, C14, C15, C16, C17, C18, C19, C20, C21, C22, C23, C24, C30, C31, C32, C33, C34, C35, C36, C37, C38, C39, C40|0.1u
4|C25, C26, C27, C28|10u Electrolytic
1|C29|22u Electrolytic
1|C46|47uF Electrolytic
8|D2, D5, D7, D8, D9, D10, D11, D12|LED
1|D4|LED
1|D6|1N4148
1|J1|Pin Header 02x08
1|J2|Pin Header 01x03
1|J3|Pin Header 01x03
1|J4|Pin Header 01x02
1|J7|Pin Header 02x09
1|J8|Pin Header 02x09
1|J11|Pin Header 02x20
2|J13, J14|Pin Header 01x03
1|JP1|Pin Header  01x02
1|JP4|Pin Header 02x04
3|P1, P2, P3|Pin Header 02x25
3|R1, R2, R3|10K
3|R4, R6, R7|1K
1|R5|10
1|R9|1K
3|RN1, RN4, RN5|4700  8 res network
1|RN2|10K  8 res network
1|RN3|470 8 res network
1|RN6|470 4 res network 
1|SW1|Switch:SW_Push
1|U1|74LS04
1|U2|74LS32
2|U3, U19|74ALS373
1|U4|74LS07
1|U5|8259
6|U6, U8, U10, U14, U17, U31|74LS244
1|U7|74LS240
1|U9|OSC 2x rated CPU freq (10-20mhz, should be an even number)
1|U11|74LS245
1|U12|80C188
1|U13|DS1233
2|U15, U25|GAL22V10
1|U16|74LS08
1|U18|OSC 1.8432
1|U20|TL16C550CFN
1|U21|74LS74
1|U22|74LS688
1|U23|74LS00
1|U24|74LS259
1|U26|29F040
1|U27|PCF8584
1|U28|PCF CLOCK
1|U33|74LS374


        