The front-panel board connects to the Z80 processor to allow local access to configuration status input and display.  Also supports TTL serial to USB connection, an SSD1306 OLED display, and an I2C to SD card.  Several Z80 processor parameters can be set along with a reset button.

The I2C to SD card uses an ATtiny microcontroller which requires programming to work.  It is modeled after the I2C to SD card project at Technoblogy

http://www.technoblogy.com/show?3XEP

Using this program

https://github.com/technoblogy/i2c-sd-card-module

You can program your ATtiny using the Arduino IDE for Linux 1.8.13 available here

https://www.arduino.cc/en/software/OldSoftwareReleases

with the megaTinyCore available here

https://wolles-elektronikkiste.de/en/using-megatinycore#usb2ttl_adaper_as_updi

I used a 3.3V TTL serial to USB cable direct to the UPDI connector on the front-panel and it worked fine

Following the instructions, I was able to successfully program the ATtiny1614 in-circuit

Alternatively, you can use pymcuprog on Linux.  Just follow the instructions

https://pypi.org/project/pymcuprog/

For example, I was able to "ping" the ATtiny1614 and get a verbose status using:

pymcuprog ping -d attiny1614 -t uart -u /dev/ttyUSB0 -v debug