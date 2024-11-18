import os
import filecmp
import subprocess


import numpy as np 
from PIL import Image

import scripts.Image_input_test as Image_input_test
import scripts.Image_result_test as Image_result_test

import argparse
parser = argparse.ArgumentParser(description='Stereo Vision Core Simulation')
parser.add_argument('-D','--Disparity', default=64, type=int, help='disparity levels')
parser.add_argument('-Wc','--Wcensus', default=7, type=int, help='Census window size')
parser.add_argument('-Wh','--Whamming', default=13, type=int, help='Hamming window size')
parser.add_argument('-N','--Nbits', default=8, type=int, help='Number of bits per pixel')
parser.add_argument('-im','--image', default='Tsukuba', type=str, help='image: [Tsukuba, Cones, Teddy]')
parser.add_argument('-gv','--generate-verilog', default=False, type=lambda x: bool(int(x)), help='enable the elaboration from VHDL to verilog')
parser.add_argument('-simt','--simulation-tool', default='verilator', type=str, help='simulation tool: [verilator, cocotb+verilator, qsim+VHDL, qsim+verilog]')


def main():
    # this are the configuration parameters of the accelerator passed trought the TB
    args=parser.parse_args()
    D=args.Disparity
    Wc=args.Wcensus
    Wh=args.Whamming
    N=args.Nbits

    image=args.image
    # These are the input images to be evaluated
    if image=="Tsukuba":
        Thresh=32 # Factor 8 for rendering the image 255/8=32
    if image=="Cones":
        Thresh=64  # Factor 4 for rendering the image 255/4=64
    if image=="Teddy":
        Thresh=64 # Factor 4 for rendering the image 255/4=64
    if image=="Venus":
        Thresh=32  # Factor 8 for rendering the image 255/8=32
    # These are the input images to be evaluated

    Left_image = np.array(Image.open(f"./dataset/{image}L.png").convert('L'))
    Right_image = np.array(Image.open(f"./dataset/{image}R.png").convert('L'))

    im_shape=Left_image.shape

    im_shape=Left_image.shape
    if len(im_shape)<3:
        (N_filas, N_columnas)=im_shape
        num_channels = 0
    else:
        (N_filas, N_columnas, num_channels)=im_shape
        
    print(im_shape)


    command = "rm -R ./work"
    print(command)
    os.system(command)

    # This function serializes the images to make them compatible with the accelerator processing architecture

    Image_input_test.serialize_stereo_images(Left_image=Left_image,Right_image=Right_image)
    print(args.generate_verilog)
    if (args.generate_verilog==True) and (args.simulation_tool=='cocotb+verilator' or args.simulation_tool=='verilator' or args.simulation_tool=='qsim+verilog'):
        os.system(f"export D={D} M={N_columnas}; bash scripts/yosys_ghdl.sh ")        

    #os.chdir(os.path.join(os.getcwd(),"TestBench"))
    # this command launch the simulation in modelsim

    if args.simulation_tool=='verilator':
        os.chdir(os.path.join(os.getcwd(),"TestBench"))
        command = "verilator -max-num-width 80000 --trace --trace-depth 1 --cc ../Stereo_Match.v --exe Stereo_Match_tb.cpp; make -C obj_dir -f VStereo_Match.mk VStereo_Match; ./obj_dir/VStereo_Match"
        print(command)
        os.system(command)
        os.chdir("..")
    elif args.simulation_tool=='cocotb+verilator':
        os.chdir(os.path.join(os.getcwd(),"TestBench"))
        # this command launch the simulation in modelsim
        command = "make"
        print(command)
        os.system(command)
        os.chdir("..")
    elif args.simulation_tool=='qsim+verilog':
        # Here I create the configuration file that resize the accelerator according to the width of the input image
        with open("vsim_config.txt","w") as vsim_config:
            vsim_config.write(f"-64 -voptargs=+acc -gD={D} -gM={N_columnas} work.stereo_match_tb")
        # this command launch the simulation in modelsim
        command = "vsim -c -do scripts/vsim_compile_verilog.tcl"
        print(command)
        os.system(command)
    elif args.simulation_tool=='qsim+VHDL':
        # Here I create the configuration file that resize the accelerator according to the width of the input image
        with open("vsim_config.txt","w") as vsim_config:
            vsim_config.write(f"-64 -voptargs=+acc -gD={D} -gM={N_columnas} work.stereo_match_tb")

        # this command launch the simulation in modelsim
        command = "vsim -c -do ./scripts/vsim_compile.tcl"
        print(command)
        os.system(command)
    else:
        os.system(f"export D={D} M={N_columnas}; bash scripts/yosys_ghdl.sh ")
        command = "verilator -max-num-width 80000 --trace --trace-depth 1 --cc ../Stereo_Match.v --exe Stereo_Match_tb.cpp; make -C obj_dir -f VStereo_Match.mk VStereo_Match; ./obj_dir/VStereo_Match"
        print(command)
        os.system(command)
    #os.chdir("..")

    # This function takes the output results of the simulation and create the disparity map result as image
    Image_result_test.create_disparity_map(N_filas,N_columnas,3,Thresh)

    # removing parameters from previous configurations:
    File_path=os.getcwd()
    print(File_path)
    #os.system("rm *.txt")


if __name__=='__main__':
    main()