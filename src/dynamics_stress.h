
#ifndef DYNAMICS_STRESS_Eins_H
#define DYNAMICS_STRESS_Eins_H

using namespace DATA_NS;

namespace GS_NS{

  class Dynamics_stress: public Dynamics {//total energy for its main definition
  public:
	// virtual functions need to be overriden
	virtual int Initialize();
	virtual int Calculate();
	virtual int RunFunc(string funcName);
	virtual int Fix(real progress);
	virtual string Get(string );//return the statistic info
	///////////////////////
	//virtual int Set(string);

	Dynamics_stress();
	~Dynamics_stress();
	// eta and con free chemical free energy

	int 		VariantN;
	static const int  BaseVariantN=6;
	Real		Xi;

	Data<Real>  *Eta;
	Data<Real>  *Stress;
	Data<Real>  *Defect;
	Data<Real>  *StrainTensor;
	Data<Real>  tensor;
	
	//cufft plan
	cufftHandle	plan_vn;
	cufftHandle plan_bvn;
	//Elastic
	GTensorB			B;
	int 			ElasticForceCalculate();

	// temperate term
	Data<Complex>   Eta_CT;
	Data<Complex> 	RTermEta_CT; 

  };

}


#endif
