#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vstereo_match.h"
#include "Vstereo_match___024root.h"

//#define TRACE_EN

vluint64_t sim_time = 0;
vluint64_t index_data = 0;
vluint64_t fault_idx = 3;

int main(int argc, char** argv, char** env) {
    Vstereo_match *dut = new Vstereo_match;
    std::vector<int> image_left;
    std::vector<int> image_right;
    std::vector<int> image_valid;

    std::vector<int> output_data;
    std::vector<int> output_valid;
    std::vector<int> fault_descriptor;

    std::ifstream file_image_left("../input_vector_left_image.txt"); 
    std::ifstream file_image_right("../input_vector_right_image.txt"); 
    std::ifstream file_image_valid("../input_vector_valid.txt"); 
    std::ofstream outputDato("../output_vector_data.txt"); // create a new output file or overwrite an existing one
    std::ofstream outputValid("../output_vector_valid.txt");
    std::ifstream file_fault_descriptor("fault_descriptor.txt");

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
    while(std::getline(file_fault_descriptor, line)){
        fault_descriptor.push_back(std::stoi(line));
    }

    Verilated::traceEverOn(true);
    #ifdef TRACE_EN
        VerilatedVcdC *m_trace = new VerilatedVcdC;    
        dut->trace(m_trace, 1);
        m_trace->open("waveform.vcd");
    #endif
    dut->i_tresh_lrcc = 8; 
    dut->injector_i_RST=0;    
    dut->injector_i_TFEn=0;
    dut->injector_i_EN=0;
    dut->injector_i_SI=0;
    dut->injector_i_CLK=0;
    for(int i=0; i<51; i++){
        dut->i_clk ^= 1;
        dut->injector_i_CLK ^= 1;
        dut->eval();
        #ifdef TRACE_EN 
            m_trace->dump(sim_time);
        #endif
        sim_time++;       
    }    
    dut->i_rstn = 1;
    dut->injector_i_RST=1;

    int modules=fault_descriptor[0];
    int component=fault_descriptor[1];
    int sr_leght=fault_descriptor[2];
    // configuration of the saboteurs

    for(int m_shift=0; m_shift<modules; m_shift++){
        for(int bit_shift=0; bit_shift<sr_leght; bit_shift++){
            dut->injector_i_EN=1; 
            dut->i_clk ^= 1;
            dut->injector_i_CLK ^= 1;
            if (m_shift==component){
                dut->injector_i_SI = fault_descriptor[bit_shift+3];
            }else{
                dut->injector_i_SI=0;
            }
            dut->eval(); 
            #ifdef TRACE_EN 
                m_trace->dump(sim_time);
            #endif
            sim_time++;  
            dut->i_clk ^= 1;
            dut->injector_i_CLK ^= 1;   
            dut->eval(); 
            #ifdef TRACE_EN 
                m_trace->dump(sim_time);
            #endif
            sim_time++;         
        }
    }

    /*
    for(auto val:FI_register){
        int tmp=val;        
        dut->injector_i_EN=1;            
        for(int i=0; i<42; i++){
            dut->i_clk ^= 1;
            dut->injector_i_CLK ^= 1;            
            if (dut->injector_i_CLK==0){ 
                dut->injector_i_SI=tmp&1;
                tmp=tmp>>1;
            }
            dut->eval(); 
            #ifdef TRACE_EN 
                m_trace->dump(sim_time);
            #endif
            sim_time++;       
        } 
    }*/

    dut->injector_i_SI=0;
    dut->injector_i_EN=0;
    dut->injector_i_TFEn=1; //saboteur enabled
    
    // workload execution
    if (outputDato.is_open() && outputValid.is_open()) {

        while (index_data < image_valid.size()) {
            dut->i_clk ^= 1;
            dut->injector_i_CLK = 0;
            dut->eval();
            #ifdef TRACE_EN 
                m_trace->dump(sim_time);
            #endif
            if (dut->i_clk==0){       
                dut->i_dval = image_valid[index_data];
                dut->i_data_l=image_left[index_data];
                dut->i_data_r=image_right[index_data];     
                outputDato << int(dut->o_data)  << "\n";
                outputValid << int(dut->o_dval) << "\n"; 
                //output_data.push_back(dut->o_dato);
                //output_valid.push_back(dut->o_dval);
                index_data++;
            } 
            sim_time++;

        }
        outputDato.close(); // close the file when done
        outputValid.close();
        #ifdef TRACE_EN
            m_trace->close();
        #endif
        delete dut;
    }
    else {
        std::cerr << "Error opening file\n";
    }
   
    
    exit(EXIT_SUCCESS);
}
