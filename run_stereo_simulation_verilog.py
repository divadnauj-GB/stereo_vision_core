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
        Thresh=64 # Factor 4 for rendering the image 255/4=64
    if image=="Teddy":
        Thresh=64 # Factor 4 for rendering the image 255/4=64
    if image=="Venus":
        Thresh=32 # Factor 8 for rendering the image 255/8=32
        
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

    os.system(f"export D={D} M={N_columnas}; bash scripts/yosys_ghdl.sh ")

    # Here I create the configuration file that resize the accelerator according to the width of the input image
    with open("vsim_config.txt","w") as vsim_config:
        vsim_config.write(f"-64 -voptargs=+acc -gD={D} -gM={N_columnas} work.stereo_match_tb")

    # this command launch the simulation in modelsim
    command = "vsim -c -do scripts/vsim_compile_verilog.tcl"
    print(command)
    os.system(command)


    # This function takes the output results of the simulation and create the disparity map result as image
    Image_result_test.create_disparity_map(N_filas,N_columnas,3,Thresh)

    # removing parameters from previous configurations:
    File_path=os.getcwd()
    print(File_path)
    os.system("rm *.txt")

if __name__=='__main__':
    main()