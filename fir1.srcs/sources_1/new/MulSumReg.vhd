library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MulSumReg is
    generic (
        WIDTH       : positive := 8; -- width of coef and signal path (x2 for mult)
        PADDING     : positive := 4; -- extra bits incase of adder overflow
        PHASE_LAG   : integer := 0   -- additional registers to phase shift signal
    );
    port (
        -- clk, en, rst
        CLK         : in STD_LOGIC;
        EN          : in STD_LOGIC;
        RST         : in STD_LOGIC;
        -- data stream value from previous link in shift register
        REG_IN      : in STD_LOGIC_VECTOR    (WIDTH-1 downto 0);
        -- data value will be multiplied by this coef (might be a constant)
        COEF_IN     : in STD_LOGIC_VECTOR    (WIDTH-1 downto 0);
        -- unchanged data value to send to next link
        REG_OUT     : out STD_LOGIC_VECTOR   (WIDTH-1 downto 0);
        -- data*coef output (mainly for debugging purposes)
        MULT_OUT    : out STD_LOGIC_VECTOR   (WIDTH*2-1 downto 0);
        -- sum from previous link (padding to prevent overflow)
        SUM_IN      : in STD_LOGIC_VECTOR    (WIDTH*2+PADDING-1 downto 0);
        -- sum + data*coef to send to next link
        SUM_OUT     : out STD_LOGIC_VECTOR   (WIDTH*2+PADDING-1 downto 0)
    );
end MulSumReg;



architecture Behavioral of MulSumReg is

    signal mult_out_sig     : std_logic_vector(width*2-1 downto 0);
    signal sum_out_sig      : std_logic_vector(width*2+padding-1 downto 0);

begin

    -- add the product (padded) to the previous incoming sum
    sum_out_sig <= std_logic_vector(
        resize( signed(mult_out_sig) , mult_out_sig'LENGTH  +padding ) +
        signed(sum_in)
    );

    -- pass-through register plus additional phase shift registers
    signal_path : entity work.Reg2D
        generic map (
            WIDTH       => WIDTH,
            LENGTH      => 1+PHASE_LAG
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => EN, -- sample enable
            PAR_IN      => reg_in,
            PAR_OUT     => reg_out
        );

    -- multiplication register
    reg1 : reg_generic
        generic map (
            reg_len => width*2
        )
        port map (
            clk => clk,
            en => '1', -- essentially part of the "sum pipeline" (see below)
            rst => rst,
            reg_in => mult_out_sig,
            reg_out => mult_out
        );

    -- sum register
    reg2 : reg_generic
        generic map (
            reg_len => width*2+padding
        )
        port map (
            clk => clk,
            en => '1', -- "sum pipeline" is always clocking (approximates a pass-thru)
            rst => rst,
            reg_in => sum_out_sig,
            reg_out => sum_out
        );


    -- multiplier
    mult1 : mult_generic
        generic map (
            in_len => width
        )
        port map (
            in_a => reg_in,
            in_b => coef_in,
            mult_out => mult_out_sig
        );

end Behavioral;
