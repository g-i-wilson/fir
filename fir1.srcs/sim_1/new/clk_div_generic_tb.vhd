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
end component;

signal
    test_clk,
    test_rst,
    test_en,
    test_en_out
    : std_logic;
    
signal test_count_out : std_logic_vector(3 downto 0);

begin

    div0 : clk_div_generic
        generic map (
            period_width => 4
        )
        port map (
            period => x"3",
            clk => test_clk,
            en => test_en,
            rst => test_rst,
            en_out => test_en_out,
            count_out => test_count_out
        );

    process
    begin
    
        -- initial
        test_clk <= '0';
        test_rst <= '1';
        test_en <= '1';
        
            -- clock edge
            wait for 20ns;
            test_clk <= '1';
            wait for 20ns;
            test_clk <= '0';

        test_clk <= '0';
        test_rst <= '0';
        test_en <= '1';

        
        for i in 0 to 20 loop
            -- clock edge
            wait for 20ns;
            test_clk <= '1';
            wait for 20ns;
            test_clk <= '0';
            
            test_clk <= '0';
            test_rst <= '0';
            test_en <= '1';

        end loop;

    end process;

end Behavioral;
