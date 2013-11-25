#include"pub.h"
#include"pub_main.h"
#include"input.h"

using namespace GUPS_NS;
using namespace std;

int main(int argn,char* args[]){
  GV<0>::LogAndError.Init("gups");
  string file;
  if (argn==1){
	file ="in.gups";	
	GV<0>::LogAndError<<"Since no input script assigned, default \"in.gups\" is used.\n";
  }else{
	file = args[1];
	GV<0>::LogAndError<<"Input script \""<<file<<"\" is used.\n";
	int device=0;
	if (argn==3) { 
	  io(args[2],device); 
	  cudaSetDevice(device);
	  GV<0>::LogAndError<<"Gpu device set to "<<device<<"\n";
	}  
  }
  INPUT qin(file);				// 
  if (! qin.fin.fail())
	qin.Phrasing();	
  else
	GV<0>::LogAndError<<"Input script "<<file<<" is not found\n";
  return 0;
}

