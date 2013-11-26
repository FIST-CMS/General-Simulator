
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
