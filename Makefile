# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/src/crt.v
VERILOG_SOURCES += $(PWD)/src/ROM.v
VERILOG_SOURCES += $(PWD)/src/main.v
VERILOG_SOURCES += $(PWD)/src/vga_drv.v
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = crt

# MODULE is the basename of the Python test file
MODULE = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim