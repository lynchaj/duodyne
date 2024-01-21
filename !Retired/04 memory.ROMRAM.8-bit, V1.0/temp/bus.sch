EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr B 17000 11000
encoding utf-8
Sheet 3 10
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L conn:CONN_02X25 P1
U 1 1 7A9CFBC3
P 8250 8050
AR Path="/644081EC/7A9CFBC3" Ref="P1"  Part="1" 
AR Path="/6485F460/7A9CFBC3" Ref="P?"  Part="1" 
F 0 "P1" H 8250 9465 50  0000 C CNN
F 1 "CONN_02X25" H 8250 9374 50  0000 C CNN
F 2 "Connector_IDC:IDC-Header_2x25_P2.54mm_Horizontal" H 8250 7300 50  0001 C CNN
F 3 "" H 8250 7300 50  0001 C CNN
	1    8250 8050
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 P2
U 1 1 7A9CFBC4
P 8250 5300
AR Path="/644081EC/7A9CFBC4" Ref="P2"  Part="1" 
AR Path="/6485F460/7A9CFBC4" Ref="P?"  Part="1" 
F 0 "P2" H 8250 6715 50  0000 C CNN
F 1 "CONN_02X25" H 8250 6624 50  0000 C CNN
F 2 "Connector_IDC:IDC-Header_2x25_P2.54mm_Horizontal" H 8250 4550 50  0001 C CNN
F 3 "" H 8250 4550 50  0001 C CNN
	1    8250 5300
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 P3
U 1 1 652BA238
P 8250 2550
AR Path="/644081EC/652BA238" Ref="P3"  Part="1" 
AR Path="/6485F460/652BA238" Ref="P?"  Part="1" 
F 0 "P3" H 8250 3965 50  0000 C CNN
F 1 "CONN_02X25" H 8250 3874 50  0000 C CNN
F 2 "Connector_IDC:IDC-Header_2x25_P2.54mm_Horizontal" H 8250 1800 50  0001 C CNN
F 3 "" H 8250 1800 50  0001 C CNN
	1    8250 2550
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_01X04 P4
U 1 1 648C1DB9
P 10050 8950
F 0 "P4" H 9967 8575 50  0000 C CNN
F 1 "BYPASS" H 9967 8666 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x04_P2.54mm_Vertical" H 10050 8950 50  0001 C CNN
F 3 "" H 10050 8950 50  0001 C CNN
	1    10050 8950
	1    0    0    1   
