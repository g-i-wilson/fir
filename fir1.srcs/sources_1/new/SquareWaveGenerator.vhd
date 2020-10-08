library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SquareWaveGenerator is
    generic (
        WIDTH       : positive := 8
    );
    port (
        CLK             : in STD_LOGIC;
        RST             : in STD_LOGIC;
        EN              : in STD_LOGIC := '1';
        HALF_PERIOD     : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'1');
        PHASE           : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'0');
        LAGGING         : in STD_LOGIC := '1'; -- represents true or false
        DEFAULT_STATE   : in STD_LOGIC := '0';
        SIG_OUT         : out STD_LOGIC;
        COUNT           : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
    );
end SquareWaveGenerator;

architecture Behavioral of SquareWaveGenerator is

    signal state        : std_logic;
    signal pulse        : std_logic;

begin

    PulseGen_module : entity work.PulseGenerator
        generic map (
            WIDTH               => WIDTH 
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN                  => EN,
            PERIOD              => HALF_PERIOD,
            PHASE               => PHASE,
            LAGGING             => LAGGING,
            PULSE               => pulse
        );

    process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                state <= DEFAULT_STATE;
            elsif (pulse = '1') then
                state <= not state;
            else
                state <= state;
            end if;
        end if;
    end process;
    
    SIG_OUT <= state;

end Behavioral;
