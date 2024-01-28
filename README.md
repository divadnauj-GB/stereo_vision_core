# stereo_matching_core


This is implementing a stereo-matching HW accelerator for Stereo vision applications. This accelerator uses Census Transform sparse (50%) and the sum of hamming distances to perform de stereo correspondence among left and right images. The accelerator implements the streaming processing computation approach. This HW implementation got inspiration from the work published by Wade S. Fife in [IEEE Xplore](https://ieeexplore.ieee.org/document/6213095)


The details of the architecture implementation can be found [here](https://github.com/divadnauj-GB/stereo_matching_core/blob/main/docs/Stereo_Match_Core.pdf). 

## System Requierements
- Python 3.8 or newer
- Modelsim or Questasim


## How to use this repository

```
# Clone this repository
git clone https://github.com/divadnauj-GB/stereo_matching_core.git

# Run test the accelerator
cd stereo_matching_core
python3 run_stereo_simulation.py

```
