LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

  ENTITY testbench IS
  END testbench;

  ARCHITECTURE behavior OF testbench IS 

    signal clk,clk_mod :  std_logic;
    signal divide_value :  integer;
    constant clk_period : time := 10 ns;

    begin
  -- Component Instantiation
          uut: entity work.clk_gen PORT MAP(
                  clk => clk,
                  clk_mod => clk_mod,
                        divide_value => divide_value );

    simulate : process
    begin
        divide_value <= 10;  --divide the input clock by 10 to get 10(100/10) MHz signal.
        wait for 500 ns;
        divide_value <= 19;  --divide the input clock by 19 to get 5.3(100/19) MHz signal.
        wait;
    end process;

    clk_process :process  --generates a 100 MHz clock.
   begin
        clk <= '0';
        wait for clk_period/2;  --for 5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 5 ns signal is '1'.
   end process;

  END;

