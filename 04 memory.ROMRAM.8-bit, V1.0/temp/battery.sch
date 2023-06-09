EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr B 17000 11000
encoding utf-8
Sheet 5 10
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
L Power_Management:DS1210 U5
U 1 1 60579198
P 9050 3350
AR Path="/64B18D10/60579198" Ref="U5"  Part="1" 
AR Path="/641EB8C9/60579198" Ref="U?"  Part="1" 
F 0 "U5" H 8750 3700 50  0000 C CNN
F 1 "DS1210" H 9250 3700 50  0000 C CNN
F 2 "Package_DIP:DIP-8_W7.62mm" H 9050 2550 50  0001 C CNN
F 3 "" H 8950 3250 50  0001 C CNN
	1    9050 3350
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG01
U 1 1 604E2777
P 5050 2800
AR Path="/64B18D10/604E2777" Ref="#FLG01"  Part="1" 
AR Path="/641EB8C9/604E2777" Ref="#FLG?"  Part="1" 
F 0 "#FLG01" H 5050 2895 30  0001 C CNN
F 1 "PWR_FLAG" H 5050 2980 30  0000 C CNN
F 2 "" H 5050 2800 60  0001 C CNN
F 3 "" H 5050 2800 60  0001 C CNN
	1    5050 2800
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG02
U 1 1 604E2943
P 5050 3100
AR Path="/64B18D10/604E2943" Ref="#FLG02"  Part="1" 
AR Path="/641EB8C9/604E2943" Ref="#FLG?"  Part="1" 
F 0 "#FLG02" H 5050 3195 30  0001 C CNN
F 1 "PWR_FLAG" H 5050 3250 30  0000 C CNN
F 2 "" H 5050 3100 60  0001 C CNN
F 3 "" H 5050 3100 60  0001 C CNN
	1    5050 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	9050 2950 9050 2750
Wire Wire Line
	9650 3250 9450 3250
Wire Wire Line
	9450 4200 9450 3550
Wire Wire Line
	9050 3750 9050 3850
Connection ~ 9050 3750
Wire Wire Line
	8350 3250 8650 3250
Wire Wire Line
	4300 3600 4300 3700
Text Notes 3800 2500 0    60   ~ 0
JUMPER 1-2 CR2032 COIN CELL\nJUMPER 3-4 EXTERNAL BATTERY
Connection ~ 4300 3600
Text Label 4050 3000 0    60   ~ 0
V2032
$Comp
L Power_Management:DS1210 U13
U 1 1 610F95B1
P 9050 7350
AR Path="/64B18D10/610F95B1" Ref="U13"  Part="1" 
AR Path="/641EB8C9/610F95B1" Ref="U?"  Part="1" 
F 0 "U13" H 8750 7700 50  0000 C CNN
F 1 "DS1210" H 9250 7700 50  0000 C CNN
F 2 "Package_DIP:DIP-8_W7.62mm" H 9050 6550 50  0001 C CNN
F 3 "" H 8950 7250 50  0001 C CNN
	1    9050 7350
	1    0    0    -1  
$EndComp
Wire Wire Line
	9050 6950 9050 6750
Wire Wire Line
	9450 8200 9450 7550
Wire Wire Line
	9050 7750 9050 7850
Connection ~ 9050 7750
Wire Wire Line
	8200 8200 8350 8200
Text Notes 8250 8700 0    60   ~ 0
JP4 AND JP5\nU11 DS1210 INSTALLED\nCLOSE BOTH TO BYPASS\nDEFAULT BOTH OPEN 
Wire Wire Line
	9450 7250 9750 7250
Wire Wire Line
	9650 6750 9750 6750
Connection ~ 9750 6750
Wire Wire Line
	9750 6750 9750 7250
Wire Wire Line
	8350 4200 8850 4200
Wire Wire Line
	8250 7150 8650 7150
Wire Wire Line
	4800 2800 5050 2800
Wire Wire Line
	8350 3150 8650 3150
Wire Wire Line
	8250 7250 8650 7250
Wire Wire Line
	4300 3100 4300 3600
Wire Wire Line
	5300 3100 5050 3100
Wire Wire Line
	4000 3600 4300 3600
Wire Wire Line
	4300 3000 4000 3000
Wire Wire Line
	4800 2800 4800 3000
Wire Wire Line
	7750 3750 9050 3750
