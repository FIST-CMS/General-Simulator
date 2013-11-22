(* ::Package:: *)

(* ::Subsubtitle:: *)
(*Plot Functions*)


(* ::Text:: *)
(*ColorBand*)


ColorBand[]:=MatrixPlot[{Table[a,{a,0.0,0.70,0.01}]},ColorFunction->(Hue[#]&),ColorFunctionScaling->False,Frame->{{False,False},{True,False}},FrameTicks->{{{1,0}},{{1,"0"},{12,"0.16"},{24,"0.33"},{36,"0.5"},{48,"0.67"},{60,"0.84"},{71,"1.0"}}},FrameLabel->{"","Value Color"}]


ColorBand[ratio_]:=MatrixPlot[{Table[a,{a,0.0,1.0,0.01}]},ColorFunction->(Hue[ratio*#]&),ColorFunctionScaling->False,Frame->{{False,False},{True,False}},FrameTicks->{{{1,0}},Table[{i,N[0.01(i-1)]},{i,1,101,10}]},FrameLabel->{"","Value Color"}]


(* ::Input:: *)
(*ColorBand[]*)


(* ::Subsubtitle:: *)
(*Data viusalization on surface 3D and 2D*)


(* ::Subsection:: *)
(*3D surfaces*)


EvalueGrid3D[point_,data_]:=(*data is datamain part*)Module[{points,weights,values},points=Tuples[Transpose[{IntegerPart[point],IntegerPart[point]+1}]];weights=Apply[#1*#2*#3&,1-Abs[Map[(#1-point)&,points]],{1}];values=Apply[data[[#1,#2,#3]]&,points,{1}];Inner[Times,values,weights]];


DataShow3D[data_,quility_,opts___]:=Module[{dim},dim=Dimensions[data];RegionPlot3D[True,{a,1,dim[[1]]-0.01},{b,1,dim[[2]]-0.01},{c,1,dim[[3]]-0.01},ColorFunction->Function[{a,b,c},(Hue[ 0.80*EvalueGrid3D[{a,b,c},data] ])],ColorFunctionScaling->False,Mesh->None,PerformanceGoal->"Quality",PlotPoints->quility*dim,Lighting->{None},ViewPoint->{3Sin[4],3Cos[4],1.8},AxesLabel->{"x","y","z"},(*Ticks->None,Boxed->False,*)Axes->True,BoxRatios->dim,opts]];
DataShow3D[data_]:=DataShow3D[data,1]


(* ::Input:: *)
(*Max[{1,2,3,{4,5}}]*)


(* ::Subsection:: *)
(*2D surface*)


EvalueGrid2D[point_,data_]:=(*data is datamain part*)Module[{points,weights,values},points=Tuples[Transpose[{IntegerPart[point],IntegerPart[point]+1}]];weights=Apply[#1*#2&,1-Abs[Map[(#1-point)&,points]],{1}];values=Apply[data[[#1,#2]]&,points,{1}];Inner[Times,values,weights]];


DataShow2D[data_,quility_,opts___]:=Module[{dim},dim=Dimensions[data];RegionPlot[True,{a,1,dim[[1]]-0.01},{b,1,dim[[2]]-0.01},ColorFunction->Function[{a,b},(Hue[ 0.80EvalueGrid2D[{a,b},data] ])],ColorFunctionScaling->False,Mesh->None,PerformanceGoal->"Quality",PlotPoints->quility*dim,Ticks->None,Axes->False,opts]];
DataShow2D[data_]:=DataShow2D[data,1]


Options[RegionShow3D]=Flatten[{BorderRatio -> 1/2, BorderValue ->Null,BigerPart -> True}];
RegionShow3D[data_, options___] := Module[{dim = Dimensions[data], bigerPart, border, borderRatio, max = Max[Flatten[data,\[Infinity]]], min = Min[Flatten[data,\[Infinity]]], opt, optRest}, opt = Flatten[{options}];If[max==min,(Print["Max and min elements are ",max,", ",min," respectfully, showing no varience."];Return[Null])];If[Abs[(max - min)/((Abs[max] +Abs[ min])/2)] < 0.00001, Print["Max Value and Min Value are rather close to each other,so there might not be enough meaning from this para."]]; borderRatio = BorderRatio /. Flatten[{opt, BorderRatio -> 1/2}]; border = BorderValue /. Flatten[{opt, BorderValue -> (borderRatio*(max - min) + min)}];bigerPart = BigerPart /. Flatten[{opt, BigerPart -> True}];optRest=Complement[opt,FilterRules[opt,{BorderRatio,BorderValue,BigerPart}]];RegionPlot3D[data[[Floor[i], Floor[j], Floor[k]]] > border, {i, 1, dim[[1]]}, {j, 1, dim[[2]]}, {k, 1, dim[[3]]}, PlotRange -> {{1,dim[[1]]},{1,dim[[2]]},{1,dim[[3]]}}, Evaluate[optRest]]];


(* ::Subsubtitle:: *)
(*with apply in phase transition*)


ShowEta2D[file_, qua___] := Module[{data,dim,sta},{data,dim,sta} = DataImport[file]; data = (data[[1]]*-1+data[[2]]*-0.5+data[[3]]*0.5+data[[4]]*1)/2+0.5;dim=Drop[dim,2];If[dim[[3]] == 1, {dim = Drop[dim, {3}], data = UnFlatten[Flatten[data],dim]},If[dim[[2]] == 1, {dim = Drop[dim, {2}],data = UnFlatten[Flatten[data],dim]},{dim = Drop[dim, {1}], data = UnFlatten[Flatten[data],dim]}]];DataShow2D[data,dim,qua]]


ShowEta3D[file_,qua___]:=Module[{data,dim,sta},{data,dim,sta} = DataImport[file];data = (data[[ 1]]*-1 + data[[2]]*-0.5 + data[[3]]*0.5+data[[4]]*1)/2+0.5;DataShow3D[data,qua]]


ShowDefect2D[file_,qua___]:=Module[{defect,dim,sta},{ defect,dim, sta} = DataImport[file];dim=Drop[dim,1];If[dim[[3]] == 1, {dim = Drop[dim, {3}], defect = UnFlatten[Flatten[defect],dim]},If[dim[[2]] == 1, {dim = Drop[dim, {2}],defect = UnFlatten[Flatten[defect],dim]},{dim = Drop[dim, {1}], defect = UnFlatten[Flatten[defect],dim]}]];DataShow2D[defect,qua]]


ShowDefect3D[file_,qua___]:=Module[{defect},defect = DataImport[file];RegionShow3D[defect[[1]],qua]]


(* ::Section:: *)
(*FileShowEvolution*)


(* ::Text:: *)
(*Showing the Temperature vs. evolution process and gives out the temperature where shows the highest evolution velocity*)


FileShowEvolution1[file_]:=Module[{dataT,ticks,t,p},dataT=Transpose[Partition[ReadList[file,Number],{5}]];Print["The range of the highest rate is ", t={dataT[[1]][[p=Position[Differences[Plus@@Rest[dataT]],Max[Differences[Plus@@Rest[dataT]]]][[1,1]]]],dataT[[1]][[1+Position[Differences[Plus@@Rest[dataT]],Max[Differences[Plus@@Rest[dataT]]]][[1,1]]]]}," with average ", Mean[t]];ticks={Table[{i,dataT[[1,i]]},{i,1,Length[dataT[[1]]],3}]};Show[ListPlot[Join[Rest[dataT],{Plus@@Rest[dataT]}],Ticks->ticks,PlotMarkers->Automatic,Joined->True,PlotRange->{All,{0,1}},AxesOrigin->{0,0},PlotLabel->"Temperature--Transformation"],Graphics[{{Red,Dashed,Thin,Line[{{p+0.5,0.05},{p+0.5,0.95}}]},{Arrowheads[0.02],Arrow[{{p-2,0.6},{p-0.05,0.55}}]},{Text[Mean[t],{p-3.2,0.6}]}}]]]


FileShowEvolution[file_]:=Module[{dataT,ticks,t,p},dataT=Transpose[Partition[ReadList[file,Number],{6}]];Print["The range of the highest transformation rate is ",t={dataT[[1]][[p=Position[Differences[Last[dataT]],Max[Differences[Last[dataT]]]][[1,1]]]],dataT[[1]][[1+Position[Differences[Last[dataT]],Max[Differences[Last[dataT]]]][[1,1]]]]}," with average ", Mean[t]];ticks={Table[{i,dataT[[1,i]]},{i,1,Length[dataT[[1]]],3}]};Show[ListPlot[Join[Rest[dataT]],Ticks->ticks,PlotMarkers->Automatic,Joined->True,PlotRange->{All,{0,1}},AxesOrigin->{0,0},PlotLabel->"Temperature--Microstructure"],Graphics[{{Red,Dashed,Thin,Line[{{p+0.5,0.05},{p+0.5,0.95}}]},{Arrowheads[0.02],Arrow[{{p-2,0.6},{p-0.05,0.55}}]},{Text[Mean[t],{p-3.2,0.6}]}}]]]


FileShowEvolutionToFile[file_,imageFile_]:=Module[{data,image},data=DataImport3D[file];image=DataShowSurface[data];Export[imageFile,image,ImageResolution->100]]


(* ::Input:: *)
(*Options[RegionShow2D]=Flatten[{}];*)
(*RegionShow2D[data_, options___] := Module[{L = Length[data], bigerPart, border, borderRatio, max = Max[data], min = Min[data], opt, optRest}, opt = Flatten[{options}];If[max==min,(Print["Max and min elements are ",max,", ",min," respectfully, showing no varience."];Return[Null])];If[Abs[(max - min)/((Abs[max] +Abs[ min])/2)] < 0.00001, Print["Max Value and Min Value are rather close to each other,so there might not be enough meaning from this para."]]; optRest=Complement[opt,FilterRules[opt,{}]];ArrayPlot[data,ColorFunction->(Hue[0.7*(#-min)/(max-min)+0.35]&),ColorFunctionScaling->False,optRest]]*)
(**)


(* ::Input:: *)
(*RegionShow[data_,N_,options___]:=If[N==3,RegionShow3D[data,options],If[N==2,RegionShow2D[data,options],Print["Dimention ",N," version has not realized yet"]]]*)
(*Options[FileShow]=Flatten[{ExportFile->False}];*)
(*FileShow[file_,N_,options___]:=Module[{graph,data,n,x,opt,optRest,exportFile},If[Not[FileExistsQ[file]],Print["file \"",file,"\" does not exist"];Return[Null]];{data,n,x}=DataImport[file,N];opt=Flatten[{options}];exportFile=ExportFile/.Flatten[{opt,ExportFile->False}];optRest=Complement[opt,FilterRules[opt,{ExportFile}]];graph=RegionShow[data,N,optRest];If[StringQ[exportFile]==False,graph,(Export[exportFile,graph,"BMP"];graph)]]*)
(*Options[FileShow3D]=Options[FileShow];*)
(*FileShow2D[file_,options___]:=FileShow[file,2,options]*)
(*Options[FileShow3D]=Options[FileShow];*)
(*FileShow3D[file_,options___]:=FileShow[file,3,options]*)
