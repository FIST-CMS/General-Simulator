
#include"pub.h"
#include"pub_main.h"
#include"input.h"

using namespace std;
using namespace GS_NS;

INPUT::INPUT(){
}
INPUT::~INPUT(){}

int INPUT::Phrasing(string script){
  int err=0;
  string ss;
  while (getline(ss,script)){
	////////////////////
	while (ss[0]==' ') ss.erase(0,1); //delete the heading space of each line
    if (ss=="") continue;
    string command; ss>>command;
	if 		(command== "shell"   	)   { err=system(ss.c_str()); }
	//////////////////////////////////////////////////////////////
	else if (command== "logon"		)	{GV<0>::LogAndError.On=true; }
	else if (command== "logoff"		)	{GV<0>::LogAndError.On=false; }
	else if (command== "break"		)   { break; }
	else if (command== "quit"		)   { err=Code_QUIT; break; }
	//////////////////////////////////////////////////////////////
	else if (command== "link"		)   { err=Gs.Link(ss); }
	else if (command== "set"		)   { Vars.SubVar(ss,1);err=Gs.Set(ss);}
	/////////////
	else if (command== "info"     	)   { Vars.SubVar(ss,0);err=Gs.SetInfo(ss);  }
	else if (command== "dump" 	)   { Vars.SubVar(ss,1);err=Gs.SetDump(ss);} 
	/////////////
	else if (command== "read"		)   { Vars.SubVar(ss,1);err=Gs.Read(ss);}
	else if (command== "readhere"	)   { err=readhere(ss,script);}
	else if (command== "write"		)   { err=Gs.Write(ss);} 
	else if (command== "writehere"	)   { err=Gs.WriteHere(ss);} 
	//////////////////////////////////////////////////////////////
	else if (command== "device"		)	{ Vars.SubVar(ss,0);err=device(ss); }
	//else if (command== "var"	 	)   { err=Vars.Set(ss); }
	else if (command== "expr"	 	)   { err=expresion(ss); }
	else if (command== "sys"		)  	{ Vars.SubVar(ss,0); err=Gs.SetSys(ss); }
	else if (command== "run"		)   { Vars.SubVar(ss,0); err=Gs.Run(ss);}
	//////////////////////////////////////////////////////////////
	else if (command== "loop"		) 	{ err=stat_loop(ss,script);}
	else if (command== "while"		) 	{ err=stat_while(ss,script);}
	else if (command== "if"			) 	{ err=stat_if(ss,script);}
	//////////////////////////////////////////////////////////////
	else if (command== "runfunc"	)   { Vars.SubVar(ss,0);err=Gs.RunFunc(ss);}
	else {
	  Vars.SubVar(ss,0);
	  err=Gs.RunFunc(command+" "+ss);
	} // default leave out runfunc command

	/////////////////////////////////////////////////////////////////////////
	if (err == Code_COMMAND_UNKNOW){
	  GV<0>::LogAndError<<"Command "<<command <<" is unknow.\n"; 
	  return Code_ERR;
	}
	if ( err == Code_ERR ) {
	  GV<0>::LogAndError<<"Error occured when excuting command "<<command<<".\n"; 
	  return Code_ERR;
	}
	if (err == Code_QUIT ) return Code_QUIT;
	/////////////////////////////////////////////////////////////////////////
  }
  return Code_NORMAL;
}

/////////////////////////////////////////////////////////////
bool INPUT::getline(string &ss, string &script){
  if (script=="") return false;
  int n=script.find("\n");
  ss=script.substr(0, n);
  script.erase(0,n+1);
  if (ss!=""&&GV<0>::LogAndError.On)
	GV<0>::LogAndError<<">>>"<<ss<<"\n";
  return true;
};
int INPUT::standardize(string &script){
  script=script+"\n";
  int p;
  //repalce some cut as space
  //////////////////////////////////////////////////
  while ((p=script.find('\t'))>=0)  script[p]=' ';
  while ((p=script.find(",")) >=0)  script[p]=' ';
  while ((p=script.find(";")) >=0)  script[p]=' ';
  while ((p=script.find(":")) >=0)  script[p]=' ';
  while ((p=script.find("{")) >=0)  script[p]=' ';
  while ((p=script.find("}")) >=0)  script[p]=' ';
  //////////////////////////////////////////////////
  int p1=script.find("#"),p2;
  while (p1>=0){
	p2=script.find("\n",p1);
	script.erase(p1,p2-p1);
	p1=script.find("#");
  }
  //delete extra space
  while ((p=script.find("  "))>=0)
	script.erase(p,1);
  ///delete space around operator is not practicle in this case, cause space is an important mark
  // delete space and other chars between two bracket---an expression
  int n_brack=0, pre_pos=-1,pos=0;
  string  temp;
  while ( pos<script.length() ){
	if (script[pos]=='(') {
	  n_brack++;
	  if (n_brack==1) pre_pos=pos;
	}else if (script[pos]==')'){
	  n_brack--;
	  if (n_brack==0){
		//standardize the expression found
		temp=script.substr(pre_pos+1,pos-pre_pos-1);
		int p=0;
		while (p<temp.length()){
		  if (temp[p]==' '||temp[p]=='\n')
			temp.erase(p,1);
		  else p++;
		}
		script.replace(pre_pos,pos-pre_pos+1,temp);
	  }
	}
	pos++;
  }
  return 0;
}
/////////////////////////////////////////////////////////////

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
	GV<0>::LogAndError<<"Error: gpu device change operation unsuccessful!\n"; return -1;
  }
  return 0;
}

