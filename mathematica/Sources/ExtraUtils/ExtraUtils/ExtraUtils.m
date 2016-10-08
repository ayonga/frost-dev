(* Wolfram Language Package *)

(* :Title: ExtraUtils *)

(* :Author: Eric Cousineau 
            Ayonga Hereid
            Ryan Sinnet
            @(AMBER Lab) *)

(* :Summary: 
This package provides custom commonly used functions. 
*)


BeginPackage["ExtraUtils`",{"GeneralUtilities`","SnakeYaml`"}]
(* Exported symbols added here with SymbolName::usage *) 


LoadConfig::usage = 
	"LoadConfig[file] loads configuration YAML file into an association structure."

ParallelSimplify::usage = 
	"ParallelSimplify[A_?MatrixQ] simplifies a matrix in parallel.
	ParallelSimplify[V_?VectorQ]  simplifies a vector in parallel.";

ParallelFullSimplify::usage = 
	"ParallelFullSimplify[A_?MatrixQ] fully simplifies a matrix in parallel.
	ParallelFullSimplify[V_?VectorQ] fully simplifies a vector in parallel.";



Vec::usage = "Vec[x] turns an arbitrary list x into a vector";

ToExpressionEx::usage = "ToExpressionEx[expr] loosely converts any string types in an 0- \ 
to n-dimensional list to an expression.";

RationalizeEx::usage = "RationalizeEx[expr] loosely rationalizes any expression to an arbitrary precision";

RationalizeAny::usage = "RationalizeAny[value] converts `value` to an expression and use RationalizeEx";

BlockDiagonalMatrix::usage = 
	"BlockDiagonalMatrix[b:{__?MatrixQ}] creates block diagonal matrx.";

EnsureDirectoryExists::usage = 
	"EnsureDirectoryExists[dir] ensure directory exists, if not create one.";

CRoundEx::usage = 
	"CRoundEx[expr,n] eliminates those pesky small numbers in rotation matrices";

EmptyQ::usage ="EmptyQ[x] expression is a list that, when flattened, has no elements.";

SprintF::usage =
	"SprintF[format, args ...] shortened version of StringForm that returns a string";

StringImplode::usage = 
	"StringImplode[list, delim = '', format = '``'] joins list of strings with \
delim  and formats each arg with format";

Str2Num::usage = "Str2Num[s] Convert a string s into a number";

Jac::usage="Jac[h,x] Computes the Jacobian of a quantity with respect to the given coordinates."

GetFieldIndices::usage = 
	"GetFieldIndices[list, field] returns field position indices of element in the list based.";

Begin["`Private`"]
(* Implementation of the package *)

Jac[h_,x_]:=D[Flatten[h],{Flatten[x]}];



Str2Num[s_String]:=Read[StringToStream[s],Number];
Str2Num[sl_?ListQ]:=Map[Read[StringToStream[#],Number]&,Flatten@sl];

EmptyQ[x_List]:=ListQ[x]&&Length[Flatten[x]]==0;

StringImplode[list_, delim_: "", format_: "``"] := 
  StringJoin[
    Riffle[Table[SprintF[format, item], {item, list}], delim]
  ];

SprintF[args__] := ToString[StringForm[args]];

Vec[x_]:=Transpose[{Flatten[x]}];


ToExpressionEx[value_]:=Block[{result},result=If[StringQ[value],ToExpression[value],If[ListQ[value],Map[If[StringQ[#],ToExpression[#],#]&,value,-1],value]];
Return[result];];
RationalizeEx[expr_]:=Rationalize[expr,0];
RationalizeEx[expr_List]:=Map[RationalizeEx,expr,-1];
RationalizeAny[expr_]:=RationalizeEx[ToExpressionEx[expr]];


ParallelSimplify[A_?MatrixQ]:=ParallelTable[Simplify[A[[i,j]]],{i,Dimensions[A][[1]]},{j,Dimensions[A][[2]]}];
ParallelSimplify[A_?VectorQ]:=ParallelTable[Simplify[A[[i]]],{i,Length[A]}];
ParallelSimplify[A_]:=Simplify[A];

ParallelFullSimplify[A_?MatrixQ]:=ParallelTable[FullSimplify[A[[i,j]]],{i,Dimensions[A][[1]]},{j,Dimensions[A][[2]]}];
ParallelFullSimplify[A_?VectorQ]:=ParallelTable[FullSimplify[A[[i]]],{i,Length[A]}];
ParallelFullSimplify[A_]:=FullSimplify[A];


(* For eliminating those pesky small numbers in rotation matrices *)
CRound[expr_, n_:-5] := If[NumberQ[expr], Round[expr, 10^n], expr];
CRoundEx[expr_, n_:-5] := Map[CRound[#, n]&, expr, {-1}];



(*From:http://mathworld.wolfram.com/BlockDiagonalMatrix.html*)
BlockDiagonalMatrix[b:{__?MatrixQ}]:=
	Block[{r,c,n=Length[b],i,j},
		{r,c}=Transpose[Dimensions/@b];
		ArrayFlatten[
			Table[
				If[i==j,b[[i]],ConstantArray[0,{r[[i]],c[[j]]}]]
				,
				{i,n},{j,n}
			]
		]
	];
	
EnsureDirectoryExists[dir_?StringQ]:=
	Block[{pieces,cur},
		pieces=FileNameSplit[dir];
		Table[
			cur=FileNameJoin[pieces[[1;;i]]];
			If[!DirectoryQ[cur],
				CreateDirectory[cur];
			];
			,
			{i,Length[pieces]}
		];
	];	
	

LoadConfig[file_] := 
	Block[{tmp},
		tmp = YamlReadFile[file];
		ToAssociations[tmp]
	];


GetFieldIndices[arg_?ListQ, field_] := 
	Block[{},
		Return[PositionIndex[Map[#[field]&,arg]]];
	];
	
	
End[]

EndPackage[]

