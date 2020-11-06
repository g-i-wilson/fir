library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


entity PacketTx is
    generic (
        SYMBOL_WIDTH        : positive := 8; -- typically a BYTE
        PACKET_SYMBOLS      : positive := 4;
        CHECKSUM_SYMBOLS    : positive := 1;
        TIMER_WIDTH         : positive := 8;
        BIG_ENDIAN          : boolean := FALSE
    );
    port (
        CLK                 : in STD_LOGIC;
        EN                  : in STD_LOGIC := '1';
        RST                 : in STD_LOGIC;
        
        READY_OUT           : out STD_LOGIC;
        VALID_IN            : in STD_LOGIC;
        
        READY_IN            : in STD_LOGIC;
        VALID_OUT           : out STD_LOGIC;
        
        PACKET_IN           : in STD_LOGIC_VECTOR(PACKET_SYMBOLS*SYMBOL_WIDTH-1 downto 0);
        SYMBOL_OUT          : out STD_LOGIC_VECTOR(SYMBOL_WIDTH-1 downto 0)
    );
end PacketTx;

architecture Behavioral of PacketTx is

    signal valid_reg_sig            : std_logic_vector(PACKET_SYMBOLS*SYMBOL_WIDTH-1 downto 0);
    signal output_shift_en_sig      : std_logic;
    signal output_par_en_sig        : std_logic;
    signal symbol_sig               : std_logic_vector(SYMBOL_WIDTH-1 downto 0);
    signal checksum_sig             : std_logic_vector(SYMBOL_WIDTH-1 downto 0);
    signal packet_module_ready_sig  : std_logic;
    signal timer_rst_sig            : std_logic;
    signal timer_rst_fsm_sig        : std_logic;
    signal timer_en_sig             : std_logic;
    signal timer_done_sig           : std_logic;
    signal load_checksum_sig        : std_logic;

begin

    timer_rst_sig <= RST or timer_rst_fsm_sig;

    valid_in_reg: entity work.Reg1DSymbols
    generic map (
        LENGTH          => PACKET_SYMBOLS,
        SYMBOL_WIDTH    => SYMBOL_WIDTH
    )
    port map (
        CLK             => CLK,
        RST             => RST,
        
        PAR_EN          => VALID_IN,
        PAR_IN          => PACKET_IN,
        PAR_OUT         => valid_reg_sig
    );

    output_reg: entity work.Reg1DSymbols
    generic map (
        LENGTH          => PACKET_SYMBOLS,
        SYMBOL_WIDTH    => SYMBOL_WIDTH,
        BIG_ENDIAN      => BIG_ENDIAN
    )
    port map (
        CLK             => CLK,
        RST             => RST,
        
        SHIFT_EN        => output_shift_en_sig,
        SHIFT_OUT       => symbol_sig,
        
        PAR_EN          => output_par_en_sig,
        PAR_IN          => valid_reg_sig
    );
    
    SYMBOL_OUT <= checksum_sig when load_checksum_sig = '1' else symbol_sig;
    

    word_timer : entity work.Timer
    generic map (
        WIDTH           => TIMER_WIDTH
    )
    port map (
        CLK             => CLK,
        EN              => timer_en_sig,
        RST             => timer_rst_sig,
        COUNT_END       => std_logic_vector(to_unsigned(PACKET_SYMBOLS-1, TIMER_WIDTH)),

        DONE            => timer_done_sig
    );

    

end Behavioral;
