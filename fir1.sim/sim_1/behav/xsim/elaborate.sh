#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2020.1 (64-bit)
#
# Filename    : elaborate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for elaborating the compiled design
#
# Generated by Vivado on Fri Aug 21 13:46:19 CDT 2020
# SW Build 2902540 on Wed May 27 19:54:35 MDT 2020
#
# Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
#
# usage: elaborate.sh
#
# ****************************************************************************
set -Eeuo pipefail
echo "xelab -wto 1f4367962a4b4441b8e64d3ba15e400e --incr --debug typical --relax --mt 8 -L xil_defaultlib -L secureip --snapshot SerialTx_tb_behav xil_defaultlib.SerialTx_tb -log elaborate.log"
xelab -wto 1f4367962a4b4441b8e64d3ba15e400e --incr --debug typical --relax --mt 8 -L xil_defaultlib -L secureip --snapshot SerialTx_tb_behav xil_defaultlib.SerialTx_tb -log elaborate.log

