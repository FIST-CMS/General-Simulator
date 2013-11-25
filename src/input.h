
#ifndef	INPUT_Eins_H
#define 	INPUT_Eins_H

#define LOG_PREFIX_TRUE 	1
#define LOG_PREFIX_FALSE	0 

using namespace std;
namespace GS_NS{
  class INPUT{
  public:
	GS	Gs;
	ifstream fin;
	int 	 LineNumber;
	Variable Vars;
  public:
	INPUT(string infile);
	~INPUT();
	//////////////////////////////////////////////
	int 	Phrasing();//process the infile and do the task assigned
	//////////////////////////////////////////////
	string 	standardize(string ss);
	bool	fgets_str(ifstream &ifs, string &ss);
	//////////////////////////////////////////////
	int 	device(string ss);
	int  	readhere(string ss);
  };
}
#endif
