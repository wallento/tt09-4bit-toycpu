# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer
from cocotb.binary import BinaryValue
from cocotb.types import LogicArray, Range, Logic

async def fetch(dut, inst, data):
    #assert dut.uio_oe == "00000000"
    dut.uio_in.value = LogicArray(inst + data)
    await ClockCycles(dut.clk, 10)    
    dut.ui_in[0].value = 1
    await ClockCycles(dut.clk, 10)

async def scan(dut):
    data = LogicArray("x"*19)
    dut.ui_in[3].value = 1
    await ClockCycles(dut.clk, 10)
    for i in range(0,19):
        await ClockCycles(dut.clk, 10)
        dut.ui_in[2].value = 1
        await ClockCycles(dut.clk, 10)
        dut.ui_in[3].value = 0
        try:
            data[i] = dut.uo_out[5].value.integer
        except ValueError:
            data[i] = 0
        dut.ui_in[2].value = 0
    return {
        "instruction_register": data[18:15].binstr,
        "data_register": data[14:11].binstr,
        "accumulator": data[10:7].binstr,
        "C": data[6:6].binstr,
        "Z": data[5:5].binstr,
        "N": data[4:4].binstr,
        "program_counter": data[3:0].binstr
    }

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Reset
    dut._log.info("CPU Reset")
    dut.ui_in[1].value = 1
    await ClockCycles(dut.clk, 10)
    dut.ui_in[0].value = 1
    await ClockCycles(dut.clk, 10)
    dut.ui_in[1].value = 0
    await ClockCycles(dut.clk, 10)
    dut.ui_in[0].value = 0
    
    # Test
    await fetch(dut, inst="0001", data="0011")
    print(await scan(dut))
    await ClockCycles(dut.clk, 10)    
    dut.ui_in[0].value = 0
    await ClockCycles(dut.clk, 10)    
    print(await scan(dut))

    await fetch(dut, inst="0100", data="1111")
    print(await scan(dut))
    await ClockCycles(dut.clk, 10)    
    dut.ui_in[0].value = 0
    await ClockCycles(dut.clk, 10)    
    print(await scan(dut))


    await fetch(dut, inst="0011", data="1111")
    print(await scan(dut))
    await ClockCycles(dut.clk, 10)
    assert dut.uo_out[4].value == 1
    dut.ui_in[4].value = 1
    await ClockCycles(dut.clk, 10)
    assert dut.uio_out.value == "00000010"
    dut.ui_in[4].value = 1
    await ClockCycles(dut.clk, 10)
    dut.ui_in[0].value = 0
    await ClockCycles(dut.clk, 10)    
    print(await scan(dut))



    


