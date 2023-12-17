This board provides an Orange Pi Zero 2W (OPi)running Linux which can be used to self host the duodyne system removing the need for an external PC or laptop to build RomWBW and/or control the system.

Assuming you are using Linux on the OPi, type the following command at the bash prompt to discontinue getty on ttyS0 (the serial comm port)

	sudo systemctl stop serial-getty@ttyS0.service

Then run minicom from the bash prompt

	sudo minicom -D /dev/ttyS0

change the baud rate to 38400

Then from the RomWBW console, switch to the second serial port at 38400 baud:

	I 1 38400

Now OPi will act as the console for duodyne RomWBW


