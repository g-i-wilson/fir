----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/21/2020 05:07:34 PM
-- Design Name: 
-- Module Name: diff_accum - Behavioral
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

entity diff_accum is
    Port ( in_a : in STD_LOGIC_VECTOR (0 downto 0);
           in_b : in STD_LOGIC_VECTOR (0 downto 0);
           diff_sum : out STD_LOGIC_VECTOR (0 downto 0);
           sign : out STD_LOGIC;
           clk : in STD_LOGIC;
           en : in STD_LOGIC;
           rst : in STD_LOGIC);
end diff_accum;

architecture Behavioral of diff_accum is

begin


end Behavioral;
