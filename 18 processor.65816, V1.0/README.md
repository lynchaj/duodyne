# 65C816 CPU Card
68C816 processor board (hardware and software) for the Duodyne computer system.

The board contains:
* 65C816 CPU (up to 4Mhz)
* 8K Rom (the first 8K of the EPROM)
* Support for a Standard Duodyne Front Panel
* 16c550 UART


IO is mapped from $00DF00 - $00DF00 for boards prior to V1.31 and is mapped at $xx0300-$xx03FF for 1.31 and later
The on-board ROM is mapped from 00E000-00FFFF.

On board IO Address Port $50-$5F
$50	     Front Panel (RW)
$51	     Option Latch (bit 0, enable interrups, bits 1-7 exposed on front panel connector)
$52	     
$53	     Reset
$54          
$55      
$56
$57 
$58-$5F UART (RW)

Rom Images are in this repo.   DOS/65 operating system sources and images can be found here: https://github.com/danwerner21/6x0x-DOS65
DOS/65 does not work on boards prior to V1.31

# Jumper Settings
        JP1  - Allow RES_IN to generate board Reset

        J2  - Reset Control
                1&2 Only CPU
                2&3 Secondary CPU
                
        J3  - CPU Control
                1&2 Only CPU
                2&3 Secondary CPU

        JP3 - Generate Clock
                OPEN Does not place CPU Clock on BUS
                CLOSED Places CPU Clock on BUS

        JP4 - Reset
                OPEN Does not Connect RES_OUT to BUS
                CLOSED Connect RES_OUT to BUS

        JP10  - IO ADDRESS Select
        JP13  - UART IRQ Enable
        


# Bugs

Note that the PCF8584 I2C bus controller has been removed from the design after V1.3 as it never worked reliably. The timing requirements of the chip are just too different from what the 65816 is capible of delivering and the work arounds are honestly more trouble than the functionality is worth (IMHO).  

V1.2
* Activation Flip flop needs reset by RES_OUT rather then RES_IN.   Easiest patch is to connect RES_IN to RES_OUT-  JP1 pin 1 to U15 pin 2 (once done DO NOT JUMPER JP1)
* cut connection between JP1 pin 1 and P1 pin 20
* Do not populate U27, U28, R2, R3, and JP2

V1.3
* R15 incorrectly ties M1 to GND.  Do not populate the GND side of this resistor, but instead solder that side to the nearest VCC pin.
* Do not populate U27, U28, R2, R3, and JP2
* U26 lift pin 3 and short pins 2 & 3 -- then use V1.31 GALs and ROMS

# BOM (V1.31)

Qty|Reference(s)|Value
--- | ----------- | -----
1|34|C1, C2, C3, C4, C5, C6, C8, C9, C10, C11, C12, C13, C14, C15, C16, C17, C18, C19, C20, C21, C22, C23, C24, C30, C31, C32, C33, C34, C35, C36, C37, C38, C39, C40|0.1uF
2|4|C25, C26, C27, C28|10uF
3|1|C29|22uF
4|1|C46|47uF
5|1|D1|BI COLOR LED
6|6|D2, D3, D5, D7, D8, D9|LED
7|1|D4|6502
8|1|D6|1N4148
10|1|IC1|65816CPU-DIP
11|1|J1|Connector_Generic:Conn_02x08_Odd_Even
12|1|J2|Connector:Conn_01x03_Male
13|1|J3|Connector:Conn_01x03_Male
14|1|J11|Pin Header Male 02x20 Right Angle| Shrouded
15|1|JP1|Connector:Conn_01x02_Male
16|1|JP3|Jumper:Jumper_2_Open
17|1|JP4|Jumper:Jumper_2_Open
18|1|JP7|Connector_Generic:Conn_02x04_Odd_Even
19|1|JP10|Connector_Generic:Conn_02x04_Odd_Even
20|1|JP13|Jumper:Jumper_2_Open
21|3|P1, P2, P3|Pin Header Male 02x25 Right Angle| Shrouded
22|7|R1, R4, R5, R6, R11, R12, R13|470 ohm
23|1|R7|10 ohm
24|1|R8|470 ohm
25|1|R9|3K ohm
26|1|R10|1K ohm
27|1|R14|100 ohm
28|1|R15|1K ohm
29|3|RN1, RN4, RN5|4700 ohm bussed  9 pin
30|1|RN2|1K  ohm bussed  9 pin
31|1|RN8|10K  ohm bussed  9 pin
32|1|SW1|Switch:SW_Push
33|6|U1, U5, U6, U11, U23, U31|74LS244
34|1|U2|UART CLOCK
35|1|U3|74LS14
36|1|U4|74LS07
37|1|U7|74LS04
38|1|U8|74LS245
39|1|U9|GAL22V10
40|1|U10|GAL16V8
41|2|U12, U22|74LS688
42|1|U13|CPU CLOCK
43|1|U14|TL16C550CFN
44|1|U15|DS1233
45|1|U16|74LS08
46|1|U17|74LS00
47|1|U18|74HC245
48|1|U19|27C64
49|1|U20|GAL22V10
50|1|U21|74LS74
51|1|U24|74HC573
52|2|U25, U33|74LS374
53|1|U26|74LS32
