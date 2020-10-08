
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
        SIG_WIDTH               : positive := 1; -- signal path width
        LO_HALF_PERIOD_WIDTH    : positive := 16 -- width of timer register for LO
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN                      : in STD_LOGIC;
        LO_HALF_PERIOD          : in STD_LOGIC_VECTOR (LO_HALF_PERIOD_WIDTH-1 downto 0) := (others=>'0');
        SIG_IN                  : in STD_LOGIC_VECTOR (SIG_WIDTH-1 downto 0) := (others=>'0');

        I_OUT                   : out STD_LOGIC_VECTOR (SIG_WIDTH-1 downto 0) := (others=>'0');
        Q_OUT                   : out STD_LOGIC_VECTOR (SIG_WIDTH-1 downto 0) := (others=>'0')
    );
end QuadratureDemodulator;

architecture Behavioral of QuadratureDemodulator is

    signal q_half_period_sig    : STD_LOGIC_VECTOR (SIG_WIDTH-1 downto 0);

begin

    I: entity work.LOMixer
    generic map (
        SIG_WIDTH               => SIG_WIDTH,
        LO_HALF_PERIOD_WIDTH    => LO_HALF_PERIOD_WIDTH
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN,
        LO_HALF_PERIOD          => LO_HALF_PERIOD,
        SIG_IN                  => SIG_IN,

        SIG_OUT                 => I_OUT
    );

    -- Q lags I by 1/4 period (90 deg or pi/2)
    q_half_period_sig <= std_logic_vector(shift_right(unsigned(LO_HALF_PERIOD),1));

    Q: entity work.LOMixer
    generic map (
        SIG_WIDTH               => SIG_WIDTH,
        LO_HALF_PERIOD_WIDTH    => LO_HALF_PERIOD_WIDTH
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN,
        LO_HALF_PERIOD          => LO_HALF_PERIOD,
        PHASE                   => q_half_period_sig,
        LAGGING                 => '1',
        SIG_IN                  => SIG_IN,

        SIG_OUT                 => Q_OUT
    );

end Behavioral;
