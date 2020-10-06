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
        CLK             : in STD_LOGIC;
        RST             : in STD_LOGIC;
        CS              : in STD_LOGIC;
        SCK             : in STD_LOGIC;
        SDA             : in STD_LOGIC;
        UART_PERIOD     : in STD_LOGIC_VECTOR(15 downto 0);
        TEST_BYTE       : in STD_LOGIC_VECTOR(7 downto 0);
        TEST_EN         : in STD_LOGIC;
        
        TX              : out STD_LOGIC;
        TX_NOT_READY    : out STD_LOGIC
    );
end UARTSPITap;

architecture Behavioral of UARTSPITap is

    signal start_sig : std_logic;
    signal unexpected_end_sig : std_logic;
    signal spitap_valid_sig : std_logic;
    signal spitap_data_sig : std_logic_vector(7 downto 0);
    signal tx_valid_sig : std_logic;
    signal tx_ready_sig : std_logic;
    signal tx_not_ready_in_sig : std_logic;
    signal tx_not_ready_out_sig : std_logic;
    signal tx_data_sig : std_logic_vector(7 downto 0);

begin

    SPITap_module: entity work.SPITap
    generic map (
        FILTER_LENGTH       => 16,
        FILTER_SUM_WIDTH    => 4
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
    port map ( 
        -- inputs
        CLK => CLK,
        EN => '1',
        RST => RST,
        BIT_TIMER_PERIOD => UART_PERIOD,
        VALID => tx_valid_sig,
        DATA => tx_data_sig,
--        DATA => x"AB",
        -- outputs
        READY => tx_ready_sig,
        TX => TX
    );

    process (start_sig, unexpected_end_sig, spitap_valid_sig, spitap_data_sig, TEST_BYTE, TEST_EN)
    begin
    
        if (start_sig = '1') then
            tx_valid_sig <= '1';
            tx_data_sig <= x"0A"; -- '\n'
        elsif (unexpected_end_sig = '1') then
            tx_valid_sig <= '1';
            tx_data_sig <= x"3F"; -- '?'
        elsif (TEST_EN = '1') then
            tx_valid_sig <= '1';
            tx_data_sig <= TEST_BYTE;
        else
            tx_valid_sig <= spitap_valid_sig;
            tx_data_sig <= spitap_data_sig;
        end if;
    
    end process;
    
    
    process (CLK)
    begin
        if rising_edge(CLK) then
            if (RST = '1') then
                tx_not_ready_out_sig <= '0';
            else
                tx_not_ready_out_sig <= tx_not_ready_in_sig;
            end if;
        end if;
    end process;
    
    tx_not_ready_in_sig <= (tx_valid_sig and not tx_ready_sig) or tx_not_ready_out_sig;
    
    TX_NOT_READY <= tx_not_ready_out_sig;
    
    ila0: entity work.ila_uartspitap
    port map (
        CLK => CLK,
        probe0 => tx_ready_sig & tx_valid_sig & "000000",
        probe1 => tx_data_sig
    );

end Behavioral;
