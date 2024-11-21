if [[ -z "${MODULE}" ]]; then
  MODULE="disp_cmp_13_64_7"
else
  MODULE="${MODULE}"
fi

if [[ -z "${TOP_MODULE}" ]]; then
  TOP_MODULE="Stereo_Match"
else
  TOP_MODULE="${TOP_MODULE}"
fi


echo "read_verilog $TOP_MODULE.v" >> synth_generated.ys
echo "hierarchy -check -top ${MODULE}" >> synth_generated.ys
echo "proc; opt; memory; opt; fsm; opt" >> synth_generated.ys
echo "techmap; opt" >> synth_generated.ys
#echo "splitnets -driver" >> synth_generated.ys
echo "opt_clean -purge" >> synth_generated.ys
echo "check" >> synth_generated.ys
echo "clean" >> synth_generated.ys
echo "write_verilog -noattr -simple-lhs -renameprefix _nw ${MODULE}.v" >> synth_generated.ys

yosys -s synth_generated.ys
rm synth_generated.ys