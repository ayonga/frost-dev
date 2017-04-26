(* Wolfram Language Package *)

(* :Title: ExtraUtils *)

(* :Author: Eric Cousineau 
            Ayonga Hereid
            Ryan Sinnet
            @(AMBER Lab) *)

(* :Summary: 
This package provides custom commonly used functions. 
*)


BeginPackage["ExtraUtils`",{"GeneralUtilities`","SnakeYaml`","ComputerArithmetic`"}]
(* Exported symbols added here with SymbolName::usage *) 

ToMatrixForm::usage="ToMatrixForm[expr] converts expr to Matrix form (two dimensional tensor)."
ToVectorForm::usage="ToVectorForm[expr] converts expr to Vector form (one dimensional tensor)."

LoadConfig::usage = 
	"LoadConfig[file] loads configuration YAML file into an association structure."

ParallelSimplify::usage = 
	"ParallelSimplify[A_?MatrixQ] simplifies a matrix in parallel.
	ParallelSimplify[V_?VectorQ]  simplifies a vector in parallel.";

ParallelFullSimplify::usage = 
	"ParallelFullSimplify[A_?MatrixQ] fully simplifies a matrix in parallel.
	ParallelFullSimplify[V_?VectorQ] fully simplifies a vector in parallel.";

FindSymbols::usage = "FindSymbols[expr] returns all non-special symbol \
	characters in the expression.";
	
CheckSymbols::usage ="CheckSymbols[expr, list] checks if all symbols found \
	in the expressions are member of the list. Return False if Not.";

Vec::usage = "Vec[x] turns an arbitrary list x into a vector";

ToExpressionEx::usage = "ToExpressionEx[expr] loosely converts any string types in an 0- \ 
to n-dimensional list to an expression.";

(*RationalizeEx::usage = "RationalizeEx[expr] loosely rationalizes any expression to an arbitrary precision";

RationalizeAny::usage = "RationalizeAny[value] converts `value` to an expression and use RationalizeEx";
*)
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

Str2Num::usage = 
    "Str2Num[str] converts a string or a list of strings into real numbers.";

Jac::usage="Jac[h,x] Computes the Jacobian of a quantity with respect to the given coordinates."

GetFieldIndices::usage = 
	"GetFieldIndices[list, field] returns field position indices of element in the list based.";

DesiredFunction::usage = 
	"DesiredFunction[Type, N, a] returns the desired output functions.";
Begin["`Private`"]
(* Implementation of the package *)

DesiredFunction::badargs = "Undefined Function Type";
DesiredFunction["Constant", N_, a_] := {a[[#, 1]]} & /@ Range[N];
DesiredFunction["CWF", N_, 
   a_] := {(a[[#, 1]] Cos[a[[#, 2]] Global`t] + a[[#, 3]] Sin[a[[#, 2]] Global`t])/
       Exp[a[[#, 4]] Global`t] + a[[#, 5]]} & /@ Range[N];
DesiredFunction["ECWF", N_, a_] := {
     	(a[[#, 1]] Cos[a[[#, 2]] Global`t] + a[[#, 3]] Sin[a[[#, 2]] Global`t])/
       Exp[a[[#, 4]] Global`t] +
      	(2*a[[#, 4]]*a[[#, 5]]*a[[#, 6]])/(a[[#, 4]]^2 + a[[#, 2]]^2 - 
          a[[#, 6]]^2) Sin[a[[#, 6]]*Global`t] + a[[#, 7]]} & /@ Range[N];

DesiredFunction["Bezier", N_, a_, 
   M_] := {Sum[
      a[[#, j + 1]]*Binomial[M, j]*Global`t^j*(1 - Global`t)^(M - j), {j, 0, 
       M}]} & /@ Range[N];
DesiredFunction["MinJerk", N_, 
   a_] := {a[[#, 
        2]] + (a[[#, 1]] - a[[#, 2]])*(10*(Global`t/a[[#, 3]])^3 - 
         15*(Global`t/a[[#, 3]])^4 + 6*(Global`t/a[[#, 3]])^5)} & /@ Range[N];
DesiredFunction[
   type_?StringQ, ___] := (Message[
    DesiredFunction::badargs]; $Failed);

SyntaxInformation[ToVectorForm]={"ArgumentsPattern"->{_}};
ToVectorForm[expr_?MatrixQ]:=Flatten@(expr\[Transpose]); (*matrix \[Rule] vector*)
ToVectorForm[expr_?VectorQ]:=expr; (*vector \[Rule] vector*)
ToVectorForm[expr_/;!ListQ[expr]]:=Flatten@{expr}; (*scaler \[Rule] vector*)
ToVectorForm[expr_]:=Flatten@expr; (*list \[Rule] vector*)

SyntaxInformation[ToMatrixForm]={"ArgumentsPattern"->{_}};
ToMatrixForm[expr_?MatrixQ]:=expr; (*matrix \[Rule] matrix*)
ToMatrixForm[expr_?VectorQ]:=Transpose[{expr}]; (*matrix \[Rule] vector*)
ToMatrixForm[expr_/;!ListQ[expr]]:={Flatten@{expr}}; (*non-list scaler \[Rule] vector*)
ToMatrixForm[expr_/;ListQ[expr]]:={Flatten@expr}; (*non-list \[Rule] vector*)

FindSymbols[expr_]:= 
	Block[{syms},
		syms = DeleteDuplicates[DeleteCases[Cases[expr, _Symbol, Infinity], _?NumericQ]];
		Return[Flatten[syms]];
	];

CheckSymbols[expr_, list_?ListQ]:=
	Block[{syms},
		syms = FindSymbols[expr];
		
		Return[AllTrue[Map[MemberQ[list, #] &, syms],TrueQ]];
	];

Jac[h_,x_]:=D[Flatten[h],{Flatten[x]}];


Str2Num[s_String]:=RationalizeEx[Read[StringToStream[s],Number]];
Str2Num[sl_?ListQ]:=Map[Str2Num[#]&,Flatten@sl];
(*Str2Num[s_String]:=Read[StringToStream[s],Number];
Str2Num[sl_?ListQ]:=Map[Read[StringToStream[#],Number]&,Flatten@sl];*)

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
CRound[expr_?NumberQ, n_:-5] := Round[expr, 10^n];
CRound[expr_, n_:-5] := expr;
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

