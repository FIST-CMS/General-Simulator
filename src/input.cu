
#include"pub.h"
#include"pub_main.h"
#include"input.h"

using namespace std;
using namespace GS_NS;

INPUT::INPUT(){
  LineNumber=0;
}
INPUT::~INPUT(){}

bool INPUT::getline(string &ss, string &script){
  if (script=="") return false;
  LineNumber++;
  int n=script.find("\n");
  ss=script.substr(0, n);
  script.erase(0,n+1);
  GV<0>::LogAndError<<LineNumber<<": "<<ss<<"\n";
  return true;
};
int INPUT::standardize(string &script){
  script=script+"\n";
  int p;
  //repalce some cut as space
  //////////////////////////////////////////////////
  while ((p=script.find("\t"))>=0)  script[p]=' ';
  while ((p=script.find(",")) >=0)  script[p]=' ';
  while ((p=script.find(";")) >=0)  script[p]=' ';
  while ((p=script.find("{")) >=0)  script[p]=' ';
  while ((p=script.find("}")) >=0)  script[p]=' ';
  //while ((p=script.find("(")) >=0)  script[p]=' ';
  //while ((p=script.find(")")) >=0)  script[p]=' ';
  //////////////////////////////////////////////////
  int p1=script.find("#"),p2;
  while (p1>=0){
	p2=script.find("\n",p1);
	script.erase(p1,p2-p1);
	p1=script.find("#");
  }
  //delete extra space
  while ((p=script.find("  "))>=0)
	script.erase(p,2);
  return 0;
}

int INPUT::Phrasing(string script){
  standardize(script);
  int err=0;
  string ss;
  while (getline(ss,script)){
	////////////////////
	////////////////////
	while (ss[0]==' ') ss.erase(0,1); //delete the heading space of each line
    if (ss=="") continue;
    string command; ss>>command;
	if      (command== "variable" 		)   { err=Vars.Set(ss); }
	else if (command== "shell"   		)   { err=system(ss.c_str()); }
	else if (command== "quit"			)   { err=Code_QUIT; break; }
	else if (command== "break"			)   { break; }
	//////////////////////////////////////////////////////////////
	else if (command== "link"			)   { err=Gs.Link(ss); }
	else if (command== "set"			)   { Vars.SubVar(ss,1);err=Gs.Set(ss);}
	else if (command== "read"			)   { Vars.SubVar(ss,1);err=Gs.Read(ss);}
	else if (command== "dump" 			)   { Vars.SubVar(ss,1);err=Gs.SetDump(ss); } 
	else if (command== "readhere"		)   { err=readhere(ss,script);}
	else if (command== "dumphere"		)   { err=Gs.DumpHere(ss);} 
	//////////////////////////////////////////////////////////////
	else if (command== "device"			)	{ Vars.SubVar(ss,0);err=device(ss); }
	else if (command== "sys"			)  	{ Vars.SubVar(ss,0);err=Gs.SetSys(ss); }
	else if (command== "info"     		)   { Vars.SubVar(ss,0);err=Gs.SetInfo(ss);  }
	else if (command== "run"			)   { Vars.SubVar(ss,0);err=Gs.Run(ss);}
	else if (command== "runfunc"		)   { Vars.SubVar(ss,0);err=Gs.RunFunc(ss);}
	else {
	  GV<0>::LogAndError<< command <<" run as runfunc command\n"; 
	  Vars.SubVar(ss,0);
	  err=Gs.RunFunc(command+" "+ss);
	} // default leave out runfunc command
	if (err == Code_COMMAND_UNKNOW){
	  GV<0>::LogAndError<<"Command "<<command <<" is unknow.\n"; 
	  return Code_ERR;
	}
	if ( err == Code_ERR ) {
	  GV<0>::LogAndError<<"Error occured when excuting command "<<command<<"."; 
	  return Code_ERR;
	}
	if (err == Code_QUIT ) return Code_QUIT;
  }
  return Code_NORMAL;
}

int INPUT::readhere(string sr,string &script){
  int ndim=1,nele=1,tem;
  string arrays,varname,ss,sele;
  int 	index=0;
  sr>>varname;
  while (getline(ss,script)){
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
