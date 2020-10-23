
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity FIRFilterLP63tap is
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
end FIRFilterLP63tap;

architecture Behavioral of FIRFilterLP63tap is

    signal filter_in_sig        : std_logic_vector(11 downto 0);
    signal filter_out_sig       : std_logic_vector(27 downto 0);

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
        PADDING     => 4,  -- extra bits needed to pad overflow in situation of continuous DC at max level: 2^11-1 0x7FF (pos max) or 2^11 0x800 (neg max)
        SIGNED_MATH => TRUE
    )
    port map (
        CLK         => CLK,
        EN          => EN_IN,
        RST         => RST,
        COEF_IN     =>
		x"004" &
		x"013" &
		x"02C" &
		x"04D" &
		x"078" &
		x"0AC" &
		x"0E8" &
		x"12B" &
		x"176" &
		x"1C6" &
		x"21D" &
		x"277" &
		x"2D6" &
		x"337" &
		x"39B" &
		x"3FF" &
		x"463" &
		x"4C7" &
		x"528" &
		x"587" &
		x"5E1" &
		x"638" &
		x"688" &
		x"6D3" &
		x"716" &
		x"752" &
		x"786" &
		x"7B1" &
		x"7D2" &
		x"7EB" &
		x"7FA" &
		x"7FF" &
		x"7FA" &
		x"7EB" &
		x"7D2" &
		x"7B1" &
		x"786" &
		x"752" &
		x"716" &
		x"6D3" &
		x"688" &
		x"638" &
		x"5E1" &
		x"587" &
		x"528" &
		x"4C7" &
		x"463" &
		x"3FF" &
		x"39B" &
		x"337" &
		x"2D6" &
		x"277" &
		x"21D" &
		x"1C6" &
		x"176" &
		x"12B" &
		x"0E8" &
		x"0AC" &
		x"078" &
		x"04D" &
		x"02C" &
		x"013" &
		x"004" ,
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
