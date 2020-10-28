// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
// Date        : Wed Oct 28 13:47:58 2020
// Host        : blacklaptop running 64-bit Ubuntu 18.04.5 LTS
// Command     : write_verilog -force -mode synth_stub /home/gwrw/fir1/fir1.srcs/sources_1/ip/ila_0/ila_0_stub.v
// Design      : ila_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "ila,Vivado 2020.1" *)
module ila_0(clk, probe0, probe1, probe2, probe3)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[7:0],probe1[7:0],probe2[7:0],probe3[15:0]" */;
  input clk;
  input [7:0]probe0;
  input [7:0]probe1;
  input [7:0]probe2;
  input [15:0]probe3;
endmodule
