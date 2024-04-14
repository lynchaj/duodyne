/* 
   Duodyne SD card I2C to SD
   Modifications by Dan Werner

   This work is based on:
   David Johnson-Davies - www.technoblogy.com - 7th July 2022
   I2C SC-Card Module - see http://www.technoblogy.com/show?1LJI
   ATtiny1614 @ 20MHz (internal clock; BOD disabled) 
   CC BY 4.0
   Licensed under a Creative Commons Attribution 4.0 International license: 
   http://creativecommons.org/licenses/by/4.0/
*/

/* 
    Arduino Board should be set to megaTinyCode ATtiny 3224/1624/1614/1604/824/814/804/424/414/404/214/204
    Chip ATTiny1614
    Programmer should be set to Serial-UPDI SLOW 57600
*/

/*
                                     ATTINY1614-SS
                                 --------------------
                                 |                  |
                            VCC  | 1             14 |   GND
                        (SD) CS  | 2             13 |   CLK (SD)
                              X  | 3             12 |   DO  (SD)
                              X  | 4             11 |   DI  (SD)
                              X  | 5             10 |   UPDI
          BI-COLOR  -----------  | 6              9 |   I2C_SCL
               LED  -----------  | 7              8 |   I2C_SDA
                                 |                  |
                                 --------------------

Commands:
   S=Set LBA Address    Format SBBBB    (B=address Byte)
   R=Read Sector (R followed by 512 bytes of read)
   W=Write Sector (W followed by 512 bytes of write)
*/

#include <SD.h>

File myFile;

#if DEBUG
File logFile;
#endif

volatile unsigned char buffer[512];

// LEDs **********************************************

const int LEDoff = 0;
const int LEDgreen = 1;
const int LEDred = 2;

void LightLED(int colour) {
  digitalWrite(5, colour & 1);
  digitalWrite(4, colour >> 1 & 1);
}

// I2C Interface **********************************************

volatile uint8_t lbaAddress[4];

union ulbaAddress_u {
  uint8_t bytes[4];
  uint32_t number;
} ulbaAddress;

const int MyAddress = 0x25;

// TWI setup **********************************************

void I2CSetup() {
  TWI0.CTRLA = 0;               // Default timings
  TWI0.SADDR = MyAddress << 1;  // Bottom bit is R/W bit
  // Enable address, data, and stop interrupts:
  TWI0.SCTRLA = TWI_APIEN_bm | TWI_DIEN_bm | TWI_PIEN_bm | TWI_ENABLE_bm;
}

// Functions to handle each of the cases **********************************************

volatile uint8_t command = 0;  // Currently active command
volatile int ch = 0, ptr = 0;  // Filename and size pointers
boolean checknack = false;     // Don't check Host NACK first time


boolean AddressHostRead() {
  ptr = 0;
  return true;
}

boolean AddressHostWrite() {
  command = 0;
  ch = 0;
  ptr = 0;  // Reset these on writing
  return true;
}

void DataHostRead() {
  if (command == 'R') {
    if (ptr < 512) {
      TWI0.SDATA = buffer[ptr++];  // Host read operation
    } else {
      TWI0.SDATA = 0;  // Error, too many bytes read
      LightLED(LEDred);
    }
  } else {
    TWI0.SDATA = 0;  // Read in other situations
                     // LightLED(LEDred);
  }
}