Text Notes 7100 4550 0    60   ~ 0
NOTE:\nK1 VCC TOLERANCE\n1-2 CLOSED 10%\n2-3 CLOSED 5%
Wire Wire Line
	7750 7750 9050 7750
Wire Wire Line
	7650 7450 7650 7750
Wire Wire Line
	7650 7450 8650 7450
Wire Wire Line
	7550 7750 7550 6400
Wire Wire Line
	7550 6400 9750 6400
Wire Wire Line
	9750 6400 9750 6750
Text Notes 6950 8600 0    60   ~ 0
NOTE:\nK5 VCC TOLERANCE\n1-2 CLOSED 10%\n2-3 CLOSED 5%
Wire Wire Line
	9450 7550 9750 7550
Connection ~ 9450 7550
Connection ~ 9450 3550
Wire Wire Line
	9450 3550 9750 3550
$Comp
L power:GND #PWR05
U 1 1 6E2F80E9
P 4300 3700
AR Path="/64B18D10/6E2F80E9" Ref="#PWR05"  Part="1" 
AR Path="/641EB8C9/6E2F80E9" Ref="#PWR?"  Part="1" 
F 0 "#PWR05" H 4300 3450 50  0001 C CNN
F 1 "GND" H 4305 3527 50  0000 C CNN
F 2 "" H 4300 3700 50  0001 C CNN
F 3 "" H 4300 3700 50  0001 C CNN
	1    4300 3700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR04
U 1 1 6E2F8AE5
P 9050 3850
AR Path="/64B18D10/6E2F8AE5" Ref="#PWR04"  Part="1" 
AR Path="/641EB8C9/6E2F8AE5" Ref="#PWR?"  Part="1" 
F 0 "#PWR04" H 9050 3600 50  0001 C CNN
F 1 "GND" H 9055 3677 50  0000 C CNN
F 2 "" H 9050 3850 50  0001 C CNN
F 3 "" H 9050 3850 50  0001 C CNN
	1    9050 3850
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR03
U 1 1 6E2FBCBE
P 9050 2750
AR Path="/64B18D10/6E2FBCBE" Ref="#PWR03"  Part="1" 
AR Path="/641EB8C9/6E2FBCBE" Ref="#PWR?"  Part="1" 
F 0 "#PWR03" H 9050 2600 50  0001 C CNN
F 1 "VCC" H 9065 2923 50  0000 C CNN
F 2 "" H 9050 2750 50  0001 C CNN
F 3 "" H 9050 2750 50  0001 C CNN
	1    9050 2750
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR017
U 1 1 6E30323D
P 9050 6750
AR Path="/64B18D10/6E30323D" Ref="#PWR017"  Part="1" 
AR Path="/641EB8C9/6E30323D" Ref="#PWR?"  Part="1" 
F 0 "#PWR017" H 9050 6600 50  0001 C CNN
F 1 "VCC" H 9065 6923 50  0000 C CNN
F 2 "" H 9050 6750 50  0001 C CNN
F 3 "" H 9050 6750 50  0001 C CNN
	1    9050 6750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR020
U 1 1 6E303866
P 9050 7850
AR Path="/64B18D10/6E303866" Ref="#PWR020"  Part="1" 
AR Path="/641EB8C9/6E303866" Ref="#PWR?"  Part="1" 
F 0 "#PWR020" H 9050 7600 50  0001 C CNN
F 1 "GND" H 9055 7677 50  0000 C CNN
F 2 "" H 9050 7850 50  0001 C CNN
F 3 "" H 9050 7850 50  0001 C CNN
	1    9050 7850
	1    0    0    -1  
$EndComp
Wire Wire Line
	9650 2400 9650 2750
$Comp
L device:Jumper JP1
U 1 1 6FAEEE30
P 9350 2750
AR Path="/64B18D10/6FAEEE30" Ref="JP1"  Part="1" 
AR Path="/641EB8C9/6FAEEE30" Ref="JP?"  Part="1" 
F 0 "JP1" H 9350 3014 50  0000 C CNN
F 1 "BYPASS" H 9350 2923 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 9350 2750 50  0001 C CNN
F 3 "~" H 9350 2750 50  0001 C CNN
	1    9350 2750
	1    0    0    -1  
