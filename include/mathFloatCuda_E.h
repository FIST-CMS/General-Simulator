//const
#include"mathFloat_E.h"
const int maxThreadsDim=1024;
const int MaxBlocksDim=65535;

//cucomplex_E extension on cuda





//arr^2--------------------------------------------------------------//
__global__ void squareCuda_Kernel(float* arrin,float*arrout,int n);
int squareC(float *arrin,float *arrout,int n);
//arr*nu--------------------------------------------------------------//
__global__ void multiByNumberCuda_Kernel(float*arrin,float num,float *arrout ,int n);
int multiByNumberCuda(float*arrin,float num,float *arrout ,int n);
int multiByNumberC(float*arrin,float num,float *arrout ,int n);

__global__ void multiByNumberCuda_Kernel(cucomplex_E*arrin,cucomplex_E num,cucomplex_E *arrout ,int n);
int multiByNumberCuda(cucomplex_E*arrin,cucomplex_E num,cucomplex_E *arrout ,int n);
int multiByNumberC(cucomplex_E*arrin,cucomplex_E num,cucomplex_E *arrout ,int n);

__global__ void multiByNumberCuda_Kernel(cucomplex_E*arrin,float num,cucomplex_E *arrout ,int n);
int multiByNumberCuda(cucomplex_E*arrin,float num,cucomplex_E *arrout ,int n);
int multiByNumberC(cucomplex_E*arrin,float num,cucomplex_E *arrout ,int n);

__global__ void multiByNumberCuda_Kernel(cucomplex_E*arrin,float num,float *arrout ,int n);
int multiByNumberCuda(cucomplex_E*arrin,float num,float *arrout ,int n);
//arr1+arr2--------------------------------------------------------------//
__global__ void addCuda_Kernel(float*arrin1,float*arrin2 ,float *arrout ,int n);
int addCuda(float*arrin1,float *arrin2,float *arrout ,int n);
int addC(float*arrin1,float *arrin2,float *arrout ,int n);
//arr1-arr2--------------------------------------------------------------//
__global__ void minusCuda_Kernel(float*arrin1,float*arrin2 ,float *arrout ,int n);
int minusCuda(float*arrin1,float *arrin2,float *arrout ,int n);
int minusC(float*arrin1,float *arrin2,float *arrout ,int n);
//arr1*arr2--------------------------------------------------------------//
__global__ void multiCuda_Kernel(float*arrin1,float*arrin2 ,float *arrout ,int n);
int multiCuda(float*arrin1,float *arrin2,float *arrout ,int n);
int multiC(float*arrin1,float *arrin2,float *arrout ,int n);
//norm-----------------------------------------------------------
__global__ void normCuda_Kernel(float*arrin,float out,int n);
int normCuda(float*arrin,float out,int n);

//--------------------------------------------------------------//
//--------------------------------------------------------------//
//--------------------------------------------------------------//
///minus--------------------------------------------------------------//
//pure float Minus
__global__ void minusCuda_Kernel(float*arrin1,float*arrin2 ,float *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin1[tid]-arrin2[tid];
		tid+=gridDim.x*blockDim.x;
	}
}
int minusCuda(float*arrin1,float *arrin2,float *arrout ,int n){
	int griddim=min_E((n+maxThreadsDim-1)/maxThreadsDim,MaxBlocksDim);
	minusCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin1,arrin2,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
///multi--------------------------------------------------------------//
//pure float
__global__ void multiCuda_Kernel(float*arrin1,float*arrin2 ,float *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin1[tid]*arrin2[tid];
		tid+=gridDim.x*blockDim.x;
	}
}
int multiCuda(float*arrin1,float *arrin2,float *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	multiCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin1,arrin2,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//pure cucomplex
__global__ void multiCuda_Kernel(cucomplex_E*arrin1,cucomplex_E *arrin2,cucomplex_E *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid].Re=arrin1[tid].Re*arrin2[tid].Re-arrin1[tid].Im*arrin2[tid].Im;
		arrout[tid].Im=arrin1[tid].Re*arrin2[tid].Im+arrin1[tid].Im*arrin2[tid].Re;
		tid+=gridDim.x*blockDim.x;
	}
}
int multiCuda(cucomplex_E *arrin1,cucomplex_E *arrin2,cucomplex_E *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	multiCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin1,arrin2,arrout,n);
	cudaThreadSynchronize();
	return 0;
}

