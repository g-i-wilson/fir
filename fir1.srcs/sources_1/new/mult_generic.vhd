----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/06/2020 04:24:54 PM
-- Design Name: 
-- Module Name: mult_generic - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


-- based on https://www.usna.edu/EE/ee313/handouts/EE313_VHDL_Part_03.pdf (page 6)


entity mult_generic is
    generic (
        a_len : integer;
        b_len : integer
    );
    port (
        in_a : in STD_LOGIC_VECTOR (a_len-1 downto 0);
        in_b : in STD_LOGIC_VECTOR (b_len-1 downto 0);
        mult_out : out STD_LOGIC_VECTOR ((a_len-1)+(b_len-1) downto 0)
    );
end mult_generic;

architecture Behavioral of mult_generic is

signal a_signed : signed(a_len-1 downto 0);
signal b_signed : signed(b_len-1 downto 0);

begin
    
    a_signed <= signed(in_a);
    b_signed <= signed(in_b);
    mult_out <= std_logic_vector(a_signed * b_signed);

end Behavioral;
