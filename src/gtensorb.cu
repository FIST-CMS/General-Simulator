
#define DEBUG 0
#include"../include/datamain.th"
#include"gtensorb.h"
using namespace GUPS_NS;
using namespace DATA_NS;


__host__ __device__ real GTensorB_VF(int x,int n,float dx){
  int tem; if (x<n/2) tem=x; else tem=x-n;
  return 2.0f*3.14f*dx/n*tem; 
}

__global__ void unitVector_gtensorb_kernel(Real *_g, Real *_gSquare, Real *unitVector,real dx, real dy, real dz){
  int x=blockIdx.x, y=blockIdx.y,z=threadIdx.x;
  int nx=gridDim.x, ny=gridDim.y,nz=blockDim.x;
  int tid=(x*ny+y)*nz+z; //tid =(x,y,z);
  int tidd=tid*3; // tidd+d = (x,y,z,d); d:0 1 2
  Real gx,gy,gz,mo;
  _g[tidd+0]=gx=GTensorB_VF(x,nx,dx);
  _g[tidd+1]=gy=GTensorB_VF(y,ny,dy);
  _g[tidd+2]=gz=GTensorB_VF(z,nz,dz);
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

int  GTensorB::UnitVector(real dx,real dy, real dz){  int nx= _g.Dimension[1], ny= _g.Dimension[2], nz= _g.Dimension[3];
  dim3 bn(nx,ny),tn(nz);
  unitVector_gtensorb_kernel<<<bn,tn>>>
	(_g.Arr_dev, _gSquare.Arr_dev, unitVector.Arr_dev,
	 dx,dy,dz);
  return 0;
}

int GTensorB::InitB (int variantN1,int variantN2,
					int lx, int ly, int lz,
					real a1, real a2, real a3,
					Data<Real> &tensor ){

  Init(5,variantN1, variantN2, lx, ly, lz,Data_HOST_DEV);
  _g.Init(4,lx,ly,lz,3,Data_HOST_DEV);
  _gSquare.Init(3,lx,ly,lz,Data_HOST_DEV);
  unitVector.Init(4,lx,ly,lz,3,Data_HOST_DEV);
  sigma.Init(3,variantN1+variantN2,3,3,Data_HOST_DEV);
  //unitvector
  UnitVector(a1,a2,a3);
  _g.DeviceToHost(); // will be use in this function
  _gSquare.DeviceToHost(); // ..
  unitVector.DeviceToHost(); // ..
  //stress  sigma(sa,j,i)
  SetCalPos(Data_HOST);
  cijkl.Init(4,3,3,3,3); cijkl=0.f;
  cijkl(0,0,0,0) =C00; cijkl(1,1,1,1) =C00; cijkl(2,2,2,2) =C00;
  cijkl(0,0,1,1) =C01; cijkl(1,1,2,2) =C01; cijkl(2,2,0,0) =C01;
  cijkl(0,1,0,1) =C33; cijkl(1,2,1,2) =C33; cijkl(2,0,2,0) =C33;
  cijkl(1,1,0,0) =C01; cijkl(2,2,1,1) =C01; cijkl(0,0,2,2) =C01;
  cijkl(1,0,1,0) =C33; cijkl(0,1,1,0) =C33; cijkl(1,0,0,1) =C33;
  cijkl(2,1,2,1) =C33; cijkl(2,1,1,2) =C33; cijkl(1,2,2,1) =C33;
  cijkl(0,2,0,2) =C33; cijkl(0,2,2,0) =C33; cijkl(2,0,0,2) =C33;	
  //*
  cijkl(1-1,1-1,1-1,1-1) =5.39  ;//c11
  cijkl(2-1,2-1,2-1,2-1) =5.39  ;//c11
  cijkl(3-1,3-1,3-1,3-1) =5.22  ;//c11
  cijkl(1-1,1-1,2-1,2-1) =3.39  ;//c12
  cijkl(2-1,2-1,3-1,3-1) =3.56  ;//c12
  cijkl(3-1,3-1,1-1,1-1) =3.56  ;//c12
  cijkl(1-1,2-1,1-1,2-1) =0.6   ;//c44
  cijkl(2-1,3-1,2-1,3-1) =0.77  ;//c44
  cijkl(3-1,1-1,3-1,1-1) =0.77  ;//c44

  cijkl(2-1,2-1,1-1,1-1) =3.39  ;//c12
  cijkl(3-1,3-1,2-1,2-1) =3.56  ;//c12
  cijkl(1-1,1-1,3-1,3-1) =3.56  ;//c12
  cijkl(2-1,1-1,2-1,1-1) =0.60  ;//c44
  cijkl(1-1,2-1,2-1,1-1) =0.60  ;//c44
  cijkl(2-1,1-1,1-1,2-1) =0.60  ;//c44
  cijkl(3-1,2-1,3-1,2-1) =0.77  ;//c44
  cijkl(3-1,2-1,2-1,3-1) =0.77  ;//c44
  cijkl(2-1,3-1,3-1,2-1) =0.77  ;//c44
  cijkl(1-1,3-1,1-1,3-1) =0.77  ;//c44
  cijkl(1-1,3-1,3-1,1-1) =0.77  ;//c44
  cijkl(3-1,1-1,1-1,3-1) =0.77  ;//c44
  // */

  cijkl.HostToDevice(); // main cal is on device

  sigma=0.f;
  for (int sa=0; sa<variantN1+variantN2; sa++){
    for (int i=0;i<3;i++)
	 for (int j=0;j<3;j++){
	   for (int k=0;k<3;k++)
		for (int l=0;l<3;l++){
		  sigma(sa,i,j)+=cijkl(i,j,k,l)*tensor(sa,k,l);
		}
	 }
  }
  sigma.HostToDevice();

  //-------------------------------------------------------------------
  //omega
  omega.Init(2,3,3,Data_HOST_DEV);
  iomega.Init(2,3,3,Data_HOST_DEV);
  temp.Init(2,3,3,Data_HOST_DEV);
  for (int ix=0;ix<lx;ix++)
    for (int iy=0;iy<ly;iy++)
	  for (int iz=0;iz<lz;iz++){

		for (int i=0;i<3;i++)
		  for (int j=0;j<3;j++){
			iomega(i,j)=0.0;
			for (int k=0;k<3;k++){
			  for (int l=0;l<3;l++){
				iomega(i,j) = iomega(i,j) + cijkl(i,k,l,j)*unitVector(ix,iy,iz,k)*unitVector(ix,iy,iz,l);
			  }
			}
		  }

		if (_gSquare(ix,iy,iz)==0){ omega=0;}
		else GaussCMInverse(iomega.Arr,temp.Arr,omega.Arr,3);

		Real term=0;
		for (int sa=0; sa<variantN1; sa++){
		  for (int sap=0; sap<variantN2; sap++){
			int index[5]={sa,sap,ix,iy,iz};
			Part(index) =0.0f;
			for (int i=0;i<3;i++)
			  for (int j=0;j<3;j++)
				for (int k=0;k<3;k++)
				  for (int l=0;l<3;l++){ // (/ 31.4 (sqrt 1001)) (/ 3.92 (sqrt 1001))
					term=-unitVector(ix,iy,iz,i)*sigma(sa,i,j)*omega(j,k)*sigma(sap+variantN1,k,l)*unitVector(ix,iy,iz,l);
					Part(index) +=
					  cijkl(i,j,k,l)*tensor(sa,i,j)*tensor(sap+variantN1,k,l)
					  +term;
				  }
		  }
		}
	  }
  HostToDevice();
  //_g.HostToDevice();
  //_gSquare.HostToDevice();
  //unitVector.HostToDevice();
  return 0;
  
}






