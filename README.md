# duodyne
* duodyne is a hobbyist retrocomputer system comprised of modules on a system bus.  It is specifically designed to run RomWBW, however, provides support for multiple processor architectures and has a flexible and expandable system bus.

* The system bus is designed to support multiple vintage or retro computer processor architectures such as those from Intel, Zilog, Motorola, Mostek, etc.  The Z80 is the primary CPU used to develop the initial round of peripherals.

* Duodyne borrows heavily from previous computer systems.  The form factor is similar to S-100 and VME.  The bus is electrically is derived from ECB with many extensions to support other processor architectures and improved power distribution.  There are multiple pins for 5V and ground.  +12V and -12V are supported.  3.3V and other values can be derived on board using voltage regulators.

* The plan for the system is to have balance between functionality and complexity.  A single function per board has good distribution and easy expansion but leads to many boards and a large backplane which can lead to electrical and signal distribution issues.  However, full integration into a single board computer reduces complexity somewhat but can make expansion difficult.  

* Duoodyne's bus based approach with a generous board form factor allows for a blend of integration and distribution of two or more functions per board leading to a smaller overall backplane yet retaining flexibility for easy expansion.

* The duodyne core system is defined as an 4-slot or 8-slot backplane, a Z80 or other processor (currently, Z80, 65C816, and TMS9995 are supported), and a ROMRAM board.  The ROMRAM memory board assumes an 8-bit data bus so CPU's with larger data busses may require dedicated memory boards.  The Z80 processor includes a debugging serial port for console access.  The boot ROM is included on the ROMRAM board.

