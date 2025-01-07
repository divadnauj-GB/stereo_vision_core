
PATH_ROOT= `pwd`
#rm -rf fi_work
mkdir -p fi_work
cd fi_work
verilator -max-num-width 80000 --trace --trace-depth 1  --threads 4 -j 8 --cc ../FI/srcs/stereo_match.v ../FI/srcs/disp_cmp_13_64_7_sbtr.v  ../FI/sbtr_cells/shift_register.v ../FI/sbtr_cells/basic_sabotuer.v ../FI/sbtr_cells/super_sabouter.v --exe ../FI/Stereo_Match_fi_tb.cpp
make -C obj_dir -f VStereo_Match.mk Vstereo_match