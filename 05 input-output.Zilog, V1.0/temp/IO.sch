EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr B 17000 11000
encoding utf-8
Sheet 5 9
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
NoConn ~ -5550 23850
Text Notes 5050 4650 0    60   ~ 0
Note: IO Address Port $B0-BF\n1-2 =off - A7 (high)\n3-4 =on - A6 (low)\n5-6 =off - A5 (high)\n7-8 =off - A4 (high)
$Comp
L conn:CONN_02X04 JP2
U 1 1 67982F81
P 5750 5400
F 0 "JP2" H 5750 5650 50  0000 C CNN
F 1 "IO PORT ADDR" H 5750 5150 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x04_P2.54mm_Vertical" H 5750 5400 50  0001 C CNN
F 3 "" H 5750 5400 50  0001 C CNN
	1    5750 5400
	1    0    0    1   
$EndComp
$Comp
L 74xx:74LS688 U24
U 1 1 67982F8B
P 8200 4850
F 0 "U24" H 7900 5900 50  0000 C CNN
F 1 "74LS688" H 7900 3800 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 8200 4850 50  0001 C CNN
F 3 "" H 8200 4850 50  0001 C CNN
	1    8200 4850
	1    0    0    -1  
$EndComp
Text Notes 5050 3650 0    60   ~ 0
IO ADDRESS SELECT CIRCUIT
Text Notes 5650 3950 0    60   ~ 0
Interrupt filter circuit
Connection ~ 5500 5350
Connection ~ 5500 5450
Wire Wire Line
	6000 5250 6400 5250
Wire Wire Line
	6000 5350 6300 5350
Wire Wire Line
	6000 5450 6200 5450
Wire Wire Line
	6000 5550 6100 5550
Wire Wire Line
	6100 5950 6100 5550
Connection ~ 6100 5550
Wire Wire Line
	6200 5950 6200 5450
Connection ~ 6200 5450
Wire Wire Line
	6300 5950 6300 5350
Connection ~ 6300 5350
Wire Wire Line
	6400 5950 6400 5250
Connection ~ 6400 5250
Wire Wire Line
	5500 5250 5500 5350
Wire Wire Line
	5500 5350 5500 5450
Wire Wire Line
	5500 5450 5500 5550
Wire Wire Line
	6200 5450 7700 5450
Wire Wire Line
	6300 5350 7700 5350
Wire Wire Line
	6400 5250 7700 5250
Wire Wire Line
	7300 4350 7700 4350
Wire Wire Line
	7300 4450 7700 4450
Wire Wire Line
	7300 4550 7700 4550
Wire Wire Line
	7300 4650 7700 4650
Wire Wire Line
	8700 3950 9000 3950
Wire Wire Line
	6100 5550 7700 5550
$Comp
L power:VCC #PWR09
U 1 1 67982FB9
P 8200 3650
F 0 "#PWR09" H 8200 3500 50  0001 C CNN
F 1 "VCC" H 8215 3823 50  0000 C CNN
F 2 "" H 8200 3650 50  0001 C CNN
F 3 "" H 8200 3650 50  0001 C CNN
	1    8200 3650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR013
U 1 1 67982FCD
P 8200 6050
F 0 "#PWR013" H 8200 5800 50  0001 C CNN
F 1 "GND" H 8205 5877 50  0000 C CNN
F 2 "" H 8200 6050 50  0001 C CNN
F 3 "" H 8200 6050 50  0001 C CNN
	1    8200 6050
	1    0    0    -1  
$EndComp
$Comp
L device:R_Network08 RN2
U 1 1 67982FD7
P 6500 6150
F 0 "RN2" H 6020 6104 50  0000 R CNN
F 1 "10K" H 6020 6195 50  0000 R CNN
F 2 "Resistor_THT:R_Array_SIP9" V 6975 6150 50  0001 C CNN
F 3 "http://www.vishay.com/docs/31509/csc.pdf" H 6500 6150 50  0001 C CNN
	1    6500 6150
	1    0    0    1   
$EndComp
Wire Wire Line
	5800 6450 6100 6450
Text Label 5850 6450 0    60   ~ 0
VCC
Wire Wire Line
	6100 6450 6100 6350
Wire Wire Line
	7300 3950 7700 3950
Wire Wire Line
	7300 4850 7700 4850
