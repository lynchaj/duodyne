-- generated by Digital. Don't modify this file!
-- Any changes will be lost if this file is regenerated.

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity DEMUX_GATE_2 is
  generic (
    Default : integer );
  port (
    out_0: out std_logic;
    out_1: out std_logic;
    out_2: out std_logic;
    out_3: out std_logic;
    sel: in std_logic_vector (1 downto 0);
    p_in: in std_logic );
end DEMUX_GATE_2;

architecture Behavioral of DEMUX_GATE_2 is
begin
    out_0 <= p_in when sel = "00" else std_logic(to_unsigned(Default, 1)(0));
    out_1 <= p_in when sel = "01" else std_logic(to_unsigned(Default, 1)(0));
    out_2 <= p_in when sel = "10" else std_logic(to_unsigned(Default, 1)(0));
    out_3 <= p_in when sel = "11" else std_logic(to_unsigned(Default, 1)(0));
end Behavioral;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- dual 2-line to 4-line decoder/demultiplexer
entity n74139 is
  port (
    n1A: in std_logic;
    n1B: in std_logic;
    not1G: in std_logic;
    n2A: in std_logic;
    n2B: in std_logic;
    not2G: in std_logic;
    VCC: in std_logic;
    GND: in std_logic;
    not1Y0: out std_logic;
    not1Y1: out std_logic;
    not1Y2: out std_logic;
    not1Y3: out std_logic;
    not2Y0: out std_logic;
    not2Y1: out std_logic;
    not2Y2: out std_logic;
    not2Y3: out std_logic);
end n74139;

architecture Behavioral of n74139 is
  signal s0: std_logic_vector(1 downto 0);
  signal s1: std_logic_vector(1 downto 0);
begin
  s0(0) <= n1A;
  s0(1) <= n1B;
  s1(0) <= n2A;
  s1(1) <= n2B;
  gate0: entity work.DEMUX_GATE_2
    generic map (
      Default => 1)
    port map (
      sel => s0,
      p_in => not1G,
      out_0 => not1Y0,
      out_1 => not1Y1,
      out_2 => not1Y2,
      out_3 => not1Y3);
  gate1: entity work.DEMUX_GATE_2
    generic map (
      Default => 1)
    port map (
      sel => s1,
      p_in => not2G,
      out_0 => not2Y0,
      out_1 => not2Y1,
      out_2 => not2Y2,
      out_3 => not2Y3);
end Behavioral;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity MUX_GATE_BUS_1 is
  generic ( Bits : integer ); 
  port (
    p_out: out std_logic_vector ((Bits-1) downto 0);
    sel: in std_logic;
    
    in_0: in std_logic_vector ((Bits-1) downto 0);
    in_1: in std_logic_vector ((Bits-1) downto 0) );
end MUX_GATE_BUS_1;

architecture Behavioral of MUX_GATE_BUS_1 is
begin
  with sel select
    p_out <=
      in_0 when '0',
      in_1 when '1',
      (others => '0') when others;
end Behavioral;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- quad 2-line to 1-line data selectors/multiplexers
entity n74157 is
  port (
    S: in std_logic; -- select
    A1: in std_logic;
    A2: in std_logic;
    A3: in std_logic;
    A4: in std_logic;
    B1: in std_logic;
    B2: in std_logic;
    B3: in std_logic;
    B4: in std_logic;
    G: in std_logic; -- strobe
    VCC: in std_logic;
    GND: in std_logic;
    Y1: out std_logic;
    Y2: out std_logic;
    Y3: out std_logic;
    Y4: out std_logic);
end n74157;

architecture Behavioral of n74157 is
  signal s0: std_logic_vector(3 downto 0);
  signal s1: std_logic_vector(3 downto 0);
  signal s2: std_logic_vector(3 downto 0);
  signal s3: std_logic_vector(3 downto 0);
begin
  s1(0) <= B1;
  s1(1) <= B2;
  s1(2) <= B3;
  s1(3) <= B4;
  s0(0) <= A1;
  s0(1) <= A2;
  s0(2) <= A3;
  s0(3) <= A4;
  gate0: entity work.MUX_GATE_BUS_1
    generic map (
      Bits => 4)
    port map (
      sel => S,
      in_0 => s0,
      in_1 => s1,
      p_out => s2);
  gate1: entity work.MUX_GATE_BUS_1
    generic map (
      Bits => 4)
    port map (
      sel => G,
      in_0 => s2,
      in_1 => "0000",
      p_out => s3);
  Y1 <= s3(0);
  Y2 <= s3(1);
  Y3 <= s3(2);
  Y4 <= s3(3);
