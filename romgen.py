ADDRBITS = 8
DATABITS = 8

SCREENW = 40
SCREENH = 6

def makerom():
	# Load the input (ROM)
	with open("./input.txt") as f:
		inp = [line.strip() for line in f.readlines()]

	ROM = []
	for i in inp:
		i = i.split(' ')
		if i[0] == 'noop':
			ROM.append(0)
		elif i[0] == 'addx':
			ROM.append(0)
			ROM.append(int(i[1]))

	# 4'b0000 : data = 7'b1000000; // 0

	romstr = ""
	for i,d in enumerate(ROM):
		n = d if d >= 0 else 255+d
		romstr += f"\t\t{ADDRBITS}'d{i} : data = {d};\n"
		
	# print(romstr)

	VERILOG = f"""
module ROM (
	input wire [addr_bits-1:0] addr,
	output reg [data_width-1:0] data,  // reg (not wire)
	output wire [7:0] screen_w,
	output wire [7:0] screen_h
);
parameter addr_bits = {ADDRBITS},
		  data_width = {DATABITS};

assign screen_w = 8'd{SCREENW};
assign screen_h = 8'd{SCREENH};

always_comb
begin
	case(addr)
{romstr}\t\tdefault : data = 8'b00000000;
	endcase 
end

endmodule
"""

	with open("./src/ROM.sv", 'w') as f:
		f.write(VERILOG)
  
	# print("Successfully created ROM.v!")
	return ROM
  
if __name__ == '__main__':
    makerom()