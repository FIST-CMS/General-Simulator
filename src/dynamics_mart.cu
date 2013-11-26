#define DEBUG 0
#include"pub.h"
#include"../include/datamain.th"
#include<curand.h>
#include<cufft.h>
#include"random.h"
//#include"tensorb.h"
#include"gtensorb.h"

#include"dynamics.h"
#include"dynamics_mart.h"


using namespace GS_NS;
using namespace DATA_NS;

int Dynamics_mart::Initialize(){
  /////////////////////////////////////////////////////////
  //para setting should be finished before or within this function
  string ss;
  ss=Vars["gridsize"];    			if (ss!="") ss>>nx>>ny>>nz>>dx>>dy>>dz;


  weightExternal= 0.f;
  weightDislocation= 0.01f; Vars["weightdislocation"]>>=weightDislocation;
  weightNoise = 1.0f; Vars["weightnoise"]>>=weightNoise;
  DeltaTime =0.01f; Vars["deltatime"]>>=DeltaTime;
  weightGradient= 2.5f; Vars["weightgradient"]>>=weightGradient;
  weightChemical= 1.0f; Vars["weightchemical"]>>=weightChemical;
  weightElastic=  100000.0f;  Vars["weightelastic"]>>=weightElastic;
  TransitionTemperature=450.0f; Vars["transitiontemperature"]>>=TransitionTemperature;
  /////////////////////////////////////////////////////////
  LPC[2]=32.05f; LPC[3]=37.5f;
  ss=Vars["coefficient"]; if (ss!="") ss>>LPC[1]>>LPC[2]>>LPC[3];
  /////////////////////////////////////////////////////////
  StrainTensor = &((*Datas)["varianttensor"]);
  if (StrainTensor->Arr == NULL){
	GV<0>::LogAndError>>"Error: variants' strain tensor does not set while initialize dynamics\n";
	return -1;
  }
  VariantN = StrainTensor->Dimension[1];
  /////////////////////////////////////////////////////////
  // it is called to initialize the --run-- function
  // allocate memory initial size and default values
  //Init(3,nx,ny,nz,Data_NONE);
  SetCalPos(Data_HOST_DEV);
  //Eta=eta; // a pointer assign, not value or memory operation
  Eta = &((*Datas)["eta"]); // may create here
  if ( Eta->Arr == NULL ){
	Eta->Init(4,VariantN,nx,ny,nz,Data_HOST_DEV);
	SetCalPos(Data_DEV);
	(*Eta)=0.0f; 
  }else{ Eta->HostToDevice();}
  /////////////////////////////////////////////////////////
  int dim[5]={3,nx,ny,nz};
  int dimN[6]={4,VariantN,nx,ny,nz};

  Noise.InitRandom(4,VariantN,nx,ny,nz, 0, 0.001, 0,0);

  Gradient.Init(dimN,Data_HOST_DEV);
  GradientEnergy.Init(dim,Data_HOST_DEV);
  GradientForce.Init(dimN,Data_HOST_DEV);

  ChemicalEnergy.Init(dim,Data_HOST_DEV);
  ChemicalForce.Init(dimN,Data_HOST_DEV);
  /////////////////////////////////////////////////////////////////
  real C00=3.5f, C01=1.5f, C33=1.0f;//defaut values
  Data<Real> cijkl(4,3,3,3,3,Data_HOST_DEV); SetCalPos(Data_HOST);
  cijkl(0,0,0,0) =C00; cijkl(1,1,1,1) =C00; cijkl(2,2,2,2) =C00;
  cijkl(0,0,1,1) =C01; cijkl(1,1,2,2) =C01; cijkl(2,2,0,0) =C01;
  cijkl(0,1,0,1) =C33; cijkl(1,2,1,2) =C33; cijkl(2,0,2,0) =C33;
  cijkl(1,1,0,0) =C01; cijkl(2,2,1,1) =C01; cijkl(0,0,2,2) =C01;
  cijkl(1,0,1,0) =C33; cijkl(0,1,1,0) =C33; cijkl(1,0,0,1) =C33;
  cijkl(2,1,2,1) =C33; cijkl(2,1,1,2) =C33; cijkl(1,2,2,1) =C33;
  cijkl(0,2,0,2) =C33; cijkl(0,2,2,0) =C33; cijkl(2,0,0,2) =C33;			// 
  Data<Real> *modulus; modulus=&((*Datas)["modulus"]);
  if ( modulus->Arr != NULL )
	cijkl = (*modulus);
  ///////////////////////////
  Data<Real> vstrain(3,2*VariantN,3,3,Data_HOST_DEV);
  for (int i=0; i<2*VariantN*3*3; i++)
	vstrain.Arr[i]=StrainTensor->Arr[i%(VariantN*3*3)];
  ///////////////////////////
  GV<0>::LogAndError<<"Space structure tensor is calculating\n";
  B.InitB(VariantN,VariantN,nx,ny,nz,dx.Re,dy.Re,dz.Re,vstrain,cijkl); 
  GV<0>::LogAndError<<"Calculating of space structure tensor relating to the elastic terms is finished\n";
  /////////////////////////////////////////////////////////////////
  ElasticEnergy.Init(dim,Data_HOST_DEV);
  ElasticForce.Init(dimN,Data_HOST_DEV);
  Eta_RT.Init(dimN,Data_HOST_DEV);
  Eta_CT.Init(dimN,Data_HOST_DEV);
  ReciprocalTerm.Init(dimN,Data_HOST_DEV);
  /////////////////////////////////////////////////////////////////
  int rank=3,ns[3]={nx,ny,nz},dist=nx*ny*nz,stride=1;
  GV<0>::LogAndError<<"Cuda fft plan is to creat\n";
  if (cufftPlanMany(&planAll_Cuda,rank,ns,ns,stride,dist,ns,stride,dist,CUFFT_C2C,VariantN)==CUFFT_SUCCESS)
	GV<0>::LogAndError<<"Cuda fft plan is created\n";
  else GV<0>::LogAndError<<"Cuda fft plan fails to create\n";

  Defect = &((*Datas)["defect"]);
  if (Defect->Arr==NULL){
	Defect->Init(dim,Data_HOST_DEV); // it will be init when read in
	SetCalPos(Data_HOST_DEV);
	(*Defect)=0.0f;
  }else { Defect->HostToDevice();}
  
  /////////////////////////////////////////////////////////////////
  // the 6 component form should be rewriten to 3*3 form
  DislocationStressOForm= &((*Datas)["dislocationstress"]);
  int dim33[6]={5,3,3,nx,ny,nz}; 
  DislocationStress.Init(dim33,Data_HOST_DEV);//it will be also init when read in
  if (DislocationStressOForm->Arr==NULL){
	SetCalPos(Data_HOST_DEV);
	(DislocationStress)=0.0f;
  }else {
	SetCalPos(Data_HOST);
	for (int i=0; i<nx; i++)
	  for (int j=0; j<ny; j++)
		for (int k=0; k<nz; k++){
		  DislocationStress(0,0,i,j,k)=(*DislocationStressOForm)(0,i,j,k);
		  DislocationStress(0,1,i,j,k)=(*DislocationStressOForm)(1,i,j,k);
		  DislocationStress(0,2,i,j,k)=(*DislocationStressOForm)(2,i,j,k);
		  DislocationStress(1,1,i,j,k)=(*DislocationStressOForm)(3,i,j,k);
		  DislocationStress(1,2,i,j,k)=(*DislocationStressOForm)(4,i,j,k);
		  DislocationStress(2,2,i,j,k)=(*DislocationStressOForm)(5,i,j,k);
		  DislocationStress(1,0,i,j,k)=(*DislocationStressOForm)(1,i,j,k);
		  DislocationStress(2,0,i,j,k)=(*DislocationStressOForm)(2,i,j,k);
		  DislocationStress(2,1,i,j,k)=(*DislocationStressOForm)(4,i,j,k);
		}
	DislocationStress.HostToDevice();
  }

  DislocationForce.Init(dimN,Data_HOST_DEV);
  DislocationForceConst.Init(dimN,Data_HOST_DEV);
  DislocationForceInit(); //this only need one calculation
  return 0;
}

