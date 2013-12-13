

#ifndef GS_RANDOM_EINS_H
#define GS_RANDOM_EINS_H
#include<curand.h>
using namespace DATA_NS;
namespace GS_NS{

  class Random: public Data<Real>{
  public:
	curandGenerator_t Gen_dev,Gen_host;
	real	Mean,Variance;
	int Seed_dev,Seed_host;
	Random();
	~Random();
	int InitRandom(int *dimArr,real mean,real variance,int seed_host,int seed_dev);
	int InitRandom(int n,...); 
	int SetParas(real mean,real variance,int seed_host,int seed_dev);
	Random &NewNormal_device();
	Random &NewNormal_host();
  };

  

};

#endif
