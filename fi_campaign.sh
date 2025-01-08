if [[ -z "${SLURM}" ]]; then
    echo "Running locally"
else
    echo "Running on SLURM"
    module load anaconda3
    source ~/.bashrc
    conda deactivate
    cd  /leonardo/home/userexternal/jguerre1/stereo_vision_core
    conda activate stereo_tb
fi

PWD=`pwd`
echo ${PWD}
global_PWD="$PWD"

IMAGE="$1"
RESULTS_PATH=${global_PWD}/fi_work/${IMAGE}
F_TYPE=2
MODULES=64
SR_SIZE=21-2


#bash ${global_PWD}/FI/compile_fi.sh
mkdir -p ${RESULTS_PATH}

bash ${global_PWD}/FI/compile_fi.sh
mkdir -p ${RESULTS_PATH}

echo "" > ${RESULTS_PATH}/report_differences.txt

python ${global_PWD}/run_stereo_simulation_tb.py -im ${IMAGE}
mv ${global_PWD}/*.png ${RESULTS_PATH}/golden_${IMAGE}.png
mkdir -p ${global_PWD}/logs

for (( cpp=0; cpp<MODULES; cpp++ )) ; {
    if [[ -z "${SLURM}" ]]; then
        for (( cp=cpp; cp<=cpp; cp++ )) ; {
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
    else
        sbatch --output=${global_PWD}/logs/stdo_%A_%a.log \
            --error=${global_PWD}/logs/stde_%A_%a.log \
            fi_sbatch.sh ${IMAGE} ${RESULTS_PATH} ${cpp} ${cpp}
    fi
}