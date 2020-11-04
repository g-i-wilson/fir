
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
        IQ_AMP                  : integer := 0 -- 2^n amplification of I and Q raw signals
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN_IN                   : in STD_LOGIC; -- sample rate must be 8x frequency of interest
        EN_OUT                  : in STD_LOGIC; -- output sample rate could be higher (for example, to maintain precision when bit-width is reduced to small value)
        SIG_IN                  : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);

        PHASE                   : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        PHASE_DER               : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        PHASE_2DER              : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);

        FREQ_RE                 : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        FREQ_IM                 : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0)
    );
end QuadratureDemodulator;

architecture Behavioral of QuadratureDemodulator is

    signal i_out_sig        : std_logic_vector (28+IQ_AMP-1 downto 0);
    signal q_out_sig        : std_logic_vector (28+IQ_AMP-1 downto 0);

    signal phase_der_sig    : std_logic_vector (SIG_OUT_WIDTH-1 downto 0);

begin

    I: entity work.LOMixerBaseband
        generic map (
            SIG_IN_WIDTH        => SIG_IN_WIDTH, -- signal input path width
            SIG_OUT_WIDTH       => 28+IQ_AMP,
            PHASE_90_DEG_LAG    => false
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN_IN               => EN_IN, -- sample rate must be 8x frequency of interest
--            EN_OUT              => '1',
            EN_OUT              => EN_IN,
            SIG_IN              => SIG_IN,

            SIG_OUT             => i_out_sig
        );

    Q: entity work.LOMixerBaseband
        generic map (
            SIG_IN_WIDTH        => SIG_IN_WIDTH, -- signal input path width
            SIG_OUT_WIDTH       => 28+IQ_AMP,
            PHASE_90_DEG_LAG    => true
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN_IN               => EN_IN, -- sample rate must be 8x frequency of interest
--            EN_OUT              => '1',
            EN_OUT              => EN_IN,
            SIG_IN              => SIG_IN,

            SIG_OUT             => q_out_sig
        );

    inst_phase: entity work.InstantaneousPhase
    generic map (
        SIG_IN_WIDTH            => 28,
        SIG_OUT_WIDTH           => SIG_OUT_WIDTH
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN_ANGLE                => '1',
        EN_OUT                  => EN_OUT,
        RE_IN                   => i_out_sig(27 downto 0),
        IM_IN                   => q_out_sig(27 downto 0),

        PHASE                   => PHASE,
        PHASE_DER               => phase_der_sig
    );
    
    PHASE_DER <= phase_der_sig;
    
    inst_phase_2der : entity work.Derivative
    generic map (
        WIDTH       => SIG_OUT_WIDTH
    )
    port map (
        CLK         => CLK,
        RST         => RST,
        EN          => EN_OUT,
        SIG_IN      => phase_der_sig,
        DIFF_OUT    => PHASE_2DER
    );

    
    inst_frequency: entity work.InstantaneousFrequency
    generic map (
        SIG_IN_WIDTH            => 28,
        SIG_OUT_WIDTH           => SIG_OUT_WIDTH
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN_IN                   => EN_IN,
        EN_OUT                  => EN_OUT,
        RE_IN                   => i_out_sig(27 downto 0),
        IM_IN                   => q_out_sig(27 downto 0),

        FREQ_RE                 => FREQ_RE,
        FREQ_IM                 => FREQ_IM
    );
    

end Behavioral;
