
////////////////////////////////////////
#include"pub.h"
#include"dynamics.h"
////////////////////////////////////////
//#include"your_own_library.h"
///////////////////////////////////////
#include"dynamics_xxx.h"

using namespace GUPS_NS;
using namespace DATA_NS;
/*
  main calculation:
 */

int DynamicsXxx::InitDynamics(){
  //para setting should be finished before or within this function
  string ss;
  Vars["x"]>>=x;	
  return 0;

}

DynamicsXxx::DynamicsXxx(){}
DynamicsXxx::~DynamicsXxx(){}

int DynamicsXxx::CalculateAll(){
  return 0;
}
int DynamicsXxx::Iterate(){
  return 0;
} 

int DynamicsXxx::Fix(real progress){
  return 0;
}

Real DynamicsXxx::Get(string ss){ // return the statistic info.
  string var; ss>>var;
  return -999999999999999999999999999999999999999999999999999.9;
}
