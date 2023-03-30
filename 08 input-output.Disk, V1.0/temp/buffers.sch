EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr B 17000 11000
encoding utf-8
Sheet 6 7
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
L 74xx:74LS244 U?
U 1 1 6432DD33
P 7100 4600
AR Path="/66E53C87/6432DD33" Ref="U?"  Part="1" 
AR Path="/67336FCA/6432DD33" Ref="U?"  Part="1" 
AR Path="/676A3B2B/6432DD33" Ref="U?"  Part="1" 
AR Path="/644D9FC6/6432DD33" Ref="U16"  Part="1" 
F 0 "U16" H 7200 5300 60  0000 L BNN
F 1 "74LS245" H 6600 5350 60  0000 L TNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 7100 4600 60  0001 C CNN
F 3 "" H 7100 4600 60  0001 C CNN
	1    7100 4600
	1    0    0    -1  
$EndComp
NoConn ~ 7600 6400
Text Notes 6050 8100 0    60   ~ 0
Note: Buffers and Transceivers\nrespond to IO and MEM cycles
Text Notes 6350 1400 0    60   ~ 0
Z80 BUS INTERFACE
Wire Wire Line
	6050 6600 6600 6600
Wire Wire Line
	6050 6800 6600 6800
Wire Wire Line
	6050 6900 6600 6900
Wire Wire Line
	6200 4100 6600 4100
Wire Wire Line
	6200 4200 6600 4200
Wire Wire Line
	6200 4300 6600 4300
Wire Wire Line
	6200 4400 6600 4400
Wire Wire Line
	6200 4500 6600 4500
Wire Wire Line
	6200 4600 6600 4600
Wire Wire Line
	6200 4700 6600 4700
Wire Wire Line
	6200 4800 6600 4800
Wire Wire Line
	6200 5000 6600 5000
Wire Wire Line
	6050 6700 6600 6700
Wire Wire Line
	6050 6200 6600 6200
Wire Wire Line
	6600 7100 6600 7200
$Comp
L 74xx:74LS244 U?
U 1 1 676B4612
P 7100 6700
AR Path="/66E53C87/676B4612" Ref="U?"  Part="1" 
AR Path="/67336FCA/676B4612" Ref="U?"  Part="1" 
AR Path="/676A3B2B/676B4612" Ref="U?"  Part="1" 
AR Path="/644D9FC6/676B4612" Ref="U17"  Part="1" 
F 0 "U17" H 7250 7400 60  0000 C CNN
F 1 "74LS244" H 6750 7400 60  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 7100 6700 60  0001 C CNN
F 3 "" H 7100 6700 60  0001 C CNN
	1    7100 6700
	1    0    0    -1  
$EndComp
NoConn ~ 6600 6400
Wire Wire Line
	6200 2300 6600 2300
Wire Wire Line
	6200 2400 6600 2400
Wire Wire Line
	6200 2500 6600 2500
Wire Wire Line
	6200 2600 6600 2600
Wire Wire Line
	6200 2700 6600 2700
Wire Wire Line
	6200 2000 6600 2000
Wire Wire Line
	6200 2100 6600 2100
Wire Wire Line
	6200 2200 6600 2200
$Comp
L 74xx:74LS244 U?
U 1 1 699B53AB
P 7100 2500
AR Path="/66E53C87/699B53AB" Ref="U?"  Part="1" 
AR Path="/67336FCA/699B53AB" Ref="U?"  Part="1" 
AR Path="/676A3B2B/699B53AB" Ref="U?"  Part="1" 
AR Path="/644D9FC6/699B53AB" Ref="U15"  Part="1" 
F 0 "U15" H 7200 3200 60  0000 L BNN
F 1 "74LS244" H 6600 3250 60  0000 L TNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 7100 2500 60  0001 C CNN
F 3 "" H 7100 2500 60  0001 C CNN
	1    7100 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	6200 2900 6600 2900
Wire Wire Line
	6600 3000 6600 2900
