-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- VENDOR "Altera"
-- PROGRAM "Quartus II 64-Bit"
-- VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"

-- DATE "02/18/2014 00:25:39"

-- 
-- Device: Altera EPM7128SLC84-10 Package PLCC84
-- 

-- 
-- This VHDL file should be used for ModelSim-Altera (VHDL) only
-- 

LIBRARY IEEE;
LIBRARY MAX;
USE IEEE.STD_LOGIC_1164.ALL;
USE MAX.MAX_COMPONENTS.ALL;

ENTITY 	First IS
    PORT (
	pin_name9 : OUT std_logic;
	pin_name1 : IN std_logic;
	pin_name2 : IN std_logic;
	pin_name3 : IN std_logic;
	pin_name4 : IN std_logic;
	pin_name5 : IN std_logic;
	pin_name6 : IN std_logic;
	pin_name8 : IN std_logic;
	pin_name7 : IN std_logic;
	pin_name10 : OUT std_logic;
	pin_name11 : OUT std_logic
	);
END First;

-- Design Ports Information
-- pin_name1	=>  Location: PIN_33
-- pin_name2	=>  Location: PIN_52
-- pin_name3	=>  Location: PIN_81
-- pin_name4	=>  Location: PIN_4
-- pin_name5	=>  Location: PIN_24
-- pin_name6	=>  Location: PIN_5
-- pin_name8	=>  Location: PIN_80
-- pin_name7	=>  Location: PIN_61
-- pin_name10	=>  Location: PIN_11
-- pin_name11	=>  Location: PIN_12
-- pin_name9	=>  Location: PIN_10


ARCHITECTURE structure OF First IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL ww_pin_name9 : std_logic;
SIGNAL ww_pin_name1 : std_logic;
SIGNAL ww_pin_name2 : std_logic;
SIGNAL ww_pin_name3 : std_logic;
SIGNAL ww_pin_name4 : std_logic;
SIGNAL ww_pin_name5 : std_logic;
SIGNAL ww_pin_name6 : std_logic;
SIGNAL ww_pin_name8 : std_logic;
SIGNAL ww_pin_name7 : std_logic;
SIGNAL ww_pin_name10 : std_logic;
SIGNAL ww_pin_name11 : std_logic;
SIGNAL \inst|18~4_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~4_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~4_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~4_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~4_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~4_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~4_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~4_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~4_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~4_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~4_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~6_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~6_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~6_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~6_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~6_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~6_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~6_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~6_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~6_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~6_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|18~6_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|31~6_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|31~6_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|31~6_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|31~6_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|31~6_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|31~6_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|31~6_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|31~6_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|31~6_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|31~6_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|31~6_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|26~9_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|26~9_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|26~9_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|26~9_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|26~9_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|26~9_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|26~9_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|26~9_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|26~9_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|26~9_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst|26~9_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \pin_name3~dataout\ : std_logic;
SIGNAL \pin_name5~dataout\ : std_logic;
SIGNAL \pin_name6~dataout\ : std_logic;
SIGNAL \pin_name4~dataout\ : std_logic;
SIGNAL \pin_name8~dataout\ : std_logic;
SIGNAL \pin_name7~dataout\ : std_logic;
SIGNAL \inst|31~6_dataout\ : std_logic;
SIGNAL \pin_name1~dataout\ : std_logic;
SIGNAL \pin_name2~dataout\ : std_logic;
SIGNAL \inst|18~6_dataout\ : std_logic;
SIGNAL \inst|18~4_dataout\ : std_logic;
SIGNAL \inst|26~9_dataout\ : std_logic;
SIGNAL \ALT_INV_pin_name7~dataout\ : std_logic;
SIGNAL \ALT_INV_pin_name8~dataout\ : std_logic;
SIGNAL \ALT_INV_pin_name6~dataout\ : std_logic;
SIGNAL \ALT_INV_pin_name4~dataout\ : std_logic;
SIGNAL \ALT_INV_pin_name3~dataout\ : std_logic;
SIGNAL \ALT_INV_pin_name2~dataout\ : std_logic;
SIGNAL \inst|ALT_INV_18~6_dataout\ : std_logic;

