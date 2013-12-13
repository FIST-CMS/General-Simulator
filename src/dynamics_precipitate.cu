#define DEBUG 0
////////////////////////////////////////
#include"pub.h"
#include"dynamics.h"
////////////////////////////////////////
#include<curand.h>
#include<cufft.h>
#include"random.h"
#include"gtensorb.h"


#include"dynamics_precipitate.h"


using namespace GS_NS;
using namespace DATA_NS;

int Dynamics_precipitate::Initialize(){
  //para setting should be finished before or within this function
  string ss;
  ss=(*Vars)["gridsize"];    			if (ss!="") ss>>nx>>ny>>nz>>dx>>dy>>dz;
  ss=(*Vars)["deltatime"];             if (ss!="") ss>>DeltaTime;else DeltaTime=0.1;
  ss=(*Vars)["coefficient"];           if (ss!="") ss>>A[1]>>A[2]>>A[3]>>A[4]>>A[5]>>A[6]>>A[7]; else {A[1]=54.0;A[2]=-17.0;A[3]=7.0;A[4]=2.5;A[5]=0.2;A[6]=0.2;A[7]=0.2;}
  ss=(*Vars)["arfi"]; if (ss!="") ss>>Arfi; else Arfi=300.0f;
  ss=(*Vars)["beta"]; if (ss!="") ss>>Beta; else Beta=300.0f;
  ss=(*Vars)["meta"]; if (ss!="") ss>>Meta; else Meta=0.4f;
  ss=(*Vars)["lpp"];  if (ss!="") ss>>Lpp; else Lpp = 0.4f;
  ss=(*Vars)["xi"];   if (ss!="") ss>>Xi; else Xi=400.f;
  ss=(*Vars)["concentration"]; if (ss!="") ss>>Concentration1>>Concentration2; else { Concentration1=0.1; Concentration2=0.44; }
  ss=(*Vars)["weightnoise"]; if (ss!="") { ss>>weightEtaNoise; weightConNoise = weightEtaNoise; } else{ weightEtaNoise= 1.0f; weightConNoise= 1.0f;}
  ////////////////////////////////////////////////////////////
  StrainTensor = &((*Datas)["varianttensor"]);
  if (StrainTensor->Arr == NULL){
	GV<0>::LogAndError<<"Error: variants' strain tensor deoos not set while initialize dynamics\n";
	return -1;
  }
  VariantN=StrainTensor->Dimension[1]; 
  // it is called to initialize the --run-- function
  // allocate memory initial size and default values
  ////////////////////////////////////////////////////////////
  //Init(3,nx,ny,nz,Data_NONE);
  SetCalPos(Data_HOST_DEV);
  Concentration = &((*Datas)["concentration"]);
  if ( Concentration->Arr == NULL ){
	Concentration->Init(3,nx,ny,nz,Data_HOST_DEV);
	SetCalPos(Data_DEV);
	(*Concentration)=Concentration1+(Concentration2-Concentration1)/3; 
  }else{ Concentration->HostToDevice(); }
  Eta = &((*Datas)["eta"]); // may create here
  if ( Eta->Arr == NULL ){
	Eta->Init(4,VariantN,nx,ny,nz,Data_HOST_DEV);
	SetCalPos(Data_DEV);
	(*Eta)=0.0f; 
  }else{ Eta->HostToDevice(); }
  ////////////////////////////////////////////////////////////
  real C00=3.5,C01=1.5,C33=1.0;
  ss=(*Vars)["modulus"];if (ss!="") ss>>C00>>C01>>C33;
  Data<Real> cijkl; SetCalPos(Data_HOST);
  cijkl.Init(4,3,3,3,3,Data_HOST_DEV); cijkl=0.f;
  cijkl(0,0,0,0) =C00; cijkl(1,1,1,1) =C00; cijkl(2,2,2,2) =C00;
  cijkl(0,0,1,1) =C01; cijkl(1,1,2,2) =C01; cijkl(2,2,0,0) =C01;
  cijkl(0,1,0,1) =C33; cijkl(1,2,1,2) =C33; cijkl(2,0,2,0) =C33;
  cijkl(1,1,0,0) =C01; cijkl(2,2,1,1) =C01; cijkl(0,0,2,2) =C01;
  cijkl(1,0,1,0) =C33; cijkl(0,1,1,0) =C33; cijkl(1,0,0,1) =C33;
  cijkl(2,1,2,1) =C33; cijkl(2,1,1,2) =C33; cijkl(1,2,2,1) =C33;
  cijkl(0,2,0,2) =C33; cijkl(0,2,2,0) =C33; cijkl(2,0,0,2) =C33;			// 
  cijkl.HostToDevice();
  Data<Real> vstrain(3,2*VariantN,3,3,Data_HOST_DEV);
  for (int i=0; i<vstrain.N(); i++)
	vstrain.Arr[i]=StrainTensor->Arr[i%(VariantN*3*3)];
  vstrain.HostToDevice();
  GV<0>::LogAndError<<"calculating space structure tensor \n";
  B.InitB(VariantN,VariantN,nx,ny,nz,dx.Re,dy.Re,dz.Re,vstrain,cijkl); 
  GV<0>::LogAndError<<"finished calculating space structure tensor \n";
  ////////////////////////////////////////////////////////////
  int rank=3,ns[3]={nx,ny,nz},dist=nx*ny*nz,stride=1;
  GV<0>::LogAndError<<"create cuda fft plan \n";
  if (cufftPlanMany(&plan_vn,rank,ns,ns,stride,dist,ns,stride,dist,CUFFT_C2C,VariantN)==CUFFT_SUCCESS)
	GV<0>::LogAndError<<"finish creating cuda fft plan vn \n";
  else GV<0>::LogAndError<<"cuda fft plan vn fails to create\n";
  if (cufftPlan3d(&plan_n,nx,ny,nz,CUFFT_C2C)==CUFFT_SUCCESS)
	GV<0>::LogAndError<<"cuda fft plan n created\n";
  else GV<0>::LogAndError<<"cuda fft plan n fails to create\n";

  int ndim[5]={3,nx,ny,nz};
  int vndim[6]={4,VariantN,nx,ny,nz};

  EtaLFE.Init(vndim,Data_HOST_DEV);
  EtaLFE_CT.Init(vndim,Data_HOST_DEV);
  ConLFE.Init(ndim,Data_HOST_DEV);
  EtaLFE_CT.Init(vndim,Data_HOST_DEV);

  ElasticEnergy.Init(ndim,Data_HOST_DEV);
  ElasticForce.Init(vndim,Data_HOST_DEV);

  Con_CT.Init(ndim,Data_HOST_DEV);
  ConRan_CT.Init(ndim,Data_HOST_DEV);
  RTermCon_CT.Init(ndim,Data_HOST_DEV);

  Eta_CT.Init(vndim,Data_HOST_DEV);
  EtaRan_CT.Init(vndim,Data_HOST_DEV);
  RTermEta_CT.Init(vndim,Data_HOST_DEV);
  ElasticTerm_CT.Init(vndim,Data_HOST_DEV);
  
  Noise_vn.InitRandom(4,VariantN,nx,ny,nz, 0, 0.001, 0,0);
  Noise_n.InitRandom(3,nx,ny,nz, 0, 0.001, 0,0);


  return 0;

}

