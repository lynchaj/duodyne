EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr B 17000 11000
encoding utf-8
Sheet 8 10
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
L conn:CONN_02X08 JP3
U 1 1 643BB4FA
P 7900 5300
AR Path="/643278DF/643BB4FA" Ref="JP3"  Part="1" 
AR Path="/643A3E69/643BB4FA" Ref="JP?"  Part="1" 
F 0 "JP3" H 7900 5750 50  0000 C CNN
F 1 "IO PORT ADDR" H 7950 4850 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x08_P2.54mm_Vertical" H 7900 5300 50  0001 C CNN
F 3 "" H 7900 5300 50  0001 C CNN
	1    7900 5300
	1    0    0    1   
$EndComp
Text Notes 5300 5650 0    60   ~ 0
JP3 Note: Board IO Address Port $78\n(First Board Only)\n1-2 =on - A7 (low)\n3-4 =off - A6 (high)\n5-6 =off - A5 (high)\n7-8 =off - A4 (high)\n9-10 =off - A3 (high)\n11-12 =on - A2 (low)\n13-14 =on - A1 (low)\n15-16 =on - A0(low)
$Comp
L 74xx:74LS688 U4
U 1 1 643BB4FB
P 9950 4950
AR Path="/643278DF/643BB4FB" Ref="U4"  Part="1" 
AR Path="/643A3E69/643BB4FB" Ref="U?"  Part="1" 
F 0 "U4" H 9650 6000 50  0000 C CNN
F 1 "74LS688" H 9650 3900 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 9950 4950 50  0001 C CNN
F 3 "" H 9950 4950 50  0001 C CNN
	1    9950 4950
	1    0    0    -1  
$EndComp
Text Notes 8250 3850 0    60   ~ 0
IO ADDRESS SELECT CIRCUIT
Text Notes 7150 5450 0    60   ~ 0
SET IO \nADDRESS
Connection ~ 7650 5350
Connection ~ 7650 5450
Connection ~ 7650 5550
Wire Wire Line
	8150 5250 8650 5250
Wire Wire Line
	8150 5350 8550 5350
Wire Wire Line
	8150 5450 8450 5450
Wire Wire Line
	8150 5550 8350 5550
Wire Wire Line
	8150 5650 8250 5650
Wire Wire Line
	8250 5850 8250 5650
Connection ~ 8250 5650
Wire Wire Line
	8350 5850 8350 5550
Connection ~ 8350 5550
Wire Wire Line
	8450 5850 8450 5450
Connection ~ 8450 5450
Wire Wire Line
	8550 5850 8550 5350
Connection ~ 8550 5350
Wire Wire Line
	8650 5850 8650 5250
Connection ~ 8650 5250
Wire Wire Line
	7650 5250 7650 5350
Wire Wire Line
	7650 5350 7650 5450
Wire Wire Line
	7650 5450 7650 5550
Wire Wire Line
	7650 5550 7650 5650
Wire Wire Line
	8350 5550 9450 5550
Wire Wire Line
	8450 5450 9450 5450
Wire Wire Line
	8550 5350 9450 5350
Wire Wire Line
	8650 5250 9450 5250
Wire Wire Line
	8750 4350 9450 4350
Wire Wire Line
	8750 4450 9450 4450
Wire Wire Line
	8750 4550 9450 4550
Wire Wire Line
	8750 4650 9450 4650
Wire Wire Line
	8750 4750 9450 4750
Wire Wire Line
	8750 4050 9450 4050
Wire Wire Line
	8250 5650 9450 5650
$Comp
L power:VCC #PWR01
U 1 1 643BB4FC
P 9950 3750
AR Path="/643278DF/643BB4FC" Ref="#PWR01"  Part="1" 
AR Path="/643A3E69/643BB4FC" Ref="#PWR?"  Part="1" 
F 0 "#PWR01" H 9950 3600 50  0001 C CNN
F 1 "VCC" H 9965 3923 50  0000 C CNN
F 2 "" H 9950 3750 50  0001 C CNN
F 3 "" H 9950 3750 50  0001 C CNN
	1    9950 3750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR012
U 1 1 6E2D504A
P 9950 6150
AR Path="/643278DF/6E2D504A" Ref="#PWR012"  Part="1" 
AR Path="/643A3E69/6E2D504A" Ref="#PWR?"  Part="1" 
F 0 "#PWR012" H 9950 5900 50  0001 C CNN
F 1 "GND" H 9955 5977 50  0000 C CNN
F 2 "" H 9950 6150 50  0001 C CNN
F 3 "" H 9950 6150 50  0001 C CNN
	1    9950 6150
	1    0    0    -1  
$EndComp
$Comp
L device:R_Network08 RN1
U 1 1 643BB4FF
P 8650 6050
AR Path="/643278DF/643BB4FF" Ref="RN1"  Part="1" 
AR Path="/643A3E69/643BB4FF" Ref="RN?"  Part="1" 
F 0 "RN1" H 8170 6004 50  0000 R CNN
F 1 "10K" H 8170 6095 50  0000 R CNN
F 2 "Resistor_THT:R_Array_SIP9" V 9125 6050 50  0001 C CNN
F 3 "http://www.vishay.com/docs/31509/csc.pdf" H 8650 6050 50  0001 C CNN
	1    8650 6050
	1    0    0    1   
$EndComp
Wire Wire Line
	8250 6350 8550 6350
Text Label 8300 6350 0    60   ~ 0
VCC
Wire Wire Line
	8250 6350 8250 6250
Wire Wire Line
	8750 4150 9450 4150
Text GLabel 10450 4050 2    40   Output ~ 0
~CS_RTC
Text GLabel 8750 4350 0    40   Input ~ 0
bA3
Text GLabel 8750 4450 0    40   Input ~ 0
bA4
Text GLabel 8750 4550 0    40   Input ~ 0
bA5
Text GLabel 8750 4650 0    40   Input ~ 0
bA6
Text GLabel 8750 4750 0    40   Input ~ 0
bA7
Text GLabel 7650 5650 0    40   Input ~ 0
ZERO
Text Notes 5100 6000 0    60   ~ 0
NOTE: MULTIPLE BOARDS INSTALLED\nMUST HAVE UNIQUE IO PORT ADDRESSES
Wire Wire Line
	7650 4950 7650 5050
Wire Wire Line
	7650 5050 7650 5150
Connection ~ 7650 5050
Wire Wire Line
	7650 5150 7650 5250
Connection ~ 7650 5150
Connection ~ 7650 5250
Wire Wire Line
	8150 5050 8850 5050
Wire Wire Line
	8950 4950 8150 4950
Wire Wire Line
	8950 4950 9450 4950
Connection ~ 8950 4950
Wire Wire Line
	8950 4950 8950 5850
Wire Wire Line
	8150 5150 8750 5150
Wire Wire Line
	8750 5850 8750 5150
Connection ~ 8750 5150
Wire Wire Line
	8750 5150 9450 5150
Wire Wire Line
	8850 5050 8850 5850
Connection ~ 8850 5050
Wire Wire Line
	8850 5050 9450 5050
Wire Wire Line
	8750 4250 9450 4250
Text GLabel 8750 4050 0    40   Input ~ 0
bA0
Text GLabel 8750 4150 0    40   Input ~ 0
bA1
Text GLabel 8750 4250 0    40   Input ~ 0
bA2
Text GLabel 9450 5850 0    40   Input ~ 0
~IO_EN
$EndSCHEMATC
