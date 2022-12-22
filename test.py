# Write to ROM.v
from romgen import makerom, SCREENW, SCREENH
ROM = makerom()

import cocotb
from cocotb.triggers import Timer, RisingEdge, ReadOnly, FallingEdge
from cocotb.result import TestFailure, ReturnValue


dbgstr = ""
def dbg_print(*msgs, end='\n'):
    global dbgstr
    dbgstr += " ".join([str(msg) for msg in msgs]) + end

def dbg_dump():
    global dbgstr
    print(dbgstr, end='')

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(SCREENW*SCREENH+1):
        print('██' if dut.signal.value else '  ', end=('\n' if ((cycle+1)%SCREENW) == 0 else ''))
        
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")
        dut.clk.value = 0
   
        dbg_print(int(dut.DEBUG.value))

# # @cocotb.coroutine
# async def handle_rom_read(dut):
#     while (True):
#         await RisingEdge(dut.rom_req_read)
#         raddr = int(dut.rom_addr.value)
#         dut.rom_data.value = ROM[raddr] if raddr < len(ROM) else 0
#         dut.rom_ready.value = 1
#         await Timer(1, units="ns")
#         dut.rom_ready.value = 0

@cocotb.test()
async def my_second_test(dut):
	"""Try accessing the design."""

	await cocotb.start(generate_clock(dut))  # run the clock "in the background"
	# await cocotb.start(handle_rom_read(dut))

	await Timer(SCREENW*SCREENH*2, units="ns")  # wait a bit
	await FallingEdge(dut.clk)  # wait for falling edge/"negedge"

	# dbg_dump()