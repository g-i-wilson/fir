library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity QuadratureModulator_tb is
--  Port ( );
end QuadratureModulator_tb;

architecture Behavioral of QuadratureModulator_tb is

    signal test_clk, test_rst, test_sample_rate : std_logic;
    signal test_mod_out : std_logic_vector(15 downto 0);
    signal test_PA_angle, test_PA_angle_filtered, test_PA_diff, test_PA_diff_filtered, test_PA_2DER : std_logic_vector(15 downto 0);

begin

    sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => 4
    )
    port map (
        CLK             => test_clk,
        EN              => '1',
        RST             => test_rst,
        PERIOD          => x"3",
        INIT_PERIOD     => x"3",
        PULSE           => test_sample_rate
    );



    test_quad_mod: entity work.QuadratureModulator
        generic map (
            SIG_IN_WIDTH            => 8,
            SIG_OUT_WIDTH           => 16
        )
        port map (
            CLK                     => test_clk,
            RST                     => test_rst,
            EN_IN                   => test_sample_rate, -- sample rate must be 8x frequency of interest
            EN_OUT                  => test_sample_rate, -- output sample rate could be higher (for example, to maintain precision when bit-width is reduced to small value)
            EN_PHASE                => '1', -- enable the PHASE input (overrides PHASE_CHANGE)
            PHASE                   => x"88",
            EN_PHASE_CHANGE         => '0', -- enable the PHASE_CHANGE input
            PHASE_CHANGE            => x"00",

            SIG_OUT                 => test_mod_out
        );

    test_quad_demod: entity work.QuadratureDemodulator
        generic map (
            SIG_IN_WIDTH            => 16,
            SIG_OUT_WIDTH           => 16,
            IQ_AMP                  => 1
        )
        port map (
            CLK                     => test_clk,
            RST                     => test_rst,
            EN_IN                   => test_sample_rate, -- sample rate must be 8x frequency of interest
            EN_OUT                  => '1',
            SIG_IN                  => test_mod_out,

            PHASE                   => test_PA_angle,
            PHASE_FILTERED          => test_PA_angle_filtered,
            PHASE_DER               => test_PA_diff,
            PHASE_DER_FILTERED      => test_PA_diff_filtered,
            PHASE_2DER              => test_PA_2DER
        );






    process
    begin

        -- initial
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
