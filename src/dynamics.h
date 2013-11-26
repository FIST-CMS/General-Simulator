
#ifndef DYNAMICS_Eins_H
#define DYNAMICS_Eins_H

using namespace DATA_NS;

namespace GS_NS{

  class Dynamics{
  public:
	Dynamics();
	virtual ~Dynamics();
	///////////////////////////////////////////
	int 		nx,ny,nz;
	Real 		dx,dy,dz;
	///////////////////////////////////////////
	Map< string, Data<Real> >*	Datas; //big data
	Map< string, string > 		Vars;   //small para
	///////////////////////////////////////////
	virtual int 	Initialize()=0;
	virtual int 	Calculate()=0;
	virtual int 	RunFunc(string funcName)=0;
	virtual int 	Fix(real progress)=0; // from 0% to 100%
	virtual string 	Get(string svar)=0;//return staticstic variables
  };

}

#endif