$Comp
L device:LED D?
U 1 1 676B4604
P 8600 6100
AR Path="/66E53C87/676B4604" Ref="D?"  Part="1" 
AR Path="/67336FCA/676B4604" Ref="D?"  Part="1" 
AR Path="/676A3B2B/676B4604" Ref="D?"  Part="1" 
AR Path="/644D9FC6/676B4604" Ref="D8"  Part="1" 
F 0 "D8" H 8600 6200 50  0000 C CNN
F 1 "LED" H 8600 6000 50  0000 C CNN
F 2 "LED_THT:LED_D3.0mm_Horizontal_O3.81mm_Z2.0mm" H 8600 6100 60  0001 C CNN
F 3 "" H 8600 6100 60  0001 C CNN
	1    8600 6100
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 676B45C7
P 8600 5600
AR Path="/66E53C87/676B45C7" Ref="#PWR?"  Part="1" 
AR Path="/67336FCA/676B45C7" Ref="#PWR?"  Part="1" 
AR Path="/676A3B2B/676B45C7" Ref="#PWR?"  Part="1" 
AR Path="/644D9FC6/676B45C7" Ref="#PWR051"  Part="1" 
F 0 "#PWR051" H 8600 5700 30  0001 C CNN
F 1 "VCC" H 8600 5700 30  0000 C CNN
F 2 "" H 8600 5600 60  0001 C CNN
F 3 "" H 8600 5600 60  0001 C CNN
	1    8600 5600
	1    0    0    -1  
$EndComp
Text Notes 8850 6150 1    60   ~ 0
PPIDE CHIP SELECT
Wire Wire Line
	6200 5100 6600 5100
NoConn ~ 6600 6500
NoConn ~ 7600 6500
Wire Wire Line
	8600 5950 8600 5900
Wire Wire Line
	8600 6300 8600 6250
Connection ~ 6600 2900
$Comp
L power:VCC #PWR?
U 1 1 64EEB3C4
P 7100 1700
AR Path="/66E53C87/64EEB3C4" Ref="#PWR?"  Part="1" 
AR Path="/67336FCA/64EEB3C4" Ref="#PWR?"  Part="1" 
AR Path="/676A3B2B/64EEB3C4" Ref="#PWR?"  Part="1" 
AR Path="/644D9FC6/64EEB3C4" Ref="#PWR047"  Part="1" 
F 0 "#PWR047" H 7100 1550 50  0001 C CNN
F 1 "VCC" H 7115 1873 50  0000 C CNN
F 2 "" H 7100 1700 50  0001 C CNN
F 3 "" H 7100 1700 50  0001 C CNN
	1    7100 1700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 64EEBC3F
P 7100 3300
AR Path="/66E53C87/64EEBC3F" Ref="#PWR?"  Part="1" 
AR Path="/67336FCA/64EEBC3F" Ref="#PWR?"  Part="1" 
AR Path="/676A3B2B/64EEBC3F" Ref="#PWR?"  Part="1" 
AR Path="/644D9FC6/64EEBC3F" Ref="#PWR048"  Part="1" 
F 0 "#PWR048" H 7100 3050 50  0001 C CNN
F 1 "GND" H 7105 3127 50  0000 C CNN
F 2 "" H 7100 3300 50  0001 C CNN
F 3 "" H 7100 3300 50  0001 C CNN
	1    7100 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	7600 2300 8000 2300
Wire Wire Line
	7600 2200 8000 2200
Wire Wire Line
	7600 2100 8000 2100
Wire Wire Line
	7600 2000 8000 2000
Wire Wire Line
	7600 2400 8000 2400
Wire Wire Line
	7600 2500 8000 2500
Wire Wire Line
	7600 2600 8000 2600
Wire Wire Line
	7600 2700 8000 2700
Wire Wire Line
	7600 4400 8000 4400
Wire Wire Line
	7600 4300 8000 4300
