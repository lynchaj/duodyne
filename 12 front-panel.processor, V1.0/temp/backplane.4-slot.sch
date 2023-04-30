EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr B 17000 11000
encoding utf-8
Sheet 1 1
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
L conn:CONN_02X25 J1
U 1 1 63E7B556
P 11400 7750
F 0 "J1" H 11400 9165 50  0000 C CNN
F 1 "CONN_02X25" H 11400 9074 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 11400 7000 50  0001 C CNN
F 3 "" H 11400 7000 50  0001 C CNN
	1    11400 7750
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 J2
U 1 1 63E80EC4
P 11400 5000
F 0 "J2" H 11400 6415 50  0000 C CNN
F 1 "CONN_02X25" H 11400 6324 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 11400 4250 50  0001 C CNN
F 3 "" H 11400 4250 50  0001 C CNN
	1    11400 5000
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 J3
U 1 1 63E880F1
P 11400 2250
F 0 "J3" H 11400 3665 50  0000 C CNN
F 1 "CONN_02X25" H 11400 3574 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 11400 1500 50  0001 C CNN
F 3 "" H 11400 1500 50  0001 C CNN
	1    11400 2250
	1    0    0    -1  
$EndComp
$Comp
L mechanical:MountingHole_Pad H1
U 1 1 63EA844F
P 3050 9750
F 0 "H1" H 3150 9796 50  0000 L CNN
F 1 "MountingHole" H 3150 9705 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 3050 9750 50  0001 C CNN
F 3 "~" H 3050 9750 50  0001 C CNN
	1    3050 9750
	1    0    0    -1  
$EndComp
$Comp
L mechanical:MountingHole_Pad H2
U 1 1 63EAB760
P 3050 10050
F 0 "H2" H 3150 10096 50  0000 L CNN
F 1 "MountingHole" H 3150 10005 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 3050 10050 50  0001 C CNN
F 3 "~" H 3050 10050 50  0001 C CNN
	1    3050 10050
	1    0    0    -1  
$EndComp
Wire Wire Line
	2850 9850 2850 10150
Wire Wire Line
	3050 9850 2850 9850
Wire Wire Line
	3050 10150 2850 10150
Connection ~ 2850 10150
Text Label 10750 4300 0    60   ~ 0
A11
Text Label 10750 4100 0    60   ~ 0
A13
Text Label 10750 4000 0    60   ~ 0
A14
Text Label 10750 3900 0    60   ~ 0
A15
Text Label 10750 4200 0    60   ~ 0
A12
Text Label 10750 2550 0    60   ~ 0
D1
Text Label 10750 2450 0    60   ~ 0
D2
Text Label 10750 2350 0    60   ~ 0
D3
Text Label 10750 2650 0    60   ~ 0
D0
Text Label 10750 2050 0    60   ~ 0
D6
Text Label 10750 1950 0    60   ~ 0
D7
Text Label 10750 2250 0    60   ~ 0
D4
Text Label 11750 6550 0    60   ~ 0
VCC
Wire Wire Line
	10650 4300 11150 4300
Wire Wire Line
	10650 4200 11150 4200
Wire Wire Line
	10650 4100 11150 4100
Wire Wire Line
	10650 4000 11150 4000
Wire Wire Line
	10650 3900 11150 3900
Wire Wire Line
	10650 2650 11150 2650
Wire Wire Line
	10650 2550 11150 2550
Wire Wire Line
	10650 2450 11150 2450
Wire Wire Line
	10650 2350 11150 2350
Wire Wire Line
	10650 2250 11150 2250
Wire Wire Line
	10650 2050 11150 2050
Wire Wire Line
	10650 1950 11150 1950
Wire Wire Line
	11650 6550 12150 6550
Text Label 11750 3800 0    60   ~ 0
VCC
Wire Wire Line
	11650 3800 12150 3800
Text Label 10750 3800 0    60   ~ 0
VCC
Wire Wire Line
	10650 3800 11150 3800
Text Label 11750 1050 0    60   ~ 0
VCC
Wire Wire Line
	11650 1050 12150 1050
Text Label 10750 1050 0    60   ~ 0
VCC
Wire Wire Line
	10650 1050 11150 1050
Text Label 10750 3450 0    60   ~ 0
GND
Wire Wire Line
	10650 3450 11150 3450
Text Label 11750 3450 0    60   ~ 0
GND
Wire Wire Line
	11650 3450 12150 3450
Text Label 10750 6200 0    60   ~ 0
GND
Wire Wire Line
	10650 6200 11150 6200
Text Label 11750 6200 0    60   ~ 0
GND
Wire Wire Line
	11650 6200 12150 6200
Text Label 10750 8950 0    60   ~ 0
GND
Wire Wire Line
	10650 8950 11150 8950
Text Label 11750 8950 0    60   ~ 0
GND
Wire Wire Line
	11650 8950 12150 8950
Wire Wire Line
	10650 4800 11150 4800
Wire Wire Line
	10650 4900 11150 4900
Wire Wire Line
	10650 5000 11150 5000
Wire Wire Line
	10650 5100 11150 5100
Wire Wire Line
	10650 5200 11150 5200
Wire Wire Line
	10650 5300 11150 5300
Wire Wire Line
	10650 5400 11150 5400
Wire Wire Line
	10650 5500 11150 5500
Wire Wire Line
	10650 4400 11150 4400
Wire Wire Line
	10650 4500 11150 4500
Wire Wire Line
	10650 4600 11150 4600
Text Label 10750 5100 0    60   ~ 0
A4
Text Label 10750 4800 0    60   ~ 0
A7
Text Label 10750 4900 0    60   ~ 0
A6
Text Label 10750 5000 0    60   ~ 0
A5
Text Label 10750 5500 0    60   ~ 0
A0
Text Label 10750 5200 0    60   ~ 0
A3
Text Label 10750 5300 0    60   ~ 0
A2
Text Label 10750 5400 0    60   ~ 0
A1
Text Label 10750 4600 0    60   ~ 0
A8
Text Label 10750 4400 0    60   ~ 0
A10
Text Label 10750 4500 0    60   ~ 0
A9
Wire Wire Line
	10650 2150 11150 2150
Text Label 10750 2150 0    60   ~ 0
D5
Wire Wire Line
	12150 8850 11650 8850
Wire Wire Line
	11150 8850 10650 8850
Text Label 12050 8850 2    60   ~ 0
I2C_TX
Text Label 11050 8850 2    60   ~ 0
I2C_RX
Text Label 11750 5300 0    60   ~ 0
A18
Text Label 11750 5400 0    60   ~ 0
A17
Text Label 11750 5500 0    60   ~ 0
A16
Text Label 11750 5200 0    60   ~ 0
A19
Wire Wire Line
	11650 5200 12150 5200
Wire Wire Line
	11650 5300 12150 5300
Wire Wire Line
	11650 5400 12150 5400
Wire Wire Line
	11650 5500 12150 5500
Wire Wire Line
	11150 3250 10650 3250
Wire Wire Line
	11650 7250 12150 7250
Wire Wire Line
	11650 7350 12150 7350
Wire Wire Line
	11150 5700 10650 5700
Wire Wire Line
	11150 5800 10650 5800
Wire Wire Line
	11150 2850 10650 2850
Wire Wire Line
	11150 3150 10650 3150
Wire Wire Line
	11150 3050 10650 3050
Wire Wire Line
	11150 2950 10650 2950
Wire Wire Line
	12150 7150 11650 7150
Wire Wire Line
	11150 6000 10650 6000
Wire Wire Line
	11150 5900 10650 5900
Wire Wire Line
	11150 2750 10650 2750
Wire Wire Line
	11150 3350 10650 3350
Text Label 11750 4900 0    60   ~ 0
A22
Text Label 11750 5000 0    60   ~ 0
A21
Text Label 11750 5100 0    60   ~ 0
A20
Text Label 11750 4800 0    60   ~ 0
A23
Wire Wire Line
	11650 4800 12150 4800
Wire Wire Line
	11650 4900 12150 4900
Wire Wire Line
	11650 5000 12150 5000
Wire Wire Line
	11650 5100 12150 5100
Text Label 11750 4500 0    60   ~ 0
A25
Text Label 11750 4400 0    60   ~ 0
A26
Text Label 11750 4600 0    60   ~ 0
A24
Wire Wire Line
	11650 4600 12150 4600
Wire Wire Line
	11650 4500 12150 4500
Wire Wire Line
	11650 4400 12150 4400
Wire Wire Line
	11650 3900 12150 3900
Wire Wire Line
	11650 4000 12150 4000
Wire Wire Line
	11650 4100 12150 4100
Wire Wire Line
	11650 4200 12150 4200
Wire Wire Line
	11650 4300 12150 4300
Text Label 11750 4200 0    60   ~ 0
A28
Text Label 11750 3900 0    60   ~ 0
A31
Text Label 11750 4000 0    60   ~ 0
A30
Text Label 11750 4100 0    60   ~ 0
A29
Text Label 11750 4300 0    60   ~ 0
A27
Wire Wire Line
	11650 2850 12150 2850
Wire Wire Line
	11650 2950 12150 2950
Wire Wire Line
	11650 3050 12150 3050
Wire Wire Line
	11650 2750 12150 2750
Wire Wire Line
	11650 3150 12150 3150
Text Label 10750 1750 0    60   ~ 0
D9
Text Label 10750 1650 0    60   ~ 0
D10
Text Label 10750 1550 0    60   ~ 0
D11
Text Label 10750 1850 0    60   ~ 0
D8
Text Label 10750 1250 0    60   ~ 0
D14
Text Label 10750 1150 0    60   ~ 0
D15
Text Label 10750 1450 0    60   ~ 0
D12
Wire Wire Line
	10650 1850 11150 1850
Wire Wire Line
	10650 1750 11150 1750
Wire Wire Line
	10650 1650 11150 1650
Wire Wire Line
	10650 1550 11150 1550
Wire Wire Line
	10650 1450 11150 1450
Wire Wire Line
	10650 1250 11150 1250
Wire Wire Line
	10650 1150 11150 1150
Wire Wire Line
	10650 1350 11150 1350
Text Label 10750 1350 0    60   ~ 0
D13
$Comp
L device:LED D5
U 1 1 66EF3CB3
P 2100 9950
F 0 "D5" H 2100 10050 50  0000 C CNN
F 1 "LED" H 2100 9850 50  0000 C CNN
F 2 "LED_THT:LED_D3.0mm" H 2100 9950 60  0001 C CNN
F 3 "" H 2100 9950 60  0001 C CNN
	1    2100 9950
	0    -1   -1   0   
