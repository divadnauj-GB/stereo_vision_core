
IMAGE=Cones

F_TYPE=2
MODULES=1
SR_SIZE=21-2


python run_stereo_simulation_tb.py -im ${IMAGE} -gv 1
mv *.png fi_work/golden_${IMAGE}.png

for (( ft=0; ft<F_TYPE; ft++ )) ; {
   for (( cp=0; cp<MODULES; cp++ )) ; {
        for (( bt=0; bt<SR_SIZE; bt++ )) ; {
            python run_stereo_simulation_fi_tb.py -ft ${ft} -bp ${bt} -cm ${cp} -im ${IMAGE}
            mv *.png fi_work
        }
   }
}