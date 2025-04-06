#include <ArduinoOTA.h>
#include <HardwareSerial.h>
#include <SPI.h>
#include <SD.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#include "retrowifi.h"
#include "pins.h"

int SDActive = 0;

void SetupSD()
{

        SDActive = 1;
        SPI.begin(SCK, MISO, MOSI, CS);
        if (!SD.begin(CS, SPI, 80000000))
        {
                Serial.println("Card Mount Failed");
                SDActive = 0;
        }
}