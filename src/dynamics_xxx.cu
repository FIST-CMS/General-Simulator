
////////////////////////////////////////
#include"pub.h"
#include"dynamics.h"
////////////////////////////////////////
//#include"your_own_library.h"
///////////////////////////////////////
#include"dynamics_xxx.h"

using namespace GS_NS;
using namespace DATA_NS;

Dynamics_xxx::Dynamics_xxx(){}

int Dynamics_xxx::Initialize(){return 0;}

int Dynamics_xxx::Calculate(){return 0;}

int Dynamics_xxx::RunFunc(string func){ return Code_COMMAND_UNKNOW;}

int Dynamics_xxx::Fix(real progress){return 0;}

string Dynamics_xxx::Get(string var){return "nan";}

Dynamics_xxx::~Dynamics_xxx(){}
