----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 07/31/2020 03:16:41 PM
-- Design Name:
-- Module Name: reg2D_tb - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg2D_tb is
--  Port ( );
end reg2D_tb;

architecture Behavioral of reg2D_tb is

begin

  process

  begin

      -- initial
      test_rst <= '1';

      wait for 5ns;
      test_clk <= '1';
      wait for 5ns;
      test_clk <= '0';
      wait for 5ns;

      test_rst <= '0';


      for a in 0 to 4096 loop

          wait for 5ns;
          test_clk <= '1';
          wait for 5ns;
          test_clk <= '0';

      end loop;

  end process;


end Behavioral;
