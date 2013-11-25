
#include"pub.h"
#include"pub_main.h"
#include"input.h"

using namespace std;
using namespace GS_NS;

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
	if      (command== "variable" 		)   err=Vars.Set(ss); 
	else if (command== "shell"   		)   err=system(ss.c_str());
	else if (command== "quit"			)   break;
	//////////////////////////////////////////////////////////////
	else if (command== "link"			)   { err= Gs.Link(ss); }
	else if (command== "set"			)   { Vars.SubVar(ss,1); err=Gs.Set(ss);}
	else if (command== "read"			)   { Vars.SubVar(ss,1); err=Gs.Read(ss);}
	else if (command== "readhere"		)   { err=readhere(ss);}
	else if (command== "dump" 			)   { Vars.SubVar(ss,1); err=Gs.SetDump(ss); } 
	//////////////////////////////////////////////////////////////
	else{
	  Vars.SubVar(ss,0);
	  if 	  (command== "device"		) 	err=device(ss); 
	  else if (command== "sys"			)  	err=Gs.SetSys(ss);
	  else if (command== "info"     	)   err=Gs.SetInfo(ss); 
	  else if (command== "run"			)   err=Gs.Run(ss);//run(ss);
	  else{
		GV<0>::LogAndError<<"Command "<<command<<" is not supported in GS!"; 
		return -1;
	  }
	}
	if (err<0) return -1;
  }
  return 0;
}

int INPUT::readhere(string sr){
  int ndim=1,nele=1,tem;
  string arrays,varname,ss,sele;
  int 	index=0;
  sr>>varname;
  while (fgets_str(fin,ss)){
	 ss=this->standardize(ss);
	 Vars.SubVar(ss,0);
	 while (ss!=""){
	   if (index==0) {
		 ss>>ndim; arrays<<ndim<<" "; }
	   else if (index<=ndim) {
		 ss>>tem; arrays<<tem<<" "; 
		 nele*=tem; 
	   }else{
		 ss>>sele; arrays<<sele<<" ";
	   }
	   index++;
	 }
	 if ( index > ndim + nele) break;//finish condition // the final index = ndim+nele+1...cause the ndim is counted as 1
  }
  //create the variant number and its corresponding tensor
  Gs.ReadHere(varname, arrays);
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
