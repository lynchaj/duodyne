duodyne initial build and test findings

* 4-slot backplane power LED much too bright
* 4-slot backplane power connectors too close to processor slot


* ROMRAM memory configuration jumpers flipped on PCB (fixed 1.1)
* ROMRAM order the I2C jumper blocks the same as the I2C sockets -- would be even better if they could be made proximate (fixed 1.1)
* ROMRAM add bypass capacitors to the 24LC512 I2C memories (fixed 1.1)
* ROMRAM replace labels on J32-J35 with better descriptions (fixed 1.1)
* ROMRAM label DS1210s to match SRAMs (fixed 1.1)
* ROMRAM new layout for more logical structure (fixed 1.1)
* ROMRAM use 30mm speaker instead of tiny piezo (fixed 1.1)
* ROMRAM C15 reversed on back silkscreen (fixed 1.1)
* ROMRAM use TO-92 hand solder footprints (fixed 1.1)


* Z80 processor LEDs way too bright
* Z80 processor replace reset circuit with DS1233 (EconoReset) (fixed 1.1)
* Z80 processor remove spare debugging sockets, GAL, & portal holes (fixed 1.1)
* Z80 processor convert 74HCT244 symbols to 74LS244 (fixed 1.1)
* Z80 processor RUN and HALT labels reversed (fixed 1.1)
* Z80 processor change D0-D3 to D4-D7 on U22 74LS670 (fixed 1.1)
* Z80 processor R8 & R9 missing value labels (fixed 1.1)
* Z80 processor U6 reversed on back silkscreen (fixed 1.1)
* Z80 processor update to CPU-MAPPER-V3 GAL for I2C read and write fixes (fixed 1.1)
* Z80 processor requires updated U25 CPU-MAPPER GAL for I2C to function *and* U25 pins 13 and 14 connected (fixed 1.1)
* Z80 processor DMA D5 and D6 swapped in KiCAD symbol library (fixed 1.1)
* Z80 processor J3 and J4 should be labelled 1-8 not 0-7 (fixed 1.1)
* Z80 processor DMA CS GAL22V10 needs inverter on ~CPU-BUSACK for DMA-CS1 and DMA-CS2 (fixed 1.1)
* Z80 processor interrupts on IM2 reversed relative to CPU (fixed 1.1)
* Z80 processor add optional/experimental system tick timer (fixed 1.1)
* Z80 processor use TO-92 hand solder footprints (fixed 1.1)
* Z80 processor update U36 GAL to DMA-CS-V4 configuration (fixed 1.1)
* Z80 processor add jumper U36-13 to RN6-8 (fixed 1.1)


* Zilog IO U2 and U4 are really 74LS244s even though the front silkscreen says 74LS241s (fixed 1.1)
* Zilog IO Update U1 GAL to ZP-DATA-DIR-V2 configuration (fixed 1.1)
* Zilog IO Disconnect D6 from D5 on 1PIO and 2PIO (fixed 1.1)
* Zilog IO Mark default jumper locations on PCB front silkscreen (fixed 1.1)
* Zilog IO Consolidate multi small jumpers into a larger jumper group (fixed 1.1)


* Multi IO Replace 1K ohm isolated resistor networks DIP-14 with regular resistors due to obsolescence (fixed 1.1)
* Multi IO Swap Serial port A and Serial port B on TTL serial connector (A on the evens, B on the odds) (fixed 1.1)
* Multi IO add 3-pin jumper to select "reserved 2" on either 2x5 IDC PS/2 keyboard & mouse connector either pin 2 or 10 (fixed 1.1)
* Multi IO add CH376S-EVT board as alternate to CH376S and associated parts install (fixed 1.1)


* EPM7128S dev board Replace 470 ohm isolated resistor networks DIP-14 with same in DIP-16 due to obsolescence
* EPM7128S add 2 screw terminal for 9VDC
* EPM7128S add VCC and GND lugs for logic probe


* SAB80535 add VCC and GND lugs for logic probe (fixed 1.1)
* SAB80535 enlarge small labels for readability (fixed 1.1)
* SAB80535 Cut VCC trace between U10-pin32 and C12-pin1 so VBB is connected to GND via C12 not VCC (fixed 1.1)
* SAB80535 Rotate U5 180 degrees and U11 & U12 90 degrees so labels are consistent with board
* SAB80535 Replace R6 with 10K ohm resistor because LED is way too bright (fixed 1.1)
* SAB80535 Label J2 (9VDC screw terminal) connections 9VDC & GND (fixed 1.1)
* SAB80535 Add jumper select for pin 37 (VCC for SAB80C535 and 0.1uF to GND for SAB80535) (fixed 1.1)
* SAB80535 Replace SIL-6 TTL serial connectors with right angle 2x6 IDC and flip orientation (fixed 1.1)
* SAB80535 Replace 22.1184 MHz crystal with 11.0592 MHz crystal (fixed 1.1)
* SAB80535 Change LM7805 voltage regulator from vertical to horizontal with room for heatsink (fixed 1.1)
* SAB80535 FE/SS label is reversed; SS is 1-2 and FE is 3-4 (fixed 1.1)
* SAB80535 Label pins 1 and 2 on LCD interface pin socket (fixed 1.1)
* SAB80535 Replace 14-pin LCD interface with 16-pin version for LED backlight (fixed 1.1)
* SAB80535 Add LEDs for key signals (ROM /CS, RAM /CS, PPI0 & PPI1 /CS, LCD CS, LATCH /CS, /OE, /WR, T0, and T1) (fixed 1.1)
* SAB80535 Replace Flash ROM PLCC-32 with DIP-32 ZIF socket (fixed 1.1)
* SAB80535 Change LCD Vo Adjust circuit to use 10K Potentiometer (fixed 1.1)


* SelfHost exchange J3-pin1 with J3-pin4 (Tx and Rx reversed) (fixed 1.1)
* SelfHost Add BusMonitor function (fixed 1.1)


* Disk IO Change U26 (74AHC02) supply from VCC (5V) to VDD (3.3V) (fixed 1.1)
* Disk IO Remove R36 (22K) and R44 (22K); Replace R35 (10K) and R43 (10K) with wires (fixed 1.1)
* Disk IO Connect U28 & U29 D0-D7 to U14 bD0-bD7 (fixed 1.1)
* Disk IO Move SD socket up to top of board (fixed 1.1)
* Disk IO Remove U16 74LS273 as not used (fixed 1.1)
* Disk IO Add comment referring back to MT011 source document (fixed 1.1)


* front-panel Add mounting holes for OLED and microSD module (fixed 1.1)
* front-panel Reverse orientation of switches SW10-SW13 (fixed 1.1)
* front-panel Add 0.1uF bypass capacitor near U1 (fixed 1.1)

* All boards label the GAL sockets with their GAL names (like CPU-MAPPER) in addition to the Uxx designation
* All boards Ensure crystal oscillators are free of other traces interfering with connections
(RAMROM, Multi IO, Voice IO, Media IO, VDCENET, SAB80535)