$EndComp
$Comp
L device:R R6
U 1 1 603A596D
P 2100 9500
F 0 "R6" V 2180 9500 50  0000 C CNN
F 1 "470" V 2100 9500 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 2100 9500 60  0001 C CNN
F 3 "" H 2100 9500 60  0001 C CNN
	1    2100 9500
	1    0    0    -1  
$EndComp
Wire Wire Line
	2100 10100 2100 10150
Wire Wire Line
	2850 10150 2550 10150
Text Label 11750 4700 0    60   ~ 0
+12V
Wire Wire Line
	11650 4700 12150 4700
Text Label 10750 4700 0    60   ~ 0
+12V
Text Label 11750 2550 0    60   ~ 0
D17
Text Label 11750 2450 0    60   ~ 0
D18
Text Label 11750 2350 0    60   ~ 0
D19
Text Label 11750 2650 0    60   ~ 0
D16
Text Label 11750 2050 0    60   ~ 0
D22
Text Label 11750 1950 0    60   ~ 0
D23
Text Label 11750 2250 0    60   ~ 0
D20
Wire Wire Line
	11650 2650 12150 2650
Wire Wire Line
	11650 2550 12150 2550
Wire Wire Line
	11650 2450 12150 2450
Wire Wire Line
	11650 2350 12150 2350
Wire Wire Line
	11650 2250 12150 2250
Wire Wire Line
	11650 2050 12150 2050
Wire Wire Line
	11650 1950 12150 1950
Wire Wire Line
	11650 2150 12150 2150
Text Label 11750 2150 0    60   ~ 0
D21
Text Label 11750 1750 0    60   ~ 0
D25
Text Label 11750 1650 0    60   ~ 0
D26
Text Label 11750 1550 0    60   ~ 0
D27
Text Label 11750 1850 0    60   ~ 0
D24
Text Label 11750 1250 0    60   ~ 0
D30
Text Label 11750 1150 0    60   ~ 0
D31
Text Label 11750 1450 0    60   ~ 0
D28
Wire Wire Line
	11650 1850 12150 1850
Wire Wire Line
	11650 1750 12150 1750
Wire Wire Line
	11650 1650 12150 1650
Wire Wire Line
	11650 1550 12150 1550
Wire Wire Line
	11650 1450 12150 1450
Wire Wire Line
	11650 1250 12150 1250
Wire Wire Line
	11650 1150 12150 1150
Wire Wire Line
	11650 1350 12150 1350
Text Label 11750 1350 0    60   ~ 0
D29
Wire Wire Line
	10650 4700 11150 4700
Text Label 11750 8250 0    60   ~ 0
USER1
Text Label 11750 8350 0    60   ~ 0
USER0
Text Label 11750 8150 0    60   ~ 0
USER2
Wire Wire Line
	11650 8150 12150 8150
Wire Wire Line
	11650 8250 12150 8250
Wire Wire Line
	11650 8350 12150 8350
Text Label 11750 7950 0    60   ~ 0
USER4
Text Label 11750 8050 0    60   ~ 0
USER3
Text Label 11750 7850 0    60   ~ 0
USER5
Wire Wire Line
	11650 7850 12150 7850
Wire Wire Line
	11650 7950 12150 7950
Wire Wire Line
	11650 8050 12150 8050
Text Label 11750 7750 0    60   ~ 0
USER6
Text Label 11750 7550 0    60   ~ 0
USER8
Wire Wire Line
	11650 7550 12150 7550
Wire Wire Line
	11650 7650 12150 7650
Wire Wire Line
	11650 7750 12150 7750
Text Label 11750 7450 0    60   ~ 0
USER9
Wire Wire Line
	11650 7450 12150 7450
Text Label 11750 7650 0    60   ~ 0
USER7
Text Label 5650 9650 0    60   ~ 0
+12V
Wire Wire Line
	5600 9650 6100 9650
Text Label 5650 10000 0    60   ~ 0
-12V
$Comp
L conn:CONN_02X25 J6
U 1 1 643EA1F1
P 9450 2250
F 0 "J6" H 9450 3665 50  0000 C CNN
F 1 "CONN_02X25" H 9450 3574 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 9450 1500 50  0001 C CNN
F 3 "" H 9450 1500 50  0001 C CNN
	1    9450 2250
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 J5
U 1 1 643EA1E7
P 9450 5000
F 0 "J5" H 9450 6415 50  0000 C CNN
F 1 "CONN_02X25" H 9450 6324 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 9450 4250 50  0001 C CNN
F 3 "" H 9450 4250 50  0001 C CNN
	1    9450 5000
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 J4
U 1 1 643EA1DD
P 9450 7750
F 0 "J4" H 9450 9165 50  0000 C CNN
F 1 "CONN_02X25" H 9450 9074 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 9450 7000 50  0001 C CNN
F 3 "" H 9450 7000 50  0001 C CNN
	1    9450 7750
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 J9
U 1 1 643E8FB1
P 7500 2250
F 0 "J9" H 7500 3665 50  0000 C CNN
F 1 "CONN_02X25" H 7500 3574 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 7500 1500 50  0001 C CNN
F 3 "" H 7500 1500 50  0001 C CNN
	1    7500 2250
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 J8
U 1 1 643E8FA7
P 7500 5000
F 0 "J8" H 7500 6415 50  0000 C CNN
F 1 "CONN_02X25" H 7500 6324 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 7500 4250 50  0001 C CNN
F 3 "" H 7500 4250 50  0001 C CNN
	1    7500 5000
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 J7
U 1 1 643E8F9D
P 7500 7750
F 0 "J7" H 7500 9165 50  0000 C CNN
F 1 "CONN_02X25" H 7500 9074 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 7500 7000 50  0001 C CNN
F 3 "" H 7500 7000 50  0001 C CNN
	1    7500 7750
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 J12
U 1 1 643E8E2D
P 5550 2250
F 0 "J12" H 5550 3665 50  0000 C CNN
F 1 "CONN_02X25" H 5550 3574 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 5550 1500 50  0001 C CNN
F 3 "" H 5550 1500 50  0001 C CNN
	1    5550 2250
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 J11
U 1 1 643E8E23
P 5550 5000
F 0 "J11" H 5550 6415 50  0000 C CNN
F 1 "CONN_02X25" H 5550 6324 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 5550 4250 50  0001 C CNN
F 3 "" H 5550 4250 50  0001 C CNN
	1    5550 5000
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 J10
U 1 1 643E8E19
P 5550 7750
F 0 "J10" H 5550 9165 50  0000 C CNN
F 1 "CONN_02X25" H 5550 9074 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x25_P2.54mm_Vertical" H 5550 7000 50  0001 C CNN
F 3 "" H 5550 7000 50  0001 C CNN
	1    5550 7750
	1    0    0    -1  
$EndComp
Text Label 11750 3150 0    60   ~ 0
S0
Text Label 11750 3050 0    60   ~ 0
S1
Text Label 11750 2950 0    60   ~ 0
S2
Text Label 10750 6000 0    60   ~ 0
IC0
Text Label 10750 5900 0    60   ~ 0
IC1
Text Label 10750 5800 0    60   ~ 0
IC2
Text Label 10750 5700 0    60   ~ 0
IC3
Text Label 11750 7350 0    60   ~ 0
CRUIN
Text Label 11750 7250 0    60   ~ 0
CRUOUT
Text Label 11750 7150 0    60   ~ 0
CRYCCLK
Text Label 11750 6650 0    60   ~ 0
E
Wire Wire Line
	12150 7050 11650 7050
Wire Wire Line
	12150 6950 11650 6950
Wire Wire Line
	11650 5700 12150 5700
Wire Wire Line
	11650 5800 12150 5800
Wire Wire Line
	12150 6850 11650 6850
Wire Wire Line
	12150 6750 11650 6750
Wire Wire Line
	12150 6650 11650 6650
Text Label 11750 5800 0    60   ~ 0
~DREQ1
Text Label 11750 7050 0    60   ~ 0
~INT1
Text Label 11750 6950 0    60   ~ 0
~INT2
Text Label 11750 5700 0    60   ~ 0
~TEND1
Text Label 11750 6850 0    60   ~ 0
PHI
Text Label 11750 6750 0    60   ~ 0
ST
Text Label 11750 5900 0    60   ~ 0
~TEND0
Wire Wire Line
	11650 5900 12150 5900
Text Label 11750 6000 0    60   ~ 0
~DREQ0
Wire Wire Line
	11650 6000 12150 6000
Text Label 11750 3250 0    60   ~ 0
AUXCLK3
Text Label 11750 3350 0    60   ~ 0
AUXCLK2
Text Label 10750 6100 0    60   ~ 0
AUXCLK1
Text Label 11750 6100 0    60   ~ 0
AUXCLK0
Wire Wire Line
	12150 3250 11650 3250
Wire Wire Line
	10650 6100 11150 6100
Wire Wire Line
	11650 3350 12150 3350
Wire Wire Line
	11650 6100 12150 6100
Wire Wire Line
	12150 8750 11650 8750
Text Label 11750 8550 0    60   ~ 0
~BAO-1
Wire Wire Line
	12150 8550 11650 8550
Text Label 11750 8450 0    60   ~ 0
~BAI-1
Wire Wire Line
	12150 8450 11650 8450
$Comp
L mechanical:MountingHole_Pad H3
U 1 1 6985C0F8
P 3900 9750
F 0 "H3" H 4000 9796 50  0000 L CNN
F 1 "MountingHole" H 4000 9705 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 3900 9750 50  0001 C CNN
F 3 "~" H 3900 9750 50  0001 C CNN
	1    3900 9750
	1    0    0    -1  
$EndComp
$Comp
L mechanical:MountingHole_Pad H4
U 1 1 6985C102
P 3900 10050
F 0 "H4" H 4000 10096 50  0000 L CNN
F 1 "MountingHole" H 4000 10005 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 3900 10050 50  0001 C CNN
F 3 "~" H 3900 10050 50  0001 C CNN
	1    3900 10050
	1    0    0    -1  
$EndComp
Wire Wire Line
	3700 9850 3700 10150
Wire Wire Line
	3900 9850 3700 9850
Wire Wire Line
	3900 10150 3700 10150
Connection ~ 3700 10150
Wire Wire Line
	3050 10150 3700 10150
Connection ~ 3050 10150
Wire Wire Line
	2100 9650 2100 9800