Wire Wire Line
	6800 5950 6800 5150
Wire Wire Line
	6800 4050 7700 4050
Wire Wire Line
	7700 4150 6800 4150
Connection ~ 6800 4150
Wire Wire Line
	6800 4150 6800 4050
Wire Wire Line
	7700 4250 6800 4250
Connection ~ 6800 4250
Wire Wire Line
	6800 4250 6800 4150
Wire Wire Line
	7700 4950 6800 4950
Connection ~ 6800 4950
Wire Wire Line
	6800 4950 6800 4250
Wire Wire Line
	7700 5050 6800 5050
Connection ~ 6800 5050
Wire Wire Line
	6800 5050 6800 4950
Wire Wire Line
	7700 5150 6800 5150
Connection ~ 6800 5150
Wire Wire Line
	6800 5150 6800 5050
Text GLabel 7300 3950 0    40   Input ~ 0
~bIORQ
Text GLabel 7300 4350 0    40   Input ~ 0
bA4
Text GLabel 7300 4450 0    40   Input ~ 0
bA5
Text GLabel 7300 4550 0    40   Input ~ 0
bA6
Text GLabel 7300 4650 0    40   Input ~ 0
bA7
Text GLabel 9000 3950 2    40   Output ~ 0
~CS1
Text Notes 7900 6500 2    40   ~ 0
NOTE: THIS IO DECODER DOES *NOT*\nINCLUDE ~bM1~ BECAUSE IT IS ACTIVE\nDURING INTERRUPT RESPONSES (IM2)
Text Notes 9600 4650 0    60   ~ 0
Note: IO Address Port $C0-C3\n1-2 =off - A7 (high)\n3-4 =off - A6 (high)\n5-6 =on - A5 (low)\n7-8 =on - A4 (low)\n9-10 =on - A3 (low)\n11-12 =off - A2 (high)
$Comp
L conn:CONN_02X06 JP1
U 1 1 6402E84A
P 10300 5300
F 0 "JP1" H 10300 5650 50  0000 C CNN
F 1 "IO PORT ADDR" H 10350 4950 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x06_P2.54mm_Vertical" H 10300 5300 50  0001 C CNN
F 3 "" H 10300 5300 50  0001 C CNN
	1    10300 5300
	1    0    0    1   
$EndComp
$Comp
L 74xx:74LS688 U5
U 1 1 6402E854
P 12750 4850
F 0 "U5" H 12450 5900 50  0000 C CNN
F 1 "74LS688" H 12450 3800 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 12750 4850 50  0001 C CNN
F 3 "" H 12750 4850 50  0001 C CNN
	1    12750 4850
	1    0    0    -1  
$EndComp
Text Notes 9600 3650 0    60   ~ 0
IO ADDRESS SELECT CIRCUIT
Text Notes 10200 3950 0    60   ~ 0
Interrupt filter circuit
Connection ~ 10050 5350
Connection ~ 10050 5450
Wire Wire Line
	10550 5250 10950 5250
Wire Wire Line
	10550 5350 10850 5350
Wire Wire Line
	10550 5450 10750 5450
Wire Wire Line
	10550 5550 10650 5550
Wire Wire Line
	10650 5900 10650 5550
Connection ~ 10650 5550
Wire Wire Line
	10750 5900 10750 5450
Connection ~ 10750 5450
Wire Wire Line
	10850 5900 10850 5350
Connection ~ 10850 5350
Wire Wire Line
	10950 5900 10950 5250
Connection ~ 10950 5250
Wire Wire Line
	10050 5250 10050 5350
Wire Wire Line
	10050 5350 10050 5450
Wire Wire Line
	10050 5450 10050 5550
Wire Wire Line
	10750 5450 12250 5450
Wire Wire Line
	10850 5350 12250 5350
Wire Wire Line
	10950 5250 12250 5250
Wire Wire Line
	11850 4350 12250 4350
Wire Wire Line
	11850 4450 12250 4450
Wire Wire Line
	11850 4550 12250 4550
Wire Wire Line
	11850 4650 12250 4650
Wire Wire Line
	13250 3950 13550 3950
Wire Wire Line
	10650 5550 12250 5550
