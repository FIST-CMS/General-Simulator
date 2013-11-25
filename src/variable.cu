
#include"pub.h"
#include"../include/datamain.th"
#include"variable.h"
using namespace DATA_NS;
using namespace GS_NS;
using namespace std;

Variable::Variable(){};

Variable::~Variable(){};

int Variable::Calculate(string expr, string &val){
  CalTree ct(expr);
  io(ct.Val,val);
  return 0;
};

int Variable::SubVar(string &ss,int startp){//ignore the first startP words
  string st;
  map<string,string>::iterator p;
  //first replace exist variables
  p=Variables.begin();
  while (p!=Variables.end()){
	//if ((p->first== "+")||(p->first=="-")||(p->first=="*")||(p->first=="/")||(p->first=="^")) continue;
	int l=p->first.length();
	int po=-1;
	string pf=p->first,ps=p->second;
	for (int i=1;i<=startp;i++)//find a proper start index in order to ignore startp words
	  po=ss.find(" ",po+1);
	po = ss.find(pf,po+1);
	while (po>=0){
	  if ( (po>0) && ( (ss[po-1]>='a'&&ss[po-1]<='z') || (ss[po-1]>='A'&&ss[po-1]<='Z') ||( ss[po+l]>='0' && ss[po+l]<='9'))) { po = ss.find(pf,po+1); continue;}
	  if ( (po+l< ss.length() )&& ( (ss[po+l]>='a'&&ss[po+l]<='z')||(ss[po+l]>='a'&&ss[po+l]<='z') ||( ss[po+l]>='0' && ss[po+l]<='9')) ) { po = ss.find(pf,po+1); continue; }
	  ss.replace(po,l,ps);
	  po = ss.find(pf,po+ps.length());
	}
	p++;
  }

  //if + - * / ^ exists then do a math evaluation.
  char ops[5]={'+','-','*','/','^'};
  for (int i=0;i<5;i++){
	char opera = ops[i];
	string ssub;
	int po=-1,ph,pe;
	for (int i=1;i<=startp;i++)//find a proper start index in order to ignore startp words
	  po=ss.find(" ",po+1);
	po = ss.find(opera,po+1);
	while (po>=0){
	  ph=po-1; while (ph>=0&&ss[ph]!=' ') ph--;
	  pe=po+1; while (pe<=ss.length()&&ss[pe]!=' ') pe++;
	  ssub=ss.substr(ph+1,pe-ph-1);
	  Calculate(ssub,st);
	  ss.replace(ph+1,pe-ph-1,st);
	  po = ss.find(opera,ph+2);
	}
  }
  return 0;
}



int Variable::Set(string ss){
  string var,expr;
  ss>>var>>expr;
  SubVar(expr,0); 
  Variables[var]= expr;
  return 0;
}
