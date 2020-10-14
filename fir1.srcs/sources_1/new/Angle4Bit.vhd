library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Angle4Bit is
    port (
        CLK         : in STD_LOGIC;
        EN          : in STD_LOGIC := '1';
        RST         : in STD_LOGIC;

        X_IN        : in STD_LOGIC_VECTOR(3 downto 0);
		Y_IN        : in STD_LOGIC_VECTOR(3 downto 0);

        A_OUT       : out STD_LOGIC_VECTOR(7 downto 0);
        DIFF_OUT    : out STD_LOGIC_VECTOR(7 downto 0)
    );
end Angle4Bit;

architecture Behavioral of Angle4Bit is

    signal a0_sig           : std_logic_vector(7 downto 0);
    signal a1_sig           : std_logic_vector(7 downto 0);
    signal diff_sig         : std_logic_vector(7 downto 0);
    signal diff_out_sig     : std_logic_vector(7 downto 0);

begin

    diff_out_reg : entity work.Reg1D
    generic map (
        LENGTH      => 8
    )
    port map (
        CLK         => CLK,
        RST         => RST,
        PAR_EN      => EN,
        PAR_IN      => diff_sig,
        PAR_OUT     => DIFF_OUT
    );

    diff_sig <= std_logic_vector(signed(a0_sig) - signed(a1_sig));

    a_out_reg : entity work.Reg1D
    generic map (
        LENGTH      => 8
    )
    port map (
        CLK         => CLK,
        RST         => RST,
        PAR_EN      => EN,
        PAR_IN      => a0_sig,
        PAR_OUT     => a1_sig
    );

    A_OUT <= a1_sig;

	process (X_IN, Y_IN)
	begin
        case (X_IN & Y_IN) is
            when x"88" => a0_sig <= x"A0";
            when x"89" => a0_sig <= x"9D";
            when x"8A" => a0_sig <= x"9A";
            when x"8B" => a0_sig <= x"97";
            when x"8C" => a0_sig <= x"93";
            when x"8D" => a0_sig <= x"8F";
            when x"8E" => a0_sig <= x"8A";
            when x"8F" => a0_sig <= x"85";
            when x"80" => a0_sig <= x"7F";
            when x"81" => a0_sig <= x"7A";
            when x"82" => a0_sig <= x"75";
            when x"83" => a0_sig <= x"70";
            when x"84" => a0_sig <= x"6C";
            when x"85" => a0_sig <= x"68";
            when x"86" => a0_sig <= x"65";
            when x"87" => a0_sig <= x"62";
            when x"98" => a0_sig <= x"A3";
            when x"99" => a0_sig <= x"A0";
            when x"9A" => a0_sig <= x"9D";
            when x"9B" => a0_sig <= x"99";
            when x"9C" => a0_sig <= x"95";
            when x"9D" => a0_sig <= x"90";
            when x"9E" => a0_sig <= x"8B";
            when x"9F" => a0_sig <= x"86";
            when x"90" => a0_sig <= x"7F";
            when x"91" => a0_sig <= x"79";
            when x"92" => a0_sig <= x"74";
            when x"93" => a0_sig <= x"6F";
            when x"94" => a0_sig <= x"6A";
            when x"95" => a0_sig <= x"66";
            when x"96" => a0_sig <= x"62";
            when x"97" => a0_sig <= x"5F";
            when x"A8" => a0_sig <= x"A6";
            when x"A9" => a0_sig <= x"A3";
            when x"AA" => a0_sig <= x"A0";
            when x"AB" => a0_sig <= x"9C";
            when x"AC" => a0_sig <= x"98";
            when x"AD" => a0_sig <= x"93";
            when x"AE" => a0_sig <= x"8D";
            when x"AF" => a0_sig <= x"87";
            when x"A0" => a0_sig <= x"7F";
            when x"A1" => a0_sig <= x"78";
            when x"A2" => a0_sig <= x"72";
            when x"A3" => a0_sig <= x"6C";
            when x"A4" => a0_sig <= x"67";
            when x"A5" => a0_sig <= x"63";
            when x"A6" => a0_sig <= x"5F";
            when x"A7" => a0_sig <= x"5C";
            when x"B8" => a0_sig <= x"A9";
            when x"B9" => a0_sig <= x"A7";
            when x"BA" => a0_sig <= x"A4";
            when x"BB" => a0_sig <= x"A0";
            when x"BC" => a0_sig <= x"9B";
            when x"BD" => a0_sig <= x"96";
            when x"BE" => a0_sig <= x"8F";
            when x"BF" => a0_sig <= x"88";
            when x"B0" => a0_sig <= x"7F";
            when x"B1" => a0_sig <= x"77";
            when x"B2" => a0_sig <= x"70";
            when x"B3" => a0_sig <= x"69";
            when x"B4" => a0_sig <= x"64";
            when x"B5" => a0_sig <= x"5F";
            when x"B6" => a0_sig <= x"5B";
            when x"B7" => a0_sig <= x"58";
            when x"C8" => a0_sig <= x"AD";
            when x"C9" => a0_sig <= x"AB";
            when x"CA" => a0_sig <= x"A8";
            when x"CB" => a0_sig <= x"A4";
            when x"CC" => a0_sig <= x"A0";
            when x"CD" => a0_sig <= x"9A";
            when x"CE" => a0_sig <= x"93";
            when x"CF" => a0_sig <= x"8A";
            when x"C0" => a0_sig <= x"7F";
            when x"C1" => a0_sig <= x"75";
            when x"C2" => a0_sig <= x"6C";
            when x"C3" => a0_sig <= x"65";
            when x"C4" => a0_sig <= x"5F";
            when x"C5" => a0_sig <= x"5B";
            when x"C6" => a0_sig <= x"57";
            when x"C7" => a0_sig <= x"54";
            when x"D8" => a0_sig <= x"B1";
            when x"D9" => a0_sig <= x"AF";
            when x"DA" => a0_sig <= x"AD";
            when x"DB" => a0_sig <= x"AA";
            when x"DC" => a0_sig <= x"A6";
            when x"DD" => a0_sig <= x"A0";
            when x"DE" => a0_sig <= x"98";
            when x"DF" => a0_sig <= x"8D";
            when x"D0" => a0_sig <= x"7F";
            when x"D1" => a0_sig <= x"72";
            when x"D2" => a0_sig <= x"67";
            when x"D3" => a0_sig <= x"5F";
            when x"D4" => a0_sig <= x"59";
            when x"D5" => a0_sig <= x"55";
            when x"D6" => a0_sig <= x"52";
            when x"D7" => a0_sig <= x"50";
            when x"E8" => a0_sig <= x"B6";
            when x"E9" => a0_sig <= x"B4";
            when x"EA" => a0_sig <= x"B3";
            when x"EB" => a0_sig <= x"B0";
            when x"EC" => a0_sig <= x"AD";
            when x"ED" => a0_sig <= x"A8";
            when x"EE" => a0_sig <= x"A0";
            when x"EF" => a0_sig <= x"93";
            when x"E0" => a0_sig <= x"7F";
            when x"E1" => a0_sig <= x"6C";
            when x"E2" => a0_sig <= x"5F";
            when x"E3" => a0_sig <= x"57";
            when x"E4" => a0_sig <= x"52";
            when x"E5" => a0_sig <= x"4F";
            when x"E6" => a0_sig <= x"4C";
            when x"E7" => a0_sig <= x"4B";
            when x"F8" => a0_sig <= x"BB";
            when x"F9" => a0_sig <= x"BA";
            when x"FA" => a0_sig <= x"B9";
            when x"FB" => a0_sig <= x"B8";
            when x"FC" => a0_sig <= x"B6";
            when x"FD" => a0_sig <= x"B3";
            when x"FE" => a0_sig <= x"AD";
            when x"FF" => a0_sig <= x"A0";
            when x"F0" => a0_sig <= x"7F";
            when x"F1" => a0_sig <= x"5F";
            when x"F2" => a0_sig <= x"52";
            when x"F3" => a0_sig <= x"4C";
            when x"F4" => a0_sig <= x"49";
            when x"F5" => a0_sig <= x"47";
            when x"F6" => a0_sig <= x"46";
            when x"F7" => a0_sig <= x"45";
            when x"08" => a0_sig <= x"C0";
            when x"09" => a0_sig <= x"C0";
            when x"0A" => a0_sig <= x"C0";
            when x"0B" => a0_sig <= x"C0";
            when x"0C" => a0_sig <= x"C0";
            when x"0D" => a0_sig <= x"C0";
            when x"0E" => a0_sig <= x"C0";
            when x"0F" => a0_sig <= x"C0";
            when x"00" => a0_sig <= x"00";
            when x"01" => a0_sig <= x"3F";
            when x"02" => a0_sig <= x"3F";
            when x"03" => a0_sig <= x"3F";
            when x"04" => a0_sig <= x"3F";
            when x"05" => a0_sig <= x"3F";
            when x"06" => a0_sig <= x"3F";
            when x"07" => a0_sig <= x"3F";
            when x"18" => a0_sig <= x"C5";
            when x"19" => a0_sig <= x"C6";
            when x"1A" => a0_sig <= x"C6";
            when x"1B" => a0_sig <= x"C8";
            when x"1C" => a0_sig <= x"CA";
            when x"1D" => a0_sig <= x"CD";
            when x"1E" => a0_sig <= x"D3";
            when x"1F" => a0_sig <= x"E0";
            when x"10" => a0_sig <= x"00";
            when x"11" => a0_sig <= x"1F";
            when x"12" => a0_sig <= x"2C";
            when x"13" => a0_sig <= x"32";
            when x"14" => a0_sig <= x"35";
            when x"15" => a0_sig <= x"37";
            when x"16" => a0_sig <= x"39";
            when x"17" => a0_sig <= x"39";
            when x"28" => a0_sig <= x"CA";
            when x"29" => a0_sig <= x"CB";
            when x"2A" => a0_sig <= x"CD";
            when x"2B" => a0_sig <= x"CF";
            when x"2C" => a0_sig <= x"D3";
            when x"2D" => a0_sig <= x"D8";
            when x"2E" => a0_sig <= x"E0";
            when x"2F" => a0_sig <= x"ED";
            when x"20" => a0_sig <= x"00";
            when x"21" => a0_sig <= x"12";
            when x"22" => a0_sig <= x"1F";
            when x"23" => a0_sig <= x"27";
            when x"24" => a0_sig <= x"2C";
            when x"25" => a0_sig <= x"30";
            when x"26" => a0_sig <= x"32";
            when x"27" => a0_sig <= x"34";
            when x"38" => a0_sig <= x"CE";
            when x"39" => a0_sig <= x"D0";
            when x"3A" => a0_sig <= x"D3";
            when x"3B" => a0_sig <= x"D6";
            when x"3C" => a0_sig <= x"DA";
            when x"3D" => a0_sig <= x"E0";
            when x"3E" => a0_sig <= x"E8";
            when x"3F" => a0_sig <= x"F2";
            when x"30" => a0_sig <= x"00";
            when x"31" => a0_sig <= x"0D";
            when x"32" => a0_sig <= x"17";
            when x"33" => a0_sig <= x"1F";
            when x"34" => a0_sig <= x"25";
            when x"35" => a0_sig <= x"29";
            when x"36" => a0_sig <= x"2C";
            when x"37" => a0_sig <= x"2F";
            when x"48" => a0_sig <= x"D3";
            when x"49" => a0_sig <= x"D5";
            when x"4A" => a0_sig <= x"D8";
            when x"4B" => a0_sig <= x"DB";
            when x"4C" => a0_sig <= x"E0";
            when x"4D" => a0_sig <= x"E5";
            when x"4E" => a0_sig <= x"ED";
            when x"4F" => a0_sig <= x"F6";
            when x"40" => a0_sig <= x"00";
            when x"41" => a0_sig <= x"09";
            when x"42" => a0_sig <= x"12";
            when x"43" => a0_sig <= x"1A";
            when x"44" => a0_sig <= x"1F";
            when x"45" => a0_sig <= x"24";
            when x"46" => a0_sig <= x"27";
            when x"47" => a0_sig <= x"2A";
            when x"58" => a0_sig <= x"D6";
            when x"59" => a0_sig <= x"D9";
            when x"5A" => a0_sig <= x"DC";
            when x"5B" => a0_sig <= x"E0";
            when x"5C" => a0_sig <= x"E4";
            when x"5D" => a0_sig <= x"EA";
            when x"5E" => a0_sig <= x"F0";
            when x"5F" => a0_sig <= x"F7";
            when x"50" => a0_sig <= x"00";
            when x"51" => a0_sig <= x"08";
            when x"52" => a0_sig <= x"0F";
            when x"53" => a0_sig <= x"15";
            when x"54" => a0_sig <= x"1B";
            when x"55" => a0_sig <= x"1F";
            when x"56" => a0_sig <= x"23";
            when x"57" => a0_sig <= x"26";
            when x"68" => a0_sig <= x"DA";
            when x"69" => a0_sig <= x"DD";
            when x"6A" => a0_sig <= x"E0";
            when x"6B" => a0_sig <= x"E3";
            when x"6C" => a0_sig <= x"E8";
            when x"6D" => a0_sig <= x"ED";
            when x"6E" => a0_sig <= x"F2";
            when x"6F" => a0_sig <= x"F9";
            when x"60" => a0_sig <= x"00";
            when x"61" => a0_sig <= x"06";
            when x"62" => a0_sig <= x"0D";
            when x"63" => a0_sig <= x"12";
            when x"64" => a0_sig <= x"17";
            when x"65" => a0_sig <= x"1C";
            when x"66" => a0_sig <= x"1F";
            when x"67" => a0_sig <= x"22";
            when x"78" => a0_sig <= x"DD";
            when x"79" => a0_sig <= x"E0";
            when x"7A" => a0_sig <= x"E3";
            when x"7B" => a0_sig <= x"E6";
            when x"7C" => a0_sig <= x"EA";
            when x"7D" => a0_sig <= x"EF";
            when x"7E" => a0_sig <= x"F4";
            when x"7F" => a0_sig <= x"FA";
            when x"70" => a0_sig <= x"00";
            when x"71" => a0_sig <= x"05";
            when x"72" => a0_sig <= x"0B";
            when x"73" => a0_sig <= x"10";
            when x"74" => a0_sig <= x"15";
            when x"75" => a0_sig <= x"19";
            when x"76" => a0_sig <= x"1C";
            when x"77" => a0_sig <= x"1F";
            when others => a0_sig <= x"00";
        end case;
	end process;

end Behavioral;
