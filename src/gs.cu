
#include"pub.h"
#include"pub_main.h"

using namespace GS_NS;
using namespace DATA_NS;


GS::GS(){ 
  for (int i=0;i<DynaMax;i++){
	Dyna[i] = NULL;
	IsDynaInit[i] = false;
  }
}


GS::~GS(){
  for (int i=0;i<DynaMax;i++)
	if (Dyna[i]!=NULL) delete Dyna[i];
}

int GS::SetInfo(string ss){ss>>InfoSteps; InfoMode  = ss; return 0;}

int GS::InfoOut(){
  string sm,ss; sm=InfoMode;
  GV<0>::LogAndError<<"Step  "<<CurrentStep<<" \t";
  while (sm !=""){
	sm>>ss;
	GV<0>::LogAndError<<Dyna[DynaID]->Get(ss)<<" \t";
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
	if (Datas(ss) != NULL){
	  if (Datas[ss].Position==Data_DEV)
		Datas[ss].DeviceToHost();
	  string file; file<<DumpFolder<<"/"<<ss<<"."<<CurrentStep<<".data";
	  if (CurrentStep==TotalSteps) {
		file="";
		file<<DumpFolder<<"/"<<ss<<".final.data";
	  }
	  Datas[ss].DumpFile(file);
	}else GV<0>::LogAndError<<"Error: data "<<ss<<" does not exist!\n";
  }
  return 0;
}

int GS::SetSys(string ss){
  string sys;
  int id=0;
  ss>>sys>>id;
  DynaID=id;
  if ( id >=DynaMax || id<0 ){
	DynaID=(id%DynaMax+DynaMax)%DynaMax;
	GV<0>::LogAndError<<"Dyna ID is out of the allowed index range. It is moduled to "<<DynaID<<"\n";
	return -1;
  }
  if (Dyna[DynaID]!=NULL) // if the DynaID dyna has been created then delete it.
	delete Dyna[id];

  bool hassys=false;
  ///////////////////////////////////
  //GS_SYS_DEFINE_START
  if (sys == "cores"	) { Dyna[DynaID] = new Dynamics_cores; hassys=true; }
  if (sys == "diffuse"	) { Dyna[DynaID] = new Dynamics_diffuse; hassys=true; }
  if (sys == "mart"	) { Dyna[DynaID] = new Dynamics_mart; hassys=true; }
  if (sys == "pow2"	) { Dyna[DynaID] = new Dynamics_pow2; hassys=true; }
  if (sys == "pow"	) { Dyna[DynaID] = new Dynamics_pow; hassys=true; }
  if (sys == "stress"	) { Dyna[DynaID] = new Dynamics_stress; hassys=true; }
  if (sys == "xxx"	) { Dyna[DynaID] = new Dynamics_xxx; hassys=true; }
  //GS_SYS_DEFINE_END
  ///////////////////////////////////
  if (!hassys) {
	GV<0>::LogAndError<<"Error: System "<<ss<<"is not recognized\n";
	return -1;
  }
  return 0;
}

//////////////////////////////////////////////////
int GS::Set(string ss){
  string var;
  ss>>var;
  Vars[var] = ss;
  return 0;
}

int GS::Link(string ss){
  string target,link;
  ss>>target>>link;
  Vars.Link(target,link);
  return 0;
}

int GS::Read(string ss){
  string file,var; ss>>var>>file;
  ifstream ifs;
  ifs.open(file.c_str());
  if (ifs){
	ifs>>Datas[var];
	ifs.close();
  }else{
	GV<0>::LogAndError<<"Error: File "<<file<<" not found!\n";
	return -1;
  }
  return 0;
}

int GS::ReadHere(string name, string &arrays){
  int n; arrays>>n;
  int *dim = new int[n+1]; dim[0]=n;
  for (int i=1; i<=n; i++) arrays>>dim[i];
  Datas[name].Init(dim,Data_HOST);
  for (int i=0; i<Datas[name].N(); i++)
	arrays>>Datas[name].Arr[i];
  return 0;
}

int GS::Write(string sm){
  string ss,file;
  while (sm !=""){
	sm>>ss>>file;
	if (Datas(ss) != NULL){
	  if (Datas[ss].Position==Data_DEV)
		Datas[ss].DeviceToHost();
	  if (file == "") file<<ss<<".data";
	  Datas[ss].DumpFile(file);
	}else GV<0>::LogAndError<<"Error: data "<<ss<<" does not exist!\n";
  }
  return 0;
}

int GS::WriteHere(string sm){
  string ss;
  while (sm !=""){
	sm>>ss;
	if (Datas(ss) != NULL){
	  if (Datas[ss].Position==Data_DEV)
		Datas[ss].DeviceToHost();
	  cout<<Datas[ss];
	  GV<0>::LogAndError.Logofs<<Datas[ss];
	}if (Vars(ss) != NULL){
	  cout<<Vars[ss];
	  GV<0>::LogAndError.Logofs<<Vars[ss];
	}else GV<0>::LogAndError<<"Error: data "<<ss<<" does not exist!\n";
  }
  return 0;
}


int GS::Run(string ss){
  int totalsteps=1;
  ss>>totalsteps; TotalSteps=totalsteps; if (totalsteps <= 0 ) return -1;
  //what dyna to use???? defined in sys
  // the data is passed by reference ( big )
  // paras is passed by value ( small )
  Dyna[DynaID]->Datas = &Datas; 
  Dyna[DynaID]->Vars= Vars; 
  if ( !IsDynaInit[DynaID] ){
	Dyna[DynaID]->Initialize();
	IsDynaInit[ DynaID ] = true;
  }
  //////////////////////////////////////////////////////////////
  int  infoInterval;
  if ( InfoSteps==0) infoInterval=totalsteps+1;else infoInterval = totalsteps/InfoSteps;
  if ( infoInterval==0 ) infoInterval=1;
  int  dumpInterval;
  if ( DumpSteps== 0 ) dumpInterval= totalsteps+1; else dumpInterval  = totalsteps/DumpSteps;
  if ( dumpInterval == 0 ) dumpInterval =1;
  //////////////////////////////////////////////////////////////
  string mode=InfoMode,tempss;
  GV<0>::LogAndError<<"Info \t\t"; while (mode!=""){ mode>>tempss; GV<0>::LogAndError<<tempss<<"\t"; };
  GV<0>::LogAndError<<"\n";
  for (int i=1;i<=totalsteps;i++) {
	CurrentStep = i; // this will be used in dump and info to identity the progress
	Dyna[DynaID]->Fix(real(i)/totalsteps);
	Dyna[DynaID]->Calculate();

	if (i % infoInterval==0|| i==totalsteps) InfoOut();
	if (i % dumpInterval  ==0|| i==totalsteps) DumpOut();
  }
  //////////////////////////////////////////////////////////////
  return 0;
}

int GS::RunFunc(string func){
  if (Dyna[DynaID]==NULL){
	GV<0>::LogAndError<<"Error: no system set, runfunc commands not available\n";
	return Code_ERR;
  }
  Dyna[DynaID]->Datas = &Datas; 
  Dyna[DynaID]->Vars= Vars; 
  if ( !IsDynaInit[DynaID] ){
	GV<0>::LogAndError<<"Warning: Initialization function called\n";
	Dyna[DynaID]->Initialize();
	IsDynaInit[ DynaID ] = true;
  }
  Dyna[DynaID]->RunFunc(func);
  return 0;
}
