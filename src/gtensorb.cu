
#define DEBUG 0
#include"../include/datamain.th"
#include"gtensorb.h"
using namespace GUPS_NS;
using namespace DATA_NS;


__host__ __device__ real GTensorB_VF(int x,int n,float dx){
  int tem; if (x<n/2) tem=x; else tem=x-n;
  return 2.0f*3.14f*dx/n*tem; 
}

__global__ void unitVector_gtensorb_kernel(Real *_gSquare, Real *unitVector,real dx, real dy, real dz){
  int x=blockIdx.x, y=blockIdx.y,z=threadIdx.x;
  int nx=gridDim.x, ny=gridDim.y,nz=blockDim.x;
  int tid=(x*ny+y)*nz+z; //tid =(x,y,z);
  int tidd=tid*3; // tidd+d = (x,y,z,d); d:0 1 2
  Real gx,gy,gz,mo;
  gx=GTensorB_VF(x,nx,dx);
  gy=GTensorB_VF(y,ny,dy);
  gz=GTensorB_VF(z,nz,dz);
  _gSquare[tid]=(gx^2)+(gy^2)+(gz^2);
  mo = sqrt(_gSquare[tid]);
  if (mo > 0.0000005){
	unitVector[tidd+0]=gx/mo;
	unitVector[tidd+1]=gy/mo;
	unitVector[tidd+2]=gz/mo;
  }else{
	unitVector[tidd+0]=0;
	unitVector[tidd+1]=0;
	unitVector[tidd+2]=0;
  }
}

int  GTensorB::UnitVector(real dx,real dy, real dz){
  int nx= unitVector.Dimension[1], ny= unitVector.Dimension[2],
	nz= unitVector.Dimension[3];
  dim3 bn(nx,ny),tn(nz);
  unitVector_gtensorb_kernel<<<bn,tn>>>
	(_gSquare.Arr_dev, unitVector.Arr_dev,
	 dx,dy,dz);
  return 0;
}

__global__ void gtensorb_kernel_calculate
(
 Real *B,
 Real*modulus,Real*sigma,Real*tensor,
 Real*unitVector,
 int VariantN1,int VariantN2,
 Real*iomega,Real*omega
 );

int GTensorB::InitB (int variantN1,int variantN2,
					int lx, int ly, int lz,
					real a1, real a2, real a3,
					 Data<Real> &tensor, Data<Real>&modulus ){

  Init(5,variantN1, variantN2, lx, ly, lz,Data_HOST_DEV);
  _gSquare.Init(3,lx,ly,lz,Data_HOST_DEV);
  unitVector.Init(4,lx,ly,lz,3,Data_HOST_DEV);
  ///////////////////////////////////////////////////////
  UnitVector(a1,a2,a3);
  _gSquare.DeviceToHost(); // ..
  unitVector.DeviceToHost(); // ..
  ////////////////////////////////////////////
  Data<Real> sigma;
  sigma.Init(3,variantN1+variantN2,3,3,Data_HOST_DEV);
  sigma=0.f;
  for (int sa=0; sa<variantN1+variantN2; sa++){
    for (int i=0;i<3;i++)
	 for (int j=0;j<3;j++){
	   for (int k=0;k<3;k++)
		for (int l=0;l<3;l++){
		  sigma(sa,i,j)+=modulus(i,j,k,l)*tensor(sa,k,l);
		}
	 }
  }
  sigma.HostToDevice();
  tensor.HostToDevice();
  modulus.HostToDevice();
  //-------------------------------------------------------------------
  ////////////////////////////////////////////////////////////////////
  Data<Real> iomega(5,lx,ly,lz,3,3,Data_DEV); // in order to free in time
  Data<Real> omega(5,lx,ly,lz,3,3,Data_DEV); //as temp variables
  dim3 bn(lx,ly,1), tn(lz,1,1);
  gtensorb_kernel_calculate<<<bn,tn>>>
	(
	 Arr_dev,
	 modulus.Arr_dev,sigma.Arr_dev,tensor.Arr_dev,
	 unitVector.Arr_dev,
	 variantN1,variantN2,
	 iomega.Arr_dev,omega.Arr_dev
	 );

  DeviceToHost();
  //DumpFile("data.structure.factor");
  return 0;
  
}

