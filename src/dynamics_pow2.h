
#ifndef DYNAMICS_POW2_Eins_H
#define DYNAMICS_POW2_Eins_H

using namespace DATA_NS;

namespace GS_NS{

  class Dynamics_pow2: public Dynamics {
  public:
	int Matrix_multi(string para);
	////////////////////////////////
	Dynamics_pow2();
	virtual int 	Initialize();
	virtual int 	Calculate();
	virtual int 	RunFunc(string func);
	virtual int 	Fix(real progress);
	virtual string 	Get(string var);
	~Dynamics_pow2();
	////////////////////////////////
	float x;
	Data<Real>* Matrix;
  };

}

#endif