Dynamics_mart::Dynamics_mart(){
  //default weight values
}
Dynamics_mart::~Dynamics_mart(){
  if (planAll_Cuda) cufftDestroy(planAll_Cuda);
}

__global__ void Grad_Mart_Kernel(Real *Gradient_arr,  Real* Eta_arr,int *dim, Real dx, Real dy, Real dz){
  // (* 4 128 128) (* 4 128)
  int x=blockIdx.x, y= blockIdx.y, z=threadIdx.x, v=blockIdx.z;
  /**/PPart(Gradient_arr,dim,v,x,y,z)=
	 (PPart(Eta_arr,dim,v,x+1,y,z)+PPart(Eta_arr,dim,v,x-1,y,z)-2*PPart(Eta_arr,dim,v,x,y,z))/(2.0f* dx)/3.0f
	+(PPart(Eta_arr,dim,v,x,y+1,z)+PPart(Eta_arr,dim,v,x,y-1,z)-2*PPart(Eta_arr,dim,v,x,y,z))/(2.0f* dy)/3.0f	
	+(PPart(Eta_arr,dim,v,x,y,z+1)+PPart(Eta_arr,dim,v,x,y,z-1)-2*PPart(Eta_arr,dim,v,x,y,z))/(2.0f* dz)/3.0f	; // */
  /*PPart(Gradient_arr,dim,v,x,y,z)=
	 (PPart(Eta_arr,dim,v,x+1,y,z)+PPart(Eta_arr,dim,v,x-1,y,z)-2*PPart(Eta_arr,dim,v,x,y,z))/(dx^2)
	+(PPart(Eta_arr,dim,v,x,y+1,z)+PPart(Eta_arr,dim,v,x,y-1,z)-2*PPart(Eta_arr,dim,v,x,y,z))/(dy^2)	
	+(PPart(Eta_arr,dim,v,x,y,z+1)+PPart(Eta_arr,dim,v,x,y,z-1)-2*PPart(Eta_arr,dim,v,x,y,z))/(dz^2)	; // */

}
int Dynamics_mart::GradientCalculate(){
  dim3 bn(nx,ny,VariantN);
  dim3 tn(nz);
  Grad_Mart_Kernel<<<bn,tn>>>(Gradient.Arr_dev,  Eta->Arr_dev, Eta->Dimension_dev, dx,dy,dz);
  if (DEBUG) Gradient.DeviceToHost();
  return 0;
}

