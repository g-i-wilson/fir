library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity PacketRxFSM is
    port (
        CLK                 : in STD_LOGIC;
        RST                 : in STD_LOGIC;
        
        READY_OUT           : out STD_LOGIC;
        VALID_IN            : in STD_LOGIC;
        
        READY_IN            : in STD_LOGIC;
        VALID_OUT           : out STD_LOGIC;
        
        HEADER_VERIFIED     : in STD_LOGIC;
        CHECKSUM_VERIFIED   : in STD_LOGIC;
        SUM_RST             : out STD_LOGIC
    );
end PacketRxFSM;

architecture Behavioral of PacketRxFSM is

    type state_type is (
        SHIFT_EN_STATE,
        HEADER_ONLY_STATE,
        VALID_OUT_STATE
    );
    
    signal current_state        : state_type := SHIFT_EN_STATE;
    signal next_state           : state_type := SHIFT_EN_STATE;
  
begin

    FSM_state_register: process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                current_state <= SHIFT_EN_STATE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;


    FSM_next_state_logic: process (current_state, VALID_IN, READY_IN, HEADER_VERIFIED, CHECKSUM_VERIFIED) begin
    
        next_state <= current_state;
        
        case current_state is
        
            when SHIFT_EN_STATE =>
                if (HEADER_VERIFIED = '1') then
                    if (CHECKSUM_VERIFIED = '1') then
                        next_state <= VALID_OUT_STATE;
                    else
                        next_state <= HEADER_ONLY_STATE;
                    end if;
                end if;
                
            when HEADER_ONLY_STATE =>
                next_state <= SHIFT_EN_STATE;
                
            when VALID_OUT_STATE =>
                if (READY_IN = '1') then
                    next_state <= SHIFT_EN_STATE;
                end if;
                                
            when others =>
                next_state <= SHIFT_EN_STATE;
                
        end case;
        
    end process;


  FSM_output_logic: process (current_state) begin
  
    -- defaults
    READY_OUT           <= '0';
    VALID_OUT           <= '0';
    SUM_RST             <= '0';
    
    case current_state is
        when SHIFT_EN_STATE         =>
            READY_OUT           <= '1';
        when HEADER_ONLY_STATE      =>
            SUM_RST             <= '1';
        when VALID_OUT_STATE        =>
            VALID_OUT           <= '1';
            SUM_RST             <= '1';
        when others =>
            -- nothing
    end case;

  end process;

end Behavioral;