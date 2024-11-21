# import torch
# import torchvision
import numpy as np 
from PIL import Image



# Left_image = np.array(Image.open("./imL.png").convert('RGB'))
# 
# im_shape=Left_image.shape
# 
# (N_filas, N_columnas, num_channels)=im_shape

def create_disparity_map(N_filas, N_columnas, num_channels, Thresh=64):

    Vector_left=[]
    Vector_right=[]
    Vector_valid=[]

    with open("output_vector_data.txt",'r') as FIDR, open("output_vector_valid.txt",'r') as FIDV:
        Data = FIDR.readlines()
        valid = FIDV.readlines()

    tmp=[]
    Output_image=np.zeros((N_filas, N_columnas, num_channels))
    i=0
    j=0
    for k in range(0,len(valid)):
        if int(valid[k])==1:
            Output_image[(i,j,0)]=int(Data[k])
            Output_image[(i,j,1)]=int(Data[k])
            Output_image[(i,j,2)]=int(Data[k])
            j=j+1
            if j==N_columnas:
                j=0
                i=i+1
                if i==N_filas:
                    i=N_filas-1


    Output_image[Output_image>=Thresh]=0
    result=Output_image*255/(Output_image.max())
    print(Output_image.max())
    #output_file=result.to(torch.uint8)
    output_file=result.astype(np.uint8)
    print(output_file.max())
    #torchvision.io.write_png(output_file,"Disparity_map.png")

    im = Image.fromarray(output_file, mode="RGB")
    #im.save("Disparity_map.png")
    return(im)