__global__ void gtensorb_kernel_calculate
(
 Real *B,
 Real *modulus,Real *sigma,Real *tensor,
 Real *unitVector,
 int variantN1,int variantN2,
 Real*iomega,Real*omega
 ){
  int nx= gridDim.x,  ny= gridDim.y,  nz=blockDim.x;
  int ix= blockIdx.x, iy= blockIdx.y, iz=threadIdx.x;
  /////////////////
  for (int i=0;i<3;i++)
	for (int j=0;j<3;j++){
	  iomega[(((ix*ny+iy)*nz+iz)*3+i)*3+j]=0.0f;
	  iomega[(((ix*ny+iy)*nz+iz)*3+i)*3+j]=0.0f;
	  for (int k=0;k<3;k++){
		for (int l=0;l<3;l++){
		  iomega[(((ix*ny+iy)*nz+iz)*3+i)*3+j] += 
			( modulus[((i*3+k)*3+l)*3+j]
			   * unitVector[((ix*ny+iy)*nz+iz)*3+k]
			   * unitVector[((ix*ny+iy)*nz+iz)*3+l]
			   );
		}
	  }
	}
  //////////////////////////////////////////////////////////////////////
  //gtensorb_Inverse3x3((float*)iomega,(float*)omega);
  Real det_m1; Real *m1,*m2; m1=iomega; m2=omega;
  det_m1=
	-m1[((ix*ny+iy)*nz+iz)*9+2]*m1[((ix*ny+iy)*nz+iz)*9+4]*m1[((ix*ny+iy)*nz+iz)*9+6]
	+ m1[((ix*ny+iy)*nz+iz)*9+1]*m1[((ix*ny+iy)*nz+iz)*9+5]*m1[((ix*ny+iy)*nz+iz)*9+6]
	+ m1[((ix*ny+iy)*nz+iz)*9+2]*m1[((ix*ny+iy)*nz+iz)*9+3]*m1[((ix*ny+iy)*nz+iz)*9+7]
	- m1[((ix*ny+iy)*nz+iz)*9+0]*m1[((ix*ny+iy)*nz+iz)*9+5]*m1[((ix*ny+iy)*nz+iz)*9+7]
	- m1[((ix*ny+iy)*nz+iz)*9+1]*m1[((ix*ny+iy)*nz+iz)*9+3]*m1[((ix*ny+iy)*nz+iz)*9+8]
	+ m1[((ix*ny+iy)*nz+iz)*9+0]*m1[((ix*ny+iy)*nz+iz)*9+4]*m1[((ix*ny+iy)*nz+iz)*9+8];
  if (det_m1>=0.00000001f||det_m1<=-0.00000001f){
	m2[((ix*ny+iy)*nz+iz)*9+0]=( -m1[((ix*ny+iy)*nz+iz)*9+5]*m1[((ix*ny+iy)*nz+iz)*9+7] + m1[((ix*ny+iy)*nz+iz)*9+4]*m1[((ix*ny+iy)*nz+iz)*9+8])/det_m1; 
	m2[((ix*ny+iy)*nz+iz)*9+1]=( m1[((ix*ny+iy)*nz+iz)*9+2]*m1[((ix*ny+iy)*nz+iz)*9+7] - m1[((ix*ny+iy)*nz+iz)*9+1]*m1[((ix*ny+iy)*nz+iz)*9+8])/det_m1;
	m2[((ix*ny+iy)*nz+iz)*9+2]=( -m1[((ix*ny+iy)*nz+iz)*9+2]*m1[((ix*ny+iy)*nz+iz)*9+4] + m1[((ix*ny+iy)*nz+iz)*9+1]*m1[((ix*ny+iy)*nz+iz)*9+5])/det_m1;
	m2[((ix*ny+iy)*nz+iz)*9+3]=( m1[((ix*ny+iy)*nz+iz)*9+5]*m1[((ix*ny+iy)*nz+iz)*9+6] - m1[((ix*ny+iy)*nz+iz)*9+3]*m1[((ix*ny+iy)*nz+iz)*9+8])/det_m1;
	m2[((ix*ny+iy)*nz+iz)*9+4]=( -m1[((ix*ny+iy)*nz+iz)*9+2]*m1[((ix*ny+iy)*nz+iz)*9+6] + m1[((ix*ny+iy)*nz+iz)*9+0]*m1[((ix*ny+iy)*nz+iz)*9+8])/det_m1; 
	m2[((ix*ny+iy)*nz+iz)*9+5]=( m1[((ix*ny+iy)*nz+iz)*9+2]*m1[((ix*ny+iy)*nz+iz)*9+3] - m1[((ix*ny+iy)*nz+iz)*9+0]*m1[((ix*ny+iy)*nz+iz)*9+5])/det_m1;
	m2[((ix*ny+iy)*nz+iz)*9+6]=( -m1[((ix*ny+iy)*nz+iz)*9+4]*m1[((ix*ny+iy)*nz+iz)*9+6] + m1[((ix*ny+iy)*nz+iz)*9+3]*m1[((ix*ny+iy)*nz+iz)*9+7])/det_m1; 
	m2[((ix*ny+iy)*nz+iz)*9+7]=( m1[((ix*ny+iy)*nz+iz)*9+1]*m1[((ix*ny+iy)*nz+iz)*9+6] - m1[((ix*ny+iy)*nz+iz)*9+0]*m1[((ix*ny+iy)*nz+iz)*9+7])/det_m1;
	m2[((ix*ny+iy)*nz+iz)*9+8]=( -m1[((ix*ny+iy)*nz+iz)*9+1]*m1[((ix*ny+iy)*nz+iz)*9+3] + m1[((ix*ny+iy)*nz+iz)*9+0]*m1[((ix*ny+iy)*nz+iz)*9+4])/det_m1;
  }else{
	for (int i=0; i<9; i++) m2[((ix*ny+iy)*nz+iz)*9+i]=0.f;
  }

  //////////////////////////////////////////////////////////////////////
  Real term=0;
  for (int sa=0; sa<variantN1; sa++){
	for (int sap=0; sap<variantN2; sap++){
	  B[((((sa*variantN2+sap)*nx+ix)*ny+iy)*nz+iz)]=0.0f;
	  for (int i=0;i<3;i++)
		for (int j=0;j<3;j++)
		  for (int k=0;k<3;k++)
			for (int l=0;l<3;l++){ 
			  term=
				-unitVector[((ix*ny+iy)*nz+iz)*3+i]
				*sigma[(sa*3+i)*3+j]
				*omega[(((ix*ny+iy)*nz+iz)*3+j)*3+k]
				*sigma[((sap+variantN1)*3+k)*3+l]
				*unitVector[((ix*ny+iy)*nz+iz)*3+l];
			  B[((((sa*variantN2+sap)*nx+ix)*ny+iy)*nz+iz)]+=
				modulus[((i*3+j)*3+k)*3+l]// an error
				*tensor[(sa*3+i)*3+j]
				*tensor[((sap+variantN1)*3+k)*3+l]
				+term;
			}
	}
  }
}

