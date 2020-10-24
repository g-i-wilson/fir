
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity PhasorAnalyzer is
    generic (
        SIG_IN_WIDTH            : positive; -- signal input path width
        SIG_OUT_WIDTH           : positive -- signal output path width
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN_IN                   : in STD_LOGIC;
        EN_OUT                  : in STD_LOGIC;
        X_IN                    : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);
        Y_IN                    : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);

        ANGLE                   : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        ANGLE_FILTERED          : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        ANGLE_DIFF              : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        ANGLE_DIFF_FILTERED     : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0)
    );
end PhasorAnalyzer;

architecture Behavioral of PhasorAnalyzer is

    signal x_sig                : STD_LOGIC_VECTOR (3 downto 0);
    signal y_sig                : STD_LOGIC_VECTOR (3 downto 0);

    signal angle_sig            : STD_LOGIC_VECTOR (7 downto 0);
    signal angle_diff_sig       : STD_LOGIC_VECTOR (7 downto 0);

    signal angle_resized_sig        : STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
    signal angle_diff_resized_sig   : STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);

begin

    X_coupler: entity work.BitWidthCoupler
    generic map (
        SIG_IN_WIDTH            => SIG_IN_WIDTH,
        SIG_OUT_WIDTH           => 4
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN_IN,
        SIG_IN                  => X_IN,

        SIG_OUT                 => x_sig
    );

    Y_coupler: entity work.BitWidthCoupler
    generic map (
        SIG_IN_WIDTH            => SIG_IN_WIDTH,
        SIG_OUT_WIDTH           => 4
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN_IN,
        SIG_IN                  => Y_IN,

        SIG_OUT                 => y_sig
    );

    phase_angle: entity work.Angle4Bit
        port map (
            CLK         => CLK,
            EN          => EN_IN,
            RST         => RST,

            X_IN        => x_sig,
            Y_IN        => y_sig,
--            X_IN        => X_IN,
--            Y_IN        => Y_IN,

            A_OUT       => angle_sig,
            DIFF_OUT    => angle_diff_sig
        );

    angle_resize: entity work.BitWidthCoupler
    generic map (
        SIG_IN_WIDTH            => 8,
        SIG_OUT_WIDTH           => SIG_OUT_WIDTH
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN_IN,
        SIG_IN                  => angle_sig,

        SIG_OUT                 => angle_resized_sig
    );

    angle_diff_resize: entity work.BitWidthCoupler
    generic map (
        SIG_IN_WIDTH            => 8,
        SIG_OUT_WIDTH           => SIG_OUT_WIDTH
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN_IN,
        SIG_IN                  => angle_diff_sig,

        SIG_OUT                 => angle_diff_resized_sig
    );


    ANGLE <= angle_resized_sig;

    ANGLE_DIFF <= angle_diff_resized_sig;


    angle_filter: entity work.FIRFilterLP15tap
    generic map (
        SIG_IN_WIDTH        => 8,
        SIG_OUT_WIDTH       => SIG_OUT_WIDTH
    )
    port map (
        CLK                 => CLK,
        RST                 => RST,
        EN_IN               => EN_IN,
        EN_OUT              => EN_OUT,
        SIG_IN              => angle_sig,

        SIG_OUT             => ANGLE_FILTERED
    );

    angle_diff_filter: entity work.FIRFilterLP63tap
    generic map (
        SIG_IN_WIDTH        => 8,
        SIG_OUT_WIDTH       => SIG_OUT_WIDTH
    )
    port map (
        CLK                 => CLK,
        RST                 => RST,
        EN_IN               => EN_IN,
        EN_OUT              => EN_OUT,
        SIG_IN              => angle_diff_sig,

        SIG_OUT             => ANGLE_DIFF_FILTERED
    );

end Behavioral;
