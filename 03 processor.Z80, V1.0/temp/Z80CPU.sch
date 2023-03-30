EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr B 17000 11000
encoding utf-8
Sheet 9 11
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	9350 4750 9550 4750
Wire Wire Line
	9350 4850 9550 4850
Wire Wire Line
	9350 4950 9550 4950
Wire Wire Line
	9350 5050 9550 5050
Wire Wire Line
	9350 5150 9550 5150
Wire Wire Line
	9350 5250 9550 5250
Wire Wire Line
	9350 5350 9550 5350
Wire Wire Line
	9350 5450 9550 5450
Wire Wire Line
	9350 5550 9550 5550
Wire Wire Line
	9350 5650 9550 5650
Wire Wire Line
	9350 5750 9550 5750
Wire Wire Line
	7150 5250 7950 5250
Wire Wire Line
	7950 5050 7150 5050
Wire Wire Line
	7950 4850 7150 4850
Wire Wire Line
	7950 4250 7150 4250
Text Notes 8150 7200 0    60   ~ 0
Tri-state address, data, & \ncontrol bus during DMA
$Comp
L conn:DIL14 U?
U 1 1 6413E1CC
P 5000 4600
AR Path="/646800AA/6413E1CC" Ref="U?"  Part="1" 
AR Path="/640FA3F5/6413E1CC" Ref="U3"  Part="1" 
AR Path="/64122C47/6413E1CC" Ref="U?"  Part="1" 
F 0 "U3" H 5000 5122 60  0000 C CNN
F 1 "CPU CLOCK" H 5000 5024 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 5000 4600 60  0001 C CNN
F 3 "" H 5000 4600 60  0001 C CNN
	1    5000 4600
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 4600 5550 4600
Wire Wire Line
	5550 4600 5550 4900
Wire Wire Line
	5550 4900 5350 4900
Wire Wire Line
	4650 4600 4400 4600
Wire Wire Line
	4400 4600 4400 4900
Wire Wire Line
	4400 4900 4650 4900
Wire Wire Line
	4400 4950 4400 4900
Connection ~ 4400 4900
NoConn ~ 4650 4400
NoConn ~ 4650 4500
NoConn ~ 4650 4700
NoConn ~ 4650 4800
NoConn ~ 5350 4800
NoConn ~ 5350 4700
NoConn ~ 5350 4500
NoConn ~ 5350 4400
Text Notes 8100 3900 0    60   ~ 0
PROCESSOR, Z80
$Comp
L power:GND #PWR?
U 1 1 6413E1E3
P 4400 4950
AR Path="/646800AA/6413E1E3" Ref="#PWR?"  Part="1" 
AR Path="/640FA3F5/6413E1E3" Ref="#PWR0148"  Part="1" 
AR Path="/64122C47/6413E1E3" Ref="#PWR?"  Part="1" 
F 0 "#PWR0148" H 4400 4700 50  0001 C CNN
F 1 "GND" H 4405 4777 50  0000 C CNN
F 2 "" H 4400 4950 50  0001 C CNN
F 3 "" H 4400 4950 50  0001 C CNN
	1    4400 4950
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 6413E1E9
P 4650 4300
AR Path="/646800AA/6413E1E9" Ref="#PWR?"  Part="1" 
AR Path="/640FA3F5/6413E1E9" Ref="#PWR0149"  Part="1" 
AR Path="/64122C47/6413E1E9" Ref="#PWR?"  Part="1" 
F 0 "#PWR0149" H 4650 4150 50  0001 C CNN
F 1 "VCC" H 4665 4473 50  0000 C CNN
F 2 "" H 4650 4300 50  0001 C CNN
F 3 "" H 4650 4300 50  0001 C CNN
	1    4650 4300
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 6413E1EF
P 5350 4300
AR Path="/646800AA/6413E1EF" Ref="#PWR?"  Part="1" 
AR Path="/640FA3F5/6413E1EF" Ref="#PWR0150"  Part="1" 
AR Path="/64122C47/6413E1EF" Ref="#PWR?"  Part="1" 
F 0 "#PWR0150" H 5350 4150 50  0001 C CNN
F 1 "VCC" H 5365 4473 50  0000 C CNN
F 2 "" H 5350 4300 50  0001 C CNN
F 3 "" H 5350 4300 50  0001 C CNN
	1    5350 4300
	1    0    0    -1  
