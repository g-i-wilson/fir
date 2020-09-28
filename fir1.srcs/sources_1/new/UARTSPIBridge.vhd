
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UARTSPIBridge is
    generic (
        SPI3WIRE : boolean := FALSE
    );
    port (
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        RX : in STD_LOGIC;
        TX : out STD_LOGIC;
        CS : out STD_LOGIC;
        SCK : out STD_LOGIC;
        MOSI : out STD_LOGIC;
        MISO : in STD_LOGIC;
        RX_ERR : out STD_LOGIC_VECTOR(1 downto 0)
    );
end UARTSPIBridge;

architecture Behavioral of UARTSPIBridge is

    signal ready_out_sig : std_logic;
    signal valid_in_sig : std_logic;
    signal data_in_sig : std_logic_vector(7 downto 0);
    
    signal ready_in_sig : std_logic;
    signal valid_out_sig : std_logic;
    signal data_out_sig : std_logic_vector(7 downto 0);

begin

    RX_module: entity work.SerialRx
    port map (
        -- inputs
        CLK => CLK,
        EN => '1',
        RST => RST,
        RX => RX,
        -- outputs
        VALID => valid_in_sig,
        DATA => data_in_sig,
        ALARM => RX_ERR
    );


    SPI_module: entity work.SPITransaction
    generic map (
        SCK_HALF_PERIOD_WIDTH => 28
    )
    port map (
        CLK                 => CLK,
        RST                 => RST,
        
        -- data path IN
        READY_OUT           => ready_out_sig,
        VALID_IN            => valid_in_sig,
        DATA_IN             => data_in_sig,
        -- data path OUT
        READY_IN            => ready_in_sig,
        VALID_OUT           => valid_out_sig,
        DATA_OUT            => data_out_sig,
        
        -- SPI
        SCK_HALF_PERIOD     => x"5F5E100",
        MOSI                => MOSI,
        MISO                => MISO,
        SCK                 => SCK,
        CS                  => CS,
        TRISTATE_EN         => open
    );


    TX_module: entity work.SerialTx
    port map ( 
        -- inputs
        CLK => CLK,
        EN => '1',
        RST => RST,
        VALID => valid_out_sig,
        DATA => data_out_sig,
        -- outputs
        READY => ready_in_sig,
        TX => TX
    );



end Behavioral;
