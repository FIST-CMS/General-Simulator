#!/usr/local/bin/MathematicaScript -script
(* ::Package:: *)

Get["/public/home/Eins/include/datamain.m"]
Get["precipitate.Init.m"]
Print[Directory[]]
l=8; nx=l; ny=l; nz=l; radius=2; coresn=1; variantn=4;
cores=RandomCores[nx,ny,nz,radius,coresn,variantn]
cores=RegularCores1D[nx,ny,nz,radius,coresn,variantn]
Export["cores.eps",ShowCores[cores],"EPS"]
Concentration["con.init.data",cores,0.2,0.44]
Eta["eta.init.data",cores]

Export["eta.init.eps",ShowEta3D["./eta.init.data"],"EPS"]
Export["con.init.eps",
  DataShow3D[DataImport["./con.init.data"][[1]]],"EPS"]
(*Export["eta100.eps",ShowEta3D["dump/eta100.data"],"EPS"]
 Export["concentration100.eps",
 DataShow3D[DataImport["dump/concentration100.data"][[1]]],"EPS"]*)