$EndComp
Wire Wire Line
	9350 5950 9550 5950
Wire Wire Line
	9350 6050 9550 6050
Wire Wire Line
	9350 6150 9550 6150
Wire Wire Line
	9350 6250 9550 6250
Wire Wire Line
	9350 6350 9550 6350
Wire Wire Line
	9350 6450 9550 6450
Wire Wire Line
	9350 6550 9550 6550
Wire Wire Line
	9350 6650 9550 6650
Wire Wire Line
	9350 4250 9550 4250
Wire Wire Line
	9350 4350 9550 4350
Wire Wire Line
	9350 4450 9550 4450
Wire Wire Line
	9350 4550 9550 4550
Wire Wire Line
	9350 4650 9550 4650
Wire Wire Line
	5550 4900 5650 4900
Connection ~ 5550 4900
Wire Wire Line
	7150 5750 7950 5750
Wire Wire Line
	7150 6250 7950 6250
Wire Wire Line
	7150 4350 7950 4350
Wire Wire Line
	7150 5550 7950 5550
Wire Wire Line
	7150 5450 7950 5450
Wire Wire Line
	7150 4550 7950 4550
Wire Wire Line
	7150 4650 7950 4650
Wire Wire Line
	7950 4450 7150 4450
$Comp
L Zilog_z80:Z80CPU-LCC U?
U 1 1 6413E20E
P 8150 4150
AR Path="/646800AA/6413E20E" Ref="U?"  Part="1" 
AR Path="/640FA3F5/6413E20E" Ref="U7"  Part="1" 
AR Path="/64122C47/6413E20E" Ref="U?"  Part="1" 
F 0 "U7" H 8900 4250 59  0000 C CNN
F 1 "Z80CPU-LCC" H 8250 4250 59  0000 C CNN
F 2 "Package_LCC:PLCC-44_THT-Socket" H 8650 2450 50  0001 C CNN
F 3 "https://www.mouser.co.uk/datasheet/2/450/ps0178-19386.pdf" H 8650 2950 50  0001 C CNN
F 4 "Zilog" H 7750 4200 50  0001 C CNN "Manufacturer_Name"
F 5 "Z84C00" H 7650 4350 50  0001 C CNN "Manufacturer_Part_Number"
	1    8150 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	7150 6650 7950 6650
Text Label 7200 6650 0    60   ~ 0
VCC
Text Label 7200 6450 0    60   ~ 0
GND
Wire Wire Line
	7150 6450 7950 6450
Text GLabel 7150 6250 0    40   Input ~ 0
CLK
Wire Wire Line
	7150 6050 7950 6050
Wire Wire Line
	7150 5950 7950 5950
