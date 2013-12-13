
#include"pub.h"
#include"pub_main.h"

using namespace GS_NS;
using namespace DATA_NS;


GS::GS(){
  DynaTotal=0;
  DynaPosition=-1;
  DynaName="";
  Datas = new Map < Data<Real> >;
  Vars  = new Map < string >;
}


GS::~GS(){}

int GS::SetInfo(string ss){ss>>InfoSteps; InfoMode  = ss; return 0;}

int GS::InfoOut(){
  string sm,ss; sm=InfoMode;
  GV<0>::LogAndError<<"Step  "<<CurrentStep<<" \t";
  while (sm !=""){
	sm>>ss;
	GV<0>::LogAndError<<Dynas[DynaPosition]->Get(ss)<<" \t";
  }
  GV<0>::LogAndError<<"\n";
  return 0;
}

int GS::SetDump(string ss){
  ss>>DumpFolder>>DumpSteps;
  string cmd="if [ -s "+DumpFolder+" ]; then echo \'dump to folder"+DumpFolder+"\'; else mkdir "+DumpFolder+"; fi";
  if (system(cmd.c_str()));
  DumpMode	 = ss;
  return 0;
}

int GS::DumpOut(){
  string sm,ss;
  sm=DumpMode;
  while (sm !=""){
	sm>>ss;
	if ((*Datas)(ss) != NULL){
	  if ((*Datas)[ss].Position==Data_DEV)
		(*Datas)[ss].DeviceToHost();
	  string file; file<<DumpFolder<<"/"<<ss<<"."<<CurrentStep<<".data";
	  if (BinaryMode) (*Datas)[ss].BinaryDumpFile(file);
	  else (*Datas)[ss].DumpFile(file);
	}else GV<0>::LogAndError<<"Error: data "<<ss<<" does not exist!\n";
  }
  return 0;
}

int GS::SetSys(string ss){
  string sys; ss>>sys;
  /////////////////////////
  int pos=-1;
  if ( DynaPositions(sys)!=NULL ) {
	DynaName=sys;
	DynaPosition=DynaPositions[ sys ];
	return 0;
  }
  ////////////////////////////////////
  //create a new dyna
  pos = DynaTotal;
  bool hassys=false;
  ///////////////////////////////////
  //GS_SYS_DEFINE_START
  if (sys == "cores"	) { Dynas[ pos ] = new Dynamics_cores; hassys=true; }
  if (sys == "mart"	) { Dynas[ pos ] = new Dynamics_mart; hassys=true; }
  if (sys == "multi"	) { Dynas[ pos ] = new Dynamics_multi; hassys=true; }
  if (sys == "pow"	) { Dynas[ pos ] = new Dynamics_pow; hassys=true; }
  if (sys == "precipitate"	) { Dynas[ pos ] = new Dynamics_precipitate; hassys=true; }
  if (sys == "stress"	) { Dynas[ pos ] = new Dynamics_stress; hassys=true; }
  if (sys == "xxx"	) { Dynas[ pos ] = new Dynamics_xxx; hassys=true; }
  //GS_SYS_DEFINE_END
  ///////////////////////////////////
  if (!hassys) {
	GV<0>::LogAndError<<"Error: unknown system \""<<sys<<"\"\n";
	return -1;
  }
  ///then a new will be create
  DynasInited[sys]=false;
  DynaPositions[sys]=pos;
  DynaName=sys;
  DynaPosition=pos;
  DynaTotal++;
  return 0;
}

//////////////////////////////////////////////////
int GS::Set(string ss){
  string var,str;
  ss>>var;
  if (var=="binary"){
    ss>>str; 
    if (str=="on") BinaryMode=true;
    else BinaryMode=false;
  }else if (var=="log"){
    ss>>str;
    if (str=="off") GV<0>::LogAndError.On=false;
    else GV<0>::LogAndError.On=true;
  }else (*Vars)[var] = ss;
  return 0;
}

int GS::Link(string ss){
  string target,link;
  ss>>target>>link;
  Vars->link(target,link);
  return 0;
}

int GS::Read(string ss){
  string file,var; ss>>var>>file;
  if (BinaryMode)
    return (*Datas)[var].BinaryReadFile(file);
  else
    return (*Datas)[var].ReadFile(file);
}

