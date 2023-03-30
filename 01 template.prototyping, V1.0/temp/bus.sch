EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr B 17000 11000
encoding utf-8
Sheet 2 4
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
U 1 1 658B4EE0
P 8650 8050
AR Path="/658A2182/658B4EE0" Ref="P1"  Part="1" 
AR Path="/658C2B13/658B4EE0" Ref="P?"  Part="1" 
F 0 "P1" H 8650 9465 50  0000 C CNN
F 1 "CONN_02X25" H 8650 9374 50  0000 C CNN
F 2 "Connector_IDC:IDC-Header_2x25_P2.54mm_Horizontal" H 8650 7300 50  0001 C CNN
F 3 "" H 8650 7300 50  0001 C CNN
	1    8650 8050
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 P2
U 1 1 658B4EE6
P 8650 5300
AR Path="/658A2182/658B4EE6" Ref="P2"  Part="1" 
AR Path="/658C2B13/658B4EE6" Ref="P?"  Part="1" 
F 0 "P2" H 8650 6715 50  0000 C CNN
F 1 "CONN_02X25" H 8650 6624 50  0000 C CNN
F 2 "Connector_IDC:IDC-Header_2x25_P2.54mm_Horizontal" H 8650 4550 50  0001 C CNN
F 3 "" H 8650 4550 50  0001 C CNN
	1    8650 5300
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_02X25 P3
U 1 1 658B4EEC
P 8650 2550
AR Path="/658A2182/658B4EEC" Ref="P3"  Part="1" 
AR Path="/658C2B13/658B4EEC" Ref="P?"  Part="1" 
F 0 "P3" H 8650 3965 50  0000 C CNN
F 1 "CONN_02X25" H 8650 3874 50  0000 C CNN
F 2 "Connector_IDC:IDC-Header_2x25_P2.54mm_Horizontal" H 8650 1800 50  0001 C CNN
F 3 "" H 8650 1800 50  0001 C CNN
	1    8650 2550
	1    0    0    -1  
$EndComp
Text GLabel 7900 5000 0    40   Output ~ 0
+12V
Text GLabel 9400 5000 2    40   Output ~ 0
+12V
Text GLabel 9400 5900 2    40   Output ~ 0
-12V
Text GLabel 7900 5900 0    40   Output ~ 0
-12V
Text GLabel 9400 6500 2    40   Output ~ 0
GND
Text GLabel 7900 6500 0    40   Output ~ 0
GND
Text GLabel 9400 6850 2    40   Output ~ 0
VCC
Text GLabel 7900 6850 0    40   Output ~ 0
VCC
Text GLabel 7900 9250 0    40   Output ~ 0
GND
Text GLabel 9400 9250 2    40   Output ~ 0
GND
Text GLabel 7900 4100 0    40   Output ~ 0
VCC
Text GLabel 9400 4100 2    40   Output ~ 0
VCC
Text GLabel 9400 1350 2    40   Output ~ 0
VCC
Text GLabel 7900 1350 0    40   Output ~ 0
VCC
Text GLabel 9400 3750 2    40   Output ~ 0
GND
Text GLabel 7900 3750 0    40   Output ~ 0
GND
$Comp
L conn:CONN_01X04 P4
U 1 1 64274636
P 10250 8900
F 0 "P4" H 10167 8525 50  0000 C CNN
F 1 "BYPASS" H 10167 8616 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x04_P2.54mm_Vertical" H 10250 8900 50  0001 C CNN
F 3 "" H 10250 8900 50  0001 C CNN
	1    10250 8900
	1    0    0    1   
$EndComp
Text GLabel 9400 8750 2    40   Input ~ 0
~BAI
Text GLabel 9400 8850 2    40   Output ~ 0
~BAO
Text GLabel 9400 8950 2    40   Input ~ 0
~IEI
Text GLabel 9400 9050 2    40   Output ~ 0
~IEO
Text GLabel 10050 8750 0    40   Input ~ 0
~BAI
Text GLabel 10050 8850 0    40   Output ~ 0
~BAO
Text GLabel 10050 8950 0    40   Input ~ 0
~IEI
Text GLabel 10050 9050 0    40   Output ~ 0
~IEO
Text Label 8000 4600 0    60   ~ 0
A11
Text Label 8000 4400 0    60   ~ 0
A13
Text Label 8000 4300 0    60   ~ 0
A14
Text Label 8000 4200 0    60   ~ 0
A15
Text Label 8000 4500 0    60   ~ 0
A12
Text Label 8000 2850 0    60   ~ 0
D1
Text Label 8000 2750 0    60   ~ 0
D2
Text Label 8000 2650 0    60   ~ 0
D3
Text Label 8000 2950 0    60   ~ 0
D0
Text Label 8000 2350 0    60   ~ 0
D6
Text Label 8000 2250 0    60   ~ 0
D7
Text Label 8000 2550 0    60   ~ 0
D4
Text Label 9000 6850 0    60   ~ 0
VCC
Wire Wire Line
	7900 4600 8400 4600
