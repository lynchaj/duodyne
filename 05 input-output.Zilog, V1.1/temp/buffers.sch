EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr B 17000 11000
encoding utf-8
Sheet 4 9
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 7800 1500 0    60   ~ 0
Z80 BUS INTERFACE
Wire Wire Line
	7950 7300 7150 7300
Wire Wire Line
	7950 7200 7150 7200
Wire Wire Line
	7150 4900 7950 4900
Wire Wire Line
	7150 4800 7950 4800
Wire Wire Line
	7150 4700 7950 4700
Wire Wire Line
	7150 4600 7950 4600
Wire Wire Line
	7150 4500 7950 4500
Wire Wire Line
	7150 4400 7950 4400
Wire Wire Line
	7150 4300 7950 4300
Wire Wire Line
	7150 4200 7950 4200
Wire Wire Line
	8950 4900 9750 4900
Wire Wire Line
	8950 4800 9750 4800
Wire Wire Line
	8950 4700 9750 4700
Wire Wire Line
	8950 4600 9750 4600
Wire Wire Line
	8950 4500 9750 4500
Wire Wire Line
	8950 4400 9750 4400
Wire Wire Line
	8950 4300 9750 4300
Wire Wire Line
	8950 4200 9750 4200
Wire Wire Line
	7150 2400 7950 2400
Wire Wire Line
	7150 2300 7950 2300
Wire Wire Line
	7150 2200 7950 2200
Wire Wire Line
	7150 2100 7950 2100
Wire Wire Line
	8950 2400 9750 2400
Wire Wire Line
	8950 2200 9750 2200
Wire Wire Line
	8950 2100 9750 2100
Wire Wire Line
	7150 7000 7950 7000
Wire Wire Line
	7150 6900 7950 6900
Wire Wire Line
	7150 6800 7950 6800
Wire Wire Line
	7150 6700 7950 6700
Wire Wire Line
	7150 6600 7950 6600
Wire Wire Line
	7150 6500 7950 6500
Wire Wire Line
	7150 6400 7950 6400
Wire Wire Line
	7150 6300 7950 6300
Wire Wire Line
	8950 7000 9750 7000
Wire Wire Line
	8950 6900 9750 6900
Wire Wire Line
	8950 6800 9750 6800
Wire Wire Line
	8950 6700 9750 6700
Wire Wire Line
	8950 6600 9750 6600
Wire Wire Line
	8950 6500 9750 6500
Wire Wire Line
	8950 6400 9750 6400
Wire Wire Line
	8950 6300 9750 6300
Wire Wire Line
	7150 2700 7950 2700
Wire Wire Line
	7150 2600 7950 2600
Wire Wire Line
	7150 2800 7950 2800
Wire Wire Line
	8950 2700 9750 2700
Wire Wire Line
	8950 2600 9750 2600
Wire Wire Line
	8950 2800 9750 2800
Wire Wire Line
	7150 5200 7950 5200
Wire Wire Line
	7150 5100 7950 5100
Wire Wire Line
	7150 3100 7950 3100
Wire Wire Line
	7150 3000 7950 3000
$Comp
L 74xx:74LS241 U4
U 1 1 6C2E7727
P 8450 2600
AR Path="/64BCEB01/6C2E7727" Ref="U4"  Part="1" 
AR Path="/64F87FDC/6C2E7727" Ref="U?"  Part="1" 
F 0 "U4" H 8550 3350 50  0000 C CNN
F 1 "74LS241" H 8200 3350 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 8450 2600 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ls241.pdf" H 8450 2600 50  0001 C CNN
	1    8450 2600
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0103
U 1 1 6C465C34
P 8450 1800
AR Path="/64BCEB01/6C465C34" Ref="#PWR0103"  Part="1" 
AR Path="/64F87FDC/6C465C34" Ref="#PWR?"  Part="1" 
F 0 "#PWR0103" H 8450 1650 50  0001 C CNN
F 1 "VCC" H 8465 1973 50  0000 C CNN
F 2 "" H 8450 1800 50  0001 C CNN
F 3 "" H 8450 1800 50  0001 C CNN
	1    8450 1800
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0104
U 1 1 6C466310
P 8450 3400
AR Path="/64BCEB01/6C466310" Ref="#PWR0104"  Part="1" 
AR Path="/64F87FDC/6C466310" Ref="#PWR?"  Part="1" 
F 0 "#PWR0104" H 8450 3150 50  0001 C CNN
F 1 "GND" H 8455 3227 50  0000 C CNN
F 2 "" H 8450 3400 50  0001 C CNN
F 3 "" H 8450 3400 50  0001 C CNN
	1    8450 3400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS241 U2
