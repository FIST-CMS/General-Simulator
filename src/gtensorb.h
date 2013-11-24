
#ifndef GTENSORB_EINS_H
#define GTENSORB_EINS_H

using namespace DATA_NS;

namespace GUPS_NS{

  class GTensorB: public Data<Real>{
  public:
	//TensorB();
	int InitB (int variantN1,int variantN2,
			   int lx, int ly, int lz,
			   real a1, real a2, real a3,
			   Data<Real> &tensor,Data<Real> &modulus);
	int UnitVector(float dx,float dy,float dz);
	//real C00,C01,C33;
	Data<Real> _gSquare;
	Data<Real> unitVector;
  };
}
	

#endif
