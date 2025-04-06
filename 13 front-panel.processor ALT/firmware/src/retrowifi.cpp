#include <Arduino.h>
#include <Preferences.h>
#include <WiFi.h>
#include <HardwareSerial.h>
#include "ESPTelnetStream.h"

#include "retrowifi.h"
#include "pins.h"

HardwareSerial ConsoleSerial(1); // define a Serial for UART2
ESPTelnetStream telnet;
Preferences preferences;

void SetupTelnet()
{
        preferences.begin("retroESP32", false);
        String ssid = preferences.getString("ssid", "");
        String password = preferences.getString("password", "");
        String hostname = preferences.getString("hostname", "duodyne");
        IPAddress staticIP = getStoredIP("static");
        IPAddress gateway = getStoredIP("gateway");
        IPAddress subnet = getStoredIP("subnet");
        IPAddress primaryDNS = getStoredIP("primaryDNS");
        IPAddress secondaryDNS = getStoredIP("secondaryDNS");
        int baud = preferences.getInt("baud", 38400);
        long sparms = preferences.getLong("serialparms", 0x800001c);

        ConsoleSerial.setRxBufferSize(8192);
        ConsoleSerial.setTxBufferSize(8192);
        ConsoleSerial.setPins(ConsoleSerialRX, ConsoleSerialTX, ConsoleSerialCTS, ConsoleSerialRTS);
        ConsoleSerial.begin(baud, sparms, ConsoleSerialRX, ConsoleSerialTX);
        ConsoleSerial.setPins(ConsoleSerialRX, ConsoleSerialTX, ConsoleSerialCTS, ConsoleSerialRTS);
        ConsoleSerial.setHwFlowCtrlMode(UART_HW_FLOWCTRL_CTS_RTS);
        Serial.printf("Console Baud=%i\n\r", ConsoleSerial.baudRate());

        Serial.printf("SSID=%s\n\r", ssid);
        WiFi.mode(WIFI_STA);
        if (staticIP[0] != 0)
        {
                Serial.printf("STATIC IP SET. \n\r");
                WiFi.config(staticIP, gateway, subnet, primaryDNS, secondaryDNS);
        }
        WiFi.setHostname(hostname.c_str());
        WiFi.begin(ssid, password);

        Serial.print("Connecting to WiFi ('X' to abort) ..");
        while (WiFi.status() != WL_CONNECTED)
        {
                Serial.print('.');
                delay(1000);
                if (Serial.available() > 0)
                {
                        char c = Serial.read();
                        if (c == 'X')
                                return;
                }
        }
        Serial.println(WiFi.localIP());

        // passing on functions for various telnet events
        telnet.onConnect(onTelnetConnect);
        telnet.onConnectionAttempt(onTelnetConnectionAttempt);
        telnet.onReconnect(onTelnetReconnect);
        telnet.onDisconnect(onTelnetDisconnect);
        telnet.onInputReceived(onTelnetInput);

        Serial.print("- Telnet: ");
        if (telnet.begin(ConsolePort))
        {
                Serial.println("running");
        }
        else
        {
                Serial.println("error.");
        }
}

void onTelnetConnect(String ip)
{
        Serial.print("- Telnet: ");
        Serial.print(ip);
        Serial.println(" connected");

        telnet.println("\377\375\042\377\373\001");
        telnet.println("\nWelcome " + telnet.getIP());
        telnet.println("(Use ^] + q  to disconnect.)");
}

void onTelnetDisconnect(String ip)
{
        Serial.print("- Telnet: ");
        Serial.print(ip);
        Serial.println(" disconnected");
}

void onTelnetReconnect(String ip)
{
        Serial.print("- Telnet: ");
        Serial.print(ip);
        Serial.println(" reconnected");
}

void onTelnetConnectionAttempt(String ip)
{
        Serial.print("- Telnet: ");
        Serial.print(ip);
        Serial.println(" tried to connected");
}

void onTelnetInput(String str)
{
        ConsoleSerial.printf("%s", str);
}

