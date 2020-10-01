library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UARTSPITap is
    port ( 
        CLK     : in STD_LOGIC;
        RST     : in STD_LOGIC;
        CS      : in STD_LOGIC;
        SCK     : in STD_LOGIC;
        SDA     : in STD_LOGIC;
        
        TX      : out STD_LOGIC
    );
end UARTSPITap;

architecture Behavioral of UARTSPITap is

    signal start_sig : std_logic;
    signal unexpected_end_sig : std_logic;
    signal spitap_valid_sig : std_logic;
    signal spitap_data_sig : std_logic_vector(7 downto 0);
    signal tx_valid_sig : std_logic;
    signal tx_data_sig : std_logic_vector(7 downto 0);

begin

    test_SPITap: entity work.SPITap
    generic map (
        FILTER_LENGTH       => 256
    )
    port map ( 
        CLK                 => CLK,
        RST                 => RST,
        CS                  => CS,
        SCK                 => SCK,
        SDA                 => SDA,
        START               => start_sig,
        UNEXPECTED_END      => unexpected_end_sig,
        VALID               => spitap_valid_sig,
        DATA                => spitap_data_sig
    );

    TX_module: entity work.SerialTx
    generic map (
        BIT_TIMER_WIDTH => 12,
        BIT_TIMER_PERIOD => 1042
    )
    port map ( 
        -- inputs
        CLK => CLK,
        EN => '1',
        RST => RST,
        VALID => tx_valid_sig,
        DATA => tx_data_sig,
        -- outputs
        READY => open,
        TX => TX
    );

    process (start_sig, unexpected_end_sig, spitap_valid_sig, spitap_data_sig)
    begin
    
        if (start_sig = '1') then
            tx_valid_sig <= '1';
            tx_data_sig <= x"7C"; -- '|'
        elsif (unexpected_end_sig = '1') then
            tx_valid_sig <= '1';
            tx_data_sig <= x"3F"; -- '?'
        else
            tx_valid_sig <= spitap_valid_sig;
            tx_data_sig <= spitap_data_sig;
        end if;
    
    end process;

end Behavioral;
