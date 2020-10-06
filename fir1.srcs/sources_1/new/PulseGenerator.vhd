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
        PERIOD      : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'1');
        PHASE       : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'0');
        LAGGING     : in STD_LOGIC := '1'; -- represents true or false
        PULSE       : out STD_LOGIC;
        COUNT       : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
    );
end PulseGenerator;

architecture Behavioral of PulseGenerator is

    signal pulse_sig            : std_logic;
    signal timer_rst_sig        : std_logic;
    signal timer_pulse_sig      : std_logic;
    signal prev_phase_sig       : std_logic_vector (WIDTH-1 downto 0) := (others=>'0');
    signal phase_diff_sig       : std_logic_vector (WIDTH-1 downto 0) := (others=>'0');
    signal end_minus_phase_sig  : std_logic_vector (WIDTH-1 downto 0) := (others=>'0');
    signal count_in_sig         : std_logic_vector (WIDTH-1 downto 0) := (others=>'0');
    signal count_out_sig        : std_logic_vector (WIDTH-1 downto 0) := (others=>'0');

begin

    PULSE <= timer_pulse_sig;
    
    timer_rst_sig <= RST or timer_pulse_sig;
    
    end_minus_phase_sig <= std_logic_vector(unsigned(PERIOD) + unsigned(phase_diff_sig))
        when (LAGGING = '1') else std_logic_vector(unsigned(PERIOD) - unsigned(phase_diff_sig));
    
    Timer_module : entity work.Timer
        generic map (
            WIDTH               => WIDTH
        )
        port map (
            CLK                 => CLK,
            EN                  => EN,
            RST                 => timer_rst_sig,
            COUNT_END           => end_minus_phase_sig,
            PULSE               => timer_pulse_sig,
            COUNT               => COUNT
        );


    
    phase_diff_sig <= std_logic_vector(signed(PHASE) - signed(prev_phase_sig));

    Reg1d_module: entity work.Reg1D
        generic map (
            LENGTH              => WIDTH
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,

            PAR_EN              => timer_rst_sig,
            PAR_IN              => PHASE,
            PAR_OUT             => prev_phase_sig
        );


end Behavioral;