$EndComp
Text GLabel 9850 8800 0    40   Output ~ 0
~BAI
Text GLabel 9850 8900 0    40   Input ~ 0
~BAO
Text GLabel 9850 9000 0    40   Output ~ 0
~IEI
Text GLabel 9850 9100 0    40   Input ~ 0
~IEO
NoConn ~ 7500 3450
NoConn ~ 7500 1450
NoConn ~ 7500 1550
NoConn ~ 7500 1650
NoConn ~ 7500 1750
NoConn ~ 7500 1850
NoConn ~ 7500 1950
NoConn ~ 7500 2050
NoConn ~ 7500 2150
NoConn ~ 7500 3050
NoConn ~ 7500 3150
NoConn ~ 7500 3250
NoConn ~ 7500 3350
NoConn ~ 7500 3550
NoConn ~ 7500 3650
Text GLabel 7500 4200 0    40   Input ~ 0
A15
Text GLabel 7500 4300 0    40   Input ~ 0
A14
Text GLabel 7500 4400 0    40   Input ~ 0
A13
Text GLabel 7500 4500 0    40   Input ~ 0
A12
Text GLabel 7500 4600 0    40   Input ~ 0
A11
Text GLabel 7500 4700 0    40   Input ~ 0
A10
Text GLabel 7500 4800 0    40   Input ~ 0
A9
Text GLabel 7500 4900 0    40   Input ~ 0
A8
Text GLabel 7500 5100 0    40   Input ~ 0
A7
Text GLabel 7500 5200 0    40   Input ~ 0
A6
Text GLabel 7500 5300 0    40   Input ~ 0
A5
Text GLabel 7500 5400 0    40   Input ~ 0
A4
Text GLabel 7500 5500 0    40   Input ~ 0
A3
Text GLabel 7500 5600 0    40   Input ~ 0
A2
Text GLabel 7500 5700 0    40   Input ~ 0
A1
Text GLabel 7500 5800 0    40   Input ~ 0
A0
Text GLabel 7500 2950 0    40   BiDi ~ 0
D0
Text GLabel 7500 2850 0    40   BiDi ~ 0
D1
Text GLabel 7500 2750 0    40   BiDi ~ 0
D2
Text GLabel 7500 2650 0    40   BiDi ~ 0
D3
Text GLabel 7500 2550 0    40   BiDi ~ 0
D4
Text GLabel 7500 2450 0    40   BiDi ~ 0
D5
Text GLabel 7500 2350 0    40   BiDi ~ 0
D6
Text GLabel 7500 2250 0    40   BiDi ~ 0
D7
Text GLabel 7500 6950 0    40   Input ~ 0
~RD
Text GLabel 7500 7050 0    40   Input ~ 0
~WR
Text GLabel 7500 7150 0    40   Input ~ 0
~IORQ
Text GLabel 7500 7250 0    40   Input ~ 0
~MREQ
Text GLabel 7500 7350 0    40   Input ~ 0
~M1
Text GLabel 7500 7850 0    40   Input ~ 0
~RESET
Text GLabel 7500 5000 0    40   Output ~ 0
+12V
Text GLabel 9000 5000 2    40   Output ~ 0
+12V
Text GLabel 9000 5900 2    40   Output ~ 0
-12V
Text GLabel 7500 5900 0    40   Output ~ 0
-12V
Text GLabel 9000 6500 2    40   Output ~ 0
GND
Text GLabel 7500 6500 0    40   Output ~ 0
GND
Text GLabel 9000 6850 2    40   Output ~ 0
VCC
Text GLabel 7500 6850 0    40   Output ~ 0
VCC
Text GLabel 7500 9250 0    40   Output ~ 0
GND
Text GLabel 9000 9250 2    40   Output ~ 0
GND
Text GLabel 7500 4100 0    40   Output ~ 0
VCC
Text GLabel 9000 4100 2    40   Output ~ 0
VCC
Text GLabel 9000 1350 2    40   Output ~ 0
VCC
Text GLabel 7500 1350 0    40   Output ~ 0
VCC
Text GLabel 9000 3750 2    40   Output ~ 0
GND
Text GLabel 7500 3750 0    40   Output ~ 0
GND
Text GLabel 9000 8750 2    40   Input ~ 0
~BAI
Text GLabel 9000 8850 2    40   Output ~ 0
~BAO
Text GLabel 9000 8950 2    40   Input ~ 0
~IEI
Text GLabel 9000 9050 2    40   Output ~ 0
~IEO
Text Label 7600 4600 0    60   ~ 0
A11
Text Label 7600 4400 0    60   ~ 0
A13
Text Label 7600 4300 0    60   ~ 0
A14
Text Label 7600 4200 0    60   ~ 0
A15
Text Label 7600 4500 0    60   ~ 0
A12
Text Label 7600 2850 0    60   ~ 0
D1
Text Label 7600 2750 0    60   ~ 0
D2
Text Label 7600 2650 0    60   ~ 0
D3
Text Label 7600 2950 0    60   ~ 0
D0
Text Label 7600 2350 0    60   ~ 0
D6
Text Label 7600 2250 0    60   ~ 0
D7
Text Label 7600 2550 0    60   ~ 0
D4
Text Label 8600 6850 0    60   ~ 0
VCC
Wire Wire Line
	7500 4600 8000 4600
Wire Wire Line
	7500 4500 8000 4500
Wire Wire Line
	7500 4400 8000 4400
Wire Wire Line
	7500 4300 8000 4300
Wire Wire Line
	7500 4200 8000 4200
