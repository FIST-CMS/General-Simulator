(* ::Package:: *)

Get["/public/home/Eins/include/datavisual.m"]



(* ::Section:: *)
(*Function Usage doc*)


DataImport::"usage"=
"DataImport[file_] import data in file arranged in a row.
 It returns {data,{n,n1,n2,n..,nn,totalNumber},{min[data],mean[data],max[data]}
	data stores the elements imported
	...
";


(* ::Section:: *)
(*Code Definition Part*)


(* ::Subsection:: *)
(*Expression Transfer*)


ChangeToExpression[x__]:=ToExpression[StringJoin[ToString/@{x}]]
ChangeToString[x__]:=StringJoin[ToString/@{x}]


(* ::Subsection:: *)
(*Data Import, Export and Print  Functions*)


(* ::Text:: *)
(*Import data of arbitary shape*)


unflatten[e_,{d__?((IntegerQ[#]&&Positive[#])&)}]:= Fold[Partition,e,Take[{d},{-1,2,-1}]] /;(Length[e]===Times[d]);
UnFlatten[e_,{d__}]:= Fold[Partition,e,Take[{d},{-1,2,-1}]] /;(Length[e]===Times[d]);


DataImport[file_]:=Module[{data,dim,sta,datamain},If[Not[FileExistsQ[file]],Print["file \"",file,"\" does not exist"];Return[Null]];data=ReadList[file,Number];dim= data[[1;;data[[1]]+1]];datamain=Drop[data,data[[1]]+1];sta={Min[datamain],Mean[datamain],Max[datamain]};datamain=unflatten[datamain,Rest[dim]];{datamain,dim,sta}];


(* ::Text:: *)
(*the format of DataImport is :  { data, dim, statistics}*)


DataExport[data_,file_]:=Module[{ofs,dim},dim = Dimensions[data];ofs = OpenWrite[file];WriteString[ofs,Length[dim]," "];WriteString[ofs, #]&/@Flatten[{#," "}&/@dim];Write[ofs];Write[ofs, #]&/@Flatten[data, \[Infinity]];Close[ofs];]


DataPrint[data_]:=Module[{ofs,dim},dim = Dimensions[data];ofs = OutputStream["stdout",1];WriteString[ofs,Length[dim]," "];WriteString[ofs, #]&/@Flatten[{#," "}&/@dim];Write[ofs];Write[ofs, #]&/@Flatten[data, \[Infinity]];]


(* ::Text:: *)
(*The format of DataExport and DataPrint is the same as Data in the cuda*)
