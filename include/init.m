(* ::Package:: *)

(* ::Section:: *)
(*comstom settings*)


(* ::Text:: *)
(*Working directory*)


SetDirectory["F:\\SkyDrive\\Desktop"];


(* ::Section:: *)
(*Redefine Usage*)


(* ::Text:: *)
(*Usage statement*)


Button[$UserBaseDirectory, Inherited, BaseStyle -> "Link", ButtonData -> "paclet:ref/$UserBaseDirectory"]
Button[$BaseDirectory, Inherited, BaseStyle -> "Link", ButtonData -> "paclet:ref/$BaseDirectory"]


(** User Mathematica initialization file **)
EqualToRule::"usage"="EqualToRule[\!\(\*
StyleBox[\"expr\",\nFontColor->RGBColor[0, 1, 0]]\)] replaces '\[Equal]' with '\[Rule]' in \!\(\*
StyleBox[\"expr\",\nFontColor->RGBColor[0, 1, 0]]\)" ;
EqualToRule[expr_]:=expr/.{a_==b_->a->b};
EqualToRule[{expr__}]:={expr}/.{a_==b_->a->b};


(* ::Section:: *)
(*Get in pachage working packages high-freq*)


Get["E:\\SkyDrive\\Include_E\\DataProcess.m"]
