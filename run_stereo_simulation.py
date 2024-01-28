import os
import filecmp
import subprocess

import numpy as np 
from PIL import Image

import Image_input_test
import Image_result_test

command = "rm -R ./work"
print(command)
os.system(command)


Left_image = np.array(Image.open("./imL.png").convert('L'))
Right_image = np.array(Image.open("./imR.png").convert('L'))

im_shape=Left_image.shape

im_shape=Left_image.shape
if len(im_shape)<3:
    (N_filas, N_columnas)=im_shape
    num_channels = 0
else:
    (N_filas, N_columnas, num_channels)=im_shape
    
print(im_shape)

Image_input_test.serialize_stereo_images(Left_image=Left_image,Right_image=Right_image)

command = "vsim -c -do vsim_compile.tcl"
print(command)
os.system(command)

Image_result_test.create_disparity_map(N_filas,N_columnas,3)

# removing parameters from previous configurations:
File_path=os.getcwd()
print(File_path)