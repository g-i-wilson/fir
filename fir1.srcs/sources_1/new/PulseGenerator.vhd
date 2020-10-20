library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PulseGenerator is
    generic (
        WIDTH       : positive := 8
    );
    port ( 
        CLK         : in STD_LOGIC;
        RST         : in STD_LOGIC;
        EN          : in STD_LOGIC := '1';
        PERIOD      : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'1'); -- unsigned
        PHASE       : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'0'); -- unsigned
        LAGGING     : in STD_LOGIC := '1'; -- represents true or false
        PULSE       : out STD_LOGIC;
        COUNT       : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
    );
end PulseGenerator;

architecture Behavioral of PulseGenerator is

    signal pulse_sig            : std_logic;
    signal timer_rst_sig        : std_logic;
    signal timer_pulse_sig      : std_logic;
    signal curr_phase_sig       : std_logic_vector (WIDTH downto 0) := (others=>'0'); -- signed
    signal prev_phase_sig       : std_logic_vector (WIDTH downto 0) := (others=>'0'); -- signed
    signal phase_diff_sig       : std_logic_vector (WIDTH downto 0) := (others=>'0'); -- signed
    signal end_plus_phase_sig   : std_logic_vector (WIDTH downto 0) := (others=>'0'); -- unsigned
    signal count_in_sig         : std_logic_vector (WIDTH-1 downto 0) := (others=>'0');
    signal count_out_sig        : std_logic_vector (WIDTH-1 downto 0) := (others=>'0');

begin

    PULSE <= timer_pulse_sig;
    
    timer_rst_sig <= RST or timer_pulse_sig;
    
    curr_phase_sig <= '0' & PHASE when LAGGING = '1' else std_logic_vector(unsigned(not('0' & PHASE)) + 1);
    
    phase_diff_sig <= std_logic_vector(signed(curr_phase_sig) - signed(prev_phase_sig));
    
    end_plus_phase_sig <= std_logic_vector(unsigned('0' & PERIOD) + unsigned(phase_diff_sig));
    

    Timer_module : entity work.Timer
        generic map (
            WIDTH               => WIDTH
        )
        port map (
            CLK                 => CLK,
            EN                  => EN,
            RST                 => timer_rst_sig,
            COUNT_END           => end_plus_phase_sig(WIDTH-1 downto 0),
            DONE                => timer_pulse_sig,
            COUNT               => COUNT
        );

    phase_history: entity work.Reg1D
        generic map (
            LENGTH              => WIDTH+1
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,

            PAR_EN              => timer_rst_sig,
            PAR_IN              => curr_phase_sig,
            PAR_OUT             => prev_phase_sig
        );


end Behavioral;