$EndComp
Connection ~ 9050 2750
Connection ~ 9650 2750
Wire Wire Line
	9650 2750 9650 3250
$Comp
L device:Jumper JP4
U 1 1 6FAF150B
P 9150 4200
AR Path="/64B18D10/6FAF150B" Ref="JP4"  Part="1" 
AR Path="/641EB8C9/6FAF150B" Ref="JP?"  Part="1" 
F 0 "JP4" H 9300 4300 50  0000 C CNN
F 1 "BYPASS" H 9150 4100 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 9150 4200 50  0001 C CNN
F 3 "~" H 9150 4200 50  0001 C CNN
	1    9150 4200
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_01X03 K1
U 1 1 6FAF66AF
P 7650 3950
AR Path="/64B18D10/6FAF66AF" Ref="K1"  Part="1" 
AR Path="/641EB8C9/6FAF66AF" Ref="K?"  Part="1" 
F 0 "K1" V 7521 4128 50  0000 L CNN
F 1 "VCC TOL 0" V 7612 4128 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical" H 7650 3950 50  0001 C CNN
F 3 "" H 7650 3950 50  0001 C CNN
	1    7650 3950
	0    -1   1    0   
$EndComp
$Comp
L conn:CONN_02X02 JP2
U 1 1 6FAFB49D
P 4550 3050
AR Path="/64B18D10/6FAFB49D" Ref="JP2"  Part="1" 
AR Path="/641EB8C9/6FAFB49D" Ref="JP?"  Part="1" 
F 0 "JP2" H 4550 3315 50  0000 C CNN
F 1 "BATT SEL" H 4550 3224 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x02_P2.54mm_Vertical" H 4550 1850 50  0001 C CNN
F 3 "" H 4550 1850 50  0001 C CNN
	1    4550 3050
	1    0    0    -1  
$EndComp
$Comp
L device:Battery BT1
U 1 1 6FB9C2C1
P 4000 3300
AR Path="/64B18D10/6FB9C2C1" Ref="BT1"  Part="1" 
AR Path="/641EB8C9/6FB9C2C1" Ref="BT?"  Part="1" 
F 0 "BT1" H 4108 3346 50  0000 L CNN
F 1 "Battery" H 4108 3255 50  0000 L CNN
F 2 "Battery:BatteryHolder_Keystone_103_1x20mm" V 4000 3360 50  0001 C CNN
F 3 "~" V 4000 3360 50  0001 C CNN
	1    4000 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	4000 3100 4000 3000
Wire Wire Line
	4000 3600 4000 3500
$Comp
L device:Jumper JP5
U 1 1 6FCD9E52
P 9350 6750
AR Path="/64B18D10/6FCD9E52" Ref="JP5"  Part="1" 
AR Path="/641EB8C9/6FCD9E52" Ref="JP?"  Part="1" 
F 0 "JP5" H 9350 7014 50  0000 C CNN
F 1 "BYPASS" H 9350 6923 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 9350 6750 50  0001 C CNN
F 3 "~" H 9350 6750 50  0001 C CNN
	1    9350 6750
	1    0    0    -1  
$EndComp
Connection ~ 9050 6750
$Comp
L device:Jumper JP6
U 1 1 6FD79BAD
P 9150 8200
AR Path="/64B18D10/6FD79BAD" Ref="JP6"  Part="1" 
AR Path="/641EB8C9/6FD79BAD" Ref="JP?"  Part="1" 
F 0 "JP6" H 9300 8300 50  0000 C CNN
F 1 "BYPASS" H 9150 8100 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 9150 8200 50  0001 C CNN
F 3 "~" H 9150 8200 50  0001 C CNN
	1    9150 8200
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_01X03 K5
U 1 1 6FE18788
P 7650 7950
AR Path="/64B18D10/6FE18788" Ref="K5"  Part="1" 
AR Path="/641EB8C9/6FE18788" Ref="K?"  Part="1" 
F 0 "K5" V 7521 8128 50  0000 L CNN
F 1 "VCC TOL 1" V 7612 8128 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical" H 7650 7950 50  0001 C CNN
F 3 "" H 7650 7950 50  0001 C CNN
	1    7650 7950
	0    -1   1    0   
$EndComp
Text Notes 8300 4700 0    60   ~ 0
JP1 AND JP3\nU2 DS1210 INSTALLED\nCLOSE BOTH TO BYPASS\nDEFAULT BOTH OPEN 
Wire Wire Line
	9650 2400 9800 2400
