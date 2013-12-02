
#ifndef VARIABLE_EINS_H
#define VARIABLE_EINS_H



#include<map>
using namespace std;
using namespace DATA_NS;

namespace GS_NS{

#define _NAN_Var -9.9999e23


  class Variable{
  public:
	Map<string>  	  *Vars;
	Map< Data<Real> > *Datas;
	//////////////////////////////////////////////////////
	Variable();
	~Variable();
	//////////////////////////////////////////////////////
	string operator()(string id);// return value or ""
	string &operator[](string id);//create new if necc.
	/////////////////////////////////////////////////////
	int Set(string);
	int SubVar(string &ss);
	int SubVar(string &ss,int start_words_num);
	int SubVar(string &ss,int start_words_num,int num);
	int Calculate(string ss,string &value);
	////////////////////////////////////////////////////
	int Evaluate(string &ss);
	int ReplaceExpr(string &ss);
  };
  class ExprTree{
  public:
	string 	Expr;
	real 	Val;
	string 	Opera;
	ExprTree *Left, *Right;
	Map<string> *Vars;
	ExprTree();
	~ExprTree();
	int Init(string expr,Map<string> *vars);
  };
}

#endif
  /*
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
  */
