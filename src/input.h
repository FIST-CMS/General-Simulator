
#ifndef	INPUT_Eins_H
#define INPUT_Eins_H

#define LOG_PREFIX_TRUE 	1
#define LOG_PREFIX_FALSE	0 


using namespace std;
namespace GS_NS{
  class INPUT{
  public:
	GS	Gs;
	int 	 LineNumber;
	Variable Vars;
  public:
	INPUT();
	~INPUT();
	//////////////////////////////////////////////
	int 	Phrasing(string script);//process peice of scripts
	//////////////////////////////////////////////
	bool	getline(string &ss, string&script);
	int		standardize(string&script);
	//////////////////////////////////////////////
	int 	device(string ss);
	int 	print(string ss);
	int  	readhere(string ss,string&script);//read data from script
	//////////////////////////////////////////////
	int		get_expresion(string &expr,string &script);
	int		find_sub_script(string&script,string&sub_script);
	int 	find_else_script(string&script,string&sub_script1,string &sub_script2);
	//////////////////////////////////////////////
	int 	stat_loop(string ss,string&script);
	int 	stat_while(string ss,string&script);
	int 	stat_if(string ss,string&script);
	//////////////////////////////////////////////
  };
}
#endif
