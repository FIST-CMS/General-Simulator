
#include"pub.h"
#include"pub_main.h"
#include"input.h"

using namespace std;
using namespace GUPS_NS;

INPUT::INPUT(string infile){
  fin.open(infile.c_str());
  LineNumber=0;
}

INPUT::~INPUT(){
  if (fin)  fin.close();
}

string  INPUT::standardize(string ss){
  int p,p1;
  p=ss.find("#");
  ss=ss.substr(0,p); ss+="\n";
  //repalce other cut as space
  while ((p=ss.find("\n")) >=0)  ss[p]=' ';
  while ((p=ss.find("\t"))>=0) ss[p]=' ';
  while ((p=ss.find(",")) >=0)  ss[p]=' ';
  while ((p=ss.find(";")) >=0)  ss[p]=' ';
  while ((p=ss.find("{")) >=0)  ss[p]=' ';
  while ((p=ss.find("}")) >=0)  ss[p]=' ';
  while ((p=ss.find("(")) >=0)  ss[p]=' ';
  while ((p=ss.find(")")) >=0)  ss[p]=' ';
  while (ss[0]==' ')  ss=ss.erase(0,1);
  //delete extra space
  p=ss.find(" ");
  while (p>=0){
    p1=ss.find(" ",p+1);
    if (p1==p+1) 
	 ss.erase(p+1,1);
    else{
	 p = ss.find(" ",p+1);
    }
  }
  return ss;
}

bool INPUT::fgets_str(ifstream &is, string &ss){
  if (getline(is,ss)){ LineNumber++; return 1; }
  else return 0;
}

int INPUT::Phrasing(){
  int err=0;
  string ss;
  while (fgets_str(fin,ss)){
	GV<0>::LogAndError<<LineNumber<<": "<<ss<<"\n";
    ss=this->standardize(ss);
    if (ss=="") continue;
    string command; ss>>command;
	if      (command== "variable" 		)   err=Vars.Set(ss); //variable(ss);
	else if (command== "shell"   		)   err=system(ss.c_str());
	else if (command== "quit"			)   break;
	//////////////////////////////////////////////////////////////
	else if (command== "link"			)   { err= Gups.Link(ss); }
	else if (command== "set"			)   { Vars.SubVar(ss,1); err=Gups.Set(ss);}
	else if (command== "read"			)   { Vars.SubVar(ss,1); err=Gups.Read(ss);}
	else if (command== "dump" 			)   { Vars.SubVar(ss,1); err=Gups.SetDump(ss); } 
	//////////////////////////////////////////////////////////////
	else{
	  Vars.SubVar(ss,0);
	  if 	  (command== "device"		) 	err=device(ss); 
	  else if (command== "sys"			)  	err=Gups.SetSys(ss);
	  else if (command== "variant"		) 	err=variant(ss);
	  else if (command== "thermo"     	)   err=Gups.SetThermo(ss); 
	  else if (command== "run"			)   err=Gups.Run(ss);//run(ss);
	  else{
		GV<0>::LogAndError<<"Command "<<command<<" is not supported in GUPS!"; 
		return -1;
	  }
	}
	if (err<0) return -1;
  }
  return 0;
}

int INPUT::variant(string sr){
  int n;
  sr>>n;
  if (n<=0){
	GV<0>::LogAndError>>"Variant number is less than one!\n";
    return -1;
  }

  real *arr=new real[n*3*3];
  string 	ss;
  int 	index=0;
  while (fgets_str(fin,ss)){
	 ss=this->standardize(ss);
	 Vars.SubVar(ss,0);
	 while (ss!=""){
	   ss>>arr[index];
	   index++;
	 }
	 if ( index >= 3*3*n) break;//finish condition
  }
  //create the variant number and its corresponding tensor
  Gups.CreateVariant(n, arr);
  delete []arr;

  //log the straintensor
  GV<0>::LogAndError<<"straintensor created\n";
  for (int v = 0; v < n; v++){
    for (int i=0;i<3;i++){
	 for (int j=0;j<3;j++){
	   GV<0>::LogAndError<<(Gups.Datas["straintensor"])(v,i,j)<<" ";
	 }
	 GV<0>::LogAndError<<"\n";
    }
	GV<0>::LogAndError<<"\n";
  }
  return 0;
}

int INPUT::device(string ss){
  int id; ss>>id;
  if (cudaSetDevice(id) )
	GV<0>::LogAndError<<"gpu device changes to devide "<<id<<"\n";
  else {
	GV<0>::LogAndError>>"Error: gpu device change operation unsuccessful!\n"; return -1;
  }
  return 0;
}
