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
        BIT_PERIOD_WIDTH        : positive := 4
    );
    port ( 
        -- inputs
        CLK                     : in STD_LOGIC;
        EN                      : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        VALID                   : in STD_LOGIC;
        DATA                    : in STD_LOGIC_VECTOR (7 downto 0);
        BIT_PERIOD              : in STD_LOGIC_VECTOR (BIT_PERIOD_WIDTH-1 downto 0);
        -- outputs
        READY                   : out STD_LOGIC;
        TX                      : out STD_LOGIC
    );
end SerialTx;

architecture Behavioral of SerialTx is
       
  signal bit_en_sig             : std_logic;
  signal word_en_sig            : std_logic;
  signal ready_sig              : std_logic;
  signal count_rst              : std_logic;

  signal reg_par_en             : std_logic;
  signal reg_shift_en           : std_logic;
  signal reg_bits_in            : std_logic_vector (9 downto 0);
  
  signal word_period            : std_logic_vector (BIT_PERIOD_WIDTH+4-1 downto 0);
       
begin


    count_rst <= ready_sig;
    word_period <= std_logic_vector(resize(unsigned(BIT_PERIOD)*10,BIT_PERIOD_WIDTH+4));

    -- bit counter
   bit_div : entity work.clk_div_generic
        generic map (
            period_width        => BIT_PERIOD_WIDTH,
            phase_lead          => 1 -- load and timing start together, but after that, the shift happens 1 after timing
        )
        port map (
            period              => BIT_PERIOD,
            clk                 => clk,
            en                  => en,
            rst                 => count_rst,
            en_out              => bit_en_sig
        );

    -- word (byte + start/stop bits) counter
    word_div : entity work.clk_div_generic
        generic map (
            period_width        => BIT_PERIOD_WIDTH+4,
            phase_lead          => 1
        )
        port map (
            period              => word_period,
            clk                 => clk,
            en                  => en,
            rst                 => count_rst,
            en_out              => word_en_sig
        );
        
        
    reg_bits_in <= '1' & DATA & '0'; -- stop-bit, data, start-bit
    
    -- output load/shift register
    tx_reg: entity work.reg1D
        generic map (
            LENGTH              => 10,
            BIG_ENDIAN          => false
        )
        port map (
            CLK                 => CLK,
            RST                 => ready_sig,
            
            PAR_EN              => reg_par_en,
            PAR_IN              => reg_bits_in,
            
            SHIFT_EN            => reg_shift_en,
            SHIFT_OUT           => TX,
            
            DEFAULT_STATE       => "1111111111" -- all stop bits
        );
        
    -- FSM to control the load/shift register
    FSM: entity work.SerialTxFSM
        port map (
            CLK                 => CLK,
            EN                  => EN,
            RST                 => RST,
            VALID               => VALID,
            BIT_EN              => bit_en_sig,
            BYTE_EN             => word_en_sig,
            
            READY               => ready_sig,
            LOAD                => reg_par_en,
            SHIFT               => reg_shift_en
        );
    
    READY <= ready_sig;
    

end Behavioral;
