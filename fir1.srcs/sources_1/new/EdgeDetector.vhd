library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity EdgeDetector is
  generic (
    SAMPLE_LENGTH             : positive := 16;
    SUM_WIDTH                 : positive := 4;
    LOGIC_HIGH                : positive := 13;
    LOGIC_LOW                 : positive := 2;
    SUM_START                 : positive := 7
  );
  port (
    RST                       : in std_logic;
    EN                        : in std_logic;
    CLK                       : in std_logic;

    SIG_IN                    : in std_logic;

    EDGE_EVENT                : out std_logic;
    VALID                     : out std_logic;
    DATA                      : out std_logic
  );
end EdgeDetector;


architecture Behavioral of EdgeDetector is

  type state_type is (
    INIT,
    VALID_HIGH,
    VALID_LOW,
    FALLING,
    RISING
  );

  signal current_state        : state_type := INIT;
  signal next_state           : state_type := INIT;

  signal sum_sig              : std_logic_vector(SUM_WIDTH-1 downto 0);

begin


  moving_average : entity work.MAFilter1Bit
  generic map (
    SAMPLE_LENGTH => SAMPLE_LENGTH,
    SUM_WIDTH => SUM_WIDTH,
    SUM_START => SUM_START
  )
  port map (
    CLK => CLK,
    EN => EN,
    RST => RST,
    SIG_IN => SIG_IN,
    SUM_OUT => sum_sig
  );


  FSM_register: process (CLK) begin
    if rising_edge(CLK) then
      if (RST = '1') then
        current_state <= INIT;
      elsif (EN = '1') then
        current_state <= next_state;
      else
        current_state <= current_state;
      end if;
    end if;
  end process;


  FSM_comb_logic: process (current_state, sum_sig) begin
    -- begin with assumption output signals will be '0'
    VALID <= '0';
    DATA <= '0';
    EDGE_EVENT <= '0';
    -- INIT
    if (current_state = INIT) then
      if (unsigned(sum_sig) >= LOGIC_HIGH) then
        next_state <= VALID_HIGH;
      elsif (unsigned(sum_sig) <= LOGIC_LOW) then
        next_state <= VALID_LOW;
      end if;
    -- VALID_HIGH
    elsif (current_state = VALID_HIGH) then
      VALID <= '1';
      DATA <= '1';
      if (unsigned(sum_sig) < LOGIC_HIGH and unsigned(sum_sig) > LOGIC_LOW) then
        next_state <= FALLING;
      elsif (unsigned(sum_sig) <= LOGIC_LOW) then
        next_state <= VALID_LOW;
      end if;
    -- FALLING
    elsif (current_state = FALLING) then
      DATA <= '1';
      if (unsigned(sum_sig) <= LOGIC_LOW) then
        next_state <= VALID_LOW;
        EDGE_EVENT <= '1';
        VALID <= '1';
      elsif (unsigned(sum_sig) >= LOGIC_HIGH) then
        next_state <= VALID_HIGH;
      end if;
    -- VALID_LOW
    elsif (current_state = VALID_LOW) then
      VALID <= '1';
      if (unsigned(sum_sig) < LOGIC_HIGH and unsigned(sum_sig) > LOGIC_LOW) then
        next_state <= RISING;
      elsif (unsigned(sum_sig) >= LOGIC_HIGH) then
        next_state <= VALID_HIGH;
      end if;
    -- RISING
    elsif (current_state = RISING) then
      if (unsigned(sum_sig) >= LOGIC_HIGH) then
        next_state <= VALID_HIGH;
        EDGE_EVENT <= '1';
        VALID <= '1';
      elsif (unsigned(sum_sig) >= LOGIC_HIGH) then
        next_state <= VALID_LOW;
      end if;
    -- DEFAULT STATE (to be sure to not infer memory)
    else
      next_state <= INIT;
    end if;


  end process;


end Behavioral;
