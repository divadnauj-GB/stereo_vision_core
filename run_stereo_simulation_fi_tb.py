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
parser.add_argument('-M','--MaxImWidth', default=450, type=int, help='maximum image width')
parser.add_argument('-N','--Nbits', default=8, type=int, help='Number of bits per pixel')
parser.add_argument('-im','--image', default='Tsukuba', type=str, help='image: [Tsukuba, Cones, Teddy]')
parser.add_argument('-gv','--generate-verilog', default=False, type=lambda x: bool(int(x)), help='enable the elaboration from VHDL to verilog')
parser.add_argument('-simt','--simulation-tool', default='verilator', type=str, help='simulation tool: [verilator, cocotb+verilator, qsim+VHDL, qsim+verilog]')
parser.add_argument('-nt','--num-threads', default=4, type=int, help='num of threads for verilator simulation; default 4')


fi_structure={
    "modules":64, #64 components    
    "sr_lenght":21, # 21 bits in shift register 2bit config, 19bit different locations
    "f_model":1, # fault model: 0-> stuck-at-0, 1: stuck-at-1, 2: bit-flip
    "component": 16,
    "bit_pos":17
}


def fault_list():
    modules=fi_structure['modules']
    sr_leght = fi_structure['sr_lenght']
    component=fi_structure['component']
    bit=fi_structure['bit_pos']
    f_cntrl=fi_structure['f_model']
    with(open("./fi_work/fault_descriptor.txt","w")) as file:
        file.write(f"{modules}\n")
        file.write(f"{component}\n")
        file.write(f"{sr_leght}\n")
        for idx in range(fi_structure['sr_lenght']-2):
            if idx==bit:
                file.write(f"{1}\n")
            else:
                file.write(f"{0}\n")
        for idx in range(0,2):
            file.write(f"{f_cntrl&1}\n")
            f_cntrl=f_cntrl>>1

def main():
    # this are the configuration parameters of the accelerator passed trought the TB
    args=parser.parse_args()
    D=args.Disparity
    Wc=args.Wcensus
    Wh=args.Whamming
    N=args.Nbits
    M=args.MaxImWidth

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

    fault_list()
    command = "rm -R ./work"
    print(command)
    os.system(command)

    os.system(f"mkdir -p fi_work")

    # This function serializes the images to make them compatible with the accelerator processing architecture

    Image_input_test.serialize_stereo_images(Left_image=Left_image,Right_image=Right_image,M=M)

    if args.simulation_tool=='verilator':
        os.chdir(os.path.join(os.getcwd(),"fi_work"))        
        command = f"./obj_dir/VStereo_Match"
        print(command)
        os.system(command)
        os.chdir("..")
    
    else:
        
        os.chdir(os.path.join(os.getcwd(),"fi_work"))
        command = f"./obj_dir/VStereo_Match"
        print(command)
        os.system(command)
        os.chdir("..")
    #os.chdir("..")

    # This function takes the output results of the simulation and create the disparity map result as image
    Image_result_test.create_disparity_map(N_filas,M,3,Thresh)

    # removing parameters from previous configurations:
    File_path=os.getcwd()
    print(File_path)
    os.system("rm *.txt")


if __name__=='__main__':
    main()