int INPUT::expresion(string ss){
  string str_t,str_hold=ss;
  ss>>str_t;
  if (ss==""){
	Vars.SubVar(str_t,0);
	GV<0>::LogAndError<<str_t<<"\n";
	return 0;
  }else{
	return Vars.Set(str_hold);
  }
}
////////////////////////////////////////////////////////////

int INPUT::find_sub_script(string&script,string&sub_script){
  // each command corresponds to one and one only end
  int n_end=1;
  for (int p=0;p<script.length();p++){
	for (int i=0; i<Commands_N; i++)
	  if (script.substr(p,Commands[i].length())==Commands[i])
		n_end++;
	if (script.substr(p,3) == "end" )
	  n_end--;
	if (n_end==0){
	  sub_script = script.substr(0,p);
	  script.erase(0,p+3);
	  return 0;
	}
  }
  return Code_INPUT_UNCOMPLETE;
}

int INPUT::stat_loop(string ss,string &script){
  string sub_script,temp_sub,var; ss>>=var;
  int err=0;
  find_sub_script(script,sub_script);
  err=Vars.SubVar(var,0);
  if (err!=Code_NORMAL) return err;
  Real loop_n; var>>loop_n;
  ////////////////////////////
  for (int i=0;i<loop_n;i++){
	temp_sub=sub_script;
	err=Phrasing(temp_sub);
	if (err!=Code_NORMAL) return err;
  }
  return 0;
}

int INPUT::stat_while(string ss,string &script){
  string sub_script,temp_sub,expr; ss>>=expr;
  int err=0;
  find_sub_script(script,sub_script);
  err=Vars.SubVar(expr,0); if (err!=Code_NORMAL) return err;
  ////////////////////////////
  while( ToReal(expr)>0 ){
	temp_sub= sub_script;
	err=Phrasing(temp_sub);
	if (err!=Code_NORMAL) return err;
	ss>>=expr;
	Vars.SubVar(expr,0);
  }
  return 0;
}
int INPUT::find_else_script(string&script,string&sub_script1,string &sub_script2){
  // each command corresponds to one and one only end
  int n_end=1;
  int p_else=-1,p_end=-1;
  for (int p=0;p<script.length();p++){
	for (int i=0; i<Commands_N; i++)
	  if (script.substr(p,Commands[i].length())==Commands[i])
		n_end++;
	if (script.substr(p,3) == "end" )
	  n_end--;
	if ( p_else<0 && n_end==1
		&&script.substr(p,4) == "else"){
	  p_else = p;
	}
	if (n_end==0){
	  p_end = p;
	  break;
	}
  }
  if (n_end>0) return Code_INPUT_UNCOMPLETE;
  if (p_else <0 ){
	sub_script1 = script.substr(0,p_end);
	sub_script2 = "";
  }else{
	sub_script1 = script.substr(0,p_else);
	sub_script2 = script.substr(p_else+4,p_end-p_else-4);
  }
  script.erase(0,p_end+3);
  return Code_NORMAL;
}


int INPUT::stat_if(string ss,string &script){
  string sub_script1,sub_script2,expr; ss>>=expr;
  int err=0;
  find_else_script(script,sub_script1,sub_script2);
  Vars.SubVar(expr,0);
  if (ToReal(expr)>0){
	err=Phrasing(sub_script1);
  }else{
	err=Phrasing(sub_script2);
  }
  return err;
}

