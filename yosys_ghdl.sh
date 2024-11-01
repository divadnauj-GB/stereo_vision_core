D=48
Wc=7
Wh=13
M=384
N=8


#!/bin/bash
PWD="$(pwd)"

rm -r build
mkdir -p build
# Additional sources (i.e. the top unit)
SRC_FOLDER=${PWD}/Stereo_Match_VHDL
# Define the top-level entity name
TOP_MODULE="Stereo_Match"  # Replace with your actual top-level entity name

# Create a new Yosys script
cat > synth_generated.ys << EOF
# File: synth_generated.ys

# Read all VHDL files with GHDL
EOF

cmd="ghdl --std=08 --work=work --workdir=build -gD=${D} -gWc=${Wc} -gWh=${Wh} -gM=${M} -gN=${N} -Pbuild"

for pkg_file in $(find ${SRC_FOLDER} -type f -name "*_pkg.vhd" | sort); do
    cmd+=" $pkg_file"
done

# Add all .vhdl files to the script dynamically
for vhdl_file in $(find ${SRC_FOLDER} -type f -name "*.vhd" ! -name "*_pkg.vhd" | sort); do
    cmd+=" $vhdl_file"
done

cmd+=" -e $TOP_MODULE"
echo ${cmd} >> synth_generated.ys
echo "write_verilog -renameprefix ghdl_gen $TOP_MODULE.v" >> synth_generated.ys
#echo "hierarchy -check -top $TOP_MODULE"
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
yosys -m ghdl -s synth_generated.ys

# Clean up the generated script if you don't need it afterwards
rm synth_generated.ys

echo "read_verilog $TOP_MODULE.v" >> synth_generated.ys
echo "proc" >> synth_generated.ys
echo "write_json $TOP_MODULE.json" >> synth_generated.ys

yosys -s synth_generated.ys
rm synth_generated.ys