void ConfigureWiFi()
{

        char c = Serial.read();

        switch (c)
        {
        case '1':
                SetSSID();
                break;
        case '2':
                SetPassword();
                break;
        case '3':
                SetHostname();
                break;
        case '4':
                SetStaticIP();
                break;
        case '5':
                SetConsoleSerial();
                break;
        case '6':
                SetDisplayAddress();
                break;
        case '7':
                SetSDAddress();
                break;

        default:
                Serial.write("\n\n\n\n\r Configuration Menu\n\r");
                Serial.write(" ------------------\n\r");
                Serial.write(" 1. Set Wifi SSID\n\r");
                Serial.write(" 2. Set Wifi Password\n\r");
                Serial.write(" 3. Set Hostname\n\r");
                Serial.write(" 4. Set Static IP\n\r");
                Serial.write(" 5. Set Console Serial Parameters\n\r");
                Serial.write(" 6. Set Display Address\n\r");
                Serial.write(" 7. Set SD Address\n\r");
                Serial.write("\n\r Selection--->");
        }
}

void SetSSID()
{
        Serial.write("\n\n\n\n\r Enter SSID:");
        Serial.flush();
        String ssid = getUserString();
        preferences.putString("ssid", ssid);
        Serial.printf("SSID set to %s\n\r", ssid);
        ESP.restart();
}
void SetPassword()
{
        Serial.write("\n\n\n\n\r Enter Password:");
        Serial.flush();
        String password = getUserString();
        preferences.putString("password", password);
        Serial.printf("Password set to %s\n\r", password);
        ESP.restart();
}
void SetHostname()
{
        Serial.write("\n\n\n\n\r Enter Hostname:");
        Serial.flush();
        String hostname = getUserString();
        preferences.putString("hostname", hostname);
        Serial.printf("Hostname set to %s\n\r", hostname);
        ESP.restart();
}
void SetStaticIP()
{
        Serial.write("\n\n\n\n\r Enter IP Address (0.0.0.0 for DHCP):");
        Serial.flush();
        IPAddress staticIP =getUserIP();
        setStoredIP("static",staticIP);
        if(staticIP[0]>0)
        {
                Serial.write("\n\r Enter subnet mask:");
                Serial.flush();
                IPAddress subnet =getUserIP();
                Serial.write("\n\r Enter gateway Address:");
                Serial.flush();
                IPAddress gateway =getUserIP();
                Serial.write("\n\r Enter Primary DNS Address:");
                Serial.flush();
                IPAddress primaryDNS =getUserIP();
                Serial.write("\n\r Enter Secondary DNS Address:");
                Serial.flush();
                IPAddress secondaryDNS =getUserIP();

                setStoredIP("gateway",gateway);
                setStoredIP("subnet",subnet);
                setStoredIP("primaryDNS",primaryDNS);
                setStoredIP("secondaryDNS",secondaryDNS);
                Serial.printf("\n\n\rStatic IP Address set to %d.%d.%d.%d\n\r", staticIP[0],staticIP[1],staticIP[2],staticIP[3]);
                Serial.printf("Subnet Mask set to %d.%d.%d.%d\n\r", subnet[0],subnet[1],subnet[2],subnet[3]);
                Serial.printf("Gateway Address set to %d.%d.%d.%d\n\r", gateway[0],gateway[1],gateway[2],gateway[3]);
                Serial.printf("Primary DNS Address set to %d.%d.%d.%d\n\r", primaryDNS[0],primaryDNS[1],primaryDNS[2],primaryDNS[3]);
                Serial.printf("Secondary DNS Address set to %d.%d.%d.%d\n\r", secondaryDNS[0],secondaryDNS[1],secondaryDNS[2],secondaryDNS[3]);

        }
        else
        {
                setStoredIP("gateway",staticIP);
                setStoredIP("subnet",staticIP);
                setStoredIP("primaryDNS",staticIP);
                setStoredIP("secondaryDNS",staticIP);
                Serial.printf("\n\rIP Address set to DHCP\n\r");
        }
        ESP.restart();
}
void SetConsoleSerial()
{
        char c=0;
        Serial.write("\n\n\n\n\r Enter Console Baud Rate:");
        Serial.flush();
        int baud = getUserNumber();
        preferences.putInt("baud", baud);
        Serial.write("\n\n\r Choose Serial Parameters:\n\r");
        Serial.write(" -------------------------\n\r");
        Serial.write(" 1. 7N1\n\r");
        Serial.write(" 2. 7E1\n\r");
        Serial.write(" 3. 7O1\n\r");
        Serial.write(" 4. 8N1\n\r");
        Serial.write(" 5. 8E1\n\r");
        Serial.write(" 6. 8O1\n\r");
        Serial.flush();
        delay(500);
        Serial.flush();
        while(c==0)
        {
                while (Serial.available() == 0) {}
                c = Serial.read();
                if((c<49) || (c>54)) c=0;
        }
        Serial.printf("\n\n\rSELECTED %c",c);
        Serial.write("\n\n\n\n\n\r");
        switch (c)
        {
        case '1':
                preferences.putLong("serialparms", 0x8000018);
                break;
        case '2':
                preferences.putLong("serialparms", 0x800001a);
                break;
        case '3':
                preferences.putLong("serialparms", 0x800001b);
                break;
        case '4':
                preferences.putLong("serialparms", 0x800001c);
                break;
        case '5':
                preferences.putLong("serialparms", 0x800001e);
                break;
        case '6':
                preferences.putLong("serialparms", 0x800001f);
                break;
        }
        ESP.restart();
}
void SetDisplayAddress()
{
        Serial.write("\n\n\n\n\r Enter Display I2C Address:");
        Serial.flush();
        int address = getUserNumber();
        preferences.putInt("DisplayAddress",address);
        ESP.restart();
}
void SetSDAddress()
{
        Serial.write("\n\n\n\n\r Enter SD Card I2C Address:");
        Serial.flush();
        int address = getUserNumber();
        preferences.putInt("SDAddress",address);
        ESP.restart();
}
int getUserNumber()
{
        char c = 0;
        int o=0;
        int d=0;
        int result=0;

        while (c!=13)
        {
                while (Serial.available() == 0) {}
                c = Serial.read();
                if((c>47) && (c<58))
                {
                        Serial.write(c);
                        o=(o*10)+(c-48);
                        d++;
                        result=o;
                }
                if(c==8)
                {
                        if(d>0)
                        {
                                Serial.write(c);
                                Serial.write(' ');
                                Serial.write(c);
                                o=(o/10);
                                d--;
                                result=o;
                        }
                        else
                        {
                                o=0;
                                result=0;
                        }
                }
        }
        return result;
}
IPAddress getUserIP()
{
        char c = 0;
        int o=0;
        int d=0;
        int p=0;
        IPAddress result;

        while (p<4)
        {
                while (Serial.available() == 0) {}
                c = Serial.read();
                if((c>47) && (c<58))
                {
                        Serial.write(c);
                        o=(o*10)+(c-48);
                        d++;
                        result[p]=o;
                        if(o>255)
                        {
                                result[p]=0;
                                d=0;
                                o=0;
                                Serial.write(8);
                                Serial.write(8);
                                Serial.write(8);
                                Serial.write("   ");
                                Serial.write(8);
                                Serial.write(8);
                                Serial.write(8);
                        }
                        if(d==3)
                        {
                                if(p!=3)
                                {
                                        Serial.write('.');
                                        p++;
                                        d=0;
                                        o=0;
                                }
                        }
                }
                if((c=='.') && (d>0))
                {
                        if(p!=3)
                        {
                                Serial.write('.');
                        }
                        p++;
                        d=0;
                        o=0;
                }
                if((c==13) && (p==3))
                {
                        p++;
                        d=0;
                        o=0;
                }
                if(c==8)
                {
                        if(d>0)
                        {
                                Serial.write(c);
                                Serial.write(' ');
                                Serial.write(c);
                                o=(o/10);
                                d--;
                                result[p]=o;
                        }
                        else
                        {
                                if(p>0)
                                {
                                        p--;
                                        o=result[p];
                                        o=(o/10);
                                        result[p]=o;
                                        d=2;
                                        if(o<10) d=1;
                                        if(o==0) d=0;
                                        Serial.write(c);
                                        Serial.write(c);
                                        Serial.write("  ");
                                        Serial.write(c);
                                        Serial.write(c);
                                }
                        }
                }
        }

        return result;
}
String getUserString()
{
        char c = 0;
        String result = "";

        while (c != 13)
        {
                while (Serial.available() == 0) {}
                c = Serial.read();
                if((c>32) && (c<127))
                {
                        Serial.write(c);
                        result.concat(c);
                }
                if((c==8) && (result.length()>1))
                {
                        Serial.write(c);
                        Serial.write(' ');
                        Serial.write(c);
                        result=result.substring(0,result.length()-1);
                }
                if((c==8) && (result.length()==1))
                {
                        Serial.write(c);
                        Serial.write(' ');
                        Serial.write(c);
                        result="";
                }
        }

        return result;
}
void setStoredIP(const char *Parameter, IPAddress i)
{
        uint8_t ip[4];
        ip[0] = i[0];
        ip[1] = i[1];
        ip[2] = i[2];
        ip[3] = i[3];
        preferences.putBytes(Parameter, &ip, 4);
}
IPAddress getStoredIP(const char *Parameter)
{
        uint8_t ip[4] = {0, 0, 0, 0};
        IPAddress result;
        preferences.getBytes(Parameter, &ip, 4);
        result[0] = ip[0];
        result[1] = ip[1];
        result[2] = ip[2];
        result[3] = ip[3];

        return result;
}

