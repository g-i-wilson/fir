library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPIHalfDuplexFSM is
    port ( 
        CLK             : in STD_LOGIC;
        RST             : in STD_LOGIC;
        VALID_IN        : in STD_LOGIC;
        READY_IN        : in STD_LOGIC;
        WRITE_DONE      : in STD_LOGIC;
        READ_DONE       : in STD_LOGIC;
        BYTE_DONE       : in STD_LOGIC;
        SCK_EDGE        : in STD_LOGIC;
        
        READY_OUT       : out STD_LOGIC;
        VALID_OUT       : out STD_LOGIC;
        READ_EN         : out STD_LOGIC;
        SCK_EN          : out STD_LOGIC;
        BIT_COUNT_EN    : out STD_LOGIC;
        BIT_COUNT_RST   : out STD_LOGIC;
        WRITE_COUNT_EN  : out STD_LOGIC;
        READ_COUNT_EN   : out STD_LOGIC;
        TRISTATE_EN     : out STD_LOGIC;
        LOAD_WRITE_LEN  : out STD_LOGIC;
        LOAD_READ_LEN   : out STD_LOGIC;
        LOAD_DATA_IN    : out STD_LOGIC;
        LOAD_DATA_OUT   : out STD_LOGIC;
        SHIFT_DATA      : out STD_LOGIC;
        CS              : out STD_LOGIC;
        SCK             : out STD_LOGIC
    );
end SPIHalfDuplexFSM;

architecture Behavioral of SPIHalfDuplexFSM is

  type state_type is (
      STDBY_STATE,
      LOAD_WRITE_LEN_STATE,
      LOAD_READ_LEN_STATE,
      FIRST_DATA_STATE,
      W_CLK_H_STATE,
      W_CLK_L_STATE,
      W_SHIFT_DATA_STATE,
      W_BYTE_END_STATE,
      W_NEXT_DATA_STATE,
      R_CLK_H_STATE,
      R_CLK_L_STATE,
      R_SHIFT_DATA_STATE,
      R_BYTE_END_STATE,
      R_NEXT_DATA_STATE,
      TRANSACTION_COMPLETE
    );

    signal current_state        : state_type := STDBY_STATE;
    signal next_state           : state_type := STDBY_STATE;

begin

    FSM_state_register: process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                current_state <= STDBY_STATE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;


    FSM_next_state_logic: process (current_state, VALID_IN, WRITE_DONE, READ_DONE, BYTE_DONE, SCK_EDGE) begin
  
        next_state <= current_state;
        
        -- INIT states
          
        if current_state = STDBY_STATE then
            if (VALID_IN = '1') then
                next_state <= LOAD_WRITE_LEN_STATE;
            end if;
    
        elsif current_state = LOAD_WRITE_LEN_STATE then
            if (VALID_IN = '1') then
                next_state <= LOAD_READ_LEN_STATE;
            end if;
    
        elsif current_state = LOAD_READ_LEN_STATE then
            if (VALID_IN = '1') then
                next_state <= FIRST_DATA_STATE;
            end if;
              
        elsif current_state = FIRST_DATA_STATE then
            next_state <= W_CLK_L_STATE;
              
        
        -- WRITE states
                          
        elsif current_state = W_CLK_H_STATE then
            if (SCK_EDGE = '1') then
                if (BYTE_DONE = '1') then
                    next_state <= W_BYTE_END_STATE;
                else
                    next_state <= W_SHIFT_DATA_STATE;
                end if;
            end if;
        
        elsif current_state = W_BYTE_END_STATE then
            if (WRITE_DONE = '1' and READ_DONE = '1') then
                next_state <= TRANSACTION_COMPLETE;
            elsif (WRITE_DONE = '1') then
                next_state <= R_BYTE_END_STATE;
            elsif (VALID_IN = '1') then
                next_state <= W_NEXT_DATA_STATE;
            end if;
            
        elsif current_state = W_NEXT_DATA_STATE then
            next_state <= W_CLK_L_STATE;
            
        elsif current_state = W_SHIFT_DATA_STATE then
            next_state <= W_CLK_L_STATE;
            
        elsif current_state = W_CLK_L_STATE then
            if (SCK_EDGE = '1') then
                next_state <= W_CLK_H_STATE;
            end if;
                            
        
        -- READ states
                
        elsif current_state = R_CLK_H_STATE then
            if (SCK_EDGE = '1') then
                if (BYTE_DONE = '1') then
                    next_state <= R_BYTE_END_STATE;
                else
                    next_state <= R_SHIFT_DATA_STATE;
                end if;
            end if;
        
        elsif current_state = R_BYTE_END_STATE then
            if (READ_DONE = '1') then
                next_state <= TRANSACTION_COMPLETE;
            elsif (READY_IN = '1') then
                next_state <= R_NEXT_DATA_STATE;
            end if;
        
        elsif current_state = R_NEXT_DATA_STATE then
            next_state <= R_CLK_L_STATE;
            
        elsif current_state = R_SHIFT_DATA_STATE then
            next_state <= R_CLK_L_STATE;
            
        elsif current_state = R_CLK_L_STATE then
            if (SCK_EDGE = '1') then
                next_state <= R_CLK_H_STATE;
            end if;
            
        -- FINAL states
        
        elsif current_state = TRANSACTION_COMPLETE then
            if (SCK_EDGE = '1') then
                next_state <= STDBY_STATE;
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
    SHIFT_DATA              <= '0';
    CS                      <= '1';
    SCK                     <= '0';
    VALID_OUT               <= '0';
    READ_EN                 <= '0';
    TRISTATE_EN             <= '1';
    SCK_EN                  <= '1';
    BIT_COUNT_EN            <= '0';
    BIT_COUNT_RST           <= '0';
    WRITE_COUNT_EN          <= '0';
    READ_COUNT_EN           <= '0';

    -- INIT states
    if current_state = STDBY_STATE then
        READY_OUT           <= '1';
        SCK_EN              <= '0';
    elsif current_state = LOAD_WRITE_LEN_STATE then
        READY_OUT           <= '1';
        SCK_EN              <= '0';
        LOAD_WRITE_LEN      <= '1';
