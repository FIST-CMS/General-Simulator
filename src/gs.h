/*

 */

#ifndef GS_Eins_H
#define GS_Eins_H


using namespace DATA_NS;

namespace GS_NS{
  class GS{//
  public:
	Map< Data<Real> > 	*Datas;
	Map< string > 		*Vars;
	////////////////////////////////
	const static int 	DynaMax  = 1000;
	int					DynaTotal;
	Dynamics	        *Dynas[DynaMax];
	Map< bool >			DynasInited;
	Map< int  >			DynaPositions;
	string				DynaName;
	int					DynaPosition;

  public:
	GS();
	~GS();
	int SetSys(string ss); //set the system type which should be a pre-command for other commands except the device
	////////////////////////////////////////////
	int Set(string); 
	int Link(string);
	///////////////////////////////////////////
	int Read(string); 
	int ReadHere(string name, string &arrays); // read directly from script
	int Write(string);
	int WriteHere(string);
	////////////////////////////////////////////
	int CurrentStep;
	int	TotalSteps;
	int Run();
	int Run(string ss);
	int RunFunc(string funcName);
	////////////////////////////////////////////
	int InfoSteps;
	string InfoMode;
	int SetInfo(string ss);
	int InfoOut();
	////////////////////////////////////////////
	string DumpFolder;
	int DumpSteps;
	string DumpMode;
	int SetDump(string ss);
	int DumpOut();
	////////////////////////////////////////////
  };
};

#endif