$Comp
L power:VCC #PWR0101
U 1 1 69A9E9AA
P 2100 9350
F 0 "#PWR0101" H 2100 9200 50  0001 C CNN
F 1 "VCC" H 2115 9523 50  0000 C CNN
F 2 "" H 2100 9350 50  0001 C CNN
F 3 "" H 2100 9350 50  0001 C CNN
	1    2100 9350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0102
U 1 1 69A9F763
P 2100 10150
F 0 "#PWR0102" H 2100 9900 50  0001 C CNN
F 1 "GND" H 2105 9977 50  0000 C CNN
F 2 "" H 2100 10150 50  0001 C CNN
F 3 "" H 2100 10150 50  0001 C CNN
	1    2100 10150
	1    0    0    -1  
$EndComp
Connection ~ 2100 10150
$Comp
L conn:Screw_Terminal_1x02 T1
U 1 1 63F221C6
P 1300 10050
F 0 "T1" H 1382 10392 50  0000 C CNN
F 1 "Screw_Terminal_1x02" H 1382 10301 50  0000 C CNN
F 2 "TerminalBlock_Phoenix:TerminalBlock_Phoenix_MKDS-1,5-2-5.08_1x02_P5.08mm_Horizontal" H 1300 9825 50  0001 C CNN
F 3 "" H 1275 10050 50  0001 C CNN
	1    1300 10050
	1    0    0    -1  
$EndComp
Wire Wire Line
	1500 9950 1800 9950
Wire Wire Line
	1800 9950 1800 9350
Wire Wire Line
	1800 9350 2100 9350
Connection ~ 2100 9350
Wire Wire Line
	2550 10150 2100 10150
$Comp
L power:PWR_FLAG #FLG01
U 1 1 6AD1A104
P 2550 9350
F 0 "#FLG01" H 2550 9425 50  0001 C CNN
F 1 "PWR_FLAG" H 2550 9523 50  0000 C CNN
F 2 "" H 2550 9350 50  0001 C CNN
F 3 "~" H 2550 9350 50  0001 C CNN
	1    2550 9350
	1    0    0    -1  
$EndComp
Wire Wire Line
	2100 9350 2550 9350
Wire Wire Line
	1500 10150 2100 10150
$Comp
L power:PWR_FLAG #FLG02
U 1 1 6AD2C6BE
P 2550 10150
F 0 "#FLG02" H 2550 10225 50  0001 C CNN
F 1 "PWR_FLAG" H 2550 10323 50  0000 C CNN
F 2 "" H 2550 10150 50  0001 C CNN
F 3 "~" H 2550 10150 50  0001 C CNN
	1    2550 10150
	1    0    0    -1  
$EndComp
$Comp
L conn:Screw_Terminal_1x02 T2
U 1 1 6AD35C27
P 5050 9900
F 0 "T2" H 5132 10242 50  0000 C CNN
F 1 "Screw_Terminal_1x02" H 5132 10151 50  0000 C CNN
F 2 "TerminalBlock_Phoenix:TerminalBlock_Phoenix_MKDS-1,5-2-5.08_1x02_P5.08mm_Horizontal" H 5050 9675 50  0001 C CNN
F 3 "" H 5025 9900 50  0001 C CNN
	1    5050 9900
	1    0    0    -1  
$EndComp
Wire Wire Line
	5250 10000 6100 10000
Wire Wire Line
	5250 9800 5600 9800
Wire Wire Line
	5600 9800 5600 9650
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 6AD8E5EB
P 6100 9650
F 0 "#FLG0101" H 6100 9725 50  0001 C CNN
F 1 "PWR_FLAG" H 6100 9823 50  0000 C CNN
F 2 "" H 6100 9650 50  0001 C CNN
F 3 "~" H 6100 9650 50  0001 C CNN
	1    6100 9650
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 6AD91473
P 6100 10000
F 0 "#FLG0102" H 6100 10075 50  0001 C CNN
F 1 "PWR_FLAG" H 6100 10173 50  0000 C CNN
F 2 "" H 6100 10000 50  0001 C CNN
F 3 "~" H 6100 10000 50  0001 C CNN
	1    6100 10000
	1    0    0    -1  
$EndComp
Connection ~ 2550 10150
$Comp
L conn:CONN_01X04 P1
U 1 1 61844E6F
P 11750 10250
F 0 "P1" H 11828 10291 50  0000 L CNN
F 1 "INT-CHN" H 11828 10200 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x04_P2.54mm_Vertical" H 11750 10250 50  0001 C CNN
F 3 "" H 11750 10250 50  0001 C CNN
	1    11750 10250
	1    0    0    1   
$EndComp
Wire Wire Line
	11050 10100 11550 10100
Text Label 11150 10100 0    60   ~ 0
~BAI-1
Wire Wire Line
	11050 10200 11550 10200
Text Label 11150 10300 0    60   ~ 0
~IEI-1
Text Label 11150 10400 0    60   ~ 0
~IEO-2
Wire Wire Line
	11050 10400 11550 10400
Text Label 11150 10200 0    60   ~ 0
~BAO-2
Wire Wire Line
	11050 10300 11550 10300
$Comp
L conn:CONN_01X04 P2
U 1 1 61F6A0F6
P 10500 10200
F 0 "P2" H 10578 10241 50  0000 L CNN
F 1 "INT-CHN" H 10578 10150 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x04_P2.54mm_Vertical" H 10500 10200 50  0001 C CNN
F 3 "" H 10500 10200 50  0001 C CNN
	1    10500 10200
	1    0    0    1   
$EndComp
Wire Wire Line
	9800 10050 10300 10050
Text Label 9900 10050 0    60   ~ 0
~BAI-2
Wire Wire Line
	9800 10150 10300 10150
Text Label 9900 10250 0    60   ~ 0
~IEI-2
Text Label 9900 10350 0    60   ~ 0
~IEO-3
Wire Wire Line
	9800 10350 10300 10350
Text Label 9900 10150 0    60   ~ 0
~BAO-3
Wire Wire Line
	9800 10250 10300 10250
$Comp
L conn:CONN_01X04 P3
U 1 1 61AFFACF
P 9250 10200
F 0 "P3" H 9328 10241 50  0000 L CNN
F 1 "INT-CHN" H 9328 10150 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x04_P2.54mm_Vertical" H 9250 10200 50  0001 C CNN
F 3 "" H 9250 10200 50  0001 C CNN
	1    9250 10200
	1    0    0    1   
$EndComp
Wire Wire Line
	8550 10050 9050 10050
Text Label 8650 10050 0    60   ~ 0
~BAI-3
Wire Wire Line
	8550 10150 9050 10150
Text Label 8650 10250 0    60   ~ 0
~IEI-3
Text Label 8650 10350 0    60   ~ 0
~IEO-4
Wire Wire Line
	8550 10350 9050 10350
Text Label 8650 10150 0    60   ~ 0
~BAO-4
Wire Wire Line
	8550 10250 9050 10250
Text Notes 9550 9800 0    60   ~ 0
Zilog Interrupt Priority Bus Jumpers
Text Label 11750 2750 0    60   ~ 0
UDS
Text Label 11750 2850 0    60   ~ 0
LDS
Text Label 10750 2750 0    60   ~ 0
BUSERR
Text Label 10750 2850 0    60   ~ 0
VPA
Text Label 10750 2950 0    60   ~ 0
VMA
Text Label 10750 3050 0    60   ~ 0
~BHE
Text Label 10750 3150 0    60   ~ 0
IPL2
Text Label 10750 3250 0    60   ~ 0
IPL1
Text Label 10750 3350 0    60   ~ 0
IPL0
Wire Wire Line
	12150 8650 11650 8650
Text Label 11750 8750 0    60   ~ 0
~IEO-1
Text Label 11750 8650 0    60   ~ 0
~IEI-1
Wire Wire Line
	11650 5600 12150 5600
Text Label 11750 5600 0    60   ~ 0
-12V
Wire Wire Line
	10650 5600 11150 5600
Text Label 10750 5600 0    60   ~ 0
-12V
Wire Wire Line
	10650 8750 11150 8750
Wire Wire Line
	10650 8050 11150 8050
Wire Wire Line
	10650 8150 11150 8150
Wire Wire Line
	10650 8250 11150 8250
Wire Wire Line
	10650 8350 11150 8350
Wire Wire Line
	10650 8450 11150 8450
Wire Wire Line
	10650 8550 11150 8550
Wire Wire Line
	10650 8650 11150 8650
Text Label 10750 8750 0    60   ~ 0
~EIRQ0
Text Label 10750 8650 0    60   ~ 0
~EIRQ1
Text Label 10750 8550 0    60   ~ 0
~EIRQ2
Text Label 10750 8450 0    60   ~ 0
~EIRQ3
Text Label 10750 8350 0    60   ~ 0
~EIRQ4
Text Label 10750 8250 0    60   ~ 0
~EIRQ5
Text Label 10750 8150 0    60   ~ 0
~EIRQ6
Text Label 10750 8050 0    60   ~ 0
~EIRQ7
Text Label 10750 6950 0    60   ~ 0
~MREQ
Text Label 10750 6850 0    60   ~ 0
~IORQ
Text Label 10750 7250 0    60   ~ 0
CLK
Wire Wire Line
	10650 7850 11150 7850
Wire Wire Line
	10650 6850 11150 6850
Wire Wire Line
	10650 6950 11150 6950
Text Label 10750 7850 0    60   ~ 0
~HALT
Wire Wire Line
	10650 7250 11150 7250
Wire Wire Line
	10650 6650 11150 6650
Wire Wire Line
	10650 6750 11150 6750
Wire Wire Line
	10650 7150 11150 7150
Wire Wire Line
	10650 7950 11150 7950
Wire Wire Line
	10650 7050 11150 7050
Text Label 10750 6650 0    60   ~ 0
~RD
Text Label 10750 6750 0    60   ~ 0
~WR
Text Label 10750 7050 0    60   ~ 0
~M1
Text Label 10750 7150 0    60   ~ 0
~BUSACK
Text Label 10750 7950 0    60   ~ 0
~RFSH
Text Label 10750 7650 0    60   ~ 0
~BUSRQ
Text Label 10750 7750 0    60   ~ 0
~WAIT
Text Label 10750 7550 0    60   ~ 0
~RESET
Wire Wire Line
	10650 7550 11150 7550
Wire Wire Line
	10650 7750 11150 7750
Wire Wire Line
	10650 7650 11150 7650
Wire Wire Line
	10650 6550 11150 6550
Text Label 10750 6550 0    60   ~ 0
VCC
Wire Wire Line
	10650 7350 11150 7350
Wire Wire Line
	10650 7450 11150 7450