Wire Wire Line
	7500 2950 8000 2950
Wire Wire Line
	7500 2850 8000 2850
Wire Wire Line
	7500 2750 8000 2750
Wire Wire Line
	7500 2650 8000 2650
Wire Wire Line
	7500 2550 8000 2550
Wire Wire Line
	7500 2350 8000 2350
Wire Wire Line
	7500 2250 8000 2250
Wire Wire Line
	8500 6850 9000 6850
Text Label 8600 4100 0    60   ~ 0
VCC
Wire Wire Line
	8500 4100 9000 4100
Text Label 7600 4100 0    60   ~ 0
VCC
Wire Wire Line
	7500 4100 8000 4100
Text Label 8600 1350 0    60   ~ 0
VCC
Wire Wire Line
	8500 1350 9000 1350
Text Label 7600 1350 0    60   ~ 0
VCC
Wire Wire Line
	7500 1350 8000 1350
Text Label 7600 3750 0    60   ~ 0
GND
Wire Wire Line
	7500 3750 8000 3750
Text Label 8600 3750 0    60   ~ 0
GND
Wire Wire Line
	8500 3750 9000 3750
Text Label 7600 6500 0    60   ~ 0
GND
Wire Wire Line
	7500 6500 8000 6500
Text Label 8600 6500 0    60   ~ 0
GND
Wire Wire Line
	8500 6500 9000 6500
Text Label 7600 9250 0    60   ~ 0
GND
Wire Wire Line
	7500 9250 8000 9250
Text Label 8600 9250 0    60   ~ 0
GND
Wire Wire Line
	8500 9250 9000 9250
Wire Wire Line
	7500 5100 8000 5100
Wire Wire Line
	7500 5200 8000 5200
Wire Wire Line
	7500 5300 8000 5300
Wire Wire Line
	7500 5400 8000 5400
Wire Wire Line
	7500 5500 8000 5500
Wire Wire Line
	7500 5600 8000 5600
Wire Wire Line
	7500 5700 8000 5700
Wire Wire Line
	7500 5800 8000 5800
Wire Wire Line
	7500 4700 8000 4700
Wire Wire Line
	7500 4800 8000 4800
Wire Wire Line
	7500 4900 8000 4900
Text Label 7600 5400 0    60   ~ 0
A4
Text Label 7600 5100 0    60   ~ 0
A7
Text Label 7600 5200 0    60   ~ 0
A6
Text Label 7600 5300 0    60   ~ 0
A5
Text Label 7600 5800 0    60   ~ 0
A0
Text Label 7600 5500 0    60   ~ 0
A3
Text Label 7600 5600 0    60   ~ 0
A2
Text Label 7600 5700 0    60   ~ 0
A1
Text Label 7600 4900 0    60   ~ 0
A8
Text Label 7600 4700 0    60   ~ 0
A10
Text Label 7600 4800 0    60   ~ 0
A9
Wire Wire Line
	7500 2450 8000 2450
Text Label 7600 2450 0    60   ~ 0
D5
Wire Wire Line
	9000 9150 8500 9150
Wire Wire Line
	8000 9150 7500 9150
Text Label 8900 9150 2    60   ~ 0
I2C_TX
Text Label 7900 9150 2    60   ~ 0
I2C_RX
Text Label 8600 5600 0    60   ~ 0
A18
Text Label 8600 5700 0    60   ~ 0
A17
Text Label 8600 5800 0    60   ~ 0
A16
Text Label 8600 5500 0    60   ~ 0
A19
Wire Wire Line
	8500 5500 9000 5500
Wire Wire Line
	8500 5600 9000 5600
Wire Wire Line
	8500 5700 9000 5700
Wire Wire Line
	8500 5800 9000 5800
Wire Wire Line
	8000 3550 7500 3550
Wire Wire Line
	8500 7550 9000 7550
Wire Wire Line
	8500 7650 9000 7650
Wire Wire Line
	8000 6000 7500 6000
Wire Wire Line
	8000 6100 7500 6100
