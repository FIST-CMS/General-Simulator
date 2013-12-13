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
	ofstream Logofs;
	bool On;
	int Init(string name){
	  Name=name;
	  On=true;
	  Logofs.open((name+".log").c_str());
	  return 0;
	}
	~LogAndError(){
	  if (Logofs) Logofs.close();
	}
	template<class type> LogAndError &operator<<(type val){ //for log
	  Logofs<<""<<val;
	  cout<<""<<val;
	  return *this;
	}
  };
}
#endif
