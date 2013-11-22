//const
#include"math_E.h"
const int ThreadsInOneBlock=128;
const int MaxBlocks=65536;
//arr^2--------------------------------------------------------------//
__global__ void squareCuda_Kernel(double* arrin,double*arrout,int n);
int squareC(double *arrin,double *arrout,int n);
//arr*nu--------------------------------------------------------------//
__global__ void multiByNumberCuda_Kernel(double*arrin,double num,double *arrout ,int n);
int multiByNumberCuda(double*arrin,double num,double *arrout ,int n);
int multiByNumberC(double*arrin,double num,double *arrout ,int n);

__global__ void multiByNumberCuda_Kernel(complex_E*arrin,complex_E num,complex_E *arrout ,int n);
int multiByNumberCuda(complex_E*arrin,complex_E num,complex_E *arrout ,int n);
int multiByNumberC(complex_E*arrin,complex_E num,complex_E *arrout ,int n);

__global__ void multiByNumberCuda_Kernel(complex_E*arrin,double num,complex_E *arrout ,int n);
int multiByNumberCuda(complex_E*arrin,double num,complex_E *arrout ,int n);
int multiByNumberC(complex_E*arrin,double num,complex_E *arrout ,int n);

__global__ void multiByNumberCuda_Kernel(complex_E*arrin,double num,double *arrout ,int n);
int multiByNumberCuda(complex_E*arrin,double num,double *arrout ,int n);
//arr1+arr2--------------------------------------------------------------//
__global__ void addCuda_Kernel(double*arrin1,double*arrin2 ,double *arrout ,int n);
int addCuda(double*arrin1,double *arrin2,double *arrout ,int n);
int addC(double*arrin1,double *arrin2,double *arrout ,int n);
//arr1-arr2--------------------------------------------------------------//
__global__ void minusCuda_Kernel(double*arrin1,double*arrin2 ,double *arrout ,int n);
int minusCuda(double*arrin1,double *arrin2,double *arrout ,int n);
int minusC(double*arrin1,double *arrin2,double *arrout ,int n);
//arr1*arr2--------------------------------------------------------------//
__global__ void multiCuda_Kernel(double*arrin1,double*arrin2 ,double *arrout ,int n);
int multiCuda(double*arrin1,double *arrin2,double *arrout ,int n);
int multiC(double*arrin1,double *arrin2,double *arrout ,int n);
//norm-----------------------------------------------------------
__global__ void normCuda_Kernel(double*arrin,double out,int n);
int normCuda(double*arrin,double out,int n);

