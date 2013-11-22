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
const float E=2.7182818284590;
const float Pi=3.1415926;
/*****************random functions******************************/
//real random number between 0~1
float randreal(){ return rand()*1.0/RAND_MAX; }
//real random number between 0~max
float randreal(float max){ return randreal()*max; }
//real random number between min~max
float randreal(float min,float max){ return min+randreal()*(max-min); }
//real random number obey normal distribution with mean=0 and SD=1
float NormalDistributionX(){ float U1,U2,R,Z,th; U1=randreal();U2=randreal(); R=sqrt(-2*log(U2)); th=2*3.1415926*U1; Z=R*cos(th); return Z; }
// real random number obey normal distribution with mean and SD
float NormalDistributionX(float mean,float sd){ return mean+sd*NormalDistributionX(); }
/****************useful math function but not defined formally*/
// exp(x)
//float exp(float x){ return pow(E,x); }
//float exp(float x){ return pow(E,x); }
//float exp(int x){ return pow(E,x); }
//float abs(float x){if (x>=0) return x; else return -x;}



//complex number define-------------------------
class complex_E{
public:
	float Re;
	float Im;
	//construct from nothing
	complex_E(){ Re=0; Im=0; }
	//type change between complex_E and float--------------------------
	//float to complex_E
	complex_E(float real,float image){ this->Re=real; this->Im=image; }
	//float[2] to complex_E;
	complex_E(float c[2]){ Re=c[0]; Im=c[1]; }
	// complex_E to float
	operator float(){return Re;}

	//+ - * / reload----------------------------------
  //reload =
	complex_E& operator =(float left_d){
		this->Re=left_d;this->Im=0;
		return *this;
	}
	
	// << reload
	friend ostream& operator<<(ostream &os,complex_E &c){
		os<<"("<<c.Re<<","<<c.Im<<")"; return os;
	}
};
//+ - * / reload----------------------------------
//reload +
complex_E operator+(complex_E c1,complex_E c2){return complex_E(c1.Re+c2.Re,c1.Im+c2.Im); }
complex_E operator+(float d,complex_E c){ return complex_E(d+c.Re,c.Im); }
complex_E operator+(complex_E c,float d){ return complex_E(d+c.Re,c.Im); }
//reload -
complex_E operator-(complex_E c1,complex_E c2){ return complex_E(c1.Re-c2.Re,c1.Im-c2.Im); }
complex_E operator-(float d,complex_E c){ return complex_E(d-c.Re,-c.Im); }
complex_E operator-(complex_E c,float d){ return complex_E(c.Re-d,c.Im); }
//reload *
complex_E operator*(complex_E c1,complex_E c2){ return complex_E(c1.Re*c2.Re-c1.Im*c2.Im,c1.Re*c2.Im+c1.Im*c2.Re);}
complex_E operator*(complex_E c,float d){ return complex_E(c.Re*d,c.Im*d);}
complex_E operator*(float d,complex_E c){ return complex_E(c.Re*d,c.Im*d);}
//reload /
complex_E operator/(complex_E c1,complex_E c2){ float mo=pow2_E(c2.Re)+pow2_E(c2.Im);return complex_E((c1.Re*c2.Re+c1.Im*c2.Im)/mo,(c1.Im*c2.Re-c1.Re*c2.Im)/mo);}
complex_E operator/(complex_E c,float d){ return complex_E(c.Re/d,c.Im/d);}
complex_E operator/(float d,complex_E c){ float mo=pow2_E(c.Re)+pow2_E(c.Im); return complex_E(c.Re*d/mo,c.Im*d/mo);}


//reload !=
int operator!=(complex_E c1,complex_E c2){if (c1.Re!=c2.Re||c1.Im!=c2.Im)return 1;else return 0;}
int operator!=(complex_E c1,float c2){if (c1.Re!=c2||c1.Im!=0)return 1;else return 0;}
int operator!=(float c2,complex_E c1){if (c1.Re!=c2||c1.Im!=0)return 1;else return 0;}

//-------------------------------------------------------------------------------------
//cucomplex number define-------------------------
class cucomplex_E{
public:
	float Re;
	float Im;
	//construct from nothing
	__device__ cucomplex_E(){ Re=0; Im=0; }
	//type change between cucomplex_E and float--------------------------
	//float to cucomplex_E
	__device__ cucomplex_E(float real,float image){ this->Re=real; this->Im=image; }
	//float[2] to cucomplex_E;
	__device__ cucomplex_E(float c[2]){ Re=c[0]; Im=c[1]; }
	//complex_E to cucomplex_E;
	__device__ cucomplex_E(complex_E c){ Re=c.Re; Im=c.Im; }
	// cucomplex_E to float
	__device__ float cufloat(){return Re;}
	
};
//+ - * / reload----------------------------------
//reload =
	__device__ int cuset(cucomplex_E &left,float right){
		left.Re=right;  left.Im=0;
		return 0;
	}
	__device__ int cuset(cucomplex_E &left,cucomplex_E right){
		left.Re=right.Re;left.Im=right.Im;
		return 0;
	}

