# Advent of Code 2022 Day 10: FPGA visualization

HDL and scripts for part two of day 10 using a FPGA (ICE40UP5K, Upduino) and 1-bit color 480p VGA.

## Contents

- `src/`: HDL for the visualization, VGA, etc.
- `sim/`: Simulator and visualization using cocotb
- `romgen.py`: Converts the day's input (`input.txt`) into a Verilog mock-ROM.