end Behavioral;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity MUX_GATE_2 is
  port (
    p_out: out std_logic;
    sel: in std_logic_vector (1 downto 0);
    
    in_0: in std_logic;
    in_1: in std_logic;
    in_2: in std_logic;
    in_3: in std_logic );
end MUX_GATE_2;

architecture Behavioral of MUX_GATE_2 is
begin
  with sel select
    p_out <=
      in_0 when "00",
      in_1 when "01",
      in_2 when "10",
      in_3 when "11",
      '0' when others;
end Behavioral;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- dual 4-line to 1-line data selectors/multiplexers
entity n74153 is
  port (
    A: in std_logic;
    B: in std_logic;
    n2G: in std_logic;
    n2C0: in std_logic;
    n2C1: in std_logic;
    n2C2: in std_logic;
    n2C3: in std_logic;
    n1G: in std_logic;
    n1C0: in std_logic;
    n1C1: in std_logic;
    n1C2: in std_logic;
    n1C3: in std_logic;
    VCC: in std_logic;
    GND: in std_logic;
    n2Y: out std_logic;
    n1Y: out std_logic);
end n74153;

architecture Behavioral of n74153 is
  signal s0: std_logic_vector(1 downto 0);
  signal s1: std_logic;
  signal s2: std_logic;
begin
  s0(0) <= A;
  s0(1) <= B;
  gate0: entity work.MUX_GATE_2
    port map (
      sel => s0,
      in_0 => n2C0,
      in_1 => n2C1,
      in_2 => n2C2,
      in_3 => n2C3,
      p_out => s1);
  gate1: entity work.MUX_GATE_2
    port map (
      sel => s0,
      in_0 => n1C0,
      in_1 => n1C1,
      in_2 => n1C2,
      in_3 => n1C3,
      p_out => s2);
  n2Y <= (NOT n2G AND s1);
  n1Y <= (NOT n1G AND s2);
end Behavioral;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- 8-line to 3-Line priority encoder
entity n74148 is
  port (
    EI: in std_logic;
    n0: in std_logic;
    n1: in std_logic;
    n2: in std_logic;
    n3: in std_logic;
    n4: in std_logic;
    n5: in std_logic;
    n6: in std_logic;
    n7: in std_logic;
    VCC: in std_logic;
    GND: in std_logic;
    A2: out std_logic;
    A1: out std_logic;
    A0: out std_logic;
    GS: out std_logic;
    E0: out std_logic);
end n74148;

architecture Behavioral of n74148 is
  signal s0: std_logic;
  signal s1: std_logic;
  signal s2: std_logic;
  signal s3: std_logic;
begin
  A2 <= ((n4 AND n5 AND n6 AND n7) OR EI);
  GS <= ((n0 AND n1 AND n2 AND n3 AND n4 AND n5 AND n6 AND n7) OR EI);
  s2 <= NOT n2;
  s0 <= NOT n4;
  s1 <= NOT n5;
  s3 <= NOT n6;
  A1 <= ((n2 AND n3 AND n6 AND n7) OR (s0 AND n6 AND n7) OR (s1 AND n6 AND n7) OR EI);
  A0 <= ((n1 AND n3 AND n5 AND n7) OR (s2 AND n3 AND n5 AND n7) OR (s0 AND n5 AND n7) OR (s3 AND n7) OR EI);
  E0 <= (NOT n0 OR NOT n1 OR s2 OR NOT n3 OR s0 OR s1 OR s3 OR NOT n7 OR EI);
end Behavioral;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity DIG_D_FF_AS is
  
  port (
    Q: out std_logic;
    notQ: out std_logic;
    Set: in std_logic;
    D: in std_logic;
    C: in std_logic;
    Clr: in std_logic );
end DIG_D_FF_AS;

architecture Behavioral of DIG_D_FF_AS is
   signal state : std_logic := '0';
begin
    process (Set, Clr, C)
    begin
        if (Set='1') then
            state <= NOT('0');
        elsif (Clr='1') then
            state <= '0';
        elsif rising_edge(C) then
            state <= D;
        end if;
    end process;

    Q <= state;
    notQ <= NOT( state );
end Behavioral;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- 8-bit parallel-out serial shift register, asynchronous clear
entity n74164 is
  port (
    CP: in std_logic;
    DSA: in std_logic;
    DSB: in std_logic;
    notMR: in std_logic;
    VCC: in std_logic;
    GND: in std_logic;
    Q0: out std_logic;
    Q1: out std_logic;
    Q2: out std_logic;
    Q3: out std_logic;
    Q4: out std_logic;
    Q5: out std_logic;
    Q6: out std_logic;
    Q7: out std_logic);
