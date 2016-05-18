(* ::Package:: *)

Needs["Experimental`"];


BeginPackage["CseOptimization`"];

(*********CseOptimization: Simplify Expression via Common Subexpression Elimination Technique(CSE) ***********)
(* Developed and maintained by Ayonga Hereid @ AMBER Lab*)
(* Contact: ayonga27@gmail.com*)


(* Version Logs:
05/17/2016 ayonga - changed function names and minor updates.
05/17/2016 ayonga - fixed transformation from scaler to matrix and scaler to vector.
05/17/2016 ayonga - Removed the export utlities to ToCpp package, left with pure expression simplifying utilities.*)

CseOptimizeExpression::usage="CseOptimizeExpression[expr] eliminates common subexpressions in 'expr', 
and return a Decomposed Block in Hold form.

Options:
OptimizationLevel -> The level of optimization, choose from 0, 1, 2. The higher value gives more optimized code.
";

DecomposeBlock::usage="DecomposeBlock[Block] decomposes the 'Block' in hold into two parts: 
'vars' - a list of local variables, and 'code' - CompoundExpression of the 'Block' in Hold form";

ReplaceVariable::usage="ReplaceVariable[vars,code] replaces 'vars' in code to some 
readible symbols."

ConvertToRule::usage="ConvertToRule[code] replaces Set in expression 'code' to 
subsititution rules."

DeleteUnnecessoryExpr::usage="DeleteUnnecessoryExpr[code] deletes some sub expression 
in the 'code' that appears only once, and replace those subvariables with the 
original expressions in the following expression (it should have only one expression
that use the subvaribale.)";

GetSequenceExprMatlab::usage="GetSequenceExprMatlab[code] decomposes the compound expression 'code into two parts and
return 'seq' - sequenced expression except the last one.";
GetFinalExprMatlab::usage="GetFinalExprMatlab[code] decomposes the compound expression 'code into two parts and
return 'final' - the last expression.";

GetSequenceExprCpp::usage="GetSequenceExprCpp[code] decomposes the compound expression 'code into two parts and
return 'seq' - sequenced expression except the last one.";
GetFinalExprCpp::usage="GetFinalExprCpp[code] decomposes the compound expression 'code into two parts and
return 'final' - the last expression.";

ConvertToCForm::usage="ConvertToCForm[code] Convert CompoundedExpressions into string of C++ code (CForm)."

ToMatrixForm::usage="ToMatrixForm[expr] converts expr to Matrix form (two dimensional tensor)."
ToVectorForm::usage="ToVectorForm[expr] converts expr to Vector form (one dimensional tensor)."


Begin["`Private`"]


ToVectorForm[expr_?MatrixQ]:=Flatten@(expr\[Transpose]); (*matrix \[Rule] vector*)
ToVectorForm[expr_?VectorQ]:=expr; (*vector \[Rule] vector*)
ToVectorForm[expr_/;!ListQ[expr]]:={Flatten@expr}; (*scaler \[Rule] vector*)
ToVectorForm[expr_]:={Flatten@expr}; (*list \[Rule] vector*)

ToMatrixForm[expr_?MatrixQ]:=expr; (*matrix \[Rule] matrix*)
ToMatrixForm[expr_?VectorQ]:=Transpose[{expr}]; (*matrix \[Rule] vector*)
ToMatrixForm[expr_/;!ListQ[expr]]:={{Flatten@expr}}; (*scaler \[Rule] vector*)


CseOptimizeExpression[expr_,OptionsPattern[]]:=
	Block[{optExpr},
	optExpr = Experimental`OptimizeExpression[expr,OptimizationLevel->OptionValue[OptimizationLevel]];
	DecomposeBlock[optExpr]
	];
Options[CseOptimizeExpression]={OptimizationLevel-> 1};

DecomposeBlock[block_]:=
	ReleaseHold[(Hold@@block)/.Verbatim[Block][vars_,seq_]:>{vars,Hold[seq]}];

ReplaceVariable[vars_,code_]:=
    Block[{nvars},
	nvars=Dispatch[MapIndexed[#1-> ToExpression["t"<>ToString@@#2]&,vars]];
	{vars,code}/.nvars];


ConvertToRule[code_]:= code/.Set-> Rule;

DeleteUnnecessoryExpr[code_]:=
	Block[{unvars},
	unvars=Cases[Cases[code,_Symbol,Infinity]//Tally,{_,2}][[All,1]];
	Verbatim[Rule][Alternatives@@unvars,_]//DeleteCases[code,#,Infinity]//.Cases[code,#,Infinity]&
	];


GetSequenceExprMatlab[code_]:= code/.Hold[CompoundExpression[s___,f_]]:>s;
GetFinalExprMatlab[code_]:= code/.Hold[CompoundExpression[s___,f_]]:>f;


GetSequenceExprCpp[code_]:= Map[Hold,N[code,15],{2}]/.Hold[CompoundExpression[seq__,f_]]:>{seq};
GetFinalExprCpp[code_]:= ReleaseHold[Map[Hold,N[code,15],{2}]/.Hold[CompoundExpression[seq__,f_]]:>{f}];


ConvertToCForm[code_]:=StringReplace[ToString[CForm[#]],"Hold("~~ShortestMatch[a___]~~")":>a]&/@code;


End[]
EndPackage[]
