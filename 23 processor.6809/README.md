# Duodyne 6809 Card
6809 processor board (hardware and software) for the Duodyne computer system.

The board contains:
* 6809 CPU
* 8K Rom (the first 8K of the EPROM)
* Support for a Standard Duodyne Front Panel
* 16c550 UART
* PCF8584 I2C bus controller
* Banked MMU with 4 selectable memory windows

Memory Map:
0000 - 3FFF BANK 0
4000 - 7FFF BANK 1
8000 - BFFF BANK 2
C000 - FFFF BANK 3

IO is mapped from 00:DF00 - 00:DFFF, and must be visible in the memory map for the system to operate properly.
The on-board ROM is mapped from 00:E000-00:FFFF.

On board IO Address Port $50-$5F
$50	     PAGER BANK 0(WR)
$51	     PAGER BANK 1(WR)
$52	     PAGER BANK 2(WR)
$53	     PAGER BANK 3(WR)
$54          Front Panel (RW)
$55     
$56-$57 I2C(RW)
$58-$5F UART (RW)

One "Toggle" address is jumper selectable and visible in the OP port range to switch between CPUs in the Duodyne system.

Rom Images are in this repo.   Cubix operating system sources and images can be found here: https://github.com/danwerner21/CUBIX09

# Bugs

V1.00
The following patches are required for the v1.00 6809 board prior to running:
* Pin 33 of U2 (the CPU) must be tied high. Connect a 1K resistor between pin 33 and Pin 7 (+5V) of the CPU
* The traces to Pins 7 and 8 on U9 (Address Decoder) need to be cut on the top of the board
* Pin 7 of U9 needs to be connected to pin 4 of U19
* Pin 8 of U9 needs to be connected to pin 7 of U19
* Connect Pin 19 and 20 of U9 to Pin 3 of U2
* On top of board cut the trace between pin 2 & 6 and also between 8 & 12 of U21 or alternately lift pins 6 & 8.
* Connect pin 1 J2 (/RES_OUT) to pin 20 U3 IO_DECODE GAL
* Update U3 IO-DECODE GAL. 

V1.1
* FIRQ needs a pull up.  Connect U28 Pin 4 to RN1 Pin 2
* Activation Flip flop needs reset by RES_OUT rather then RES_IN.   Easiest patch is to connect RES_IN to RES_OUT-  J4 pin 1 to U15 pin 2 (once done DO NOT JUMPER J4)
* cut connection between J4 pin 1 and P1 pin 20


# JUMPER SETTINGS
## General
        JP1 - Export Clock to Bus
                Closed for Only CPU
                Open For Secondary CPU

        JP3 - Export Reset to Bus
                Closed for Only CPU
                Open For Secondary CPU

        JP4 - Pull up for Bus Signals
                Closed for Only CPU/Pull up
                Open For Secondary CPU/No Pull up

        J11 - 
        J11 NOTE: 
            PINS 5, 7, 9, 11, 13, 15, 17, 19 ARE FOR LED STATUS
            FOR ROMWBW FRONT PANEL INDICATOR
            
            PINS 6, 8, 10, 12, 14, 16, 18, 20 ARE FOR SWITCH
            INPUTS FOR ROMWBW FRONT PANEL

            PINS 21, 23 ARE FOR I2C CONNECTION (SDA & SCL)

            PINS 25, 27, 29, 31, 33, AND 35
            ARE FOR TTL SERIAL CONNECTOR TO UART

            PINS 29, 37 ARE FOR SERIAL VCC POWER ENABLE
            PINS 22, 24 ARE FOR EXTERNAL RESET SWITCH

            
            
        J1  - Toggle IO Address Selection

        J2  - Reset Control
                1&2 Only CPU
                2&3 Secondary CPU

        J3  - Enable
                1&2 Only CPU
                2&3 Secondary CPU

        J4 - Reset
                OPEN Only CPU
                CLOSED Secondary CPU


        J5  - CPU NMI Selection
        J6  - CPU IRQ Selection
        J7  - I2C IRQ Selection
        J8  - UART IRQ Selection
        J9  - CPU FIRQ Selection

        J10 - CPU READY
                1&2 Disable CPU Wait
                2&3 Enable CPU Wait           
        
        
        