int Dynamics_mart::GradientEnergyCalculate(){
  return 0;
};

int Dynamics_mart::GradientForceCalculate(){
  GradientCalculate();
  GradientForce= Gradient;
  if (DEBUG) GradientForce.DeviceToHost();
  return 0;
}

int Dynamics_mart::LPCConstruct(){
  LPC[1]=0.02f *(Temperature-TransitionTemperature);
  return 0;
}
__global__ void ChemiEner_Mart_Kernel(Real *ChemE_arr,Real*Eta_arr,int v,Real a1, Real a2, Real a3){
  int tid=blockIdx.x* gridDim.y* blockIdx.x + blockIdx.y* blockDim.x + threadIdx.x ;
  int vn=gridDim.x*gridDim.y*blockDim.x;
  Real term1=0.f,term2=0.f,term3=0.f;
  for (int i=0; i<v; i++) term1=term1+(Eta_arr[tid+i*vn]^2);
  for (int i=0; i<v; i++) term2=term2+(Eta_arr[tid+i*vn]^4);
  term3=(term1^3);
  ChemE_arr[tid]= a1* term1 - a2* term2 + a3* term3;
}

int Dynamics_mart::ChemicalEnergyCalculate(){
  LPCConstruct();
  dim3 bn(nx,ny);
  dim3 tn(nz);
  LPCConstruct();
  ChemiEner_Mart_Kernel<<<bn,tn>>>(ChemicalEnergy.Arr_dev,Eta->Arr_dev,VariantN,LPC[1],LPC[2],LPC[3]);
  if (DEBUG) ChemicalEnergy.DeviceToHost();

  return 0;
}

