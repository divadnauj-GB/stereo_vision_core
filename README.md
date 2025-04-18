The thesis summary:

An increase in complexity of electronic systems leads to less tolerance such systems for 
performance degradation and safety hazards. Therefore, guaranteeing relaibility of electronic 
systems is crutial for safety-critical applications. It is needed to identify any kinds of errors and 
possible origin of the error as early as possible and find out solutions not to sacrifice for 
performance.  

An occurrence of the error can depends on different reasons including manufacturing 
defects, aging, environmental interruption and so on. Some of this errors can be detected and 
corrected after production however some of them may also arises after use. This may cause a 
failure if designer is not aware of such cases while designing its product. There might be such 
cases where even engineer can not intervene to fix the error for instance space applications. 
Hence, the electronic systems should be capable of rectifying the errors or be resistant to the 
errors. 

Modelling faults and analyzing their effects are significant for performance. A fault can 
be defined as a representation of defect which is unexpected behavior between planned design 
and implemented design. There are different fault models to test the designs. This thesis focuses 
on stuck-at and transient fault models to test a hardware. 

A targeted hardware is a stereo match accelarator core based on census transform. As 
name indicates, the accelerator infers depth information from two images of the same scene but 
different angles. The image dataset is obtained from Middlebury Stereo Datasets. Four scenes 
are used: tsukuba, cones, venus and teddy. The accelerator creates a disparity map showing 
depth of the objects. The Middlebury Stereo Datasets also provides ground-truth iamges for the 
scenes and they are used to calculate an accuracy, peak-signal-to-noise ratio (PSNR) and signal
to-noise ratio (SNR).  These metrics are used for a reference. 

As mentioned, the accelerator is based on census transform which has different 
configurations. Kernel size (5x5, 7x7 and 9x9) and number of neigborhoods (9 configurations) 
are features for the census transform. The provided hardware was implemented with 7x7 kernel 
and uniformly distributed neighborhoods. To gain comprehensive view, all combinations of the 
features are implemented since the resilience to a fault for one configuration may not be same 
for another. In the other word, fault that not arise in one configuration may appear. However, 
quality of the dispart map can also be different. Therefore, all configurations of the census 
transform are implemented and adapted in the accelerator. The metrics were calculated for four 
scenes with Matlab. This forms the initial part of the thesis. The metrics for fault-free 
simulations are present at this stage. 

After that work, an analysis for fault injected hardware starts. Since there are a lot of  
configurations, an automated framework is needed to expedite the injection process. The 
framework needs a fault list which stores locations where fault will be injected. Stuck-at faults 
are implemented via Questa simulator. 

The framework takes the selected hardware and then compile it. A script reads the fault 
list line by line and for each fault it simulates the selected hardware. The output of the 
accelerator, a disparty map, will be compared with ground-truth image with help of a python 
script which calculated the metrics and write them down in csv file.  
Creation of the fault list is completed after several trials. First list targets location which  
are intuitively selected. It requires an understanding of the hardware. The most significant bits 
of signed additions and subtructions are mostly targeted. There are also comparators in the 
hardware and some bits are also targeted. Since there are millions of bits, it is impossible to 
simulate all of them within a certain period of time. That is the reason for fault list creation. 
Nevertless, the time is still limited to simulate all design. At this point, second list emerged. 
This list targets the most significant bits of outputs of the all modules in the design. Aim is to 
identify the effect of sign bits in the circuit. Finally, simulations were conducted as time 
permitted. Metrics are calculated for 7x7 window for all neighborhoods configurations. As a 
result sign bits make a difference for stuck-at-0 fault for all designs. The second stage of the 
thesis is concluded with these simulations. 

Finally, the thesis seeks to solution to accelerate the simulations. The solution is to 
migrate the framework into FPGA environment. As it is apparent, FPGA can enable the 
simulations to run almost in real time. Hyper FPGA, Trenz SOM TE0803-03-4BE11-A, is used 
for the purpose. However, it is provided us by Multidisciplinary LABoratory (MLAB) from 
The Abdus Salam International Centre for Theoretical Physics (ICTP, Italy). A framework was 
introduced us by them. Connection to hyper FPGA is provided us via jupiter notebook. 
The framework aims to connect any custom design into FPGA via the communication block IP 
core (core ComBlock) which provides interfaces such as registers and FIFOs to programmer of 
the programmable logic (PL). It helps to bypass the complexity of the bus provided by the 
processing system (PS). 

The plan of this stage is to set hardware for: (i) input image selection, (ii) location of the 
fault injection/s and (iii) collection of statistics automatically. These requires modifications on 
hardware and additional controller hardware for status of the hardware. 
The hardware needs to be inserted with sabotuers which are the small hardware to select 
fault types (stuck-at-0, stuck-at-1 and transient fault specifically single-event-upset (SEU)). 
Beside the sabotuers, shift register has to be inserted to store enable signales. These are inserted 
into comparator modules of the accelerator for trail since it is a small hardware. The injection 
process are also done automatically with a python script. After successful compilation, the 
controller module is desinged. 

The controller is a harware which let the programmer know about status of the hardware. 
It establishes a kind of handshake protocol between programmer and hardware. For instance, if 
the hardware received the input image and ready to start simulation or it concludes the 
simulation. This type of message are important to obtain reliable results. Then the accelerator 
with the controller is implemented and interfaces are also handled. This was the last stage of 
the thesis. 

In conlusion, the FPGA framework is needed to be tested for functionality which is a 
future work. However, the effort put on this thesis is important to test any hardware via FPGA 
automatically, and contribute to run simulations faster. The proposed framework can contribute 
to designer to test their design faster and build fault correction algorithms accordingly. 
