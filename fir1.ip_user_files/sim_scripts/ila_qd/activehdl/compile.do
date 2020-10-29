vlib work
vlib activehdl

vlib activehdl/xpm
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../../fir1.srcs/sources_1/ip/ila_qd/hdl/verilog" \
"/home/gwrw/Xilinx/Vivado/2020.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/home/gwrw/Xilinx/Vivado/2020.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"/home/gwrw/Xilinx/Vivado/2020.1/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../fir1.srcs/sources_1/ip/ila_qd/sim/ila_qd.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

