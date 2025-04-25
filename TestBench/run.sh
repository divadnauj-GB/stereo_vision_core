#!/bin/bash



APP_ARGS=$*
if [[ -v GOLDEN ]]; then
    #./obj_dir/Vtb_stereo_match > stdout.txt 2> stderr.txt 
    echo "generating golden files"
    cd ../
    python run_stereo_simulation_tb.py -im Cones -simt verilator+timing > stdout.log 2> stderr.log 
    cd -
    # copy the inputs and outputs to the current directory
    mv ../Disparity_map.png Golden_Disparity_map.png
    mv ../input_vector_left_image.txt input_vector_left_image.txt
    mv ../input_vector_right_image.txt input_vector_right_image.txt
    mv ../input_vector_valid.txt input_vector_valid.txt
    mv ../output_vector_data.txt Golden_output_vector_data.txt
    mv ../output_vector_valid.txt Golden_output_vector_valid.txt

else
    ./obj_dir/Vtb_stereo_match > stdout.log 2> stderr.log
fi

