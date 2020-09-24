library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Timer is
    generic (
        WIDTH               : positive := 8
    );
    port (
        -- inputs
        CLK                 : in STD_LOGIC;
        EN                  : in STD_LOGIC;
        RST                 : in STD_LOGIC;
        CMP                 : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
        -- outputs
        DONE                : out STD_LOGIC;
        COUNT               : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
   );
end Timer;

architecture Behavioral of Timer is

    signal done_sig         : std_logic;
    signal count_in_sig     : std_logic_vector (WIDTH-1 downto 0);
    signal count_out_sig    : std_logic_vector (WIDTH-1 downto 0);

begin
    
    COUNT <= count_out_sig;
    DONE <= done_sig;
    
    count_in_sig <= std_logic_vector( unsigned(count_out_sig) + 1 );

    process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                done_sig <= '0';
                count_out_sig <= (others=>'0');
            elsif (EN = '1') then
                if (unsigned(count_out_sig) < unsigned(CMP)) then
                    count_out_sig <= count_in_sig;
                else
                    done_sig <= '1';
                end if;
            else
                count_out_sig <= count_out_sig;
                done_sig <= done_sig;
            end if;
        end if;
    end process;

end Behavioral;
