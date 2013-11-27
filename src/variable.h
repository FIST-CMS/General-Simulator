
#ifndef VARIABLE_EINS_H
#define VARIABLE_EINS_H

#include<map>
using namespace std;
using namespace DATA_NS;

namespace GS_NS{


  class Variable{
  public:
	map<string,string> Variables; // <vname, vvalue>
	//////////////////////////////////////////////////////
	Variable();
	~Variable();
	//////////////////////////////////////////////////////
	string operator()(string id);// return value or ""
	string &operator[](string id);//create new if necc.
	/////////////////////////////////////////////////////
	int SubVar(string &ss,int startp);
	int Set(string);
	int Calculate(string ss,string &value);
  };
  class CalTree{
  public:
	string 	Expr;
	real 	Val;
	string 	Opera;
	CalTree *Left, *Right;
	CalTree();
	~CalTree();
	int Init(string expr);
  };
}

#endif