$Comp
L power:VCC #PWR01
U 1 1 6402E87C
P 12750 3650
F 0 "#PWR01" H 12750 3500 50  0001 C CNN
F 1 "VCC" H 12765 3823 50  0000 C CNN
F 2 "" H 12750 3650 50  0001 C CNN
F 3 "" H 12750 3650 50  0001 C CNN
	1    12750 3650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR03
U 1 1 6402E890
P 12750 6050
F 0 "#PWR03" H 12750 5800 50  0001 C CNN
F 1 "GND" H 12755 5877 50  0000 C CNN
F 2 "" H 12750 6050 50  0001 C CNN
F 3 "" H 12750 6050 50  0001 C CNN
	1    12750 6050
	1    0    0    -1  
$EndComp
$Comp
L device:R_Network08 RN1
U 1 1 6402E89A
P 11050 6100
F 0 "RN1" H 10570 6054 50  0000 R CNN
F 1 "10K" H 10570 6145 50  0000 R CNN
F 2 "Resistor_THT:R_Array_SIP9" V 11525 6100 50  0001 C CNN
F 3 "http://www.vishay.com/docs/31509/csc.pdf" H 11050 6100 50  0001 C CNN
	1    11050 6100
	1    0    0    1   
$EndComp
Wire Wire Line
	10350 6400 10650 6400
Text Label 10400 6400 0    60   ~ 0
VCC
Wire Wire Line
	10650 6400 10650 6300
Wire Wire Line
	11850 3950 12250 3950
Wire Wire Line
	11850 4850 12250 4850
Wire Wire Line
	11350 4050 12250 4050
Wire Wire Line
	12250 4950 11350 4950
Text GLabel 11850 3950 0    40   Input ~ 0
~bIORQ
Text GLabel 11850 4350 0    40   Input ~ 0
bA4
Text GLabel 11850 4450 0    40   Input ~ 0
bA5
Text GLabel 11850 4550 0    40   Input ~ 0
bA6
Text GLabel 11850 4650 0    40   Input ~ 0
bA7
Text GLabel 13550 3950 2    40   Output ~ 0
~CS2
Text Notes 12450 6500 2    40   ~ 0
NOTE: THIS IO DECODER DOES *NOT*\nINCLUDE ~bM1~ BECAUSE IT IS ACTIVE\nDURING INTERRUPT RESPONSES (IM2)
Text GLabel 11850 4250 0    40   Input ~ 0
bA3
Wire Wire Line
	11850 4250 12250 4250
Text GLabel 11850 4150 0    40   Input ~ 0
bA2
Wire Wire Line
	11850 4150 12250 4150
Wire Wire Line
	11050 5900 11050 5150
Wire Wire Line
	11150 5900 11150 5050
Wire Wire Line
	11150 5050 12250 5050
Wire Wire Line
	11350 4050 11350 4950
Connection ~ 11350 4950
Wire Wire Line
	11350 4950 11350 5900
Wire Wire Line
	11050 5150 12250 5150
Wire Wire Line
	10550 5150 11050 5150
Connection ~ 11050 5150
Wire Wire Line
	11150 5050 10550 5050
Connection ~ 11150 5050
Wire Wire Line
	10050 5250 10050 5150
Connection ~ 10050 5250
Connection ~ 10050 5150
Wire Wire Line
	10050 5150 10050 5050
Text Notes 7900 3250 0    40   ~ 0
CTC-SIO-DUAL PIO ZILOG\nPERIPHERALS CHAIN\nIO PORT DECODER\n
Text Notes 12250 3350 0    40   ~ 0
DEDICATED CTC INTERRUPT\nHANDLER IO PORT DECODER\n
Text GLabel 5500 5550 0    40   Input ~ 0
ZERO
Text GLabel 10050 5550 0    40   Input ~ 0
ZERO
Text GLabel 7300 4850 0    40   Input ~ 0
ZERO
Text GLabel 7700 5750 0    40   Input ~ 0
ZERO
Text GLabel 11850 4850 0    40   Input ~ 0
ZERO
Text GLabel 12250 5750 0    40   Input ~ 0
ZERO
Text GLabel 6500 5950 1    40   Output ~ 0
10KA
Text GLabel 6600 5950 1    40   Output ~ 0
10KB
Text GLabel 6700 5950 1    40   Output ~ 0
10KC
Text GLabel 11250 5900 1    40   Output ~ 0
10KD
$EndSCHEMATC
