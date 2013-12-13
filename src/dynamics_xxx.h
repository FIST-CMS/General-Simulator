
#ifndef DYNAMICS_xxx_GS_H
#define DYNAMICS_xxx_GS_H

using namespace DATA_NS;

namespace GS_NS{

  class Dynamics_xxx: public Dynamics {
  public:
	////////////////////////////////
	Dynamics_xxx();
	virtual int 	Initialize();
	virtual int 	Calculate();
	virtual int 	RunFunc(string func);
	virtual int 	Fix(real progress);
	virtual string	Get(string var);
	~Dynamics_xxx();
	////////////////////////////////
  };
}
#endif