# BOM

Qty|Reference(s)|Value
--- | --- | ---
33|C2, C3, C4, C5, C6, C8, C9, C10, C11, C12, C13, C14, C15, C16, C17, C18, C19, C20, C21, C22, C23, C24, C30, C31, C32, C33, C34, C35, C36, C37, C38, C39, C40|0.1u
4|C25, C26, C27, C28|10u
1|C29|22u
1|C46|47uF
4|D2, D3, D7, D9|LED
1|D4|6809
1|D6|1N4148
1|J1|IO Address Select -  male Pin Header 2x8
1|J2|6809 RESET -  male Pin Header 1x3 right angle
1|J3|6809 ONLY -  male Pin Header 1x3 right angle
1|J4|RES SEL -  male Pin Header 1x2 right angle
1|J5|NMI Selection -  male Pin Header 2x9
1|J6|IRQ Selection -  male Pin Header 2x9
1|J7|I2C IRQ Selection -  male Pin Header 2x9
1|J8|UART IRQ Selection -  male Pin Header 2x9
1|J9|FIRQ Selection -  male Pin Header 2x9
1|J10|MRDY -  male Pin Header 1x3
1|J11|FPANEL -  male Pin Header 2x20 right angle
1|JP1|GENERATE CLOCK -  male Pin Header 1x2
1|JP3|GENERATE RESET -  male Pin Header 1x2
1|JP4|BUS CPU -  male Pin Header 2x4
1|JP10|IO PORT ADDR -  male Pin Header 2x4
3|P1, P2, P3|CONN_02X25 -  male Pin Header 2x25 right angle
2|R1, R6|1K
2|R2, R3|10K
4|R4, R5, R12, R13|470
1|R7|10
1|R8|470ohm
3|RN1, RN4, RN5|4700 network 9 pin
1|RN2|10Kohm network 9 pin
1|RN3|470 network 9 pin
1|RN8|10K network 9 pin
1|SW1|RESET- Tact Button, right angle
1|U1|74LS04
1|U2|GAL16V8
1|U3|GAL22V10
1|U4|74LS07
1|U5|27C010
6|U6, U8, U10, U14, U17, U31|74LS244
1|U7|74LS14
1|U9|GAL22V10
1|U11|74LS245
2|U12, U22|74LS688
1|U13|CPU CLOCK- TTL Osc 
1|U15|DS1233
1|U16|74LS08
1|U18|UART CLOCK - TTL Osc
1|U19|74LS157
1|U20|TL16C550CFN
1|U21|74LS74
2|U24, U29|74LS670
1|U27|PCF8584
1|U28|MC6809 (pref 68B09)
1|U33|74HCT374

U18 UART CLOCK = 1.8432mhz
U13 CPU CLOCK : 6809 Uses a 4xclock so use 4Mhz for 1mhz CPU, 8Mhz for 2Mhz CPU, etc.
U33 Front panel LED driver should be 74HCT374.
U5 Can be 27C010, Intel P28F001, SST29EE010 

# SOFTWARE
Three Rom images are provided
* Scream - simple scream test, RAM-less
* Monitor - basic monitor
* mon09 - Full featured monitor

The .HEX file can be used to program U5 EPROM/Flash device.

### SCREAM
Serial setting 38400N1

### MONITOR

Monitor is a simple machine language monitor that will allow you to view and manipulate the 6809 operating environment.

Serial setting 9600N1

Monitor Supports the following Commands:

```
	* D -  XXXX YYYY - Dump memory from XXXX to YYYY
        * L - Load a S19 file into RAM
       	* M XXXX YY  - update the ram at XXXX with value YY
        * G XXXX - Execute program at XXXX
        * P - PRINT CONTENTS OF STACK
```

### MON09

MON09 is an interactive software debugger and machine language monitor for the motorola 6809 microprocessor.  It contains display/alter memory/register facilities, as well as a full 6809 disassembler.  Mon09 is a product of Dunfield Development Systems http://www.dunfield.com, 1985-2007 Dave Dunfield.
   
