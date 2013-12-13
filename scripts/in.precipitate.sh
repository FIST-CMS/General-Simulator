#!/bin/bash
stepsprecipitate=2000
stepsmart=3000
nx=64
ny=64
nz=64
dx=0.2
dy=0.2
dz=0.2
dumpN=5

echo "
##########################################################
sys cores 
##########################################################
set gridsize $nx $ny $nz $dx $dy $dz 
set variantn 4
set coresn 2
set radius 10
set concentration 0.2 0.44
set method random
##########################################################
dump ./ 1 eta concentration 
run
shell mv concentration.1.data data.con.for.precipitate
shell mv eta.1.data data.eta.for.precipitate
"> in.cores

echo "
sys precipitate #assign the type of the system
:steps=${stepsprecipitate}
###########################################################
set gridsize $nx $ny $nz $dx $dy $dz  #the length unit is in nm
set deltatime 0.1
set coefficient 54.00 -17.0 7.0 2.5 0.2 0.2 0.2
set arfi 300.0
set beta 300.0
set meta 0.4
set lpp  0.4
set xi   400
set concentration 0.1 0.44 # the init con of the mother phase is 0.2
###########################################################
read eta data.eta.for.precipitate
read concentration data.con.for.precipitate
###########################################################
readhere varianttensor
3 4 3 3
-0.01126 -0.00709 -0.00709 -0.00709 -0.01126 -0.00709 -0.00709 -0.00709 -0.01126 
-0.01126 0.00709 0.00709 0.00709 -0.01126 -0.00709 0.00709 -0.00709 -0.01126 
-0.01126 0.00709 -0.00709 0.00709 -0.01126 0.00709 -0.00709 0.00709 -0.01126 
-0.01126 -0.00709 0.00709 -0.00709 -0.01126 0.00709 0.00709 0.00709 -0.01126 
######################################
info {steps/5} eta_average # (/ 4 2)
shell rm dump.precipitate
dump dump.precipitate $dumpN eta concentration
#####################################
run {steps}
" > in.precipitate

echo "
##########################################################
sys stress #assign the type of the system
##########################################################
set gridsize $nx $ny $nz $dx $dy $dz  #the length unit is in nm
###########################################################
read eta dump.precipitate/eta.${stepsprecipitate}.data  #read the shape (order parameter)
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
shell mv stress.1.data data.stress.for.mart
shell mv defect.1.data data.defect.for.mart
" > in.stress


echo "
###########################################################
#device 0 #assign gpu device ID for cal. default 0. also ./gups in.script deviceID
sys mart  #assign the type of the system
###########################################################
:steps=${stepsmart}
###########################################################
set gridsize $nx $ny $nz $dx $dy $dz  #the length unit is in nm
set deltatime 0.01
set transitiontemperature 450
set weightdislocation .1
##########################################################
read dislocationstress data.stress.for.mart
read defect data.defect.for.mart
###########################################################
readhere varianttensor
3 4 3 3
0.00 0.0063 0.0063  0.0063 0.0 0.0063    0.0063 0.0063 0.0 
0.00 0.0063 -0.0063  0.0063 0.0 -0.0063 -0.0063 -0.0063 0.0
0.00 -0.0063 0.0063  -0.0063 0.0 -0.0063  0.0063 -0.0063 0.0
0.00 -0.0063 -0.0063  -0.0063 0.0 0.0063  -0.0063 0.0063 0.0
######################################
######################################
info {steps/5} temperature eta gradient chemical elastic dislocation
shell rm dump.martensite
dump dump.martensite $dumpN eta
#####################################
set fix temperature 460 300 #assign the temperature route  
run {steps}
#####################################
set fix temperature 300 300 #assign the temperature route  
run {steps}
"> in.mart
