library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPIConfigure is
    generic (
        ADDR_WIDTH              : positive := 16;
        DATA_WIDTH		        : positive := 8;
        CONFIG_LENGTH           : positive;
        SCK_HALF_PERIOD_WIDTH   : positive := 8;
        COUNTER_WIDTH           : positive := 8
		);
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        CONFIG                  : in STD_LOGIC_VECTOR ((ADDR_WIDTH+DATA_WIDTH)*CONFIG_LENGTH-1 downto 0);
        SCK_HALF_PERIOD	        : in STD_LOGIC_VECTOR (SCK_HALF_PERIOD_WIDTH-1 downto 0);
        CS                      : out STD_LOGIC;
        SCK                     : out STD_LOGIC;
        MISO                    : in STD_LOGIC;
        MOSI                    : out STD_LOGIC;
        TRISTATE_EN             : out STD_LOGIC
    );
end SPIConfigure;

architecture Behavioral of SPIConfigure is

    signal spi_ready_sig : std_logic;
    signal reg_valid_sig : std_logic;
    signal spi_valid_sig : std_logic;
    signal config_done_sig : std_logic;
    signal en_config_sig : std_logic;
    signal reg_out_sig : std_logic_vector(ADDR_WIDTH+DATA_WIDTH-1 downto 0);

begin

    Config_counter : entity work.Timer
        generic map (
            WIDTH               => COUNTER_WIDTH
        )
        port map (
            CLK                 => CLK,
            EN                  => spi_ready_sig,
            RST                 => RST,
            DONE                => config_done_sig
        );
        
    en_config_sig <= spi_ready_sig and (not config_done_sig);
    
    Config_reg: entity work.Reg1DSymbols
        generic map (
            LENGTH              => CONFIG_LENGTH,
            SYMBOL_WIDTH        => ADDR_WIDTH + DATA_WIDTH
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            SHIFT_EN            => en_config_sig,
            SHIFT_OUT           => reg_out_sig,
            
            DEFAULT_STATE       => CONFIG
        );

    SPIMaster_module: entity work.SPIMaster
        generic map (
            SCK_HALF_PERIOD_WIDTH   =>  SCK_HALF_PERIOD_WIDTH,
            ADDR_WIDTH              =>  ADDR_WIDTH,
            DATA_WIDTH              =>  DATA_WIDTH,
            COUNTER_WIDTH           =>  COUNTER_WIDTH
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            
            -- R/W
            WRITE                   => '1',
            
            -- upstream
            READY_OUT               => spi_ready_sig,
            VALID_IN                => '1',
            
            -- downstream
            READY_IN                => open,
            VALID_OUT               => spi_valid_sig,
    
            -- ADDR & DATA
            ADDR                    => reg_out_sig(ADDR_WIDTH+DATA_WIDTH-1 downto DATA_WIDTH),
            DATA_IN                 => reg_out_sig(DATA_WIDTH-1 downto 0),
            DATA_OUT                => open,
            
            -- SPI
            SCK_HALF_PERIOD         => SCK_HALF_PERIOD,
            MISO                    => MISO,
            MOSI                    => MOSI,
            SCK                     => SCK,
            CS                      => CS,
            TRISTATE_EN             => TRISTATE_EN
        );

end Behavioral;
