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
        period_width : integer
    );
    port (
        period : std_logic_vector (period_width-1 downto 0);
        clk : in std_logic;
        en : in std_logic;
        rst : in std_logic;
        
        en_out : out std_logic;
        count_out : out std_logic_vector (period_width-1 downto 0)
    );
end clk_div_generic;



architecture Behavioral of clk_div_generic is

signal en_sig : std_logic;
signal count_sig : std_logic_vector (period_width-1 downto 0) := (others=>'0');

begin

    count_out <= count_sig;

    -- counter register and output logic
    process (clk) begin
        if rising_edge(clk) then
            if (rst = '1') then
                en_sig <= '0';
                count_sig <= (others=>'0'); -- reset to zeros
            elsif (en = '1') then
                count_sig <= std_logic_vector( unsigned(count_sig) + 1 );
                if (count_sig = period) then
                    count_sig <= (others=>'0'); -- reset to zeros
                    en_sig <= '1';
                else
                    en_sig <= '0';
                end if;
            end if;
        end if;
    end process;
    
    -- FF after output logic
    process (clk) begin
        if rising_edge(clk) then
            if (rst = '1') then
                en_out <= '0';
            elsif (en = '1') then
                en_out <= en_sig;
            end if;
        end if;
    end process;

end Behavioral;
