
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity QuadratureDemodulator is
    generic (
        SIG_IN_WIDTH            : positive := 1; -- signal input path width
        SIG_OUT_WIDTH           : positive := 4; -- signal output path width
        IQ_AMP                  : positive := 0 -- 2^n amplification of I and Q raw signals
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN_IN                   : in STD_LOGIC; -- sample rate must be 8x frequency of interest
        EN_OUT                  : in STD_LOGIC; -- output sample rate could be higher (for example, to maintain precision when bit-width is reduced to small value)
        SIG_IN                  : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);

        PHASE                   : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        PHASE_FILTERED          : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        PHASE_DER               : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        PHASE_DER_FILTERED      : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        PHASE_2DER              : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0)
    );
end QuadratureDemodulator;

architecture Behavioral of QuadratureDemodulator is

    signal i_out_sig : std_logic_vector (4+IQ_AMP-1 downto 0); -- adding extra bit to account for 
    signal q_out_sig : std_logic_vector (4+IQ_AMP-1 downto 0); -- adding extra bit to account for 

begin

    I: entity work.LOMixerBaseband
        generic map (
            SIG_IN_WIDTH        => SIG_IN_WIDTH, -- signal input path width
            SIG_OUT_WIDTH       => 4+IQ_AMP,
            PHASE_90_DEG_LAG    => false
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN_IN               => EN_IN, -- sample rate must be 8x frequency of interest
            EN_OUT              => '1',
            SIG_IN              => SIG_IN,

            SIG_OUT             => i_out_sig
        );

    Q: entity work.LOMixerBaseband
        generic map (
            SIG_IN_WIDTH        => SIG_IN_WIDTH, -- signal input path width
            SIG_OUT_WIDTH       => 4+IQ_AMP,
            PHASE_90_DEG_LAG    => true
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN_IN               => EN_IN, -- sample rate must be 8x frequency of interest
            EN_OUT              => '1',
            SIG_IN              => SIG_IN,

            SIG_OUT             => q_out_sig
        );

    PhasorAnalyzer_module: entity work.PhasorAnalyzer
    generic map (
        SIG_IN_WIDTH            => 4,
        SIG_OUT_WIDTH           => SIG_OUT_WIDTH
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN_IN                   => '1',
        EN_OUT                  => EN_OUT,
        X_IN                    => i_out_sig(3 downto 0),
        Y_IN                    => q_out_sig(3 downto 0),

        ANGLE                   => PHASE,
        ANGLE_FILTERED          => PHASE_FILTERED,
        ANGLE_DER               => PHASE_DER,
        ANGLE_DER_FILTERED      => PHASE_DER_FILTERED,
        ANGLE_2DER              => PHASE_2DER
    );
    

end Behavioral;