Wire Wire Line
	8000 3150 7500 3150
Wire Wire Line
	8000 3450 7500 3450
Wire Wire Line
	8000 3350 7500 3350
Wire Wire Line
	8000 3250 7500 3250
Wire Wire Line
	9000 7450 8500 7450
Wire Wire Line
	8000 6300 7500 6300
Wire Wire Line
	8000 6200 7500 6200
Wire Wire Line
	8000 3050 7500 3050
Wire Wire Line
	8000 3650 7500 3650
Text Label 8600 5200 0    60   ~ 0
A22
Text Label 8600 5300 0    60   ~ 0
A21
Text Label 8600 5400 0    60   ~ 0
A20
Text Label 8600 5100 0    60   ~ 0
A23
Wire Wire Line
	8500 5100 9000 5100
Wire Wire Line
	8500 5200 9000 5200
Wire Wire Line
	8500 5300 9000 5300
Wire Wire Line
	8500 5400 9000 5400
Text Label 8600 4800 0    60   ~ 0
A25
Text Label 8600 4700 0    60   ~ 0
A26
Text Label 8600 4900 0    60   ~ 0
A24
Wire Wire Line
	8500 4900 9000 4900
Wire Wire Line
	8500 4800 9000 4800
Wire Wire Line
	8500 4700 9000 4700
Wire Wire Line
	8500 4200 9000 4200
Wire Wire Line
	8500 4300 9000 4300
Wire Wire Line
	8500 4400 9000 4400
Wire Wire Line
	8500 4500 9000 4500
Wire Wire Line
	8500 4600 9000 4600
Text Label 8600 4500 0    60   ~ 0
A28
Text Label 8600 4200 0    60   ~ 0
A31
Text Label 8600 4300 0    60   ~ 0
A30
Text Label 8600 4400 0    60   ~ 0
A29
Text Label 8600 4600 0    60   ~ 0
A27
Wire Wire Line
	8500 3150 9000 3150
Wire Wire Line
	8500 3250 9000 3250
Wire Wire Line
	8500 3350 9000 3350
Wire Wire Line
	8500 3050 9000 3050
Wire Wire Line
	8500 3450 9000 3450
Text Label 7600 2050 0    60   ~ 0
D9
Text Label 7600 1950 0    60   ~ 0
D10
Text Label 7600 1850 0    60   ~ 0
D11
Text Label 7600 2150 0    60   ~ 0
D8
Text Label 7600 1550 0    60   ~ 0
D14
Text Label 7600 1450 0    60   ~ 0
D15
Text Label 7600 1750 0    60   ~ 0
D12
Wire Wire Line
	7500 2150 8000 2150
Wire Wire Line
	7500 2050 8000 2050
Wire Wire Line
	7500 1950 8000 1950
Wire Wire Line
	7500 1850 8000 1850
Wire Wire Line
	7500 1750 8000 1750
Wire Wire Line
	7500 1550 8000 1550
Wire Wire Line
	7500 1450 8000 1450
Wire Wire Line
	7500 1650 8000 1650
Text Label 7600 1650 0    60   ~ 0
D13
Text Label 8600 5000 0    60   ~ 0
+12V
Wire Wire Line
	8500 5000 9000 5000
Text Label 7600 5000 0    60   ~ 0
+12V
Text Label 8600 2850 0    60   ~ 0
D17
Text Label 8600 2750 0    60   ~ 0
D18
Text Label 8600 2650 0    60   ~ 0
D19
Text Label 8600 2950 0    60   ~ 0
D16
Text Label 8600 2350 0    60   ~ 0
D22
Text Label 8600 2250 0    60   ~ 0
D23
Text Label 8600 2550 0    60   ~ 0
D20
Wire Wire Line
	8500 2950 9000 2950
Wire Wire Line
	8500 2850 9000 2850
Wire Wire Line
	8500 2750 9000 2750
Wire Wire Line
	8500 2650 9000 2650
Wire Wire Line
	8500 2550 9000 2550
Wire Wire Line
	8500 2350 9000 2350
