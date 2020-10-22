
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity FIRFilterLP4f63tap is
    generic (
        SIG_IN_WIDTH            : positive := 8; -- signal input path width
        SIG_OUT_WIDTH           : positive := 8 -- signal output path width
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN_IN                   : in STD_LOGIC; -- sample rate of the FIR filter
        EN_OUT                  : in STD_LOGIC; -- should be same or faster rate than EN_IN, otherwise will undersample the filter output
        SIG_IN                  : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0) := (others=>'0');

        SIG_OUT                 : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0) := (others=>'0')
    );
end FIRFilterLP4f63tap;

architecture Behavioral of FIRFilterLP4f63tap is

    signal filter_in_sig        : std_logic_vector(11 downto 0);
    signal filter_out_sig       : std_logic_vector(26 downto 0);

begin


    gen_less_than_12 : if SIG_IN_WIDTH < 12 generate
--        filter_in_sig <= std_logic_vector( shift_left(signed(mixer_out_sig), 12-SIG_IN_WIDTH ) );
        filter_in_sig <= SIG_IN & std_logic_vector(to_unsigned(0, 12-SIG_IN_WIDTH)); -- simple shift left (having bugs simulating with shift_left function)
    end generate gen_less_than_12;

    gen_equal_to_12 : if SIG_IN_WIDTH = 12 generate
        filter_in_sig <= SIG_IN;
    end generate gen_equal_to_12;

    gen_greater_than_12 : if SIG_IN_WIDTH > 12 generate
        IDM_input: entity work.IntegerDensityModulator
        -- When the output width is 1, the output becomes Pulse Density Modulation (PDM)
        generic map (
            INPUT_WIDTH         => SIG_IN_WIDTH,
            OUTPUT_WIDTH        => 12,
            PULSE_COUNT_WIDTH   => 1
        )
        port map (
            CLK                 => CLK,
            EN                  => EN_IN,
            RST                 => RST,
            PULSE_LENGTH(0)     => '1',
            INPUT               => SIG_IN,

            OUTPUT              => filter_in_sig
        );
    end generate gen_greater_than_12;

    ----------------------------------------
    -- FIRFilter
    ----------------------------------------
    FIR: entity work.FIRFilter
    generic map (
        LENGTH      => 63, -- number of taps
        WIDTH       => 12, -- width of coef and signal path (x2 after multiplication)
        PADDING     => 3,  -- extra bits needed to pad overflow in situation of continuous DC at max level: 2^11-1 0x7FF (pos max) or 2^11 0x800 (neg max)
        SIGNED_MATH => TRUE
    )
    port map (
        CLK         => CLK,
        EN          => EN_IN,
        RST         => RST,
        COEF_IN     =>
		x"FFF" &
		x"FFE" &
		x"FFB" &
		x"FF5" &
		x"FED" &
		x"FE0" &
		x"FD1" &
		x"FC0" &
		x"FAE" &
		x"F9E" &
		x"F92" &
		x"F8E" &
		x"F93" &
		x"FA6" &
		x"FCA" &
		x"000" &
		x"04A" &
		x"0AA" &
		x"11F" &
		x"1A8" &
		x"244" &
		x"2ED" &
		x"3A0" &
		x"458" &
		x"50F" &
		x"5BE" &
		x"660" &
		x"6ED" &
		x"761" &
		x"7B8" &
		x"7ED" &
		x"7FF" &
		x"7ED" &
		x"7B8" &
		x"761" &
		x"6ED" &
		x"660" &
		x"5BE" &
		x"50F" &
		x"458" &
		x"3A0" &
		x"2ED" &
		x"244" &
		x"1A8" &
		x"11F" &
		x"0AA" &
		x"04A" &
		x"000" &
		x"FCA" &
		x"FA6" &
		x"F93" &
		x"F8E" &
		x"F92" &
		x"F9E" &
		x"FAE" &
		x"FC0" &
		x"FD1" &
		x"FE0" &
		x"FED" &
		x"FF5" &
		x"FFB" &
		x"FFE" &
		x"FFF" ,
        SHIFT_IN    => filter_in_sig,

        SUM_OUT     => filter_out_sig
    );

    ----------------------------------------
    -- IDM signal width reduction
    ----------------------------------------
    gen_out_less_than_28 : if SIG_OUT_WIDTH < 28 generate
        IDM_output: entity work.IntegerDensityModulator
        -- When the output width is 1, the output becomes Pulse Density Modulation (PDM)
        generic map (
            INPUT_WIDTH         => 28,
            OUTPUT_WIDTH        => SIG_OUT_WIDTH,
            PULSE_COUNT_WIDTH   => 1
        )
        port map (
            CLK                 => CLK,
            EN                  => EN_OUT,
            RST                 => RST,
            PULSE_LENGTH(0)     => '1',
            INPUT               => filter_out_sig,

            OUTPUT              => SIG_OUT
        );
    end generate gen_out_less_than_28;

    gen_out_equals_28 : if SIG_OUT_WIDTH = 28 generate
        SIG_OUT <= filter_out_sig;
    end generate gen_out_equals_28;

    gen_out_greater_than_28 : if SIG_OUT_WIDTH > 28 generate
        -- SIG_OUT <= std_logic_vector( shift_left(signed(filter_out_sig), SIG_OUT_WIDTH-27) );
        SIG_OUT <= filter_out_sig & std_logic_vector(to_unsigned(0, SIG_OUT_WIDTH-28)); -- simple shift left (having bugs simulating with shift_left function)
    end generate gen_out_greater_than_28;

end Behavioral;
