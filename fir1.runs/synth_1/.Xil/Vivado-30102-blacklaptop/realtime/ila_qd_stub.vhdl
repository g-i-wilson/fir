-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_qd is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe1 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe2 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe3 : in STD_LOGIC_VECTOR ( 15 downto 0 )
  );

end ila_qd;

architecture stub of ila_qd is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "ila,Vivado 2020.1";
begin
end;