BEGIN

pin_name9 <= ww_pin_name9;
ww_pin_name1 <= pin_name1;
ww_pin_name2 <= pin_name2;
ww_pin_name3 <= pin_name3;
ww_pin_name4 <= pin_name4;
ww_pin_name5 <= pin_name5;
ww_pin_name6 <= pin_name6;
ww_pin_name8 <= pin_name8;
ww_pin_name7 <= pin_name7;
pin_name10 <= ww_pin_name10;
pin_name11 <= ww_pin_name11;

\inst|18~4_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~4_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \pin_name6~dataout\ & \pin_name5~dataout\ & \pin_name7~dataout\ & \pin_name8~dataout\);

\inst|18~4_pterm2_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~4_pterm3_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~4_pterm4_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~4_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~4_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~4_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~4_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\inst|18~4_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~4_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~6_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~6_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & \pin_name4~dataout\ & \pin_name3~dataout\ & \pin_name6~dataout\ & \pin_name5~dataout\ & \pin_name7~dataout\ & \pin_name8~dataout\ & \pin_name2~dataout\ & \pin_name1~dataout\);

\inst|18~6_pterm2_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~6_pterm3_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~6_pterm4_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~6_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~6_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~6_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~6_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\inst|18~6_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|18~6_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|31~6_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|31~6_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \pin_name6~dataout\ & \pin_name5~dataout\ & NOT \pin_name3~dataout\);

\inst|31~6_pterm2_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \pin_name4~dataout\ & \pin_name6~dataout\ & \pin_name5~dataout\);

\inst|31~6_pterm3_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \pin_name8~dataout\);

\inst|31~6_pterm4_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \pin_name7~dataout\);

\inst|31~6_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|31~6_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|31~6_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|31~6_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\inst|31~6_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|31~6_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|26~9_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|26~9_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \pin_name7~dataout\ & NOT \pin_name6~dataout\);

\inst|26~9_pterm2_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \pin_name5~dataout\ & NOT \pin_name4~dataout\ & \pin_name7~dataout\);

\inst|26~9_pterm3_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \pin_name3~dataout\ & NOT \pin_name2~dataout\ & \pin_name5~dataout\ & \pin_name7~dataout\);

\inst|26~9_pterm4_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \pin_name8~dataout\);

\inst|26~9_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|26~9_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|26~9_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|26~9_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\inst|26~9_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst|26~9_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);
\ALT_INV_pin_name7~dataout\ <= NOT \pin_name7~dataout\;
\ALT_INV_pin_name8~dataout\ <= NOT \pin_name8~dataout\;
\ALT_INV_pin_name6~dataout\ <= NOT \pin_name6~dataout\;
\ALT_INV_pin_name4~dataout\ <= NOT \pin_name4~dataout\;
\ALT_INV_pin_name3~dataout\ <= NOT \pin_name3~dataout\;
\ALT_INV_pin_name2~dataout\ <= NOT \pin_name2~dataout\;
\inst|ALT_INV_18~6_dataout\ <= NOT \inst|18~6_dataout\;

-- Location: PIN_81
\pin_name3~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_pin_name3,
	dataout => \pin_name3~dataout\);

-- Location: PIN_24
\pin_name5~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_pin_name5,
	dataout => \pin_name5~dataout\);

-- Location: PIN_5
\pin_name6~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_pin_name6,
	dataout => \pin_name6~dataout\);

-- Location: PIN_4
\pin_name4~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_pin_name4,
	dataout => \pin_name4~dataout\);

-- Location: PIN_80
\pin_name8~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_pin_name8,
	dataout => \pin_name8~dataout\);