Text GLabel 7150 4850 0    40   Output ~ 0
~CPU-RFSH
Text GLabel 7150 4550 0    40   Output ~ 0
~CPU-RD
Text GLabel 7150 4450 0    40   Output ~ 0
~CPU-IORQ
Text GLabel 7150 4350 0    40   Output ~ 0
~CPU-MREQ
Text GLabel 7150 4250 0    40   Output ~ 0
~CPU-M1
Text GLabel 7150 4650 0    40   Output ~ 0
~CPU-WR
Text GLabel 9550 4250 2    40   Output ~ 0
CPU-A0
Text GLabel 9550 4350 2    40   Output ~ 0
CPU-A1
Text GLabel 7150 6050 0    40   Output ~ 0
~CPU-BUSACK
Text GLabel 7150 5250 0    40   Output ~ 0
~CPU-WAIT
Text GLabel 7150 5950 0    40   Input ~ 0
~CPU-BUSRQ
Text GLabel 9550 4450 2    40   Output ~ 0
CPU-A2
Text GLabel 9550 4550 2    40   Output ~ 0
CPU-A3
Text GLabel 9550 4650 2    40   Output ~ 0
CPU-A4
Text GLabel 9550 4750 2    40   Output ~ 0
CPU-A5
Text GLabel 9550 4850 2    40   Output ~ 0
CPU-A6
Text GLabel 9550 4950 2    40   Output ~ 0
CPU-A7
Text GLabel 9550 5050 2    40   Output ~ 0
CPU-A8
Text GLabel 9550 5150 2    40   Output ~ 0
CPU-A9
Text GLabel 9550 5250 2    40   Output ~ 0
CPU-A10
Text GLabel 9550 5350 2    40   Output ~ 0
CPU-A11
Text GLabel 9550 5450 2    40   Output ~ 0
CPU-A12
Text GLabel 9550 5550 2    40   Output ~ 0
CPU-A13
Text GLabel 9550 5650 2    40   Output ~ 0
CPU-A14
Text GLabel 9550 5750 2    40   Output ~ 0
CPU-A15
Text GLabel 9550 5950 2    40   BiDi ~ 0
CPU-D0
Text GLabel 9550 6050 2    40   BiDi ~ 0
CPU-D1
Text GLabel 9550 6150 2    40   BiDi ~ 0
CPU-D2
Text GLabel 9550 6250 2    40   BiDi ~ 0
CPU-D3
Text GLabel 9550 6350 2    40   BiDi ~ 0
CPU-D4
Text GLabel 9550 6450 2    40   BiDi ~ 0
CPU-D5
Text GLabel 9550 6550 2    40   BiDi ~ 0
CPU-D6
Text GLabel 9550 6650 2    40   BiDi ~ 0
CPU-D7
Text GLabel 5650 4900 2    40   Output ~ 0
RAW-CLK
Text GLabel 7150 5050 0    40   Output ~ 0
~CPU-HALT
Text GLabel 7150 5450 0    40   Input ~ 0
~CPU-INT
Text GLabel 7150 5550 0    40   Input ~ 0
~CPU-NMI
Text GLabel 7150 5750 0    40   Input ~ 0
~CPU-RESET
$Comp
L 74xx:74LS07 U?
U 3 1 64364AAF
P 4650 8150
AR Path="/646800AA/64364AAF" Ref="U?"  Part="3" 
AR Path="/640FA3F5/64364AAF" Ref="U4"  Part="3" 
AR Path="/64122C47/64364AAF" Ref="U?"  Part="3" 
F 0 "U4" H 4600 8200 50  0000 C CNN
F 1 "74LS07" H 4600 8100 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 4650 8150 50  0001 C CNN
F 3 "" H 4650 8150 50  0001 C CNN
	3    4650 8150
	1    0    0    -1  
$EndComp
$Comp
L device:LED D?
U 1 1 64364ABB
P 4950 8000
AR Path="/646800AA/64364ABB" Ref="D?"  Part="1" 
AR Path="/640FA3F5/64364ABB" Ref="D4"  Part="1" 
AR Path="/64122C47/64364ABB" Ref="D?"  Part="1" 
F 0 "D4" H 4950 8100 50  0000 C CNN
F 1 "LED" H 4950 7900 50  0000 C CNN
F 2 "LED_THT:LED_D3.0mm_Horizontal_O3.81mm_Z2.0mm" H 4950 8000 60  0001 C CNN
F 3 "" H 4950 8000 60  0001 C CNN
	1    4950 8000
	0    -1   -1   0   
$EndComp
Wire Wire Line
	4400 6950 4500 6950
