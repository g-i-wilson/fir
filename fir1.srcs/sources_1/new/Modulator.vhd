
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Modulator is
    generic (
        SIG_WIDTH               : positive := 4; -- signal path width
        LO_HALF_PERIOD_WIDTH    : positive := 16 -- width of timer register for LO
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN                      : in STD_LOGIC;
        LO_HALF_PERIOD          : in STD_LOGIC_VECTOR (LO_HALF_PERIOD_WIDTH-1 downto 0) := (others=>'0');
        PHASE                   : in STD_LOGIC_VECTOR (LO_HALF_PERIOD_WIDTH-1 downto 0) := (others=>'0');
        LAGGING                 : in STD_LOGIC := '1';
        DEFAULT_STATE           : in STD_LOGIC := '0';
        SIG_IN                  : in STD_LOGIC_VECTOR (SIG_WIDTH-1 downto 0) := (others=>'0');
        
        SIG_OUT                 : out STD_LOGIC_VECTOR (SIG_WIDTH-1 downto 0) := (others=>'0')
    );
end Modulator;

architecture Behavioral of Modulator is

    signal lo_sig : STD_LOGIC;
    signal lo_vector_sig : STD_LOGIC_VECTOR(LO_HALF_PERIOD_WIDTH-1 downto 0);

begin

    SqWave_module: entity work.SquareWaveGenerator
    generic map (
        WIDTH           => LO_HALF_PERIOD_WIDTH
    )
    port map (
        CLK             => CLK,
        RST             => RST,
        EN              => EN,
        HALF_PERIOD     => LO_HALF_PERIOD,
        PHASE           => PHASE,
        LAGGING         => LAGGING,
        DEFAULT_STATE   => DEFAULT_STATE,
        SIG_OUT         => lo_sig
    );
    
    lo_vector_sig(SIG_WIDTH-1) <= not lo_sig;
    lo_vector_sig(SIG_WIDTH-2 downto 0) <= (others=>lo_sig); -- +/- maximum
    
    mix_greater_than_2 : if SIG_WIDTH > 2 generate
    
    
    end generate mix_greater_than_2;


    mix_2_or_1 : if SIG_WIDTH <= 2 generate
    
        
    
    end generate mix_2_or_1;

end Behavioral;
