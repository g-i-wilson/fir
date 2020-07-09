--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
--Date        : Thu Jul  9 13:53:58 2020
--Host        : black-computer running 64-bit Ubuntu 18.04.4 LTS
--Command     : generate_target design_2_wrapper.bd
--Design      : design_2_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_2_wrapper is
end design_2_wrapper;

architecture STRUCTURE of design_2_wrapper is
  component design_2 is
  end component design_2;
begin
design_2_i: component design_2
 ;
end STRUCTURE;
