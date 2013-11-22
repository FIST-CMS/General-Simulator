
//#define DEBUG 1
#include"log_error.h"
#include"../include/datamain.th"

using namespace GUPS_NS;

template<int id> class GV{
public:
  static LogAndError LogAndError;
};

template<int id> LogAndError GV<id>::LogAndError;