Wire Wire Line
	7600 4200 8000 4200
Wire Wire Line
	7600 4100 8000 4100
Wire Wire Line
	7600 4500 8000 4500
Wire Wire Line
	7600 4600 8000 4600
Wire Wire Line
	7600 4700 8000 4700
Wire Wire Line
	7600 4800 8000 4800
$Comp
L power:VCC #PWR?
U 1 1 6549DF51
P 7100 3800
AR Path="/66E53C87/6549DF51" Ref="#PWR?"  Part="1" 
AR Path="/67336FCA/6549DF51" Ref="#PWR?"  Part="1" 
AR Path="/676A3B2B/6549DF51" Ref="#PWR?"  Part="1" 
AR Path="/644D9FC6/6549DF51" Ref="#PWR049"  Part="1" 
F 0 "#PWR049" H 7100 3650 50  0001 C CNN
F 1 "VCC" H 7115 3973 50  0000 C CNN
F 2 "" H 7100 3800 50  0001 C CNN
F 3 "" H 7100 3800 50  0001 C CNN
	1    7100 3800
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 676B4608
P 7100 5400
AR Path="/66E53C87/676B4608" Ref="#PWR?"  Part="1" 
AR Path="/67336FCA/676B4608" Ref="#PWR?"  Part="1" 
AR Path="/676A3B2B/676B4608" Ref="#PWR?"  Part="1" 
AR Path="/644D9FC6/676B4608" Ref="#PWR050"  Part="1" 
F 0 "#PWR050" H 7100 5150 50  0001 C CNN
F 1 "GND" H 7105 5227 50  0000 C CNN
F 2 "" H 7100 5400 50  0001 C CNN
F 3 "" H 7100 5400 50  0001 C CNN
	1    7100 5400
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 65A31167
P 7100 5900
AR Path="/66E53C87/65A31167" Ref="#PWR?"  Part="1" 
AR Path="/67336FCA/65A31167" Ref="#PWR?"  Part="1" 
AR Path="/676A3B2B/65A31167" Ref="#PWR?"  Part="1" 
AR Path="/644D9FC6/65A31167" Ref="#PWR052"  Part="1" 
F 0 "#PWR052" H 7100 5750 50  0001 C CNN
F 1 "VCC" H 7115 6073 50  0000 C CNN
F 2 "" H 7100 5900 50  0001 C CNN
F 3 "" H 7100 5900 50  0001 C CNN
	1    7100 5900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 676B460A
P 7100 7500
AR Path="/66E53C87/676B460A" Ref="#PWR?"  Part="1" 
AR Path="/67336FCA/676B460A" Ref="#PWR?"  Part="1" 
AR Path="/676A3B2B/676B460A" Ref="#PWR?"  Part="1" 
AR Path="/644D9FC6/676B460A" Ref="#PWR053"  Part="1" 
F 0 "#PWR053" H 7100 7250 50  0001 C CNN
F 1 "GND" H 7105 7327 50  0000 C CNN
F 2 "" H 7100 7500 50  0001 C CNN
F 3 "" H 7100 7500 50  0001 C CNN
	1    7100 7500
	1    0    0    -1  
$EndComp
Connection ~ 6600 7100
Wire Wire Line
	6050 6300 6600 6300
Wire Wire Line
	6050 7100 6600 7100
Wire Wire Line
	7600 6200 8150 6200
Wire Wire Line
	7600 6800 8150 6800
Wire Wire Line
	7600 6600 8150 6600
Wire Wire Line
	7600 6900 8150 6900
Wire Wire Line
	7600 6700 8150 6700
Wire Wire Line
	7600 6300 8600 6300
