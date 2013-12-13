#include<cufft.h>
#include<curand.h>
#include"../include/datamain.th"
#include"variable.h"
#include"gtensorb.h"
#include"random.h"
//////////////////////////////////////////////////////
//user defined head file needed by your dynamics files

//////////////////////////////////////////////////////
#include"dynamics.h"
//GS_SYS_DEFINE_START
#include"dynamics_cores.h"
<<<<<<< HEAD
#include"dynamics_mart.h"
#include"dynamics_multi.h"
#include"dynamics_pow.h"
#include"dynamics_precipitate.h"
=======
#include"dynamics_diffuse.h"
#include"dynamics_mart.h"
#include"dynamics_multi.h"
#include"dynamics_pow.h"
>>>>>>> origin/master
#include"dynamics_stress.h"
#include"dynamics_xxx.h"
//GS_SYS_DEFINE_END
//////////////////////////////////////////////////////
#include"gs.h"
