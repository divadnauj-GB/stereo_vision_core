#!/usr/bin/tclsh
set Core_Generic_root "."
quit -sim

exec vlib work
#exec vmap gpgpu work

set gpgpu_vhdls [list \
	"# SHD" \
	"$Core_Generic_root/Stereo_Match_VHDL/SHD/funciones_pkg.vhd" \
	"$Core_Generic_root/Stereo_Match_VHDL/SHD/Num_of_ones.vhd" \
	"$Core_Generic_root/Stereo_Match_VHDL/SHD/Disp_Cmp.vhd" \
	"$Core_Generic_root/Stereo_Match_VHDL/SHD/Window_sum.vhd" \
	"$Core_Generic_root/Stereo_Match_VHDL/SHD/SHD.vhd" \
	"# Census" \
	"$Core_Generic_root/Stereo_Match_VHDL/Census/Census_Transform.vhd" \
	"# LRCC" \
	"$Core_Generic_root/Stereo_Match_VHDL/LRCC/LRCC.vhd" \
	"# Top" \
	"$Core_Generic_root/Stereo_Match_VHDL/stereo_match.vhd" \
	"# TB" \
	"$Core_Generic_root/TestBench/Stereo_Match_tb.vhd" \
]

foreach src $gpgpu_vhdls {
	if [expr {[string first # $src] eq 0}] {puts $src} else {
		#exec >@stdout 2>@stderr
		vcom -64 -2008 -work work $src
	}
}

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
