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
    port (
        -- inputs
        CLK                     : in STD_LOGIC;
        EN                      : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        BIT_TIMER_PERIOD        : in STD_LOGIC_VECTOR (15 downto 0) := x"28B1"; -- units of clock cycles (default is 9600bps)
        VALID                   : in STD_LOGIC;
        DATA                    : in STD_LOGIC_VECTOR (7 downto 0);
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
  
  signal data_sig               : std_logic_vector (7 downto 0);
  signal reg_bits_in            : std_logic_vector (9 downto 0);

  signal word_period            : std_logic_vector (31 downto 0);

begin


    count_rst <= ready_sig;

    -- bit counter
--   bit_timer : entity work.clk_div_generic
--        generic map (
--            period_width        => 16,
--            phase_lead          => 1 -- load and timing start together, but after that, the shift happens 1 after timing
--        )
--        port map (
--            period              => BIT_TIMER_PERIOD,
--            clk                 => clk,
--            en                  => en,
--            rst                 => count_rst,
--            en_out              => bit_en_sig
--        );
    bit_pulses : entity work.PulseGenerator
        generic map (
            WIDTH               => 16 
        )
        port map (
            CLK                 => CLK,
            RST                 => count_rst,
            EN                  => EN,
            PERIOD              => BIT_TIMER_PERIOD,
            PHASE               => x"0001", -- load and timing start together, but after that, the shift happens 1 after timing
            LAGGING             => '1', -- true
            PULSE               => bit_en_sig
        );

        
--    word_period <= std_logic_vector(unsigned(BIT_TIMER_PERIOD)*to_unsigned(10,16));

--    -- word (byte + start/stop bits) counter
--    word_div : entity work.clk_div_generic
--        generic map (
--            period_width        => 32,
--            phase_lead          => 1
--        )
--        port map (
--            period              => word_period,
--            clk                 => clk,
--            en                  => en,
--            rst                 => count_rst,
--            en_out              => word_en_sig
--        );
    word_timer : entity work.Timer
        generic map (
            WIDTH           => 4
        )
        port map (
            -- inputs
            CLK             => CLK,
            EN              => bit_en_sig,
            RST             => count_rst,
            COUNT_END       => x"9", -- 0 through 9 bits in a word
            -- outputs
            DONE            => word_en_sig
        );



    -- valid buffer register
    valid_buf_reg: entity work.reg1D
        generic map (
            LENGTH              => 8
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,

            PAR_EN              => VALID,
            PAR_IN              => DATA,
            PAR_OUT             => data_sig
        );


    reg_bits_in <= '1' & data_sig & '0'; -- stop-bit, data, start-bit

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
