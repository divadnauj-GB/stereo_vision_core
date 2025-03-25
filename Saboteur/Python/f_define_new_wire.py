from class_wire_extraction import WireInfo

# This function define new temporary wires.
# exp:
# wire [11:0] _004_;
# new wire definition:
# wire [11:0] temp__004_;

def define_new_wire(original_wire):
    new_name = "temp_" + original_wire.get_name()
    msb      = original_wire.get_MSB()
    numBits =  original_wire.get_numBit() - 1
    lsb = msb - numBits

    if original_wire.get_numBit() > 1:
        definition = "  wire [" + str(msb) + ":" + str(lsb) + "] " + new_name + ";\n"
    else:
        definition = "  wire " + new_name + ";\n"

    
    # print("new def:", definition ,numBits)

    return definition