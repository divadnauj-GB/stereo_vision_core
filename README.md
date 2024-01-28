# stereo_matching_core


This is the implementation of an stereo Matching HW accelerator for Stereo vision applications. This accelerators uses Census Transform sparce (50%), and the sum of hamming distances to permor de stereo correspondence among left and right images. The accelerator implements the streaming processing computation approach. This HW implementation got inspiration on the work published by Wade S. Fife in [IEEE Xplore](https://ieeexplore.ieee.org/document/6213095)


The detailes architecture implementation can be found [here](https://github.com/divadnauj-GB/stereo_matching_core/blob/main/docs/Stereo_Match_Core.pdf). 