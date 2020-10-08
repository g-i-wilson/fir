library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PulseDensityModulator is
    generic (
        INPUT_WIDTH         : integer;
        OUTPUT_WIDTH        : integer;
        PULSE_COUNT_WIDTH   : integer
    );
    port (
        CLK                 : in STD_LOGIC;
        EN                  : in STD_LOGIC;
        RST                 : in STD_LOGIC;
        PULSE_LenGTH        : in STD_LOGIC_VECTOR (PULSE_COUNT_WIDTH-1 downto 0);
        INPUT               : in STD_LOGIC_VECTOR (INPUT_WIDTH-1 downto 0);

        ERROR               : out STD_LOGIC_VECTOR (1+PULSE_COUNT_WIDTH+(INPUT_WIDTH-OUTPUT_WIDTH)-1 downto 0);
        ERROR_SIGN          : out std_logic;
        PULSE_COUNT         : out STD_LOGIC_VECTOR (PULSE_COUNT_WIDTH-1 downto 0);
        PULSE_en            : out std_logic;
        OUTPUT              : out STD_LOGIC_VECTOR (OUTPUT_WIDTH-1 downto 0)
    );
end PulseDensityModulator;


architecture Behavioral of PulseDensityModulator is

    signal
        en_pulse_sig,
        pos_err
        : std_logic;
    signal
        out_sig,
        out_sig_left_shifted
        : std_logic_vector (INPUT_WIDTH-1 downto 0);


begin

    pulse_width: entity work.PulseGenerator
        generic map (
            period_width => PULSE_COUNT_WIDTH
        )
        port map (
            period => PULSE_LenGTH,
            CLK => CLK,
            en => en,
            RST => RST,
            en_out => en_pulse_sig,
            count_out => PULSE_COUNT
        );

    ERROR_function: diff_accum
        generic map (
            in_width => INPUT_WIDTH,
            sum_width => 1+PULSE_COUNT_WIDTH+(INPUT_WIDTH-OUTPUT_WIDTH)
        )
        port map (
            in_a => INPUT,
            in_b => out_sig_left_shifted,
            diff_sum => ERROR,
            pos_sign => pos_err,
            CLK => CLK,
            en => en,
            RST => RST
        );

    virtual_DAC: shorten
        generic map (
            width => INPUT_WIDTH,
            places => (INPUT_WIDTH-OUTPUT_WIDTH)
        )
        port map (
            INPUT => INPUT,
            OUTPUT => out_sig,
            round_up => pos_err,
            CLK => CLK,
            en => en_pulse_sig,
            RST => RST
        );

    out_sig_left_shifted <= std_logic_vector(
        shift_left(
            signed(out_sig),
            (INPUT_WIDTH-OUTPUT_WIDTH)
        )
    );

    OUTPUT <= out_sig(OUTPUT_WIDTH-1 downto 0);

    ERROR_SIGN <= pos_err;

    PULSE_en <= en_pulse_sig;

end Behavioral;
