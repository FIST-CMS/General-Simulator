/*

 */

#ifndef GUPS_Eins_H
#define GUPS_Eins_H


using namespace DATA_NS;

namespace GUPS_NS{
  //GUPS: Gpu based Universal Phase Field Simulator
  class GUPS{//default 3D situation
  public:
	Map< string, Data<Real> > 	Datas;
	Map< string, string > 		Vars;
	/*
	  eta defect straintensor will be used in mart
	  sys mart
	    Vars:
		  gridsize nx ny nz dx dy dz
		  variantn n
		Datas:
		  eta
		  defect
	 */

	static const int	DynaMax=100;
	int 		DynaID; // the current Dyna[i] in calculation
	Dynamics 	*Dyna[DynaMax]; //base pointer to access derived dynammics
	bool 		IsDynaInit[DynaMax];

  public:
	GUPS();
	~GUPS();
	int SetSys(string ss); //set the system type which should be a pre command for other commands except for device
	////////////////////////////////////////////
	int Set(string); // cal dyna->Set
	int Link(string);
	int Read(string); // cal dyna->Read
	////////////////////////////////////////////
	int CreateVariant(int n1, real *tensor);

	//real StartTemperature, EndTemperature;
	int Fix(int step, int totalsteps); // set mode with set fix ...

	int CurrentStep;
	int	TotalSteps;
	int Run();
	int Run(string ss);

	int ThermoSteps;
	string ThermoMode;
	int SetThermo(string ss);
	int ThermoOut();

	string DumpFolder;
	int DumpSteps;
	string DumpMode;
	int SetDump(string ss);
	template<class type> int DumpFile(string str,Data<type> &data);
	int DumpOut();
  };
};

#endif
