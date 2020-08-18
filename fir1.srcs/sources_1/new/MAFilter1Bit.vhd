library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity MAFilter1Bit is
  generic (
    SAMPLE_LENGTH             : positive := 10;
    SUM_WIDTH                 : positive := 3
  );
  port (
    RST                       : in std_logic;
    CLK                       : in std_logic;
    EN                        : in std_logic;
    SIG_IN                    : in std_logic;

    SUM_OUT                   : out std_logic_vector(SUM_WIDTH-1 downto 0)
  );
end MAFilter1Bit;


architecture Behavioral of MAFilter1Bit is

  signal newest_sample    : std_logic;
  signal oldest_sample    : std_logic;
  signal sum_in_sig       : std_logic_vector(SUM_WIDTH-1 downto 0);
  signal sum_out_sig      : std_logic_vector(SUM_WIDTH-1 downto 0);

begin

  newest_sample <= SIG_IN;

  shift_reg : entity work.Reg1D
  generic map (
    LENGTH          => SAMPLE_LENGTH
  )
  port map (
    RST             => RST,
    CLK             => CLK,
    SHIFT_EN        => EN,
    SHIFT_IN        => newest_sample,
    SHIFT_OUT       => oldest_sample
  );


  sequential_adder: process (sum_out_sig, newest_sample, oldest_sample)
  begin
    if (newest_sample='0' and oldest_sample='1') then
--      sum_in_sig <= std_logic_vector( unsigned(sum_out_sig) - 1 );
      sum_in_sig <= std_logic_vector( unsigned(sum_out_sig) - 1 );
    elsif (newest_sample='1' and oldest_sample='0') then
--      sum_in_sig <= std_logic_vector( unsigned(sum_out_sig) + 1 );
      sum_in_sig <= std_logic_vector( unsigned(sum_out_sig) + 1 );
    else
      sum_in_sig <= sum_out_sig;
    end if;
  end process;


  sum_reg : entity work.Reg1D
  generic map (
    LENGTH          => SUM_WIDTH
  )
  port map (
    RST             => RST,
    CLK             => CLK,
    PAR_EN          => EN,
    PAR_IN          => sum_in_sig,
    PAR_OUT         => sum_out_sig
  );

  SUM_OUT <= sum_out_sig;

end Behavioral;