U 1 1 6C5C0A57
P 8450 4700
AR Path="/64BCEB01/6C5C0A57" Ref="U2"  Part="1" 
AR Path="/64F87FDC/6C5C0A57" Ref="U?"  Part="1" 
F 0 "U2" H 8550 5450 50  0000 C CNN
F 1 "74LS241" H 8200 5450 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 8450 4700 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ls241.pdf" H 8450 4700 50  0001 C CNN
	1    8450 4700
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0107
U 1 1 6C5C0A61
P 8450 3900
AR Path="/64BCEB01/6C5C0A61" Ref="#PWR0107"  Part="1" 
AR Path="/64F87FDC/6C5C0A61" Ref="#PWR?"  Part="1" 
F 0 "#PWR0107" H 8450 3750 50  0001 C CNN
F 1 "VCC" H 8465 4073 50  0000 C CNN
F 2 "" H 8450 3900 50  0001 C CNN
F 3 "" H 8450 3900 50  0001 C CNN
	1    8450 3900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0108
U 1 1 6C5C0A6B
P 8450 5500
AR Path="/64BCEB01/6C5C0A6B" Ref="#PWR0108"  Part="1" 
AR Path="/64F87FDC/6C5C0A6B" Ref="#PWR?"  Part="1" 
F 0 "#PWR0108" H 8450 5250 50  0001 C CNN
F 1 "GND" H 8455 5327 50  0000 C CNN
F 2 "" H 8450 5500 50  0001 C CNN
F 3 "" H 8450 5500 50  0001 C CNN
	1    8450 5500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS245 U3
U 1 1 6C874F4F
P 8450 6800
AR Path="/64BCEB01/6C874F4F" Ref="U3"  Part="1" 
AR Path="/64F87FDC/6C874F4F" Ref="U?"  Part="1" 
F 0 "U3" H 8550 7500 50  0000 C CNN
F 1 "74LS245" H 8200 7500 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm" H 8450 6800 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS245" H 8450 6800 50  0001 C CNN
	1    8450 6800
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0112
U 1 1 6C92095D
P 8450 6000
AR Path="/64BCEB01/6C92095D" Ref="#PWR0112"  Part="1" 
AR Path="/64F87FDC/6C92095D" Ref="#PWR?"  Part="1" 
F 0 "#PWR0112" H 8450 5850 50  0001 C CNN
F 1 "VCC" H 8465 6173 50  0000 C CNN
F 2 "" H 8450 6000 50  0001 C CNN
F 3 "" H 8450 6000 50  0001 C CNN
	1    8450 6000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0113
U 1 1 6C921482
P 8450 7600
AR Path="/64BCEB01/6C921482" Ref="#PWR0113"  Part="1" 
AR Path="/64F87FDC/6C921482" Ref="#PWR?"  Part="1" 
F 0 "#PWR0113" H 8450 7350 50  0001 C CNN
F 1 "GND" H 8455 7427 50  0000 C CNN
F 2 "" H 8450 7600 50  0001 C CNN
F 3 "" H 8450 7600 50  0001 C CNN
	1    8450 7600
	1    0    0    -1  
$EndComp
NoConn ~ -5550 23850
Text Notes 10850 2700 1    60   ~ 0
IO CHIP SELECT CS1
$Comp
L device:LED D1
U 1 1 6068F1F7
P 10600 2350
AR Path="/64BCEB01/6068F1F7" Ref="D1"  Part="1" 
AR Path="/64F87FDC/6068F1F7" Ref="D?"  Part="1" 
F 0 "D1" H 10600 2450 50  0000 C CNN
F 1 "LED" H 10600 2250 50  0000 C CNN
F 2 "LED_THT:LED_D3.0mm_Horizontal_O3.81mm_Z2.0mm" H 10600 2350 60  0001 C CNN
F 3 "" H 10600 2350 60  0001 C CNN
	1    10600 2350
	0    -1   -1   0   
$EndComp
Wire Wire Line
	7150 2500 7950 2500
Wire Wire Line
	8950 2500 10600 2500
