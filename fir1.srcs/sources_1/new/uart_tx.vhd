----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/11/2020 10:55:02 AM
-- Design Name: 
-- Module Name: uart_tx - Behavioral
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

entity uart_tx is
    generic (
        bit_period_width : integer;
        little_endian : boolean := true
    );
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (7 downto 0);
           tx_out : out STD_LOGIC;
           bit_period : in STD_LOGIC_VECTOR (bit_period_width-1 downto 0)
    );
end uart_tx;

architecture Behavioral of uart_tx is

    signal
        bit_period_en,
        bit_period_rst,
        bit_edge_sig,
        
        reg_shift_en,
        reg_par_en,
        reg_rst,
        reg_out_sig
        
        : std_logic;
        
        
    
    signal
        reg_default_state
        
        : std_logic_vector(7 downto 0) := x"00";
        
        
begin


   bit_period_div : entity work.clk_div_generic
        generic map (
            period_width => bit_period_width
        )
        port map (
            period => bit_period,
            clk => clk,
            en => bit_period_en,
            rst => bit_period_rst,
            en_out => bit_edge_sig
        );
        

    tx_reg: entity work.reg1D
      generic map (
        length => 8,
        big_endian => false
      )
      port map (
        clk => clk,
        rst => reg_rst,
        
        shift_en => reg_shift_en,
        par_en => reg_par_en,
     
        par_in => data_in,
        shift_out => reg_out_sig,
        
        default_state => reg_default_state
      );


end Behavioral;
