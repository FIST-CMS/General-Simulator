
////////////////////////////////////////
#include"pub.h"
#include"dynamics.h"
////////////////////////////////////////

#include"dynamics_cores.h"

using namespace GS_NS;
using namespace DATA_NS;
/*
  main calculation:
 */

int Dynamics_cores::Initialize(){
  //para setting should be finished before or within this function
  string ss;
  ss=(*Vars)["gridsize"];if (ss!="") { ss>>nx>>ny>>nz>>dx>>dy>>dz;} else {nx=ny=nz=16; dx=dy=dz=0.1;}
  ss=(*Vars)["variantn"];if (ss!="") { ss>>VariantN;} else {VariantN=4;}
  ss=(*Vars)["coresn"];	if (ss!="") { ss>>CoresN; }else { CoresN=5;}
  ss=(*Vars)["radius"];	if (ss!="") { ss>>Radius; }else { Radius=5;}
  ss=(*Vars)["concentration"];			if (ss!="") { ss>>Concentration1>>Concentration2; }else {Concentration1=0.2f; Concentration2 = 0.44f;}
  ss=(*Vars)["method"];  if (ss!="") { ss>>Method; } else { Method = "random"; }
  // it is called to initialize the --run-- function
  ///////////////////////////////////////////////////
  Eta = &((*Datas)["eta"]); // may create here
  Concentration = &((*Datas)["concentration"]); // may create here
  Eta->Init(4,VariantN,nx,ny,nz,Data_HOST);
  Concentration->Init(3,nx,ny,nz,Data_HOST);

  Cores.Init(2,CoresN,3,Data_HOST);
  Mark.Init(3,nx,ny,nz,Data_HOST);

  SetCalPos(Data_HOST);
  Mark=false;
  (*Concentration)=Concentration1;
  (*Eta)=0.f;

  return 0;

}

Dynamics_cores::Dynamics_cores(){}
Dynamics_cores::~Dynamics_cores(){}

int Dynamics_cores::RandomCores(){
  SetCalPos(Data_HOST);
  Mark=false;
  (*Concentration)=Concentration1;
  (*Eta)=0.f;
  for (int cn=0;cn<CoresN; cn++){
	int ox,oy,oz;
	for (int j=0;j< 100000;j++){
	  ox=random()%nx; oy= random()%ny; oz=random()%nz;
	  if (!Mark(ox,oy,oz)) break;
	}
	Cores(cn,0)=ox; Cores(cn,1)=oy; Cores(cn,2)=oz;
	int vtype=random()%VariantN;
	for (int i=0;i<nx; i++)
	  for (int j=0;j<ny; j++)
		for (int k=0;k<nz; k++)
		  if (
			  pow(0.0f+i-ox,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2)  ||
			  pow(0.0f+i-ox+nx,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) ||
			  pow(0.0f+i-ox-nx,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) || 
			  pow(0.0f+i-ox,2)+pow(0.0f+j-oy+ny,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) || 
			  pow(0.0f+i-ox,2)+pow(0.0f+j-oy-ny,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) ||
			  pow(0.0f+i-ox,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz+nz,2)<=pow(0.0f+Radius,2) || 
			  pow(0.0f+i-ox,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz-nz,2)<=pow(0.0f+Radius,2) 
			  ){
			Mark(i,j,k)=true;
			(*Concentration)(i,j,k)=Concentration2;
			(*Eta)(vtype,i,j,k)=1.0f;
		  }
  }
  return 0;
}

int Dynamics_cores::RegularCores1D(){
  for (int cn=0;cn<CoresN; cn++){
	int ox,oy,oz;
	ox=nx/2; oy=ny/2; oz= nz/CoresN/2+nx/CoresN*cn;
	Cores(cn,0)=ox; Cores(cn,1)=oy; Cores(cn,2)=oz;
	int vtype=(int)floor(random()%VariantN);
	vtype = cn % VariantN; // for debug????
	for (int i=0;i<nx; i++)
	  for (int j=0;j<ny; j++)
		for (int k=0;k<nz; k++)
		  if (
			  pow(0.0f+i-ox,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2)  ||
			  pow(0.0f+i-ox+nx,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) ||
			  pow(0.0f+i-ox-nx,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) || 
			  pow(0.0f+i-ox,2)+pow(0.0f+j-oy+ny,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) || 
			  pow(0.0f+i-ox,2)+pow(0.0f+j-oy-ny,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) ||
			  pow(0.0f+i-ox,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz+nz,2)<=pow(0.0f+Radius,2) || 
			  pow(0.0f+i-ox,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz-nz,2)<=pow(0.0f+Radius,2) 
			  ){
			Mark(i,j,k)=true;
			(*Concentration)(i,j,k)=Concentration2;
			(*Eta)(vtype,i,j,k)=1.0f;
		  }
  }
  return 0;
}

