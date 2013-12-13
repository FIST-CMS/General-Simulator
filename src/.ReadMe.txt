README.txt for martensite transformation process simulation

CONTENT

This set of programs is designed for simulating the martensite transformation from B2 to R process of Ti-Ni system. It is coded in the cudaC manner, which is a extention of c++ with the ability to manipulate the GPU devices by the Nvidia corporation. 

It is a demonstration on that the powerful paraellel GPU devices can be utilized in Phase field simulations. Moreover, the utilization is worthwhile for the high performance attained. According to our test in a 3D system with 64x64x64 scale, the program can run approximately fifty times faster on Tesla/C2050 than a serial program run on Intel Xeon E5645@2.4GHz. This acceleration can be more notable when system becomes larger.

RUNNING 

The accessable script for running the simulation is "excute.sh", in which the scale of the system, the start temperature and the change of temperature in the transition path is adjustable. Fix the parameters in "excute.sh" and use "./excute.sh" to begin the simulation.
Input:
	There is no other input data needed other than the parameters needed in "excute.sh".
Output:
	The order parameters representting the micorostructure of the system at different steps and corresponding teperature is printed in files(see martTransformatioon for details).
Requirement for running "excute.sh": cuda evironment is ready for use.

RELATED DOCUMENTS 

The program uses two math-libs provided by nVIDIA: cufft and curand. One can download or refer online @ developer.nvidia.com. Here tree documents related to the progject is presented.
		CUDA_C_Programming_Guide.pdf
		CUDA_CUFFT_Users_Guide.pdf
		CURAND_Library.pdf
The fft transformation operation is doned under the methods provided by "CUDA_CUFFT_Users_Guide.pdf". The random number needed by simulating the stochastic properties is produced via the methods provided by "CURAND_Library.pdf".

COPYING

You can use and copy it as much as you like, but we are not responsible for any consequence it brings for we provided it for a demonstration purpose.

MAIN AUTHOR

Send any other comments and suggestions to:
	
	Wang, Dong

	Xiao, Hu		E-mail: EinsXiao@gmail.com
		FIST, Xi'an Jiaotong University
		A222, No.1 West Building,
		No.99 YanXiang Road, YanTa District, Xi'an,
		ShaanXi Province, 710054
		P. R. China
