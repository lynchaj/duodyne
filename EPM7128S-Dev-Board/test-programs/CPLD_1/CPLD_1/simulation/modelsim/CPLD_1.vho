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
-- PROGRAM "Quartus II 32-bit"
-- VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"

-- DATE "11/24/2023 10:04:39"

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

ENTITY 	CPLD_1 IS
    PORT (
	\/CTCE\ : OUT std_logic;
	A2 : IN std_logic;
	A4 : IN std_logic;
	A5 : IN std_logic;
	A6 : IN std_logic;
	A7 : IN std_logic;
	A3 : IN std_logic;
	OUT0 : OUT std_logic;
	\/M1\ : IN std_logic;
	A0 : IN std_logic;
	A1 : IN std_logic;
	\/WR\ : IN std_logic;
	\/IORQ\ : IN std_logic
	);
END CPLD_1;

-- Design Ports Information
-- A2	=>  Location: PIN_52
-- A4	=>  Location: PIN_4
-- A5	=>  Location: PIN_81
-- A6	=>  Location: PIN_33
-- A7	=>  Location: PIN_61
-- A3	=>  Location: PIN_24
-- /M1	=>  Location: PIN_80
-- A0	=>  Location: PIN_5
-- A1	=>  Location: PIN_6
-- /WR	=>  Location: PIN_15
-- /IORQ	=>  Location: PIN_34
-- /CTCE	=>  Location: PIN_12
-- OUT0	=>  Location: PIN_11


ARCHITECTURE structure OF CPLD_1 IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL \ww_/CTCE\ : std_logic;
SIGNAL ww_A2 : std_logic;
SIGNAL ww_A4 : std_logic;
SIGNAL ww_A5 : std_logic;
SIGNAL ww_A6 : std_logic;
SIGNAL ww_A7 : std_logic;
SIGNAL ww_A3 : std_logic;
SIGNAL ww_OUT0 : std_logic;
SIGNAL \ww_/M1\ : std_logic;
SIGNAL ww_A0 : std_logic;
SIGNAL ww_A1 : std_logic;
SIGNAL \ww_/WR\ : std_logic;
SIGNAL \ww_/IORQ\ : std_logic;
SIGNAL \inst~3_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst~3_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst~3_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst~3_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst~3_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst~3_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst~3_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst~3_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst~3_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst~3_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst~3_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst11~3_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst11~3_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst11~3_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst11~3_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst11~3_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst11~3_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst11~3_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst11~3_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst11~3_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst11~3_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \inst11~3_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \A3~dataout\ : std_logic;
SIGNAL \A2~dataout\ : std_logic;
SIGNAL \A4~dataout\ : std_logic;
SIGNAL \A5~dataout\ : std_logic;
SIGNAL \A6~dataout\ : std_logic;
SIGNAL \A7~dataout\ : std_logic;
SIGNAL \inst~3_dataout\ : std_logic;
SIGNAL \/M1~dataout\ : std_logic;
SIGNAL \A0~dataout\ : std_logic;
SIGNAL \A1~dataout\ : std_logic;
SIGNAL \/WR~dataout\ : std_logic;
SIGNAL \/IORQ~dataout\ : std_logic;
SIGNAL \inst11~3_dataout\ : std_logic;
SIGNAL \ALT_INV_A1~dataout\ : std_logic;
SIGNAL \ALT_INV_A0~dataout\ : std_logic;
SIGNAL \ALT_INV_A3~dataout\ : std_logic;
SIGNAL \ALT_INV_A7~dataout\ : std_logic;
SIGNAL \ALT_INV_A6~dataout\ : std_logic;
SIGNAL \ALT_INV_A5~dataout\ : std_logic;
SIGNAL \ALT_INV_A4~dataout\ : std_logic;
SIGNAL \ALT_INV_A2~dataout\ : std_logic;

BEGIN

\/CTCE\ <= \ww_/CTCE\;
ww_A2 <= A2;
ww_A4 <= A4;
ww_A5 <= A5;
ww_A6 <= A6;
ww_A7 <= A7;
ww_A3 <= A3;
OUT0 <= ww_OUT0;
\ww_/M1\ <= \/M1\;
ww_A0 <= A0;
ww_A1 <= A1;
\ww_/WR\ <= \/WR\;
\ww_/IORQ\ <= \/IORQ\;

\inst~3_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst~3_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \A7~dataout\ & NOT \A6~dataout\ & NOT \A5~dataout\ & NOT \A4~dataout\ & NOT \A2~dataout\ & \A3~dataout\);

