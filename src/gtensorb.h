
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
			   Data<Real> &tensor);
 	//__host__ __device__ real VF(int x,int n,float dx);
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
	Data<Real> temp;
  };
}
	

#endif
