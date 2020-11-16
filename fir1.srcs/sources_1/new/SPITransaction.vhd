library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPITransaction is
    generic (
        SCK_HALF_PERIOD_WIDTH   : positive := 8;
        MISO_DETECTOR_SAMPLES   : positive := 16;
        ADDR_WIDTH              : positive := 8;
        DATA_WIDTH              : positive := 8
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        
        -- upstream
        READY_OUT               : out STD_LOGIC;
        VALID_IN                : in STD_LOGIC;
        
        -- downstream
        READY_IN                : in STD_LOGIC;
        VALID_OUT               : out STD_LOGIC;

        -- ADDR & DATA
        ADDR                    : in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
        DATA_IN                 : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        DATA_OUT                : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        
        -- SPI
        SCK_HALF_PERIOD         : in STD_LOGIC_VECTOR (SCK_HALF_PERIOD_WIDTH-1 downto 0);
        MISO                    : in STD_LOGIC;
        MOSI                    : out STD_LOGIC;
        SCK                     : out STD_LOGIC;
        CS                      : out STD_LOGIC;
        TRISTATE_EN             : out STD_LOGIC
    );
end SPITransaction;

architecture Behavioral of SPITransaction is

    -- data busses
    signal valid_buffer_sig     : std_logic_vector(7 downto 0);
    signal mosi_sig             : std_logic;
    signal miso_sync_sig        : std_logic;
    signal bit_count_sig        : std_logic_vector(3 downto 0);

    -- FSM inputs
    signal addr_done_sig        : std_logic;
    signal data_done_sig        : std_logic;
    signal sck_edge_sig         : std_logic;
    
    -- FSM outputs
    signal sck_rst_sig          : std_logic;
    signal counter_en_sig       : std_logic;
    signal counter_rst_sig      : std_logic;
    signal counter_rst_fsm_sig  : std_logic;
    signal shift_in_reg_sig     : std_logic;
    signal shift_out_reg_sig    : std_logic;

    signal state_debug          : std_logic_vector(7 downto 0);


begin

    ----------------------------------------------------
    -- FSM
    ----------------------------------------------------
    
    FSM: entity work.SPITransactionFSM
        port map ( 
            -- inputs
            CLK                 => CLK,
            RST                 => RST,
            VALID_IN            => VALID_IN,
            READY_IN            => READY_IN,
            ADDR_DONE           => addr_done_sig,
            DATA_DONE           => data_done_sig,
            SCK_EDGE            => sck_edge_sig,
            -- outputs
            READY_OUT           => READY_OUT,
            VALID_OUT           => VALID_OUT,
            SCK_RST             => sck_rst_sig,
            TRISTATE_EN         => TRISTATE_EN,
            COUNTER_EN          => counter_en_sig,
            COUNTER_RST         => counter_rst_sig,
            SHIFT_IN_REG        => shift_in_reg_sig,
            SHIFT_OUT_REG       => shift_out_reg_sig,
            CS                  => CS,
            SCK                 => SCK,
            -- debug outputs
            STATE               => state_debug
        );

    ----------------------------------------------------
    -- LOGIC
    ----------------------------------------------------

    MISO_detector: entity work.EdgeDetector
    generic map (
        SAMPLE_LENGTH             => MISO_DETECTOR_SAMPLES,
        SUM_WIDTH                 => SCK_HALF_PERIOD_WIDTH,
        LOGIC_HIGH                => MISO_DETECTOR_SAMPLES*3/4-1,
        LOGIC_LOW                 => MISO_DETECTOR_SAMPLES/4,
        SUM_START                 => MISO_DETECTOR_SAMPLES/2
    )
    port map (
        RST                       => RST,
        CLK                       => CLK,
        
        SAMPLE                    => '1',
        SIG_IN                    => MISO,
        
        DATA                      => miso_sync_sig
    );
    
    counter_rst_sig <= RST or counter_rst_fsm_sig;
    
    MOSI <= mosi_sig;
    

    ----------------------------------------------------
    -- REGISTERS
    ----------------------------------------------------
    
    valid_buffer: entity work.reg1D
        generic map (
            LENGTH              => 8
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            PAR_EN              => VALID_IN,
            PAR_IN              => DATA_IN,
            PAR_OUT             => valid_buffer_sig
        );

    DATA_IN_reg: entity work.reg1D
        generic map (
            LENGTH              => ADDR_WIDTH + DATA_WIDTH
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            PAR_EN              => load_data_in_sig,
            PAR_IN              => valid_buffer_sig,
            
            SHIFT_EN            => shift_data_in_sig,
            SHIFT_OUT           => mosi_sig
        );

    DATA_OUT_reg: entity work.reg1D
        generic map (
            LENGTH              => DATA_WIDTH
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            PAR_EN              => load_data_out_sig,
            PAR_IN              => valid_buffer_sig,
            PAR_OUT             => DATA_OUT,
            
            SHIFT_EN            => shift_data_out_sig,
            SHIFT_IN            => miso_sync_sig
        );

    ----------------------------------------------------
    -- COUNTERS
    ----------------------------------------------------
    
    SCK_EDGE_pules : entity work.PulseGenerator
    generic map (
        WIDTH       => SCK_HALF_PERIOD_WIDTH
    )
    port map ( 
        CLK         => CLK,
        RST         => RST,
        EN          => '1',
        PERIOD      => SCK_HALF_PERIOD,
        INIT_PERIOD => SCK_HALF_PERIOD,
        PULSE       => sck_edge_sig,
        COUNT       => count_sig
    );
        
    counter : entity work.Timer
        generic map (
            WIDTH               => 3 -- defaults to "000" through "111", which is 8 combinations
        )
        port map (
            CLK                 => CLK,
            EN                  => bit_count_en_sig,
            RST                 => bit_count_rst_sig,
            DONE                => byte_done_sig
        );
                
        
    ila0: entity work.ila_SPITransaction
    port map (
        CLK => CLK,
        probe0 => byte_done_sig & write_done_sig & read_done_sig & shift_data_in_sig & shift_data_out_sig & "000",
        probe1 => write_len_sig,
        probe2 => read_len_sig,
        probe3 => state_debug
    );


end Behavioral;