Connection ~ 9650 2400
Text GLabel 9800 2400 2    40   Output ~ 0
VCC_SRAM0
Text GLabel 9750 3550 2    40   Input ~ 0
~CEO0
Wire Wire Line
	8200 4200 8350 4200
Connection ~ 8350 4200
Text GLabel 8200 4200 0    40   Input ~ 0
~CS_RAM0
Text GLabel 9900 6400 2    40   Output ~ 0
VCC_SRAM1
Wire Wire Line
	9900 6400 9750 6400
Connection ~ 9750 6400
Text GLabel 9750 7550 2    40   Input ~ 0
~CEO1
Text GLabel 8200 8200 0    40   Input ~ 0
~CS_RAM1
Wire Wire Line
	8350 7550 8350 8200
Wire Wire Line
	8350 7550 8650 7550
Connection ~ 8350 8200
Wire Wire Line
	8350 8200 8850 8200
Text GLabel 8250 7150 0    40   Output ~ 0
VBAT1
Text GLabel 8250 7250 0    40   Output ~ 0
VBAT2
Text GLabel 5300 2800 2    40   Output ~ 0
VBAT1
Text GLabel 5300 3100 2    40   Output ~ 0
VBAT2
Connection ~ 5050 2800
Wire Wire Line
	5050 2800 5300 2800
Connection ~ 5050 3100
Wire Wire Line
	5050 3100 4800 3100
Wire Wire Line
	7550 2400 7550 3750
Wire Wire Line
	7550 2400 9650 2400
Wire Wire Line
	7650 3450 8650 3450
Wire Wire Line
	7650 3450 7650 3750
Wire Wire Line
	8350 4200 8350 3550
Wire Wire Line
	8350 3550 8650 3550
Text GLabel 8350 3150 0    40   Output ~ 0
VBAT1
Text GLabel 8350 3250 0    40   Output ~ 0
VBAT2
$Comp
L Power_Management:DS1210 U18
U 1 1 641ED85B
P 13050 3350
AR Path="/64B18D10/641ED85B" Ref="U18"  Part="1" 
AR Path="/641EB8C9/641ED85B" Ref="U?"  Part="1" 
F 0 "U18" H 12750 3700 50  0000 C CNN
F 1 "DS1210" H 13250 3700 50  0000 C CNN
F 2 "Package_DIP:DIP-8_W7.62mm" H 13050 2550 50  0001 C CNN
F 3 "" H 12950 3250 50  0001 C CNN
	1    13050 3350
	1    0    0    -1  
$EndComp
Wire Wire Line
	13050 2950 13050 2750
Wire Wire Line
	13650 3250 13450 3250
Wire Wire Line
	13450 4200 13450 3550
Wire Wire Line
	13050 3750 13050 3850
Connection ~ 13050 3750
Wire Wire Line
	12350 3250 12650 3250
$Comp
L Power_Management:DS1210 U19
U 1 1 641ED99D
P 13050 7350
AR Path="/64B18D10/641ED99D" Ref="U19"  Part="1" 
AR Path="/641EB8C9/641ED99D" Ref="U?"  Part="1" 
F 0 "U19" H 12750 7700 50  0000 C CNN
F 1 "DS1210" H 13250 7700 50  0000 C CNN
F 2 "Package_DIP:DIP-8_W7.62mm" H 13050 6550 50  0001 C CNN
F 3 "" H 12950 7250 50  0001 C CNN
	1    13050 7350
	1    0    0    -1  
$EndComp
Wire Wire Line
	13050 6950 13050 6750
Wire Wire Line
	13450 8200 13450 7550
Wire Wire Line
	13050 7750 13050 7850
Connection ~ 13050 7750
Wire Wire Line
	12200 8200 12350 8200
Text Notes 12250 8700 0    60   ~ 0
JP4 AND JP5\nU11 DS1210 INSTALLED\nCLOSE BOTH TO BYPASS\nDEFAULT BOTH OPEN 
Wire Wire Line
	13450 7250 13750 7250
Wire Wire Line
	13650 6750 13750 6750
Connection ~ 13750 6750
Wire Wire Line
	13750 6750 13750 7250
Wire Wire Line
	12350 4200 12850 4200
Wire Wire Line
	12250 7150 12650 7150
