
import os
import filecmp
import subprocess



# removing parameters from previous configurations:
File_path=os.getcwd()
print(File_path)

"""
print("rm -R ./TestBench/run")
os.system("rm -R ./TestBench/run")
print("mkdir ./TestBench/run")
os.system("mkdir ./TestBench/run")

command="cp ./Kernel_GPU_RTL/global_mem.mif ./GenericDesign_RTL/ML605_Top"
print(command)
os.system(command)

command="cp ./GenericDesign_RTL/ML605_Top/global_mem.mif ./TestBench/run"
print(command)
os.system(command)

command="cp ./GenericDesign_RTL/ML605_Top/constant_mem.mif ./TestBench/run"
print(command)
os.system(command)

command="cp ./GenericDesign_RTL/ML605_Top/system_mem.mif ./TestBench/run"
print(command)
os.system(command)


os.chdir("./TestBench/run")
"""
command = "vsim -c -do vsim_compile.tcl"
print(command)
os.system(command)

# os.system("cp ./gpgpu_rdata.log ../../Kernel_GPU_RTL")
# os.system("cp ./vsim.wlf ../../Kernel_GPU_RTL")
# os.system("cp ../wave_custom_JDGB.do ../../Kernel_GPU_RTL")


