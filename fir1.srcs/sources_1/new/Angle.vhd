
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
        SIG_IN_WIDTH            : positive := 1; -- input signal path width
        SIG_OUT_WIDTH           : positive := 8 -- output signal path width
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN                      : in STD_LOGIC;
        X_IN                    : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0) := (others=>'0');
        Y_IN                    : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0) := (others=>'0');

        SIG_OUT                 : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0) := (others=>'0')
    );
end Angle;

architecture Behavioral of Angle is

begin

    width_greater_than_1 : if SIG_IN_WIDTH > 1 generate
        process (CLK)
        begin
            

        end process;
    end generate width_greater_than_1;

    width_1 : if SIG_IN_WIDTH = 1 generate

    end generate width_1;

end Behavioral;