Wire Wire Line
	7900 4500 8400 4500
Wire Wire Line
	7900 4400 8400 4400
Wire Wire Line
	7900 4300 8400 4300
Wire Wire Line
	7900 4200 8400 4200
Wire Wire Line
	7900 2950 8400 2950
Wire Wire Line
	7900 2850 8400 2850
Wire Wire Line
	7900 2750 8400 2750
Wire Wire Line
	7900 2650 8400 2650
Wire Wire Line
	7900 2550 8400 2550
Wire Wire Line
	7900 2350 8400 2350
Wire Wire Line
	7900 2250 8400 2250
Wire Wire Line
	8900 6850 9400 6850
Text Label 9000 4100 0    60   ~ 0
VCC
Wire Wire Line
	8900 4100 9400 4100
Text Label 8000 4100 0    60   ~ 0
VCC
Wire Wire Line
	7900 4100 8400 4100
Text Label 9000 1350 0    60   ~ 0
VCC
Wire Wire Line
	8900 1350 9400 1350
Text Label 8000 1350 0    60   ~ 0
VCC
Wire Wire Line
	7900 1350 8400 1350
Text Label 8000 3750 0    60   ~ 0
GND
Wire Wire Line
	7900 3750 8400 3750
Text Label 9000 3750 0    60   ~ 0
GND
Wire Wire Line
	8900 3750 9400 3750
Text Label 8000 6500 0    60   ~ 0
GND
Wire Wire Line
	7900 6500 8400 6500
Text Label 9000 6500 0    60   ~ 0
GND
Wire Wire Line
	8900 6500 9400 6500
Text Label 8000 9250 0    60   ~ 0
GND
Wire Wire Line
	7900 9250 8400 9250
Text Label 9000 9250 0    60   ~ 0
GND
Wire Wire Line
	8900 9250 9400 9250
Wire Wire Line
	7900 5100 8400 5100
Wire Wire Line
	7900 5200 8400 5200
Wire Wire Line
	7900 5300 8400 5300
Wire Wire Line
	7900 5400 8400 5400
Wire Wire Line
	7900 5500 8400 5500
Wire Wire Line
	7900 5600 8400 5600
Wire Wire Line
	7900 5700 8400 5700
Wire Wire Line
	7900 5800 8400 5800
Wire Wire Line
	7900 4700 8400 4700
Wire Wire Line
	7900 4800 8400 4800
Wire Wire Line
	7900 4900 8400 4900
Text Label 8000 5400 0    60   ~ 0
A4
Text Label 8000 5100 0    60   ~ 0
A7
Text Label 8000 5200 0    60   ~ 0
A6
Text Label 8000 5300 0    60   ~ 0
A5
Text Label 8000 5800 0    60   ~ 0
A0
Text Label 8000 5500 0    60   ~ 0
A3
Text Label 8000 5600 0    60   ~ 0
A2
Text Label 8000 5700 0    60   ~ 0
A1
Text Label 8000 4900 0    60   ~ 0
A8
Text Label 8000 4700 0    60   ~ 0
A10
Text Label 8000 4800 0    60   ~ 0
A9
Wire Wire Line
	7900 2450 8400 2450
Text Label 8000 2450 0    60   ~ 0
D5
Wire Wire Line
	9400 9150 8900 9150
Wire Wire Line
	8400 9150 7900 9150
Text Label 9300 9150 2    60   ~ 0
I2C_TX
Text Label 8300 9150 2    60   ~ 0
I2C_RX
Text Label 9000 5600 0    60   ~ 0
A18
Text Label 9000 5700 0    60   ~ 0
A17
Text Label 9000 5800 0    60   ~ 0
A16
Text Label 9000 5500 0    60   ~ 0
A19
Wire Wire Line
	8900 5500 9400 5500
Wire Wire Line
	8900 5600 9400 5600