/*
bool retroWifi::setSSID(uint8_t b)
{
    *currentPointer++ = b;
    if (b == 0)
    {
        strncpy(m_ssid,(char *)&buffer[0], 64);
        preferences.putString("ssid", m_ssid);
        return true;
    }
    return false;
}

bool retroWifi::setPassword(uint8_t b)
{
    *currentPointer++ = b;
    if (b == 0)
    {
        strncpy(m_password,(char *)&buffer[0], 64);
        preferences.putString("password", m_password);
        return true;
    }
    return false;
}

void retroWifi::resetPointer()
{
    currentPointer = buffer;
}


uint8_t retroWifi::status()
{
    return WiFi.status();
}

uint8_t retroWifi::strength()
{
    return WiFi.RSSI();
}

void retroWifi::getIpAddress()
{
    IPAddress add = WiFi.localIP();
    queueByte(add[0]);
    queueByte(add[1]);
    queueByte(add[2]);
    queueByte(add[3]);
}

void retroWifi::getSubnet()
{
    IPAddress add = WiFi.subnetMask();
    queueByte(add[0]);
    queueByte(add[1]);
    queueByte(add[2]);
    queueByte(add[3]);
}

void retroWifi::getGateway()
{
    IPAddress add = WiFi.gatewayIP();
    queueByte(add[0]);
    queueByte(add[1]);
    queueByte(add[2]);
    queueByte(add[3]);
}

void retroWifi::getPrimaryDns()
{
    IPAddress add = WiFi.dnsIP(0);
    queueByte(add[0]);
    queueByte(add[1]);
    queueByte(add[2]);
    queueByte(add[3]);
}

void retroWifi::getSecondaryDns()
{
    IPAddress add = WiFi.dnsIP(1);
    queueByte(add[0]);
    queueByte(add[1]);
    queueByte(add[2]);
    queueByte(add[3]);
}

bool retroWifi::setIpAddress(uint8_t b)
{
    *currentPointer++ = b;
    if ((currentPointer - buffer) == 4)
    {
        IPAddress i;
        i[0] = buffer[0];
        i[1] = buffer[1];
        i[2] = buffer[2];
        i[3] = buffer[3];
        setStoredIP("static", i);
        staticIP = getStoredIP("static");
        return true;
    }
    return false;
}

bool retroWifi::setSubnet(uint8_t b)
{
    *currentPointer++ = b;
    if ((currentPointer - buffer) == 4)
    {
        IPAddress i;
        i[0] = buffer[0];
        i[1] = buffer[1];
        i[2] = buffer[2];
        i[3] = buffer[3];
        setStoredIP("subnet", i);
        subnet = getStoredIP("subnet");
        return true;
    }
    return false;
}

bool retroWifi::setGateway(uint8_t b)
{
    *currentPointer++ = b;
    if ((currentPointer - buffer) == 4)
    {
        IPAddress i;
        i[0] = buffer[0];
        i[1] = buffer[1];
        i[2] = buffer[2];
        i[3] = buffer[3];
        setStoredIP("gateway", i);
        gateway = getStoredIP("gateway");
        return true;
    }
    return false;
}
bool retroWifi::setPrimaryDns(uint8_t b)
{
    *currentPointer++ = b;
    if ((currentPointer - buffer) == 4)
    {
        IPAddress i;
        i[0] = buffer[0];
        i[1] = buffer[1];
        i[2] = buffer[2];
        i[3] = buffer[3];
        setStoredIP("primaryDNS", i);
        primaryDNS = getStoredIP("primaryDNS");

        return true;
    }
    return false;
}
bool retroWifi::setSecondaryDns(uint8_t b)
{
    *currentPointer++ = b;
    if ((currentPointer - buffer) == 4)
    {
        IPAddress i;
        i[0] = buffer[0];
        i[1] = buffer[1];
        i[2] = buffer[2];
        i[3] = buffer[3];
        setStoredIP("secondaryDNS", i);
        secondaryDNS = getStoredIP("secondaryDNS");
        return true;
    }
    return false;
}


bool retroWifi::setHostname(uint8_t b)
{
    *currentPointer++ = b;
    if (b == 0)
    {
        strncpy(m_hostname,(char *)&buffer[0], 64);
        preferences.putString("hostname", m_hostname);
        return true;
    }
    return false;
}

bool retroWifi::createOutgoingConnection(uint8_t b)
{
    *currentPointer++ = b;
    if ((currentPointer - buffer) > sizeof(OutgoingConnectionParameter))
    {
        OutgoingConnectionParameter *p;
        p = (OutgoingConnectionParameter *)buffer;
        if (b == 0)
        {
            if (p->connectionNumber > 0)
            {
                client[p->connectionNumber].stop();
                client[p->connectionNumber].connect((char *)&buffer[sizeof(OutgoingConnectionParameter)], p->portNumber);
            }
            return true;
        }
    }
    return false;
}

void retroWifi::setIncomingPort(uint16_t b)
{
    server.stopAll();
    server.begin(b);
}

bool retroWifi::outByteToConnection(uint8_t b)
{
    *currentPointer++ = b;
    int len = (currentPointer - buffer);
    if (len == 2)
    {
        client[buffer[0]].write(buffer[1]);
        return true;
    }
    return false;
}

bool retroWifi::outStringToConnection(uint8_t b)
{
    *currentPointer++ = b;
    int len = (currentPointer - buffer);
    if (len > 1)
    {
        if (b == 0)
        {

            client[buffer[0]].write((char *)&buffer[1]);
            return true;
        }
    }
    return false;
}

void retroWifi::inByteFromConnection(uint8_t b)
{
    queueByte(client[b].read());
}

void retroWifi::queuedBytesFromConnection(uint8_t b)
{
    queueByte(client[b].available());
}

void retroWifi::listenForIncomingConnection()
{
    if (!client[0].connected())
    {
        client[0] = server.available();
    }
}

void retroWifi::getMacAddress()
{
    uint8_t MAC_Address[6];
    WiFi.macAddress(MAC_Address);
    queueByte(MAC_Address[0]);
    queueByte(MAC_Address[1]);
    queueByte(MAC_Address[2]);
    queueByte(MAC_Address[3]);
    queueByte(MAC_Address[4]);
    queueByte(MAC_Address[5]);
}
*/