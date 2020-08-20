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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SerialTx is
    generic (
        BIT_PERIOD : positive := 4
    );
    port ( 
        CLK : in STD_LOGIC;
        EN : in STD_LOGIC;
        RST : in STD_LOGIC;
        VALID : in STD_LOGIC;
        DATA : in STD_LOGIC_VECTOR (7 downto 0);
        
        READY : out STD_LOGIC;
        TX : out STD_LOGIC
    );
end SerialTx;

architecture Behavioral of SerialTx is
       
  signal bit_en_sig               : std_logic;
  signal byte_en_sig        : std_logic;
  signal ready_sig              : std_logic;
  signal count_rst              : std_logic;

  signal reg_par_en           : std_logic;
  signal reg_shift_en           : std_logic;
  signal reg_bits_in        : std_logic_vector (9 downto 0);
  
  constant WORD_PERIOD       : integer := BIT_PERIOD*10;
  signal bit_period_count       : integer := 0;
  signal word_period_count       : integer := 0;
       
begin


    count_rst <= ready_sig;

    -- bit & byte counters
   bit_div : entity work.clk_div_generic
        generic map (
            period_width => half_period_width
        )
        port map (
            period => half_period,
            clk => clk,
            en => en,
            rst => rst,
            en_out => bit_en_sig
        );

   word_div : entity work.clk_div_generic
        generic map (
            period_width => half_period_width
        )
        port map (
            period => half_period,
            clk => clk,
            en => en,
            rst => rst,
            en_out => byte_en_sig
        );
        
        
    reg_bits_in <= '1' & DATA & '0'; -- stop-bit, data, start-bit
   
    tx_reg: entity work.reg1D
      generic map (
        LENGTH => 10,
        BIG_ENDIAN => false
      )
      port map (
        CLK => CLK,
        RST => ready_sig,
        
        PAR_EN => reg_par_en,
        PAR_IN => reg_bits_in,
        
        SHIFT_EN => reg_shift_en,
        SHIFT_OUT => TX,
        
        DEFAULT_STATE => "1111111111" -- all stop bits
      );

  FSM: entity work.SerialTxFSM
  port map (
    CLK => CLK,
    EN => EN,
    RST => RST,
    VALID => VALID,
    BIT_EN => bit_en_sig,
    BYTE_EN => byte_en_sig,
    
    READY => ready_sig,
    LOAD => reg_par_en,
    SHIFT => reg_shift_en
  );
  
  READY <= ready_sig;


end Behavioral;
