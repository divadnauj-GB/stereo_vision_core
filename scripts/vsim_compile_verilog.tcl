#!/usr/bin/tclsh
set Core_Generic_root "."
quit -sim

exec vlib work
#exec vmap gpgpu work

vlog -64 -work work "$Core_Generic_root/stereo_match.v"

vcom -64 -2008 -work work "$Core_Generic_root/Stereo_Match_VHDL/SHD/funciones_pkg.vhd"
vcom -64 -2008 -work work "$Core_Generic_root/TestBench/Stereo_Match_verilog_tb.vhd"
#vsim -64 -voptargs=+acc work.stereo_match_tb
vsim -f vsim_config.txt
#vsim -voptargs=+acc work.tb_top_level

#vcd dumpports -file ../../Test_Programs/dumpports_SMP.evcd sim:/tb_top_level/uGPGPU/uStreamingMultiProcessor/*

#force -freeze tb_top_level/uGPGPU/uStreamingMultiProcessor/uPipelineExecute/uSpecialFunctionUnitProcessor/gSpecialFunctionUnit(0)/uSpecialFunctionUnit/s_in_sign 0

do ./vsim_waveforms.do
#do wave_custom_JDGB_fault_list.do
# do wave.do
run -all

quit