Wire Wire Line
	8900 5700 9400 5700
Wire Wire Line
	8900 5800 9400 5800
Wire Wire Line
	8400 3550 7900 3550
Wire Wire Line
	8900 7550 9400 7550
Wire Wire Line
	8900 7650 9400 7650
Wire Wire Line
	8400 6000 7900 6000
Wire Wire Line
	8400 6100 7900 6100
Wire Wire Line
	8400 3150 7900 3150
Wire Wire Line
	8400 3450 7900 3450
Wire Wire Line
	8400 3350 7900 3350
Wire Wire Line
	8400 3250 7900 3250
Wire Wire Line
	9400 7450 8900 7450
Wire Wire Line
	8400 6300 7900 6300
Wire Wire Line
	8400 6200 7900 6200
Wire Wire Line
	8400 3050 7900 3050
Wire Wire Line
	8400 3650 7900 3650
Text Label 9000 5200 0    60   ~ 0
A22
Text Label 9000 5300 0    60   ~ 0
A21
Text Label 9000 5400 0    60   ~ 0
A20
Text Label 9000 5100 0    60   ~ 0
A23
Wire Wire Line
	8900 5100 9400 5100
Wire Wire Line
	8900 5200 9400 5200
Wire Wire Line
	8900 5300 9400 5300
Wire Wire Line
	8900 5400 9400 5400
Text Label 9000 4800 0    60   ~ 0
A25
Text Label 9000 4700 0    60   ~ 0
A26
Text Label 9000 4900 0    60   ~ 0
A24
Wire Wire Line
	8900 4900 9400 4900
Wire Wire Line
	8900 4800 9400 4800
Wire Wire Line
	8900 4700 9400 4700
Wire Wire Line
	8900 4200 9400 4200
Wire Wire Line
	8900 4300 9400 4300
Wire Wire Line
	8900 4400 9400 4400
Wire Wire Line
	8900 4500 9400 4500
Wire Wire Line
	8900 4600 9400 4600
Text Label 9000 4500 0    60   ~ 0
A28
Text Label 9000 4200 0    60   ~ 0
A31
Text Label 9000 4300 0    60   ~ 0
A30
Text Label 9000 4400 0    60   ~ 0
A29
Text Label 9000 4600 0    60   ~ 0
A27
Wire Wire Line
	8900 3150 9400 3150
Wire Wire Line
	8900 3250 9400 3250
Wire Wire Line
	8900 3350 9400 3350
Wire Wire Line
	8900 3050 9400 3050
Wire Wire Line
	8900 3450 9400 3450
Text Label 8000 2050 0    60   ~ 0
D9
Text Label 8000 1950 0    60   ~ 0
D10
Text Label 8000 1850 0    60   ~ 0
D11
Text Label 8000 2150 0    60   ~ 0
D8
Text Label 8000 1550 0    60   ~ 0
D14
Text Label 8000 1450 0    60   ~ 0
D15
Text Label 8000 1750 0    60   ~ 0
D12
Wire Wire Line
	7900 2150 8400 2150
Wire Wire Line
	7900 2050 8400 2050
Wire Wire Line
	7900 1950 8400 1950
Wire Wire Line
	7900 1850 8400 1850
Wire Wire Line
	7900 1750 8400 1750
Wire Wire Line
	7900 1550 8400 1550
Wire Wire Line
	7900 1450 8400 1450
Wire Wire Line
	7900 1650 8400 1650
Text Label 8000 1650 0    60   ~ 0
D13
Text Label 9000 5000 0    60   ~ 0
+12V
Wire Wire Line
	8900 5000 9400 5000
Text Label 8000 5000 0    60   ~ 0
+12V
Text Label 9000 2850 0    60   ~ 0
D17
Text Label 9000 2750 0    60   ~ 0
D18
Text Label 9000 2650 0    60   ~ 0
D19
Text Label 9000 2950 0    60   ~ 0
D16
Text Label 9000 2350 0    60   ~ 0
D22
Text Label 9000 2250 0    60   ~ 0
D23
Text Label 9000 2550 0    60   ~ 0
D20
Wire Wire Line
	8900 2950 9400 2950
Wire Wire Line
	8900 2850 9400 2850
Wire Wire Line
	8900 2750 9400 2750
Wire Wire Line
	8900 2650 9400 2650
Wire Wire Line
	8900 2550 9400 2550
Wire Wire Line
	8900 2350 9400 2350
Wire Wire Line
	8900 2250 9400 2250
