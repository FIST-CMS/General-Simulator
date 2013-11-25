
#ifndef DYNAMICS_CORES_Eins_H
#define DYNAMICS_CORES_Eins_H

using namespace DATA_NS;

namespace GS_NS{

  class DynamicsCores: public Dynamics {//total energy for its main definition
  public:
	// virtual functions need to be overriden
	virtual int Initialize();
	virtual int Calculate();
	virtual int RunFunc(string funcName);
	virtual int Fix(real progress);
	virtual string Get(string );//return the statistic info
	///////////////////////
	//virtual int Set(string);
	DynamicsCores();
	~DynamicsCores();
	// eta and con free chemical free energy

	int 		VariantN,CoresN;
	real		Radius;
	real		Concentration1,Concentration2;
	string 		Method;
	Data<Real>  *Eta;
	Data<Real>  *Concentration;
	Data<Real>  Cores;
	Data<bool>  Mark;
	int RandomCores();
	int RegularCores1D();
	int RegularCores2D();
	int RegularCores3D();
  };

}


#endif