Text GLabel 7150 2100 0    40   Input ~ 0
CLK
Text GLabel 7150 2200 0    40   Input ~ 0
~IORQ
Text GLabel 7150 2300 0    40   Input ~ 0
~CS2
Text GLabel 7150 2400 0    40   Input ~ 0
~RD
Text GLabel 7150 2500 0    40   Input ~ 0
~CS1
Text GLabel 7150 2600 0    40   Input ~ 0
~M1
Text GLabel 7150 2700 0    40   Input ~ 0
~RESET
Text GLabel 7150 2800 0    40   Input ~ 0
~IEI
Text GLabel 7150 3000 0    40   Input ~ 0
ZERO
Text GLabel 7150 3100 0    40   Input ~ 0
ZERO
Text GLabel 7150 4200 0    40   Input ~ 0
A0
Text GLabel 7150 4300 0    40   Input ~ 0
A1
Text GLabel 7150 4400 0    40   Input ~ 0
A2
Text GLabel 7150 4500 0    40   Input ~ 0
A3
Text GLabel 7150 4600 0    40   Input ~ 0
A4
Text GLabel 7150 4700 0    40   Input ~ 0
A5
Text GLabel 7150 4800 0    40   Input ~ 0
A6
Text GLabel 7150 4900 0    40   Input ~ 0
A7
Text GLabel 7150 5100 0    40   Input ~ 0
ZERO
Text GLabel 7150 5200 0    40   Input ~ 0
ZERO
Text GLabel 7150 6300 0    40   BiDi ~ 0
D0
Text GLabel 7150 6400 0    40   BiDi ~ 0
D1
Text GLabel 7150 6500 0    40   BiDi ~ 0
D2
Text GLabel 7150 6600 0    40   BiDi ~ 0
D3
Text GLabel 7150 6700 0    40   BiDi ~ 0
D4
Text GLabel 7150 6800 0    40   BiDi ~ 0
D5
Text GLabel 7150 6900 0    40   BiDi ~ 0
D6
Text GLabel 7150 7000 0    40   BiDi ~ 0
D7
Text GLabel 7150 7200 0    40   Input ~ 0
DATA_DIR
Text GLabel 7150 7300 0    40   Input ~ 0
ZERO
Text GLabel 9750 2100 2    40   Output ~ 0
bCLK
Text GLabel 9750 2200 2    40   Output ~ 0
~bIORQ_RAW
Text GLabel 9750 2400 2    40   Output ~ 0
~bRD
Text GLabel 9750 2600 2    40   Output ~ 0
~bM1
Text GLabel 9750 2700 2    40   Output ~ 0
~bRESET
Text GLabel 9750 2800 2    40   Output ~ 0
~bIEI
Text GLabel 9750 4200 2    40   Output ~ 0
bA0
Text GLabel 9750 4300 2    40   Output ~ 0
bA1
Text GLabel 9750 4400 2    40   Output ~ 0
bA2
Text GLabel 9750 4500 2    40   Output ~ 0
bA3
Text GLabel 9750 4600 2    40   Output ~ 0
bA4
Text GLabel 9750 4700 2    40   Output ~ 0
bA5
Text GLabel 9750 4800 2    40   Output ~ 0
bA6
Text GLabel 9750 4900 2    40   Output ~ 0
bA7
Text GLabel 9750 6300 2    40   BiDi ~ 0
bD0
Text GLabel 9750 6400 2    40   BiDi ~ 0
bD1
Text GLabel 9750 6500 2    40   BiDi ~ 0
bD2
Text GLabel 9750 6600 2    40   BiDi ~ 0
bD3
Text GLabel 9750 6700 2    40   BiDi ~ 0
bD4
Text GLabel 9750 6800 2    40   BiDi ~ 0
bD5
Text GLabel 9750 6900 2    40   BiDi ~ 0
bD6
Text GLabel 9750 7000 2    40   BiDi ~ 0
bD7
Text Notes 10250 2050 1    60   ~ 0
IO CHIP SELECT CS2
$Comp
L device:LED D2
U 1 1 643EBCBD
P 10400 1600
AR Path="/64BCEB01/643EBCBD" Ref="D2"  Part="1" 
AR Path="/64F87FDC/643EBCBD" Ref="D?"  Part="1" 
F 0 "D2" H 10400 1700 50  0000 C CNN
F 1 "LED" H 10400 1500 50  0000 C CNN
F 2 "LED_THT:LED_D3.0mm_Horizontal_O3.81mm_Z2.0mm" H 10400 1600 60  0001 C CNN
F 3 "" H 10400 1600 60  0001 C CNN
	1    10400 1600
	0    -1   -1   0   
$EndComp
Wire Wire Line
	10400 2300 10400 1750
Wire Wire Line
	8950 2300 10400 2300
Text GLabel 10600 2200 1    40   Input ~ 0
470B
Text GLabel 10400 1450 1    40   Input ~ 0
470C
$EndSCHEMATC
