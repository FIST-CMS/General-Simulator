/*

 */

#ifndef GS_Eins_H
#define GS_Eins_H


using namespace DATA_NS;

namespace GS_NS{
  class GS{//
  public:
	Map< string, Data<Real> > 	Datas;
	Map< string, string > 		Vars;

	static const int	DynaMax=1000;
	int 				DynaID; // the current Dyna[i] in calculation
	Dynamics 			*Dyna[DynaMax]; //base pointer to access derived dynammics
	bool 				IsDynaInit[DynaMax];

  public:
	GS();
	~GS();
	int SetSys(string ss); //set the system type which should be a pre-command for other commands except the device
	////////////////////////////////////////////
	int Set(string); 
	int Link(string);
	int Read(string); 
	int ReadHere(string name, string &arrays); // read Data in the script directly
	////////////////////////////////////////////
	//real StartTemperature, EndTemperature;
	int CurrentStep;
	int	TotalSteps;
	int Run();
	int Run(string ss);
	int RunFunc(string funcName);

	int InfoSteps;
	string InfoMode;
	int SetInfo(string ss);
	int InfoOut();

	string DumpFolder;
	int DumpSteps;
	string DumpMode;
	int SetDump(string ss);
	template<class type> int DumpFile(string str,Data<type> &data);
	int DumpOut();
  };
};

#endif
