
## About

DACTONE is a CP/M-80 program running under RomWBW that is used to send
a sine wave of a specified frequency to the digital-to-analog
converter
[DAC0800](https://www.ti.com/lit/ds/symlink/dac0800.pdf?ts=1715491182024&ref_url=https%253A%252F%252Fwww.ti.com%252Fproduct%252FDAC0800)
on the Duodyne Voice board. 

This image shows the output of the DAC from the command `dactone 440`
when disconnected from the LM714 op amp and its resistors. The DAC
outputs are connected to the positive and negative supplies using 5K
registors as shown on the first page of the linked datasheet. 

![DAC output](img/DACOUTPUT.png)

## Usage

    usage: dactone [-v] [-s] frequency
         -v         Show verbose output.
         -s         Send samples (four seconds) to SIO0 Channel A instead of the DAC.

         frequency  The frequency of the tone to generate.

## Serial Debug Mode

Using the `-s` option tells DACTONE to send the audio samples to port
A of the SIO on the Duodyne Zilog peripherals board *instead* of to
the DAC. About four seconds of samples are sent. The serial port is
configured by DACTONE for 115200 baud, N81.

A WAV file header is sent so the resulting samples can be played on a
PC.

### Serial capture and playback on the Mac

Capturing the samples under MacOS is a two step process. First, before
running DACTONE on the Duodyne system, you have to `cat` the serial
adapter device that is connected to SIO PORT A to a file:

    cat /dev/cu.usbserial-AC013VEM > test.wav

Then, in a separate terminal, set the USB serial adapter baud rate:

    stty -f /dev/cu.usbserial-AC013VEM 115200

The `stty` command has do be done while the `cat` command above is
running.

Once DACTONE playback is done, stop the `cat` program with Control-C,
then use `afplay` to play the received tone:

    afplay test.wav

### Serial capture and playback on Linux

## Technical Notes

The program uses Channel 3 of the second CTC chip to generate an
approximately 8 kHz interrupt. The CTC runs at 7,372,800 Hz and is
programmed to use a divide-by-16 prescalar. The time constant is
programmed with 58d, giving

    7,372,800 / 16 / 58 = 7944 Hz

The interrupt handler is configued to use slot 11 of the RomWBW
interrupt table.

The sample data is generated from a 1024-entry sine wave table. A
phase incrementer loop is used to generate the required samples for
the input frequency given an 8 kHz sample rate. These samples are
placed in a buffer for use by the interrupt handler before the handler
starts. The interrupt handler then sends samples to the DAC from a
single circular buffer. This continues until either the user presses a
key or about four seconds have elapsed in serial debug mode.

The system tick timer is disabled during playback to the DAC and
restored when done.

## Building

The program is written in C and Z80 assembly using the
[Z88DK](https://z88dk.org/site/) development kit. Assuming you have
z88dk installed and have configured the environment (see
`set_environment.sh`), you can just run `make` to build the code.
There is a pre-compiled binary available.

## License

Copyright 2024 Rob Gowin

All files here are licensed using GPL version 2.0 or later. See
[COPYING](COPYING.md).