Text Label 10750 7350 0    60   ~ 0
~INT0
Text Label 10750 7450 0    60   ~ 0
~NMI
Text Label 9800 6650 0    60   ~ 0
E
NoConn ~ 12150 8550
NoConn ~ 12150 8750
Text Label 8800 4300 0    60   ~ 0
A11
Text Label 8800 4100 0    60   ~ 0
A13
Text Label 8800 4000 0    60   ~ 0
A14
Text Label 8800 3900 0    60   ~ 0
A15
Text Label 8800 4200 0    60   ~ 0
A12
Text Label 8800 2550 0    60   ~ 0
D1
Text Label 8800 2450 0    60   ~ 0
D2
Text Label 8800 2350 0    60   ~ 0
D3
Text Label 8800 2650 0    60   ~ 0
D0
Text Label 8800 2050 0    60   ~ 0
D6
Text Label 8800 1950 0    60   ~ 0
D7
Text Label 8800 2250 0    60   ~ 0
D4
Wire Wire Line
	8700 4300 9200 4300
Wire Wire Line
	8700 4200 9200 4200
Wire Wire Line
	8700 4100 9200 4100
Wire Wire Line
	8700 4000 9200 4000
Wire Wire Line
	8700 3900 9200 3900
Wire Wire Line
	8700 2650 9200 2650
Wire Wire Line
	8700 2550 9200 2550
Wire Wire Line
	8700 2450 9200 2450
Wire Wire Line
	8700 2350 9200 2350
Wire Wire Line
	8700 2250 9200 2250
Wire Wire Line
	8700 2050 9200 2050
Wire Wire Line
	8700 1950 9200 1950
Text Label 8800 3800 0    60   ~ 0
VCC
Wire Wire Line
	8700 3800 9200 3800
Text Label 8800 1050 0    60   ~ 0
VCC
Wire Wire Line
	8700 1050 9200 1050
Text Label 8800 3450 0    60   ~ 0
GND
Wire Wire Line
	8700 3450 9200 3450
Text Label 8800 6200 0    60   ~ 0
GND
Wire Wire Line
	8700 6200 9200 6200
Text Label 8800 8950 0    60   ~ 0
GND
Wire Wire Line
	8700 8950 9200 8950
Wire Wire Line
	8700 4800 9200 4800
Wire Wire Line
	8700 4900 9200 4900
Wire Wire Line
	8700 5000 9200 5000
Wire Wire Line
	8700 5100 9200 5100
Wire Wire Line
	8700 5200 9200 5200
Wire Wire Line
	8700 5300 9200 5300
Wire Wire Line
	8700 5400 9200 5400
Wire Wire Line
	8700 5500 9200 5500
Wire Wire Line
	8700 4400 9200 4400
Wire Wire Line
	8700 4500 9200 4500
Wire Wire Line
	8700 4600 9200 4600
Text Label 8800 5100 0    60   ~ 0
A4
Text Label 8800 4800 0    60   ~ 0
A7
Text Label 8800 4900 0    60   ~ 0
A6
Text Label 8800 5000 0    60   ~ 0
A5
Text Label 8800 5500 0    60   ~ 0
A0
Text Label 8800 5200 0    60   ~ 0
A3
Text Label 8800 5300 0    60   ~ 0
A2
Text Label 8800 5400 0    60   ~ 0
A1
Text Label 8800 4600 0    60   ~ 0
A8
Text Label 8800 4400 0    60   ~ 0
A10
Text Label 8800 4500 0    60   ~ 0
A9
Wire Wire Line
	8700 2150 9200 2150
Text Label 8800 2150 0    60   ~ 0
D5
Wire Wire Line
	9200 8850 8700 8850
Text Label 9100 8850 2    60   ~ 0
I2C_RX
Wire Wire Line
	9200 3250 8700 3250
Wire Wire Line
	9200 5700 8700 5700
Wire Wire Line
	9200 5800 8700 5800
Wire Wire Line
	9200 2850 8700 2850
Wire Wire Line
	9200 3150 8700 3150
Wire Wire Line
	9200 3050 8700 3050
Wire Wire Line
	9200 2950 8700 2950
Wire Wire Line
	9200 6000 8700 6000
Wire Wire Line
	9200 5900 8700 5900
Wire Wire Line
	9200 2750 8700 2750
Wire Wire Line
	9200 3350 8700 3350
Text Label 8800 1750 0    60   ~ 0
D9
Text Label 8800 1650 0    60   ~ 0
D10
Text Label 8800 1550 0    60   ~ 0
D11
Text Label 8800 1850 0    60   ~ 0
D8
Text Label 8800 1250 0    60   ~ 0
D14
Text Label 8800 1150 0    60   ~ 0
D15
Text Label 8800 1450 0    60   ~ 0
D12
Wire Wire Line
	8700 1850 9200 1850
Wire Wire Line
	8700 1750 9200 1750
Wire Wire Line
	8700 1650 9200 1650
Wire Wire Line
	8700 1550 9200 1550
Wire Wire Line
	8700 1450 9200 1450
Wire Wire Line
	8700 1250 9200 1250
Wire Wire Line
	8700 1150 9200 1150
Wire Wire Line
	8700 1350 9200 1350
Text Label 8800 1350 0    60   ~ 0
D13
Text Label 8800 4700 0    60   ~ 0
+12V
Wire Wire Line
	8700 4700 9200 4700
Text Label 8800 6000 0    60   ~ 0
IC0
Text Label 8800 5900 0    60   ~ 0
IC1
Text Label 8800 5800 0    60   ~ 0
IC2
Text Label 8800 5700 0    60   ~ 0
IC3
Text Label 8800 6100 0    60   ~ 0
AUXCLK1
Wire Wire Line
	8700 6100 9200 6100
Text Label 8800 2750 0    60   ~ 0
BUSERR
Text Label 8800 2850 0    60   ~ 0
VPA
Text Label 8800 2950 0    60   ~ 0
VMA
Text Label 8800 3050 0    60   ~ 0
~BHE
Text Label 8800 3150 0    60   ~ 0
IPL2
Text Label 8800 3250 0    60   ~ 0
IPL1
Text Label 8800 3350 0    60   ~ 0
IPL0
Wire Wire Line
	8700 5600 9200 5600
Text Label 8800 5600 0    60   ~ 0
-12V
Wire Wire Line
	8700 8750 9200 8750
Wire Wire Line
	8700 8050 9200 8050
Wire Wire Line
	8700 8150 9200 8150
Wire Wire Line
	8700 8250 9200 8250
Wire Wire Line
	8700 8350 9200 8350
Wire Wire Line
	8700 8450 9200 8450
Wire Wire Line
	8700 8550 9200 8550
Wire Wire Line
	8700 8650 9200 8650
Text Label 8800 8750 0    60   ~ 0
~EIRQ0
Text Label 8800 8650 0    60   ~ 0
~EIRQ1
Text Label 8800 8550 0    60   ~ 0
~EIRQ2
Text Label 8800 8450 0    60   ~ 0
~EIRQ3
Text Label 8800 8350 0    60   ~ 0
~EIRQ4
Text Label 8800 8250 0    60   ~ 0
~EIRQ5
Text Label 8800 8150 0    60   ~ 0
~EIRQ6
Text Label 8800 8050 0    60   ~ 0
~EIRQ7
Text Label 8800 6950 0    60   ~ 0
~MREQ
Text Label 8800 6850 0    60   ~ 0
~IORQ
Text Label 8800 7250 0    60   ~ 0
CLK
Wire Wire Line
	8700 7850 9200 7850
Wire Wire Line
	8700 6850 9200 6850
Wire Wire Line
	8700 6950 9200 6950
Text Label 8800 7850 0    60   ~ 0
~HALT
Wire Wire Line
	8700 7250 9200 7250
Wire Wire Line
	8700 6650 9200 6650
Wire Wire Line
	8700 6750 9200 6750
Wire Wire Line
	8700 7150 9200 7150
Wire Wire Line
	8700 7950 9200 7950
Wire Wire Line
	8700 7050 9200 7050
Text Label 8800 6650 0    60   ~ 0
~RD
Text Label 8800 6750 0    60   ~ 0
~WR
Text Label 8800 7050 0    60   ~ 0
~M1
Text Label 8800 7150 0    60   ~ 0
~BUSACK
Text Label 8800 7950 0    60   ~ 0
~RFSH
Text Label 8800 7650 0    60   ~ 0
~BUSRQ
Text Label 8800 7750 0    60   ~ 0
~WAIT
Text Label 8800 7550 0    60   ~ 0
~RESET
Wire Wire Line
	8700 7550 9200 7550
Wire Wire Line
	8700 7750 9200 7750
Wire Wire Line
	8700 7650 9200 7650
Wire Wire Line
	8700 6550 9200 6550
Text Label 8800 6550 0    60   ~ 0
VCC
Wire Wire Line
	8700 7350 9200 7350
Wire Wire Line
	8700 7450 9200 7450
Text Label 8800 7350 0    60   ~ 0
~INT0
Text Label 8800 7450 0    60   ~ 0
~NMI
Text Label 6850 4300 0    60   ~ 0
A11
Text Label 6850 4100 0    60   ~ 0
A13
Text Label 6850 4000 0    60   ~ 0
A14
Text Label 6850 3900 0    60   ~ 0
A15
Text Label 6850 4200 0    60   ~ 0
A12
Text Label 6850 2550 0    60   ~ 0
D1
Text Label 6850 2450 0    60   ~ 0
D2
Text Label 6850 2350 0    60   ~ 0
D3
Text Label 6850 2650 0    60   ~ 0
D0
Text Label 6850 2050 0    60   ~ 0
D6
Text Label 6850 1950 0    60   ~ 0
D7
Text Label 6850 2250 0    60   ~ 0
D4
Wire Wire Line
	6750 4300 7250 4300
Wire Wire Line
	6750 4200 7250 4200
Wire Wire Line
	6750 4100 7250 4100
Wire Wire Line
	6750 4000 7250 4000
Wire Wire Line
	6750 3900 7250 3900
Wire Wire Line
	6750 2650 7250 2650
Wire Wire Line
	6750 2550 7250 2550
Wire Wire Line
	6750 2450 7250 2450
Wire Wire Line
	6750 2350 7250 2350
Wire Wire Line
	6750 2250 7250 2250
Wire Wire Line
	6750 2050 7250 2050
Wire Wire Line
	6750 1950 7250 1950
Text Label 6850 3800 0    60   ~ 0
VCC
Wire Wire Line
	6750 3800 7250 3800
Text Label 6850 1050 0    60   ~ 0
VCC
Wire Wire Line
	6750 1050 7250 1050
