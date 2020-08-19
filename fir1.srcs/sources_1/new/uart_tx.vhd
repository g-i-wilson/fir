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
        BIT_PERIOD_WIDTH : positive;
        LITTLE_ENDIAN : boolean := true
    );
    port ( 
        CLK : in STD_LOGIC;
        EN : in STD_LOGIC;
        RST : in STD_LOGIC;
        VALID_IN : in STD_LOGIC;
        DATA_IN : in STD_LOGIC_VECTOR (7 downto 0);
        BIT_PERIOD : in STD_LOGIC_VECTOR (bit_period_width-1 downto 0); -- units of clock cycles
        
        READY_OUT : out STD_LOGIC;
        TX_OUT : out STD_LOGIC
    );
end SerialTx;

architecture Behavioral of SerialTx is

  
  type state_type is (
    READY,
    START,
    TX_BYTE,
    STOP
  );

  signal current_state        : state_type := STOP;
  signal next_state           : state_type := STOP;
       
  signal timing_en            : std_logic;
  signal timing_rst           : std_logic;
  signal bit_en               : std_logic;
  signal bit_countdown        : std_logic_vector (3 downto 0);
  signal byte_en              : std_logic;
  signal bit_period_sig       : std_logic;
  signal byte_period_sig      : std_logic;

  signal reg_shift_en         : std_logic;
  signal reg_par_en           : std_logic;
  signal reg_rst              : std_logic;
  signal reg_shift_out        : std_logic;
  signal reg_default_state    : std_logic_vector (7 downto 0) := x"00";
       
begin


   bit_div : entity work.clk_div_generic
        generic map (
            period_width => bit_period_width
        )
        port map (
            PERIOD => BIT_PERIOD,
            CLK => CLK,
            EN => timing_en,
            RST => timing_rst,
            
            EN_OUT => bit_en
        );
   
   byte_div : entity work.clk_div_generic
        generic map (
            period_width => 4
        )
        port map (
            PERIOD => x"A",
            CLK => CLK,
            EN => bit_en,
            RST => timing_rst,
            
            COUNT_OUT => bit_countdown
        );

    tx_reg: entity work.reg1D
      generic map (
        length => 8,
        big_endian => false
      )
      port map (
        CLK => CLK,
        RST => reg_rst,
        
        shift_en => reg_shift_en,
        par_en => reg_par_en,
     
        par_in => DATA_IN,
        shift_out => reg_shift_out,
        
        default_state => reg_default_state
      );

  FSM_state_register: process (CLK) begin
    if rising_edge(CLK) then
      if (RST = '1') then
        current_state <= READY;
      elsif (EN = '1') then
        current_state <= next_state;
      else
        current_state <= current_state;
      end if;
    end if;
  end process;


  FSM_next_state_logic: process (current_state, bit_countdown, VALID_IN) begin

    if (current_state = READY) then
      if (VALID_IN = '1') then
        next_state <= START;
      end if;

    elsif (current_state = START) then
      if (unsigned(bit_countdown) = 9) then
        next_state <= TX_BYTE;
      end if;

    elsif (current_state = TX_BYTE) then
      if (unsigned(bit_countdown) = 2) then
        next_state <= STOP;
      end if;

    elsif (current_state = STOP) then
      if (unsigned(bit_countdown) = 1) then
          if (VALID_IN = '1') then
            next_state <= START;
          else
            next_state <= READY;
          end if;
      end if;
      
    else
      next_state <= READY;
    end if;

  end process;


  FSM_output_logic: process (current_state) begin
  
    if (current_state = READY) then

    elsif (current_state = START) then

    elsif (current_state = TX_BYTE) then

    elsif (current_state = STOP) then
      
    else

    end if;

  end process;


end Behavioral;