end n74164;

architecture Behavioral of n74164 is
  signal s0: std_logic;
  signal s1: std_logic;
  signal Q0_temp: std_logic;
  signal Q1_temp: std_logic;
  signal Q2_temp: std_logic;
  signal Q3_temp: std_logic;
  signal Q4_temp: std_logic;
  signal Q5_temp: std_logic;
  signal Q6_temp: std_logic;
begin
  s0 <= (DSA AND DSB);
  s1 <= NOT notMR;
  gate0: entity work.DIG_D_FF_AS
    port map (
      Set => '0',
      D => s0,
      C => CP,
      Clr => s1,
      Q => Q0_temp);
  gate1: entity work.DIG_D_FF_AS
    port map (
      Set => '0',
      D => Q0_temp,
      C => CP,
      Clr => s1,
      Q => Q1_temp);
  gate2: entity work.DIG_D_FF_AS
    port map (
      Set => '0',
      D => Q1_temp,
      C => CP,
      Clr => s1,
      Q => Q2_temp);
  gate3: entity work.DIG_D_FF_AS
    port map (
      Set => '0',
      D => Q2_temp,
      C => CP,
      Clr => s1,
      Q => Q3_temp);
  gate4: entity work.DIG_D_FF_AS
    port map (
      Set => '0',
      D => Q3_temp,
      C => CP,
      Clr => s1,
      Q => Q4_temp);
  gate5: entity work.DIG_D_FF_AS
    port map (
      Set => '0',
      D => Q4_temp,
      C => CP,
      Clr => s1,
      Q => Q5_temp);
  gate6: entity work.DIG_D_FF_AS
    port map (
      Set => '0',
      D => Q5_temp,
      C => CP,
      Clr => s1,
      Q => Q6_temp);
  gate7: entity work.DIG_D_FF_AS
    port map (
      Set => '0',
      D => Q6_temp,
      C => CP,
      Clr => s1,
      Q => Q7);
  Q0 <= Q0_temp;
  Q1 <= Q1_temp;
  Q2 <= Q2_temp;
  Q3 <= Q3_temp;
  Q4 <= Q4_temp;
  Q5 <= Q5_temp;
  Q6 <= Q6_temp;
end Behavioral;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity main is
  port (
    IOxSEL: in std_logic;
    notCPUxRD: in std_logic;
    notDMAxIEI1: in std_logic;
    notCPUxM1: in std_logic;
    notCPUxIORQ: in std_logic;
    notDMAxIEO2: in std_logic;
    notFPxLATCH: in std_logic;
    notCPUxWR: in std_logic;
    CPU_A2: in std_logic;
    notCSxMAP: in std_logic;
    CPU_A14: in std_logic;
    mA14: in std_logic;
    CPU_A15: in std_logic;
    mA15: in std_logic;
    CPU_A1: in std_logic;
    notINTxI2C: in std_logic;
    notA: in std_logic;
    WSxMEMRD: in std_logic;
    WSxIORD: in std_logic;
    WSxMEMWR: in std_logic;
    WSxIOWR: in std_logic;
    notCPUxMREQ: in std_logic;
    notCPUxRFSH: in std_logic;
    CPU_D0: in std_logic;
    notEIRQ7: in std_logic;
    notEIRQ6: in std_logic;
    notEIRQ0: in std_logic;
    notEIRQ1: in std_logic;
    notEIRQ2: in std_logic;
    notEIRQ3: in std_logic;
    notEIRQ5: in std_logic;
    notEIRQ4: in std_logic;
    CLK: in std_logic;
    notCPUxRESET: in std_logic;
    DATAxDIR: out std_logic;
    notIM2xEN: out std_logic;
    notFPxLATCHxRD: out std_logic;
    FPxLATCHxWR: out std_logic;
    notIM2xIEO: out std_logic;
    SEL_A14: out std_logic;
    SEL_A15: out std_logic;
    notCSxI2C: out std_logic;
    INT_I2C: out std_logic;
    notCSxI2CxWR: out std_logic;
    notAxPRIME: out std_logic;
    READY: out std_logic;
    notPAGExEN: out std_logic;
    notPAGExWR: out std_logic;
    IM2xS2: out std_logic;
    IM2xS1: out std_logic;
    IM2xS0: out std_logic;
    notIM2xINT: out std_logic;
    n1WS: out std_logic;
    n2WS: out std_logic;
    n3WS: out std_logic;
    n4WS: out std_logic;
    n5WS: out std_logic;
    n6WS: out std_logic;
    n7WS: out std_logic;
    n8WS: out std_logic;
    RESET: out std_logic);