Wire Wire Line
	12350 3150 12650 3150
Wire Wire Line
	12250 7250 12650 7250
Wire Wire Line
	11750 3750 13050 3750
Text Notes 11100 4550 0    60   ~ 0
NOTE:\nK1 VCC TOLERANCE\n1-2 CLOSED 10%\n2-3 CLOSED 5%
Wire Wire Line
	11750 7750 13050 7750
Wire Wire Line
	11650 7450 11650 7750
Wire Wire Line
	11650 7450 12650 7450
Wire Wire Line
	11550 7750 11550 6400
Wire Wire Line
	11550 6400 13750 6400
Wire Wire Line
	13750 6400 13750 6750
Text Notes 10950 8600 0    60   ~ 0
NOTE:\nK5 VCC TOLERANCE\n1-2 CLOSED 10%\n2-3 CLOSED 5%
Wire Wire Line
	13450 7550 13750 7550
Connection ~ 13450 7550
Connection ~ 13450 3550
Wire Wire Line
	13450 3550 13750 3550
$Comp
L power:GND #PWR024
U 1 1 641ED9C2
P 13050 3850
AR Path="/64B18D10/641ED9C2" Ref="#PWR024"  Part="1" 
AR Path="/641EB8C9/641ED9C2" Ref="#PWR?"  Part="1" 
F 0 "#PWR024" H 13050 3600 50  0001 C CNN
F 1 "GND" H 13055 3677 50  0000 C CNN
F 2 "" H 13050 3850 50  0001 C CNN
F 3 "" H 13050 3850 50  0001 C CNN
	1    13050 3850
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR022
U 1 1 641ED9CC
P 13050 2750
AR Path="/64B18D10/641ED9CC" Ref="#PWR022"  Part="1" 
AR Path="/641EB8C9/641ED9CC" Ref="#PWR?"  Part="1" 
F 0 "#PWR022" H 13050 2600 50  0001 C CNN
F 1 "VCC" H 13065 2923 50  0000 C CNN
F 2 "" H 13050 2750 50  0001 C CNN
F 3 "" H 13050 2750 50  0001 C CNN
	1    13050 2750
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR032
U 1 1 641ED9D6
P 13050 6750
AR Path="/64B18D10/641ED9D6" Ref="#PWR032"  Part="1" 
AR Path="/641EB8C9/641ED9D6" Ref="#PWR?"  Part="1" 
F 0 "#PWR032" H 13050 6600 50  0001 C CNN
F 1 "VCC" H 13065 6923 50  0000 C CNN
F 2 "" H 13050 6750 50  0001 C CNN
F 3 "" H 13050 6750 50  0001 C CNN
	1    13050 6750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR034
U 1 1 641ED9E0
P 13050 7850
AR Path="/64B18D10/641ED9E0" Ref="#PWR034"  Part="1" 
AR Path="/641EB8C9/641ED9E0" Ref="#PWR?"  Part="1" 
F 0 "#PWR034" H 13050 7600 50  0001 C CNN
F 1 "GND" H 13055 7677 50  0000 C CNN
F 2 "" H 13050 7850 50  0001 C CNN
F 3 "" H 13050 7850 50  0001 C CNN
	1    13050 7850
	1    0    0    -1  
$EndComp
Wire Wire Line
	13650 2400 13650 2750
$Comp
L device:Jumper JP8
U 1 1 641ED9EB
P 13350 2750
AR Path="/64B18D10/641ED9EB" Ref="JP8"  Part="1" 
AR Path="/641EB8C9/641ED9EB" Ref="JP?"  Part="1" 
F 0 "JP8" H 13350 3014 50  0000 C CNN
F 1 "BYPASS" H 13350 2923 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 13350 2750 50  0001 C CNN
F 3 "~" H 13350 2750 50  0001 C CNN
	1    13350 2750
	1    0    0    -1  
$EndComp
Connection ~ 13050 2750
Connection ~ 13650 2750
Wire Wire Line
	13650 2750 13650 3250
