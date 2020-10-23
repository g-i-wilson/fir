
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Angle is
    generic (
        SIG_IN_WIDTH            : positive := 4; -- input signal path width
        SIG_OUT_WIDTH           : positive := 16 -- output signal path width
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN                      : in STD_LOGIC; -- sample rate of I/Q input (some of the filter stages run at divided sample rate)
        X_IN                    : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);
        Y_IN                    : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);

        A_OUT                   : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        A_OUT_MA                : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        A_OUT_FIR1              : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        A_OUT_FIR2              : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        DIFF_OUT                : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        DIFF_OUT_MA             : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        DIFF_OUT_FIR1           : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        DIFF_OUT_FIR2           : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0)
    );
end Angle;

architecture Behavioral of Angle is

    signal x_sig            : std_logic_vector(SIG_IN_WIDTH-1 downto 0);
    signal y_sig            : std_logic_vector(SIG_IN_WIDTH-1 downto 0);

    signal angle_sig        : std_logic_vector(7 downto 0);
    signal diff_sig         : std_logic_vector(7 downto 0);

    signal angle_ma_sig     : std_logic_vector(15 downto 0);
    signal angle_fir1_sig   : std_logic_vector(15 downto 0);
    signal diff_ma_sig      : std_logic_vector(15 downto 0);
    signal diff_fir1_sig    : std_logic_vector(15 downto 0);


begin




end Behavioral;