Wire Wire Line
	8500 2250 9000 2250
Wire Wire Line
	8500 2450 9000 2450
Text Label 8600 2450 0    60   ~ 0
D21
Text Label 8600 2050 0    60   ~ 0
D25
Text Label 8600 1950 0    60   ~ 0
D26
Text Label 8600 1850 0    60   ~ 0
D27
Text Label 8600 2150 0    60   ~ 0
D24
Text Label 8600 1550 0    60   ~ 0
D30
Text Label 8600 1450 0    60   ~ 0
D31
Text Label 8600 1750 0    60   ~ 0
D28
Wire Wire Line
	8500 2150 9000 2150
Wire Wire Line
	8500 2050 9000 2050
Wire Wire Line
	8500 1950 9000 1950
Wire Wire Line
	8500 1850 9000 1850
Wire Wire Line
	8500 1750 9000 1750
Wire Wire Line
	8500 1550 9000 1550
Wire Wire Line
	8500 1450 9000 1450
Wire Wire Line
	8500 1650 9000 1650
Text Label 8600 1650 0    60   ~ 0
D29
Wire Wire Line
	7500 5000 8000 5000
Text Label 8600 8550 0    60   ~ 0
USER1
Text Label 8600 8650 0    60   ~ 0
USER0
Text Label 8600 8450 0    60   ~ 0
USER2
Wire Wire Line
	8500 8450 9000 8450
Wire Wire Line
	8500 8550 9000 8550
Wire Wire Line
	8500 8650 9000 8650
Text Label 8600 8250 0    60   ~ 0
USER4
Text Label 8600 8350 0    60   ~ 0
USER3
Text Label 8600 8150 0    60   ~ 0
USER5
Wire Wire Line
	8500 8150 9000 8150
Wire Wire Line
	8500 8250 9000 8250
Wire Wire Line
	8500 8350 9000 8350
Text Label 8600 8050 0    60   ~ 0
USER6
Text Label 8600 7850 0    60   ~ 0
USER8
Wire Wire Line
	8500 7850 9000 7850
Wire Wire Line
	8500 7950 9000 7950
Wire Wire Line
	8500 8050 9000 8050
Text Label 8600 7750 0    60   ~ 0
USER9
Wire Wire Line
	8500 7750 9000 7750
Text Label 8600 7950 0    60   ~ 0
USER7
Text Label 8600 3450 0    60   ~ 0
S0
Text Label 8600 3350 0    60   ~ 0
S1
Text Label 8600 3250 0    60   ~ 0
S2
Text Label 7600 6300 0    60   ~ 0
IC0
Text Label 7600 6200 0    60   ~ 0
IC1
Text Label 7600 6100 0    60   ~ 0
IC2
Text Label 7600 6000 0    60   ~ 0
IC3
Text Label 8600 7650 0    60   ~ 0
CRUIN
Text Label 8600 7550 0    60   ~ 0
CRUOUT
Text Label 8600 7450 0    60   ~ 0
CRYCCLK
Text Label 8600 6950 0    60   ~ 0
E
Wire Wire Line
	9000 7350 8500 7350
Wire Wire Line
	9000 7250 8500 7250
Wire Wire Line
	8500 6000 9000 6000
Wire Wire Line
	8500 6100 9000 6100
Wire Wire Line
	9000 7150 8500 7150
Wire Wire Line
	9000 7050 8500 7050
Wire Wire Line
	9000 6950 8500 6950
Text Label 8600 6100 0    60   ~ 0
~DREQ1
Text Label 8600 7350 0    60   ~ 0
~INT1
Text Label 8600 7250 0    60   ~ 0
~INT2
Text Label 8600 6000 0    60   ~ 0
~TEND1
Text Label 8600 7150 0    60   ~ 0
PHI
Text Label 8600 7050 0    60   ~ 0
ST
Text Label 8600 6200 0    60   ~ 0
~TEND0
Wire Wire Line
	8500 6200 9000 6200