//float float to Complex
__global__ void multiCuda_Kernel(float*arrin1,float*arrin2 ,cucomplex_E *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid].Re=arrin1[tid]*arrin2[tid];
		arrout[tid].Im=0;
		tid+=gridDim.x*blockDim.x;
	}
}
int multiCuda(float *arrin1,float *arrin2, cucomplex_E *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	multiCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin1,arrin2,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//Complex float to float
__global__ void multiCuda_Kernel(cucomplex_E *arrin1,float*arrin2 ,float *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin1[tid].Re*arrin2[tid];
		tid+=gridDim.x*blockDim.x;
	}
}
int multiCuda(cucomplex_E *arrin1,float *arrin2,float *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	multiCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin1,arrin2,arrout,n);
	cudaThreadSynchronize();
	return 0;
}

//--------------------------------------------------------------//
//add--------------------------------------------------------------//
//pure float 
__global__ void addCuda_Kernel(float*arrin1,float*arrin2 ,float *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin1[tid]+arrin2[tid];
		tid+=gridDim.x*blockDim.x;
	}
}
int addCuda(float*arrin1,float *arrin2,float *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	addCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin1,arrin2,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//pure  cucomplex
__global__ void addCuda_Kernel(cucomplex_E *arrin1,cucomplex_E *arrin2 ,cucomplex_E *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid].Re=arrin1[tid].Re+arrin2[tid].Re;
		arrout[tid].Im=arrin1[tid].Im+arrin2[tid].Im;
		tid+=gridDim.x*blockDim.x;
	}
}
int addCuda(cucomplex_E*arrin1,cucomplex_E *arrin2,cucomplex_E *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	addCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin1,arrin2,arrout,n);
	cudaThreadSynchronize();
	return 0;
}

//--------------------------------------------------------------//
//multiByNumber--------------------------------------------------------------//
//pure float
__global__ void multiByNumberCuda_Kernel(float*arrin,float num,float *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin[tid]*num;
		tid+=gridDim.x*blockDim.x;
	}
}
int multiByNumberCuda(float*arrin,float num,float *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	multiByNumberCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin,num,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//pure cucomplex
__global__ void multiByNumberCuda_Kernel(cucomplex_E*arrin,cucomplex_E num,cucomplex_E *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid].Re=arrin[tid].Re*num.Re-arrin[tid].Im*num.Im;
		arrout[tid].Im=arrin[tid].Re*num.Im+arrin[tid].Im*num.Re;
		tid+=gridDim.x*blockDim.x;
	}
}
int multiByNumberCuda(cucomplex_E*arrin,cucomplex_E num,cucomplex_E *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	multiByNumberCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin,num,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//cucomplex by float
__global__ void multiByNumberCuda_Kernel(cucomplex_E*arrin,float num,cucomplex_E *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid].Re=arrin[tid].Re*num;
		arrout[tid].Im=arrin[tid].Im*num;
		tid+=gridDim.x*blockDim.x;
	}
}
int multiByNumberCuda(cucomplex_E*arrin,float num,cucomplex_E *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	multiByNumberCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin,num,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//cucomplex to float
__global__ void multiByNumberCuda_Kernel(cucomplex_E*arrin,float num,float *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin[tid].Re*num;
		tid+=gridDim.x*blockDim.x;
	}
}

int multiByNumberCuda(cucomplex_E*arrin,float num,float *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	multiByNumberCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin,num,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//float to cucomplex 
__global__ void multiByNumberCuda_Kernel(float*arrin,float num,cucomplex_E *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid].Re=arrin[tid]*num;
		arrout[tid].Im=0;
		tid+=gridDim.x*blockDim.x;
	}
}