Dynamics_precipitate::Dynamics_precipitate(){}
Dynamics_precipitate::~Dynamics_precipitate(){
  if (plan_n) cufftDestroy(plan_n);
  if (plan_vn) cufftDestroy(plan_vn);
}

__global__ void LocalConFreeEnergyCalculate_Diffuse_Kernel(Real * ConLFE, Real * Eta, Real* Concentration, Real A1,Real A2, Real Concentration1 , int VariantN ){
  int nx = gridDim.x, ny = gridDim.y, nz = blockDim.x;
  int x=blockIdx.x, y= blockIdx.y, z=threadIdx.x;
  int tid = (x*ny + y)*nz+z; // (x,y,z)
  int nn= nx*ny*nz;
  ConLFE[ tid ] = 0.f;
  for ( int va=0 ; va<VariantN; va++ )
	ConLFE[ tid]+= (A2/2.0f) * ( Eta[ tid + va *nn ]^2 );
  ConLFE[ tid ]+= A1 * ( Concentration[tid] - Concentration1);
}

int Dynamics_precipitate::LocalConFreeEnergyCalculate(){
  dim3 bn(nx,ny), tn(nz);
  LocalConFreeEnergyCalculate_Diffuse_Kernel<<<bn,tn>>>
	(ConLFE.Arr_dev, Eta->Arr_dev, Concentration->Arr_dev, A[1], A[2], Concentration1, VariantN);
  return 0;
}