--        LOAD_DATA_OUT       <= '1'; -- copy of WRITE_LEN byte is loaded into DATA_OUT
    elsif current_state = LOAD_READ_LEN_STATE then
        READY_OUT           <= '1';
        SCK_EN              <= '0';
        LOAD_READ_LEN       <= '1';
--        LOAD_DATA_OUT       <= '1'; -- copy of READ_LEN byte is loaded into DATA_OUT
    elsif current_state = FIRST_DATA_STATE then
        SCK_EN              <= '0';
        LOAD_DATA_IN        <= '1';
--        LOAD_DATA_OUT       <= '1'; -- copy of DATA_IN byte is loaded into DATA_OUT
        WRITE_COUNT_EN      <= '1'; -- decrement WRITE_COUNT
        CS                  <= '0';
        TRISTATE_EN         <= '0';
    
    -- WRITE states
    elsif current_state = W_CLK_H_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        TRISTATE_EN         <= '0'; -- writing is always done with tristate disabled
    elsif current_state = W_SHIFT_DATA_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        TRISTATE_EN         <= '0'; -- writing is always done with tristate disabled
        SHIFT_DATA          <= '1'; -- shift DATA_IN << 1 (into DATA_OUT); bit at MSB of DATA_IN is written to SPI
    elsif current_state = W_BYTE_END_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        SCK_EN              <= '0'; -- disable the SCK_EDGE timer while waiting for a VALID_IN signal
        TRISTATE_EN         <= '0'; -- writing is always done with tristate disabled
        READY_OUT           <= '1'; -- READY_OUT is asserted; waits in this state until VALID_IN is asserted
        BIT_COUNT_RST       <= '1';
    elsif current_state = W_NEXT_DATA_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        TRISTATE_EN         <= '0'; -- writing is always done with tristate disabled
        LOAD_DATA_IN        <= '1'; -- enables loading of DATA_IN from size-1 "valid buffer" register
        WRITE_COUNT_EN      <= '1'; -- decrement WRITE_COUNT
    elsif current_state = W_CLK_L_STATE then
        CS                  <= '0';
        TRISTATE_EN         <= '0'; -- writing is always done with tristate disabled
        
    -- READ states
    elsif current_state = R_CLK_H_STATE then
        CS                  <= '0';
        SCK                 <= '1';
    elsif current_state = R_SHIFT_DATA_STATE then
        CS                  <= '0';
        SCK                 <= '1';
        SHIFT_DATA          <= '1';
        READ_EN             <= '1';  -- SPI bus is now shifted into the DATA_OUT register, instead of DATA_IN
    elsif current_state = R_BYTE_END_STATE then
        CS                  <= '0';
        SCK                 <= '1';
        SCK_EN              <= '0'; -- disable the SCK_EDGE timer while waiting for a VALID_IN signal
        VALID_OUT           <= '1';
        BIT_COUNT_RST       <= '1';
    elsif current_state = R_NEXT_DATA_STATE then
        CS                  <= '0';
        SCK                 <= '1'; -- SCK H
        READ_COUNT_EN       <= '1'; -- decrement READ_COUNT
    elsif current_state = R_CLK_L_STATE then
        CS                  <= '0';
        
    -- FINAL state
    elsif current_state = TRANSACTION_COMPLETE then
        -- defaults only
        
    end if;

end process;

end Behavioral;
