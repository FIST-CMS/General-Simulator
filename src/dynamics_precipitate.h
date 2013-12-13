
#ifndef DYNAMICS_precipitate_Eins_H
#define DYNAMICS_precipitate_Eins_H

using namespace DATA_NS;

namespace GS_NS{

  class Dynamics_precipitate: public Dynamics {//total energy for its main definition
  public:
	// virtual functions need to be overriden
	virtual int Initialize();
	virtual int Calculate();
	virtual int RunFunc(string funcName);
	virtual int Fix(real progress);
	virtual string Get(string );//return the statistic info
	///////////////////////
	//virtual int Set(string);

	Dynamics_precipitate();
	~Dynamics_precipitate();
	// eta and con free chemical free energy

	int 		VariantN;
	Real		TransitionTemperature;
	Real		Temperature;
	Real		Meta,Beta,DeltaTime,Xi, Lpp, Arfi;
	Real		A[10];
	//Real		*A_dev;
	Real		Concentration1, Concentration2;
	Real 		weightElastic;
	Real		weightConNoise;
	Real		weightEtaNoise;

	Data<Real>  *Concentration;
	Data<Real>  *Eta;
	Data<Real>  *StrainTensor;

	
	Data<Real> 		EtaLFE;
	Data<Complex> 	EtaLFE_CT;
	Data<Real>		ConLFE;
	Data<Complex>	ConLFE_CT;


	//cufft plan
	cufftHandle		plan_vn;
	cufftHandle 	plan_n;
	//Elastic
	GTensorB		B;
	Data<Real> 		ElasticEnergy;
	Data<Real> 		ElasticForce;
	int 			ElasticEnergyCalculate();
	int 			ElasticForceCalculate();


	// temperate term
	Data<Complex> 	Con_CT;	
	Data<Complex> 	ConRan_CT;	
	Data<Complex>   RTermCon_CT;
	int				LocalConFreeEnergyCalculate();

	Data<Complex>   Eta_CT;
	Data<Complex>   EtaRan_CT;
	Data<Complex> 	RTermEta_CT; 
	Data<Complex>	ElasticTerm_CT;
	int 			LocalEtaFreeEnergyCalculate();

	//noise
	Random 		Noise_vn;
	Random 		Noise_n;
	int             ConcentrationUpdate();
	int 			EtaUpdate();
  };

}
#endif
