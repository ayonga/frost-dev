(* Wolfram Language Package *)

(* :Title: ExtraUtils *)

(* :Author: Eric Cousineau 
            Ayonga Hereid
            Ryan Sinnet
            @(AMBER Lab) *)

(* :Summary: 
This package provides custom commonly used functions. 
*)

(* :Context: SnakeYaml` *)

BeginPackage["ExtraUtils`"]
(* Exported symbols added here with SymbolName::usage *) 




ParallelSimplify::usage="
ParallelSimplify[A_?MatrixQ]  
Simplifies a matrix in parallel.
ParallelSimplify[V_?VectorQ]  
Simplifies a vector in parallel.";

ParallelFullSimplify::usage="
ParallelFullSimplify[A_?MatrixQ]  
Fully simplifies a matrix in parallel.
ParallelFullSimplify[V_?VectorQ]  
Fully simplifies a vector in parallel."



Vec::usage="Vec[x]  Turn arbitrary list into vector";

ToExpressionEx::usage="ToExpressionEx[expr]  loosely converts any string types in an 0- to n-dimensional list to an expression.";

RationalizeEx::usage="RationalizeEx[expr]  loosely rationalize any expression to an arbitrary precision";

RationalizeAny::usage="RationalizeAny[value]  convert `value` to an expression and use RationalizeEx";

BlockDiagonalMatrix::usage="BlockDiagonalMatrix[b:{__?MatrixQ}]
Create block diagonal matrx.";

EnsureDirectoryExists::usage="EnsureDirectoryExists[dir]
Ensure directory exists, if not create one.";

CRoundEx::usage="CRoundEx[expr,n]
For eliminating those pesky small numbers in rotation matrices";

EmptyQ::usage =
"EmptyQ[x]  Expression is a list that, when flattened, has no elements.";


Begin["`Private`"]
(* Implementation of the package *)

EmptyQ[x_List]:=ListQ[x]&&Length[Flatten[x]]==0;



Vec[x_]:=Transpose[{Flatten[x]}];


ToExpressionEx[value_]:=Module[{result},result=If[StringQ[value],ToExpression[value],If[ListQ[value],Map[If[StringQ[#],ToExpression[#],#]&,value,-1],value]];
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
	Module[{r,c,n=Length[b],i,j},
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
	Module[{pieces,cur},
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
	
SyntaxInformation[LoadConfig]={"ArgumentsPattern"->{_}};
LoadConfig[file_]:=Apply[Association,Association@SnakeYaml`YamlReadFile[file],{2}];
	
End[]

EndPackage[]

