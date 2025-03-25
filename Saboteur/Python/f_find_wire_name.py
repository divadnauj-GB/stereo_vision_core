import re

# This function receive line containing assign and then return wire name.
# exp:
# assign _000_[0] = _005_[0] &(* src = "comparator.v:12.21-12.64" *)  _005_[1];
# extracting "_000_"

def find_wire_name(line):
    start_index = line.find("assign") + len("assign")
    end_index = line.find("=")
    wire_name = line[start_index:end_index-1].strip()

    # print("Extracted signal:", wire_name)

    return wire_name