int GS::ReadHere(string name, string &arrays){
  int n; arrays>>n;
  int *dim = new int[n+1]; dim[0]=n;
  for (int i=1; i<=n; i++) arrays>>dim[i];
  (*Datas)[name].Init(dim,Data_HOST);
  for (int i=0; i<(*Datas)[name].N(); i++)
	arrays>>(*Datas)[name].Arr[i];
  return 0;
}

int GS::Write(string sm){
  string ss,file;
  while (sm !=""){
	sm>>ss>>file;
	if ((*Datas)(ss) != NULL){
	  if ( (*Datas)[ss].Position==Data_DEV)
		(*Datas)[ss].DeviceToHost();
	  if (file == "") file<<ss<<".data";
	  if (BinaryMode) (*Datas)[ss].BinaryDumpFile(file);
	  else (*Datas)[ss].DumpFile(file);
	}else GV<0>::LogAndError<<"Error: unknown data \""<<ss<<"\"\n";
  }
  return 0;
}

int GS::WriteHere(string sm){
  string ss;
  while (sm !=""){
	sm>>ss;
	if ((*Datas)(ss) != NULL){
	  if ((*Datas)[ss].Position==Data_DEV)
		(*Datas)[ss].DeviceToHost();
	  cout<<(*Datas)[ss];
	  GV<0>::LogAndError.Logofs<<(*Datas)[ss];
	}else if ((*Vars)(ss) != NULL){
	  cout<<(*Vars)[ss];
	  GV<0>::LogAndError.Logofs<<(*Vars)[ss];
	}else GV<0>::LogAndError<<"Error: unknown data \""<<ss<<"\"\n";
  }
  return 0;
}


int GS::Run(string ss){
  if (DynaName=="") {
	GV<0>::LogAndError<<"Error: run before system setting\n";
	return -1;
  }
  ////////////////////////////////////
  int totalsteps=1;
  ss>>totalsteps; TotalSteps=totalsteps;
  if (totalsteps <= 0 ) return -1;
  Dynas[DynaPosition]->Datas = Datas; 
  Dynas[DynaPosition]->Vars = Vars; 
  if ( !DynasInited[DynaName] ){
	Dynas[DynaPosition]->Initialize();
	DynasInited[DynaName]=true;
	//////////////////////////////////////////////////////////////
	CurrentStep=0;
	(*Vars)["ahead_steps"]>>=CurrentStep;
  }
  //////////////////////////////////////////////////////////////
  int  infoInterval;
  if ( InfoSteps==0) infoInterval=totalsteps+1;
  else infoInterval = totalsteps/InfoSteps;
  if ( infoInterval==0 ) infoInterval=1;
  int  dumpInterval;
  if ( DumpSteps== 0 ) dumpInterval= totalsteps+1;
  else dumpInterval  = totalsteps/DumpSteps;
  if ( dumpInterval == 0 ) dumpInterval =1;
  //////////////////////////////////////////////////////////////
  string mode=InfoMode,tempss;
  GV<0>::LogAndError<<"Info \t\t";
  while (mode!=""){ mode>>tempss; GV<0>::LogAndError<<tempss<<"\t"; };
  GV<0>::LogAndError<<"\n";
  //////////////////////////////////////////////////////////////
  for (int i=1;i<=totalsteps;i++) {
	CurrentStep++; // this will be used in dump and info to identity the progress
	/////////////////////////////
	Dynas[DynaPosition]->Fix(real(i)/totalsteps);
	Dynas[DynaPosition]->Calculate();
	//////////////////////////////
	if (i % infoInterval==0|| i==totalsteps) InfoOut();
	if (i % dumpInterval  ==0|| i==totalsteps) DumpOut();
  }
  //////////////////////////////////////////////////////////////
  return 0;
}

int GS::RunFunc(string func ){
  if (DynaPositions(DynaName)==NULL){
	GV<0>::LogAndError<<"Error: no system set, runfunc commands not available\n";
	return Code_ERR;
  }
  Dynas[DynaPosition]->Datas = Datas; 
  Dynas[DynaPosition]->Vars= Vars; 
  if ( !DynasInited[DynaName] ){
	GV<0>::LogAndError<<"Warning: Initialization function called\n";
	Dynas[ DynaPosition]->Initialize();
	DynasInited[ DynaName ] = true;
  }
  return Dynas[ DynaPosition ]->RunFunc(func);
}
