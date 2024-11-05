#!/usr/bin/env bash

set -e

cd $(dirname "$0")

PWD="$(pwd)"

# NEORV32 home folder
HOME=${PWD}
# Additional sources (i.e. the top unit)
SRC_FOLDER=${PWD}/Stereo_Match_VHDL
#Name of the top unit
TOP=Stereo_Match

mkdir -p build

# show NEORV32 version
echo "STEREO CORE Version:"
echo ""
sleep 2

# Import and analyze sources
ghdl -i --std=08 --work=work --workdir=build -Pbuild $SRC_FOLDER/SHD/*.vhd $SRC_FOLDER/Census/*.vhd $SRC_FOLDER/LRCC/*.vhd $SRC_FOLDER/$TOP.vhd
ghdl -m --std=08 --work=work --workdir=build $TOP
# Synthesize Verilog
ghdl synth --std=08 --work=work --workdir=build -Pbuild --out=verilog $TOP > $SRC_FOLDER/$TOP.v

# Show interface of generated Verilog module
echo ""
echo "-----------------------------------------------"
echo "Verilog instantiation prototype"
echo "-----------------------------------------------"
sed -n "/module $TOP/,/);/p" $SRC_FOLDER/$TOP.v
echo "-----------------------------------------------"
echo ""