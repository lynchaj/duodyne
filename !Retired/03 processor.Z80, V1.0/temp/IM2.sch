EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr B 17000 11000
encoding utf-8
Sheet 6 11
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 8700 5750 0    40   Input ~ 0
~CPU-M1
Text GLabel 8700 6450 0    40   Input ~ 0
~IM2-EN
Text GLabel 7850 5450 2    40   Output ~ 0
~IM2-INT
Wire Wire Line
	8900 6450 8700 6450
$Comp
L device:R_Network08 RN?
U 1 1 64713837
P 6100 5950
AR Path="/646800AA/64713837" Ref="RN?"  Part="1" 
AR Path="/6468C3E4/64713837" Ref="RN2"  Part="1" 
F 0 "RN2" H 6488 5996 50  0000 L CNN
F 1 "4700" H 6488 5905 50  0000 L CNN
F 2 "Resistor_THT:R_Array_SIP9" V 6575 5950 50  0001 C CNN
F 3 "http://www.vishay.com/docs/31509/csc.pdf" H 6100 5950 50  0001 C CNN
	1    6100 5950
	1    0    0    1   
$EndComp
Wire Wire Line
	5700 6150 5700 6200
Wire Wire Line
	5700 6200 5450 6200
Text Label 5500 6200 0    40   ~ 0
VCC
Wire Wire Line
	6400 5750 6400 4950
Wire Wire Line
	6300 5750 6300 5050
Wire Wire Line
	6200 5750 6200 5150
Wire Wire Line
	6100 5750 6100 5250
Wire Wire Line
	6000 5750 6000 5350
Wire Wire Line
	5900 5750 5900 5450
Wire Wire Line
	5800 5750 5800 5550
Wire Wire Line
	5700 5750 5700 5650
Wire Wire Line
	5700 5650 5600 5650
Wire Wire Line
	5800 5550 5600 5550
Wire Wire Line
	5900 5450 5600 5450
Wire Wire Line
	6000 5350 5600 5350
Wire Wire Line
	6100 5250 5600 5250
Wire Wire Line
	6200 5150 5600 5150
Wire Wire Line
	5600 5050 6300 5050
Wire Wire Line
	6300 5050 6750 5050
Connection ~ 6300 5050
Wire Wire Line
	5600 4950 6400 4950
Wire Wire Line
	6400 4950 6750 4950
Connection ~ 6400 4950
Text GLabel 6750 5750 0    40   Input ~ 0
ZERO
Text GLabel 8700 5550 0    40   Input ~ 0
ZERO
Text GLabel 10600 5550 2    40   Output ~ 0
D7
Text GLabel 10600 5450 2    40   Output ~ 0
D6
Text GLabel 10600 5350 2    40   Output ~ 0
D5
Text GLabel 10600 5250 2    40   Output ~ 0
D4
Text GLabel 10600 5150 2    40   Output ~ 0
D3
Text GLabel 10600 5050 2    40   Output ~ 0
D2
Text GLabel 10600 4950 2    40   Output ~ 0
D1
Text GLabel 10600 4850 2    40   Output ~ 0
D0
Text GLabel 5600 5650 0    40   Input ~ 0
~EIRQ7
Text GLabel 5600 5550 0    40   Input ~ 0
~EIRQ6
Text GLabel 5600 5450 0    40   Input ~ 0
~EIRQ5
Text GLabel 5600 5350 0    40   Input ~ 0
~EIRQ4
Text GLabel 5600 5250 0    40   Input ~ 0
~EIRQ3
Text GLabel 5600 5150 0    40   Input ~ 0
~EIRQ2
Text GLabel 5600 5050 0    40   Input ~ 0
~EIRQ1
Text GLabel 5600 4950 0    40   Input ~ 0
~EIRQ0
Wire Wire Line
	8900 5850 9100 5850
Wire Wire Line
	8700 5750 9100 5750
Wire Wire Line
	7750 5450 7850 5450
Wire Wire Line
	8700 5550 9100 5550
$Comp
L power:GND #PWR?
U 1 1 6471386A
P 9600 6150
AR Path="/646800AA/6471386A" Ref="#PWR?"  Part="1" 
AR Path="/6468C3E4/6471386A" Ref="#PWR0137"  Part="1" 
F 0 "#PWR0137" H 9600 5900 50  0001 C CNN
F 1 "GND" H 9605 5977 50  0000 C CNN
F 2 "" H 9600 6150 50  0001 C CNN
F 3 "" H 9600 6150 50  0001 C CNN
	1    9600 6150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 64713870
