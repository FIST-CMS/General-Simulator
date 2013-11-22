#include<stdlib.h>
#include<iostream>
#include<math.h>
#include<string>
#include<time.h>
using namespace std;

#define max_E(a,b) (((a)>(b))?(a):(b))
#define min_E(a,b) (((a)<(b))?(a):(b))
#define abs_E(x) (((x)>0)?(x):-(x))

#define pow2_E(a) ((a)*(a))
#define pow3_E(a) ((a)*(a)*(a))
#define pow4_E(a) ((a)*(a)*(a)*(a))
#define pow5_E(a) ((a)*(a)*(a)*(a)*(a))
#define pow6_E(a) ((a)*(a)*(a)*(a)*(a)*(a))

#define mod2P_E(a,n) (i&(n-1))
#define div2P_E(a,n) (i>>log2(n))

#define uperTrunc(a,x) (((a)<=(x))?(1):(0))
#define lowerTrunc(a,x) (((a)>=(x))?(1):(0))

/************** useful constant*********************************/ 
const double E=2.7182818284590;
const double Pi=3.1415926;
/*****************random functions******************************/
//real random number between 0~1
double randreal(){ return rand()*1.0/RAND_MAX; }
//real random number between 0~max
double randreal(double max){ return randreal()*max; }
//real random number between min~max
double randreal(double min,double max){ return min+randreal()*(max-min); }
//real random number obey normal distribution with mean=0 and SD=1
double NormalDistributionX(){ double U1,U2,R,Z,th; U1=randreal();U2=randreal(); R=sqrt(-2*log(U2)); th=2*3.1415926*U1; Z=R*cos(th); return Z; }
// real random number obey normal distribution with mean and SD
double NormalDistributionX(double mean,double sd){ return mean+sd*NormalDistributionX(); }
/****************useful math function but not defined formally*/
// exp(x)
//double exp(double x){ return pow(E,x); }
//double exp(float x){ return pow(E,x); }
//double exp(int x){ return pow(E,x); }
//double abs(double x){if (x>=0) return x; else return -x;}



//complex number define-------------------------
class complex_E{
public:
	double Re;
	double Im;
	//construct from nothing
	complex_E(){ Re=0; Im=0; }
	//type change between complex_E and double--------------------------
	//double to complex_E
	complex_E(double real,double image){ this->Re=real; this->Im=image; }
	//double[2] to complex_E;
	complex_E(double c[2]){ Re=c[0]; Im=c[1]; }
	// complex_E to double
	operator double(){return Re;}
	//+ - * / reload----------------------------------
  //reload =
	complex_E& operator =(double left_d){
		this->Re=left_d;this->Im=0;
		return *this;
	}
	
	// << reload
	friend ostream& operator<<(ostream &os,complex_E &c){
		os<<"("<<c.Re<<","<<c.Im<<")"; return os;
	}
};
//reload +
complex_E operator+(complex_E c1,complex_E c2){return complex_E(c1.Re+c2.Re,c1.Im+c2.Im); }
complex_E operator+(double d,complex_E c){ return complex_E(d+c.Re,c.Im); }
complex_E operator+(complex_E c,double d){ return complex_E(d+c.Re,c.Im); }
//reload -
complex_E operator-(complex_E c1,complex_E c2){ return complex_E(c1.Re-c2.Re,c1.Im-c2.Im); }
complex_E operator-(double d,complex_E c){ return complex_E(d-c.Re,-c.Im); }
complex_E operator-(complex_E c,double d){ return complex_E(c.Re-d,c.Im); }
//reload *
complex_E operator*(complex_E c1,complex_E c2){ return complex_E(c1.Re*c2.Re-c1.Im*c2.Im,c1.Re*c2.Im+c1.Im*c2.Re);}
complex_E operator*(complex_E c,double d){ return complex_E(c.Re*d,c.Im*d);}
complex_E operator*(double d,complex_E c){ return complex_E(c.Re*d,c.Im*d);}
//reload !=
int operator!=(complex_E c1,complex_E c2){if (c1.Re!=c2.Re||c1.Im!=c2.Im)return 1;else return 0;}
int operator!=(complex_E c1,double c2){if (c1.Re!=c2||c1.Im!=0)return 1;else return 0;}
int operator!=(double c2,complex_E c1){if (c1.Re!=c2||c1.Im!=0)return 1;else return 0;}


