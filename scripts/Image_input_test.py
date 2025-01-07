# import torch
# import torchvision
import numpy as np 
from PIL import Image



# Left_image = np.array(Image.open("./imL.png").convert('L'))
# Right_image = np.array(Image.open("./imR.png").convert('L'))


def serialize_stereo_images(Left_image,Right_image,M):

    #Left_image=torchvision.io.read_image("./imL.png",torchvision.io.ImageReadMode.GRAY)
    #right_image=torchvision.io.read_image("./imR.png",torchvision.io.ImageReadMode.GRAY)

    im_shape=Left_image.shape
    if len(im_shape)<3:
        (N_filas, N_columnas)=im_shape
        num_channels = 0
    else:
        (N_filas, N_columnas, num_channels)=im_shape
        
    print(im_shape)


    Vector_left=[]
    Vector_right=[]
    Vector_valid=[]


    for i in range(0,10*M):
        Vector_left.append(0)
        Vector_right.append(0)
        Vector_valid.append(0)
        
    for i in range(0,N_filas):
        for j in range(0,M):
            if j<N_columnas:
                if num_channels!=0:
                    Vector_left.append(Left_image[(i,j,0)])
                    Vector_right.append(Right_image[(i,j,0)])
                else:
                    Vector_left.append(Left_image[(i,j)])
                    Vector_right.append(Right_image[(i,j)])
            else:
                Vector_left.append(0)
                Vector_right.append(0)
            Vector_valid.append(1)
        Vector_left.append(0)
        Vector_right.append(0)
        Vector_valid.append(0)
            
    for i in range(0,30*M): #(10*N_columnas+N_columnas*N_filas):(10*N_columnas+N_columnas*N_filas+10*N_columnas)
        Vector_left.append(0)
        Vector_right.append(0)
        Vector_valid.append(1)

    for i in range(0,20*M): #(10*N_columnas+N_columnas*N_filas):(10*N_columnas+N_columnas*N_filas+10*N_columnas)
        Vector_left.append(0)
        Vector_right.append(0)
        Vector_valid.append(0)


    with open("input_vector_left_image.txt",'w') as FIDL, open("input_vector_right_image.txt",'w') as FIDR, open("input_vector_valid.txt",'w') as FIDV:
        for index in range(len(Vector_valid)):
            FIDL.write(f"{Vector_left[index]}\n")
            FIDR.write(f"{Vector_right[index]}\n")
            FIDV.write(f"{Vector_valid[index]}\n")  
