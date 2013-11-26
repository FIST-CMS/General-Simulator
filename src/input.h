
#ifndef	INPUT_Eins_H
#define 	INPUT_Eins_H

#define LOG_PREFIX_TRUE 	1
#define LOG_PREFIX_FALSE	0 

using namespace std;
namespace GS_NS{
  class INPUT{
  public:
	GS	Gs;
	//ifstream fin;
	int 	 LineNumber;
	Variable Vars;
  public:
	INPUT();
	~INPUT();
	//////////////////////////////////////////////
	bool	getline(string &ss, string &script);
	int		standardize(string &script);
	int 	Phrasing(string script);//process peice of scripts
	//////////////////////////////////////////////
	//////////////////////////////////////////////
	int 	device(string ss);
	int  	readhere(string ss,string &script);//read data from script
  };
}
#endif
