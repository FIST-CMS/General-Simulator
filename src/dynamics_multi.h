
#ifndef DYNAMICS_MULTI_Eins_H
#define DYNAMICS_MULTI_Eins_H

using namespace DATA_NS;

namespace GS_NS{

  class Dynamics_multi: public Dynamics {
  public:
	int Matrix_multi(string para);
	////////////////////////////////
	Dynamics_multi();
	virtual int 	Initialize();
	virtual int 	Calculate();
	virtual int 	RunFunc(string func);
	virtual int 	Fix(real progress);
	virtual string 	Get(string var);
	~Dynamics_multi();
	////////////////////////////////
  };
}
#endif
