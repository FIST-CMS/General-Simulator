
#ifndef	INPUT_Eins_H
#define 	INPUT_Eins_H

#define LOG_PREFIX_TRUE 	1
#define LOG_PREFIX_FALSE	0 

using namespace std;
namespace GUPS_NS{
  class INPUT{
  public:
	GUPS	Gups;
	ifstream fin;
	int 	 LineNumber;
	Variable Vars;
  public:
	INPUT(string infile);
	~INPUT();

	int Phrasing();//process the infile and do the task assigned


	//Log Warning and Wrong case dealing

	int 	variable(string ss);
	string 	standardize(string ss);
	bool	fgets_str(ifstream &ifs, string &ss);
	//commands
	int device(string ss);
	//int sys(string 		ss);
	int variant(string	ss);


  };



}

#endif
