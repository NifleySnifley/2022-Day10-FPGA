# Makefile to build UPduino v3.0 rgb_blink.v  with icestorm toolchain
# Original Makefile is taken from: 
# https://github.com/tomverbeure/upduino/tree/master/blink
# On Linux, copy the included upduinov3.rules to /etc/udev/rules.d/ so that we don't have
# to use sudo to flash the bit file.
# Thanks to thanhtranhd for making changes to thsi makefile.

main.bin: main.asc
	icepack main.asc main.bin

main.asc: main.json ./upduino.pcf
	nextpnr-ice40 --up5k --package sg48 --json main.json --pcf ./upduino.pcf --asc main.asc   # run place and route

main.json: main.sv ROM.sv clock_480p.sv simple_480p.sv
	yosys -q -p "synth_ice40 -json main.json" main.sv ROM.sv clock_480p.sv simple_480p.sv

.PHONY: flash
flash:
	iceprog -d i:0x0403:0x6014 main.bin

.PHONY: clean
clean:
	$(RM) -f main.json main.asc main.bin