

#ifndef RANDOM_EINS_H
#define RANDOM_EINS_H
using namespace DATA_NS;
namespace GUPS_NS{

  class Random: public Data<Real>{
  public:
	curandGenerator_t Gen_dev,Gen_host;
	real	Mean,Variance;
	real	Seed_dev,Seed_host;
	Random();
	~Random();
	int InitRandom(int *dimArr,real mean,real variance,real seed_host,real seed_dev);
	int InitRandom(int n,...); 
	int SetParas(real mean,real variance,real seed_host,real seed_dev);
	Random &NewNormal_device();
	Random &NewNormal_host();
  };

  

};

#endif
