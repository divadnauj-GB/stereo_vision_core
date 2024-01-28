onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /stereo_match_tb/si_clk

add wave -noupdate -group TB /stereo_match_tb/si_clk
add wave -noupdate -group TB /stereo_match_tb/si_rst
add wave -noupdate -group TB /stereo_match_tb/si_dato_L
add wave -noupdate -group TB /stereo_match_tb/si_dato_R
add wave -noupdate -group TB /stereo_match_tb/si_dval
add wave -noupdate -group TB /stereo_match_tb/si_Tresh_LRCC
add wave -noupdate -group TB /stereo_match_tb/so_dval
add wave -noupdate -group TB /stereo_match_tb/so_dato