__global__ void LocalEtaFreeEnergyCalculate_Diffuse_Kernel
(Real* EtaLFE, Real* Eta, Real* Concentration,
 Real A1,Real A2,Real A3, Real A4, Real A5, Real A6, Real A7, Real Concentration2 ){
  int nx = gridDim.x, ny = gridDim.y, nv =gridDim.z, nz = blockDim.x;
  int x  = blockIdx.x, y = blockIdx.y, v =blockIdx.z, z = threadIdx.x;
  int nn = nx * ny * nz;
  int tid  = ( x * ny + y) * nz + z;  //(x,y,z)
  int ntid = (( v * nx + x )* ny + y) *nz + z; //(v,x,y,z)
  Real term2 =0, term4 =0, term22 =0;
  EtaLFE[ ntid ] = 0.f;
  for (int i=0; i<nv; i++)
	if (i!=v){
	term2+= (Eta[tid+i*nn]^2);
	term4+= (Eta[tid+i*nn]^4);
  }
  for (int i=0; i<nv; i++)
	for (int j=0; j<nv; j++)
	  if ( v!=i && v!=j && i!= j)
		term22+= (Eta[i*nn + tid]^2)*(Eta[j*nn + tid ]^2);
  EtaLFE[ ntid ] =
	(2.f * A5 * Eta[ntid] + 4.f * A6 * (Eta[ntid] ^3))* term2
	+(2.0f * A6 * Eta[ntid]) * term4
	+(2.0f * A7 * Eta[ntid]) * term22
	+(A2 * Eta[ntid] * ( Concentration[tid] - Concentration2 ))
	-(A3 * (Eta[ntid]^3))
	+(A4 * (Eta[ntid]^5));
}

int Dynamics_precipitate::LocalEtaFreeEnergyCalculate(){
  dim3 bn(nx,ny,VariantN), tn(nz,1,1);
  LocalEtaFreeEnergyCalculate_Diffuse_Kernel<<<bn,tn>>>(EtaLFE.Arr_dev,Eta->Arr_dev,Concentration->Arr_dev,A[1],A[2],A[3],A[4],A[5],A[6],A[7],Concentration2);
  return 0;
}

__global__ void ElasticEnergyForceCalculate_Diffuse_Kernel(Complex *RTerm,Complex*Eta_sq,Real* B){
  int VariantN=gridDim.z;
  int nx= gridDim.x, ny= gridDim.y, nz = blockDim.x;
  int x = blockIdx.x, y = blockIdx.y, z = threadIdx.x, v = blockIdx.z;
  RTerm[((v*nx+x)*ny+y)*nz+z]=0.f;
  for (int i=0;i<VariantN;i++){
	RTerm[((v*nx+x)*ny+y)*nz+z]+=B[(((v*VariantN+i)*nx+x)*ny+y)*nz+z]* Eta_sq[((i*nx+x)*ny+y)*nz+z];
  }
}

int Dynamics_precipitate::ElasticForceCalculate(){
  SetCalPos(Data_DEV);
  Eta_CT=(*Eta)*(*Eta); //Store it in the buffer area
  ///////////////////////////////////////////////////////////////
  cufftExecC2C(plan_vn,(cufftComplex*)Eta_CT.Arr_dev,(cufftComplex*)Eta_CT.Arr_dev,CUFFT_FORWARD);
  Eta_CT = Eta_CT/Eta_CT.N()*VariantN; // equavilent to /(nx*ny*nz)
  ///////////////////////////////////////////////////////////////
  dim3 bn(nx,ny,VariantN);
  dim3 tn(nz);
  ElasticEnergyForceCalculate_Diffuse_Kernel<<<bn,tn>>>
	(RTermEta_CT.Arr_dev,Eta_CT.Arr_dev,B.Arr_dev);
  cufftExecC2C(plan_vn,(cufftComplex*)RTermEta_CT.Arr_dev,(cufftComplex*)RTermEta_CT.Arr_dev,CUFFT_INVERSE);
  ///////////////////////////////////////////////////////////////
  ElasticForce = 2.0f* RTermEta_CT* (*Eta); // the coefficient 2.0f is ....????
  return 0;
}