boolean DataHostWrite() {

#if DEBUG
  logFile.write("IB");
  logFile.write(TWI0.SDATA);
  logFile.flush();
#endif

  if (command == 0) {  // No command in progress

#if DEBUG
    logFile.write("CM");
    logFile.flush();
#endif

    command = TWI0.SDATA;
    LightLED(LEDgreen);  // Got Command
    if (command != 'I') return true;
  }

  if (command == 'R') {  // READ
#if DEBUG
    logFile.write("CR");
    logFile.flush();
#endif
    ptr = 0;
    return true;
  }


  if (command == 'I') {  // INFO
#if DEBUG
    logFile.write("CI");
    logFile.flush();
#endif
    unsigned long sz = myFile.size();
    unsigned char *p = (unsigned char *)&sz;
    for (int i = 0; i < 512; i++) buffer[i] = 0;
    buffer[0] = 'S';
    buffer[1] = 'D';
    buffer[2] = p[3];
    buffer[3] = p[2];
    buffer[4] = p[1];
    buffer[5] = p[0];
    ptr = 0;
#if DEBUG
    logFile.write(buffer[0]);
    logFile.write(buffer[1]);
    logFile.write(buffer[2]);
    logFile.write(buffer[3]);
    logFile.write(buffer[4]);
    logFile.write(buffer[5]);
    logFile.flush();
#endif
    return true;
  }



  if (command == 'S') {  // Set Sector
#if DEBUG
    logFile.write("CS");
    logFile.write(3 - ch);
    logFile.flush();
#endif
    if (ch < 4) {
      lbaAddress[3 - (ch++)] = TWI0.SDATA;
      if (ch == 4) {
        ulbaAddress.bytes[0] = lbaAddress[0];
        ulbaAddress.bytes[1] = lbaAddress[1];
        ulbaAddress.bytes[2] = lbaAddress[2];
        ulbaAddress.bytes[3] = lbaAddress[3];
        myFile.seek(ulbaAddress.number * 512);
        for (int i = 0; i < 512; i++) {
          buffer[i] = myFile.read();
        }
      }
      ptr = 0;
      return true;
    }
  }

  if (command == 'W') {
#if DEBUG
    logFile.write("CW");
    logFile.write(ptr);
    logFile.flush();
#endif
    if (ptr < 512) {
      buffer[ptr++] = TWI0.SDATA;
      if (ptr == 512) {
        ulbaAddress.bytes[0] = lbaAddress[0];
        ulbaAddress.bytes[1] = lbaAddress[1];
        ulbaAddress.bytes[2] = lbaAddress[2];
        ulbaAddress.bytes[3] = lbaAddress[3];

        myFile.seek(ulbaAddress.number * 512);
        for (int i = 0; i < 512; i++) {
          myFile.write(buffer[i]);
        }
        myFile.flush();
      }    
    return true;
  }
}

// LightLED(LEDred);
return false;
}

void Stop() {
  LightLED(LEDoff);
}

void SendResponse(boolean succeed) {
  if (succeed) {
    TWI0.SCTRLB = TWI_ACKACT_ACK_gc | TWI_SCMD_RESPONSE_gc;  // Send ACK
  } else {
    TWI0.SCTRLB = TWI_ACKACT_NACK_gc | TWI_SCMD_RESPONSE_gc;  // Send NACK
  }
}

// TWI interrupt service routine **********************************************

// TWI interrupt
ISR(TWI0_TWIS_vect) {
  boolean succeed;

  // Address interrupt:
  if ((TWI0.SSTATUS & TWI_APIF_bm) && (TWI0.SSTATUS & TWI_AP_bm)) {
    if (TWI0.SSTATUS & TWI_DIR_bm) {  // Host reading from client
      succeed = AddressHostRead();
    } else {
      succeed = AddressHostWrite();  // Host writing to client
    }
    SendResponse(succeed);
    return;
  }

  // Data interrupt:
  if (TWI0.SSTATUS & TWI_DIF_bm) {
    // LightLED(LEDred);
    if (TWI0.SSTATUS & TWI_DIR_bm) {  // Host reading from client
                                      //  LightLED(LEDgreen);
      if ((TWI0.SSTATUS & TWI_RXACK_bm) && checknack) {
        checknack = false;
      } else {
        DataHostRead();
        checknack = true;
      }
      TWI0.SCTRLB = TWI_SCMD_RESPONSE_gc;  // No ACK/NACK needed
    } else {                               // Host writing to client
      //LightLED(LEDoff);
      succeed = DataHostWrite();
      SendResponse(succeed);
    }

    return;
  }

  // Stop interrupt:
  if ((TWI0.SSTATUS & TWI_APIF_bm) && (!(TWI0.SSTATUS & TWI_AP_bm))) {
    Stop();
    TWI0.SCTRLB = TWI_SCMD_COMPTRANS_gc;  // Complete transaction
    return;
  }
}

// Setup **********************************************

void setup(void) {
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  SD.begin();

#if DEBUG
  logFile = SD.open("logfile.log", O_WRITE | O_APPEND | O_CREAT);
#endif

  myFile = SD.open("IMAGE.IMG", O_RDWR | O_CREAT);
  I2CSetup();
}

void loop(void) {
}