Text Label 6850 3450 0    60   ~ 0
GND
Wire Wire Line
	6750 3450 7250 3450
Text Label 6850 6200 0    60   ~ 0
GND
Wire Wire Line
	6750 6200 7250 6200
Text Label 6850 8950 0    60   ~ 0
GND
Wire Wire Line
	6750 8950 7250 8950
Wire Wire Line
	6750 4800 7250 4800
Wire Wire Line
	6750 4900 7250 4900
Wire Wire Line
	6750 5000 7250 5000
Wire Wire Line
	6750 5100 7250 5100
Wire Wire Line
	6750 5200 7250 5200
Wire Wire Line
	6750 5300 7250 5300
Wire Wire Line
	6750 5400 7250 5400
Wire Wire Line
	6750 5500 7250 5500
Wire Wire Line
	6750 4400 7250 4400
Wire Wire Line
	6750 4500 7250 4500
Wire Wire Line
	6750 4600 7250 4600
Text Label 6850 5100 0    60   ~ 0
A4
Text Label 6850 4800 0    60   ~ 0
A7
Text Label 6850 4900 0    60   ~ 0
A6
Text Label 6850 5000 0    60   ~ 0
A5
Text Label 6850 5500 0    60   ~ 0
A0
Text Label 6850 5200 0    60   ~ 0
A3
Text Label 6850 5300 0    60   ~ 0
A2
Text Label 6850 5400 0    60   ~ 0
A1
Text Label 6850 4600 0    60   ~ 0
A8
Text Label 6850 4400 0    60   ~ 0
A10
Text Label 6850 4500 0    60   ~ 0
A9
Wire Wire Line
	6750 2150 7250 2150
Text Label 6850 2150 0    60   ~ 0
D5
Wire Wire Line
	7250 8850 6750 8850
Text Label 7150 8850 2    60   ~ 0
I2C_RX
Wire Wire Line
	7250 3250 6750 3250
Wire Wire Line
	7250 5700 6750 5700
Wire Wire Line
	7250 5800 6750 5800
Wire Wire Line
	7250 2850 6750 2850
Wire Wire Line
	7250 3150 6750 3150
Wire Wire Line
	7250 3050 6750 3050
Wire Wire Line
	7250 2950 6750 2950
Wire Wire Line
	7250 6000 6750 6000
Wire Wire Line
	7250 5900 6750 5900
Wire Wire Line
	7250 2750 6750 2750
Wire Wire Line
	7250 3350 6750 3350
Text Label 6850 1750 0    60   ~ 0
D9
Text Label 6850 1650 0    60   ~ 0
D10
Text Label 6850 1550 0    60   ~ 0
D11
Text Label 6850 1850 0    60   ~ 0
D8
Text Label 6850 1250 0    60   ~ 0
D14
Text Label 6850 1150 0    60   ~ 0
D15
Text Label 6850 1450 0    60   ~ 0
D12
Wire Wire Line
	6750 1850 7250 1850
Wire Wire Line
	6750 1750 7250 1750
Wire Wire Line
	6750 1650 7250 1650
Wire Wire Line
	6750 1550 7250 1550
Wire Wire Line
	6750 1450 7250 1450
Wire Wire Line
	6750 1250 7250 1250
Wire Wire Line
	6750 1150 7250 1150
Wire Wire Line
	6750 1350 7250 1350
Text Label 6850 1350 0    60   ~ 0
D13
Text Label 6850 4700 0    60   ~ 0
+12V
Wire Wire Line
	6750 4700 7250 4700
Text Label 6850 6000 0    60   ~ 0
IC0
Text Label 6850 5900 0    60   ~ 0
IC1
Text Label 6850 5800 0    60   ~ 0
IC2
Text Label 6850 5700 0    60   ~ 0
IC3
Text Label 6850 6100 0    60   ~ 0
AUXCLK1
Wire Wire Line
	6750 6100 7250 6100
Text Label 6850 2750 0    60   ~ 0
BUSERR
Text Label 6850 2850 0    60   ~ 0
VPA
Text Label 6850 2950 0    60   ~ 0
VMA
Text Label 6850 3050 0    60   ~ 0
~BHE
Text Label 6850 3150 0    60   ~ 0
IPL2
Text Label 6850 3250 0    60   ~ 0
IPL1
Text Label 6850 3350 0    60   ~ 0
IPL0
Wire Wire Line
	6750 5600 7250 5600
Text Label 6850 5600 0    60   ~ 0
-12V
Wire Wire Line
	6750 8750 7250 8750
Wire Wire Line
	6750 8050 7250 8050
Wire Wire Line
	6750 8150 7250 8150
Wire Wire Line
	6750 8250 7250 8250
Wire Wire Line
	6750 8350 7250 8350
Wire Wire Line
	6750 8450 7250 8450
Wire Wire Line
	6750 8550 7250 8550
Wire Wire Line
	6750 8650 7250 8650
Text Label 6850 8750 0    60   ~ 0
~EIRQ0
Text Label 6850 8650 0    60   ~ 0
~EIRQ1
Text Label 6850 8550 0    60   ~ 0
~EIRQ2
Text Label 6850 8450 0    60   ~ 0
~EIRQ3
Text Label 6850 8350 0    60   ~ 0
~EIRQ4
Text Label 6850 8250 0    60   ~ 0
~EIRQ5
Text Label 6850 8150 0    60   ~ 0
~EIRQ6
Text Label 6850 8050 0    60   ~ 0
~EIRQ7
Text Label 6850 6950 0    60   ~ 0
~MREQ
Text Label 6850 6850 0    60   ~ 0
~IORQ
Text Label 6850 7250 0    60   ~ 0
CLK
Wire Wire Line
	6750 7850 7250 7850
Wire Wire Line
	6750 6850 7250 6850
Wire Wire Line
	6750 6950 7250 6950
Text Label 6850 7850 0    60   ~ 0
~HALT
Wire Wire Line
	6750 7250 7250 7250
Wire Wire Line
	6750 6650 7250 6650
Wire Wire Line
	6750 6750 7250 6750
Wire Wire Line
	6750 7150 7250 7150
Wire Wire Line
	6750 7950 7250 7950
Wire Wire Line
	6750 7050 7250 7050
Text Label 6850 6650 0    60   ~ 0
~RD
Text Label 6850 6750 0    60   ~ 0
~WR
Text Label 6850 7050 0    60   ~ 0
~M1
Text Label 6850 7150 0    60   ~ 0
~BUSACK
Text Label 6850 7950 0    60   ~ 0
~RFSH
Text Label 6850 7650 0    60   ~ 0
~BUSRQ
Text Label 6850 7750 0    60   ~ 0
~WAIT
Text Label 6850 7550 0    60   ~ 0
~RESET
Wire Wire Line
	6750 7550 7250 7550
Wire Wire Line
	6750 7750 7250 7750
Wire Wire Line
	6750 7650 7250 7650
Wire Wire Line
	6750 6550 7250 6550
Text Label 6850 6550 0    60   ~ 0
VCC
Wire Wire Line
	6750 7350 7250 7350
Wire Wire Line
	6750 7450 7250 7450
Text Label 6850 7350 0    60   ~ 0
~INT0
Text Label 6850 7450 0    60   ~ 0
~NMI
Text Label 4900 4300 0    60   ~ 0
A11
Text Label 4900 4100 0    60   ~ 0
A13
Text Label 4900 4000 0    60   ~ 0
A14
Text Label 4900 3900 0    60   ~ 0
A15
Text Label 4900 4200 0    60   ~ 0
A12
Text Label 4900 2550 0    60   ~ 0
D1
Text Label 4900 2450 0    60   ~ 0
D2
Text Label 4900 2350 0    60   ~ 0
D3
Text Label 4900 2650 0    60   ~ 0
D0
Text Label 4900 2050 0    60   ~ 0
D6
Text Label 4900 1950 0    60   ~ 0
D7
Text Label 4900 2250 0    60   ~ 0
D4
Wire Wire Line
	4800 4300 5300 4300
Wire Wire Line
	4800 4200 5300 4200
Wire Wire Line
	4800 4100 5300 4100
Wire Wire Line
	4800 4000 5300 4000
Wire Wire Line
	4800 3900 5300 3900
Wire Wire Line
	4800 2650 5300 2650
Wire Wire Line
	4800 2550 5300 2550
Wire Wire Line
	4800 2450 5300 2450
Wire Wire Line
	4800 2350 5300 2350
Wire Wire Line
	4800 2250 5300 2250
Wire Wire Line
	4800 2050 5300 2050
Wire Wire Line
	4800 1950 5300 1950
Text Label 4900 3800 0    60   ~ 0
VCC
Wire Wire Line
	4800 3800 5300 3800
Text Label 4900 1050 0    60   ~ 0
VCC
Wire Wire Line
	4800 1050 5300 1050
Text Label 4900 3450 0    60   ~ 0
GND
Wire Wire Line
	4800 3450 5300 3450
Text Label 4900 6200 0    60   ~ 0
GND
Wire Wire Line
	4800 6200 5300 6200
Text Label 4900 8950 0    60   ~ 0
GND
Wire Wire Line
	4800 8950 5300 8950
Wire Wire Line
	4800 4800 5300 4800
Wire Wire Line
	4800 4900 5300 4900
Wire Wire Line
	4800 5000 5300 5000
Wire Wire Line
	4800 5100 5300 5100
Wire Wire Line
	4800 5200 5300 5200
Wire Wire Line
	4800 5300 5300 5300
Wire Wire Line
	4800 5400 5300 5400
Wire Wire Line
	4800 5500 5300 5500
Wire Wire Line
	4800 4400 5300 4400
Wire Wire Line
	4800 4500 5300 4500
Wire Wire Line
	4800 4600 5300 4600
Text Label 4900 5100 0    60   ~ 0
A4
Text Label 4900 4800 0    60   ~ 0
A7
Text Label 4900 4900 0    60   ~ 0
A6
Text Label 4900 5000 0    60   ~ 0
A5
Text Label 4900 5500 0    60   ~ 0
A0
Text Label 4900 5200 0    60   ~ 0
A3
Text Label 4900 5300 0    60   ~ 0
A2
Text Label 4900 5400 0    60   ~ 0
A1
Text Label 4900 4600 0    60   ~ 0
A8
Text Label 4900 4400 0    60   ~ 0
A10
Text Label 4900 4500 0    60   ~ 0
A9
Wire Wire Line
	4800 2150 5300 2150
Text Label 4900 2150 0    60   ~ 0
D5
Wire Wire Line
	5300 8850 4800 8850