\inst~3_pterm2_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst~3_pterm3_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst~3_pterm4_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst~3_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst~3_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst~3_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst~3_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\inst~3_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst~3_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst11~3_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst11~3_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & NOT \A7~dataout\ & NOT \A6~dataout\ & NOT \A5~dataout\ & NOT \A4~dataout\ & NOT \A2~dataout\ & \/WR~dataout\ & NOT \A1~dataout\ & NOT \A0~dataout\ & \/M1~dataout\ & NOT \A3~dataout\);

\inst11~3_pterm2_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & \/IORQ~dataout\ & NOT \A7~dataout\ & NOT \A6~dataout\ & NOT \A5~dataout\ & NOT \A4~dataout\ & NOT \A2~dataout\ & NOT \A1~dataout\ & NOT \A0~dataout\ & \/M1~dataout\ & NOT \A3~dataout\);

\inst11~3_pterm3_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst11~3_pterm4_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst11~3_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst11~3_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst11~3_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst11~3_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\inst11~3_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\inst11~3_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);
\ALT_INV_A1~dataout\ <= NOT \A1~dataout\;
\ALT_INV_A0~dataout\ <= NOT \A0~dataout\;
\ALT_INV_A3~dataout\ <= NOT \A3~dataout\;
\ALT_INV_A7~dataout\ <= NOT \A7~dataout\;
\ALT_INV_A6~dataout\ <= NOT \A6~dataout\;
\ALT_INV_A5~dataout\ <= NOT \A5~dataout\;
\ALT_INV_A4~dataout\ <= NOT \A4~dataout\;
\ALT_INV_A2~dataout\ <= NOT \A2~dataout\;

-- Location: PIN_24
\A3~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_A3,
	dataout => \A3~dataout\);

-- Location: PIN_52
\A2~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_A2,
	dataout => \A2~dataout\);

-- Location: PIN_4
\A4~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_A4,
	dataout => \A4~dataout\);

-- Location: PIN_81
\A5~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_A5,
	dataout => \A5~dataout\);

-- Location: PIN_33
\A6~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_A6,
	dataout => \A6~dataout\);

-- Location: PIN_61
\A7~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_A7,
	dataout => \A7~dataout\);

-- Location: LC3
\inst~3\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "invert",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pterm0 => \inst~3_pterm0_bus\,
	pterm1 => \inst~3_pterm1_bus\,
	pterm2 => \inst~3_pterm2_bus\,
	pterm3 => \inst~3_pterm3_bus\,
	pterm4 => \inst~3_pterm4_bus\,
	pterm5 => \inst~3_pterm5_bus\,
	pxor => \inst~3_pxor_bus\,
	pclk => \inst~3_pclk_bus\,
	papre => \inst~3_papre_bus\,
	paclr => \inst~3_paclr_bus\,
	pena => \inst~3_pena_bus\,
	dataout => \inst~3_dataout\);

-- Location: PIN_80
\/M1~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => \ww_/M1\,
	dataout => \/M1~dataout\);

-- Location: PIN_5
\A0~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_A0,
	dataout => \A0~dataout\);

-- Location: PIN_6
\A1~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_A1,
	dataout => \A1~dataout\);

-- Location: PIN_15
\/WR~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => \ww_/WR\,
	dataout => \/WR~dataout\);

-- Location: PIN_34
\/IORQ~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => \ww_/IORQ\,
	dataout => \/IORQ~dataout\);

-- Location: LC5
\inst11~3\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "invert",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pterm0 => \inst11~3_pterm0_bus\,
	pterm1 => \inst11~3_pterm1_bus\,
	pterm2 => \inst11~3_pterm2_bus\,
	pterm3 => \inst11~3_pterm3_bus\,
	pterm4 => \inst11~3_pterm4_bus\,
	pterm5 => \inst11~3_pterm5_bus\,
	pxor => \inst11~3_pxor_bus\,
	pclk => \inst11~3_pclk_bus\,
	papre => \inst11~3_papre_bus\,
	paclr => \inst11~3_paclr_bus\,
	pena => \inst11~3_pena_bus\,
	dataout => \inst11~3_dataout\);

-- Location: PIN_12
\/CTCE~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "output",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	datain => \inst~3_dataout\,
	oe => VCC,
	padio => \ww_/CTCE\);

-- Location: PIN_11
\OUT0~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "output",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	datain => \inst11~3_dataout\,
	oe => VCC,
	padio => ww_OUT0);
END structure;


