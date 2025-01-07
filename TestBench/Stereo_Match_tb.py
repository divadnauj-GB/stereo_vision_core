# test_my_design.py (extended)

import cocotb
from cocotb.triggers import FallingEdge, Timer
from cocotb.clock import Clock

import numpy as np 



async def generate_clock(dut,clocks):
    """Generate clock pulses."""

    for cycle in range(clocks):
        dut.i_clk.value = 0
        await Timer(10, units="ns")
        dut.i_clk.value = 1
        await Timer(10, units="ns")


@cocotb.test()
async def test_stereo_dataset(dut):
    """Try accessing the design."""
    # this are the configuration parameters of the accelerator passed trought the TB
    
    with (open("../input_vector_left_image.txt",'r')) as fp:
        Vector_left=fp.readlines()
    with (open("../input_vector_right_image.txt",'r')) as fp:
        Vector_right=fp.readlines()
    with (open("../input_vector_valid.txt",'r')) as fp:
        Vector_valid=fp.readlines()
    
    #await cocotb.start(generate_clock(dut,len(Vector_valid)+1000))  # run the clock "in the background"
    cocotb.start_soon(Clock(dut.i_clk, 1, units="ns").start())
    
    dut.i_rstn.value=0
    dut.i_data_l.value=0
    dut.i_data_r.value=0
    dut.i_dval.value=0
    dut.i_thresh_lrcc.value=8
    
    await Timer(10, units="ns")  # wait a bit
    await FallingEdge(dut.i_clk)  # wait for falling edge/"negedge"
    
    dut.i_rstn.value=1
    await FallingEdge(dut.i_clk) 
    
    
    with open("../output_vector_data.txt","w") as fp_data, open("../output_vector_valid.txt","w") as fp_valid:
        for i in range(len(Vector_valid)):
        #for i in range(500):
            dut.i_data_l.value=int(Vector_left[i])
            dut.i_data_r.value=int(Vector_right[i])
            dut.i_dval.value=int(Vector_valid[i])
            await FallingEdge(dut.i_clk)
            fp_data.write(f"{int(dut.o_data.value)}\n")
            fp_valid.write(f"{int(dut.o_dval.value)}\n")

    