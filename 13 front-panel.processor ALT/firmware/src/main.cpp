#include <ArduinoOTA.h>
#include <HardwareSerial.h>
#include <SPI.h>
#include <SD.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#include "retrowifi.h"
#include "pins.h"

// TODO: USB MENU FOR SETUP OF WIFI
// TODO: I2C Protocol for Display
// TODO: I2C Protocol for SD Card Access

void SetupDisplay();
void i2cSetup();
void SetupSD();

void setup()
{
  // Setup Debug USB Serial
  Serial.begin(115200);

  // Setup i2c Communication Bus
  i2cSetup();

  // Setup the OLED Display
  SetupDisplay();

  // Setup the SD Card
  //SetupSD();

  // Setup Wifi
  SetupTelnet();

  // Setup for OTA update
  ArduinoOTA
      .onStart([]()
               {
    String type;
    if (ArduinoOTA.getCommand() == U_FLASH) {
      type = "sketch";
    } else {  // U_SPIFFS
      type = "filesystem";
    }

    // NOTE: if updating SPIFFS this would be the place to unmount SPIFFS using SPIFFS.end()
    Serial.println("Start updating " + type); })
      .onEnd([]()
             { Serial.println("\nEnd"); })
      .onProgress([](unsigned int progress, unsigned int total)
                  { Serial.printf("Progress: %u%%\r", (progress / (total / 100))); })
      .onError([](ota_error_t error)
               {
    Serial.printf("Error[%u]: ", error);
    if (error == OTA_AUTH_ERROR) {
      Serial.println("Auth Failed");
    } else if (error == OTA_BEGIN_ERROR) {
      Serial.println("Begin Failed");
    } else if (error == OTA_CONNECT_ERROR) {
      Serial.println("Connect Failed");
    } else if (error == OTA_RECEIVE_ERROR) {
      Serial.println("Receive Failed");
    } else if (error == OTA_END_ERROR) {
      Serial.println("End Failed");
    } });

  ArduinoOTA.begin();
}

void loop()
{

  while (true)
  {
    if (WiFi.isConnected())
      ArduinoOTA.handle();

    telnet.loop();

    if (ConsoleSerial.available() > 0)
    {
      telnet.write(ConsoleSerial.read());
    }

    if (Serial.available()>0)
    {
      ConfigureWiFi();
    }
  }
}