Wire Wire Line
	8900 2450 9400 2450
Text Label 9000 2450 0    60   ~ 0
D21
Text Label 9000 2050 0    60   ~ 0
D25
Text Label 9000 1950 0    60   ~ 0
D26
Text Label 9000 1850 0    60   ~ 0
D27
Text Label 9000 2150 0    60   ~ 0
D24
Text Label 9000 1550 0    60   ~ 0
D30
Text Label 9000 1450 0    60   ~ 0
D31
Text Label 9000 1750 0    60   ~ 0
D28
Wire Wire Line
	8900 2150 9400 2150
Wire Wire Line
	8900 2050 9400 2050
Wire Wire Line
	8900 1950 9400 1950
Wire Wire Line
	8900 1850 9400 1850
Wire Wire Line
	8900 1750 9400 1750
Wire Wire Line
	8900 1550 9400 1550
Wire Wire Line
	8900 1450 9400 1450
Wire Wire Line
	8900 1650 9400 1650
Text Label 9000 1650 0    60   ~ 0
D29
Wire Wire Line
	7900 5000 8400 5000
Text Label 9000 8550 0    60   ~ 0
USER1
Text Label 9000 8650 0    60   ~ 0
USER0
Text Label 9000 8450 0    60   ~ 0
USER2
Wire Wire Line
	8900 8450 9400 8450
Wire Wire Line
	8900 8550 9400 8550
Wire Wire Line
	8900 8650 9400 8650
Text Label 9000 8250 0    60   ~ 0
USER4
Text Label 9000 8350 0    60   ~ 0
USER3
Text Label 9000 8150 0    60   ~ 0
USER5
Wire Wire Line
	8900 8150 9400 8150
Wire Wire Line
	8900 8250 9400 8250
Wire Wire Line
	8900 8350 9400 8350
Text Label 9000 8050 0    60   ~ 0
USER6
Text Label 9000 7850 0    60   ~ 0
USER8
Wire Wire Line
	8900 7850 9400 7850
Wire Wire Line
	8900 7950 9400 7950
Wire Wire Line
	8900 8050 9400 8050
Text Label 9000 7750 0    60   ~ 0
USER9
Wire Wire Line
	8900 7750 9400 7750
Text Label 9000 7950 0    60   ~ 0
USER7
Text Label 9000 3450 0    60   ~ 0
S0
Text Label 9000 3350 0    60   ~ 0
S1
Text Label 9000 3250 0    60   ~ 0
S2
Text Label 8000 6300 0    60   ~ 0
IC0
Text Label 8000 6200 0    60   ~ 0
IC1
Text Label 8000 6100 0    60   ~ 0
IC2
Text Label 8000 6000 0    60   ~ 0
IC3
Text Label 9000 7650 0    60   ~ 0
CRUIN
Text Label 9000 7550 0    60   ~ 0
CRUOUT
Text Label 9000 7450 0    60   ~ 0
CRYCCLK
Text Label 9000 6950 0    60   ~ 0
E
Wire Wire Line
	9400 7350 8900 7350
Wire Wire Line
	9400 7250 8900 7250
Wire Wire Line
	8900 6000 9400 6000
Wire Wire Line
	8900 6100 9400 6100
Wire Wire Line
	9400 7150 8900 7150
Wire Wire Line
	9400 7050 8900 7050
Wire Wire Line
	9400 6950 8900 6950
Text Label 9000 6100 0    60   ~ 0
~DREQ1
Text Label 9000 7350 0    60   ~ 0
~INT1
Text Label 9000 7250 0    60   ~ 0
~INT2
Text Label 9000 6000 0    60   ~ 0
~TEND1
Text Label 9000 7150 0    60   ~ 0
PHI
Text Label 9000 7050 0    60   ~ 0
ST
Text Label 9000 6200 0    60   ~ 0
~TEND0
Wire Wire Line
	8900 6200 9400 6200
Text Label 9000 6300 0    60   ~ 0
~DREQ0
Wire Wire Line
	8900 6300 9400 6300
Text Label 9000 3550 0    60   ~ 0
AUXCLK3
Text Label 9000 3650 0    60   ~ 0
AUXCLK2
Text Label 8000 6400 0    60   ~ 0
AUXCLK1
Text Label 9000 6400 0    60   ~ 0
AUXCLK0
Wire Wire Line
	9400 3550 8900 3550
Wire Wire Line
	7900 6400 8400 6400
