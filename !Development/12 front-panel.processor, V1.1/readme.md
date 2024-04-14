The front-panel board connects to the Z80 processor to allow local access to configuration status input and display.  Also supports TTL serial to USB connection, an SSD1306 OLED display, and an I2C to SD card.  Several Z80 processor parameters can be set along with a reset button.

The I2C to SD card uses an ATtiny microcontroller which requires programming to work.  It is modeled after the I2C to SD card project at Technoblogy (http://www.technoblogy.com/show?3XEP)

Firmware for the card can be built and programed from the Arduino project located in the ATTINY_SD_FIRMWARE folder in this repo


You can program your ATtiny using the Arduino IDE for Linux 1.8.13 available here: https://www.arduino.cc/en/software/OldSoftwareReleases

with the megaTinyCore available here: https://wolles-elektronikkiste.de/en/using-megatinycore#usb2ttl_adaper_as_updi

I used a 3.3V TTL serial to USB cable direct to the UPDI connector on the front-panel and it worked fine. Following the instructions, I was able to successfully program the ATtiny1614 in-circuit. Alternatively, you can use pymcuprog on Linux.  Just follow the instructions here:https://pypi.org/project/pymcuprog/

For example, I was able to "ping" the ATtiny1614 and get a verbose status using: pymcuprog ping -d attiny1614 -t uart -u /dev/ttyUSB0 -v debug



Once programmed the ATTINY will respond to the I2C address 0x25.   This address can be updated in the code by changing the line "const int MyAddress = 0x25;"


The communication flow to the SD-I2C controller is very simple.  There are only 4 commands (I)nfo, (S)et block, (R)ead, (W)rite.  The SD-I2C controller expects a FAT formatted SD card with an raw HDD image file in the root directory called "IMAGE.IMG".   Cubix, DOS/65, or RomWBW image files should work without modification.


Info Command:

   Send one I2C data frame containing a single bytes:  'I'   (This tells the controller to put the SD information in the buffer)
   Send one I2C data frame containing a single bytes:  'R'   (This tells the controller that the host system wants to read the buffer)
   Read one I2C data frame -- should return 6 bytes:  'S' 'D' Byte1 Byte2 Byte3 Byte4  (the 4 bytes is one Double word containing the length in bytes of the image file- Big Endian)
   
   
   
Set Block Command:

   Send one I2C data frame containing 5 bytes:  'S' Byte1 Byte2 Byte3 Byte4  (the 4 bytes is one Double word containing the LBA block number that you wish to access in the image file- Big Endian)  
   
   
   
Read Command:

   Send one I2C data frame containing a single byte:  'R'   (This tells the controller that the host system wants to read the buffer)
   Read one I2C data frame -- should return 512 bytes 

   

Write Command:

   Send one I2C data frame containing  513 bytes:  'W' (512 bytes of sector data)  

