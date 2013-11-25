
#define DEBUG 0

////////////////////////////////////////
#include"pub.h"
#include"dynamics.h"
////////////////////////////////////////
#include<curand.h>
#include<cufft.h>
#include"random.h"
#include"gtensorb.h"

#include"dynamics_stress.h"

using namespace GS_NS;
using namespace DATA_NS;
/*
  main calculation:
    the structure tensor B
	derivative of order parameter and concentration
 */

int DynamicsStress::Initialize(){
  //para setting should be finished before or within this function
  string ss;

  (((((Vars["gridsize"]>>=nx)>>=ny)>>=nz)>>=dx)>>=dy)>>=dz;
  Xi=4000.0f;  Vars["xi"]>>=Xi;
  StrainTensor = &((*Datas)["varianttensor"]);
  if (StrainTensor->Arr == NULL){
	GV<0>::LogAndError>>"Error: variants' strain tensor does not set while initialize dynamics\n";
	return -1;
  }
  VariantN = StrainTensor->Dimension[1];
  ///////////////////////////////////////////////////
  Stress = &((*Datas)["stress"]); // the assign function will malloc space for Stress
  Defect = &((*Datas)["defect"]); // may create here
  Stress->Init(4,6,nx,ny,nz,Data_HOST_DEV);
  Defect->Init(3,nx,ny,nz,Data_HOST);
  ///////////////////////////////////////////////////
  Eta = &((*Datas)["eta"]); // may create here
  if ( Eta->Arr == NULL ){
	Eta->Init(4,VariantN,nx,ny,nz,Data_HOST_DEV);
	SetCalPos(Data_DEV);
	(*Eta)=0.0f; 
  }else { Eta->HostToDevice(); }
  ////////////////////////////////////////////////////
  Data<Real> cijkl;
  SetCalPos(Data_HOST);
  cijkl.Init(4,3,3,3,3); cijkl=0.f;
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
  Data<Real> *modulus; modulus=&((*Datas)["modulus"]);
  if ( modulus->Arr != NULL )
	cijkl = (*modulus);
  ////////////////////////////////////////////////////
  tensor.Init(3,BaseVariantN+VariantN,3,3,Data_HOST_DEV); 
  SetCalPos(Data_HOST);
  tensor=0.f;
  tensor(0,0,0)=1.0f; tensor(1,0,1)=1.0f; tensor(2,0,2)=1.0f;
  tensor(3,1,1)=1.0f; tensor(4,1,2)=1.0f; tensor(5,2,2)=1.0f;
  for (int i=6*9; i< (6+VariantN)*9; i++)
	tensor[i]=(*StrainTensor)[i-6*9];
  
  GV<0>::LogAndError<<"Calculating space structure tensor \n";
  B.InitB(BaseVariantN,VariantN,nx,ny,nz,dx.Re,dy.Re,dz.Re,tensor,cijkl); 
  GV<0>::LogAndError<<"Calculating space structure finished\n";

  int rank=3,ns[3]={nx,ny,nz},dist=nx*ny*nz,stride=1;
  GV<0>::LogAndError<<"Cuda fft plan is to create\n";
  if (cufftPlanMany(&plan_vn,rank,ns,ns,stride,dist,ns,stride,dist,CUFFT_C2C,VariantN)==CUFFT_SUCCESS)
	GV<0>::LogAndError<<"Cuda fft plan vn is created\n";
  else GV<0>::LogAndError<<"Cuda fft plan vn fails to create\n";

  if (cufftPlanMany(&plan_bvn,rank,ns,ns,stride,dist,ns,stride,dist,CUFFT_C2C,BaseVariantN/*6*/)==CUFFT_SUCCESS)
	GV<0>::LogAndError<<"Cuda fft plan bvn is created\n";
  else GV<0>::LogAndError<<"Cuda fft plan bvn fails to create\n";

  int vndim[6]={4,VariantN,nx,ny,nz};
  int bvndim[6]={4,BaseVariantN,nx,ny,nz};

  Eta_CT.Init(vndim,Data_HOST_DEV);
  RTermEta_CT.Init(bvndim,Data_HOST_DEV);

  return 0;

}

DynamicsStress::DynamicsStress(){}
DynamicsStress::~DynamicsStress(){
  if (plan_vn) cufftDestroy(plan_vn);
  if (plan_bvn) cufftDestroy(plan_bvn);
}

__global__ void ElasticForceCalculate_Stress_Kernel(Complex *ReTerm,Complex*Eta_sq,Real* B,int VariantN,Real Xi){
  //int BaseVariantN = gridDim.z;
  int nx= gridDim.x, ny= gridDim.y, nz = blockDim.x;
  int x = blockIdx.x, y = blockIdx.y, z = threadIdx.x, v = blockIdx.z;
  int nn= nx*ny*nz;
  int nvn=  VariantN* nn;
  int pn= (x*ny +y)*nx+z;
  Complex temp = 0;
  for (int i=0;i<VariantN;i++){
	temp+=Xi*B[ v*nvn + i*nn +pn ]* Eta_sq[ i*nn + pn ];
	if (DEBUG) ReTerm[v*nn+pn]=temp;
  }
  ReTerm[ v*nn + pn ] = temp;
}

int DynamicsStress::ElasticForceCalculate(){
  SetCalPos(Data_DEV);
  //Eta_CT=(*Eta)*(*Eta); //Store it in the buffer area
  Eta_CT=(*Eta); //Store it in the buffer area
  cufftExecC2C(plan_vn,(cufftComplex*)Eta_CT.Arr_dev,(cufftComplex*)Eta_CT.Arr_dev,CUFFT_FORWARD);
  divi_device(Eta_CT.Arr_dev,Eta_CT.Arr_dev ,real(nx*ny*nz) ,Eta_CT.N() ); // seperate transformed
  dim3 bn(nx,ny,BaseVariantN/*6*/);
  dim3 tn(nz);
  ElasticForceCalculate_Stress_Kernel<<<bn,tn>>>
	(RTermEta_CT.Arr_dev,Eta_CT.Arr_dev,B.Arr_dev,VariantN,Xi);
  cufftExecC2C(plan_bvn,(cufftComplex*)RTermEta_CT.Arr_dev,(cufftComplex*)RTermEta_CT.Arr_dev,CUFFT_INVERSE);
  *Stress = - RTermEta_CT;
  return 0;
}

int DynamicsStress::Calculate(){
  string ss;
  
  ElasticForceCalculate();

  SetCalPos(Data_HOST);
  (*Defect)=0.f;
  for (int v=0; v<VariantN; v++)
	for (int i=0; i<nx; i++)
	  for (int j=0; j<ny; j++)
		for (int k=0; k<nz; k++)
		  if (abs((*Eta)(v,i,j,k))>0.9)
			(*Defect)(i,j,k)=1.f;
  
  return 0;
}

int DynamicsStress::RunFunc(string funcName){ return 0; }
 

int DynamicsStress::Fix(real progress){
  string ss,mode;
  return 0;
}

string DynamicsStress::Get(string ss){ // return the statistic info.
  string var; ss>>var;
  return "nan"; 
}
