
#include"pub.h"
#include"../include/datamain.th"
#include"variable.h"
using namespace DATA_NS;
using namespace GS_NS;
using namespace std;

Variable::Variable(){};

Variable::~Variable(){};

int Variable::Calculate(string expr, string &val){
  CalTree ct;
  ct.Init(expr);
  val= ct.Expr;
  return 0;
};

bool _not_operator(string &expr, int &pos){
  if (pos>0 && (expr[pos]=='+'||expr[pos]=='-')&&(expr[pos-1]=='e'||expr[pos-1]=='E'))
	return true;
  return false;
}

int _postion_of_operator(string expr,string opera,int pos){
  int npos;
  npos=expr.find(opera,pos);
  while ( npos>=0 && _not_operator(expr,npos) )
	npos=expr.find(opera,npos+1);
  return npos;
}

int Variable::SubVar(string &ss,int startp){//ignore the first startP words
  string st;
  map<string,string>::iterator p;
  //first replace exist variables
  p=Variables.begin();
  while (p!=Variables.end()){
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
  for (int i=0;i<Operator_N;i++){
	string opera = Operators[i];
	string ssub;
	int po=-1,ph,pe;
	for (int i=1;i<=startp;i++)//find start index to ignore startp words; changes when under operates
	  po=ss.find(" ",po+1);
	po=_postion_of_operator(ss,opera,po+1);
	while (po>=0){
	  ph=po-1; while (ph>=0&&ss[ph]!=' ') ph--;
	  pe=po+1; while (pe<=ss.length()&&ss[pe]!=' ') pe++;
	  ssub=ss.substr(ph+1,pe-ph-1);
	  Calculate(ssub,st);
	  ss.replace(ph+1,pe-ph-1,st);
	  po=_postion_of_operator(ss,opera,ph+2);
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

string Variable::operator()(string id){// return value or ""
  map<string,string>::iterator viter;
  viter=Variables.find(id);
  if ( viter == Variables.end() )
	return "";
  else return viter->second;
}
string &Variable::operator[](string id){//create new if necc.
  return Variables[id];
}


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
  while (expr[0]=='('&&expr[len-1]==')') {expr=expr.substr(1,len-2); len=expr.length();}//?????
  ////////////////////seperate the expresion
  int expr_position=-1,lev=9999,operator_position=-1;
  for (int p=0;p<len;p++){
	if (expr[p]=='(') count++;
	if (expr[p]==')') count--;
	if (count!=0) continue;
	// some specific form can not be included e- e+
	if ( _not_operator(expr,p) ) continue;
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
	Expr=expr;
	expr>>=Val;
	/*
	int len=expr.length();
	for (int i=0;i<len; i++)
	  if (expr[i]>'9' || expr[i]<'0'){
		GV<0>::LogAndError<<"Error: expression "<<expr<<" unknown\n";
		Expr="nan";
		Val=-9.9999999e+23;
		return 0;
	  }
	*/
  }
  else{
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
	else if (Opera=="<") { if (Left->Val <Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera==">") { if (Left->Val >Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="<="){ if (Left->Val<=Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera==">="){ if (Left->Val>=Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="=="){ if (Left->Val==Right->Val) Val=1; else Val=0; io(Val,Expr);}
	else if (Opera=="!="){ if (Left->Val!=Right->Val) Val=1; else Val=0; io(Val,Expr);}
  }
  return 0;
}

