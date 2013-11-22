
#ifndef VARIABLE_EINS_H
#define VARIABLE_EINS_H

#include<map>
using namespace std;
using namespace DATA_NS;

namespace GUPS_NS{


  class Variable{
  public:
	map<string,string> Variables; // <vname, vvalue>

	Variable();
	~Variable();

	int SubVar(string &ss,int startp);
	int Set(string);
	int Calculate(string ss,string &value);

  };
  class CalTree{
  public:
	string Expr;
	real Val;
	char Opera;
	CalTree *Left, *Right;

	CalTree(string expr){
	  Left=NULL; Right=NULL; Val=0;
	  Expr=expr; if (expr=="") return;
	  string st=Expr; int count=0,l=st.length();
	  {int p; while ((p=st.find(" ")) >=0) st=st.erase(p,1);}
	  while (st[0]=='('&&st[l]==')') {st=st.substr(1,l-1); l=st.length();}
	  Expr = st;
	  int po=-1,lev=3;
	  for (int p=0;p<l;p++){
		if (st[p]=='(') count++;
		if (st[p]==')') count--;
		if (count!=0) continue;
		if (((st[p]=='+')||(st[p]=='-'))&&lev>=0)
		  { po= p; lev=0;}
		if (((st[p]=='*')||(st[p]=='/'))&&lev>=1)
		  { po=p; lev=1;}
		if ((st[p]=='^')&&lev>=2)
		  { po=p; lev=2;}
	  }
	  if (po<0) io(st,Val);
	  else{
		Opera= st[po];
		Left= new CalTree(st.substr(0,po));
		Right= new CalTree(st.substr(po+1,l-po));
		if (Opera=='+') Val= Left->Val + Right->Val;
		else if (Opera=='-')Val= Left->Val - Right->Val;
		else if (Opera=='*')Val= Left->Val * Right->Val;
		else if (Opera=='/')Val= Left->Val / Right->Val;
		else if (Opera=='^')Val= (Real(Left->Val) ^ Right->Val).Re;
	  }
	
	}
	~CalTree(){
	  if (Left!=NULL) delete Left;
	  if (Right!=NULL) delete Right;
	}
  };


}

#endif
