----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/21/2020 05:07:34 PM
-- Design Name: 
-- Module Name: shorten - Behavioral
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

entity shorten is
    Port ( input : in STD_LOGIC_VECTOR (0 downto 0);
           output : out STD_LOGIC_VECTOR (0 downto 0);
           round_up : in STD_LOGIC);
end shorten;

architecture Behavioral of shorten is

begin


end Behavioral;