Text Label 5200 8850 2    60   ~ 0
I2C_RX
Wire Wire Line
	5300 3250 4800 3250
Wire Wire Line
	5300 5700 4800 5700
Wire Wire Line
	5300 5800 4800 5800
Wire Wire Line
	5300 2850 4800 2850
Wire Wire Line
	5300 3150 4800 3150
Wire Wire Line
	5300 3050 4800 3050
Wire Wire Line
	5300 2950 4800 2950
Wire Wire Line
	5300 6000 4800 6000
Wire Wire Line
	5300 5900 4800 5900
Wire Wire Line
	5300 2750 4800 2750
Wire Wire Line
	5300 3350 4800 3350
Text Label 4900 1750 0    60   ~ 0
D9
Text Label 4900 1650 0    60   ~ 0
D10
Text Label 4900 1550 0    60   ~ 0
D11
Text Label 4900 1850 0    60   ~ 0
D8
Text Label 4900 1250 0    60   ~ 0
D14
Text Label 4900 1150 0    60   ~ 0
D15
Text Label 4900 1450 0    60   ~ 0
D12
Wire Wire Line
	4800 1850 5300 1850
Wire Wire Line
	4800 1750 5300 1750
Wire Wire Line
	4800 1650 5300 1650
Wire Wire Line
	4800 1550 5300 1550
Wire Wire Line
	4800 1450 5300 1450
Wire Wire Line
	4800 1250 5300 1250
Wire Wire Line
	4800 1150 5300 1150
Wire Wire Line
	4800 1350 5300 1350
Text Label 4900 1350 0    60   ~ 0
D13
Text Label 4900 4700 0    60   ~ 0
+12V
Wire Wire Line
	4800 4700 5300 4700
Text Label 4900 6000 0    60   ~ 0
IC0
Text Label 4900 5900 0    60   ~ 0
IC1
Text Label 4900 5800 0    60   ~ 0
IC2
Text Label 4900 5700 0    60   ~ 0
IC3
Text Label 4900 6100 0    60   ~ 0
AUXCLK1
Wire Wire Line
	4800 6100 5300 6100
Text Label 4900 2750 0    60   ~ 0
BUSERR
Text Label 4900 2850 0    60   ~ 0
VPA
Text Label 4900 2950 0    60   ~ 0
VMA
Text Label 4900 3050 0    60   ~ 0
~BHE
Text Label 4900 3150 0    60   ~ 0
IPL2
Text Label 4900 3250 0    60   ~ 0
IPL1
Text Label 4900 3350 0    60   ~ 0
IPL0
Wire Wire Line
	4800 5600 5300 5600
Text Label 4900 5600 0    60   ~ 0
-12V
Wire Wire Line
	4800 8750 5300 8750
Wire Wire Line
	4800 8050 5300 8050
Wire Wire Line
	4800 8150 5300 8150
Wire Wire Line
	4800 8250 5300 8250
Wire Wire Line
	4800 8350 5300 8350
Wire Wire Line
	4800 8450 5300 8450
Wire Wire Line
	4800 8550 5300 8550
Wire Wire Line
	4800 8650 5300 8650
Text Label 4900 8750 0    60   ~ 0
~EIRQ0
Text Label 4900 8650 0    60   ~ 0
~EIRQ1
Text Label 4900 8550 0    60   ~ 0
~EIRQ2
Text Label 4900 8450 0    60   ~ 0
~EIRQ3
Text Label 4900 8350 0    60   ~ 0
~EIRQ4
Text Label 4900 8250 0    60   ~ 0
~EIRQ5
Text Label 4900 8150 0    60   ~ 0
~EIRQ6
Text Label 4900 8050 0    60   ~ 0
~EIRQ7
Text Label 4900 6950 0    60   ~ 0
~MREQ
Text Label 4900 6850 0    60   ~ 0
~IORQ
Text Label 4900 7250 0    60   ~ 0
CLK
Wire Wire Line
	4800 7850 5300 7850
Wire Wire Line
	4800 6850 5300 6850
Wire Wire Line
	4800 6950 5300 6950
Text Label 4900 7850 0    60   ~ 0
~HALT
Wire Wire Line
	4800 7250 5300 7250
Wire Wire Line
	4800 6650 5300 6650
Wire Wire Line
	4800 6750 5300 6750
Wire Wire Line
	4800 7150 5300 7150
Wire Wire Line
	4800 7950 5300 7950
Wire Wire Line
	4800 7050 5300 7050
Text Label 4900 6650 0    60   ~ 0
~RD
Text Label 4900 6750 0    60   ~ 0
~WR
Text Label 4900 7050 0    60   ~ 0
~M1
Text Label 4900 7150 0    60   ~ 0
~BUSACK
Text Label 4900 7950 0    60   ~ 0
~RFSH
Text Label 4900 7650 0    60   ~ 0
~BUSRQ
Text Label 4900 7750 0    60   ~ 0
~WAIT
Text Label 4900 7550 0    60   ~ 0
~RESET
Wire Wire Line
	4800 7550 5300 7550
Wire Wire Line
	4800 7750 5300 7750
Wire Wire Line
	4800 7650 5300 7650
Wire Wire Line
	4800 6550 5300 6550
Text Label 4900 6550 0    60   ~ 0
VCC
Wire Wire Line
	4800 7350 5300 7350
Wire Wire Line
	4800 7450 5300 7450
Text Label 4900 7350 0    60   ~ 0
~INT0
Text Label 4900 7450 0    60   ~ 0
~NMI
Text Label 9800 6550 0    60   ~ 0
VCC
Wire Wire Line
	9700 6550 10200 6550
Text Label 9800 3800 0    60   ~ 0
VCC
Wire Wire Line
	9700 3800 10200 3800
Text Label 9800 1050 0    60   ~ 0
VCC
Wire Wire Line
	9700 1050 10200 1050
Text Label 9800 3450 0    60   ~ 0
GND
Wire Wire Line
	9700 3450 10200 3450
Text Label 9800 6200 0    60   ~ 0
GND
Wire Wire Line
	9700 6200 10200 6200
Text Label 9800 8950 0    60   ~ 0
GND
Wire Wire Line
	9700 8950 10200 8950
Wire Wire Line
	10200 8850 9700 8850
Text Label 10100 8850 2    60   ~ 0
I2C_TX
Text Label 9800 5300 0    60   ~ 0
A18
Text Label 9800 5400 0    60   ~ 0
A17
Text Label 9800 5500 0    60   ~ 0
A16
Text Label 9800 5200 0    60   ~ 0
A19
Wire Wire Line
	9700 5200 10200 5200
Wire Wire Line
	9700 5300 10200 5300
Wire Wire Line
	9700 5400 10200 5400
Wire Wire Line
	9700 5500 10200 5500
Wire Wire Line
	9700 7250 10200 7250
Wire Wire Line
	9700 7350 10200 7350
Wire Wire Line
	10200 7150 9700 7150
Text Label 9800 4900 0    60   ~ 0
A22
Text Label 9800 5000 0    60   ~ 0
A21
Text Label 9800 5100 0    60   ~ 0
A20
Text Label 9800 4800 0    60   ~ 0
A23
Wire Wire Line
	9700 4800 10200 4800
Wire Wire Line
	9700 4900 10200 4900
Wire Wire Line
	9700 5000 10200 5000
Wire Wire Line
	9700 5100 10200 5100
Text Label 9800 4500 0    60   ~ 0
A25
Text Label 9800 4400 0    60   ~ 0
A26
Text Label 9800 4600 0    60   ~ 0
A24
Wire Wire Line
	9700 4600 10200 4600
Wire Wire Line
	9700 4500 10200 4500
Wire Wire Line
	9700 4400 10200 4400
Wire Wire Line
	9700 3900 10200 3900
Wire Wire Line
	9700 4000 10200 4000
Wire Wire Line
	9700 4100 10200 4100
Wire Wire Line
	9700 4200 10200 4200
Wire Wire Line
	9700 4300 10200 4300
Text Label 9800 4200 0    60   ~ 0
A28
Text Label 9800 3900 0    60   ~ 0
A31
Text Label 9800 4000 0    60   ~ 0
A30
Text Label 9800 4100 0    60   ~ 0
A29
Text Label 9800 4300 0    60   ~ 0
A27
Wire Wire Line
	9700 2850 10200 2850
Wire Wire Line
	9700 2950 10200 2950
Wire Wire Line
	9700 3050 10200 3050
Wire Wire Line
	9700 2750 10200 2750
Wire Wire Line
	9700 3150 10200 3150
Text Label 9800 4700 0    60   ~ 0
+12V
Wire Wire Line
	9700 4700 10200 4700
Text Label 9800 2550 0    60   ~ 0
D17
Text Label 9800 2450 0    60   ~ 0
D18
Text Label 9800 2350 0    60   ~ 0
D19
Text Label 9800 2650 0    60   ~ 0
D16
Text Label 9800 2050 0    60   ~ 0
D22
Text Label 9800 1950 0    60   ~ 0
D23
Text Label 9800 2250 0    60   ~ 0
D20
Wire Wire Line
	9700 2650 10200 2650
Wire Wire Line
	9700 2550 10200 2550
Wire Wire Line
	9700 2450 10200 2450
Wire Wire Line
	9700 2350 10200 2350
Wire Wire Line
	9700 2250 10200 2250
Wire Wire Line
	9700 2050 10200 2050
Wire Wire Line
	9700 1950 10200 1950
Wire Wire Line
	9700 2150 10200 2150
Text Label 9800 2150 0    60   ~ 0
D21
Text Label 9800 1750 0    60   ~ 0
D25
Text Label 9800 1650 0    60   ~ 0
D26
Text Label 9800 1550 0    60   ~ 0
D27
Text Label 9800 1850 0    60   ~ 0
D24
Text Label 9800 1250 0    60   ~ 0
D30
Text Label 9800 1150 0    60   ~ 0
D31
Text Label 9800 1450 0    60   ~ 0
D28
Wire Wire Line
	9700 1850 10200 1850
Wire Wire Line
	9700 1750 10200 1750
Wire Wire Line
	9700 1650 10200 1650
Wire Wire Line
	9700 1550 10200 1550
Wire Wire Line
	9700 1450 10200 1450
Wire Wire Line
	9700 1250 10200 1250
Wire Wire Line
	9700 1150 10200 1150
Wire Wire Line
	9700 1350 10200 1350
Text Label 9800 1350 0    60   ~ 0
D29
Text Label 9800 8250 0    60   ~ 0
USER1
Text Label 9800 8350 0    60   ~ 0
USER0
Text Label 9800 8150 0    60   ~ 0
USER2
Wire Wire Line
	9700 8150 10200 8150