__global__ void ChemiFor_Mart_Kernel(Real*ChemiForce_arr,Real*Eta_arr,int v,Real a1,Real a2,Real a3){// n1*n2*n3 each variant have an driving force
  int tid=blockIdx.x* gridDim.y* blockDim.x
	+ blockIdx.y* blockDim.x 
	+ threadIdx.x ;
  int vn=gridDim.x*gridDim.y*blockDim.x;
  Real term3=0;
  for (int i=0;i<v;i++)
	term3=term3+(Eta_arr[tid+i*vn]^2);
  for (int i=0;i<v;i++){
	if (Eta_arr[tid+i*vn]<0){//1 2 3 and for energy it is 2 3 4 
	  ChemiForce_arr[tid+i*vn]= Eta_arr[tid+i*vn]* ( a1 - a2* Eta_arr[tid+i*vn] + a3*term3 );
	}else{//1 3 5  //For energy it is 2 4 6
	  ChemiForce_arr[tid+i*vn]= Eta_arr[tid+i*vn]* ( a1 - a2*(Eta_arr[tid+i*vn]^2) + a3*(term3^2) );
	} //(sqrt (/ 9608  37.5))
  }
}

int Dynamics_mart::ChemicalForceCalculate(){
  dim3 bn(nx,ny);
  dim3 tn(nz);
  LPCConstruct();
  ChemiFor_Mart_Kernel<<<bn,tn>>>(ChemicalForce.Arr_dev, Eta->Arr_dev, VariantN, LPC[1], LPC[2], LPC[3]);
  if (DEBUG) ChemicalForce.DeviceToHost();
  return 0;
} //(* 2373 0.9)

__global__ void ElaFor_Mart_Kernel(Complex *ReTerm,Complex*Eta_sq,Real* B){
  int v=gridDim.x;
  int nv= gridDim.x* gridDim.y *gridDim.z *blockDim.x;
  int n=  gridDim.y *gridDim.z *blockDim.x;
  int pvv = blockIdx.x;
  int pn= blockIdx.y *gridDim.z*blockDim.x + blockIdx.z *blockDim.x + threadIdx.x;
  ReTerm[pvv*n +pn] = 0;
  for (int i=0;i<v;i++)
	ReTerm[pvv*n +pn] +=  B[pvv*nv + i*n +pn ]* Eta_sq[i*n + pn ];
}
int Dynamics_mart::ElasticForceCalculate(){
  SetCalPos(Data_DEV);
  Eta_CT=(*Eta)*(*Eta); //Store it in the buffer area
  cudaThreadSynchronize();
  if (DEBUG) Eta_CT.DeviceToHost();
  cufftExecC2C(planAll_Cuda,(cufftComplex*)Eta_CT.Arr_dev,(cufftComplex*)Eta_CT.Arr_dev,CUFFT_FORWARD);
  if (DEBUG) Eta_CT.DeviceToHost();
  dim3 bn(VariantN,nx,ny);
  dim3 tn(nz);
  cudaThreadSynchronize();
  Eta_CT = Eta_CT/Eta_CT.N()*VariantN;
  cudaThreadSynchronize();
  if (DEBUG) {Eta_CT.DeviceToHost();}
  ElaFor_Mart_Kernel<<<bn,tn>>>(ReciprocalTerm.Arr_dev,Eta_CT.Arr_dev,B.Arr_dev);
  cudaThreadSynchronize();
  if (DEBUG) ReciprocalTerm.DeviceToHost();
  cufftExecC2C(planAll_Cuda,(cufftComplex*)ReciprocalTerm.Arr_dev,(cufftComplex*)ReciprocalTerm.Arr_dev,CUFFT_INVERSE);
  cudaThreadSynchronize();
  if (DEBUG) ReciprocalTerm.DeviceToHost();
  ElasticForce = ReciprocalTerm* (*Eta);
  cudaThreadSynchronize();
  if (DEBUG) ElasticForce.DeviceToHost();

  return 0;
}

