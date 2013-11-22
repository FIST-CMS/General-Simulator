
#define DEBUG 0

#include"pub.h"
#include"pub_main.h"

using namespace GUPS_NS;
using namespace DATA_NS;


GUPS::GUPS(){ 
  for (int i=0;i<DynaMax;i++){
	Dyna[i] = NULL;
	IsDynaInit[i] = false;
  }
}


GUPS::~GUPS(){
  for (int i=0;i<DynaMax;i++)
	if (Dyna[i]!=NULL) delete Dyna[i];
}

int GUPS::CreateVariant(int n, real *tensor){
  Vars["variantn"]<<n;
  Datas["straintensor"].Init(3,n,3,3,Data_HOST_DEV);
  set_host(Datas["straintensor"].Arr,tensor,n*3*3);
  Datas["straintensor"].HostToDevice();
  return 0;
}

int GUPS::SetThermo(string ss){ss>>ThermoSteps; ThermoMode  = ss; return 0;}

int GUPS::ThermoOut(){
  string sm,ss; sm=ThermoMode;
  GV<0>::LogAndError<<"Steps "<<CurrentStep<<": \t";
  while (sm !=""){
	sm>>ss;
	GV<0>::LogAndError<<Dyna[DynaID]->Get(ss)<<" \t";
  }
  GV<0>::LogAndError<<"\n";
  return 0;
}

int GUPS::SetDump(string ss){
  ss>>DumpFolder>>DumpSteps;
  string cmd="mkdir "+DumpFolder;
  if (system(cmd.c_str()));
  DumpMode	 = ss;
  return 0;
}

template<class type> int GUPS::DumpFile(string str,Data<type> &data){
  data.DeviceToHost();
  string file; file<<DumpFolder<<"/"<<str<<CurrentStep<<".data";
  if (CurrentStep==TotalSteps) {file="";file<<DumpFolder<<"/"<<str<<".final.data";}
  ofstream of(file.c_str());
  cudaThreadSynchronize();
  of<<data;
  of.close();
  return 0;
}
  
int GUPS::DumpOut(){
  string sm,ss;
  sm=DumpMode;
  //if (DumpMode==""){//dedaut mode
  //DumpFile("eta",Datas["eta"]);
  //}else
  while (sm !=""){
	sm>>ss;
	if (Datas(ss) != NULL)
	  DumpFile(ss,Datas[ss]);
	else GV<0>::LogAndError>>"Error: data ">>ss>>" does not exist!\n";
  }
  return 0;
}

int GUPS::SetSys(string ss){
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

  ///////////////////////////////////
  //GUPS_SYS_DEFINE
  if (sys == "cores"	) {Dyna[DynaID] = new DynamicsCores;}
  if (sys == "diffuse"	) {Dyna[DynaID] = new DynamicsDiffuse;}
  if (sys == "mart"	) {Dyna[DynaID] = new DynamicsMart;}
  if (sys == "stress"	) {Dyna[DynaID] = new DynamicsStress;}
  if (sys == "xxx"	) {Dyna[DynaID] = new DynamicsXxx;}
  //GUPS_SYS_DEFINE
  ///////////////////////////////////
  else {
	GV<0>::LogAndError>>"System ">>ss>>"is not recognized\n";
	return -1;
  }
  return 0;
}

//////////////////////////////////////////////////
int GUPS::Set(string ss){
  string var;
  ss>>var;
  Vars[var] = ss;
  return 0;
}

int GUPS::Link(string ss){
  string target,link;
  ss>>target>>link;
  Vars.Link(target,link);
  return 0;
}

int GUPS::Read(string ss){
  string file,var; ss>>var>>file;
  ifstream ifs;
  ifs.open(file.c_str());
  if (ifs){
	ifs>>Datas[var];
	ifs.close();
  }else{
	GV<0>::LogAndError>>"File ">>file>>" not found!\n";
	return -1;
  }
  return 0;
}

int GUPS::Run(string ss){
  int totalsteps=1;
  ss>>totalsteps; TotalSteps=totalsteps;
  if (totalsteps <= 0 ) return -1;
  //what dyna to use???? is defined in sys
  Dyna[DynaID]->Datas = &Datas; // the data is passed by reference ( big )
  // paras is passed by value ( small )
  Dyna[DynaID]->Vars= Vars; 
  if ( !IsDynaInit[DynaID] ){
	Dyna[DynaID]->InitDynamics();
	IsDynaInit[ DynaID ] = true;
  }
  int  thermoInterval;
  if ( ThermoSteps==0) thermoInterval=totalsteps+1;else thermoInterval = totalsteps/ThermoSteps;
  if ( thermoInterval==0 ) thermoInterval=1;
  int  dumpInterval;
  if ( DumpSteps== 0 ) dumpInterval= totalsteps+1; else dumpInterval  = totalsteps/DumpSteps;
  if ( dumpInterval == 0 ) dumpInterval =1;
  for (int i=1;i<=totalsteps;i++) {
	CurrentStep = i; // this will be used in dump and thermo to identity the progress
	//if (DEBUG) Datas["eta"].DeviceToHost();
	Dyna[DynaID]->Fix(real(i)/totalsteps);
	Dyna[DynaID]->CalculateAll();
	Dyna[DynaID]->Iterate();

	if (i % thermoInterval==0|| i==totalsteps) ThermoOut();
	if (i % dumpInterval  ==0|| i==totalsteps) DumpOut();
  }
  return 0;
}
