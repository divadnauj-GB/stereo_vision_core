from class_wire_extraction import WireInfo
from f_define_new_wire import define_new_wire
from f_find_wire_name import find_wire_name
from f_insert_sabouter import insert_instances
from f_create_detailed_report import create_detailed_report
import shutil
import math

def inject_sabotuer(i_file):
    wire_list = []          # holds wire names and their bit number
    temp_wire_list = []     # holds new temporary wire names and their number of bits
    input_list = []         # list for input signals

# WRITE YOUR FILENAMES HERE (MODIFY ACCORDING TO YOUR DESIGN):
    filename = i_file                                    # the netlist
    new_filename = "with_sabotuer_" + i_file        # output: new netlist

# read line by line and save wire and input names with their number of bits into the list:
    lineNum = 0
    with open(filename, 'r') as file:
        for line_design in file:
            lineNum += 1
            if 'wire' in line_design:        # get signals defined as wire
                wire_info = WireInfo(line_design)         # send to class and get wire name and number of bits
                wire_info.lineNum = lineNum
                wire_list.append(wire_info)                       # append the list
            elif 'input' in line_design:    # get signals defined as input
                input_info = WireInfo(line_design)        # send to class and get input name and number of bits
                input_list.append(input_info)                     # append the list

    file.close()

    # delete input signals from the wire list. input signals will not be used for new signal definitions
    for x in input_list:
        for y in wire_list:
            if x.get_name() == y.get_name():
                wire_list.remove(y)
   
    for x in wire_list:
        print(f"Name: {x.get_name()} - Number of Bits: {x.get_numBit()}")

    # send each wire to the function to create new wire definitions
    for w in wire_list:
        new_wire_info = define_new_wire(w)
        temp_wire_list.append(new_wire_info)    # save them in a new list

    total_enables = 0   # counts total number of bits
    index = 0           # index number for the list
    number_of_super_sabouter = 0    # needed when inserting sabouters. sabouter-1, sabouter-2...
    # print to see wires and their new definitions
    for x in wire_list:
    #    print(f"Name: {x.get_name()} - Number of Bits: {x.get_numBit()}")
    #    print(f"New Definition: {temp_wire_list[index]}")
        total_enables = total_enables + x.get_numBit()  
        index = index + 1
        number_of_super_sabouter = number_of_super_sabouter + 1

    # copy the original file:
    shutil.copy(filename,new_filename)

    with open(new_filename, 'r') as file:
        lines = file.readlines()    #  returns the contents of the entire file 

    # insert new wires and replace wire names after "assign"
    with open(new_filename, 'w') as file:
        for line in lines:                                       # insert my new temporary wires
            if 'module' in line and 'endmodule' not in line:           # Check if the current line contains 'module'
                file.write(line)
                file.writelines(temp_wire_list)                        # Insert new lines after the line containing 'module'
            elif 'assign' in line:                                     
                wire_name_assign = find_wire_name(line)
                replace_wire_with = "temp_" + wire_name_assign         # exp: replace "_000_" with "temp__000_"
                new_line = line.replace(wire_name_assign, replace_wire_with)  
                file.write(new_line)          
            else:
                file.write(line)
    file.close()

    # insert components before "endmodule":
    # find line number for "endmodule"
    with open(new_filename, 'r') as file:
        lines = file.readlines()    #  returns the contents of the entire file 

    endmodule_line_number = None
    for i, line in enumerate(lines):
        if 'endmodule' in line:
            endmodule_line_number = i   # find line number containing "endmodule". with that i will insert components before endmodule
            break
    
    numBit_SS = math.floor(math.log2(number_of_super_sabouter)) + 1
    WIDTH = total_enables + 2
    COMPONENTS1 = insert_instances(wire_list, "i_TFEn", "EN_CTRL", WIDTH)

    new_lines = lines[:endmodule_line_number]  + COMPONENTS1 + lines[endmodule_line_number:]

    with open(new_filename, 'w') as file:
        file.writelines(new_lines)
    file.close()

    # insert new ports for inputs and outputs
    new_ports       = ", i_FI_CONTROL_PORT, i_SI, o_SI"
    parameter       = f" #(parameter WIDTH_SR = {WIDTH})"
    def_si          =  "  input i_SI;\n"
    def_new_port    =  "  input [3:0] i_FI_CONTROL_PORT;\n"        # control signals definition (CLK,  RST, TFEn and EN_SR)
    def_o_si        =  "  output o_SI;\n"                       # the only output controled by Fault Injection framework
    def_wire        = f"  wire [WIDTH_SR-1:0] o_SR;\n"
    assign_o_SI     =  "  assign o_SI = o_SR[0];\n"             # enable signals which will be shifted in the shift register


    with open(new_filename, 'r') as file:
        lines = file.readlines()
    with open(new_filename, 'w') as file:
        for line in lines:
            if 'module' in line and 'endmodule' not in line:
                x = line.find("(")
                str1 = line[:x] + parameter + line[x:]
                y = str1.find(";")
                new_line = str1[:y-1] + new_ports + str1[y-1:]

                file.write(new_line)
                file.write(def_si)
                file.write(def_new_port)
                file.write(def_o_si)
                file.write(def_wire)
                file.write(assign_o_SI)
            else:
                file.write(line)
    file.close()

    total = total_enables + 2
    print("Total number of bits for shift register:")
    print(f"[Enable Signals ({total_enables})] + [Control (2)] = {total}")

    print("Super Sabouters' lengths respectively (0 to N):")
    for x in wire_list:      
        print(x.get_numBit(), end=' ')

    print("\nNumber of Super Sabouter:", number_of_super_sabouter)
    print("Number of bits to represent Super Sabouter Number:", numBit_SS)

    create_detailed_report(wire_list, filename, "SABOTUER")