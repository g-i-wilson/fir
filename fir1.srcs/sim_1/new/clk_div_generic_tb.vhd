----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/10/2020 01:34:21 PM
-- Design Name: 
-- Module Name: clk_div_generic_tb - Behavioral
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

entity clk_div_generic_tb is
--  Port ( );
end clk_div_generic_tb;


architecture Behavioral of clk_div_generic_tb is

component clk_div_generic
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
end component;

signal
    test_clk_in,
    test_clk_out,
    test_rst,
    test_en
    : std_logic;
    
signal test_half_div : std_logic_vector(3 downto 0);

begin

    div0 : clk_div_generic
        generic map (
            half_div_width => 4
        )
        port map (
            half_div_value => x"3",
            half_div_out => test_half_div,
            clk_in => test_clk_in,
            clk_out => test_clk_out,
            en => test_en,
            rst => test_rst
        );

    process
    begin
    
        -- initial
        test_clk_in <= '0';
        test_rst <= '1';
        test_en <= '1';
        
            -- clock edge
            wait for 20ns;
            test_clk_in <= '1';
            wait for 20ns;
            test_clk_in <= '0';

        test_clk_in <= '0';
        test_rst <= '0';
        test_en <= '1';

        
        for i in 0 to 20 loop
            -- clock edge
            wait for 20ns;
            test_clk_in <= '1';
            wait for 20ns;
            test_clk_in <= '0';
            
            test_clk_in <= '0';
            test_rst <= '0';
            test_en <= '1';

        end loop;

    end process;

end Behavioral;
