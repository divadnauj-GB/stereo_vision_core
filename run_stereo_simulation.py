import os
import filecmp
import subprocess

import numpy as np 
from PIL import Image

import Image_input_test
import Image_result_test

# this are the configuration parameters of the accelerator passed trought the TB
D=48
Wc=7
Wh=13
N=8

# These are the input images to be evaluated

Left_image = np.array(Image.open("./im2.png").convert('L'))
Right_image = np.array(Image.open("./im6.png").convert('L'))

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


# Here I create the configuration file that resize the accelerator according to the width of the input image
with open("vsim_config.txt","w") as vsim_config:
    vsim_config.write(f"-64 -voptargs=+acc -gD={D} -gM={N_columnas} work.stereo_match_tb")

# this command launch the simulation in modelsim
command = "vsim -c -do vsim_compile.tcl"
print(command)
os.system(command)


# This function takes the output results of the simulation and create the disparity map result as image
Image_result_test.create_disparity_map(N_filas,N_columnas,3)

# removing parameters from previous configurations:
File_path=os.getcwd()
print(File_path)