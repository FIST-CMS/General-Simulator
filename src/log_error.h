#ifndef GS_LOG_H
#define GS_LOG_H

#include<iostream>
#include<string>
#include<fstream>
using namespace std;

namespace GS_NS{

  class LogAndError{
  public:
	string Name;
	ofstream Logofs, Errorofs;
	int Init(string name){
	  Name=name;
	  Logofs.open((name+".log").c_str());
	  Errorofs.open((name+".err").c_str());
	  return 0;
	}
	~LogAndError(){
	  if (Logofs) Logofs.close();
	  if (Errorofs) Errorofs.close();
	}
	template<class type> LogAndError &operator<<(type val){ //for log
	  Logofs<<""<<val;
	  cout<<""<<val;
	  return *this;
	}
	template<class type> LogAndError &operator>>(type val){ //for error
	  Errorofs<<""<<val;
	  Logofs<<""<<val;
	  cout<<""<<val;
	  return *this;
	}
  };
}
#endif
