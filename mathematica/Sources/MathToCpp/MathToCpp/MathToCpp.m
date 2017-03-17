(* Wolfram Language Package *)

(* Created by the Wolfram Workbench Sep 18, 2016 *)

(*********CseOptimization: Simplify Expression via Common Subexpression Elimination Technique(CSE) ***********)
(* Developed and maintained by Ayonga Hereid @ AMBER Lab*)

BeginPackage["MathToCpp`",{"ExtraUtils`","Experimental`"}]
(* Exported symbols added here with SymbolName::usage *) 



CseWriteCpp::usage="CseWriteCpp[name,expr,options] optimizes expressions using CSE and export the resulting code
into C++ (mex) file.

Inputs:
name -> A string contains the file name of the exported C++ files (name.cc and name.hh).
expr -> The expression that planned to be exported, ONLY supports 1-dimensional (scaler, vector) and 2-dimensional list (matrix).
options -> Additional options defined below. They could be defined by SetOptions function outside of the function call.

Options:
ExportDirectory -> Export directory for file (default: '.')
ArgumentLists -> The list of input arguments as symbols (e.g. {x,p} represents two input arguments x and p) of the exported function (default: {})
ArgumentDimensions -> Dimensions of input arguments (e.g. {{3,1},{4,1}} represents that the argument is 3x1 vector and the second is 4x1 vector). 
                       If the input argument is scaler, please write the dimension as {1,1}.
                       Only Support scaler, vector, and matrix form of inputs.
                       It has to be a 2-dimensional list (matrix) with dimension 2xN, where N is the number of input arguments (default: {})