Text Notes 5550 6750 1    60   ~ 0
HALT RED
Text Notes 4950 6750 1    60   ~ 0
RUN GREEN
$Comp
L device:LED D?
U 1 1 64364AD0
P 5100 6700
AR Path="/646800AA/64364AD0" Ref="D?"  Part="1" 
AR Path="/640FA3F5/64364AD0" Ref="D2"  Part="1" 
AR Path="/64122C47/64364AD0" Ref="D?"  Part="1" 
F 0 "D2" H 5100 6800 50  0000 C CNN
F 1 "LED" H 5100 6600 50  0000 C CNN
F 2 "LED_THT:LED_D3.0mm_Horizontal_O3.81mm_Z2.0mm" H 5100 6700 60  0001 C CNN
F 3 "" H 5100 6700 60  0001 C CNN
	1    5100 6700
	0    -1   -1   0   
$EndComp
Text Notes 5000 6000 0    60   ~ 0
RUN/HALT LEDS
$Comp
L device:LED D?
U 1 1 64364AD7
P 5700 6700
AR Path="/646800AA/64364AD7" Ref="D?"  Part="1" 
AR Path="/640FA3F5/64364AD7" Ref="D1"  Part="1" 
AR Path="/64122C47/64364AD7" Ref="D?"  Part="1" 
F 0 "D1" H 5700 6800 50  0000 C CNN
F 1 "LED" H 5700 6600 50  0000 C CNN
F 2 "LED_THT:LED_D3.0mm_Horizontal_O3.81mm_Z2.0mm" H 5700 6700 60  0001 C CNN
F 3 "" H 5700 6700 60  0001 C CNN
	1    5700 6700
	0    -1   -1   0   
$EndComp
Wire Wire Line
	4350 8150 4250 8150
Text GLabel 4400 6950 0    40   Input ~ 0
~HALT
Text GLabel 4250 8150 0    40   Input ~ 0
~NMI
Text Notes 5200 7600 3    60   ~ 0
NMI LED
$Comp
L 74xx:74LS06 U?
U 5 1 64364AF3
P 5400 6950
AR Path="/646800AA/64364AF3" Ref="U?"  Part="5" 
AR Path="/643138DC/64364AF3" Ref="U?"  Part="5" 
AR Path="/640FA3F5/64364AF3" Ref="U24"  Part="5" 
AR Path="/64122C47/64364AF3" Ref="U?"  Part="5" 
F 0 "U24" H 5350 7000 50  0000 C CNN
F 1 "74LS06" H 5350 6900 50  0000 C CNN
F 2 "" H 5400 6950 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS06" H 5400 6950 50  0001 C CNN
	5    5400 6950
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS06 U?
U 4 1 64364AF9
P 4800 6950
AR Path="/646800AA/64364AF9" Ref="U?"  Part="4" 
AR Path="/643138DC/64364AF9" Ref="U?"  Part="4" 
AR Path="/640FA3F5/64364AF9" Ref="U24"  Part="4" 
AR Path="/64122C47/64364AF9" Ref="U?"  Part="4" 
F 0 "U24" H 4750 7000 50  0000 C CNN
F 1 "74LS06" H 4750 6900 50  0000 C CNN
F 2 "" H 4800 6950 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS06" H 4800 6950 50  0001 C CNN
	4    4800 6950
	1    0    0    -1  
$EndComp
Wire Wire Line
	5700 6850 5700 6950
Wire Wire Line
	5100 6850 5100 6950
Connection ~ 5100 6950
$Comp
L 74xx:74LS07 U?
U 5 1 643AE38A
P 8950 8450
AR Path="/646800AA/643AE38A" Ref="U?"  Part="5" 
AR Path="/640FA3F5/643AE38A" Ref="U4"  Part="5" 
AR Path="/64122C47/643AE38A" Ref="U?"  Part="5" 
F 0 "U4" H 8900 8500 50  0000 C CNN
F 1 "74LS07" H 8900 8400 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm" H 8950 8450 50  0001 C CNN
F 3 "" H 8950 8450 50  0001 C CNN
	5    8950 8450
	1    0    0    1   
