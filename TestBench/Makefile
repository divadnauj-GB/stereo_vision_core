# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

# Makefile

# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

EXTRA_ARGS += -max-num-width 80000 --trace --trace-depth 1 -Wno-UNOPTFLAT

VERILOG_SOURCES += $(PWD)/../Stereo_Match.v
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = Stereo_Match

# MODULE is the basename of the Python test file
MODULE = Stereo_Match_tb

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