end main;

architecture Behavioral of main is
  signal s0: std_logic;
  signal notIM2xIEO_temp: std_logic;
  signal notIM2xINT_temp: std_logic;
  signal s1: std_logic;
  signal s2: std_logic;
  signal s3: std_logic;
  signal notCSxI2C_temp: std_logic;
  signal s4: std_logic;
  signal s5: std_logic;
  signal const1b1: std_logic;
  signal s6: std_logic;
  signal s7: std_logic;
  signal s8: std_logic;
begin
  const1b1 <= '1';
  s0 <= (notCPUxM1 OR notCPUxIORQ);
  notFPxLATCHxRD <= (notCPUxRD OR notFPxLATCH);
  FPxLATCHxWR <= NOT (notFPxLATCH OR notCPUxWR);
  gate0: entity work.n74139
    port map (
      n1A => CPU_A2,
      n1B => notCSxMAP,
      not1G => notCPUxWR,
      n2A => CPU_A2,
      n2B => notCSxMAP,
      not2G => '0',
      VCC => '1',
      GND => '0',
      not1Y0 => notPAGExWR,
      not1Y1 => s1,
      not2Y1 => s2);
  gate1: entity work.n74157
    port map (
      S => notCPUxIORQ,
      A1 => CPU_A14,
      A2 => CPU_A15,
      A3 => '1',
      A4 => '1',
      B1 => mA14,
      B2 => mA15,
      B3 => '1',
      B4 => '1',
      G => '0',
      VCC => '1',
      GND => '0',
      Y1 => SEL_A14,
      Y2 => SEL_A15);
  INT_I2C <= NOT notINTxI2C;
  gate2: entity work.n74153
    port map (
      A => notCPUxMREQ,
      B => notCPUxRD,
      n2G => '1',
      n2C0 => '1',
      n2C1 => '1',
      n2C2 => '1',
      n2C3 => '1',
      n1G => '0',
      n1C0 => WSxMEMRD,
      n1C1 => WSxIORD,
      n1C2 => WSxMEMWR,
      n1C3 => WSxIOWR,
      VCC => '1',
      GND => '0',
      n1Y => s4);
  s5 <= NOT (notCPUxMREQ AND notCPUxIORQ);
  gate3: entity work.n74148
    port map (
      EI => '0',
      n0 => notEIRQ7,
      n1 => notEIRQ6,
      n2 => notEIRQ5,
      n3 => notEIRQ4,
      n4 => notEIRQ3,
      n5 => notEIRQ2,
      n6 => notEIRQ1,
      n7 => notEIRQ0,
      VCC => '1',
      GND => '0',
      A2 => IM2xS2,
      A1 => IM2xS1,
      A0 => IM2xS0,
      GS => notIM2xINT_temp);
  RESET <= NOT notCPUxRESET;
  s6 <= NOT const1b1;
  s7 <= NOT notCPUxRESET;
  DATAxDIR <= ((notCPUxRD OR IOxSEL) AND (s0 OR NOT notDMAxIEI1));
  notIM2xIEO_temp <= (notIM2xINT_temp OR NOT notDMAxIEO2);
  s3 <= (s1 OR CPU_A1);
  notCSxI2C_temp <= (s2 OR NOT CPU_A1);
  READY <= (NOT (s5 AND notCPUxRFSH) OR s4);
  gate4: entity work.n74164
    port map (
      CP => CLK,
      DSA => '1',
      DSB => '1',
      notMR => s5,
      VCC => '1',
      GND => '0',
      Q0 => n1WS,
      Q1 => n2WS,
      Q2 => n3WS,
      Q3 => n4WS,
      Q4 => n5WS,
      Q5 => n6WS,
      Q6 => n7WS,
      Q7 => n8WS);
  notIM2xEN <= (s0 OR notIM2xIEO_temp);
  notAxPRIME <= (notCSxI2C_temp OR notCPUxWR);
  gate5: entity work.DIG_D_FF_AS
    port map (
      Set => s6,
      D => CPU_D0,
      C => s3,
      Clr => s7,
      notQ => s8);
  notPAGExEN <= (s8 OR (NOT const1b1 AND NOT notCPUxRESET));
  notIM2xIEO <= notIM2xIEO_temp;
  notCSxI2C <= notCSxI2C_temp;
  notCSxI2CxWR <= notA;
  notIM2xINT <= notIM2xINT_temp;
end Behavioral;
