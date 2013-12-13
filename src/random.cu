
#include<curand.h>
#include"../include/datamain.th"
#include"random.h"

using namespace GS_NS;
using namespace DATA_NS;

<<<<<<< HEAD
int Random::InitRandom(int *dimArr, real mean, real variance,int seed_host,int seed_dev){
  curandCreateGenerator(&Gen_dev,CURAND_RNG_PSEUDO_DEFAULT);
  curandCreateGeneratorHost(&Gen_host,CURAND_RNG_PSEUDO_DEFAULT);
  curandSetPseudoRandomGeneratorSeed(Gen_dev,seed_dev);
  curandSetPseudoRandomGeneratorSeed(Gen_host,seed_host);
  Init(dimArr,Data_HOST_DEV);
  Mean=mean;
  Variance=variance;
  Seed_dev=seed_dev;
  Seed_host=seed_host;
=======
int Random::InitRandom(int *dimArr, real mean, real variance,real Seed_host,real Seed_dev){
  curandCreateGenerator(&Gen_dev,CURAND_RNG_PSEUDO_DEFAULT);
  curandCreateGeneratorHost(&Gen_host,CURAND_RNG_PSEUDO_DEFAULT);
  curandSetPseudoRandomGeneratorSeed(Gen_dev,Seed_dev);
  curandSetPseudoRandomGeneratorSeed(Gen_host,Seed_host);
  Init(dimArr,Data_HOST_DEV);
  Mean=mean;
  Variance=variance;
>>>>>>> origin/master
  return 0;
}

Random::Random(){
<<<<<<< HEAD
  Mean=0.0f;
  Variance=1.0f;
  Seed_dev=0;
  Seed_host=0;
=======
  Mean=0.0;
  Variance=1.0;
  Seed_dev=0.0;
  Seed_host=0.0;
>>>>>>> origin/master
  Gen_host = NULL;
  Gen_dev  = NULL;
}
Random::~Random(){
  if (Gen_dev) curandDestroyGenerator(Gen_dev);
  if (Gen_host) curandDestroyGenerator(Gen_host);
}
int Random::InitRandom(int n, ...){
  va_list args;
  va_start(args,n);
  int *arr	=	new int [ n+ 2 ];
  arr[0]=n;
  for (int i=1; i<=n; i++)
	arr[i]	=	va_arg(args,int);
  va_end(args);
  InitRandom(arr,Mean,Variance,Seed_host,Seed_dev);
  delete[]arr;
  return 0;
}
<<<<<<< HEAD
int Random::SetParas(real mean,real variance,int seed_host,int seed_dev){
=======
int Random::SetParas(real mean,real variance,real seed_host,real seed_dev){
>>>>>>> origin/master
  Mean=mean;
  Variance=variance;
  Seed_host=seed_host;
  Seed_dev=seed_dev;
  curandSetPseudoRandomGeneratorSeed(Gen_dev,Seed_dev);
  curandSetPseudoRandomGeneratorSeed(Gen_host,Seed_host);
  return 0;
}

  
Random &Random::NewNormal_device(){
  curandGenerateNormal(Gen_dev,(float*)Arr_dev,N(),Mean,Variance);//??
  return *this;
}
Random &Random::NewNormal_host(){
  curandGenerateNormal(Gen_host,(float*)Arr,N(),Mean,Variance);
  return *this;
}