```
       Operand format

        Anywhere that MON09 expects an 8 bit value, you may use:

            Two HEX digits                              Eg: 1F
            A QUOTE followed by an ASCII character      Eg: 'a

        Anywhere that MON09 expects a 16 bit value, you may use:

            Four HEX digits                             Eg: 09AB
            ASCII characters preceeded by quotes        Eg: 'a'b
            X, Y, U, P, or S for current CPU register   EG: X

        Monitor Commands

             The following commands are implemented in the monitor.

               CR <register> <value>

                  Changes  6809  registers  values.  Register  is  a  single
                  character, which may be as follows:

                  A   - Set A accumulator (8 bit value).
                  B   - Set B accumulator (8 bit value).
                  C   - Set condition code register (8 bit value).
                  D   - Set direct page register (8 bit value).
                  X   - Set X register (16 bit value).
                  Y   - Set Y register (16 bit value).
                  U   - Set user stack pointer (16 bit value).
                  S   - Set system stack pointer (16 bit value).
                  P   - Set program counter (16 bit value).
                  sp  - (SPACE) Set D accumulator (16 bit value).

               CV <vector> <address>

                     Changes the interrupt  vector  handler  addresses.  The
                  vectors are as follows:

                  1 or 'S' - SWI  (Software Interrupt) vector
                  2        - SWI2 (Software Interrupt 2) vector
                  3        - SWI3 (Software Interrupt 3) vector
                  4 or 'I' - IRQ  (Interrupt Request) vector
                  5 or 'F' - FIRQ (Fast Interrupt Request) vector

               DI <start>,<end>

                  Disassembles memory,  starting at  indicated  address.  If
                  SPACE  is  entered  for  <end>  address,   assumes   FFFF.
                  Disassembler output contains address, opcodes bytes, ASCII
                  equivalent of  opcode  bytes,  instruction  neumonic,  and
                  operands to instruction.

               DM <start>,<end>

                  Displays memory, in HEX/ASCII dump format, starting at the
                  indicated  address.  If  a  SPACE  is  entered  for  <end>
                  address, assumes FFFF.

               DR

                  Displays the values of the 6809 registers.

               DV

                  Display the current interrupt vector address assignments.

               E <address>

                  Edit memory,  Address and contents are displayed,  Enter
                  two hex digits to change value, or a single quote followed
                  by a character. Entering SPACE skips to the next location,
                  BACKSPACE  backups  to  the  previous  location.  CARRIAGE
                  RETURN terminates the edit command.

               FM <start>,<end> <value>

                  Fill's memory from <start> to <end> with the byte <value>.

               G <address>

                  Begins execution at the indicated address.  If a SPACE  is
                  entered instead of an address,  begins  execution  at  the
                  address in the saved 6809 program counter.

               L

                  Downloads data which may be in either MOTOROLA or INTEL hex format.

               MM <start>,<end> <destination>

                  Move memory  from  <start>  to  <end>,  placeing  it  at
                  <destination>.

               MT <start>,<end>

                  Performs a memory test on memory from  <start>  to  <end>.
                  Pass number is displayed,  First two digits indicate total
                  number completed tests,  last two digits indicate  current
                  pass  (value)  within the  test.  Each  value  is  written
                  sequentially to memory,  insuring that previous  data  has
                  not changed before the new value is written.  To exit  the
                  test, press the escape key.

               RR <address>

                  This command loops,  performing a read  of  the  specified
                  address until it is terminated by the escape key.

               RW <address> <value>

                  This  command  loops,  writing  the  given  value  to  the
                  specified address until it is  terminated  by  the  escape
                  key.

               W <address> <value>

                  Performs  a  single  write  of  the  given  value  to  the
                  specified address in memory.

               XR <address>

                  As 'RR' command, except that a 16 bit value is read.

               XW <address> <word value>

                  As 'RW' command, except that a 16 bit value is written.

               + <value>+<value>

                  Performs 16 bit addition of the values,  and displays  the
                  result.

               - <value>-<Value>

                  Performs 16 bit subtraction of the  values,  and  displays
                  the result.

               ?

                  Displays a short help summary of the commands.

```           
       


