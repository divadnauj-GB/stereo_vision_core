# this function fill the list with component super_sabouter that takes parameter. this parameter defines how many
# bits input enable has.

def insert_instances(wire_list, enable_super_sabouter, enable_ctrl, WIDTH):
    
    cnt_ss = 0
    index = 0
    instance_list = []

    for x in wire_list:
        temp_wire = "temp_" + x.get_name()


        text = f"""super_sabouter #(.WIDTH({x.get_numBit()})) SS{cnt_ss}(
                  .i_sig({temp_wire}),
                  .i_en_super_sabouter(i_FI_CONTROL_PORT[1]),
                  .i_en_basic_sabouter(o_SR[{index+x.get_numBit()-1}:{index}]),
                  .i_ctrl(o_SR[{WIDTH-1}:{WIDTH-2}]),
                  .o_sig({x.get_name()})
                  );\n"""
        cnt_ss += 1
        index = index + x.get_numBit()
        instance_list.append(text)

    text = f"""shift_register #(.WIDTH(WIDTH_SR)) SR(
                    .i_CLK(i_FI_CONTROL_PORT[3]),
                    .i_RST(i_FI_CONTROL_PORT[2]),
                    .i_EN(i_FI_CONTROL_PORT[0]),
                    .i_SI(i_SI),
                    .o_DATA(o_SR)
                    );\n"""
    instance_list.append(text)

    return instance_list