
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity reg2D is
  generic (
    length : integer := 0; -- for length <= 0: generates a zero-length "pass-through"
    width : positive := 8;
    big_endian : boolean := true
  );
  port (
    clk : in std_logic;
    rst : in std_logic;

    shift_en : in std_logic := '0';
    par_en : in std_logic := '0';

    shift_in : in std_logic := '0';
    par_in : in std_logic_vector(width-1 downto 0) := (others=>'0');

    default_state : in std_logic_vector((width*length)-1 downto 0) := (others=>'0');
    shift_out : out std_logic;
    par_out : out std_logic_vector(width-1 downto 0);
    all_lower_out : out std_logic_vector((width*(length-1))-1 downto 0)
  );
end;


architecture Behavioral of reg2D is

  signal par_connect_sig : std_logic_vector((width*(length-1))-1 downto 0);
  -- provides parallel signals "between" each register, so width*(length-1)

  signal shift_connect_sig : std_logic_vector((length-1)-1 downto 0);
  -- provides bit signals "between" each register, so width*(length-1)

  begin
      
    -- special case where length = 0
    gen_zero: if (length <= 0) generate
      shift_out  <= shift_in;
      par_out    <= par_in;
      all_lower_out <= (others=>'0');
    end generate gen_zero;

    -- special case where length = 1
    gen_first_unity: if (length = 1) generate
    first_reg : entity work.reg1D
    generic map (
      length => width,
      big_endian => big_endian
    )
    port map (
      clk      => clk,
      rst      => rst,
    
      shift_en => shift_en,
      par_en   => par_en,
    
      default_state => default_state   (width-1 downto 0),
    
      shift_in   => shift_in,
      shift_out  => shift_out,
    
      par_in     => par_in,
      par_out    => par_out
    );
    end generate gen_first_unity;

    gen_first: if (length > 1) generate
      first_reg : entity work.reg1D
        generic map (
          length => width,
          big_endian => big_endian
        )
        port map (
          clk      => clk,
          rst      => rst,

          shift_en => shift_en,
          par_en   => par_en,

          default_state => default_state   (width-1 downto 0),

          shift_in   => shift_in,
          shift_out  => shift_connect_sig  (0),

          par_in     => par_in,
          par_out    => par_connect_sig    (width-1 downto 0)
        );
      end generate gen_first;
      
      gen_middle : for i in 0 to (length-3) generate -- length 5 regs is: in,0,1,2,out
          middle_reg : entity work.reg1D
            generic map (
              length => width,
              big_endian => big_endian
            )
            port map (
              clk      => clk,
              rst      => rst,

              shift_en => shift_en,
              par_en   => par_en,

              default_state => default_state ( (i+1)*width  +(width-1)            downto  (i+1)   *width ),

              shift_in  => shift_connect_sig (  i   ),
              shift_out => shift_connect_sig (  i+1 ),

              par_in    => par_connect_sig (    i   *width   +(width-1)           downto  i       *width ),
              par_out   => par_connect_sig (   (i+1)*width   +(width-1)           downto  (i+1)   *width )

            );
      end generate gen_middle;

      gen_last: if (length >= 2) generate
          last_reg : entity work.reg1D
            generic map (
              length => width,
              big_endian => big_endian
            )
            port map (
              clk      => clk,
              rst      => rst,
    
              shift_en => shift_en,
              par_en   => par_en,
    
              default_state => default_state   ( default_state'high   downto   default_state'high-(width-1) ),
    
              shift_in   => shift_connect_sig  ( shift_connect_sig'high ),
              shift_out  => shift_out,
    
              par_in     => par_connect_sig    ( par_connect_sig'high   downto   par_connect_sig'high-(width-1) ),
              par_out    => par_out
            );
    
          all_lower_out <= par_connect_sig;
      end generate gen_last;

end Behavioral;
