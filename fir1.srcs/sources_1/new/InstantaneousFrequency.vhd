
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity InstantaneousFrequency is
    generic (
        SIG_IN_WIDTH            : positive := 4; -- signal input path width
        SIG_OUT_WIDTH           : positive := 16 -- signal output path width
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN_IN                   : in STD_LOGIC;
--        EN_ANGLE                : in STD_LOGIC;
        EN_OUT                  : in STD_LOGIC;

        RE_IN                   : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);
        IM_IN                   : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);

        FREQ_RE                 : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        FREQ_IM                 : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0)
    );
end InstantaneousFrequency;

architecture Behavioral of InstantaneousFrequency is

    signal re1_sig                  : STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);
    signal im1_sig                  : STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);
    signal im1_conj_sig             : STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);

    signal freq_re_sig              : STD_LOGIC_VECTOR (SIG_IN_WIDTH*2-1+1 downto 0); -- padded 1 bit to prevent overflow
    signal freq_im_sig              : STD_LOGIC_VECTOR (SIG_IN_WIDTH*2-1+1 downto 0); -- padded 1 bit to prevent overflow

begin


    RE1_reg : entity work.Reg1D
    generic map (
        LENGTH              => SIG_IN_WIDTH
    )
    port map (
        CLK                 => CLK,
        RST                 => RST,
        PAR_EN              => EN_IN,
        PAR_IN              => RE_IN,
        PAR_OUT             => re1_sig
    );

    IM1_reg : entity work.Reg1D
    generic map (
        LENGTH              => SIG_IN_WIDTH
    )
    port map (
        CLK                 => CLK,
        RST                 => RST,
        PAR_EN              => EN_IN,
        PAR_IN              => IM_IN,
        PAR_OUT             => im1_sig
    );

    im1_conj_sig <= std_logic_vector( unsigned(not(im1_sig)) + 1 ); -- *(-1) 2s compliment

    complex_conjugate: entity work.MulComplex
    generic map (
        WIDTH                   => SIG_IN_WIDTH,
        SIGNED_MATH             => TRUE,
        PADDING                 => 1
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN_IN,
        A_REAL                  => RE_IN,
        A_IMAG                  => IM_IN,
        B_REAL                  => re1_sig,
        B_IMAG                  => im1_conj_sig,
        P_REAL                  => freq_re_sig,
        P_IMAG                  => freq_im_sig
    );

    RE_coupler: entity work.BitWidthCoupler
    generic map (
        SIG_IN_WIDTH            => SIG_IN_WIDTH*2+1,
        SIG_OUT_WIDTH           => SIG_OUT_WIDTH
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN_OUT,
        SIG_IN                  => freq_re_sig,

        SIG_OUT                 => FREQ_RE
    );

    IM_coupler: entity work.BitWidthCoupler
    generic map (
        SIG_IN_WIDTH            => SIG_IN_WIDTH*2+1,
        SIG_OUT_WIDTH           => SIG_OUT_WIDTH
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN_OUT,
        SIG_IN                  => freq_im_sig,

        SIG_OUT                 => FREQ_IM
    );

end Behavioral;
