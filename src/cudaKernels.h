//save the many 

const int NxL=nz*ny*nx,NyL=ny*nz,NzL=nz,NnL=nz*ny*nx*np;//NxLev means x have a base of NxLev
const int NnpLev=nz*ny*nx,NxLev=ny*nz,NyLev=nz,NzLev=1;
const int n=nz*ny*nx*np;//NxLev means x have a base of NxLev
__device__ int xn(int tid){ return (tid+NyL)%NxL+(tid/NxL)*NxL; }
__device__ int xp(int tid){ return (tid-NyL+NxL)%NxL+(tid/NxL)*NxL; }
__device__ int yn(int tid){ return (tid+NzL)%NyL+(tid/NyL)*NyL; }
__device__ int yp(int tid){ return (tid-NzL+NyL)%NyL+(tid/NyL)*NyL; }
__device__ int zn(int tid){ return (tid+1)%NzL+(tid/NzL)*NzL; }
__device__ int zp(int tid){ return (tid-1+NzL)%NzL+(tid/NzL)*NzL; }
__device__ int ni(int tid,int i){ return tid%NnL+i*NnL;}// i is the index of dimension (i,x,y,z)...

__global__ void Grad_Kernel(float *fgrad,float*grad,float*ppsi,float dx){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
//	while (tid<n){
		fgrad[tid]=(
				 pow2_E(ppsi[xn(tid)] -ppsi[xp(tid)])
				+pow2_E(ppsi[yn(tid)] -ppsi[yp(tid)])
				+pow2_E(ppsi[zn(tid)] -ppsi[zp(tid)])
				)*(1.00/dx/dx);
		grad[tid]=(
				 (ppsi[xn(tid)] +ppsi[xp(tid)])
				+(ppsi[yn(tid)] +ppsi[yp(tid)])
				+(ppsi[zn(tid)] +ppsi[zp(tid)])
				-6.0f*ppsi[tid]
				)*(1.00/dx/dx);
//		tid+=gridDim.x*blockDim.x;
//	}
}
__global__ void Bulk_Kernel(float *flan,float*ppsi){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
//	while (tid<NnpLev){
		flan[tid]=
			( pow2_E(ppsi[tid])+pow2_E(ppsi[n+tid])+pow2_E(ppsi[n+n+tid]))*0.50f
			-(pow4_E(ppsi[tid])+pow4_E(ppsi[n+tid])+pow4_E(ppsi[n+n+tid]))*0.250f
			+pow3_E(pow2_E(ppsi[tid])+pow2_E(ppsi[n+tid])+pow2_E(ppsi[n+n+tid]))*0.166666666667f;
//		tid+=gridDim.x*blockDim.x;
//	}
}
__global__ void DrivingForce_Kernel(float *lan,cucomplex_E*ppsi2n,float*ppsi,float* localStress,float a1,float a2,float a3){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
//	while (tid<n){
		if (ppsi[tid]<0){
			lan[tid]=ppsi[tid]*(a1-a2*ppsi[tid]
					+a3*(pow2_E(ppsi[tid%NnpLev])+pow2_E(ppsi[tid%NnpLev+NnpLev])
						+pow2_E(ppsi[tid%NnpLev+NnpLev*2])+pow2_E(ppsi[tid%NnpLev+NnpLev*3])
						));
		}else{
			lan[tid]= ppsi[tid]*
				(a1-a2*pow2_E(ppsi[tid])
				 +a3*pow2_E(pow2_E(ppsi[tid%NnpLev])+pow2_E(ppsi[tid%NnpLev+NnpLev])
					 +pow2_E(ppsi[tid%NnpLev+NnpLev*2])+pow2_E(ppsi[tid%NnpLev+NnpLev*3])
					 )
				);//-localStress[tid]*(0.5+a2*pow(ppsi[tid],2));
		}
//		tid+=gridDim.x*blockDim.x;
//	}
}
__global__ void BpqElastic_Kernel(cucomplex_E *_ReciprocalElasticTerm,cucomplex_E*ppsi2n,float* bpq){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	float re,im;
//	while (tid<n){
		for (int j=0;j<np;j++){
			re=re+bpq[j*NnpLev+(tid/NnpLev)*n+tid%NnpLev]*ppsi2n[j*NnpLev+tid%NnpLev].Re;
			im=im+bpq[j*NnpLev+(tid/NnpLev)*n+tid%NnpLev]*ppsi2n[j*NnpLev+tid%NnpLev].Im;
		}
		_ReciprocalElasticTerm[tid].Re=re;
		_ReciprocalElasticTerm[tid].Im=im;
//		tid+=gridDim.x*blockDim.x;
//	}
}
__global__ void Evolution_Kernel(float*ppsi,float*precippo,float*grad,float*lan,float*relast,float*extressenergy,float*_Noise,float dt,float betaa,float xi){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
//	while (tid<n){
		ppsi[tid]=
			(ppsi[tid]+dt*(
					-(-betaa*grad[tid]+lan[tid])
					-xi*relast[tid]*ppsi[tid]
					-extressenergy[tid]*ppsi[tid]
					)
			// +0.02f
			//+0.02f*(((tid%NnpLev)/NxLev+(tid%NxLev)/NyLev+(tid%NyLev)+3.0f)*(1.0f/(nx*3)))*1
			+_Noise[tid]//(
			)*uperTrunc(precippo[tid%NnpLev],0.8f);
//		tid+=gridDim.x*blockDim.x;
//	}
	return;
}

