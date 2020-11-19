library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPIConfigure_tb is
--  Port ( );
end SPIConfigure_tb;

architecture Behavioral of SPIConfigure_tb is

	signal test_clk : std_logic;
	signal test_rst : std_logic;
	signal test_pass : std_logic;
	signal test_fail : std_logic;
	signal test_mosi : std_logic;
	signal test_miso : std_logic;
	signal test_sck : std_logic;
	signal test_cs : std_logic;
	signal test_tristate_en : std_logic;
	
	signal test_config : std_logic_vector(95 downto 0);
	signal test_verify : std_logic_vector(47 downto 0);


begin



    SPIConfigure_module: entity work.SPIConfigure
    generic map (
        ADDR_WIDTH                  => 16,
        DATA_WIDTH		            => 8,
        CONFIG_LENGTH               => 4,
        VERIFY_LENGTH               => 2,
        SCK_HALF_PERIOD_WIDTH       => 8,
        VERIFY_RETRY_PERIOD_WIDTH   => 28,
        COUNTER_WIDTH               => 8
    )
    port map (
        CLK                     => test_clk,
        RST                     => test_rst,
        CONFIG                  => test_config,
        VERIFY                  => test_verify,
        SCK_HALF_PERIOD         => x"03",
        MISO                    => test_miso,
        MOSI                    => test_mosi,
        SCK                     => test_sck,
        CS                      => test_cs,
        TRISTATE_EN             => test_tristate_en,
        
        VERIFY_PASS             => test_pass,
        VERIFY_FAIL             => test_fail,
        VERIFY_RETRY_PERIOD     => x"0000040"
    );

    

    process
    begin
    

        
        test_miso <= '1';
        test_config <=  x"AAAA55" &
        				x"BBBB55" &
        				x"CCCC55" &
        				x"DDDD55" ;   
        				   				
        test_verify <=  x"AAAA55" &
        				x"BBBB55" ;      
        								
        test_rst <= '1';
        
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';

        test_rst <= '0';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;

        for a in 0 to 4095 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;
        
        test_miso <= '1';
        test_config <=  x"AAAA55" &
        				x"BBBB55" &
        				x"CCCC55" &
        				x"DDDD55" ;      
        								
        test_verify <=  x"AAAAFF" &
        				x"BBBBFF" ;      				

        test_rst <= '1';
        
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';

        test_rst <= '0';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;

        for a in 0 to 4095 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;
        
        


    end process;


end Behavioral;