Wire Wire Line
	8900 3650 9400 3650
Wire Wire Line
	8900 6400 9400 6400
Wire Wire Line
	9400 9050 8900 9050
Text Label 9000 8850 0    60   ~ 0
~BAO-1
Wire Wire Line
	9400 8850 8900 8850
Text Label 9000 8750 0    60   ~ 0
~BAI-1
Wire Wire Line
	9400 8750 8900 8750
Text Label 9000 3050 0    60   ~ 0
UDS
Text Label 9000 3150 0    60   ~ 0
LDS
Text Label 8000 3050 0    60   ~ 0
BUSERR
Text Label 8000 3150 0    60   ~ 0
VPA
Text Label 8000 3250 0    60   ~ 0
VMA
Text Label 8000 3350 0    60   ~ 0
~BHE
Text Label 8000 3450 0    60   ~ 0
IPL2
Text Label 8000 3550 0    60   ~ 0
IPL1
Text Label 8000 3650 0    60   ~ 0
IPL0
Wire Wire Line
	9400 8950 8900 8950
Text Label 9000 9050 0    60   ~ 0
~IEO-1
Text Label 9000 8950 0    60   ~ 0
~IEI-1
Wire Wire Line
	8900 5900 9400 5900
Text Label 9000 5900 0    60   ~ 0
-12V
Wire Wire Line
	7900 5900 8400 5900
Text Label 8000 5900 0    60   ~ 0
-12V
Wire Wire Line
	7900 9050 8400 9050
Wire Wire Line
	7900 8350 8400 8350
Wire Wire Line
	7900 8450 8400 8450
Wire Wire Line
	7900 8550 8400 8550
Wire Wire Line
	7900 8650 8400 8650
Wire Wire Line
	7900 8750 8400 8750
Wire Wire Line
	7900 8850 8400 8850
Wire Wire Line
	7900 8950 8400 8950
Text Label 8000 9050 0    60   ~ 0
~EIRQ0
Text Label 8000 8950 0    60   ~ 0
~EIRQ1
Text Label 8000 8850 0    60   ~ 0
~EIRQ2
Text Label 8000 8750 0    60   ~ 0
~EIRQ3
Text Label 8000 8650 0    60   ~ 0
~EIRQ4
Text Label 8000 8550 0    60   ~ 0
~EIRQ5
Text Label 8000 8450 0    60   ~ 0
~EIRQ6
Text Label 8000 8350 0    60   ~ 0
~EIRQ7
Text Label 8000 7250 0    60   ~ 0
~MREQ
Text Label 8000 7150 0    60   ~ 0
~IORQ
Text Label 8000 7550 0    60   ~ 0
CLK
Wire Wire Line
	7900 8150 8400 8150
Wire Wire Line
	7900 7150 8400 7150
Wire Wire Line
	7900 7250 8400 7250
Text Label 8000 8150 0    60   ~ 0
~HALT
Wire Wire Line
	7900 7550 8400 7550
Wire Wire Line
	7900 6950 8400 6950
Wire Wire Line
	7900 7050 8400 7050
Wire Wire Line
	7900 7450 8400 7450
Wire Wire Line
	7900 8250 8400 8250
Wire Wire Line
	7900 7350 8400 7350
Text Label 8000 6950 0    60   ~ 0
~RD
Text Label 8000 7050 0    60   ~ 0
~WR
Text Label 8000 7350 0    60   ~ 0
~M1
Text Label 8000 7450 0    60   ~ 0
~BUSACK
Text Label 8000 8250 0    60   ~ 0
~RFSH
Text Label 8000 7950 0    60   ~ 0
~BUSRQ
Text Label 8000 8050 0    60   ~ 0
~WAIT
Text Label 8000 7850 0    60   ~ 0
~RESET
Wire Wire Line
	7900 7850 8400 7850
Wire Wire Line
	7900 8050 8400 8050
Wire Wire Line
	7900 7950 8400 7950
Wire Wire Line
	7900 6850 8400 6850
Text Label 8000 6850 0    60   ~ 0
VCC
Wire Wire Line
	7900 7650 8400 7650
Wire Wire Line
	7900 7750 8400 7750