//reload +
__device__ cucomplex_E cuadd(cucomplex_E c1,cucomplex_E c2){return cucomplex_E(c1.Re+c2.Re,c1.Im+c2.Im); }
__device__ cucomplex_E cuadd(float d,cucomplex_E c){ return cucomplex_E(d+c.Re,c.Im); }
__device__ cucomplex_E cuadd(cucomplex_E c,float d){ return cucomplex_E(d+c.Re,c.Im); }
//reload -
__device__ cucomplex_E cuminus(cucomplex_E c1,cucomplex_E c2){ return cucomplex_E(c1.Re-c2.Re,c1.Im-c2.Im); }
__device__ cucomplex_E cuminus(float d,cucomplex_E c){ return cucomplex_E(d-c.Re,-c.Im); }
__device__ cucomplex_E cuminus(cucomplex_E c,float d){ return cucomplex_E(c.Re-d,c.Im); }
//reload *
__device__ cucomplex_E cumulti(cucomplex_E c1,cucomplex_E c2){ return cucomplex_E(c1.Re*c2.Re-c1.Im*c2.Im,c1.Re*c2.Im+c1.Im*c2.Re);}
__device__ cucomplex_E cumulti(cucomplex_E c,float d){ return cucomplex_E(c.Re*d,c.Im*d);}
__device__ cucomplex_E cumulti(float d,cucomplex_E c){ return cucomplex_E(c.Re*d,c.Im*d);}
__device__ cucomplex_E cumulti(float d,float c){ return cucomplex_E(c*d,0.0f);}
//reload /
__device__ cucomplex_E cudivi(cucomplex_E c1,cucomplex_E c2){ float mo=pow2_E(c2.Re)+pow2_E(c2.Im);return cucomplex_E((c1.Re*c2.Re+c1.Im*c2.Im)/mo,(c1.Im*c2.Re-c1.Re*c2.Im)/mo);}
__device__ cucomplex_E cudivi(cucomplex_E c,float d){ return cucomplex_E(c.Re/d,c.Im/d);}
__device__ cucomplex_E cudivi(float d,cucomplex_E c){ float mo=pow2_E(c.Re)+pow2_E(c.Im); return cucomplex_E(c.Re*d/mo,c.Im*d/mo);}

//reload !=
__device__ int cuunequal(cucomplex_E c1,cucomplex_E c2){if (c1.Re!=c2.Re||c1.Im!=c2.Im)return 1;else return 0;}
__device__ int cuunequal(cucomplex_E c1,float c2){if (c1.Re!=c2||c1.Im!=0)return 1;else return 0;}
__device__ int cuunequal(float c2,cucomplex_E c1){if (c1.Re!=c2||c1.Im!=0)return 1;else return 0;}

//

//------------------------------------------------------------------------------------------
//use gauss collum main to find the inverse of a Matrix
int GaussCMInverse(float *AA,float *B,int n){
  int i,j,k;
	float temp;
	float *A;
	A=(float*)malloc(sizeof(float)*n*n);

	for (int i=0;i<n;i++)
		for (int j=0;j<n;j++){
			if (i==j) B[i*n+j]=1;else B[i*n+j]=0;
			A[i*n+j]=AA[i*n+j];
		}
	for (i=0;i<n;i++){
		//find the maximum one  ...
		k=i;
		temp=fabs(A[i*n+i]);
		for (j=i;j<n;j++)
			if (fabs(A[j*n+i])>temp){ k=j;temp=fabs(A[j*n+i]); }
		//if no answer return error code -1
		if (temp==0){ free(A); return -1;}
		//change the one with the maximum one  ...
		if (i!=k)
			for (j=0;j<n;j++){
				temp=A[i*n+j];A[i*n+j]=A[k*n+j]; A[k*n+j]=temp;
				temp=B[i*n+j];B[i*n+j]=B[k*n+j]; B[k*n+j]=temp;
			}
		//dismiss 
		for (j=0;j<n;j++){
			if (j==i) continue;
			temp=A[j*n+i]/A[i*n+i];
			for (k=0;k<n;k++) {
				A[j*n+k]=A[j*n+k]-A[i*n+k]*temp;
				B[j*n+k]=B[j*n+k]-B[i*n+k]*temp;
			}
		}
		temp=A[i*n+i];
		for (j=0;j<n;j++){ A[i*n+j]=A[i*n+j]/temp;B[i*n+j]=B[i*n+j]/temp;}
	}
	free(A);
	return 0;
}


int SetZeros(float * _m,int n){
	for (int i=0;i<n;i++){
		_m[i]=0.0;
	}
	return 0;
}