__global__ void ConcentrationUpdate_Diffuse_Kernel(Complex *Con_CT, Complex* ConLFE_CT, Complex* ConRan_CT, Real* gSquare, Real dt, Real meta,Real beta, Real weightConNoise){
  //int nx = gridDim.x;
  int ny = gridDim.y, nz = blockDim.x;
  int x=blockIdx.x, y= blockIdx.y, z=threadIdx.x;
  int tid = (x*ny + y)*nz+z; //(x,y,z)
  //int nn= nx*ny*nz;
  Con_CT[tid] =
	( Con_CT[tid] - meta * gSquare[tid] *dt * ( ConLFE_CT[tid] + 0.0001f*weightConNoise * ConRan_CT[tid] ) )
	/ ( 1.0f + dt * meta * beta * gSquare[tid] * gSquare[tid] );
}

int Dynamics_precipitate::ConcentrationUpdate(){
  SetCalPos(Data_DEV);
  Noise_n.NewNormal_device(); cudaThreadSynchronize();
  set_device(ConRan_CT.Arr_dev,Noise_n.Arr_dev, ConRan_CT.N());
  Con_CT = *Concentration; ///real((nx*ny*nz));
  ConLFE_CT = ConLFE;
  if (DEBUG){ConRan_CT.DeviceToHost(); Con_CT.DeviceToHost(); ConLFE_CT.DeviceToHost(); }
  ///////////////////////////////////////////////////////////
  cufftExecC2C(plan_n,(cufftComplex*)ConRan_CT.Arr_dev,(cufftComplex*)ConRan_CT.Arr_dev, CUFFT_FORWARD); 
  cufftExecC2C(plan_n,(cufftComplex*)Con_CT.Arr_dev,(cufftComplex*)Con_CT.Arr_dev, CUFFT_FORWARD); 
  cufftExecC2C(plan_n,(cufftComplex*)ConLFE_CT.Arr_dev,(cufftComplex*)ConLFE_CT.Arr_dev, CUFFT_FORWARD); 
  //////////////////
  divi_device(Con_CT.Arr_dev,Con_CT.Arr_dev,real(nx*ny*nz),Con_CT.N());
  divi_device(ConRan_CT.Arr_dev, ConRan_CT.Arr_dev,real(nx*ny*nz),ConRan_CT.N());
  divi_device(ConLFE_CT.Arr_dev, ConLFE_CT.Arr_dev,real(nx*ny*nz),ConLFE_CT.N());
  if (DEBUG){ConRan_CT.DeviceToHost(); Con_CT.DeviceToHost(); ConLFE_CT.DeviceToHost(); }
  if (DEBUG) { ConRan_CT=0.f; }
  /////////////////
  ///////////////////////////////////////////////////////////
  // the factor nx*ny*nz within the transformation
  dim3 bn(nx,ny);
  dim3 tn(nz);
  ConcentrationUpdate_Diffuse_Kernel<<<bn,tn>>>(Con_CT.Arr_dev,ConLFE_CT.Arr_dev, ConRan_CT.Arr_dev, B._gSquare.Arr_dev, DeltaTime, Meta ,Beta, weightConNoise);
  cufftExecC2C(plan_n,(cufftComplex*)Con_CT.Arr_dev, (cufftComplex*)Con_CT.Arr_dev, CUFFT_INVERSE);
  ///////////////////////////////////////////////////////////
  (*Concentration) = Con_CT; // / real(sqrt(nx*ny*nz)); // be done before the update
  if (DEBUG) { Concentration->DeviceToHost(); }
  return 0;
}

__global__ void EtaUpdate_Diffuse_Kernel(
	Complex* Eta, Complex* ElasticTerm, Complex* EtaRan, Real* gSquare,
	Real DeltaTime, Real weightEtaNoise,Real lpp,Real arfi) {
  //int nv = gridDim.z;
  int nx=gridDim.x,ny=gridDim.y,nz = blockDim.x;
  int v = blockIdx.z;
  int x=blockIdx.x, y=blockIdx.y, z=threadIdx.x;
  int tid = (( v* nx+x )*ny + y)*nz+z; //(v,x,y,z)
  int ntid = ( x*ny + y )*nz+ z;       //(x,y,z)

  Eta[tid]=
	(Eta[tid]
	 - DeltaTime * lpp *( ElasticTerm[tid] + 0.0001f*weightEtaNoise* EtaRan[tid]))  
	/(1.0f + DeltaTime* lpp* arfi * gSquare[ntid] );
}