SubstitutionRules -> A list of rules that substitute Mathmatica symbols with input arguments defined in ArgumentLists. It must have a 
                      a form of {X -> HoldForm@x}. Be ware of the different indexing between Mathematica (starting from 1) and 
                      C/C++ (starting from 0). For example, For a vector X with dimension n, the rule has to be defined as:
                      {X[[1]]->HoldForm@x[[0]],...,X[[n]]->HoldForm@x[[n-1]]}. For a scaler variable, please define as:
                      {A -> HoldForm@a[[0]]}. If you have multiple substitution rules, they could be Join as one.
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
	optExpr = Experimental`OptimizeExpression[expr,OptimizationLevel->OptionValue[OptimizationLevel]];
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

SyntaxInformation[DeleteUnnecessoryExpr]={"ArgumentsPattern"->{_}};
DeleteUnnecessoryExpr[code_]:=
	Block[{unvars},
	unvars=Cases[Cases[code,_Symbol,Infinity]//Tally,{_,2}][[All,1]];
	Verbatim[Rule][Alternatives@@unvars,_]//DeleteCases[code,#,Infinity]//.Cases[code,#,Infinity]&
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



SyntaxInformation[CseWriteCpp]={"ArgumentsPattern"->{_,_,OptionsPattern[]}};
CseWriteCpp[name_String,expr_,OptionsPattern[]]:=
	Block[{argins,arginDims,csubs,cFile,hFile,argoutDims,funcLists,tpl,hdr,seqs,finals,lvars,optStatement,assoc},
		(*Obtain basic information*)
		argins = OptionValue[ArgumentLists];
		arginDims = OptionValue[ArgumentDimensions];
		csubs=OptionValue[SubstitutionRules];
		cFile = FileNameJoin[{OptionValue[ExportDirectory],name <> ".cc"}];
		hFile = FileNameJoin[{OptionValue[ExportDirectory],name <> ".hh"}];

        (* Get dimensions of output arguments *)
		argoutDims=Join[Dimensions/@(ExtraUtils`ToMatrixForm/@expr)];
        (* Create a list of strings for output arguments: output1, output2, ..., outputN *)
		funcLists=StringInsert[ToString/@Range[Length[argoutDims]],"output",1];

        (* Simplify expressions and store results in a list, each expression has three parts:*)
        (* vars: strings of local variables (intermediate) definition *)
        (* statement: strings of intermediate code *)
        (* result: strings of final result code *)
		optStatement=Block[{vexpr,oexpr,seq,vars,code,subcode,final,statement,result,NonZeroIndices,y},
			Table[
              (* vectorize expression *)
			  vexpr=ExtraUtils`ToVectorForm[expr[[i]]];
              (* Simplify and decompose expression *)
			  oexpr=CseOptimizeExpression[vexpr];
			  If[ExtraUtils`EmptyQ[oexpr], (* If the expression is empty *)
                vars={"_NotUsed"};
				statement={"NULL"};
                result={"NULL"};
                argoutDims[[i]]={0,0};(*empty matrix*)
                ,
                If[ListQ[First[oexpr]],
				  {vars,code}=ReplaceVariable[First[oexpr],Last[oexpr]];
				  subcode=code/.csubs;
				  seq=GetSequenceExprCpp[subcode];
				  final=GetFinalExprCpp[subcode];
				  statement=ConvertToCForm[seq];
                  (* Get the non zero elements of the output arguments and assign them one by one. Zero elements are by default set to zero.*)
                  If[OptionValue[ExportFull],
                    NonZeroIndices = Range@(argoutDims[[i,1]]*argoutDims[[i,2]]),
                    NonZeroIndices = Flatten@Position[Table[SameQ[y,0],{y,Flatten[final]}],False]
                  ];
                  result=Table["p_"<>ToString@funcLists[[i]]<>"["<>ToString[j-1]<>"]="<>ToString[CForm@final[[1,j]]],{j,NonZeroIndices}];
                  ,
				  vars={"_NotUsed"};
				  statement={"NULL"};
                  final={oexpr/.csubs};
                  If[OptionValue[ExportFull],
                    NonZeroIndices = Range@(argoutDims[[i,1]]*argoutDims[[i,2]]),
                    NonZeroIndices = Flatten@Position[Table[SameQ[y,0],{y,Flatten[final]}],False];
                  ];
                  If[ExtraUtils`EmptyQ[NonZeroIndices],
                    result={"NULL"};
                    ,
                    result=Table["p_"<>ToString@funcLists[[i]]<>"["<>ToString[j-1]<>"]="<>ToString[CForm@final[[1,j]]],{j,NonZeroIndices}];
                  ];
                ];
              ];
			    {vars,statement,result}
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
                 "namespace"->OptionValue[Namespace],
                 "behavior"->OptionValue[Behavior]|>;
		FileTemplateApply[tpl,assoc,cFile];
		If[OptionValue[ExportHeaderFile],
			FileTemplateApply[hdr,assoc,hFile];
		];
	];
Options[CseWriteCpp]={ExportDirectory->".",
                      ArgumentLists->{},
                      ArgumentDimensions->{},
                      SubstitutionRules->{},
                      TemplateFile->FileNameJoin[{DirectoryName[$InputFileName],"Template","template.cc"}],
                      TemplateHeader->FileNameJoin[{DirectoryName[$InputFileName],"Template","template.hh"}],
                      Namespace->"symbolic",
                      Behavior->"basic",
                      ExportHeaderFile->False,
                      ExportFull->True};
                      
                      
SyntaxInformation[ExportWithGradient]={"ArgumentsPattern"->{_,_,_}};
ExportWithGradient[name_,expr_,vars_]:=
Block[
	{gradExpr,fvars,fexprs,statesubs,gradStruct,nVar,nExpr,nzGrad,gradExprVec},
	(* Flatten input arguments *)
    fvars=Flatten[vars];
    fexprs=Flatten[expr];
    nVar=Length[fvars];
    nExpr=Length[fexprs];
    (* Compute the first order Jacobian *)
	gradExpr=Grad[fexprs,fvars];    
    
    (* setup the c++ export options *)
	statesubs=Dispatch@Join[((fvars[[#+1]]-> HoldForm@Global`var[[#]]&)/@(Range[nVar]-1))];
	SetOptions[CseWriteCpp,
		ArgumentLists->{Global`var},
		ArgumentDimensions-> {{nVar,1}},
		SubstitutionRules-> statesubs
	];
	(* Export expression *)
    CseWriteCpp["f_"<>name,{expr}];
    (* Compute sparsity structure of the first order jacobian: 1 if nonzero*)
    gradStruct=Boole@Table[!SameQ[gradExpr[[i,j]],0],{i,1,nExpr},{j,1,nVar}];
    (* Extract the nonzero entries of the first order jacobian, and vectorize it*)
    nzGrad=Position[gradStruct,1];
    gradExprVec=ExtraUtils`ToVectorForm[Extract[gradExpr,nzGrad]];
    (* Export the vectorized partial first order jacobian*)
	CseWriteCpp["J_"<>name,{gradExprVec},ExportFull->True];

    
    
    (* Export the sparsity structure of the first and second order jacobian*)
    SetOptions[CseWriteCpp,
		ArgumentLists->{Global`var},(*no input argument needed. Include a arbitray scaler input just for the correctness of the template.*)
		ArgumentDimensions-> {{1,1}}
	];
	CseWriteCpp["Js_"<>name,{nzGrad}];
];
ExportWithGradient[name_,expr_,vars_,consts_]:=
Block[
	{gradExpr,fvars,fexprs,statesubs,fconsts,gradStruct,nVar,nExpr,nzGrad,gradExprVec},
	(* Flatten input arguments *)
    fvars=Flatten[vars];
	fconsts=Flatten[consts];
    fexprs=Flatten[expr];
    nVar=Length[fvars];
    nExpr=Length[fexprs];
    (* Compute the first order Jacobian *)
	gradExpr=Grad[fexprs,fvars];    
   
    (* setup the c++ export options *)
	statesubs=Dispatch@Join[Flatten[{((fvars[[#+1]]-> HoldForm@Global`var[[#]]&)/@(Range[nVar]-1)),((fconsts[[#+1]]-> HoldForm@Global`auxdata[[#]]&)/@(Range[Length[fconsts]]-1))}]];
	SetOptions[CseWriteCpp,
		ArgumentLists->{Global`var,Global`auxdata},
		ArgumentDimensions-> {{nVar,1},{Length[fconsts],1}},
		SubstitutionRules-> statesubs
	];    
	(* Export expression *)
    CseWriteCpp["f_"<>name,{expr}];
    (* Compute sparsity structure of the first order jacobian: 1 if nonzero*)
    gradStruct=Boole@Table[!SameQ[gradExpr[[i,j]],0],{i,1,nExpr},{j,1,nVar}];
    (* Extract the nonzero entries of the first order jacobian, and vectorize it*)
    nzGrad=Position[gradStruct,1];
    gradExprVec=ExtraUtils`ToVectorForm[Extract[gradExpr,nzGrad]];
    (* Export the vectorized partial first order jacobian*)
	CseWriteCpp["J_"<>name,{gradExprVec},ExportFull->True];
    
    
    (* Export the sparsity structure of the first and second order jacobian*)
    SetOptions[CseWriteCpp,
		ArgumentLists->{Global`var},(*no input argument needed. Include a arbitray scaler input just for the correctness of the template.*)
		ArgumentDimensions-> {{1,1}}
	];
	CseWriteCpp["Js_"<>name,{nzGrad}];
];
     
     
SyntaxInformation[ExportWithHessian]={"ArgumentsPattern"->{_,_,_}};
ExportWithHessian[name_,expr_,vars_]:=
Block[
	{gradExpr,fvars,fexprs,statesubs,gradStruct,hessExprTensor,hessExpr,hessStruct,nVar,nExpr,nzGrad,nzHess,gradExprVec,hessExprVec,\[CapitalLambda]},
	(* Flatten input arguments *)
    fvars=Flatten[vars];
    fexprs=Flatten[expr];
    nVar=Length[fvars];
    nExpr=Length[fexprs];
    (* Compute the first order Jacobian *)
	gradExpr=Grad[fexprs,fvars];    
    (* Compute the second order Jacobian*)
    hessExprTensor=Table[Grad[gradExpr[[i,;;]],fvars],{i,1,nExpr}];
    
    (* setup the c++ export options *)
	statesubs=Dispatch@Join[((fvars[[#+1]]-> HoldForm@Global`var[[#]]&)/@(Range[nVar]-1))];
	SetOptions[CseWriteCpp,
		ArgumentLists->{Global`var},
		ArgumentDimensions-> {{nVar,1}},
		SubstitutionRules-> statesubs
	];
	(* Export expression *)
    CseWriteCpp["f_"<>name,{expr}];
    (* Compute sparsity structure of the first order jacobian: 1 if nonzero*)
    gradStruct=Boole@Table[!SameQ[gradExpr[[i,j]],0],{i,1,nExpr},{j,1,nVar}];
    (* Extract the nonzero entries of the first order jacobian, and vectorize it*)
    nzGrad=Position[gradStruct,1];
    gradExprVec=ExtraUtils`ToVectorForm[Extract[gradExpr,nzGrad]];
    (* Export the vectorized partial first order jacobian*)
	CseWriteCpp["J_"<>name,{gradExprVec},ExportFull->True];

    
    (* Compute the sparsity structure of the second order jacobian(hessian) *)
    hessStruct=Boole@Table[!SameQ[hessExprTensor[[i,j,k]],0],{i,1,nExpr},{j,nVar},{k,1,nVar}];
    (* Since the Hessian is symmetric matrix, only use the lower triangular part  *)
    hessExpr=Table[LowerTriangularize@hessStruct[[i,;;]],{i,nExpr}];
    (* Extract the nonzero entris of the second order jacobian, and vectorize it *)
    nzHess=Table[Position[hessExpr[[i,;;]],1],{i,nExpr}];
    \[CapitalLambda]=Flatten@Table[\[Lambda][i],{i,nExpr}];
    hessExprVec=Flatten@Table[\[CapitalLambda][[i]]*Extract[hessExprTensor[[i,;;]],nzHess[[i,;;]]],{i,nExpr}];
    statesubs=Dispatch@Join[Normal@statesubs,((\[CapitalLambda][[#+1]]-> HoldForm@Global`lambda[[#]]&)/@(Range[nExpr]-1))];
    SetOptions[CseWriteCpp,
		ArgumentLists->{Global`var,Global`lambda},(*no input argument needed. Include a arbitray scaler input just for the correctness of the template.*)
		ArgumentDimensions-> {{nVar,1},{nExpr,1}},
		SubstitutionRules-> statesubs
	];
    (* Export the vectorized partial second order jacobian*)
    CseWriteCpp["H_"<>name,{hessExprVec},ExportFull->True];
    (* Export the sparsity structure of the first and second order jacobian*)
    SetOptions[CseWriteCpp,
		ArgumentLists->{Global`var},(*no input argument needed. Include a arbitray scaler input just for the correctness of the template.*)
		ArgumentDimensions-> {{1,1}}
	];
	CseWriteCpp["Js_"<>name,{nzGrad}];
    CseWriteCpp["Hs_"<>name,{Catenate@nzHess}];
];
ExportWithHessian[name_,expr_,vars_,consts_]:=
Block[
	{gradExpr,fvars,fexprs,statesubs,fconsts,gradStruct,hessExpr,hessStruct,nVar,nExpr,hessExprTensor,nzGrad,nzHess,gradExprVec,hessExprVec,\[CapitalLambda]},
	(* Flatten input arguments *)
    fvars=Flatten[vars];
	fconsts=Flatten[consts];
    fexprs=Flatten[expr];
    nVar=Length[fvars];
    nExpr=Length[fexprs];
    (* Compute the first order Jacobian *)
	gradExpr=Grad[fexprs,fvars];    
    (* Compute the second order Jacobian*)
    hessExprTensor=Table[Grad[gradExpr[[i,;;]],fvars],{i,1,nExpr}];
    (* setup the c++ export options *)
	statesubs=Dispatch@Join[Flatten[{((fvars[[#+1]]-> HoldForm@Global`var[[#]]&)/@(Range[nVar]-1)),((fconsts[[#+1]]-> HoldForm@Global`auxdata[[#]]&)/@(Range[Length[fconsts]]-1))}]];
	SetOptions[CseWriteCpp,
		ArgumentLists->{Global`var,Global`auxdata},
		ArgumentDimensions-> {{nVar,1},{Length[fconsts],1}},
		SubstitutionRules-> statesubs
	];    
	(* Export expression *)
    CseWriteCpp["f_"<>name,{expr}];
    (* Compute sparsity structure of the first order jacobian: 1 if nonzero*)
    gradStruct=Boole@Table[!SameQ[gradExpr[[i,j]],0],{i,1,nExpr},{j,1,nVar}];
    (* Extract the nonzero entries of the first order jacobian, and vectorize it*)
    nzGrad=Position[gradStruct,1];
    gradExprVec=ExtraUtils`ToVectorForm[Extract[gradExpr,nzGrad]];
    (* Export the vectorized partial first order jacobian*)
	CseWriteCpp["J_"<>name,{gradExprVec},ExportFull->True];
    (* Compute the sparsity structure of the second order jacobian(hessian) *)
    hessStruct=Boole@Table[!SameQ[hessExprTensor[[i,j,k]],0],{i,1,nExpr},{j,nVar},{k,1,nVar}];
    (* Since the Hessian is symmetric matrix, only use the lower triangular part  *)
    hessExpr=Table[LowerTriangularize@hessStruct[[i,;;]],{i,nExpr}];
    (* Extract the nonzero entris of the second order jacobian, and vectorize it *)
    nzHess=Table[Position[hessExpr[[i,;;]],1],{i,nExpr}];
    \[CapitalLambda]=Flatten@Table[\[Lambda][i],{i,nExpr}];
    hessExprVec=Flatten@Table[\[CapitalLambda][[i]]*Extract[hessExprTensor[[i,;;]],nzHess[[i,;;]]],{i,nExpr}];
    statesubs=Dispatch@Join[Normal@statesubs,((\[CapitalLambda][[#+1]]-> HoldForm@Global`lambda[[#]]&)/@(Range[nExpr]-1))];
    SetOptions[CseWriteCpp,
		ArgumentLists->{Global`var,Global`lambda,Global`auxdata},(*no input argument needed. Include a arbitray scaler input just for the correctness of the template.*)
		ArgumentDimensions-> {{nVar,1},{nExpr,1},{Length[fconsts],1}},
		SubstitutionRules-> statesubs
	];
    (* Export the vectorized partial second order jacobian*)
    CseWriteCpp["H_"<>name,{hessExprVec},ExportFull->True];
    (* Export the sparsity structure of the first and second order jacobian*)
    SetOptions[CseWriteCpp,
		ArgumentLists->{Global`var},(*no input argument needed. Include a arbitray scaler input just for the correctness of the template.*)
		ArgumentDimensions-> {{1,1}}
	];
	CseWriteCpp["Js_"<>name,{nzGrad}];
    CseWriteCpp["Hs_"<>name,{Catenate@nzHess}];
];

                      
                      
End[]

EndPackage[]