Wire Wire Line
	9700 8250 10200 8250
Wire Wire Line
	9700 8350 10200 8350
Text Label 9800 7950 0    60   ~ 0
USER4
Text Label 9800 8050 0    60   ~ 0
USER3
Text Label 9800 7850 0    60   ~ 0
USER5
Wire Wire Line
	9700 7850 10200 7850
Wire Wire Line
	9700 7950 10200 7950
Wire Wire Line
	9700 8050 10200 8050
Text Label 9800 7750 0    60   ~ 0
USER6
Text Label 9800 7550 0    60   ~ 0
USER8
Wire Wire Line
	9700 7550 10200 7550
Wire Wire Line
	9700 7650 10200 7650
Wire Wire Line
	9700 7750 10200 7750
Text Label 9800 7450 0    60   ~ 0
USER9
Wire Wire Line
	9700 7450 10200 7450
Text Label 9800 7650 0    60   ~ 0
USER7
Text Label 9800 3150 0    60   ~ 0
S0
Text Label 9800 3050 0    60   ~ 0
S1
Text Label 9800 2950 0    60   ~ 0
S2
Text Label 9800 7350 0    60   ~ 0
CRUIN
Text Label 9800 7250 0    60   ~ 0
CRUOUT
Text Label 9800 7150 0    60   ~ 0
CRYCCLK
Wire Wire Line
	10200 7050 9700 7050
Wire Wire Line
	10200 6950 9700 6950
Wire Wire Line
	9700 5700 10200 5700
Wire Wire Line
	9700 5800 10200 5800
Wire Wire Line
	10200 6850 9700 6850
Wire Wire Line
	10200 6750 9700 6750
Wire Wire Line
	10200 6650 9700 6650
Text Label 9800 5800 0    60   ~ 0
~DREQ1
Text Label 9800 7050 0    60   ~ 0
~INT1
Text Label 9800 6950 0    60   ~ 0
~INT2
Text Label 9800 5700 0    60   ~ 0
~TEND1
Text Label 9800 6850 0    60   ~ 0
PHI
Text Label 9800 6750 0    60   ~ 0
ST
Text Label 9800 5900 0    60   ~ 0
~TEND0
Wire Wire Line
	9700 5900 10200 5900
Text Label 9800 6000 0    60   ~ 0
~DREQ0
Wire Wire Line
	9700 6000 10200 6000
Text Label 9800 3250 0    60   ~ 0
AUXCLK3
Text Label 9800 3350 0    60   ~ 0
AUXCLK2
Text Label 9800 6100 0    60   ~ 0
AUXCLK0
Wire Wire Line
	10200 3250 9700 3250
Wire Wire Line
	9700 3350 10200 3350
Wire Wire Line
	9700 6100 10200 6100
Wire Wire Line
	10200 8750 9700 8750
Text Label 9800 8550 0    60   ~ 0
~BAO-2
Wire Wire Line
	10200 8550 9700 8550
Text Label 9800 8450 0    60   ~ 0
~BAI-2
Wire Wire Line
	10200 8450 9700 8450
Text Label 9800 2750 0    60   ~ 0
UDS
Text Label 9800 2850 0    60   ~ 0
LDS
Wire Wire Line
	10200 8650 9700 8650
Text Label 9800 8750 0    60   ~ 0
~IEO-2
Text Label 9800 8650 0    60   ~ 0
~IEI-2
Wire Wire Line
	9700 5600 10200 5600
Text Label 9800 5600 0    60   ~ 0
-12V
Text Label 7850 6550 0    60   ~ 0
VCC
Wire Wire Line
	7750 6550 8250 6550
Text Label 7850 3800 0    60   ~ 0
VCC
Wire Wire Line
	7750 3800 8250 3800
Text Label 7850 1050 0    60   ~ 0
VCC
Wire Wire Line
	7750 1050 8250 1050
Text Label 7850 3450 0    60   ~ 0
GND
Wire Wire Line
	7750 3450 8250 3450
Text Label 7850 6200 0    60   ~ 0
GND
Wire Wire Line
	7750 6200 8250 6200
Text Label 7850 8950 0    60   ~ 0
GND
Wire Wire Line
	7750 8950 8250 8950
Wire Wire Line
	8250 8850 7750 8850
Text Label 8150 8850 2    60   ~ 0
I2C_TX
Text Label 7850 5300 0    60   ~ 0
A18
Text Label 7850 5400 0    60   ~ 0
A17
Text Label 7850 5500 0    60   ~ 0
A16
Text Label 7850 5200 0    60   ~ 0
A19
Wire Wire Line
	7750 5200 8250 5200
Wire Wire Line
	7750 5300 8250 5300
Wire Wire Line
	7750 5400 8250 5400
Wire Wire Line
	7750 5500 8250 5500
Wire Wire Line
	7750 7250 8250 7250
Wire Wire Line
	7750 7350 8250 7350
Wire Wire Line
	8250 7150 7750 7150
Text Label 7850 4900 0    60   ~ 0
A22
Text Label 7850 5000 0    60   ~ 0
A21
Text Label 7850 5100 0    60   ~ 0
A20
Text Label 7850 4800 0    60   ~ 0
A23
Wire Wire Line
	7750 4800 8250 4800
Wire Wire Line
	7750 4900 8250 4900
Wire Wire Line
	7750 5000 8250 5000
Wire Wire Line
	7750 5100 8250 5100
Text Label 7850 4500 0    60   ~ 0
A25
Text Label 7850 4400 0    60   ~ 0
A26
Text Label 7850 4600 0    60   ~ 0
A24
Wire Wire Line
	7750 4600 8250 4600
Wire Wire Line
	7750 4500 8250 4500
Wire Wire Line
	7750 4400 8250 4400
Wire Wire Line
	7750 3900 8250 3900
Wire Wire Line
	7750 4000 8250 4000
Wire Wire Line
	7750 4100 8250 4100
Wire Wire Line
	7750 4200 8250 4200
Wire Wire Line
	7750 4300 8250 4300
Text Label 7850 4200 0    60   ~ 0
A28
Text Label 7850 3900 0    60   ~ 0
A31
Text Label 7850 4000 0    60   ~ 0
A30
Text Label 7850 4100 0    60   ~ 0
A29
Text Label 7850 4300 0    60   ~ 0
A27
Wire Wire Line
	7750 2850 8250 2850
Wire Wire Line
	7750 2950 8250 2950
Wire Wire Line
	7750 3050 8250 3050
Wire Wire Line
	7750 2750 8250 2750
Wire Wire Line
	7750 3150 8250 3150
Text Label 7850 4700 0    60   ~ 0
+12V
Wire Wire Line
	7750 4700 8250 4700
Text Label 7850 2550 0    60   ~ 0
D17
Text Label 7850 2450 0    60   ~ 0
D18
Text Label 7850 2350 0    60   ~ 0
D19
Text Label 7850 2650 0    60   ~ 0
D16
Text Label 7850 2050 0    60   ~ 0
D22
Text Label 7850 1950 0    60   ~ 0
D23
Text Label 7850 2250 0    60   ~ 0
D20
Wire Wire Line
	7750 2650 8250 2650
Wire Wire Line
	7750 2550 8250 2550
Wire Wire Line
	7750 2450 8250 2450
Wire Wire Line
	7750 2350 8250 2350
Wire Wire Line
	7750 2250 8250 2250
Wire Wire Line
	7750 2050 8250 2050
Wire Wire Line
	7750 1950 8250 1950
Wire Wire Line
	7750 2150 8250 2150
Text Label 7850 2150 0    60   ~ 0
D21
Text Label 7850 1750 0    60   ~ 0
D25
Text Label 7850 1650 0    60   ~ 0
D26
Text Label 7850 1550 0    60   ~ 0
D27
Text Label 7850 1850 0    60   ~ 0
D24
Text Label 7850 1250 0    60   ~ 0
D30
Text Label 7850 1150 0    60   ~ 0
D31
Text Label 7850 1450 0    60   ~ 0
D28
Wire Wire Line
	7750 1850 8250 1850
Wire Wire Line
	7750 1750 8250 1750
Wire Wire Line
	7750 1650 8250 1650
Wire Wire Line
	7750 1550 8250 1550
Wire Wire Line
	7750 1450 8250 1450
Wire Wire Line
	7750 1250 8250 1250
Wire Wire Line
	7750 1150 8250 1150
Wire Wire Line
	7750 1350 8250 1350
Text Label 7850 1350 0    60   ~ 0
D29
Text Label 7850 8250 0    60   ~ 0
USER1
Text Label 7850 8350 0    60   ~ 0
USER0
Text Label 7850 8150 0    60   ~ 0
USER2
Wire Wire Line
	7750 8150 8250 8150
Wire Wire Line
	7750 8250 8250 8250
Wire Wire Line
	7750 8350 8250 8350
Text Label 7850 7950 0    60   ~ 0
USER4
Text Label 7850 8050 0    60   ~ 0
USER3
Text Label 7850 7850 0    60   ~ 0
USER5
Wire Wire Line
	7750 7850 8250 7850
Wire Wire Line
	7750 7950 8250 7950
Wire Wire Line
	7750 8050 8250 8050
Text Label 7850 7750 0    60   ~ 0
USER6
Text Label 7850 7550 0    60   ~ 0
USER8
Wire Wire Line
	7750 7550 8250 7550
Wire Wire Line
	7750 7650 8250 7650
Wire Wire Line
	7750 7750 8250 7750
Text Label 7850 7450 0    60   ~ 0
USER9
Wire Wire Line
	7750 7450 8250 7450
Text Label 7850 7650 0    60   ~ 0
USER7
Text Label 7850 3150 0    60   ~ 0
S0
Text Label 7850 3050 0    60   ~ 0
S1
Text Label 7850 2950 0    60   ~ 0
S2
Text Label 7850 7350 0    60   ~ 0
CRUIN
Text Label 7850 7250 0    60   ~ 0
CRUOUT
Text Label 7850 7150 0    60   ~ 0
CRYCCLK
Text Label 7850 6650 0    60   ~ 0
E
Wire Wire Line
	8250 7050 7750 7050
Wire Wire Line
	8250 6950 7750 6950
Wire Wire Line
	7750 5700 8250 5700
Wire Wire Line
	7750 5800 8250 5800
Wire Wire Line
	8250 6850 7750 6850
Wire Wire Line
	8250 6750 7750 6750
Wire Wire Line
	8250 6650 7750 6650