int Dynamics_mart::DislocationForceInit(){
  SetCalPos(Data_HOST);
  for (int saq=0;saq<VariantN;saq++){
    for (int i=0;i<nx;i++)
      for (int j=0;j<ny;j++)
        for (int k=0;k<nz;k++){
          DislocationForceConst(saq,i,j,k)=0;
          for (int sa=0;sa<3;sa++)
            for (int sap=0;sap<3;sap++){
              DislocationForceConst(saq,i,j,k)=DislocationForceConst(saq,i,j,k)+25.0f*DislocationStress(sa,sap,i,j,k)*(*StrainTensor)(saq,sa,sap);
            }
        }
  }
  DislocationForceConst.HostToDevice();
  SetCalPos(Data_DEV);
  return 0;
}

int Dynamics_mart::DislocationForceCalculate(){
  SetCalPos(Data_DEV);
  DislocationForce=DislocationForceConst*(*Eta);
  return 0;
}

__global__ void Block_Mart_Kernel(Real *Eta_arr, Real *Defect_arr){
  int pn=
	blockIdx.y*gridDim.z*blockDim.x +blockIdx.z*blockDim.x +threadIdx.x;
  int pvn= blockIdx.x *gridDim.y *gridDim.z * blockDim.x +pn;
  Eta_arr[pvn]=Eta_arr[pvn]*(1.0f-Defect_arr[pn]);
}

int Dynamics_mart::Block(){
  dim3 bn(VariantN,nx,ny);
  dim3 tn(nz);
  Block_Mart_Kernel<<<bn,tn>>>(Eta->Arr_dev,Defect->Arr_dev);

  return 0;
}

int Dynamics_mart::Calculate(){
  string ss;
  Vars["temperature"]>>=Temperature; 
  GradientForceCalculate();
  ChemicalForceCalculate();
  ElasticForceCalculate();
  DislocationForceCalculate();
  ////////////////////////////
  Eta_RT=0.f;
  if (weightGradient>0) Eta_RT += weightGradient*GradientForce; cudaThreadSynchronize();
  if (weightChemical>0) Eta_RT += (0-weightChemical)*ChemicalForce; cudaThreadSynchronize();
  if (weightElastic>0) Eta_RT  += (0-weightElastic)*ElasticForce; cudaThreadSynchronize();
  if (weightDislocation>0) Eta_RT += (0-weightDislocation)*DislocationForce; cudaThreadSynchronize();
  if (weightExternal>0) Eta_RT += (0-weightExternal)*ExternalForce; cudaThreadSynchronize();
  if (weightNoise>0){
	/*/dim3 bn(VariantN,Dimension[1],Dimension[2]); dim3 tn(Dimension[3]);
	  fnoise<<<bn,tn>>>(Noise.Arr_dev);// */
	Noise.NewNormal_device();
	Eta_RT += weightNoise*0.0001* Noise;
  }
  (*Eta) += DeltaTime* Eta_RT;
  //defect block
  Block();

  ///////////////////////////////
  return 0;
}

int Dynamics_mart::RunFunc(string funcName){ return 0; }

int Dynamics_mart::Fix(real progress){
  string ss,mode;
  ss = Vars["fix"];
  do{
	ss>>mode;
	if      (mode=="temperature"	){
	  real st,et; //start and end temperature
	  ss>>st>>et;
	  (Vars["temperature"])<<=(st+ progress*(et- st));
	} else if (mode=="pressure"		){ 
	} else{
	  GV<0>::LogAndError>>"Error: fix style ">>mode>>" does not find!\n";
	}
  } while ( ss != "");

  return 0;
}

string Dynamics_mart::Get(string ss){ // return the statistic info.
  string ans="";
  string var; ss>>var;
  if (var == "temperature") return ans<<Temperature; 
  else return "nan";
}

