library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPITransactionFSM is
    port ( 
        -- inputs
        CLK             : in STD_LOGIC;
        RST             : in STD_LOGIC;
        VALID_IN        : in STD_LOGIC;
        READY_IN        : in STD_LOGIC;
        WRITE_DONE      : in STD_LOGIC;
        READ_DONE       : in STD_LOGIC;
        BYTE_DONE       : in STD_LOGIC;
        SCK_EDGE        : in STD_LOGIC;
        -- outputs
        READY_OUT       : out STD_LOGIC;
        VALID_OUT       : out STD_LOGIC;
        SCK_EN          : out STD_LOGIC;
        BIT_COUNT_EN    : out STD_LOGIC;
        BIT_COUNT_RST   : out STD_LOGIC;
        WRITE_COUNT_EN  : out STD_LOGIC;
        READ_COUNT_EN   : out STD_LOGIC;
        RW_COUNT_RST    : out STD_LOGIC;
        TRISTATE_EN     : out STD_LOGIC;
        LOAD_WRITE_LEN  : out STD_LOGIC;
        LOAD_READ_LEN   : out STD_LOGIC;
        LOAD_DATA_IN    : out STD_LOGIC;
        LOAD_DATA_OUT   : out STD_LOGIC;
        SHIFT_DATA_IN   : out STD_LOGIC;
        SHIFT_DATA_OUT  : out STD_LOGIC;
        CS              : out STD_LOGIC;
        SCK             : out STD_LOGIC;
        -- debug outputs
        STATE           : out STD_LOGIC_VECTOR(7 downto 0)
    );
end SPITransactionFSM;

architecture Behavioral of SPITransactionFSM is

--  type state_type is (
--      READY_WRITE_LEN_STATE,
--      LOAD_WRITE_LEN_STATE,
--      VALID_WRITE_LEN_STATE,
      
--      READY_READ_LEN_STATE,
--      LOAD_READ_LEN_STATE,
--      VALID_READ_LEN_STATE,
      
--      READY_FIRST_DATA_STATE,
--      LOAD_FIRST_DATA_STATE,
      
--      W_CLK_H_STATE,
--      W_CLK_L_STATE,
--      W_SHIFT_DATA_IN_STATE,
--      W_SHIFT_DATA_OUT_STATE,
--      W_COUNT_STATE,
--      W_VALID_DATA_STATE,
--      W_READY_DATA_STATE,
--      W_LOAD_DATA_IN_STATE,
      
--      R_CLK_H_STATE,
--      R_CLK_L_STATE,
--      R_SHIFT_DATA_OUT_STATE,
--      R_VALID_DATA_STATE,
--      R_COUNT_STATE,
      
--      FINAL_CLK_L_STATE,
--      FINAL_CS_H_STATE
--    );

--    signal current_state        : state_type := READY_WRITE_LEN_STATE;
--    signal next_state           : state_type := READY_WRITE_LEN_STATE;

constant READY_WRITE_LEN_STATE      : std_logic_vector(7 downto 0) := x"01";
constant LOAD_WRITE_LEN_STATE       : std_logic_vector(7 downto 0) := x"02";
constant VALID_WRITE_LEN_STATE      : std_logic_vector(7 downto 0) := x"03";
constant READY_READ_LEN_STATE       : std_logic_vector(7 downto 0) := x"04";
constant LOAD_READ_LEN_STATE        : std_logic_vector(7 downto 0) := x"05";
constant VALID_READ_LEN_STATE       : std_logic_vector(7 downto 0) := x"06";

constant READY_FIRST_DATA_STATE     : std_logic_vector(7 downto 0) := x"07";
constant LOAD_FIRST_DATA_STATE      : std_logic_vector(7 downto 0) := x"08";

constant W_CLK_H_STATE              : std_logic_vector(7 downto 0) := x"09";
constant W_CLK_L_STATE              : std_logic_vector(7 downto 0) := x"10";
constant W_SHIFT_DATA_IN_STATE      : std_logic_vector(7 downto 0) := x"11";
constant W_SHIFT_DATA_OUT_STATE     : std_logic_vector(7 downto 0) := x"12";
constant W_COUNT_STATE              : std_logic_vector(7 downto 0) := x"13";
constant W_VALID_DATA_STATE         : std_logic_vector(7 downto 0) := x"14";
constant W_READY_DATA_STATE         : std_logic_vector(7 downto 0) := x"15";
constant W_LOAD_DATA_IN_STATE       : std_logic_vector(7 downto 0) := x"16";

constant R_CLK_H_STATE              : std_logic_vector(7 downto 0) := x"17";
constant R_CLK_L_STATE              : std_logic_vector(7 downto 0) := x"18";
constant R_SHIFT_DATA_OUT_STATE     : std_logic_vector(7 downto 0) := x"19";
constant R_VALID_DATA_STATE         : std_logic_vector(7 downto 0) := x"20";
constant R_COUNT_STATE              : std_logic_vector(7 downto 0) := x"21";

