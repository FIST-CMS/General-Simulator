
#ifndef DYNAMICS_XXX_Eins_H
#define DYNAMICS_XXX_Eins_H

using namespace DATA_NS;

namespace GUPS_NS{

  class DynamicsXxx: public Dynamics {//total energy for its main definition
  public:
	// virtual functions need to be overriden
	int InitDynamics();
	int CalculateAll();
	int Iterate();
	int Fix(real progress);
	Real Get(string );//return the statistic info
	///////////////////////
	//virtual int Set(string);
	DynamicsXxx();
	~DynamicsXxx();
	// eta and con free chemical free energy
	float x;

  };

}

#endif