int multiByNumberCuda(float*arrin,float num,cucomplex_E *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	multiByNumberCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin,num,arrout,n);
	cudaThreadSynchronize();
	return 0;
}



//squre--------------------------------------------------------------//
__global__ void squareCuda_Kernel(float* arrin,float*arrout,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin[tid]*arrin[tid];
		tid+=gridDim.x*blockDim.x;
	}
}
//--------------------------------------------------------------//
int showArrayCuda(float* arrin_dev,int n,bool ShowAll){
	float *tarr;
	tarr=(float*)malloc(sizeof(float)*n);
	cudaMemcpy(tarr,arrin_dev,sizeof(float)*n,cudaMemcpyDeviceToHost);
	for (int i=0;i<n;i++){
		if (tarr[i]!=tarr[i]){
			printf("%15.7E occured at tid == %d\n",tarr[i],i);
			return 99;
		}
		if (ShowAll)printf("%15.7E\n",tarr[i]);
	}
	free(tarr);
	return 0;
}
int showArrayC(float* arrin,int n,bool ShowAll){
	for (int i=0;i<n;i++){
		if (arrin[i]!=arrin[i]){
			printf("%15.7E occured at tid == %d\n",arrin[i],i);
			return 99;
		}
		if (ShowAll)printf("%15.7E\n",arrin[i]);
	}
	return 0;
}
//--------------------------------------------------------------//
//divi--------------------------------------------------------------//
//pure float 
__global__ void diviCuda_Kernel(float*arrin1,float*arrin2 ,float *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin1[tid]/arrin2[tid];
		tid+=gridDim.x*blockDim.x;
	}
}
int diviCuda(float*arrin1,float *arrin2,float *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	diviCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin1,arrin2,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//pure  cucomplex
__global__ void diviCuda_Kernel(cucomplex_E *arrin1,cucomplex_E *arrin2 ,cucomplex_E *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid].Re=(arrin1[tid].Re*arrin2[tid].Re+arrin1[tid].Im*arrin2[tid].Im)/(arrin2[tid].Re*arrin2[tid].Re+arrin2[tid].Im*arrin2[tid].Im);
		arrout[tid].Im=(arrin1[tid].Im*arrin2[tid].Re-arrin1[tid].Re*arrin2[tid].Im)/(arrin2[tid].Re*arrin2[tid].Re+arrin2[tid].Im*arrin2[tid].Im);
		tid+=gridDim.x*blockDim.x;
	}
}
int diviCuda(cucomplex_E *arrin1,cucomplex_E *arrin2,cucomplex_E *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	diviCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin1,arrin2,arrout,n);
	cudaThreadSynchronize();
	return 0;
}

//--------------------------------------------------------------//
//--------------------------------------------------------------//
//multiByNumber--------------------------------------------------------------//
//pure float
__global__ void addByNumberCuda_Kernel(float*arrin,float num,float *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid]=arrin[tid]+num;
		tid+=gridDim.x*blockDim.x;
	}
}
int addByNumberCuda(float*arrin,float num,float *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	addByNumberCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin,num,arrout,n);
	cudaThreadSynchronize();
	return 0;
}
//pure cucomplex
__global__ void addByNumberCuda_Kernel(cucomplex_E*arrin,cucomplex_E num,cucomplex_E *arrout ,int n){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	while (tid<n){
		arrout[tid].Re=arrin[tid].Re+num.Re;
		arrout[tid].Im=arrin[tid].Im+num.Im;
		tid+=gridDim.x*blockDim.x;
	}
}
int addByNumberCuda(cucomplex_E*arrin,cucomplex_E num,cucomplex_E *arrout ,int n){
	int griddim=(n+maxThreadsDim-1)/maxThreadsDim;if (griddim>MaxBlocksDim)griddim=MaxBlocksDim;
	addByNumberCuda_Kernel<<<griddim,maxThreadsDim>>>(arrin,num,arrout,n);
	cudaThreadSynchronize();
	return 0;
}