constant FINAL_CLK_L_STATE          : std_logic_vector(7 downto 0) := x"22";
constant FINAL_CS_H_STATE           : std_logic_vector(7 downto 0) := x"23";


signal current_state                : std_logic_vector(7 downto 0) := READY_WRITE_LEN_STATE;
signal next_state                   : std_logic_vector(7 downto 0) := READY_WRITE_LEN_STATE;


begin

    FSM_state_register: process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                current_state <= READY_WRITE_LEN_STATE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;
    
    
    STATE <= current_state;


    FSM_next_state_logic: process (current_state, VALID_IN, WRITE_DONE, READ_DONE, BYTE_DONE, SCK_EDGE) begin
  
        next_state <= current_state;
        
        -- INIT states
          
        if current_state = READY_WRITE_LEN_STATE then
            if (VALID_IN = '1') then
                next_state <= LOAD_WRITE_LEN_STATE;
            end if;
    
        elsif current_state = LOAD_WRITE_LEN_STATE then
            next_state <= VALID_WRITE_LEN_STATE;
    
        elsif current_state = VALID_WRITE_LEN_STATE then
            if (READY_IN = '1') then
                next_state <= READY_READ_LEN_STATE;
            end if;
            
    
        elsif current_state = READY_READ_LEN_STATE then
            if (VALID_IN = '1') then
                next_state <= LOAD_READ_LEN_STATE;
            end if;
    
        elsif current_state = LOAD_READ_LEN_STATE then
            next_state <= VALID_READ_LEN_STATE;
    
        elsif current_state = VALID_READ_LEN_STATE then
            if (READY_IN = '1') then
                next_state <= READY_FIRST_DATA_STATE;
            end if;
            
    
        elsif current_state = READY_FIRST_DATA_STATE then
            if (VALID_IN = '1') then
                next_state <= LOAD_FIRST_DATA_STATE;
            end if;
    
        elsif current_state = LOAD_FIRST_DATA_STATE then
            next_state <= W_CLK_L_STATE;
              
        
        -- WRITE states
                          
        elsif current_state = W_LOAD_DATA_IN_STATE then
            next_state <= W_CLK_L_STATE;
            
        elsif current_state = W_CLK_L_STATE then
            if (SCK_EDGE = '1') then
                next_state <= W_CLK_H_STATE;
            end if;
                            
        elsif current_state = W_CLK_H_STATE then
            if (SCK_EDGE = '1') then
                next_state <= W_SHIFT_DATA_OUT_STATE;
            end if;
        
        elsif current_state = W_SHIFT_DATA_OUT_STATE then
            if (BYTE_DONE = '1') then
                next_state <= W_COUNT_STATE;
            else
                next_state <= W_SHIFT_DATA_IN_STATE;
            end if;
        
        elsif current_state = W_SHIFT_DATA_IN_STATE then
            next_state <= W_CLK_L_STATE;
            
        elsif current_state = W_COUNT_STATE then
            next_state <= W_VALID_DATA_STATE;
        
        elsif current_state = W_VALID_DATA_STATE then
            if (WRITE_DONE = '1' and READ_DONE = '1') then
                next_state <= FINAL_CLK_L_STATE;
            elsif (WRITE_DONE = '1') then
                next_state <= R_CLK_L_STATE;
            elsif (READY_IN = '1') then
                next_state <= W_READY_DATA_STATE;
            end if;
            
        elsif current_state = W_READY_DATA_STATE then
            if (VALID_IN = '1') then
                next_state <= W_LOAD_DATA_IN_STATE;
            end if;
            
        
        -- READ states
                
        elsif current_state = R_CLK_L_STATE then
            if (SCK_EDGE = '1') then
                next_state <= R_CLK_H_STATE;
            end if;
            
        elsif current_state = R_CLK_H_STATE then
            if (SCK_EDGE = '1') then
                next_state <= R_SHIFT_DATA_OUT_STATE;
            end if;
        
        elsif current_state = R_SHIFT_DATA_OUT_STATE then
            if (BYTE_DONE = '1') then
                next_state <= R_COUNT_STATE;
            else
                next_state <= R_CLK_L_STATE;
            end if;
            
        elsif current_state = R_COUNT_STATE then
            next_state <= R_VALID_DATA_STATE;
            
        elsif current_state = R_VALID_DATA_STATE then
            if (READ_DONE = '1') then
                next_state <= FINAL_CLK_L_STATE;
            elsif (READY_IN = '1') then
                next_state <= R_CLK_L_STATE;
            end if;
        

        -- FINAL states
        
        elsif current_state = FINAL_CLK_L_STATE then
            if (SCK_EDGE = '1') then
                next_state <= FINAL_CS_H_STATE;
            end if;

        elsif current_state = FINAL_CS_H_STATE then
            if (SCK_EDGE = '1') then
                next_state <= READY_WRITE_LEN_STATE;
            end if;
                    
        end if;
      
    end process;


