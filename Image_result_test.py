import torch
import torchvision

(num_channels, N_filas, N_columnas)=(1,288 , 384)


Vector_left=[]
Vector_right=[]
Vector_valid=[]

with open("output_vector_data.txt",'r') as FIDR, open("output_vector_valid.txt",'r') as FIDV:
    Data = FIDR.readlines()
    valid = FIDV.readlines()


Output_image=torch.zeros(num_channels, N_filas, N_columnas)
i=0
j=0
for k in range(0,len(valid)):
    if int(valid[k])==1:
        Output_image[(0,i,j)]=int(Data[k])
        j=j+1
        if j==N_columnas:
            j=0
            i=i+1
            if i==N_filas:
                i=N_filas-1


result=Output_image*255/48
print(Output_image.max())
output_file=result.to(torch.uint8)
print(output_file.max())
torchvision.io.write_png(output_file,"Disparity_map.png")