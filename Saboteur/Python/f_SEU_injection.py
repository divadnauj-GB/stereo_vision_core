from class_wire_extraction import WireInfo
from f_create_detailed_report import create_detailed_report
import re
import csv
import os
# Single Event Upset: 
#
# this function inject xor operation before assigning the signal to FF. therefore we can check the behavior of th FF under fault.
# this function is independent from sabotuer injection and different type of fault model. user can select fault model before modifying
# the design.
#
# ie:
#   always @(posedge i_clk, negedge i_rst)
#       if (!i_rst) \13082.counter[1]  <= 1'h0;
#       else if (ghdl_gen_04_) \13082.counter[1]  <= \ghdl_gen_01_[1] ;
# code will get 2nd line after the line containing "always". it assumes the line it will modify is exactly the second line after 
# "always". then add logic before ";".
# output:
#
# always @(posedge i_clk, negedge i_rst)
#   if (!i_rst) \s_input[12]  <= 1'h0;
#   else if (i_dval) \s_input[12]  <= i_data[12] ^ (i_FI_CONTROL_PORT[1] & o_SR[7]) ;

def inject_SEU(i_file):

    reg_list = []

    # WRITE YOUR FILENAMES HERE (MODIFY ACCORDING TO YOUR DESIGN):
    filename = i_file                   # the netlist
    new_filename = "with_seu_" + i_file       # output: new netlist
    
    text_SR = f"""  shift_register #(.WIDTH(WIDTH_SR)) SR(
                        .i_CLK(i_FI_CONTROL_PORT[3]),
                        .i_RST(i_FI_CONTROL_PORT[2]),
                        .i_EN(i_FI_CONTROL_PORT[0]),
                        .i_SI(i_SI),
                        .o_DATA(o_SR)
                        );\n"""


    line_number = 0
    # read line by line and save wire and input names with their number of bits into the list:
    with open(filename, 'r') as file:
        for line_design in file:
            line_number += 1
            if 'reg' in line_design:        # get signals defined as reg
                reg_info = WireInfo(line_design)
                reg_info.lineNum = line_number
                reg_list.append(reg_info)
    file.close()

    for s in reg_list:
        print(f"{s.get_name()} - {s.get_numBit()}")

    print(f"Length of SR for SEU: {len(reg_list)}")


    with open(filename, 'r') as infile, open(new_filename, 'w') as outfile:
        while True:
            line = infile.readline()     
            # Stop if we have reached the end of the file
            if not line:
                break  
        # Check if the line contains 'always'
            if 'always' in line:
                # Write the 'always' line to the output file
                outfile.write(line)
                
                # Read the next two lines after 'always'
                next_line_1 = infile.readline().strip()
                outfile.write("    " + next_line_1 + "\n")
            # insert logic HERE
                next_line_2 = infile.readline().strip()
                match = re.search(r'(\S+)\s*<', next_line_2)        # find reg name in that line: the string before "<"
                if match:
                    reg_name = match.group(1)
                  #  print("Extracted String:", match.group(1))
                else:
                    print("No match found.")
            # get shift register enable bit location for register   
                for i, x in enumerate(reg_list):
                    if(x.get_name() == reg_name):
                        if(x.get_numBit() == 1):
                        #    print(f"{reg_name} - SR[{i}]")
                            sr_bits = f"{i}"
                        else:
                        #    print(f"{reg_name} - SR[{i+x.get_numBit()-1}:{i}]")
                            sr_bits = f"{i+x.get_numBit()-1}:{i}"
                logic_to_be_inserted = f"^ (i_FI_CONTROL_PORT[1] & o_SR[{sr_bits}])"
            # modify enable signal for FF: "else if (i_dval) \s_input[5]  <= i_data[5];" -> i_dval in that case
                if 'else if' in next_line_2:
                    position = next_line_2.find(")")
                    modified_line = next_line_2[:position] + f" || (i_FI_CONTROL_PORT[1] & o_SR[{sr_bits}]))" + next_line_2[position + 1:]
                 #   print(modified_line)
                else:
                    modified_line = next_line_2
               # print(logic_to_be_inserted)
                modified_line = re.sub(r'\s*;', f' {logic_to_be_inserted} ;', modified_line)
                modified_line = "    " + modified_line
                outfile.write(modified_line + "\n")
                
        # Now continue reading after the second line, so don't write next_line_1 and next_line_2 again
            elif 'endmodule' in line:   # insert shift register
                outfile.write(text_SR)
                outfile.write(line)
        # insert ports and define them
            elif 'module' in line and 'endmodule' not in line:  
                new_ports       = ", i_FI_CONTROL_PORT, i_SI, o_SI"
                parameter       = f" #(parameter WIDTH_SR = {len(reg_list)})"
                def_si          =  "  input i_SI;\n"
                def_new_port    =  "  input [3:0] i_FI_CONTROL_PORT;\n"        # control signals definition (CLK,  RST, TFEn and EN_SR)
                def_o_si        =  "  output o_SI;\n"                       # the only output controled by Fault Injection framework
                def_wire        = f"  wire [WIDTH_SR-1:0] o_SR;\n"
                assign_o_SI     =  "  assign o_SI = o_SR[0];\n"             # enable signals which will be shifted in the shift register

                x = line.find("(")
                str1 = line[:x] + parameter + line[x:]
                y = str1.find(";")
                new_line = str1[:y-1] + new_ports + str1[y-1:]
                outfile.write(new_line)
                outfile.write(def_si)
                outfile.write(def_new_port)
                outfile.write(def_o_si)
                outfile.write(def_wire)
                outfile.write(assign_o_SI)    
            else:
                # If the line doesn't contain 'always', just write it to the output file
                outfile.write(line)
    outfile.close()
    infile.close()

    create_detailed_report(reg_list, filename, "SEU")