$EndComp
$Comp
L device:R R?
U 1 1 643AE396
P 7900 8450
AR Path="/646800AA/643AE396" Ref="R?"  Part="1" 
AR Path="/640FA3F5/643AE396" Ref="R4"  Part="1" 
AR Path="/64122C47/643AE396" Ref="R?"  Part="1" 
F 0 "R4" V 7980 8450 50  0000 C CNN
F 1 "10" V 7900 8450 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 7900 8450 60  0001 C CNN
F 3 "" H 7900 8450 60  0001 C CNN
	1    7900 8450
	0    -1   1    0   
$EndComp
$Comp
L device:CP C?
U 1 1 643AE39C
P 8300 8600
AR Path="/646800AA/643AE39C" Ref="C?"  Part="1" 
AR Path="/640FA3F5/643AE39C" Ref="C1"  Part="1" 
AR Path="/64122C47/643AE39C" Ref="C?"  Part="1" 
F 0 "C1" H 8350 8700 50  0000 L CNN
F 1 "10u" H 8350 8500 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D5.0mm_P2.50mm" H 8300 8600 60  0001 C CNN
F 3 "" H 8300 8600 60  0001 C CNN
	1    8300 8600
	-1   0    0    -1  
$EndComp
Text Notes 8150 9000 2    60   ~ 0
Reset Button Circuit
Wire Wire Line
	7750 8450 7750 8800
$Comp
L diode:1N4148 D?
U 1 1 643AE3A4
P 8550 8300
AR Path="/646800AA/643AE3A4" Ref="D?"  Part="1" 
AR Path="/640FA3F5/643AE3A4" Ref="D3"  Part="1" 
AR Path="/64122C47/643AE3A4" Ref="D?"  Part="1" 
F 0 "D3" V 8550 8350 50  0000 L CNN
F 1 "1N4148" H 8300 8200 50  0000 L CNN
F 2 "Diode_THT:D_DO-35_SOD27_P7.62mm_Horizontal" H 8550 8125 50  0001 C CNN
F 3 "https://assets.nexperia.com/documents/data-sheet/1N4148_1N4448.pdf" H 8550 8300 50  0001 C CNN
	1    8550 8300
	0    -1   1    0   
$EndComp
Wire Wire Line
	8650 8450 8550 8450
Connection ~ 8550 8450
Wire Wire Line
	8550 8450 8300 8450
Connection ~ 8300 8450
Wire Wire Line
	8300 8450 8300 8350
Wire Wire Line
	8300 8450 8050 8450
Wire Wire Line
	7150 8450 7150 8800
$Comp
L power:GND #PWR?
U 1 1 643AE3B5
P 8300 8750
AR Path="/646800AA/643AE3B5" Ref="#PWR?"  Part="1" 
AR Path="/640FA3F5/643AE3B5" Ref="#PWR0156"  Part="1" 
AR Path="/64122C47/643AE3B5" Ref="#PWR?"  Part="1" 
F 0 "#PWR0156" H 8300 8500 50  0001 C CNN
F 1 "GND" H 8305 8577 50  0000 C CNN
F 2 "" H 8300 8750 50  0001 C CNN
F 3 "" H 8300 8750 50  0001 C CNN
	1    8300 8750
	-1   0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 643AE3C1
P 8550 8150
AR Path="/646800AA/643AE3C1" Ref="#PWR?"  Part="1" 
AR Path="/640FA3F5/643AE3C1" Ref="#PWR0158"  Part="1" 
AR Path="/64122C47/643AE3C1" Ref="#PWR?"  Part="1" 
F 0 "#PWR0158" H 8550 8000 50  0001 C CNN
F 1 "VCC" H 8565 8323 50  0000 C CNN
F 2 "" H 8550 8150 50  0001 C CNN
F 3 "" H 8550 8150 50  0001 C CNN
	1    8550 8150
	-1   0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 643AE3C7
