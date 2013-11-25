
#ifndef DYNAMICS_MART_Eins_H
#define DYNAMICS_MART_Eins_H

using namespace DATA_NS;

namespace GS_NS{

  class DynamicsMart: public Dynamics {//total energy for its main definition
  public:

	int 		VariantN;
	real 		DeltaTime;

	Data<Real>  *StrainTensor;
	Data<Real>  *Eta;
	Data<Real>  *Concentration;
	Data<Real>  *Defect;
	// virtual functions need to be overriden
	virtual int Initialize();
	virtual int Calculate();
	virtual int RunFunc(string funcName);
	virtual int Fix(real progress);
	virtual string Get(string );//return the statistic info
	///////////////////////
	//virtual int Set(string);

	DynamicsMart();
	~DynamicsMart();

	Random 	Noise;
	Real	weightNoise;
	
	Data<Real> Gradient;
	Data<Real> GradientEnergy;
	Data<Real> GradientForce;
	Real weightGradient;
	int GradientCalculate();
	int GradientEnergyCalculate();
	int GradientForceCalculate();

	real TransitionTemperature;
	real Temperature;
	real LPC[4];//Landau_Poly_Coefficients
	int SetCoeff(string ss);
	int LPCConstruct();// the function form can be uniformed
	Data<Real> ChemicalEnergy;
	Data<Real> ChemicalForce;
	Real weightChemical;
	int ChemicalEnergyCalculate();
	int ChemicalForceCalculate();
	
	GTensorB	B;
	Data<Real> 	ElasticEnergy;
	Data<Real> 	ElasticForce;
	Real 		weightElastic;
	int 		ElasticEnergyCalculate();
	int 		ElasticForceCalculate();
	Data<Real> 	Eta_RT;	//for temp use 
	Data<Complex> 	Eta_CT;	//for temp use 
	Data<Complex> 	ReciprocalTerm; // for temp use 
	cufftHandle	planAll_Cuda;

	//Data<Real> PointDefect;
	int Block();
	Data<Real> *DislocationStressOForm;
	Data<Real> DislocationStress;
	Data<Real> DislocationForceConst;
	Data<Real> DislocationForce;
	Real weightDislocation;
	int DislocationForceInit();
	int DislocationEnergyCalculate();
	int DislocationForceCalculate();

	Data<Real> ExternalStress;
	Data<Real> ExternalForce;
	Real weightExternal;
	int ExternalStressCalculate();
	int ExternalForceCalculate();


	/////////////////////////////////////////
	// para settings
	/////////////////////////////////////////

  };

}

#endif
