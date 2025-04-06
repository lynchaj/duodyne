#include <ArduinoOTA.h>
#include <HardwareSerial.h>
#include <SPI.h>
#include <SD.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>


#include <stdio.h>
#include <cstring>
#include "esp_log.h"
#include "esp_system.h"
#include "sdkconfig.h"

#include "retrowifi.h"
#include "pins.h"

void onRequest()
{
        Wire1.print(" Packets.");
        Serial.println("onRequest");
        Serial.println();
}

void onReceive(int len)
{
        Serial.printf("onReceive[%d]: ", len);
        while (Wire1.available())
        {
                Serial.write(Wire1.read());
        }
        Serial.println();
}

void i2cSetup()
{
        Preferences preferences;
        preferences.begin("retroESP32", false);
        int displayAddress=preferences.getInt("DisplayAddress",55);
        preferences.end();

        Serial.printf("Display I2C Address:0x%x\n\r ", displayAddress);
        Wire1.setPins(DUODYNEI2C_SDA, DUODYNEI2C_SCL);
        Wire1.onReceive(onReceive);
        Wire1.onRequest(onRequest);
        Wire1.begin((uint8_t )0x55,DUODYNEI2C_SDA, DUODYNEI2C_SCL,100000);

}
