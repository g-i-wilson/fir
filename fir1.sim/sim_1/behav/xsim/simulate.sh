#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2020.1 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Fri Jul 31 10:44:42 CDT 2020
# SW Build 2902540 on Wed May 27 19:54:35 MDT 2020
#
# Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
echo "xsim test_values_tb_behav -key {Behavioral:sim_1:Functional:test_values_tb} -tclbatch test_values_tb.tcl -log simulate.log"
xsim test_values_tb_behav -key {Behavioral:sim_1:Functional:test_values_tb} -tclbatch test_values_tb.tcl -log simulate.log