//--------------------------------------------------------------//
//--------------------------------------------------------------//
//--------------------------------------------------------------//
///minus--------------------------------------------------------------//
//pure double Minus
__global__ void minusCuda_Kernel(double*arrin1,double*arrin2 ,double *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin1[tid]-arrin2[tid];
		tid+=gridDim.x*blockDim.x;
	}
}
int minusCuda(double*arrin1,double *arrin2,double *arrout ,int n){
	int griddim=(n+ThreadsInOneBlock-1)/ThreadsInOneBlock;if (griddim>MaxBlocks)griddim=MaxBlocks;
	minusCuda_Kernel<<<griddim,ThreadsInOneBlock>>>(arrin1,arrin2,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
///multi--------------------------------------------------------------//
//pure double
__global__ void multiCuda_Kernel(double*arrin1,double*arrin2 ,double *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin1[tid]*arrin2[tid];
		tid+=gridDim.x*blockDim.x;
	}
}
int multiCuda(double*arrin1,double *arrin2,double *arrout ,int n){
	int griddim=(n+ThreadsInOneBlock-1)/ThreadsInOneBlock;if (griddim>MaxBlocks)griddim=MaxBlocks;
	multiCuda_Kernel<<<griddim,ThreadsInOneBlock>>>(arrin1,arrin2,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//double double to Complex
__global__ void multiCuda_Kernel(double*arrin1,double*arrin2 ,complex_E *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid].Re=arrin1[tid]*arrin2[tid];
		arrout[tid].Im=0;
		tid+=gridDim.x*blockDim.x;
	}
}
int multiCuda(double*arrin1,double *arrin2,complex_E *arrout ,int n){
	int griddim=(n+ThreadsInOneBlock-1)/ThreadsInOneBlock;if (griddim>MaxBlocks)griddim=MaxBlocks;
	multiCuda_Kernel<<<griddim,ThreadsInOneBlock>>>(arrin1,arrin2,arrout,n);
	cudaThreadSynchronize();
	return 0;
}

//--------------------------------------------------------------//
//add--------------------------------------------------------------//
//pure double 
__global__ void addCuda_Kernel(double*arrin1,double*arrin2 ,double *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin1[tid]+arrin2[tid];
		tid+=gridDim.x*blockDim.x;
	}
}
int addCuda(double*arrin1,double *arrin2,double *arrout ,int n){
	int griddim=(n+ThreadsInOneBlock-1)/ThreadsInOneBlock;if (griddim>MaxBlocks)griddim=MaxBlocks;
	addCuda_Kernel<<<griddim,ThreadsInOneBlock>>>(arrin1,arrin2,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//--------------------------------------------------------------//
//multiByNumber--------------------------------------------------------------//
//pure double
__global__ void multiByNumberCuda_Kernel(double*arrin,double num,double *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin[tid]*num;
		tid+=gridDim.x*blockDim.x;
	}
}
int multiByNumberCuda(double*arrin,double num,double *arrout ,int n){
	int griddim=(n+ThreadsInOneBlock-1)/ThreadsInOneBlock;if (griddim>MaxBlocks)griddim=MaxBlocks;
	multiByNumberCuda_Kernel<<<griddim,ThreadsInOneBlock>>>(arrin,num,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//pure complex
__global__ void multiByNumberCuda_Kernel(complex_E*arrin,complex_E num,complex_E *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid].Re=arrin[tid].Re*num.Re-arrin[tid].Im*num.Im;
		arrout[tid].Im=arrin[tid].Re*num.Im+arrin[tid].Im*num.Re;
		tid+=gridDim.x*blockDim.x;
	}
}
int multiByNumberCuda(complex_E*arrin,complex_E num,complex_E *arrout ,int n){
	int griddim=(n+ThreadsInOneBlock-1)/ThreadsInOneBlock;if (griddim>MaxBlocks)griddim=MaxBlocks;
	multiByNumberCuda_Kernel<<<griddim,ThreadsInOneBlock>>>(arrin,num,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//complex by double
__global__ void multiByNumberCuda_Kernel(complex_E*arrin,double num,complex_E *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid].Re=arrin[tid].Re*num;
		arrout[tid].Im=arrin[tid].Im*num;
		tid+=gridDim.x*blockDim.x;
	}
}
int multiByNumberCuda(complex_E*arrin,double num,complex_E *arrout ,int n){
	int griddim=(n+ThreadsInOneBlock-1)/ThreadsInOneBlock;if (griddim>MaxBlocks)griddim=MaxBlocks;
	multiByNumberCuda_Kernel<<<griddim,ThreadsInOneBlock>>>(arrin,num,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//complex to double
__global__ void multiByNumberCuda_Kernel(complex_E*arrin,double num,double *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin[tid].Re*num;
		tid+=gridDim.x*blockDim.x;
	}
}

int multiByNumberCuda(complex_E*arrin,double num,double *arrout ,int n){
	int griddim=(n+ThreadsInOneBlock-1)/ThreadsInOneBlock;if (griddim>MaxBlocks)griddim=MaxBlocks;
	multiByNumberCuda_Kernel<<<griddim,ThreadsInOneBlock>>>(arrin,num,arrout,n);
	cudaThreadSynchronize();
	return 0;
}


//squre--------------------------------------------------------------//
__global__ void squareCuda_Kernel(double* arrin,double*arrout,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin[tid]*arrin[tid];
		tid+=gridDim.x*blockDim.x;
	}
}
//--------------------------------------------------------------//

//--------------------------------------------------------------//
