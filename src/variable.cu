
#include"pub.h"
#include"../include/datamain.th"
#include"variable.h"
using namespace DATA_NS;
using namespace GS_NS;
using namespace std;

Variable::Variable(){
  Vars = new Map< string >;
  Datas = new Map< Data<Real> >;
};

Variable::~Variable(){};


bool _is_number(string ss){
  int pos;
  static const int s_N=9;
  static const string special_case[s_N]={"E+","E-","e+","e-","E","e","+","-","."};
  for (int i=0; i<s_N; i++){
	while ( (pos=ss.find(special_case[i]))>=0 )
	  ss.erase( pos, special_case[i].length() );
  }
  for (int i=0;i<ss.length(); i++)
	if (ss[i]<'0'||ss[i]>'9') return false;
  return true;
}
  
bool _not_operator_for_sure(string &expr, int &pos){
  if (pos>0 && (expr[pos]=='+'||expr[pos]=='-')&&(expr[pos-1]=='e'||expr[pos-1]=='E'))
	return true;
  return false;
}

int _postion_of_operator(string expr,string opera,int pos){
  int npos;
  npos=expr.find(opera,pos);
  while ( npos>=0 && _not_operator_for_sure(expr,npos) )
	npos=expr.find(opera,npos+1);
  return npos;
}

bool _is_var_char(char ch){
  if (ch>='a'&&ch<='z') return true;
  if (ch>='A'&&ch<='Z') return true;
  if (ch>='0'&&ch<='9') return true;
  if (ch=='_') return true;
  return false;
};

int Variable::ReplaceExpr(string &ss){//ignore the first startP words
  int err=0;
  int p_left=-1,p_right=-1,pl;
  while( (p_left=ss.find("{"))>=0){
	p_right=ss.find("}");
	if (p_right<0) return 0; //no substitution
	do {
	  pl = ss.find("{",p_left+1);
	  if (pl>p_right||pl<0){
		break;
	  }
	  p_right=ss.find("}",p_right+1);
	  if ( p_right<0 ){
		GV<0>::LogAndError<<"Error: uncomplete expression\n";
		return Code_ERR;
	  }
	}while (1);
	////////////////////////////////////
	string temp_str,result_str;
	temp_str=ss.substr(p_left+1,p_right-p_left-1);
	ExprTree tree;
	err=tree.Init(temp_str,Vars); if(err<0)return err;
	result_str = tree.Expr;
	ss.replace(p_left,p_right - p_left+1, result_str);
  }
  return 0;
}


int Variable::Evaluate(string &ss){//calculate an expression
  int pos;
  while ((pos=ss.find('{'))>=0) ss.replace(pos,1,"(");
  while ((pos=ss.find('}'))>=0) ss.replace(pos,1,")");
  ExprTree tree;
  tree.Init(ss,Vars);
  ss = tree.Expr;
  return 0;
}

int Variable::Set(string ss){
  string var,val;
  //////////////////////////////
  ss>>var>>val;
  (*Vars)[var]= val;
  //////////////////////////////
  return 0;
}

ExprTree::ExprTree(){
  Left=NULL;
  Right=NULL;
};

ExprTree::~ExprTree(){
  if (Left!=NULL ){ delete Left;  }
  if (Right!=NULL){ delete Right; }
}