-- Location: PIN_61
\pin_name7~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_pin_name7,
	dataout => \pin_name7~dataout\);

-- Location: LC5
\inst|31~6\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "invert",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pterm0 => \inst|31~6_pterm0_bus\,
	pterm1 => \inst|31~6_pterm1_bus\,
	pterm2 => \inst|31~6_pterm2_bus\,
	pterm3 => \inst|31~6_pterm3_bus\,
	pterm4 => \inst|31~6_pterm4_bus\,
	pterm5 => \inst|31~6_pterm5_bus\,
	pxor => \inst|31~6_pxor_bus\,
	pclk => \inst|31~6_pclk_bus\,
	papre => \inst|31~6_papre_bus\,
	paclr => \inst|31~6_paclr_bus\,
	pena => \inst|31~6_pena_bus\,
	dataout => \inst|31~6_dataout\);

-- Location: PIN_33
\pin_name1~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_pin_name1,
	dataout => \pin_name1~dataout\);

-- Location: PIN_52
\pin_name2~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_pin_name2,
	dataout => \pin_name2~dataout\);

-- Location: LC8
\inst|18~6\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "normal",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pterm0 => \inst|18~6_pterm0_bus\,
	pterm1 => \inst|18~6_pterm1_bus\,
	pterm2 => \inst|18~6_pterm2_bus\,
	pterm3 => \inst|18~6_pterm3_bus\,
	pterm4 => \inst|18~6_pterm4_bus\,
	pterm5 => \inst|18~6_pterm5_bus\,
	pxor => \inst|18~6_pxor_bus\,
	pclk => \inst|18~6_pclk_bus\,
	papre => \inst|18~6_papre_bus\,
	paclr => \inst|18~6_paclr_bus\,
	pena => \inst|18~6_pena_bus\,
	dataout => \inst|18~6_dataout\);

-- Location: LC3
\inst|18~4\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "normal",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pterm0 => \inst|18~4_pterm0_bus\,
	pterm1 => \inst|18~4_pterm1_bus\,
	pterm2 => \inst|18~4_pterm2_bus\,
	pterm3 => \inst|18~4_pterm3_bus\,
	pterm4 => \inst|18~4_pterm4_bus\,
	pterm5 => \inst|18~4_pterm5_bus\,
	pxor => \inst|18~4_pxor_bus\,
	pclk => \inst|18~4_pclk_bus\,
	papre => \inst|18~4_papre_bus\,
	paclr => \inst|18~4_paclr_bus\,
	pena => \inst|18~4_pena_bus\,
	dataout => \inst|18~4_dataout\);

-- Location: LC6
\inst|26~9\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "invert",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pterm0 => \inst|26~9_pterm0_bus\,
	pterm1 => \inst|26~9_pterm1_bus\,
	pterm2 => \inst|26~9_pterm2_bus\,
	pterm3 => \inst|26~9_pterm3_bus\,
	pterm4 => \inst|26~9_pterm4_bus\,
	pterm5 => \inst|26~9_pterm5_bus\,
	pxor => \inst|26~9_pxor_bus\,
	pclk => \inst|26~9_pclk_bus\,
	papre => \inst|26~9_papre_bus\,
	paclr => \inst|26~9_paclr_bus\,
	pena => \inst|26~9_pena_bus\,
	dataout => \inst|26~9_dataout\);

-- Location: PIN_11
\pin_name10~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "output",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	datain => \inst|31~6_dataout\,
	oe => \inst|ALT_INV_18~6_dataout\,
	padio => ww_pin_name10);

-- Location: PIN_12
\pin_name11~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "output",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	datain => \inst|18~4_dataout\,
	oe => \inst|ALT_INV_18~6_dataout\,
	padio => ww_pin_name11);

-- Location: PIN_10
\pin_name9~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "output",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	datain => \inst|26~9_dataout\,
	oe => \inst|ALT_INV_18~6_dataout\,
	padio => ww_pin_name9);
END structure;


