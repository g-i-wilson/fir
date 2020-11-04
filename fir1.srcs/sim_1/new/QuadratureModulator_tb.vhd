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

    signal test_clk, test_rst, test_sample_rate, test_phase_change_rate : std_logic;
    signal test_mod_out             : std_logic_vector(15 downto 0);
    signal test_mod_filtered_out    : std_logic_vector(15 downto 0);
    signal test_PA_angle            : std_logic_vector(15 downto 0);
    signal test_PA_diff             : std_logic_vector(15 downto 0);
    signal sin_sig                  : std_logic_vector(15 downto 0);
    signal cos_sig                  : std_logic_vector(15 downto 0);
    signal test_PA_2DER             : std_logic_vector(15 downto 0);
    signal test_freq_re             : std_logic_vector(15 downto 0);
    signal test_freq_im             : std_logic_vector(15 downto 0);

begin

    sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => 8
    )
    port map (
        CLK             => test_clk,
        EN              => '1',
        RST             => test_rst,
        PERIOD          => x"07",
        INIT_PERIOD     => x"07",
        PULSE           => test_sample_rate
    );

    phase_change_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => 8
    )
    port map (
        CLK             => test_clk,
        EN              => '1',
        RST             => test_rst,
        PERIOD          => x"40",
        INIT_PERIOD     => x"40",
        PULSE           => test_phase_change_rate
    );

    sin_gen: entity work.SinusoidGenerator64
        generic map (
            WIDTH           => 16
        )
        port map (
            CLK             => test_clk,
            EN              => test_phase_change_rate,
            RST             => test_rst,
    
            COS_OUT         => cos_sig,
            SIN_OUT         => sin_sig
        );


    test_quad_mod: entity work.QuadratureModulator
        generic map (
            SIG_IN_WIDTH            => 16,
            SIG_OUT_WIDTH           => 16
        )
        port map (
            CLK                     => test_clk,
            RST                     => test_rst,
            EN_IN                   => test_sample_rate, -- sample rate must be 8x frequency of interest
            EN_OUT                  => '1', -- output sample rate could be higher (for example, to maintain precision when bit-width is reduced to small value)
            EN_PHASE                => '1', -- enable the PHASE input (overrides PHASE_CHANGE)
            PHASE                   => cos_sig,
            EN_PHASE_CHANGE         => '0', -- enable the PHASE_CHANGE input
            PHASE_CHANGE            => x"0000",

            SIG_OUT                 => test_mod_out
        );
        
        
    filter_mod_signal: entity work.FIRFilterLP4f63tap
        generic map (
            SIG_IN_WIDTH        => 16, -- signal input path width
            SIG_OUT_WIDTH       => 16 -- signal output path width
        )
        port map (
            CLK                 => test_clk,
            RST                 => test_rst,
            EN_IN               => '1',
            EN_OUT              => '1',
            SIG_IN              => test_mod_out,

            SIG_OUT             => test_mod_filtered_out
        );        

    test_quad_demod: entity work.QuadratureDemodulator
        generic map (
            SIG_IN_WIDTH            => 16,
            SIG_OUT_WIDTH           => 16,
            IQ_AMP                  => 2
        )
        port map (
            CLK                     => test_clk,
            RST                     => test_rst,
            EN_IN                   => test_sample_rate, -- sample rate must be 8x frequency of interest
            EN_OUT                  => '1',
            SIG_IN                  => test_mod_filtered_out,

            PHASE                   => test_PA_angle,
            PHASE_DER               => test_PA_diff,
            PHASE_2DER              => test_PA_2DER,
            
            FREQ_RE                 => test_freq_re,
            FREQ_IM                 => test_freq_im
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

        for a in 1 to 20000 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;

    end process;


end Behavioral;
