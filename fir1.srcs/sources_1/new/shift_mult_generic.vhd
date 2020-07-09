----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2020 10:01:33 AM
-- Design Name: 
-- Module Name: shift_mult_generic - Behavioral
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

entity shift_mult_generic is
    generic (
        length : integer;
        width : integer
    );
    port (
        shift_in : in STD_LOGIC_VECTOR (width-1 downto 0);
        shift_out : out STD_LOGIC_VECTOR (width-1 downto 0);
        sum_out : out STD_LOGIC_VECTOR (width-1 downto 0);
        clk : in STD_LOGIC;
        en : in STD_LOGIC;
        rst : in STD_LOGIC;
        par_out : out STD_LOGIC_VECTOR ((width*(length-1))-1 downto 0);
        mult_in : in STD_LOGIC_VECTOR (width*length-1 downto 0);
        mult_out : out STD_LOGIC_VECTOR (width*2*length-1 downto 0)
    );
end shift_mult_generic;



architecture Behavioral of shift_mult_generic is

component reg_mult_generic
    generic (
        width : integer
    );
    port (
        reg_in : in STD_LOGIC_VECTOR (width-1 downto 0);
        coef_in : in STD_LOGIC_VECTOR (width-1 downto 0);
        reg_out : out STD_LOGIC_VECTOR (width-1 downto 0);
        clk : in STD_LOGIC;
        en : in STD_LOGIC;
        rst : in STD_LOGIC;
        mult_out : out STD_LOGIC_VECTOR (width*2-1 downto 0)
    );
end component;

signal all_reg_sig : std_logic_vector((width*(length-1))-1 downto 0);
-- provides all signals "between" each register, so width*(length-1)

begin

    in_reg : reg_mult_generic
        generic map (width)
        port map (
            clk      => clk,
            en       => en,
            rst      => rst,
            reg_in   => shift_in,
            reg_out  => all_reg_sig  (width   -1 downto 0),
            coef_in  => mult_in      (width   -1 downto 0),
            mult_out => mult_out     (width*2 -1 downto 0)
        );
        
    gen_middle : for i in 0 to (length-3) generate -- length 5 regs is: in,0,1,2,out
        middle_reg : reg_mult_generic
            generic map (width)
            port map (
                clk      => clk,
                en       => en,
                rst      => rst,
                reg_in   => all_reg_sig (  i    *width   +(width-1)   downto  i    *width   ),
                reg_out  => all_reg_sig ( (i+1) *width   +(width-1)   downto (i+1) *width   ),
                coef_in  => mult_in     ( (i+1) *width   +(width-1)   downto (i+1) *width   ),
                mult_out => mult_out    ( (i+1) *width*2 +(width*2-1) downto (i+1) *width*2 )
            );
    end generate gen_middle;
    
    out_reg : reg_mult_generic
        generic map (width)
        port map (
            clk      => clk,
            en       => en,
            rst      => rst,
            reg_in  => all_reg_sig  ( all_reg_sig'high  downto all_reg_sig'high -(width-1)   ),
            reg_out => shift_out,
            coef_in  => mult_in      ( mult_in'high      downto mult_in'high     -(width-1)   ),
            mult_out => mult_out     ( mult_out'high     downto mult_out'high    -(width*2-1) )
        );

    par_out <= all_reg_sig;
    
end Behavioral;
