DAISY256 is an experimental project board to determine if the CTS256A-AL2 can be replaced with TMS7xxx microcontrollers in microprocessor mode using an external boot ROM.

It is not intended to be a general purpose text to speech board.

The DAISY256 is inspired by:

https://github.com/mecparts/Talker
https://github.com/GmEsoft/CTS256A-AL2
https://github.com/jim11662418/CTS256-SP0256
https://www.smbaker.com/cts256a-al2-text-to-speech-board

Important Setup Notes:
* default serial parameters are 9600, 8 data bits, No Parity, 1 stop bit, RTS/CTS handshaking
* mecparts Talker exception ROM must be installed in Expansion ROM socket
* 6116 SRAM (200-300 ns) must be installed in Buffer socket

Fixes:
* check Plot -> Component Labels for Gerbers
* add power switch
* add power LED
* add logic probe VCC and GND loops
* convert power to LM7805 and reverse voltage protection diode

20 Apr 2024: Built DAISY256 prototype, confirmed control works per mecparts Talker. Mode jumper installed (full expansion mode, not microprocessor mode)

20 Apr 2024: installed Boot EPROM (2732 contains CTS256 recovered firmware), removed mode jumper.  Confirmed CTS256 is able to boot from external EPROM.  Works just like internal firmware.

20 Apr 2024: replaced CTS256 with TMS7001.  Works fine, says "OK" on reset.  Accepts input from serial port.  Acts just like a CTS256.

