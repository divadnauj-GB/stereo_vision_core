

if [[ -z "${D}" ]]; then
  D=48
else
  D="${D}"
fi

if [[ -z "${Wc}" ]]; then
  Wc=7
else
  Wc="${Wc}"
fi

if [[ -z "${Wh}" ]]; then
  Wh=13
else
  Wh="${Wh}"
fi

if [[ -z "${M}" ]]; then
  M=384
else
  M="${M}"
fi

if [[ -z "${N}" ]]; then
  N=8
else
  N="${N}"
fi


#!/bin/bash
PWD="$(pwd)"

rm -r build
mkdir -p build
# Additional sources (i.e. the top unit)
SRC_FOLDER=${PWD}/stereo_match_verilog
# Define the top-level entity name
TOP_MODULE="stereo_match"  # Replace with your actual top-level entity name

# Create a new Yosys script
cat > synth_generated.ys << EOF
# File: synth_generated.ys

# Read all VHDL files with GHDL
EOF

cmd="read_verilog -defer "

for verilog_file in $(find ${SRC_FOLDER} -type f -name "*.v" | sort); do
    cmd+=" $verilog_file"
done

echo ${cmd} >> synth_generated.ys
echo "chparam -set D $D" $TOP_MODULE>> synth_generated.ys
echo "chparam -set WC $Wc $TOP_MODULE" >> synth_generated.ys
echo "chparam -set WH $Wh $TOP_MODULE" >> synth_generated.ys
echo "chparam -set M $M $TOP_MODULE" >> synth_generated.ys
echo "chparam -set N $N $TOP_MODULE" >> synth_generated.ys
echo "hierarchy -check -top $TOP_MODULE" >> synth_generated.ys
echo "proc; opt; memory; opt; fsm; opt" >> synth_generated.ys
echo "opt_clean -purge" >> synth_generated.ys
echo "write_verilog -noattr -simple-lhs -renameprefix rtil_signal $TOP_MODULE.v" >> synth_generated.ys
echo "exit">> synth_generated.ys

# Elaborate the top-level entity
# echo "ghdl -e $TOP_MODULE" >> synth_generated.ys

# Add synthesis and netlist output commands
cat >> synth_generated.ys << EOF

# Synthesize the top module
# synth -top $TOP_MODULE

# Write the synthesized netlist to a Verilog file
# write_verilog synthesized_netlist.v
EOF

# Run the generated Yosys script
yosys -s synth_generated.ys

# Clean up the generated script if you don't need it afterwards
rm synth_generated.ys

echo "read_verilog $TOP_MODULE.v" >> synth_generated.ys
echo "proc" >> synth_generated.ys
echo "write_json $TOP_MODULE.json" >> synth_generated.ys

yosys -s synth_generated.ys
rm synth_generated.ys
