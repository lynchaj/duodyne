#include <ArduinoOTA.h>
#include <HardwareSerial.h>
#include <SPI.h>
#include <SD.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#include "retrowifi.h"
#include "pins.h"

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1); // Declaration for an SSD1306 display connected to I2C (SDA, SCL pins)

void SetupDisplay()
{
        Wire.setPins(DISPLAYI2C_SDA, DISPLAYI2C_SCL);

        // SSD1306_SWITCHCAPVCC = generate display voltage from 3.3V internally
        if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C))
        {
                Serial.println(F("SSD1306 allocation failed"));
        }

        // Clear the buffer
        display.clearDisplay();

        display.setTextSize(2); // Draw 2X-scale text
        display.setTextColor(WHITE);
        display.println("DUODYNE");

        display.display();
}