Text Label 7850 5800 0    60   ~ 0
~DREQ1
Text Label 7850 7050 0    60   ~ 0
~INT1
Text Label 7850 6950 0    60   ~ 0
~INT2
Text Label 7850 5700 0    60   ~ 0
~TEND1
Text Label 7850 6850 0    60   ~ 0
PHI
Text Label 7850 6750 0    60   ~ 0
ST
Text Label 7850 5900 0    60   ~ 0
~TEND0
Wire Wire Line
	7750 5900 8250 5900
Text Label 7850 6000 0    60   ~ 0
~DREQ0
Wire Wire Line
	7750 6000 8250 6000
Text Label 7850 3250 0    60   ~ 0
AUXCLK3
Text Label 7850 3350 0    60   ~ 0
AUXCLK2
Text Label 7850 6100 0    60   ~ 0
AUXCLK0
Wire Wire Line
	8250 3250 7750 3250
Wire Wire Line
	7750 3350 8250 3350
Wire Wire Line
	7750 6100 8250 6100
Wire Wire Line
	8250 8750 7750 8750
Text Label 7850 8550 0    60   ~ 0
~BAO-3
Wire Wire Line
	8250 8550 7750 8550
Text Label 7850 8450 0    60   ~ 0
~BAI-3
Wire Wire Line
	8250 8450 7750 8450
Text Label 7850 2750 0    60   ~ 0
UDS
Text Label 7850 2850 0    60   ~ 0
LDS
Wire Wire Line
	8250 8650 7750 8650
Text Label 7850 8750 0    60   ~ 0
~IEO-3
Text Label 7850 8650 0    60   ~ 0
~IEI-3
Wire Wire Line
	7750 5600 8250 5600
Text Label 7850 5600 0    60   ~ 0
-12V
Text Label 5900 6550 0    60   ~ 0
VCC
Wire Wire Line
	5800 6550 6300 6550
Text Label 5900 3800 0    60   ~ 0
VCC
Wire Wire Line
	5800 3800 6300 3800
Text Label 5900 1050 0    60   ~ 0
VCC
Wire Wire Line
	5800 1050 6300 1050
Text Label 5900 3450 0    60   ~ 0
GND
Wire Wire Line
	5800 3450 6300 3450
Text Label 5900 6200 0    60   ~ 0
GND
Wire Wire Line
	5800 6200 6300 6200
Text Label 5900 8950 0    60   ~ 0
GND
Wire Wire Line
	5800 8950 6300 8950
Wire Wire Line
	6300 8850 5800 8850
Text Label 6200 8850 2    60   ~ 0
I2C_TX
Text Label 5900 5300 0    60   ~ 0
A18
Text Label 5900 5400 0    60   ~ 0
A17
Text Label 5900 5500 0    60   ~ 0
A16
Text Label 5900 5200 0    60   ~ 0
A19
Wire Wire Line
	5800 5200 6300 5200
Wire Wire Line
	5800 5300 6300 5300
Wire Wire Line
	5800 5400 6300 5400
Wire Wire Line
	5800 5500 6300 5500
Wire Wire Line
	5800 7250 6300 7250
Wire Wire Line
	5800 7350 6300 7350
Wire Wire Line
	6300 7150 5800 7150
Text Label 5900 4900 0    60   ~ 0
A22
Text Label 5900 5000 0    60   ~ 0
A21
Text Label 5900 5100 0    60   ~ 0
A20
Text Label 5900 4800 0    60   ~ 0
A23
Wire Wire Line
	5800 4800 6300 4800
Wire Wire Line
	5800 4900 6300 4900
Wire Wire Line
	5800 5000 6300 5000
Wire Wire Line
	5800 5100 6300 5100
Text Label 5900 4500 0    60   ~ 0
A25
Text Label 5900 4400 0    60   ~ 0
A26
Text Label 5900 4600 0    60   ~ 0
A24
Wire Wire Line
	5800 4600 6300 4600
Wire Wire Line
	5800 4500 6300 4500
Wire Wire Line
	5800 4400 6300 4400
Wire Wire Line
	5800 3900 6300 3900
Wire Wire Line
	5800 4000 6300 4000
Wire Wire Line
	5800 4100 6300 4100
Wire Wire Line
	5800 4200 6300 4200
Wire Wire Line
	5800 4300 6300 4300
Text Label 5900 4200 0    60   ~ 0
A28
Text Label 5900 3900 0    60   ~ 0
A31
Text Label 5900 4000 0    60   ~ 0
A30
Text Label 5900 4100 0    60   ~ 0
A29
Text Label 5900 4300 0    60   ~ 0
A27
Wire Wire Line
	5800 2850 6300 2850
Wire Wire Line
	5800 2950 6300 2950
Wire Wire Line
	5800 3050 6300 3050
Wire Wire Line
	5800 2750 6300 2750
Wire Wire Line
	5800 3150 6300 3150
Text Label 5900 4700 0    60   ~ 0
+12V
Wire Wire Line
	5800 4700 6300 4700
Text Label 5900 2550 0    60   ~ 0
D17
Text Label 5900 2450 0    60   ~ 0
D18
Text Label 5900 2350 0    60   ~ 0
D19
Text Label 5900 2650 0    60   ~ 0
D16
Text Label 5900 2050 0    60   ~ 0
D22
Text Label 5900 1950 0    60   ~ 0
D23
Text Label 5900 2250 0    60   ~ 0
D20
Wire Wire Line
	5800 2650 6300 2650
Wire Wire Line
	5800 2550 6300 2550
Wire Wire Line
	5800 2450 6300 2450
Wire Wire Line
	5800 2350 6300 2350
Wire Wire Line
	5800 2250 6300 2250
Wire Wire Line
	5800 2050 6300 2050
Wire Wire Line
	5800 1950 6300 1950
Wire Wire Line
	5800 2150 6300 2150
Text Label 5900 2150 0    60   ~ 0
D21
Text Label 5900 1750 0    60   ~ 0
D25
Text Label 5900 1650 0    60   ~ 0
D26
Text Label 5900 1550 0    60   ~ 0
D27
Text Label 5900 1850 0    60   ~ 0
D24
Text Label 5900 1250 0    60   ~ 0
D30
Text Label 5900 1150 0    60   ~ 0
D31
Text Label 5900 1450 0    60   ~ 0
D28
Wire Wire Line
	5800 1850 6300 1850
Wire Wire Line
	5800 1750 6300 1750
Wire Wire Line
	5800 1650 6300 1650
Wire Wire Line
	5800 1550 6300 1550
Wire Wire Line
	5800 1450 6300 1450
Wire Wire Line
	5800 1250 6300 1250
Wire Wire Line
	5800 1150 6300 1150
Wire Wire Line
	5800 1350 6300 1350
Text Label 5900 1350 0    60   ~ 0
D29
Text Label 5900 8250 0    60   ~ 0
USER1
Text Label 5900 8350 0    60   ~ 0
USER0
Text Label 5900 8150 0    60   ~ 0
USER2
Wire Wire Line
	5800 8150 6300 8150
Wire Wire Line
	5800 8250 6300 8250
Wire Wire Line
	5800 8350 6300 8350
Text Label 5900 7950 0    60   ~ 0
USER4
Text Label 5900 8050 0    60   ~ 0
USER3
Text Label 5900 7850 0    60   ~ 0
USER5
Wire Wire Line
	5800 7850 6300 7850
Wire Wire Line
	5800 7950 6300 7950
Wire Wire Line
	5800 8050 6300 8050
Text Label 5900 7750 0    60   ~ 0
USER6
Text Label 5900 7550 0    60   ~ 0
USER8
Wire Wire Line
	5800 7550 6300 7550
Wire Wire Line
	5800 7650 6300 7650
Wire Wire Line
	5800 7750 6300 7750
Text Label 5900 7450 0    60   ~ 0
USER9
Wire Wire Line
	5800 7450 6300 7450
Text Label 5900 7650 0    60   ~ 0
USER7
Text Label 5900 3150 0    60   ~ 0
S0
Text Label 5900 3050 0    60   ~ 0
S1
Text Label 5900 2950 0    60   ~ 0
S2
Text Label 5900 7350 0    60   ~ 0
CRUIN
Text Label 5900 7250 0    60   ~ 0
CRUOUT
Text Label 5900 7150 0    60   ~ 0
CRYCCLK
Text Label 5900 6650 0    60   ~ 0
E
Wire Wire Line
	6300 7050 5800 7050
Wire Wire Line
	6300 6950 5800 6950
Wire Wire Line
	5800 5700 6300 5700
Wire Wire Line
	5800 5800 6300 5800
Wire Wire Line
	6300 6850 5800 6850
Wire Wire Line
	6300 6750 5800 6750
Wire Wire Line
	6300 6650 5800 6650
Text Label 5900 5800 0    60   ~ 0
~DREQ1
Text Label 5900 7050 0    60   ~ 0
~INT1
Text Label 5900 6950 0    60   ~ 0
~INT2
Text Label 5900 5700 0    60   ~ 0
~TEND1
Text Label 5900 6850 0    60   ~ 0
PHI
Text Label 5900 6750 0    60   ~ 0
ST
Text Label 5900 5900 0    60   ~ 0
~TEND0
Wire Wire Line
	5800 5900 6300 5900
Text Label 5900 6000 0    60   ~ 0
~DREQ0
Wire Wire Line
	5800 6000 6300 6000
Text Label 5900 3250 0    60   ~ 0
AUXCLK3
Text Label 5900 3350 0    60   ~ 0
AUXCLK2
Text Label 5900 6100 0    60   ~ 0
AUXCLK0
Wire Wire Line
	6300 3250 5800 3250
Wire Wire Line
	5800 3350 6300 3350
Wire Wire Line
	5800 6100 6300 6100
Wire Wire Line
	6300 8750 5800 8750
Text Label 5900 8550 0    60   ~ 0
~BAO-4
Wire Wire Line
	6300 8550 5800 8550
Text Label 5900 8450 0    60   ~ 0
~BAI-4
Wire Wire Line
	6300 8450 5800 8450
Text Label 5900 2750 0    60   ~ 0
UDS
Text Label 5900 2850 0    60   ~ 0
LDS
Wire Wire Line
	6300 8650 5800 8650
Text Label 5900 8750 0    60   ~ 0
~IEO-4
Text Label 5900 8650 0    60   ~ 0
~IEI-4
Wire Wire Line
	5800 5600 6300 5600
Text Label 5900 5600 0    60   ~ 0
-12V
NoConn ~ 6300 8450
NoConn ~ 6300 8650
$EndSCHEMATC