P 7250 6100
AR Path="/646800AA/64713870" Ref="#PWR?"  Part="1" 
AR Path="/6468C3E4/64713870" Ref="#PWR0138"  Part="1" 
F 0 "#PWR0138" H 7250 5850 50  0001 C CNN
F 1 "GND" H 7255 5927 50  0000 C CNN
F 2 "" H 7250 6100 50  0001 C CNN
F 3 "" H 7250 6100 50  0001 C CNN
	1    7250 6100
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 64713876
P 7250 4650
AR Path="/646800AA/64713876" Ref="#PWR?"  Part="1" 
AR Path="/6468C3E4/64713876" Ref="#PWR0139"  Part="1" 
F 0 "#PWR0139" H 7250 4500 50  0001 C CNN
F 1 "VCC" H 7265 4823 50  0000 C CNN
F 2 "" H 7250 4650 50  0001 C CNN
F 3 "" H 7250 4650 50  0001 C CNN
	1    7250 4650
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 6471387C
P 9600 4550
AR Path="/646800AA/6471387C" Ref="#PWR?"  Part="1" 
AR Path="/6468C3E4/6471387C" Ref="#PWR0140"  Part="1" 
F 0 "#PWR0140" H 9600 4400 50  0001 C CNN
F 1 "VCC" H 9615 4723 50  0000 C CNN
F 2 "" H 9600 4550 50  0001 C CNN
F 3 "" H 9600 4550 50  0001 C CNN
	1    9600 4550
	1    0    0    -1  
$EndComp
Wire Wire Line
	10100 5550 10600 5550
Wire Wire Line
	10100 5450 10600 5450
Wire Wire Line
	10100 5350 10600 5350
Wire Wire Line
	10100 5250 10600 5250
Wire Wire Line
	10100 5150 10600 5150
Wire Wire Line
	10100 5050 10600 5050
Wire Wire Line
	10100 4950 10600 4950
Wire Wire Line
	10100 4850 10600 4850
$Comp
L device:Jumper JP?
U 1 1 6471388A
P 8900 6150
AR Path="/646800AA/6471388A" Ref="JP?"  Part="1" 
AR Path="/6468C3E4/6471388A" Ref="JP3"  Part="1" 
F 0 "JP3" V 8854 6276 50  0000 L CNN
F 1 "IM2 EN" V 8945 6276 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 8900 6150 50  0001 C CNN
F 3 "~" H 8900 6150 50  0001 C CNN
	1    8900 6150
	0    1    1    0   
$EndComp
Text Notes 7750 4050 0    60   ~ 0
Interrupt Mode 2 (IM2) Circuit
Wire Wire Line
	8700 5450 8700 5550
Wire Wire Line
	8700 5450 9100 5450
Connection ~ 8700 5450
Wire Wire Line
	8700 5350 8700 5450
Wire Wire Line
	8700 5350 9100 5350
Connection ~ 8700 5350
Wire Wire Line
	8700 5250 8700 5350
Wire Wire Line
	8700 5250 9100 5250
Connection ~ 8700 5250
Wire Wire Line
	8700 4850 8700 5250
Wire Wire Line
	9100 4850 8700 4850
Wire Wire Line
	7750 5150 9100 5150
Wire Wire Line
	7750 5050 9100 5050
Wire Wire Line
	7750 4950 9100 4950
$Comp
L 74xx:74LS373 U?
U 1 1 6471389F
P 9600 5350
AR Path="/646800AA/6471389F" Ref="U?"  Part="1" 
AR Path="/6468C3E4/6471389F" Ref="U16"  Part="1" 
F 0 "U16" H 9600 6500 50  0000 C CNN
F 1 "74LS373" H 9600 6400 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 9600 5350 50  0001 C CNN
F 3 "" H 9600 5350 50  0001 C CNN
	1    9600 5350
	1    0    0    -1  
$EndComp
NoConn ~ 7750 5550
Wire Wire Line
	7250 6050 7250 6100
$Comp
L 74xx:74LS148 U?
U 1 1 647138A7
P 7250 5350
AR Path="/646800AA/647138A7" Ref="U?"  Part="1" 
AR Path="/6468C3E4/647138A7" Ref="U15"  Part="1" 
F 0 "U15" H 7250 6400 50  0000 C CNN
F 1 "74LS148" H 7250 6300 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm" H 7250 5350 50  0001 C CNN
F 3 "" H 7250 5350 50  0001 C CNN
	1    7250 5350
	1    0    0    -1  
$EndComp
Connection ~ 5700 5650
Wire Wire Line
	6750 5650 5700 5650
Connection ~ 5800 5550
Wire Wire Line
	6750 5550 5800 5550
Connection ~ 5900 5450
Wire Wire Line
	6750 5450 5900 5450
Connection ~ 6000 5350
Wire Wire Line
	6750 5350 6000 5350
Connection ~ 6100 5250
Wire Wire Line
	6750 5250 6100 5250
Connection ~ 6200 5150
Wire Wire Line
	6750 5150 6200 5150
$EndSCHEMATC
