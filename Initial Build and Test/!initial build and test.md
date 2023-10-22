duodyne initial build and test findings

4-slot backplane power LED much too bright
4-slot backplane power connectors too close to processor slot

ROMRAM memory configuration jumpers flipped on PCB (fixed 1.1)
ROMRAM order the I2C jumper blocks the same as the I2C sockets -- would be even better if they could be made proximate (fixed 1.1)
ROMRAM add bypass capacitors to the 24LC512 I2C memories (fixed 1.1)
ROMRAM replace labels on J32-J35 with better descriptions (fixed 1.1)
ROMRAM label DS1210s to match SRAMs (fixed 1.1)
ROMRAM new layout for more logical structure (fixed 1.1)
ROMRAM use 30mm speaker instead of tiny piezo (fixed 1.1)
ROMRAM C15 reversed on back silkscreen (fixed 1.1)
ROMRAM use TO-92 hand solder footprints (fixed 1.1)

Z80 processor LEDs way too bright
Z80 processor replace reset circuit with DS1233 (EconoReset) (fixed 1.1)
Z80 processor remove spare debugging sockets, GAL, & portal holes (fixed 1.1)
Z80 processor convert 74HCT244 symbols to 74LS244 (fixed 1.1)
Z80 processor RUN and HALT labels reversed (fixed 1.1)
Z80 processor change D0-D3 to D4-D7 on U22 74LS670 (fixed 1.1)
Z80 processor R8 & R9 missing value labels (fixed 1.1)
Z80 processor U6 reversed on back silkscreen (fixed 1.1)
Z80 processor update to CPU-MAPPER-V3 GAL for I2C read and write fixes (fixed 1.1)
Z80 processor requires updated U25 CPU-MAPPER GAL for I2C to function *and* U25 pins 13 and 14 connected (fixed 1.1)
Z80 processor DMA D5 and D6 swapped in KiCAD symbol library (fixed 1.1)
Z80 processor J3 and J4 should be labelled 1-8 not 0-7 (fixed 1.1)
Z80 processor DMA CS GAL22V10 needs inverter on ~CPU-BUSACK for DMA-CS1 and DMA-CS2 (fixed 1.1)
Z80 processor interrupts on IM2 reversed relative to CPU (fixed 1.1)
Z80 processor add optional/experimental system tick timer (fixed 1.1)
Z80 processor use TO-92 hand solder footprints (fixed 1.1)
Z80 processor update U36 GAL to DMA-CS-V4 configuration (fixed 1.1)
Z80 processor add jumper U36-13 to RN6-8 (fixed 1.1)

Zilog IO U2 and U4 are really 74LS244s even though the front silkscreen says 74LS241s (fixed 1.1)
Zilog IO Update U1 GAL to ZP-DATA-DIR-V2 configuration (fixed 1.1)
Zilog IO Disconnect D6 from D5 on 1PIO and 2PIO
Zilog IO Mark default jumper locations on PCB front silkscreen
Zilog IO Consolidate multi small jumpers into a larger jumper group

Multi IO Replace 1K ohm isolated resistor networks DIP-14 with same in DIP-16 due to obsolescence
Multi IO Swap Serial port A and Serial port B on TTL serial connector (A on the evens, B on the odds)
Multi IO add 3-pin jumper to select "reserved 2" on either 2x5 IDC PS/2 keyboard & mouse connector either pin 2 or 10

EPM7128S dev board Replace 470 ohm isolated resistor networks DIP-14 with same in DIP-16 due to obsolescence

All boards label the GAL sockets with their GAL names (like CPU-MAPPER) in addition to the Uxx designation
