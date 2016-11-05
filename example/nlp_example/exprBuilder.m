(* ::Package:: *)

ClearAll;


(* ::Section:: *)
(*Initializate Packages*)


SetDirectory[NotebookDirectory[]];
ApplicationPath=FileNameJoin[{ParentDirectory[ParentDirectory[]],"mathematica","Applications"}];
$Path=DeleteDuplicates[Append[$Path,ApplicationPath]];


Get["MathToCpp`"];
Needs["ExtraUtils`"];


On[Assert];



$ExportPath=FileNameJoin[{NotebookDirectory[],"export"}];
EnsureDirectoryExists[$ExportPath];



SetOptions[CseWriteCpp,
    ExportDirectory->$ExportPath
];


(* ::Section:: *)
(*Configure NLP Variables*)


X = Vec[{x[1],x[2],x[3]}];
Y = Vec[{y[1],y[2]}];


(* ::Section:: *)
(*Configure Cost function*)


f1 = (x[1]-x[2])^2;
f2 = (x[2]+x[3] - 2)^2;
f3 = (y[1]-1)^2 + (y[2]-1)^2;



ExportWithHessian["cost1",{f1},{X}];
ExportWithHessian["cost2",{f2},{X}];


ExportWithGradient["cost3",{f3},{Y}]


(* ::Section:: *)
(*Configure Constraints*)


c1 = x[1] + 3*x[2];
c2 = x[3] + y[1] - 2*y[2];
c3 = x[2] - y[2];




