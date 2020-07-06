----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2020 12:47:15 PM
-- Design Name: 
-- Module Name: test_synth - Behavioral
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

entity test_synth is
    Port ( sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0));
end test_synth;

architecture Behavioral of test_synth is

signal nib_in, nib_out : std_logic_vector (3 downto 0);

component encoder is
    Port ( level_in : in STD_LOGIC_VECTOR (15 downto 0);
           nibble_out : out STD_LOGIC_VECTOR (3 downto 0);
           en : in STD_LOGIC);
end component;

component decoder is
    Port ( nibble_in : in STD_LOGIC_VECTOR (3 downto 0);
           level_out : out STD_LOGIC_VECTOR (15 downto 0);
           en : in STD_LOGIC);
end component;
    
begin

    nib_out <= std_logic_vector( unsigned(nib_in) + 1 );

    encode : encoder port map (
        level_in => sw,
        nibble_out => nib_in,
        en => '1'
    );
    
    decode : decoder port map (
        level_out => led,
        nibble_in => nib_out,
        en => '1'
    );

end Behavioral;
