
#ifndef DYNAMICS_pow_GS_H
#define DYNAMICS_pow_GS_H

using namespace DATA_NS;

namespace GS_NS{

  class Dynamics_pow: public Dynamics {
  public:
	////////////////////////////////
	Dynamics_pow();
	virtual int 	Initialize();
	virtual int 	Calculate();
	virtual int 	RunFunc(string func);
	virtual int 	Fix(real progress);
	virtual string	Get(string var);
	~Dynamics_pow();
	////////////////////////////////
	Real x;
	Data<Real>* Matrix;
  };
}
#endif
