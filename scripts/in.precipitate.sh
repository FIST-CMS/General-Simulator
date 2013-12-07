#!/bin/bash
stepsdiffuse=100
stepsmart=100
nx=160
ny=256
nz=256
dumpN=0
echo "
##########################################################
sys cores #assign the type of the system
##########################################################
set gridsize $nx $ny $nz 0.1 0.1 0.1  #the length unit is in nm
set variantn 4
set coresn 4
set radius 6
set concentration 0.2 0.44
set method regular
###########################################################
##########################################################
dump ./ 1 eta concentration #cores
run
shell cp concentration.final.data data.con.for.diffuse
shell cp eta.final.data data.eta.for.diffuse
shell rm eta.final.data concentration.final.data
"> in.cores

echo "
#device 0 #assign gpu device ID for cal. default 0. also ./gups in.script deviceID
##########################################################
sys diffuse #assign the type of the system
##########################################################
:steps=${stepsdiffuse}
###########################################################
set gridsize $nx $ny $nz 0.1 0.1 0.1  #the length unit is in nm
set deltatime 0.1
set coefficient 54.00 -17.0 7.0 2.5 0.2 0.2 0.2
set arfi 300.0
set beta 300.0
set meta 0.4
set lpp  0.4
set xi   400
set concentration 0.1 0.44 # the init con of the mother phase is 0.2
###########################################################
read eta data.eta.for.diffuse
read concentration data.con.for.diffuse
###########################################################
readhere varianttensor
3 4 3 3
-0.01126 -0.00709 -0.00709 -0.00709 -0.01126 -0.00709 -0.00709 -0.00709 -0.01126 
-0.01126 0.00709 0.00709 0.00709 -0.01126 -0.00709 0.00709 -0.00709 -0.01126 
-0.01126 0.00709 -0.00709 0.00709 -0.01126 0.00709 -0.00709 0.00709 -0.01126 
-0.01126 -0.00709 0.00709 -0.00709 -0.01126 0.00709 0.00709 0.00709 -0.01126 
######################################
######################################
info {steps} # (/ 4 2)
shell rm -rf dump_pre
dump dump_pre $dumpN eta concentration
#####################################
run {steps}
shell cp dump_pre/eta.final.data data.eta.for.stress
shell cp dump_pre/concentration.final.data data.con.final
" > in.diffuse
echo "
##########################################################
sys stress #assign the type of the system
##########################################################
set gridsize $nx $ny $nz 0.1 0.1 0.1  #the length unit is in nm
set xi 4000.0
###########################################################
read eta data.eta.for.stress  #read the shape (order parameter)
##########################################################
readhere varianttensor
3 4 3 3 
{
-1.835*0.01, -8.1868274*0.001, -5.7889605*0.001,-8.1868256*0.001, -8.897*0.001, -3.3422573*0.001,-5.7889605*0.001, -3.3422580*0.001, -6.54*0.001
-4.17*0.001,  0.0,  0.0, 0.0, -2.3*0.01, 6.6845156*0.001, 0.0,  6.6845166*0.001, -6.5*0.001
-4.17*0.001,  0.0,  0.0, 0.0, -4.17*0.001, 0.0,0.0,  0.0, -2.544*0.01
-1.835*0.01,  8.1868265*0.001,  5.788961*0.001,8.1868256*0.001, -8.897*0.001, -3.3422573*0.001,5.7889605*0.001, -3.3422580*0.001, -6.5*0.001
}
###########################################################
dump ./ 1 stress defect
run
shell cp stress.final.data data.stress.for.mart
shell cp defect.final.data data.defect.for.mart
shell rm stress.final.data defect.final.data
" > in.stress
echo "
###########################################################
#device 0 #assign gpu device ID for cal. default 0. also ./gups in.script deviceID
sys mart  #assign the type of the system
###########################################################
:steps=${stepsmart}
###########################################################
set gridsize $nx $ny $nz 0.1 0.1 0.1  #the length unit is in nm
set transitiontemperature 450
set deltatime 0.01
set fix temperature 460 300 #assign the temperature route  
set weightdislocation 1
##########################################################
#read dislocationstress data.stress.for.mart
#read defect data.defect.for.mart
###########################################################
readhere varianttensor
3 4 3 3
0.00 0.0063 0.0063  0.0063 0.0 0.0063    0.0063 0.0063 0.0 
0.00 0.0063 -0.0063  0.0063 0.0 -0.0063 -0.0063 -0.0063 0.0
0.00 -0.0063 0.0063  -0.0063 0.0 -0.0063  0.0063 -0.0063 0.0
0.00 -0.0063 -0.0063  -0.0063 0.0 0.0063  -0.0063 0.0063 0.0
######################################
######################################
info {steps} temperature # (/ 4 2)
shell rm -rf dump_mart
dump dump_mart $dumpN eta
#####################################
run {steps}
shell cp dump_mart/eta.final.data data.eta.final
"> in.mart

