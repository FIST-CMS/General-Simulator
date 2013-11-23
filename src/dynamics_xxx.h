
#ifndef DYNAMICS_XXX_Eins_H
#define DYNAMICS_XXX_Eins_H

using namespace DATA_NS;

namespace GUPS_NS{

  class DynamicsXxx: public Dynamics {//total energy for its main definition
  public:
	DynamicsXxx();
	~DynamicsXxx();
	////////////////////////////////
	virtual int Initialize();
	virtual int Calculate();
	virtual int RunFunc(string funcName);
	virtual int Fix(real progress);
	virtual string Get(string );
	////////////////////////////////
	float x;

  };

}

#endif
