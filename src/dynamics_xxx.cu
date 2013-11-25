
////////////////////////////////////////
#include"pub.h"
#include"dynamics.h"
////////////////////////////////////////
//#include"your_own_library.h"
///////////////////////////////////////
#include"dynamics_xxx.h"

using namespace GS_NS;
using namespace DATA_NS;

DynamicsXxx::DynamicsXxx(){}
DynamicsXxx::~DynamicsXxx(){}

int DynamicsXxx::Initialize(){
  //para setting should be finished before or within this function
  string ss;
  Vars["x"]>>=x;	
  Matrix = &((*Datas)["matrix"]);
  return 0;
}

int DynamicsXxx::Calculate(){
  (*Matrix)=(*Matrix)*x;
  return 0;
}

int DynamicsXxx::RunFunc(string funcName){
  if (funcName=="calculate") Calculate();
  return 0;
}

int DynamicsXxx::Fix(real progress){return 0;}

string DynamicsXxx::Get(string ss){
  string ans;
  if (ss=="x") return ans<<x;
  if (ss=="sumofmatrix") return ans<<(Matrix->TotalHost());
  return "nan";
}
