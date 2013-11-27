
#include"log_error.h"
#include"../include/datamain.th"

using namespace GS_NS;

template<int id> class GV{
public:
  static LogAndError LogAndError;
};

template<int id> LogAndError GV<id>::LogAndError;

const int Code_NORMAL			=	 0;
const int Code_ERR				=	-1;
const int Code_BREAK			=	-2;
const int Code_QUIT				=	-3;
const int Code_COMMAND_UNKNOW 	= 	-4;
const int Code_INPUT_UNCOMPLETE =	-5;

const static int  	Operator_N 	= 11; 
const static int  	Operator_Levels	[Operator_N] = {19 ,19 ,20 ,20 ,21 ,18 ,18 , 18 , 18 ,18 , 18 };
const static string Operators		[Operator_N] = {"+","-","*","/","^","<",">","<=",">=","=","!="};

const static int Commands_N=3;
const static string Commands[Commands_N]={"if","loop","while"};