int Dynamics_cores::RegularCores2D(){
  for (int cn1=0;cn1<CoresN; cn1++){
	for (int cn2=0;cn2<CoresN; cn2++){
	  int ox,oy,oz;
	  ox=nx/2;
	  oy= ny/CoresN/2+ny/CoresN*cn2;
	  oz= nz/CoresN/2+nx/CoresN*cn1;
	  Cores(cn1*CoresN+cn2,0)=ox; Cores(cn1*CoresN+cn2,1)=oy; Cores(cn1*CoresN+cn2,2)=oz;
	  int vtype=(int)floor(random()*VariantN);
	  for (int i=0;i<nx; i++)
		for (int j=0;j<ny; j++)
		  for (int k=0;k<nz; k++)
			if (
				pow(0.0f+i-ox,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2)  ||
				pow(0.0f+i-ox+nx,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) ||
				pow(0.0f+i-ox-nx,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) || 
				pow(0.0f+i-ox,2)+pow(0.0f+j-oy+ny,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) || 
				pow(0.0f+i-ox,2)+pow(0.0f+j-oy-ny,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) ||
				pow(0.0f+i-ox,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz+nz,2)<=pow(0.0f+Radius,2) || 
				pow(0.0f+i-ox,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz-nz,2)<=pow(0.0f+Radius,2) 
				){
			  Mark(i,j,k)=true;
			  (*Concentration)(i,j,k)=Concentration2;
			  (*Eta)(vtype,i,j,k)=1.0f;
			}
	}
  }
  return 0;
}
int Dynamics_cores::RegularCores3D(){
  for (int cn1=0;cn1<CoresN; cn1++){
	for (int cn2=0;cn2<CoresN; cn2++){
	  for (int cn3=0;cn3<CoresN; cn3++){
		int ox,oy,oz;
		ox= nx/CoresN/2+nx/CoresN*cn3;
		oy= ny/CoresN/2+ny/CoresN*cn2;
		oz= nz/CoresN/2+nx/CoresN*cn1;
		Cores((cn1*CoresN+cn2)*CoresN+cn3,0)=ox; Cores((cn1*CoresN+cn2)*CoresN+cn3,1)=oy; Cores((cn1*CoresN+cn2)*CoresN+cn3,2)=oz;
		int vtype=(int)floor(random()*VariantN);
		for (int i=0;i<nx; i++)
		  for (int j=0;j<ny; j++)
			for (int k=0;k<nz; k++)
			  if (
				  pow(0.0f+i-ox,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2)  ||
				  pow(0.0f+i-ox+nx,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) ||
				  pow(0.0f+i-ox-nx,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) || 
				  pow(0.0f+i-ox,2)+pow(0.0f+j-oy+ny,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) || 
				  pow(0.0f+i-ox,2)+pow(0.0f+j-oy-ny,2)+pow(0.0f+k-oz,2)<=pow(0.0f+Radius,2) ||
				  pow(0.0f+i-ox,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz+nz,2)<=pow(0.0f+Radius,2) || 
				  pow(0.0f+i-ox,2)+pow(0.0f+j-oy,2)+pow(0.0f+k-oz-nz,2)<=pow(0.0f+Radius,2) 
				  ){
				Mark(i,j,k)=true;
				(*Concentration)(i,j,k)=Concentration2;
				(*Eta)(vtype,i,j,k)=1.0f;
			  }
	  }
	}
  }
  return 0;
}

int Dynamics_cores::Calculate(){
  if (Method == "random") RandomCores();
  else if (Method =="regular") RegularCores1D();
  else if (Method =="regular2d") RegularCores2D();
  else if (Method =="regular3d") RegularCores3D();

  return 0;
}

int Dynamics_cores::RunFunc(string funcName){return 0;}

int Dynamics_cores::Fix(real progress){return 0;}

string Dynamics_cores::Get(string ss){ // return the statistic info.
  string var; ss>>var;
  return "nan";
}
