#pragma once
#include <Arduino.h>
#include <HardwareSerial.h>
#include "ESPTelnetStream.h"
#include <Preferences.h>

void SetupTelnet();
void onTelnetConnect(String ip);
void onTelnetDisconnect(String ip);
void onTelnetReconnect(String ip);
void onTelnetConnectionAttempt(String ip);
void onTelnetInput(String str);
void ConfigureWiFi();
void setStoredIP(const char *Parameter, IPAddress i);
IPAddress getStoredIP(const char *Parameter);
void SetSSID();
void SetPassword();
void SetHostname();
void SetStaticIP();
void SetConsoleSerial();
IPAddress getUserIP();
String getUserString();
int getUserNumber();
void SetDisplayAddress();
void SetSDAddress();


extern ESPTelnetStream telnet;
extern HardwareSerial ConsoleSerial;
