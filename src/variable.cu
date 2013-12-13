
#include"pub.h"
#include"../include/datamain.th"
#include"variable.h"
using namespace DATA_NS;
using namespace GS_NS;
using namespace std;

Variable::Variable(){
  Vars = new Map< string >;
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

bool _is_var_char(char ch){
  if (ch>='a'&&ch<='z') return true;
  if (ch>='A'&&ch<='Z') return true;
  if (ch>='0'&&ch<='9') return true;
  if (ch=='_') return true;
  return false;
};

<<<<<<< HEAD
int Variable::shell(string ss){ 
  int err=0; string temp; 
  err=shell(ss,temp); 
  GV<0>::LogAndError<<temp<<"\n";
  return err;
}
int Variable::shell(string ss,string &result){
  string st; st =ss+" 2>&1 >.gs.shell.tmp"; 
  if (system(st.c_str()));
  ifstream in(".gs.shell.tmp",ios::in);
  if (in.fail()){
    GV<0>::LogAndError<<"Error: fail to read shell results\n";
    return 0;
  }
  istreambuf_iterator<char> beg(in), end;
  result=string(beg,end);
  in.close();
  if (result.length()>0) result.erase(result.length()-1,1);
  return 0;
};

int Variable::ReplaceExpr(string &ss){//ignore the first startP words
  int err=0;
  int p_left=-1,p_right=-1,pl;
  while( (p_left=ss.find("`"))>=0){
    p_right=ss.find("`",p_left+1);
    if ( p_right<0 ){
	 GV<0>::LogAndError<<"Error: uncomplete expression\n";
	 return Code_ERR;
    }
    ////////////////////////////////////
    string temp_str,result_str;
    temp_str=ss.substr(p_left+1,p_right-p_left-1);
    err=shell(temp_str,result_str); if(err<0)return err;
    ss.replace(p_left,p_right - p_left+1, result_str);
  }
  p_left=-1;
  while( (p_left=ss.find("{"))>=0){
    p_right=-1;
	do {
=======
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
>>>>>>> origin/master
	  p_right=ss.find("}",p_right+1);
	  if ( p_right<0 ){
		GV<0>::LogAndError<<"Error: uncomplete expression\n";
		return Code_ERR;
	  }
<<<<<<< HEAD
	  pl = ss.find("{",p_left+1);
	  if (pl>p_right||pl<0){
		break;
	  }
=======
>>>>>>> origin/master
	}while (1);
	////////////////////////////////////
	string temp_str,result_str;
	temp_str=ss.substr(p_left+1,p_right-p_left-1);
	ExprTree tree;
	err=tree.Init(temp_str,Vars,Vars_gs); if(err<0)return err;
	result_str = tree.Expr;
	ss.replace(p_left,p_right - p_left+1, result_str);
  }
  return 0;
}

<<<<<<< HEAD
=======

>>>>>>> origin/master
int Variable::Evaluate(string &ss){//calculate an expression
  int pos;
  while ((pos=ss.find('{'))>=0) ss.replace(pos,1,"(");
  while ((pos=ss.find('}'))>=0) ss.replace(pos,1,")");
  ExprTree tree;
  tree.Init(ss,Vars,Vars_gs);
  ss = tree.Expr;
  return 0;
}

<<<<<<< HEAD
=======
int Variable::Set(string ss){
  string var,val;
  //////////////////////////////
  ss>>var>>val;
  (*Vars)[var]= val;
  //////////////////////////////
  return 0;
}

>>>>>>> origin/master
ExprTree::ExprTree(){
  Left=NULL;
  Right=NULL;
};

ExprTree::~ExprTree(){
  if (Left!=NULL ){ delete Left;  }
  if (Right!=NULL){ delete Right; }
}

int ExprTree::Init(string expr,Map<string> *vars,Map<string> *vars_gs){
  Left=NULL; Right=NULL; Val=0; Expr="";
  if (expr=="") return 0;
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
	/////////////
	if ( vars->exist(temp_s) ){
<<<<<<< HEAD
	  (*vars)[temp_s]>>=Expr;
	  Expr>>=Val;
=======
	  (*vars)[temp_s]>>=Val;
	  Expr<<Val;
>>>>>>> origin/master
	  return 0;
	}
	if (temp_s[0]=='$') temp_s.erase(0,1);
	if ( vars_gs->exist(temp_s) ){
<<<<<<< HEAD
	  (*vars_gs)[temp_s]>>=Expr;
	  Expr>>=Val;
=======
	  (*vars_gs)[temp_s]>>=Val;
	  Expr<<Val;
>>>>>>> origin/master
	  return 0;
	}
	////////////////
	if (_is_number(temp_s)){
<<<<<<< HEAD
	  Expr=temp_s;
	  temp_s>>=Val;
=======
	  temp_s>>=Val;
	  Expr<<Val;
>>>>>>> origin/master
	  return 0;
	}else{
	  GV<0>::LogAndError<<"Error: \""<<temp_s<<"\" unknown \n";
	  Val=_NAN_Var;
	  Expr="nan";
	  return Code_ERR;
	}
  }
  else{
	string l_expr, r_expr;
	Opera= Operators[operator_position];
	l_expr=expr.substr(0,expr_position);
	r_expr=expr.substr(expr_position + Opera.length() ,len-expr_position);

	Left = new ExprTree;
	Right= new ExprTree;
	Right->Init(r_expr,vars,vars_gs);
	if (Opera != "=") Left->Init(l_expr,vars,vars_gs);

	if (Left->Expr=="nan" || Right->Expr=="nan"){
	  Expr="nan";
	  Val=_NAN_Var;
	  return 0;
	}
	if      (Opera=="+") { Val= Left->Val + Right->Val; Expr=ToString(Val); }
	else if (Opera=="-") { Val= Left->Val - Right->Val; io(Val,Expr);}
	else if (Opera=="*") { Val= Left->Val * Right->Val; io(Val,Expr);}
	else if (Opera=="/") { if (Right->Val==0) {Expr="nan"; Val=_NAN_Var;} else{ Val= Left->Val/Right->Val;io(Val,Expr);} }
<<<<<<< HEAD
	else if (Opera=="^") { Val= (Real(Left->Val) ^ ((int)Right->Val)).Re; io(Val,Expr); }
=======
	else if (Opera=="^") { Val= (Real(Left->Val) ^ Right->Val).Re; io(Val,Expr); }
>>>>>>> origin/master
	else if (Opera=="<="){ if (Left->Val<=Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera==">="){ if (Left->Val>=Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="=="){ if (Left->Val==Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="!="){ if (Left->Val!=Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="<") { if (Left->Val <Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera==">") { if (Left->Val >Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="=") {
	  if (l_expr[0]!='$') (*vars)[l_expr]=Right->Expr; else (*vars_gs)[l_expr.substr(1)]=Right->Expr;
	  Expr=Right->Expr; Val=Right->Val;
	}
	else if (Opera=="+="){ExprTree treenew;treenew.Init(l_expr+"="+l_expr+"+"+r_expr,vars,vars_gs);Val=treenew.Val;Expr=treenew.Expr;}
	else if (Opera=="-="){ExprTree treenew;treenew.Init(l_expr+"="+l_expr+"-"+r_expr,vars,vars_gs);Val=treenew.Val;Expr=treenew.Expr;}
	else if (Opera=="*="){ExprTree treenew;treenew.Init(l_expr+"="+l_expr+"*"+r_expr,vars,vars_gs);Val=treenew.Val;Expr=treenew.Expr;}
	else if (Opera=="/="){ExprTree treenew;treenew.Init(l_expr+"="+l_expr+"/"+r_expr,vars,vars_gs);Val=treenew.Val;Expr=treenew.Expr;}
  }
  return 0;
}