FSM_output_logic: process (current_state) begin

    -- defaults
    READY_OUT               <= '0';
    LOAD_WRITE_LEN          <= '0';
    LOAD_READ_LEN           <= '0';
    LOAD_DATA_IN            <= '0';
    LOAD_DATA_OUT           <= '0';
    SHIFT_DATA_IN           <= '0';
    SHIFT_DATA_OUT          <= '0';
    CS                      <= '1';
    SCK                     <= '0';
    VALID_OUT               <= '0';
    TRISTATE_EN             <= '1';
    SCK_EN                  <= '0';
    BIT_COUNT_EN            <= '0';
    BIT_COUNT_RST           <= '0';
    WRITE_COUNT_EN          <= '0';
    READ_COUNT_EN           <= '0';
    RW_COUNT_RST            <= '0';


    -- INIT states
    if current_state = READY_WRITE_LEN_STATE then
        RW_COUNT_RST        <= '1';
        READY_OUT           <= '1';
    elsif current_state = LOAD_WRITE_LEN_STATE then
        LOAD_WRITE_LEN      <= '1';
        LOAD_DATA_OUT       <= '1';
    elsif current_state = VALID_WRITE_LEN_STATE then
        VALID_OUT           <= '1';
    elsif current_state = READY_READ_LEN_STATE then
        READY_OUT           <= '1';
    elsif current_state = LOAD_READ_LEN_STATE then
        LOAD_READ_LEN       <= '1';
        LOAD_DATA_OUT       <= '1';
    elsif current_state = VALID_READ_LEN_STATE then
        VALID_OUT           <= '1';
    elsif current_state = READY_FIRST_DATA_STATE then
        READY_OUT           <= '1';
    elsif current_state = LOAD_FIRST_DATA_STATE then
        LOAD_DATA_IN        <= '1';
        CS                  <= '0';
        TRISTATE_EN         <= '0';
    
    -- WRITE states
    elsif current_state = W_CLK_L_STATE then
        CS                  <= '0';
        SCK_EN              <= '1'; -- enable the SCK_EDGE timer
        TRISTATE_EN         <= '0'; -- writing is always done with tristate disabled
    elsif current_state = W_CLK_H_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        SCK_EN              <= '1'; -- enable the SCK_EDGE timer
        TRISTATE_EN         <= '0'; -- writing is always done with tristate disabled
    elsif current_state = W_SHIFT_DATA_OUT_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        TRISTATE_EN         <= '0'; -- writing is always done with tristate disabled
        SHIFT_DATA_OUT      <= '1'; -- shift DATA_OUT << 1; bit is shifted from MISO
        BIT_COUNT_EN        <= '1';
    elsif current_state = W_SHIFT_DATA_IN_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        TRISTATE_EN         <= '0'; -- writing is always done with tristate disabled
        SHIFT_DATA_IN       <= '1'; -- shift DATA_IN << 1; MSB of DATA_IN appears as MOSI
    elsif current_state = W_COUNT_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        TRISTATE_EN         <= '0'; -- writing is always done with tristate disabled
        WRITE_COUNT_EN      <= '1';
        BIT_COUNT_RST       <= '1';
    elsif current_state = W_VALID_DATA_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        TRISTATE_EN         <= '0'; -- writing is always done with tristate disabled
        VALID_OUT           <= '1'; -- VALID_OUT is asserted; waits in this state until READY_IN is asserted
    elsif current_state = W_READY_DATA_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        TRISTATE_EN         <= '0'; -- writing is always done with tristate disabled
        READY_OUT           <= '1'; -- READY_OUT is asserted; waits in this state until VALID_IN is asserted
    elsif current_state = W_LOAD_DATA_IN_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        TRISTATE_EN         <= '0'; -- writing is always done with tristate disabled
        LOAD_DATA_IN        <= '1'; -- enables loading of DATA_IN from size-1 "valid buffer" register
        
    -- READ states
    elsif current_state = R_CLK_L_STATE then
        CS                  <= '0';
        SCK_EN              <= '1'; -- enable the SCK_EDGE timer
    elsif current_state = R_CLK_H_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        SCK_EN              <= '1'; -- enable the SCK_EDGE timer
    elsif current_state = R_SHIFT_DATA_OUT_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        SHIFT_DATA_OUT      <= '1'; -- shift DATA_OUT << 1; bit is shifted from MISO
        BIT_COUNT_EN        <= '1';
    elsif current_state = R_COUNT_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        READ_COUNT_EN       <= '1';
        BIT_COUNT_RST       <= '1';
    elsif current_state = R_VALID_DATA_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        VALID_OUT           <= '1';
        
    -- FINAL states
    elsif current_state = FINAL_CLK_L_STATE then
        CS                  <= '0';
        SCK_EN              <= '1'; -- enable the SCK_EDGE timer
    elsif current_state = FINAL_CS_H_STATE then
        SCK_EN              <= '1'; -- enable the SCK_EDGE timer


    end if;

end process;

end Behavioral;