Text Label 8600 6300 0    60   ~ 0
~DREQ0
Wire Wire Line
	8500 6300 9000 6300
Text Label 8600 3550 0    60   ~ 0
AUXCLK3
Text Label 8600 3650 0    60   ~ 0
AUXCLK2
Text Label 7600 6400 0    60   ~ 0
AUXCLK1
Wire Wire Line
	9000 3550 8500 3550
Wire Wire Line
	7500 6400 8000 6400
Wire Wire Line
	8500 3650 9000 3650
Wire Wire Line
	8500 6400 9000 6400
Wire Wire Line
	9000 9050 8500 9050
Text Label 8600 8850 0    60   ~ 0
~BAO-1
Wire Wire Line
	9000 8850 8500 8850
Text Label 8600 8750 0    60   ~ 0
~BAI-1
Wire Wire Line
	9000 8750 8500 8750
Text Label 8600 3050 0    60   ~ 0
UDS
Text Label 8600 3150 0    60   ~ 0
LDS
Text Label 7600 3050 0    60   ~ 0
BUSERR
Text Label 7600 3150 0    60   ~ 0
VPA
Text Label 7600 3250 0    60   ~ 0
VMA
Text Label 7600 3350 0    60   ~ 0
~BHE
Text Label 7600 3450 0    60   ~ 0
IPL2
Text Label 7600 3550 0    60   ~ 0
IPL1
Text Label 7600 3650 0    60   ~ 0
IPL0
Wire Wire Line
	9000 8950 8500 8950
Text Label 8600 9050 0    60   ~ 0
~IEO-1
Text Label 8600 8950 0    60   ~ 0
~IEI-1
Wire Wire Line
	8500 5900 9000 5900
Text Label 8600 5900 0    60   ~ 0
-12V
Wire Wire Line
	7500 5900 8000 5900
Text Label 7600 5900 0    60   ~ 0
-12V
Wire Wire Line
	7500 9050 8000 9050
Wire Wire Line
	7500 8350 8000 8350
Wire Wire Line
	7500 8450 8000 8450
Wire Wire Line
	7500 8550 8000 8550
Wire Wire Line
	7500 8650 8000 8650
Wire Wire Line
	7500 8750 8000 8750
Wire Wire Line
	7500 8850 8000 8850
Wire Wire Line
	7500 8950 8000 8950
Text Label 7600 9050 0    60   ~ 0
~EIRQ0
Text Label 7600 8950 0    60   ~ 0
~EIRQ1
Text Label 7600 8850 0    60   ~ 0
~EIRQ2
Text Label 7600 8750 0    60   ~ 0
~EIRQ3
Text Label 7600 8650 0    60   ~ 0
~EIRQ4
Text Label 7600 8550 0    60   ~ 0
~EIRQ5
Text Label 7600 8450 0    60   ~ 0
~EIRQ6
Text Label 7600 8350 0    60   ~ 0
~EIRQ7
Text Label 7600 7250 0    60   ~ 0
~MREQ
Text Label 7600 7150 0    60   ~ 0
~IORQ
Text Label 7600 7550 0    60   ~ 0
CLK
Wire Wire Line
	7500 8150 8000 8150
Wire Wire Line
	7500 7150 8000 7150
Wire Wire Line
	7500 7250 8000 7250
Text Label 7600 8150 0    60   ~ 0
~HALT
Wire Wire Line
	7500 7550 8000 7550
Wire Wire Line
	7500 6950 8000 6950
Wire Wire Line
	7500 7050 8000 7050
Wire Wire Line
	7500 7450 8000 7450
Wire Wire Line
	7500 8250 8000 8250
Wire Wire Line
	7500 7350 8000 7350
Text Label 7600 6950 0    60   ~ 0
~RD
Text Label 7600 7050 0    60   ~ 0
~WR
Text Label 7600 7350 0    60   ~ 0
~M1
Text Label 7600 7450 0    60   ~ 0
~BUSACK
Text Label 7600 8250 0    60   ~ 0
~RFSH
Text Label 7600 7950 0    60   ~ 0
~BUSRQ
Text Label 7600 8050 0    60   ~ 0
~WAIT
Text Label 7600 7850 0    60   ~ 0
~RESET
Wire Wire Line
	7500 7850 8000 7850
