
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
        SIG_IN_WIDTH            : positive := 4; -- signal input path width
        SIG_OUT_WIDTH           : positive := 16 -- signal output path width
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
        ANGLE_DIR               : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        ANGLE_DIR_FILTERED      : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        ANGLE_2DIR              : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0)
    );
end PhasorAnalyzer;

architecture Behavioral of PhasorAnalyzer is

    signal x_sig                    : STD_LOGIC_VECTOR (3 downto 0);
    signal y_sig                    : STD_LOGIC_VECTOR (3 downto 0);

    signal angle_sig                : STD_LOGIC_VECTOR (7 downto 0);
    signal angle_dir_sig            : STD_LOGIC_VECTOR (7 downto 0);
    signal angle_dir_filtered_sig   : STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
    signal angle_dir_filtered_sig_0 : STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
    signal angle_2dir_sig           : STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);

    signal angle_resized_sig        : STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
    signal angle_dir_resized_sig    : STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);

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
            CLK                 => CLK,
            EN                  => EN_IN,
            RST                 => RST,

            X_IN                => x_sig,
            Y_IN                => y_sig,

            A_OUT               => angle_sig,
            DIFF_OUT            => angle_dir_sig
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

    angle_dir_resize: entity work.BitWidthCoupler
    generic map (
        SIG_IN_WIDTH            => 8,
        SIG_OUT_WIDTH           => SIG_OUT_WIDTH
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN_IN,
        SIG_IN                  => angle_dir_sig,

        SIG_OUT                 => angle_dir_resized_sig
    );


    ANGLE <= angle_resized_sig;

    ANGLE_DIR <= angle_dir_resized_sig;

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

    angle_dir_filter: entity work.FIRFilterLP63tap
    generic map (
        SIG_IN_WIDTH        => 8,
        SIG_OUT_WIDTH       => SIG_OUT_WIDTH
    )
    port map (
        CLK                 => CLK,
        RST                 => RST,
        EN_IN               => EN_IN,
        EN_OUT              => EN_OUT,
        SIG_IN              => angle_dir_sig,

        SIG_OUT             => angle_dir_filtered_sig
    );
    
    ANGLE_DIR_FILTERED <= angle_dir_filtered_sig;
    
    angle_2dir_reg : entity work.Reg1D
    generic map (
        LENGTH              => SIG_OUT_WIDTH
    )
    port map (
        CLK                 => CLK,
        RST                 => RST,
        PAR_EN              => EN_OUT,
        PAR_IN              => angle_dir_filtered_sig,
        PAR_OUT             => angle_dir_filtered_sig_0
    );

    angle_2dir_sig <= std_logic_vector(signed(angle_dir_filtered_sig) - signed(angle_dir_filtered_sig_0));
    
    angle_2dir_out_reg : entity work.Reg1D
    generic map (
        LENGTH              => SIG_OUT_WIDTH
    )
    port map (
        CLK                 => CLK,
        RST                 => RST,
        PAR_EN              => EN_OUT,
        PAR_IN              => angle_2dir_sig,
        PAR_OUT             => ANGLE_2DIR
    );

end Behavioral;
