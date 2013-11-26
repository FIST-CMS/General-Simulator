#include"pub.h"
#include"pub_main.h"
#include"input.h"

using namespace GS_NS;
using namespace std;

int main(int argn,char* args[]){
  GV<0>::LogAndError.Init("gs");
  string file;
  if (argn==1){
	file ="in.gs";	
	GV<0>::LogAndError<<"Since no input script assigned, default \"in.gs\" is used.\n";
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
  ifstream in(file.c_str(), ios::in);
  if (in.fail()){
	GV<0>::LogAndError<<"Input script "<<file<<" is not found\n";
	return -1;
  }
  istreambuf_iterator<char> beg(in), end;
  string script(beg, end);
  in.close();

  INPUT qin;				// 
  qin.Phrasing(script);	
  return 0;
}