int ExprTree::Init(string expr,Map<string> *vars){
  Left=NULL; Right=NULL; Val=0; Expr="";
  if (expr=="") return 0;
  Vars=vars;
  int count=0,len=expr.length();
  ////////////////////delete extra chars
  {int p; while ((p=expr.find(" "))>=0) expr.erase(p,1);}
  while (expr[0]=='('&&expr[len-1]==')') {expr=expr.substr(1,len-2); len=expr.length();}//?????
  ////////////////////seperate the expresion
  int expr_position=-1,lev=9999,operator_position=-1;
  for (int p=0;p<len;p++){
	if (expr[p]=='(') count++;
	if (expr[p]==')') count--;
	if (count!=0) continue;
	// some specific form can not be included e- e+
	if ( _not_operator_for_sure(expr,p) ) continue;
	  ////////////////////////////////////////
	for ( int i=0; i<Operator_N; i++)
	  if ( (expr.substr(p,Operators[i].length()) == Operators[i]) && (lev>=Operator_Levels[i])){
		expr_position=p;
		operator_position=i;
		lev=Operator_Levels[i];
	  }
	///////////////////////////////////////
  }
  //////////////////serperate and sum up
  if (expr_position<0) {
	string temp_s; expr>>=temp_s;
	if ( Vars->exist(temp_s) ){
	  (*Vars)[temp_s]>>=Val;
	  Expr<<Val;
	}else{
	  if (_is_number(temp_s)){
		temp_s>>=Val;
		Expr<<Val;
	  }else{
		GV<0>::LogAndError<<"Error: \""<<temp_s<<"\" unknown \n";
		Val=_NAN_Var;
		Expr="nan";
		return Code_ERR;
	  }
	}
  }
  else{
	string l_expr, r_expr;
	Opera= Operators[operator_position];
	l_expr=expr.substr(0,expr_position);
	r_expr=expr.substr(expr_position + Opera.length() ,len-expr_position);

	Left = new ExprTree;
	Right= new ExprTree;
	Right->Init(r_expr,Vars);
	if (Opera != "=") Left->Init(l_expr,Vars);

	if (Left->Expr=="nan" || Right->Expr=="nan"){
	  Expr="nan";
	  Val=_NAN_Var;
	  return 0;
	}
	if      (Opera=="+") { Val= Left->Val + Right->Val; Expr=ToString(Val); }
	else if (Opera=="-") { Val= Left->Val - Right->Val; io(Val,Expr);}
	else if (Opera=="*") { Val= Left->Val * Right->Val; io(Val,Expr);}
	else if (Opera=="/") { if (Right->Val==0) {Expr="nan"; Val=_NAN_Var;} else{ Val= Left->Val/Right->Val;io(Val,Expr);} }
	else if (Opera=="^") { Val= (Real(Left->Val) ^ Right->Val).Re; io(Val,Expr); }
	else if (Opera=="<="){ if (Left->Val<=Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera==">="){ if (Left->Val>=Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="=="){ if (Left->Val==Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="!="){ if (Left->Val!=Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="<") { if (Left->Val <Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera==">") { if (Left->Val >Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="=") { (*Vars)[l_expr]=Right->Expr; Expr=Right->Expr;}
	else if (Opera=="+=") { Val=Left->Val+Right->Val; io(Val,Expr); (*Vars)[l_expr]=Expr;}
	else if (Opera=="-=") { Val=Left->Val-Right->Val; io(Val,Expr); (*Vars)[l_expr]=Expr;}
	else if (Opera=="*=") { Val=Left->Val*Right->Val; io(Val,Expr); (*Vars)[l_expr]=Expr;}
	else if (Opera=="/=") { if (Right->Val==0) {Expr="nan"; Val=_NAN_Var;(*Vars)[l_expr]=Expr;} else{ Val= Left->Val/Right->Val;io(Val,Expr);(*Vars)[l_expr]=Expr;} }
  }
  return 0;
}

/*
int Variable::SubVar(string &ss){//ignore the first startP words
  return SubVar(ss,0,0);
}

int Variable::SubVar(string &ss,int startp){//ignore the first startP words
  return SubVar(ss,startp,0);
}

int Variable::SubVar(string &ss,int startp,int num){//ignore the first startP words
  int err=0;
  //////////////////standarlize;
  int pos; ss=ss+" "; while ((pos=ss.find("  "))>=0) ss.erase(pos,1);
  ///////////////////////////////////
  map<string,string>::iterator p;
  ////////
  p=Vars->begin();
  while (p!=Vars->end()){
	string v_name="{"+p->first+"}", v_value=(*Vars)[p];
	int pos = ss.find(v_name);
	while (pos>=0){
	  ss.replace(pos,v_name.length(),v_value);
	  pos = ss.find(v_name,pos + v_value.length());
	}
	p++;
  }
  /////////////////////////////////

  //if operator exists then do a math evaluation.
  string st;
  for (int i=0;i<Operator_N;i++){
	string opera = Operators[i];
	string ssub;
	int po=-1,ph,pe;
	po=_postion_of_operator(ss,opera,po+1);
	while (po>=0){
	  ph=po-1; while (ph>=0&&ss[ph]!=' ') ph--;
	  pe=po+1; while (pe<=ss.length()&&ss[pe]!=' ') pe++;
	  ssub=ss.substr(ph+1,pe-ph-1);
	  ///////////////////////
	  CalTree ct;
	  err =ct.Init(ssub); if (err<0) return err;
	  st = ct.Expr;
	  ////////////////////////
	  ss.replace(ph+1,pe-ph-1,st);
	  po=_postion_of_operator(ss,opera,ph+2);
	}
  }
  return 0;
}
*/

/*

CalTree::CalTree(){};

CalTree::~CalTree(){
  if (Left!=NULL ){ delete Left;  }
  if (Right!=NULL){ delete Right; }
}

int CalTree::Init(string expr){
  Left=NULL; Right=NULL; Val=0;
  if (expr=="") return 0;
  int count=0,len=expr.length();
  ////////////////////delete extra chars
  {int p; while ((p=expr.find(" ")) >=0) expr.erase(p,1);}
  while (expr[0]=='('&&expr[len-1]==')') {expr=expr.substr(1,len-2); len=expr.length();}//
  ////////////////////seperate the expresion
  int expr_position=-1,lev=9999,operator_position=-1;
  for (int p=0;p<len;p++){
	if (expr[p]=='(') count++;
	if (expr[p]==')') count--;
	if (count!=0) continue;
	// some specific form can not be included e- e+
	if ( _not_operator_for_sure(expr,p) ) continue;
	  ////////////////////////////////////////
	for ( int i=0; i<Operator_N; i++ )
	  if ( (expr.substr(p,Operators[i].length() ) == Operators[i]) && (lev>=Operator_Levels[i])){
		expr_position=p;
		operator_position=i;
		lev=Operator_Levels[i];
	  }
	///////////////////////////////////////
  }
  //////////////////serperate and sum up
  string temps;
  if (expr_position<0) {//final condition
	expr>>=Val;
	Expr<<Val;
  }else{
	Opera= Operators[operator_position];
	Left = new CalTree;
	Left->Init(expr.substr(0,expr_position));
	Right= new CalTree;
	Right->Init(expr.substr( expr_position + Opera.length() ,len-expr_position));
	if (Left->Expr=="nan" || Right->Expr=="nan"){
	  Expr="nan";
	  Val=-9.9999999e+23;
	  return 0;
	}
	if      (Opera=="+") { Val= Left->Val + Right->Val; Expr=ToString(Val); }
	else if (Opera=="-") { Val= Left->Val - Right->Val; io(Val,Expr);}
	else if (Opera=="*") { Val= Left->Val * Right->Val; io(Val,Expr);}
	else if (Opera=="/") { if (Right->Val==0) {Expr="nan"; Val=-9.9999e+23;}else{ Val= Left->Val/Right->Val;io(Val,Expr);} }
	else if (Opera=="^") { Val= (Real(Left->Val) ^ Right->Val).Re; io(Val,Expr); }
	else if (Opera=="<="){ if (Left->Val<=Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera==">="){ if (Left->Val>=Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="=="){ if (Left->Val==Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="!="){ if (Left->Val!=Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="<") { if (Left->Val <Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera==">") { if (Left->Val >Right->Val) Val=1; else Val=0; io(Val,Expr);}
  }
  return 0;
}
*/

/*
int Variable::Calculate(string expr, string &val){
  CalTree ct;
  ct.Init(expr);
  val= ct.Expr;
  return 0;
};
*/
