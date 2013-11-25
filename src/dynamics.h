
#ifndef DYNAMICS_Eins_H
#define DYNAMICS_Eins_H

using namespace DATA_NS;

namespace GS_NS{

  class Dynamics: public Data<Real>{//total energy for its main definition
  public:
	Dynamics();
	virtual ~Dynamics();
	int 		nx,ny,nz;
	Real 		dx,dy,dz;
	// big data can be transfered between different dynas by reference
	// paras may keep different in different dynas by value transfer
	Map< string, Data<Real> > 	*Datas;
	Map< string, string > 		Vars;
	// total the influence: evolution pure
	virtual int Initialize()=0;
	virtual int Calculate()=0;
	virtual int RunFunc(string funcName)=0;
	virtual int Fix(real progress)=0; // from 0% to 1%
	virtual string Get(string svar)=0;//return staticstic variables
  };

}

#endif