Text Label 8000 7650 0    60   ~ 0
~INT0
Text Label 8000 7750 0    60   ~ 0
~NMI
NoConn ~ 9400 1450
NoConn ~ 9400 1550
NoConn ~ 9400 1650
NoConn ~ 9400 1750
NoConn ~ 9400 1850
NoConn ~ 9400 1950
NoConn ~ 9400 2050
NoConn ~ 9400 2150
NoConn ~ 9400 2250
NoConn ~ 9400 2350
NoConn ~ 9400 2450
NoConn ~ 9400 2550
NoConn ~ 9400 2650
NoConn ~ 9400 2750
NoConn ~ 9400 2850
NoConn ~ 9400 2950
NoConn ~ 9400 3050
NoConn ~ 9400 3150
NoConn ~ 9400 3250
NoConn ~ 9400 3350
NoConn ~ 9400 3450
NoConn ~ 9400 3550
NoConn ~ 9400 3650
NoConn ~ 7900 1450
NoConn ~ 7900 1550
NoConn ~ 7900 1650
NoConn ~ 7900 1750
NoConn ~ 7900 1850
NoConn ~ 7900 1950
NoConn ~ 7900 2050
NoConn ~ 7900 2150
NoConn ~ 7900 2250
NoConn ~ 7900 2350
NoConn ~ 7900 2450
NoConn ~ 7900 2550
NoConn ~ 7900 2650
NoConn ~ 7900 2750
NoConn ~ 7900 2850
NoConn ~ 7900 2950
NoConn ~ 7900 3050
NoConn ~ 7900 3150
NoConn ~ 7900 3250
NoConn ~ 7900 3350
NoConn ~ 7900 3450
NoConn ~ 7900 3550
NoConn ~ 7900 3650
NoConn ~ 7900 4200
NoConn ~ 7900 4300
NoConn ~ 7900 4400
NoConn ~ 7900 4500
NoConn ~ 7900 4600
NoConn ~ 7900 4700
NoConn ~ 7900 4800
NoConn ~ 7900 4900
NoConn ~ 7900 5100
NoConn ~ 7900 5200
NoConn ~ 7900 5300
NoConn ~ 7900 5400
NoConn ~ 7900 5500
NoConn ~ 7900 5600
NoConn ~ 7900 5700
NoConn ~ 7900 5800
NoConn ~ 7900 6000
NoConn ~ 7900 6100
NoConn ~ 7900 6200
NoConn ~ 7900 6300
NoConn ~ 7900 6400
NoConn ~ 9400 6400
NoConn ~ 9400 6300
NoConn ~ 9400 6200
NoConn ~ 9400 6100
NoConn ~ 9400 6000
NoConn ~ 9400 5800
NoConn ~ 9400 5700
NoConn ~ 9400 5600
NoConn ~ 9400 5500
NoConn ~ 9400 5400
NoConn ~ 9400 5300
NoConn ~ 9400 5200
NoConn ~ 9400 5100
NoConn ~ 9400 4900
NoConn ~ 9400 4800
NoConn ~ 9400 4700
NoConn ~ 9400 4600
NoConn ~ 9400 4500
NoConn ~ 9400 4400
NoConn ~ 9400 4300
NoConn ~ 9400 4200
NoConn ~ 7900 6950
NoConn ~ 7900 7050
NoConn ~ 7900 7150
NoConn ~ 7900 7250
NoConn ~ 7900 7350
NoConn ~ 7900 7450
NoConn ~ 7900 7550
NoConn ~ 7900 7650
NoConn ~ 7900 7750
NoConn ~ 7900 7850
NoConn ~ 7900 7950
NoConn ~ 7900 8050
NoConn ~ 7900 8150
NoConn ~ 7900 8250
NoConn ~ 7900 8350
NoConn ~ 7900 8450
NoConn ~ 7900 8550
NoConn ~ 7900 8650
NoConn ~ 7900 8750
NoConn ~ 7900 8850
NoConn ~ 7900 8950
NoConn ~ 7900 9050
NoConn ~ 7900 9150
NoConn ~ 9400 9150
NoConn ~ 9400 8650
NoConn ~ 9400 8550
NoConn ~ 9400 8450
NoConn ~ 9400 8350
NoConn ~ 9400 8250
NoConn ~ 9400 8150
NoConn ~ 9400 8050
NoConn ~ 9400 7950
NoConn ~ 9400 7850
NoConn ~ 9400 7750
NoConn ~ 9400 7650
NoConn ~ 9400 7550
NoConn ~ 9400 7450
NoConn ~ 9400 7350
NoConn ~ 9400 7250
NoConn ~ 9400 7150
NoConn ~ 9400 7050
NoConn ~ 9400 6950
$EndSCHEMATC
