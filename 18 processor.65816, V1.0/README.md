# 65C816 CPU Card
68C816 processor board (hardware and software) for the Duodyne computer system.

The board contains:
* 65C816 CPU (up to 4Mhz)
* 8K Rom (the first 8K of the EPROM)
* Support for a Standard Duodyne Front Panel
* 16c550 UART
* PCF8584 I2C bus controller


IO is mapped from $00DF00 - $00DF00
The on-board ROM is mapped from 00E000-00FFFF.

On board IO Address Port $50-$5F
$50	     Front Panel (RW)
$51	     Option Latch (bit 0, enable interrups, bits 1-7 exposed on front panel connector)
$52	     
$53	     Reset
$54          
$55      
$56-$57 I2C(RW)
$58-$5F UART (RW)

Rom Images are in this repo.   DOS/65 operating system sources and images can be found here: https://github.com/danwerner21/6x0x-DOS65


# Jumper Settings
        JP1  - Allow RES_IN to generate board Reset

        JP2   - I2C IRQ Enable

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

V1.2
* Activation Flip flop needs reset by RES_OUT rather then RES_IN.   Easiest patch is to connect RES_IN to RES_OUT-  JP1 pin 1 to U15 pin 2 (once done DO NOT JUMPER JP1)
* cut connection between JP1 pin 1 and P1 pin 20

# BOM

Qty|Reference(s)|Value
--- | ----------- | -----
34|C1, C2, C3, C4, C5, C6, C8, C9, C10, C11, C12, C13, C14, C15, C16, C17, C18, C19, C20, C21, C22, C23, C24, C30, C31, C32, C33, C34, C35, C36, C37, C38, C39, C40|0.1u
4|C25, C26, C27, C28|10u
1|C29|22u
1|C46|47uF
1|D1|BI COLOR LED
7|D2, D3,D4, D5, D7, D8, D9|LED
1|D6|1N4148
1|IC1|65816CPU-DIP
1|J1|Pin Header Male 02x08
1|J2|Pin Header Male  01x03
1|J3|Pin Header Male 01x03
1|J11|"Pin Header Male 02x20 Right Angle| Shrouded"
1|JP1|Pin Header Male 01x02
1|JP2|Pin Header Male 01x02
1|JP3|Pin Header Male 01x02
1|JP4|Pin Header Male 01x02
1|JP7|Pin Header Male 02x04
1|JP10|Pin Header Male 02x04
1|JP13|Pin Header Male 01x02
3|P1, P2, P3|"Pin Header Male 02x25 Right Angle| Shrouded"
7|R1, R4, R5, R6, R11, R12, R13|470 ohm
2|R2, R3|10K
1|R7|10 ohm
1|R8|470 ohm
1|R9|3K
1|R10|1K
1|R14|100 ohm
1|R15|1K
3|RN1, RN4, RN5|4700 Net 9 pin
1|RN2|1K Net 9 pin
1|RN8|10K  Net 9 pin
1|SW1|Switch:SW_Push
6|U1, U5, U6, U11, U23, U31|74LS244
1|U2|UART CLOCK 1.8432 Mhz Osc
1|U3|74LS14
1|U4|74LS07
1|U7|74LS04
1|U8|74LS245
1|U9|GAL22V10
1|U10|GAL16V8
2|U12, U22|74LS688
1|U13|CPU CLOCK Osc Up to 4 Mhz
1|U14|TL16C550CFN 
1|U15|DS1233
1|U16|74LS08
1|U17|74LS00
1|U18|74HC245
1|U19|27C64
1|U20|GAL22V10
1|U21|74LS74
1|U24|74HC573
2|U25, U33|74LS374
1|U26|74LS32
1|U27|PCF8584
1|U28|PCF CLOCK Osc >2Mhz <8Mhz