$Comp
L device:Jumper JP11
U 1 1 641ED9F8
P 13150 4200
AR Path="/64B18D10/641ED9F8" Ref="JP11"  Part="1" 
AR Path="/641EB8C9/641ED9F8" Ref="JP?"  Part="1" 
F 0 "JP11" H 13300 4300 50  0000 C CNN
F 1 "BYPASS" H 13150 4100 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 13150 4200 50  0001 C CNN
F 3 "~" H 13150 4200 50  0001 C CNN
	1    13150 4200
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_01X03 K2
U 1 1 641EDA02
P 11650 3950
AR Path="/64B18D10/641EDA02" Ref="K2"  Part="1" 
AR Path="/641EB8C9/641EDA02" Ref="K?"  Part="1" 
F 0 "K2" V 11521 4128 50  0000 L CNN
F 1 "VCC TOL 2" V 11612 4128 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical" H 11650 3950 50  0001 C CNN
F 3 "" H 11650 3950 50  0001 C CNN
	1    11650 3950
	0    -1   1    0   
$EndComp
$Comp
L device:Jumper JP12
U 1 1 641EDA0C
P 13350 6750
AR Path="/64B18D10/641EDA0C" Ref="JP12"  Part="1" 
AR Path="/641EB8C9/641EDA0C" Ref="JP?"  Part="1" 
F 0 "JP12" H 13350 7014 50  0000 C CNN
F 1 "BYPASS" H 13350 6923 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 13350 6750 50  0001 C CNN
F 3 "~" H 13350 6750 50  0001 C CNN
	1    13350 6750
	1    0    0    -1  
$EndComp
Connection ~ 13050 6750
$Comp
L device:Jumper JP13
U 1 1 641EDA17
P 13150 8200
AR Path="/64B18D10/641EDA17" Ref="JP13"  Part="1" 
AR Path="/641EB8C9/641EDA17" Ref="JP?"  Part="1" 
F 0 "JP13" H 13300 8300 50  0000 C CNN
F 1 "BYPASS" H 13150 8100 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 13150 8200 50  0001 C CNN
F 3 "~" H 13150 8200 50  0001 C CNN
	1    13150 8200
	1    0    0    -1  
$EndComp
$Comp
L conn:CONN_01X03 K3
U 1 1 641EDA21
P 11650 7950
AR Path="/64B18D10/641EDA21" Ref="K3"  Part="1" 
AR Path="/641EB8C9/641EDA21" Ref="K?"  Part="1" 
F 0 "K3" V 11521 8128 50  0000 L CNN
F 1 "VCC TOL 3" V 11612 8128 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical" H 11650 7950 50  0001 C CNN
F 3 "" H 11650 7950 50  0001 C CNN
	1    11650 7950
	0    -1   1    0   
$EndComp
Text Notes 12300 4700 0    60   ~ 0
JP1 AND JP3\nU2 DS1210 INSTALLED\nCLOSE BOTH TO BYPASS\nDEFAULT BOTH OPEN 
Wire Wire Line
	13650 2400 13800 2400
Connection ~ 13650 2400
Text GLabel 13800 2400 2    40   Output ~ 0
VCC_SRAM2
Text GLabel 13750 3550 2    40   Input ~ 0
~CEO2
Wire Wire Line
	12200 4200 12350 4200
Connection ~ 12350 4200
Text GLabel 12200 4200 0    40   Input ~ 0
~CS_RAM2
Text GLabel 13900 6400 2    40   Output ~ 0
VCC_SRAM3
Wire Wire Line
	13900 6400 13750 6400
Connection ~ 13750 6400
Text GLabel 13750 7550 2    40   Input ~ 0
~CEO3
Text GLabel 12200 8200 0    40   Input ~ 0
~CS_RAM3
Wire Wire Line
	12350 7550 12350 8200
Wire Wire Line
	12350 7550 12650 7550
Connection ~ 12350 8200
Wire Wire Line
	12350 8200 12850 8200
Text GLabel 12250 7150 0    40   Output ~ 0
VBAT1
Text GLabel 12250 7250 0    40   Output ~ 0
VBAT2
Wire Wire Line
	11550 2400 11550 3750
Wire Wire Line
	11550 2400 13650 2400
Wire Wire Line
	11650 3450 12650 3450
Wire Wire Line
	11650 3450 11650 3750
Wire Wire Line
	12350 4200 12350 3550
Wire Wire Line
	12350 3550 12650 3550
Text GLabel 12350 3150 0    40   Output ~ 0
VBAT1
Text GLabel 12350 3250 0    40   Output ~ 0
VBAT2
$EndSCHEMATC