$Comp
L device:R R?
U 1 1 676B4616
P 8600 5750
AR Path="/66E53C87/676B4616" Ref="R?"  Part="1" 
AR Path="/67336FCA/676B4616" Ref="R?"  Part="1" 
AR Path="/676A3B2B/676B4616" Ref="R?"  Part="1" 
AR Path="/644D9FC6/676B4616" Ref="R31"  Part="1" 
F 0 "R31" V 8680 5750 50  0000 C CNN
F 1 "470" V 8600 5750 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 8600 5750 60  0001 C CNN
F 3 "" H 8600 5750 60  0001 C CNN
	1    8600 5750
	-1   0    0    1   
$EndComp
Text GLabel 6200 2000 0    40   Input ~ 0
A0
Text GLabel 6200 2100 0    40   Input ~ 0
A1
Text GLabel 6200 2200 0    40   Input ~ 0
A2
Text GLabel 6200 2300 0    40   Input ~ 0
A3
Text GLabel 6200 2400 0    40   Input ~ 0
A4
Text GLabel 6200 2500 0    40   Input ~ 0
A5
Text GLabel 6200 2600 0    40   Input ~ 0
A6
Text GLabel 6200 2700 0    40   Input ~ 0
A7
Text GLabel 6200 4100 0    40   BiDi ~ 0
D0
Text GLabel 6200 4200 0    40   BiDi ~ 0
D1
Text GLabel 6200 4300 0    40   BiDi ~ 0
D2
Text GLabel 6200 4400 0    40   BiDi ~ 0
D3
Text GLabel 6200 4500 0    40   BiDi ~ 0
D4
Text GLabel 6200 4600 0    40   BiDi ~ 0
D5
Text GLabel 6200 4700 0    40   BiDi ~ 0
D6
Text GLabel 6200 4800 0    40   BiDi ~ 0
D7
Text GLabel 6200 5000 0    40   Input ~ 0
~RD
Text GLabel 6050 6200 0    40   Input ~ 0
~RESET
Text GLabel 6050 6600 0    40   Input ~ 0
~IORQ
Text GLabel 6050 6700 0    40   Input ~ 0
~M1
Text GLabel 6050 6800 0    40   Input ~ 0
~WR
Text GLabel 6050 6900 0    40   Input ~ 0
~RD
Text GLabel 8000 2000 2    40   Output ~ 0
bA0
Text GLabel 8000 2100 2    40   Output ~ 0
bA1
Text GLabel 8000 2200 2    40   Output ~ 0
bA2
Text GLabel 8000 2300 2    40   Output ~ 0
bA3
Text GLabel 8000 2400 2    40   Output ~ 0
bA4
Text GLabel 8000 2500 2    40   Output ~ 0
bA5
Text GLabel 8000 2600 2    40   Output ~ 0
bA6
Text GLabel 8000 2700 2    40   Output ~ 0
bA7
Text GLabel 8000 4100 2    40   BiDi ~ 0
bD0
Text GLabel 8000 4200 2    40   BiDi ~ 0
bD1
Text GLabel 8000 4300 2    40   BiDi ~ 0
bD2
Text GLabel 8000 4400 2    40   BiDi ~ 0
bD3
Text GLabel 8000 4500 2    40   BiDi ~ 0
bD4
Text GLabel 8000 4600 2    40   BiDi ~ 0
bD5
Text GLabel 8000 4700 2    40   BiDi ~ 0
bD6
Text GLabel 8000 4800 2    40   BiDi ~ 0
bD7
Text GLabel 8150 6200 2    40   Output ~ 0
~bRESET
Text GLabel 8150 6600 2    40   Output ~ 0
~bIORQ
Text GLabel 8150 6700 2    40   Output ~ 0
~bM1
Text GLabel 8150 6800 2    40   Output ~ 0
~bWR
Text GLabel 8150 6900 2    40   Output ~ 0
~bRD
Text GLabel 6200 5100 0    40   Input ~ 0
~BUS_EN
Text GLabel 6050 6300 0    40   Input ~ 0
~CS_PPIDE
Text GLabel 6050 7100 0    40   Input ~ 0
ZERO
Text GLabel 6200 2900 0    40   Input ~ 0
ZERO
$EndSCHEMATC
