----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/20/2020 01:27:28 PM
-- Design Name: 
-- Module Name: pdm_generic - Behavioral
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

entity pdm_generic is
    generic (
        input_width : integer;
        output_width : integer;
        pulse_count_width : integer
    );
    port (
        input : in STD_LOGIC_VECTOR (input_width-1 downto 0);
        output : out STD_LOGIC_VECTOR (output_width-1 downto 0);
        error : out STD_LOGIC_VECTOR (pulse_count_width+(input_width-output_width)-1 downto 0);
        pulse_count : in STD_LOGIC_VECTOR (pulse_count_width-1 downto 0);
        clk : in STD_LOGIC;
        en : in STD_LOGIC;
        rst : in STD_LOGIC
    );
end pdm_generic;


architecture Behavioral of pdm_generic is

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

    component reg_generic
      generic (
        reg_len : integer
      );
      port (
        clk : in std_logic;
        rst : in std_logic;
        en : in std_logic;
     
        reg_in : in std_logic_vector(reg_len-1 downto 0);
        reg_out : out std_logic_vector(reg_len-1 downto 0)
      );
    end component;

    signal
        enable_pulse_sig
        : std_logic;
    signal
        error_count_sig,
        error_count_reg_sig 
        : std_logic_vector (pulse_count_width+(input_width-output_width)-1 downto 0) := (others=>'0');
    signal
        input_downshifted_sig, 
        input_reg_sig, output_sig, 
        output_reg_sig, 
        output_upshifted_sig,
        in_out_difference_sig
        : std_logic_vector (input_width-1 downto 0);


begin

    -- input downshifted will become the output (with possibly +1 added, depending on error function)
    input_downshifted_sig <= std_logic_vector(
        shift_right(signed(input_reg_sig),(input_width-output_width))
    );
    
    -- (input-output) delta
    in_out_difference_sig <= std_logic_vector(
        signed(input_reg_sig) - shift_left(signed(output_reg_sig),(input_width-output_width))
    );
    
    -- error function ADDER comb logic
    error_count_sig <= std_logic_vector(
        signed(error_count_reg_sig) + resize(signed(in_out_difference_sig),error_count_reg_sig'length)
    );
    
    -- determine whether the error is positive or negative (for zero, we assume negative; truncate)
    process (error_count_reg_sig, input_downshifted_sig) begin
        if (signed(error_count_reg_sig) > 0) then
            output_sig <= std_logic_vector( signed(input_downshifted_sig) + 1 );
        else
            output_sig <= input_downshifted_sig;
        end if;
    end process;
    
    
    error <= error_count_reg_sig;
    
    output <= output_reg_sig(input_width-1 downto input_width-output_width);
    

    input_reg : reg_generic
        generic map (
            reg_len => input_width
        )
        port map (
            clk => clk,
            en => en,
            rst => rst,
            reg_in => input,
            reg_out => input_reg_sig
        );

    error_reg : reg_generic
        generic map (
            reg_len => (pulse_count_width+(input_width-output_width))
        )
        port map (
            clk => clk,
            en => en,
            rst => rst,
            reg_in => error_count_sig,
            reg_out => error_count_reg_sig
        );

    output_reg : reg_generic
        generic map (
            reg_len => input_width
        )
        port map (
            clk => clk,
            en => enable_pulse_sig,
            rst => rst,
            reg_in => output_sig,
            reg_out => output_reg_sig
        );
        
   pulse_enable : clk_div_generic
        generic map (
            period_width => pulse_count_width
        )
        port map (
            period => pulse_count,
            clk => clk,
            en => '1',
            rst => rst,
            en_out => enable_pulse_sig
        );
        


end Behavioral;
