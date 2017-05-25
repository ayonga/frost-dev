(* Wolfram Language Package *)

(* Created by the Wolfram Workbench Sep 18, 2016 *)

(*********CseOptimization: Simplify Expression via Common Subexpression Elimination Technique(CSE) ***********)
(* Developed and maintained by Ayonga Hereid @ AMBER Lab*)

BeginPackage["MathToCpp`",{"ExtraUtils`","Experimental`"}]
(* Exported symbols added here with SymbolName::usage *) 

ExportToCpp::usage="ExportToCpp[name,expr,vars,options] optimizes expressions using CSE and export the resulting code
into C++ file.

Inputs:
name -> A string contains the file name of the exported C++ files (name.cc and name.hh).
expr -> The expression that planned to be exported, ONLY supports 1-dimensional (scaler, vector) and 2-dimensional list (matrix).
vars -> The list of symbolic variables in the exported expression.
varnames -> The variable names represents symbolic variables in C++ code.
options -> Additional options defined below. They could be defined by SetOptions function outside of the function call.

Options:
ExportDirectory -> Export directory for file (default: '.')
TemplateFile -> Absolute path to the template file of C++ source code.
TemplateHeader -> Absolute path to the template file of C++ header file.
Namespace(optional) -> Defines a namespace for the exported C++ function (only for standard C++ application, not defined for Matlab's mex function).
behavior(optional) -> Defines a sub-namespace for the exported C++ function (only for standard C++ application, not defined for Matlab's mex function).
                       ";


          
ExportWithGradient::usage="ExportWithGradient[name,expr,vars,const] exports the expr and its first order Jacobian w.r.t. vars in two
seperate files f_name and J_name. 

Inputs:
name -> A string contains the file name of the exported C++ files. 
        f_name.cc and f_name.hh: exported files for the expr;
        J_name.cc and J_name.hh: exported files for the first order Jacobian.
        Js_name.cc and Js_name.hh: exported files of the two vectors consisting of row/column indices of nonzero elements of the first order Jacobian.
expr -> A vector form expression to be exported.
vars -> A list of dependent variables.
const (optional) -> A list of constant that are used in the function."

ExportWithHessian::usage="ExportWithGradient[name,expr,vars,const] exports the expr and its first and second order Jacobian w.r.t. vars.
Inputs:
name -> A string contains the file name of the exported C++ files. 
        f_name.cc and f_name.hh: exported files for the expr;
        J_name.cc and J_name.hh: exported files of the vector of nonzero elements of the first order Jacobian.
        Js_name.cc and Js_name.hh: exported files of the two vectors consisting of row/column indices of nonzero elements of the first order Jacobian.
        H_name.cc and H_name.hh: exported files of the vector of nonzero elements of the second order Jacobian.
        Hs_name.cc and Hs_name.hh: exported files of the two vectors consisting of row/column indices of nonzero elements of the second order Jacobian.
expr -> A vector form expression to be exported.
vars -> A list of dependent variables.
const (optional) -> A list of constant that are used in the function."


CseOptimizeExpression::usage="CseOptimizeExpression[expr] 
Eliminates common subexpressions in 'expr', and return a Decomposed Block in Hold form.
@param expr: an symbolic expression to be simplified.
@return the simplified CompoundExpression in decomposed block with HoldForm attributes.
@option OptimizationLevel: The level of optimization, choose from 0, 1, 2. The higher value gives more optimized code.
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

             
Begin["`Private`"]
(* Implementation of the package *)



SyntaxInformation[CseOptimizeExpression]={"ArgumentsPattern"->{_,OptionsPattern[]}};
CseOptimizeExpression[expr_,OptionsPattern[]]:=
	Block[{optExpr},
	optExpr = Experimental`OptimizeExpression[expr,OptimizationLevel->OptionValue[OptimizationLevel],OptimizationSymbol->Global`t];
	DecomposeBlock[optExpr]
	];
Options[CseOptimizeExpression]={OptimizationLevel-> 1};

SyntaxInformation[DecomposeBlock]={"ArgumentsPattern"->{_}};
DecomposeBlock[block_]:=
	ReleaseHold[(Hold@@block)/.Verbatim[Block][vars_,seq_]:>{vars,Hold[seq]}];

SyntaxInformation[ReplaceVariable]={"ArgumentsPattern"->{_,_}};
ReplaceVariable[vars_,code_]:=
    Block[{nvars},
	nvars=Dispatch[MapIndexed[#1-> ToExpression["t"<>ToString@@#2]&,vars]];
	{vars,code}/.nvars];
	
SyntaxInformation[ConvertToRule]={"ArgumentsPattern"->{_}};
ConvertToRule[code_]:= code/.Set-> Rule;

SyntaxInformation[ConvertToSet]={"ArgumentsPattern"->{_}};
ConvertToSet[code_]:= code/.Rule-> Set;

DeleteUnnecessoryExpr[code_]:=
	Block[{unvars},
	unvars=Cases[Cases[code,_Symbol,Infinity]//Tally,{_,2}][[All,1]];
	Verbatim[Rule][Alternatives@@unvars,_]//DeleteCases[code,#,Infinity]//.Cases[code,#,Infinity]&
	];
(*

TODO: Deleted unnecessory expression results in incorrect expression.
*)
DeleteUnnecessoryExpr[vars_,code_]:=
	Block[{unvars, ruleCode, newCode, newVar},
	ruleCode = ConvertToRule[code];
	
	unvars=Cases[Cases[ruleCode,_Symbol,Infinity]//Tally,{_,2}][[All,1]];
	newCode = Verbatim[Rule][Alternatives@@unvars,_]//DeleteCases[ruleCode,#,Infinity]//.Cases[ruleCode,#,Infinity]&;
	
	newVar = Select[vars, Not@MemberQ[unvars, #] &];
	newCode = ConvertToSet[newCode];
	{newVar, newCode}
	];
	
SyntaxInformation[GetSequenceExprMatlab]={"ArgumentsPattern"->{_}};
GetSequenceExprMatlab[code_]:= code/.Hold[CompoundExpression[s___,f_]]:>s;

SyntaxInformation[GetFinalExprMatlab]={"ArgumentsPattern"->{_}};
GetFinalExprMatlab[code_]:= code/.Hold[CompoundExpression[s___,f_]]:>f;


SyntaxInformation[GetSequenceExprCpp]={"ArgumentsPattern"->{_}};
GetSequenceExprCpp[code_]:= Map[Hold,N[code,15],{2}]/.Hold[CompoundExpression[seq__,f_]]:>{seq};

SyntaxInformation[GetFinalExprCpp]={"ArgumentsPattern"->{_}};
GetFinalExprCpp[code_]:= ReleaseHold[Map[Hold,N[code,15],{2}]/.Hold[CompoundExpression[seq__,f_]]:>{f}];


SyntaxInformation[ConvertToCForm]={"ArgumentsPattern"->{_}};
ConvertToCForm[code_]:=StringReplace[ToString[CForm[#]],"Hold("~~ShortestMatch[a___]~~")":>a]&/@code;

SyntaxInformation[ExportToCpp]={"ArgumentsPattern"->{_,_,_,OptionsPattern[]}};
ExportToCpp[name_String,expr_,vars_, OptionsPattern[]]:=
	Block[{varname,argin, argins,arginDims,csubs,cFile,hFile,argoutDims,funcLists,tpl,hdr,seqs,finals,lvars,optStatement,assoc},
		(*Obtain basic information*)
		cFile = FileNameJoin[{OptionValue[ExportDirectory],name <> ".cc"}];
		hFile = FileNameJoin[{OptionValue[ExportDirectory],name <> ".hh"}];

		(* Get dimensions of input arguments *)
		
		arginDims= Join[Dimensions/@(ExtraUtils`ToMatrixForm/@vars)];
		argins   = ToExpression/@StringInsert[ToString/@Range[Length[arginDims]],"var",1];
		csubs    = Dispatch@Join[Flatten@Table[argin = ExtraUtils`ToVectorForm[vars[[i]]]; 
			varname = ToString@argins[[i]];
  			((argin[[# + 1]] -> ToExpression["HoldForm@(Global`" <> varname <> "[[" <> ToString[#] <>"]])"] &) /@ (Range[Length[argin]] - 1)), {i,Length[arginDims]}]];
        (* Get dimensions of output arguments *)
		argoutDims=Join[Dimensions/@(ExtraUtils`ToMatrixForm/@expr)];
        (* Create a list of strings for output arguments: output1, output2, ..., outputN *)
		funcLists=StringInsert[ToString/@Range[Length[argoutDims]],"output",1];

        (* Simplify expressions and store results in a list, each expression has three parts:*)
        (* syms: strings of local variables (intermediate) definition *)
        (* statement: strings of intermediate code *)
        (* result: strings of final result code *)
		optStatement=Block[{vexpr,oexpr,seq,syms,code,subcode,final,statement,result,NonZeroIndices,y},
			Table[
              (* vectorize expression *)
			  vexpr=ExtraUtils`ToVectorForm[expr[[i]]];
              (* Simplify and decompose expression *)
			  oexpr=CseOptimizeExpression[vexpr];
			  If[ExtraUtils`EmptyQ[oexpr], (* If the expression is empty *)
                syms={"_NotUsed"};
				statement={"NULL"};
                result={"NULL"};
                argoutDims[[i]]={0,0};(*empty matrix*)
                ,
                If[ListQ[First[oexpr]],  
				  (*{syms,code}=DeleteUnnecessoryExpr[First[oexpr],Last[oexpr]];
				  {syms,code}=ReplaceVariable[syms,code];*)
				  syms = First[oexpr];
				  code = Last[oexpr];
				  subcode=code/.csubs;
				  seq=GetSequenceExprCpp[subcode];
				  final=GetFinalExprCpp[subcode];
				  statement=ConvertToCForm[seq];
                  result=Map["p_" <> ToString@funcLists[[i]] <> "[" <> ToString[# - 1] <> "]=" <> ToString[CForm@final[[1, #]]] &,Range@(argoutDims[[i, 1]]*argoutDims[[i, 2]])];
                  ,
				  syms={"_NotUsed"};
				  statement={"NULL"};
                  final={oexpr/.csubs};
                  result=Map["p_" <> ToString@funcLists[[i]] <> "[" <> ToString[# - 1] <> "]=" <> ToString[CForm@final[[1, #]]] &,Range@(argoutDims[[i, 1]]*argoutDims[[i, 2]])];                  
                ];
              ];
			    {syms,statement,result}
			    ,{i,Length[funcLists]}
			]
		];
		lvars=optStatement[[All,1]];
		seqs=optStatement[[All,2]];
		finals=optStatement[[All,3]];
		tpl=FileTemplate[OptionValue[TemplateFile]];
		hdr=FileTemplate[OptionValue[TemplateHeader]];
		assoc=<|"name"->name,
                 "argins"-> argins,
                 "argouts"-> funcLists,
                 "arginDims"-> arginDims,
                 "argoutDims"-> argoutDims,
                 "final"-> finals,
                 "lvars"-> lvars,
                 "statements"-> seqs,
                 "namespace"->OptionValue[Namespace]|>;
		FileTemplateApply[tpl,assoc,cFile];
		FileTemplateApply[hdr,assoc,hFile];		
	];
Options[ExportToCpp]={ExportDirectory->".",
                      TemplateFile->FileNameJoin[{DirectoryName[$InputFileName],"Template","template.cc"}],
                      TemplateHeader->FileNameJoin[{DirectoryName[$InputFileName],"Template","template.hh"}],
                      Namespace->"namespace"};


                      

ExportWithGradient[name_,expr_,vars_]:=
Block[
	{gradExpr,fvars,fexprs,nzGrad,gradExprVec,var},
	(* Flatten input arguments *)
    fvars=Flatten[vars];
    fexprs=Flatten[expr];
	(* Export expression *)
    ExportToCpp["f_"<>name,{fexprs},{fvars}];
    
    (* Compute the first order Jacobian *)
	gradExpr=D[fexprs,{fvars,1}];  
    
    gradExprVec=Cases[gradExpr, Except[0], {2}];
    (* Export the vectorized partial first order jacobian*)
	ExportToCpp["J_"<>name,{gradExprVec},{fvars}];

	(* Extract the nonzero entries of the first order jacobian, and vectorize it*)
    nzGrad=Position[gradExpr, Except[0], {2}, Heads -> False];
	(* Export the sparsity structure of the first and second order jacobian*)
	ExportToCpp["Js_"<>name,{nzGrad},{var}];
];

ExportWithGradient[name_,expr_,vars_,consts_]:=
Block[
	{gradExpr,fvars,fexprs,fconsts,nzGrad,gradExprVec,var},
	(* Flatten input arguments *)
    fvars=Flatten[vars];
    fconsts=Flatten[consts];
    fexprs=Flatten[expr];
	(* Export expression *)
    ExportToCpp["f_"<>name,{fexprs},{fvars,fconsts}];
    
    (* Compute the first order Jacobian *)
	gradExpr=D[fexprs,{fvars,1}]; 
	gradExprVec=Cases[gradExpr, Except[0], {2}];
    (* Export the vectorized partial first order jacobian*)
	ExportToCpp["J_"<>name,{gradExprVec},{fvars,fconsts}];

	(* Extract the nonzero entries of the first order jacobian, and vectorize it*)
    nzGrad=Position[gradExpr, Except[0], {2}, Heads -> False];
	(* Export the sparsity structure of the first and second order jacobian*)
	ExportToCpp["Js_"<>name,{nzGrad},{var}];
];

     
     
ExportWithHessian[name_,expr_,vars_]:=
Block[
	{gradExpr,gradExprVec,fvars,fexprs,hessExprTensor,nExpr,hessExpr,hessStruct,nzGrad,nzHess,hessExprVec,\[CapitalLambda],var},
	(* Flatten input arguments *)
    fvars=Flatten[vars];
    fexprs=Flatten[expr];
	(* Export expression *)
    ExportToCpp["f_"<>name,{fexprs},{fvars}];
    
    (* Compute the first order Jacobian *)
	gradExpr=D[fexprs,{fvars,1}];  
    
    gradExprVec=Cases[gradExpr, Except[0], {2}];
    (* Export the vectorized partial first order jacobian*)
	ExportToCpp["J_"<>name,{gradExprVec},{fvars}];

	(* Extract the nonzero entries of the first order jacobian, and vectorize it*)
    nzGrad=Position[gradExpr, Except[0], {2}, Heads -> False];
	(* Export the sparsity structure of the first and second order jacobian*)
	ExportToCpp["Js_"<>name,{nzGrad},{var}];
	
	
    (* Compute the second order Jacobian*)
    hessExprTensor = D[fexprs, {fvars, 2}]; 
    
    (* Since the Hessian is symmetric matrix, only use the lower triangular part  *)
    nExpr = Length[fexprs];
    \[CapitalLambda]=Table[\[Lambda][i],{i,nExpr}];
    hessExpr=Sum[\[CapitalLambda][[i]]*LowerTriangularize@hessExprTensor[[i, ;;]], {i,nExpr}];
    
    (* Export the vectorized partial second order jacobian*)
    hessExprVec=Cases[hessExpr, Except[0], {2}];
    ExportToCpp["H_"<>name,{hessExprVec},{fvars,\[CapitalLambda]}];
   
   	(* Extract the nonzero entries of the second order jacobian, and vectorize it *)
    nzHess=Position[hessExpr, Except[0], {2}, Heads -> False];
    ExportToCpp["Hs_"<>name,{nzHess},{var}];
];
ExportWithHessian[name_,expr_,vars_,consts_]:=
Block[
	{gradExpr,gradExprVec,fvars,fexprs,fconsts,hessExprTensor,nExpr,hessExpr,hessStruct,nzGrad,nzHess,hessExprVec,\[CapitalLambda],var},
	(* Flatten input arguments *)
    fvars=Flatten[vars];
    fexprs=Flatten[expr];
    fconsts=Flatten[consts];
	(* Export expression *)
    ExportToCpp["f_"<>name,{fexprs},{fvars,fconsts}];
    
    (* Compute the first order Jacobian *)
	gradExpr=D[fexprs,{fvars,1}];  
    
    gradExprVec=Cases[gradExpr, Except[0], {2}];
    (* Export the vectorized partial first order jacobian*)
	ExportToCpp["J_"<>name,{gradExprVec},{fvars,fconsts}];

	(* Extract the nonzero entries of the first order jacobian, and vectorize it*)
    nzGrad=Position[gradExpr, Except[0], {2}, Heads -> False];
	(* Export the sparsity structure of the first and second order jacobian*)
	ExportToCpp["Js_"<>name,{nzGrad},{var}];
	
	
    (* Compute the second order Jacobian*)
    hessExprTensor = D[fexprs, {fvars, 2}]; 
    
    (* Since the Hessian is symmetric matrix, only use the lower triangular part  *)
    nExpr = Length[fexprs];
    \[CapitalLambda]=Table[\[Lambda][i],{i,nExpr}];
    hessExpr=Sum[\[CapitalLambda][[i]]*LowerTriangularize@hessExprTensor[[i, ;;]], {i,nExpr}];
    
    (* Export the vectorized partial second order jacobian*)
    hessExprVec=Cases[hessExpr, Except[0], {2}];
    ExportToCpp["H_"<>name,{hessExprVec},{fvars,\[CapitalLambda],fconsts}];
   
   	(* Extract the nonzero entries of the second order jacobian, and vectorize it *)
    nzHess=Position[hessExpr, Except[0], {2}, Heads -> False];
    ExportToCpp["Hs_"<>name,{nzHess},{var}];
];

                      
                      
End[]

EndPackage[]