int Dynamics_precipitate::EtaUpdate(){
  SetCalPos(Data_DEV);
  Noise_vn.NewNormal_device();
  set_device(EtaRan_CT.Arr_dev, Noise_vn.Arr_dev, EtaRan_CT.N());
  EtaRan_CT = EtaRan_CT; ///real(sqrt(nx*ny*nz));
  Eta_CT = (*Eta);///real(sqrt(nx*ny*nz));
  ///////////////////////////////////////////////////////////
  ElasticTerm_CT = ( Xi * ElasticForce + EtaLFE); ///real(sqrt(nx*ny*nz));
  ///////////////////////////////////////////////////////////
  if (DEBUG) { Eta_CT.DeviceToHost(); ElasticTerm_CT.DeviceToHost();ElasticForce.DeviceToHost(); EtaLFE.DeviceToHost(); }
  cufftExecC2C(plan_vn, (cufftComplex*)EtaRan_CT.Arr_dev,(cufftComplex*)EtaRan_CT.Arr_dev,CUFFT_FORWARD);
  cufftExecC2C(plan_vn, (cufftComplex*)Eta_CT.Arr_dev, (cufftComplex*)Eta_CT.Arr_dev, CUFFT_FORWARD);
  cufftExecC2C(plan_vn, (cufftComplex*)ElasticTerm_CT.Arr_dev, (cufftComplex*) ElasticTerm_CT.Arr_dev, CUFFT_FORWARD);
  divi_device(EtaRan_CT.Arr_dev , EtaRan_CT.Arr_dev,real(nx*ny*nz),EtaRan_CT.N());
  divi_device(Eta_CT.Arr_dev,Eta_CT.Arr_dev, real(nx*ny*nz),Eta_CT.N());
  divi_device(ElasticTerm_CT.Arr_dev, ElasticTerm_CT.Arr_dev,real(nx*ny*nz),ElasticTerm_CT.N());
  if (DEBUG) { Eta_CT.DeviceToHost(); ElasticTerm_CT.DeviceToHost(); }
  if (DEBUG) { SetCalPos(Data_DEV); EtaRan_CT=0.f; }
  ///////////////////////////////////////////////////////////
  dim3 bn(nx,ny,VariantN), tn(nz);
  EtaUpdate_Diffuse_Kernel<<<bn,tn>>>
	(Eta_CT.Arr_dev, ElasticTerm_CT.Arr_dev , EtaRan_CT.Arr_dev, B._gSquare.Arr_dev,
	 DeltaTime, weightEtaNoise, Lpp, Arfi );
  ///////////////////////////////////////////////////////////
  cufftExecC2C(plan_vn, (cufftComplex*)Eta_CT.Arr_dev, (cufftComplex*)Eta_CT.Arr_dev, CUFFT_INVERSE);
  ///////////////////////////////////////////////////////////
  (*Eta)=Eta_CT;
  if (DEBUG) { Eta->DeviceToHost(); }
  return 0;
}


int Dynamics_precipitate::Calculate(){
  string ss;
  (*Vars)["temperature"]>>=Temperature; 
  LocalConFreeEnergyCalculate();
  LocalEtaFreeEnergyCalculate();
  ElasticForceCalculate();
  ////////////////////////////////
  ConcentrationUpdate();
  EtaUpdate();
  ////////////////////////////////
  return 0;
}

int Dynamics_precipitate::RunFunc(string funcName){ return 0;}


int Dynamics_precipitate::Fix(real progress){
  string ss,mode;
  ss = (*Vars)["fix"];
  while( ss!= "" ){
	ss>>mode;
	if      (mode=="temperature"	){
	  real st,et; //start and end temperature
	  ss>>st>>et;
	  ((*Vars)["temperature"])<<=(st+ progress*(et- st));
	} else if (mode=="pressure"		){ 
	} else{
	  GV<0>::LogAndError<<"Error: fix style "<<mode<<" does not find!\n";
	}
  }

  return 0;
}

string Dynamics_precipitate::Get(string ss){ // return the statistic info.
  string var; ss>>var;
  if (var == "temperature") return ToString(Temperature); 
  if (var == "eta_average") return ToString(Eta->TotalDevice()/Eta->N());
  else return "nan";
}
