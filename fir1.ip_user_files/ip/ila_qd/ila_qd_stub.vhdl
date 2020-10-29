-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
-- Date        : Thu Oct 29 14:01:23 2020
-- Host        : blacklaptop running 64-bit Ubuntu 18.04.5 LTS
-- Command     : write_vhdl -force -mode synth_stub /home/gwrw/fir1/fir1.srcs/sources_1/ip/ila_qd/ila_qd_stub.vhdl
-- Design      : ila_qd
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_qd is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe1 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe2 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe3 : in STD_LOGIC_VECTOR ( 11 downto 0 )
  );

end ila_qd;

architecture stub of ila_qd is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[7:0],probe1[7:0],probe2[7:0],probe3[11:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "ila,Vivado 2020.1";
begin
end;
