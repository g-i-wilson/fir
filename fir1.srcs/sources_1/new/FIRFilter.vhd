library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FIRFilter is
    generic (
        LENGTH      : integer := 15; -- number of taps
        WIDTH       : integer := 8; -- width of coef and signal path (x2 after multiplication)
        PADDING     : integer := 4  -- extra bits may be required if sum of taps causes overflow
    );
    port (
        CLK         : in STD_LOGIC;
        EN          : in STD_LOGIC;
        RST         : in STD_LOGIC;
        COEF_IN     : in STD_LOGIC_VECTOR (WIDTH*LENGTH-1 downto 0);
        SHIFT_IN    : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);

        SHIFT_OUT   : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
        PAR_OUT     : out STD_LOGIC_VECTOR ((WIDTH*(LENGTH-1))-1 downto 0);
        MULT_OUT    : out STD_LOGIC_VECTOR (WIDTH*2*LENGTH-1 downto 0);
        SUM_OUT     : out STD_LOGIC_VECTOR (WIDTH*2+PADDING-1 downto 0)
    );
end FIRFilter;



architecture Behavioral of FIRFilter is


signal all_reg_sig : std_logic_vector((WIDTH*(LENGTH-1))-1 downto 0);
-- provides all signals "between" each register, so width*(length-1)

signal all_sum_sig : std_logic_vector(((WIDTH*2+PADDING)*(LENGTH-1))-1 downto 0);


begin

    first_reg : reg_mult_generic
        generic map (width, padding)
        port map (
            clk      => clk,
            en       => en,
            rst      => rst,
            reg_in   => shift_in,
            reg_out  => all_reg_sig  ( width-1           downto 0 ),
            coef_in  => coef_in      ( width-1           downto 0 ),
            mult_out => mult_out     ( width*2-1         downto 0 ),
            sum_in   => (others=>'0'), -- constant 0
            sum_out  => all_sum_sig  ( width*2+padding-1 downto 0 )
        );

    gen_middle : for i in 0 to (length-3) generate -- length 5 regs is: in,0,1,2,out
        middle_reg : reg_mult_generic
            generic map (width, padding)
            port map (
                clk      => clk,
                en       => en,
                rst      => rst,
                reg_in   => all_reg_sig (  i    *width             +(width-1)           downto  i    *width             ),
                reg_out  => all_reg_sig ( (i+1) *width             +(width-1)           downto (i+1) *width             ),
                coef_in  => coef_in     ( (i+1) *width             +(width-1)           downto (i+1) *width             ),
                mult_out => mult_out    ( (i+1) *width*2           +(width*2-1)         downto (i+1) *width*2           ),
                sum_in   => all_sum_sig (  i    *(width*2+padding) +(width*2+padding-1) downto  i    *(width*2+padding) ),
                sum_out  => all_sum_sig ( (i+1) *(width*2+padding) +(width*2+padding-1) downto (i+1) *(width*2+padding) )
            );
    end generate gen_middle;

    last_reg : reg_mult_generic
        generic map (width, padding)
        port map (
            clk      => clk,
            en       => en,
            rst      => rst,
            reg_in   => all_reg_sig  ( all_reg_sig'high  downto all_reg_sig'high -(width-1)           ),
            reg_out  => shift_out,
            coef_in  => coef_in      ( coef_in'high      downto coef_in'high     -(width-1)           ),
            mult_out => mult_out     ( mult_out'high     downto mult_out'high    -(width*2-1)         ),
            sum_in   => all_sum_sig  ( all_sum_sig'high  downto all_sum_sig'high -(width*2+padding-1) ),
            sum_out  => sum_out
        );

    par_out <= all_reg_sig;

--    sum_reg : reg_generic
--        generic map (
--            reg_len => width*2+padding
--        )
--        port map (
--            clk => clk,
--            en => en,
--            rst => rst,
--            reg_in => sum_out_comb,
--            reg_out => sum_out
--        );

end Behavioral;
