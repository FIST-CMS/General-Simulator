
#ifndef TENSORB_EINS_H
#define TENSORB_EINS_H

using namespace DATA_NS;

namespace GS_NS{

  class TensorB: public Data<Real>{
  public:
	TensorB();
	int InitB(int variantN, int lx, int ly, int lz, real a1, real a2, real a3, Data<Real> &tensor);
	real VF(int x,int n,float dx);
	int UnitVector(float dx,float dy,float dz);
	real C00,C01,C33;
	//private:
	Data<Real> _g;
	Data<Real> _gSquare;
	Data<Real> unitVector;
	Data<Real> sigma;

	Data<Real> omega;//(2,3,3,Data_HOST);
	Data<Real> iomega;//(2,3,3,Data_HOST);
	Data<Real> cijkl;//(4,3,3,3,3,Data_HOST);
	Data<Real> temp;//(4,3,3,3,3,Data_HOST);
  };
}
	

#endif
