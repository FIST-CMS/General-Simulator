
////////////////////////////////////////
#include"pub.h"
#include"dynamics.h"
////////////////////////////////////////
//#include"your_own_library.h"
///////////////////////////////////////
#include"dynamics_multi.h"

using namespace GS_NS;
using namespace DATA_NS;

Dynamics_multi::Dynamics_multi(){}

int Dynamics_multi::Initialize(){
  return 0;
}

int Dynamics_multi::Calculate(){
  return 0;
}

int Dynamics_multi::RunFunc(string func){
  string fname; func>>fname;
  if (fname=="matrix_multi") return Matrix_multi(func);
  return Code_COMMAND_UNKNOW;
}

int Dynamics_multi::Fix(real progress){return 0;}

string Dynamics_multi::Get(string ss){
  return "nan";
}

Dynamics_multi::~Dynamics_multi(){}

__global__ void Dynamics_multi_kernel_matrix_multi
( Real *mat1, Real*mat2,Real *mat3,
 int d_mid){
  int ny=blockDim.x;
  int x=blockIdx.x,y=threadIdx.x;
  mat3[x*ny+y]=0.0f;
  for (int i=0; i<d_mid; i++)
	mat3[x*ny+y]+=mat1[x*d_mid+i]*mat2[i*ny+y];
}

int Dynamics_multi::Matrix_multi(string para){
  Data<Real> *Mat1,*Mat2,*Mat3; string matname[3];
  ///////////////////////////////////////////////////////////////
  para>>matname[0]>>matname[1]>>matname[2];
  Mat1 = &((*Datas)[matname[0]]);
  Mat2 = &((*Datas)[matname[1]]);
  Mat3 = &((*Datas)[matname[2]]);
  ///////////////////////////////////////////////////////////////
  Mat1->HostToDevice(); Mat2->HostToDevice();
  Mat3->Init(2,Mat1->Dimension[1],Mat2->Dimension[2],Data_HOST_DEV);
  dim3 bn(Mat1->Dimension[1]),tn(Mat2->Dimension[2]);
  Dynamics_multi_kernel_matrix_multi<<<bn,tn>>>
	(Mat1->Arr_dev,Mat2->Arr_dev,Mat3->Arr_dev,
	 Mat1->Dimension[2]);
  Mat3->DeviceToHost();
  ///////////////////////////////////////////////////////////////
  return 0;
}