P 7150 8800
AR Path="/646800AA/643AE3C7" Ref="#PWR?"  Part="1" 
AR Path="/640FA3F5/643AE3C7" Ref="#PWR0159"  Part="1" 
AR Path="/64122C47/643AE3C7" Ref="#PWR?"  Part="1" 
F 0 "#PWR0159" H 7150 8550 50  0001 C CNN
F 1 "GND" H 7155 8627 50  0000 C CNN
F 2 "" H 7150 8800 50  0001 C CNN
F 3 "" H 7150 8800 50  0001 C CNN
	1    7150 8800
	-1   0    0    -1  
$EndComp
$Comp
L device:Jumper JP?
U 1 1 643AE3CD
P 7450 8800
AR Path="/646800AA/643AE3CD" Ref="JP?"  Part="1" 
AR Path="/640FA3F5/643AE3CD" Ref="JP1"  Part="1" 
AR Path="/64122C47/643AE3CD" Ref="JP?"  Part="1" 
F 0 "JP1" H 7450 9064 50  0000 C CNN
F 1 "EXT RES" H 7450 8973 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Horizontal" H 7450 8800 50  0001 C CNN
F 3 "~" H 7450 8800 50  0001 C CNN
	1    7450 8800
	-1   0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW?
U 1 1 643AE3D5
P 7450 8450
AR Path="/646800AA/643AE3D5" Ref="SW?"  Part="1" 
AR Path="/640FA3F5/643AE3D5" Ref="SW1"  Part="1" 
AR Path="/64122C47/643AE3D5" Ref="SW?"  Part="1" 
F 0 "SW1" H 7450 8735 50  0000 C CNN
F 1 "RESET" H 7450 8644 50  0000 C CNN
F 2 "Button_Switch_THT:SW_Tactile_SPST_Angled_PTS645Vx58-2LFS" H 7450 8650 50  0001 C CNN
F 3 "~" H 7450 8650 50  0001 C CNN
	1    7450 8450
	-1   0    0    -1  
$EndComp
Wire Wire Line
	7750 8450 7650 8450
Wire Wire Line
	7250 8450 7150 8450
Wire Wire Line
	9350 8450 9250 8450
Text GLabel 9350 8450 2    40   Output ~ 0
~RESET
Connection ~ 7750 8450
$Comp
L power:VCC #PWR?
U 1 1 64364ADD
P 4950 7550
AR Path="/646800AA/64364ADD" Ref="#PWR?"  Part="1" 
AR Path="/640FA3F5/64364ADD" Ref="#PWR0154"  Part="1" 
AR Path="/64122C47/64364ADD" Ref="#PWR?"  Part="1" 
F 0 "#PWR0154" H 4950 7400 50  0001 C CNN
F 1 "VCC" H 4965 7723 50  0000 C CNN
F 2 "" H 4950 7550 50  0001 C CNN
F 3 "" H 4950 7550 50  0001 C CNN
	1    4950 7550
	-1   0    0    -1  
$EndComp
$Comp
L device:R R?
U 1 1 64364AB5
P 4950 7700
AR Path="/646800AA/64364AB5" Ref="R?"  Part="1" 
AR Path="/640FA3F5/64364AB5" Ref="R5"  Part="1" 
AR Path="/64122C47/64364AB5" Ref="R?"  Part="1" 
F 0 "R5" V 5030 7700 50  0000 C CNN
F 1 "470" V 4950 7700 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" H 4950 7700 60  0001 C CNN
F 3 "" H 4950 7700 60  0001 C CNN
	1    4950 7700
	-1   0    0    1   
$EndComp
Text GLabel 5100 6550 1    40   Input ~ 0
470D
Text GLabel 5700 6550 1    40   Input ~ 0
470C
Text GLabel 8300 8350 1    40   Input ~ 0
10KA
Connection ~ 7150 8800
$EndSCHEMATC
