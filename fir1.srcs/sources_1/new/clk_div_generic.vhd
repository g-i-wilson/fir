----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/10/2020 12:58:40 PM
-- Design Name: 
-- Module Name: clk_div_generic - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_div_generic is
    generic (
        half_div_width : integer
    );
    port (
        half_div_value : std_logic_vector (half_div_width-1 downto 0);
        half_div_out : out std_logic_vector (half_div_width-1 downto 0);
        clk_in : in STD_LOGIC;
        clk_out : out STD_LOGIC;
        en : in STD_LOGIC;
        rst : in STD_LOGIC
    );
end clk_div_generic;



architecture Behavioral of clk_div_generic is

signal clk : std_logic;
signal half_div : std_logic_vector (half_div_width-1 downto 0);

begin

    clk_out <= clk;
    half_div_out <= half_div;

    process (clk_in) begin
        if rising_edge(clk_in) then
            if (rst = '1') then
                clk <= '0';
                half_div <= (others=>'0'); -- reset to zeros
            elsif (en = '1') then
                half_div <= std_logic_vector( unsigned(half_div) + 1 );
                if (half_div = half_div_value) then
                    half_div <= (others=>'0'); -- reset to zeros
                    clk <= not clk;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
