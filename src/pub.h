
#include"log_error.h"
#include"../include/datamain.th"

using namespace GS_NS;
using namespace DATA_NS;

template<int id> class GV{
public:
  static LogAndError LogAndError;
  static Map<  Data<Real> > 	Reals;
  static Map<  string > 		Strings;
};

template<int id> LogAndError GV<id>::LogAndError;
//template<int id> Map< Data<Real> > GV<id>::Reals;
//template<int id> Map< string > GV<id>::Strings;

const int Code_NORMAL			=	 0;
const int Code_ERR				=	-1;
const int Code_BREAK			=	-2;
const int Code_QUIT				=	-3;
const int Code_COMMAND_UNKNOW 	= 	-4;
const int Code_INPUT_UNCOMPLETE =	-5;

const static int  	Operator_N 	= 16; 
const static int  	Operator_Levels	[Operator_N] = {15 ,15 ,18 ,18 ,21 ,9  ,9  ,8   ,8   ,8   ,8   ,6  ,6   ,6   ,6   ,6};
const static string Operators		[Operator_N] = {"+","-","*","/","^","<",">","<=",">=","==","!=","=","+=","-=","*=","/="};

const static int Commands_N=3;
const static string Commands[Commands_N]={"if","loop","while"};
