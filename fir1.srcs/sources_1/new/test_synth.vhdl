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
library UNISIM;
use UNISIM.VComponents.all;

entity test_synth is
    port (
        clk : in std_logic;
        sw : in STD_LOGIC_VECTOR (15 downto 0);
        led : out STD_LOGIC_VECTOR (15 downto 0)
--        shift_reg_debug : out std_logic_vector (27 downto 0);
--        mult_reg_debug : out std_logic_vector (63 downto 0);
--        encoded_debug : out std_logic_vector (3 downto 0);
--        filtered_debug : out std_logic_vector (11 downto 0)
    );
end test_synth;



architecture Behavioral of test_synth is

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

component shift_mult_generic is
    generic (
        length : integer;
        width : integer;
        padding : integer
    );
    port (
        shift_in : in STD_LOGIC_VECTOR (width-1 downto 0);
        shift_out : out STD_LOGIC_VECTOR (width-1 downto 0);
        sum_out : out STD_LOGIC_VECTOR (width*2+padding-1 downto 0);
        clk : in STD_LOGIC;
        en : in STD_LOGIC;
        rst : in STD_LOGIC;
        par_out : out STD_LOGIC_VECTOR ((width*(length-1))-1 downto 0);
        coef_in : in STD_LOGIC_VECTOR (width*length-1 downto 0);
        mult_out : out STD_LOGIC_VECTOR (width*2*length-1 downto 0)
    );
end component;

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

signal mmcm_clk, en_sig : std_logic;
signal clkfb_loopback : std_logic;
signal lock_sig : std_logic;
signal rst : std_logic;
signal encoded, for_decode : std_logic_vector (3 downto 0);
signal filtered : std_logic_vector (11 downto 0);

begin

--   filtered_debug <= filtered;
--   encoded_debug <= encoded;

   rst <= '0';
   for_decode <= filtered(6 downto 3);

   MMCME2_BASE_inst : MMCME2_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F => 10.0,    -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD => 10.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT1_DIVIDE => 10,
      CLKOUT2_DIVIDE => 1,
      CLKOUT3_DIVIDE => 1,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      CLKOUT6_DIVIDE => 1,
      CLKOUT0_DIVIDE_F => 1.0,   -- Divide amount for CLKOUT0 (1.000-128.000).
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      CLKOUT6_PHASE => 0.0,
      CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      DIVCLK_DIVIDE => 1,        -- Master division value (1-106)
      REF_JITTER1 => 0.0,        -- Reference input jitter in UI (0.000-0.999).
      STARTUP_WAIT => FALSE      -- Delays DONE until MMCM is locked (FALSE, TRUE)
   )
   port map (
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => clkfb_loopback,
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT1 => mmcm_clk,     -- 1-bit output: CLKOUT1
      -- Status Ports: 1-bit (each) output: MMCM status ports
      LOCKED => lock_sig,       -- 1-bit output: LOCK
      -- Clock Inputs: 1-bit (each) input: Clock input
      CLKIN1 => clk,       -- 1-bit input: Clock
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN => '0',       -- 1-bit input: Power-down
      RST => '0',             -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => clkfb_loopback      -- 1-bit input: Feedback clock
   );

   clk_div : clk_div_generic
        generic map (
            period_width => 24
        )
        port map (
            period => x"989680", -- 100MHz/10Hz
            clk => mmcm_clk,
            en => '1',
            rst => rst,
            en_out => en_sig
        );

    encode : encoder
        port map (
            level_in => sw,
            nibble_out => encoded,
            en => '1'
        );
    
    filter : shift_mult_generic
        generic map (
            length => 8,
            width => 4,
            padding => 4
        )
        port map (
            shift_in => encoded,
            sum_out => filtered,
            clk => mmcm_clk,
            en => en_sig,
            rst => rst,
            coef_in => x"11111111"
--            par_out => shift_reg_debug,
--            mult_out => mult_reg_debug
        );
    
    decode : decoder port map (
        level_out => led,
        nibble_in => for_decode,
        en => '1'
    );

end Behavioral;
