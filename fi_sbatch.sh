#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --job-name=fault_injection
#SBATCH --mail-type=ALL
#SBATCH --mail-user=juan.guerrero@polito.it

# 1 Activate the virtual environment
#module load anaconda3
##source ~/.bashrc
#conda deactivate

#cd  /leonardo/home/userexternal/jguerre1/stereo_vision_core

#conda activate stereo_tb
F_TYPE=2
MODULES=64
SR_SIZE=21-2

PWD=`pwd`
echo ${PWD}
global_PWD="$PWD"

job_id="$SLURM_JOB_ID"

IMAGE="$1"
RESULTS_PATH="$2"
start="$3"
end="$4"

for (( cp=start; cp<=end; cp++ )) ; {
    for (( ft=0; ft<F_TYPE; ft++ )) ; {
        for (( bt=0; bt<SR_SIZE; bt++ )) ; {

            python run_stereo_simulation_fi_tb.py -ft ${ft} -bp ${bt} -cm ${cp} -im ${IMAGE}
            mv ${global_PWD}/tmp${IMAGE}${ft}_${cp}_${bt}/*.png ${RESULTS_PATH}
            #echo "${IMAGE}_f_${ft}_${cp}_${bt}.png" >> fi_work/report_differences.txt
            diff ${RESULTS_PATH}/golden_${IMAGE}.png ${RESULTS_PATH}/${IMAGE}_f_${ft}_${cp}_${bt}.png >> ${RESULTS_PATH}/report_differences.txt 
            rm -rf ${global_PWD}/tmp${IMAGE}${ft}_${cp}_${bt}

        }
   }
}