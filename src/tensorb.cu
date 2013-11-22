
#include"../include/datamain.th"
#include"tensorb.h"
using namespace GUPS_NS;
using namespace DATA_NS;

/*
Real part(Data<Real> &data,int p1){return data(p1);}
Real part(Data<Real> &data,int p1,int p2){return data(p1,p2);}
Real part(Data<Real> &data,int p1,int p2,int p3){return data(p1,p2,p3);}
Real part(Data<Real> &data,int p1,int p2,int p3,int p4){return data(p1,p2,p3,p4);}
Real part(Data<Real> &data,int p1,int p2,int p3,int p4,int p5){return data(p1,p2,p3,p4,p5);}
Real part(Data<Real> &data,int p1,int p2,int p3,int p4,int p5,int p6){return data(p1,p2,p3,p4,p5,p6);}

Complex part(Data<Complex> &data,int p1){return data(p1);}
Complex part(Data<Complex> &data,int p1,int p2){return data(p1,p2);}
Complex part(Data<Complex> &data,int p1,int p2,int p3){return data(p1,p2,p3);}
Complex part(Data<Complex> &data,int p1,int p2,int p3,int p4){return data(p1,p2,p3,p4);}
Complex part(Data<Complex> &data,int p1,int p2,int p3,int p4,int p5){return data(p1,p2,p3,p4,p5);}
Complex part(Data<Complex> &data,int p1,int p2,int p3,int p4,int p5,int p6){return data(p1,p2,p3,p4,p5,p6);}
*/

real TensorB::VF(int x,int n,float dx){
  int tem; if (x<n/2) tem=x; else tem=x-n;
  return 2.0*3.14*dx/n*tem; 
}

int  TensorB::UnitVector(real dx,real dy, real dz){
  int nx= _g.Dimension[1], ny= _g.Dimension[2], nz= _g.Dimension[3];
  Real gx,gy,gz,mo;
  for (int ix=0;ix<nx;ix++){
    for (int iy=0;iy<ny;iy++){
	 for (int iz=0;iz<nz;iz++){
	   _g(ix,iy,iz,0)=gx=VF(ix,nx,dx);
	   _g(ix,iy,iz,1)=gy=VF(iy,ny,dy);
	   _g(ix,iy,iz,2)=gz=VF(iz,nz,dz);
	   _gSquare(ix,iy,iz)=(gx^2)+(gy^2)+(gz^2);
	   mo = sqrt(_gSquare(ix,iy,iz));
	   if (mo > 0.0000005){
		 unitVector(ix,iy,iz,0)=gx/mo;
		 unitVector(ix,iy,iz,1)=gy/mo;
		 unitVector(ix,iy,iz,2)=gz/mo;
	   }else{
		 unitVector(ix,iy,iz,0)=0;
		 unitVector(ix,iy,iz,1)=0;
		 unitVector(ix,iy,iz,2)=0;
	   }
	 }
    }
  }
  return 0;
}

TensorB::TensorB(){
}
  
int TensorB::InitB(int variantN, int lx, int ly, int lz,real a1, real a2, real a3, Data<Real> &tensor ){

  SetCalPos(Data_HOST);
  Init(5,variantN, variantN, lx, ly, lz,Data_HOST_DEV);
  _g.Init(4,lx,ly,lz,3,Data_HOST_DEV);
  _gSquare.Init(3,lx,ly,lz,Data_HOST_DEV);
  unitVector.Init(4,lx,ly,lz,3,Data_HOST_DEV);
  sigma.Init(3,variantN,3,3,Data_HOST_DEV);
  //unitvector
  UnitVector(a1,a2,a3);
  
  //stress  sigma(sa,j,i)
  cijkl.Init(4,3,3,3,3); cijkl=0.f;
  cijkl(0,0,0,0) =C00; cijkl(1,1,1,1) =C00; cijkl(2,2,2,2) =C00;
  cijkl(0,0,1,1) =C01; cijkl(1,1,2,2) =C01; cijkl(2,2,0,0) =C01;
  cijkl(0,1,0,1) =C33; cijkl(1,2,1,2) =C33; cijkl(2,0,2,0) =C33;
  cijkl(1,1,0,0) =C01; cijkl(2,2,1,1) =C01; cijkl(0,0,2,2) =C01;
  cijkl(1,0,1,0) =C33; cijkl(0,1,1,0) =C33; cijkl(1,0,0,1) =C33;
  cijkl(2,1,2,1) =C33; cijkl(2,1,1,2) =C33; cijkl(1,2,2,1) =C33;
  cijkl(0,2,0,2) =C33; cijkl(0,2,2,0) =C33; cijkl(2,0,0,2) =C33;			// 

  SetCalPos(Data_HOST);
  sigma=0.f;
  for (int sa=0;sa<variantN;sa++){
    for (int i=0;i<3;i++)
	 for (int j=0;j<3;j++){
	   for (int k=0;k<3;k++)
		for (int l=0;l<3;l++){
		  sigma(sa,i,j)+=cijkl(i,j,k,l)*tensor(sa,k,l);
		}
	 }
  }

  //-------------------------------------------------------------------
  //omega
  omega.Init(2,3,3,Data_HOST);
  iomega.Init(2,3,3,Data_HOST);
  temp.Init(2,3,3,Data_HOST);
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
		for (int sa=0;sa<variantN;sa++){
		  for (int sap=0;sap<variantN;sap++){
			int index[5]={sa,sap,ix,iy,iz};
			Part(index) =0.0f;
			for (int i=0;i<3;i++)
			  for (int j=0;j<3;j++)
				for (int k=0;k<3;k++)
				  for (int l=0;l<3;l++){ // (/ 31.4 (sqrt 1001)) (/ 3.92 (sqrt 1001))
					term=-unitVector(ix,iy,iz,i)*sigma(sa,i,j)*omega(j,k)*sigma(sap,k,l)*unitVector(ix,iy,iz,l);
					Part(index) +=
					  cijkl(i,j,k,l)*tensor(sa,i,j)*tensor(sap,k,l)
					  +term;
				  }
		  }
		}
	  }
  HostToDevice();
  _g.HostToDevice();
  _gSquare.HostToDevice();
  unitVector.HostToDevice();
  return 0;
  
}
