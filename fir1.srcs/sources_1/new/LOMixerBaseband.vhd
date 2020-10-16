
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity LOMixerBaseband is
    generic (
        SIG_IN_WIDTH            : positive := 1; -- signal input path width
        SIG_OUT_WIDTH           : positive := 4; -- signal output path width
        PHASE_90_DEG_LAG        : boolean := false
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN                      : in STD_LOGIC;
        SIG_IN                  : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0) := (others=>'0');

        SIG_OUT                 : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0) := (others=>'0')
    );
end LOMixerBaseband;

architecture Behavioral of LOMixerBaseband is

    signal mixer_out_sig            : STD_LOGIC_VECTOR(SIG_IN_WIDTH-1 downto 0);
    signal mixer_out_upshifted_sig  : STD_LOGIC_VECTOR(11 downto 0);
    signal filter_out_sig           : STD_LOGIC_VECTOR(26 downto 0);
    signal idm_out_sig              : STD_LOGIC_VECTOR(SIG_OUT_WIDTH-1 downto 0);

begin

    ----------------------------------------
    -- LOMixer
    ----------------------------------------
    gen_I: if not PHASE_90_DEG_LAG generate
        LO: entity work.LOMixer
        generic map (
            SIG_WIDTH               => SIG_IN_WIDTH,
            LO_HALF_PERIOD_WIDTH    => 4
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN                      => EN,
            LO_HALF_PERIOD          => x"4",
            SIG_IN                  => SIG_IN,
    
            SIG_OUT                 => mixer_out_sig
        );
    end generate gen_I;
    
    gen_Q: if PHASE_90_DEG_LAG generate
        LO: entity work.LOMixer
        generic map (
            SIG_WIDTH               => SIG_IN_WIDTH,
            LO_HALF_PERIOD_WIDTH    => 4
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN                      => EN,
            PHASE                   => x"2",
            LAGGING                 => '1',
            LO_HALF_PERIOD          => x"4",
            SIG_IN                  => SIG_IN,
    
            SIG_OUT                 => mixer_out_sig
        );
    end generate gen_Q;
    
    
    
    -- TODO: mixer_out_upshifted_sig <= ????? <= mixer_out_sig
    
    

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
        EN          => EN,
        RST         => RST,
        COEF_IN     => 
			x"FFF" &
			x"FFE" &
			x"FFC" &
			x"FF8" &
			x"FF5" &
			x"FF4" &
			x"FF6" &
			x"000" &
			x"00F" &
			x"025" &
			x"03C" &
			x"050" &
			x"059" &
			x"052" &
			x"034" &
			x"FFF" &
			x"FB6" &
			x"F62" &
			x"F10" &
			x"ED3" &
			x"EBD" &
			x"EE1" &
			x"F4A" &
			x"000" &
			x"0FC" &
			x"232" &
			x"38A" &
			x"4E6" &
			x"623" &
			x"722" &
			x"7C6" &
			x"7FF" &
			x"7C6" &
			x"722" &
			x"623" &
			x"4E6" &
			x"38A" &
			x"232" &
			x"0FC" &
			x"000" &
			x"F4A" &
			x"EE1" &
			x"EBD" &
			x"ED3" &
			x"F10" &
			x"F62" &
			x"FB6" &
			x"FFF" &
			x"034" &
			x"052" &
			x"059" &
			x"050" &
			x"03C" &
			x"025" &
			x"00F" &
			x"000" &
			x"FF6" &
			x"FF4" &
			x"FF5" &
			x"FF8" &
			x"FFC" &
			x"FFE" &
			x"FFF" ,
        SHIFT_IN    => mixer_out_upshifted_sig,

        SUM_OUT     => filter_out_sig
    );

    ----------------------------------------
    -- IDM signal width reduction
    ----------------------------------------
    IDM: entity work.IntegerDensityModulator
    -- When the output width is 1, the output becomes Pulse Density Modulation (PDM)
    generic map (
        INPUT_WIDTH         => 27,
        OUTPUT_WIDTH        => SIG_OUT_WIDTH,
        PULSE_COUNT_WIDTH   => 1
    )
    port map (
        CLK                 => CLK,
        EN                  => EN,
        RST                 => RST,
        PULSE_LENGTH(0)     => '1',
        INPUT               => filter_out_sig,

        OUTPUT              => SIG_OUT
    );


end Behavioral;
