#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VStereo_Match.h"
#include "VStereo_Match___024root.h"

vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
    VStereo_Match *dut = new VStereo_Match;
    std::vector<int> image_left;
    std::vector<int> image_right;
    std::vector<int> image_valid;

    std::vector<int> output_data;
    std::vector<int> output_valid;

    std::ifstream file_image_left; 
    file_image_left.open("../input_vector_left_image.txt");
    std::ifstream file_image_right; 
    file_image_right.open("../input_vector_right_image.txt");
    std::ifstream file_image_valid; 
    file_image_valid.open("../input_vector_valid.txt");

    std::string line;
    if(file_image_left)
    while(std::getline(file_image_left, line)){
        image_left.push_back(std::stoi(line));
    }
    while(std::getline(file_image_right, line)){
        image_right.push_back(std::stoi(line));
    }
    while(std::getline(file_image_valid, line)){
        image_valid.push_back(std::stoi(line));
    }

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 1);
    m_trace->open("waveform.vcd");
    dut->i_Tresh_LRCC = 8;     
    for(int i=0; i<50; i++){
        dut->i_clk ^= 1;
        dut->eval();        
    }    
    dut->i_rst = 1;
    std::cout << "vector size "<<sizeof(image_valid);
    while (sim_time < image_valid.size()) {
        dut->i_clk ^= 1;
        dut->eval();
        m_trace->dump(sim_time);        
        if (dut->i_clk==0){       
            dut->i_dval = image_valid[sim_time];
            dut->i_dato_L=image_left[sim_time];
            dut->i_dato_R=image_right[sim_time];     
            output_data.push_back(dut->o_dato);
            output_valid.push_back(dut->o_dval);
        }        
        sim_time++;
    }
    m_trace->close();
    delete dut;

    std::ofstream outputDato; // create a new output file or overwrite an existing one
    outputDato.open("../output_vector_data.txt");
    std::ofstream outputValid("../output_vector_valid.txt");

    
    if (outputDato.is_open()) { // check if the file was opened successfully
        for(auto val:output_data){
            outputDato << val << "\n"; // write data to the file
         }
    outputDato.close(); // close the file when done
    }
    else {
        std::cerr << "Error opening file\n";
    }
   
   if (outputValid.is_open()) { // check if the file was opened successfully
        for(auto val:output_valid){
            outputValid << val << "\n"; // write data to the file
         }
    outputValid.close(); // close the file when done
    }
    else {
        std::cerr << "Error opening file\n";
    }
    
    exit(EXIT_SUCCESS);
}