Wire Wire Line
	7500 8050 8000 8050
Wire Wire Line
	7500 7950 8000 7950
Wire Wire Line
	7500 6850 8000 6850
Text Label 7600 6850 0    60   ~ 0
VCC
Wire Wire Line
	7500 7650 8000 7650
Wire Wire Line
	7500 7750 8000 7750
Text Label 7600 7650 0    60   ~ 0
~INT0
Text Label 7600 7750 0    60   ~ 0
~NMI
NoConn ~ 9000 1450
NoConn ~ 9000 1550
NoConn ~ 9000 1650
NoConn ~ 9000 1750
NoConn ~ 9000 1850
NoConn ~ 9000 1950
NoConn ~ 9000 2050
NoConn ~ 9000 2150
NoConn ~ 9000 2250
NoConn ~ 9000 2350
NoConn ~ 9000 2450
NoConn ~ 9000 2550
NoConn ~ 9000 2650
NoConn ~ 9000 2750
NoConn ~ 9000 2850
NoConn ~ 9000 2950
NoConn ~ 9000 3050
NoConn ~ 9000 3150
NoConn ~ 9000 3250
NoConn ~ 9000 3350
NoConn ~ 9000 3450
NoConn ~ 9000 3550
NoConn ~ 9000 3650
NoConn ~ 9000 6400
NoConn ~ 9000 5200
NoConn ~ 9000 5100
NoConn ~ 9000 4900
NoConn ~ 9000 4800
NoConn ~ 9000 4700
NoConn ~ 9000 4600
NoConn ~ 9000 4500
NoConn ~ 9000 4400
NoConn ~ 9000 4300
NoConn ~ 9000 4200
NoConn ~ 9000 9150
NoConn ~ 9000 8650
NoConn ~ 9000 8550
NoConn ~ 9000 8450
NoConn ~ 9000 8350
NoConn ~ 9000 8250
NoConn ~ 9000 8150
NoConn ~ 9000 8050
NoConn ~ 9000 7950
NoConn ~ 9000 7850
NoConn ~ 9000 7750
NoConn ~ 9000 7650
NoConn ~ 9000 7550
NoConn ~ 9000 7450
NoConn ~ 9000 7350
NoConn ~ 9000 7250
NoConn ~ 9000 7150
NoConn ~ 9000 7050
NoConn ~ 9000 6950
Text GLabel 9000 5800 2    40   Input ~ 0
A16
Text GLabel 9000 5700 2    40   Input ~ 0
A17
Text GLabel 9000 5600 2    40   Input ~ 0
A18
Text GLabel 9000 5500 2    40   Input ~ 0
A19
Text GLabel 9000 5400 2    40   Input ~ 0
A20
Text GLabel 9000 5300 2    40   Input ~ 0
A21
NoConn ~ 7500 9150
Text Label 8600 6400 0    60   ~ 0
AUXCLK0
NoConn ~ 7500 6000
NoConn ~ 7500 6100
NoConn ~ 7500 6200
NoConn ~ 7500 6300
NoConn ~ 7500 6400
NoConn ~ 7500 7450
NoConn ~ 7500 7550
NoConn ~ 7500 7650
NoConn ~ 7500 7750
NoConn ~ 7500 7950
NoConn ~ 7500 8050
NoConn ~ 7500 8150
NoConn ~ 7500 8250
NoConn ~ 7500 8350
NoConn ~ 7500 8450
NoConn ~ 7500 8550
NoConn ~ 7500 8650
NoConn ~ 7500 8750
NoConn ~ 7500 8850
NoConn ~ 7500 8950
NoConn ~ 7500 9050
NoConn ~ 9000 6000
NoConn ~ 9000 6100
NoConn ~ 9000 6200
NoConn ~ 9000 6300
$EndSCHEMATC
