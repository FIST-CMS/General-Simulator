
////////////////////////////////////////
#include"pub.h"
#include"dynamics.h"
////////////////////////////////////////
//#include"your_own_library.h"
///////////////////////////////////////
#include"dynamics_pow.h"

using namespace GS_NS;
using namespace DATA_NS;

Dynamics_pow::Dynamics_pow(){}




int Dynamics_pow::Initialize(){
  x=2.0f; Vars["x"]>>=x;// x default set to 2.0
  Matrix = &((*Datas)["matrix"]);
  return 0;
}





int Dynamics_pow::Calculate(){
  (*Matrix)=(*Matrix)*x;
  return 0;
}




int Dynamics_pow::RunFunc(string func){ return Code_COMMAND_UNKNOW;}

int Dynamics_pow::Fix(real progress){return 0;}



string Dynamics_pow::Get(string var){
  if (var=="x") return ToString(x);
  if (var=="sum_of_matrix")
	return ToString(Matrix->TotalHost());
  return "nan";
}





Dynamics_pow::~Dynamics_pow(){}
