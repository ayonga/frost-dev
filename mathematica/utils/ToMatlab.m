(* ::Package:: *)

Needs["ExtraUtil`"];
Needs["CseOptimization`"];


BeginPackage["ToMatlab`"];

(****** ToMatlab.mth -- Mathematica expressions into Matlab form *************)

(*
May 17, 2016
ayonga - Added CseWriteMatlab[]
June 7, 2011
eacousineau - Modified to include WriteMatlabVar[] and WriteMatlabVarList[]
June 15, 2011
eacousineau - Fixed a bug concerning vertcat errors in Matlab due to binary/unary operators in Matlab and the Dot-Dot-Dot operator
September 3, 2012
eacousineau - Added Common Subexpression Elimination support to WriteMatlabVar[]
September 7, 2012
eacousineau - Added case for empty list expression, and ExtraUtils`EmptyQ[]
September 15, 2012
eacousineau - I had been using an old version of ToMatlabMod.m, had to find my version online:
	http://pastebin.com/TcjErHVT - I talked about the vertcat bug, but I'm not sure if I fixed it...

Consider just using CForm, replacing certain things ???

BUG: Can't seem to get the right pattern to override ToMatlab[_?RuleQ] for empty {}
Just doing a simple if
*)

(* 

ToMatlab[expr] 

Converts the expression expr into matlab syntax and
returns it as a String.

ToMatlab[expr, name] 

Returns an assignment of expr into name as a String. name can be also
a more complicated string, e.g.,

	ToMatlab[If[t,a,b],"function y=iffun(t,a,b)\ny"].

The special symbol Colon can be used to denote the matlab colon
operator :, and Colon[a,b] for a:b, Colon[a,b,c] for a:b:c.


WriteMatlab[expr, file]
WriteMatlab[expr, file, name] 

Writes the expr in matlab form into the given file. The second form
makes this an assignment into the variable name. Example:

	f = OpenWrite["file.m"]; 
	WriteMatlab[Cos[x]-x, f, y]; 
	Close[f];

The file argument can also be a String that gives the name of the
file:

	WriteMatlab[Cos[x]-x, "file.m", y]; 

achieves the same result as the previous example (but this limits one
expression per file).


PrintMatlab[expr]
PrintMatlab[expr, name] 

is like ToMatlab but instead of returning the String, it is printed on
the screen.


RulesToMatlab[rules] 

Where rules is the result from Solve or NSolve: converts the rules into
individual assignment statements.

*)

(* (C) 1997-1999 Harri Ojanen  
	harri.ojanen@iki.fi
	http://www.iki.fi/~harri.ojanen/ *)

ToMatlab::usage = 
"ToMatlab[expr]  converts the expression  expr  into matlab syntax and returns it as a String.
If expr satisfies RuleQ, then it will generate a series of assignments for the given rules.
ToMatlab[expr, name]  returns an assignment of  expr  into  name as a String. name can be also a more complicated string, e.g., ToMatlab[If[t,a,b],\"function y=iffun(t,a,b)\\ny\"].

The special symbol Colon can be used to denote the matlab colon operator :, and Colon[a,b] for a:b, Colon[a,b,c] for a:b:c.
See also  WriteMatlab  and  PrintMatlab.
All functions accept an optional last argument that is the maximum line width."

ToMatlabExpressionSet::usage =
"ToMatlabExpressionSet[exprSet, name]  Same as ToMatlab[expr, name], but exprSet is of form {rules, expr} which will generate a series of assignments for the rules and assign resulting expression to name.";

WriteMatlab::usage =
"WriteMatlab[expr, file]  or  WriteMatlab[expr, file, name] Writes the  expr  in matlab form into the given file. The second form makes this an assignment into the variable  name.\nExample: f = OpenWrite[\"file.m\"]; WriteMatlab[Cos[x]-x, f, y]; Close[f];\nThe file argument can also be a String that gives the name of the file: WriteMatlab[Cos[x]-x, \"file.m\", y]; achieves the same result as the previous example (but this limits one expression per file).\nSee also  ToMatlab  and  PrintMatlab."

PrintMatlab::usage =
"PrintMatlab[expr]  or  PrintMatlab[expr, name]  is like  ToMatlab but instead of returning the String, it is printed on the screen. See also  ToMatlab  and  WriteMatlab."

RulesToMatlab::usage =
"RulesToMatlab[rules] where rules is from Solve or NSolve converts the rules into individual assignment statements."

WriteMatlabFunction::usage =
"WriteMatlabVar[name, expr] writes expression  expr  to a matlab function file  <name>.m.

Options:
ExportDirectory -> output directory for file (default: '.')
Arguments -> arguments in MATLAB function, as symbols (default: {})
CheckArguments -> do not include arguments in function header if they are not in the expression (default: False)
PreStatement -> add additional statements before function body (like 'a = getrobotparameter(...)')
Formatter -> a pure function applied to expression before converting to MATLAB expression (default (#&))";

CseWriteMatlab::usage = "CseWriteMatlab[name, expr] optimizes the expression 'expr' compound expressions by 
eliminating common subexpressions, then convert them into MATLAB systax and write to matlab file.
Options:
ExportDirectory -> output directory for file (default: '.')
Arguments -> arguments in MATLAB function, as symbols (default: {})
SubstitutionRules -> A list of rules that substitute Mathmatica symbols with input arguments defined in ArgumentLists. It should have a 
                      a form of {X[[i,j]] -> x[i]}. For example, For a vector X with dimension n, the rule has to be defined as:
                      {X[[1,1]]->x[1],...,X[[n,1]]->x[n]}. For a scaler variable, please define as:
                      {A -> a}. If you have multiple substitution rules, they could be Join as one.
OptimizationLevel -> optimization level (0,1,2) for common subexpression elimination (default: 2)
PreStatement -> add additional statements before function body (like 'a = getrobotparameter(...)')";


(*SetMargin::usage = "SetMargin[margin]"
RestoreMargin::usage = "RestoreMargin[]"*)


Begin["`Private`"]


CseWriteMatlab[name_String,expr_,OptionsPattern[]]:=
	Block[{vexpr,vars,code,subCode,seq,final,body, file, args, argsString, outputName, extra,comment},
    vexpr=CseOptimization`ToVectorForm[expr/.OptionValue[SubstitutionRules]];
	{vars,code} = CseOptimization`CseOptimizeExpression[vexpr,OptimizationLevel->OptionValue[OptimizationLevel]];
	{vars,subCode} = CseOptimization`DeleteUnnecessoryExpr[CseOptimization`ConvertToRule[CseOptimization`ReplaceVariable[vars,code]]];
	seq = CseOptimization`GetSequenceExprMatlab[subCode];
	final = CseOptimization`GetFinalExprMatlab[subCode];

	outputName = "x_" <> name;
	file = FileNameJoin[{OptionValue[ExportDirectory], name <> ".m"}];
	extra = (If[# != "", # <> "\n", ""] &) @ OptionValue[PreStatement];
	args = OptionValue[Arguments];
	argsString = StringJoin[Riffle[ToString /@ args, ", "]];
	comment = "%"<>name<>"\n%    "<>outputName<>" = "<>name<>"("<>argsString <> ")\n\n"<>
		"% This function was generated by Mathematica Common \n% Subexpression Eliminating Package (CseOptimization)\n% " <> DateString[];
	body = "function [" <> outputName <> "] = " <> name <> "(" <> argsString <> ")\n" <> comment <>"\n\n"<> extra <> RulesToMatlab[List[seq]]<>
		outputName<>"="<>ToString[ToMatlab[final]]<>"\nend %function";
	Block[{f = OpenWrite[file]},
		WriteString[f, body];
		Close[f];
	];
];

Options[CseWriteMatlab]={ExportDirectory->".",Arguments->{},SubstitutionRules->{},OptimizationLevel->2,PreStatement->""};	



WriteMatlab[e_, file_OutputStream, margin_Integer:72] :=
    (WriteString[file, ToMatlab[e, margin]];)

WriteMatlab[e_, file_OutputStream, name_, margin_Integer:72] :=
    WriteString[file, ToMatlab[e, name, margin]];

WriteMatlab[e_, file_String, margin_Integer:72] :=
Block[{f = OpenWrite[file]},
	WriteMatlab[e, f, margin];
	Close[f];
];

WriteMatlab[e_, file_String, name_, margin_Integer:72] :=
Block[{f = OpenWrite[file]},
	WriteMatlab[e, f, name, margin];
	Close[f];
];


(*Custom stuff*)
(*Maybe: Allow args be specified by rule, Symbol->"var_name"*)
WriteMatlabFunction[name_String, var_, OptionsPattern[]] := Module[
	{expr, body, file, argsInput, args, argsString, outputName, extra}, 
	expr = OptionValue[Formatter] /@ var;
	outputName = "x_" <> name;
	file = FileNameJoin[{OptionValue[ExportDirectory], name <> ".m"}];
	extra = (If[# != "", # <> "\n", ""] &) @ OptionValue[PreStatement];
	argsInput = OptionValue[Arguments];
	(*Select only the symbols that are present in the expression*)
	(*Instead, should select up to that symbol?*)
	args = If[OptionValue[CheckArguments], 
		Select[argsInput, Position[expr, #, Infinity, 1] != {} &] , 
		argsInput
	];
	argsString = StringJoin[Riffle[ToString /@ args, ", "]];
	body = "function [" <> outputName <> "] = " <> name <> "(" <> argsString <> ")\n" <> extra <> ToMatlab[expr, outputName];
	Block[{f = OpenWrite[file]},
		WriteString[f, body];
		Close[f];
	];
];

Options[WriteMatlabFunction]={ExportDirectory->".",Arguments->{},Formatter->(#&),PreStatement->"",CheckArguments->False};


PrintMatlab[e_] := 
    (Print[ToMatlab[e, 60]];)

PrintMatlab[e_, name_] := 
    (Print[ToMatlab[e, name, 60]];)	    /; (!NumberQ[name])

PrintMatlab[e_, margin_Integer] := 
    (Print[ToMatlab[e, margin]];)

PrintMatlab[e_, name_, margin_Integer] := 
    (Print[ToMatlab[e, name, margin]];)


ToMatlab[e_] := foldlines[ToMatlabaux[e] <> ";\n"]

ToMatlab[e_?ExtraUtils`EmptyQ] := foldlines["[];\n"];

(* This might be a duplicate of RulesToMatlab, but oh well *)
(* Have to override this to get ExtraUtils`EmptyQ rule to actually work *)
ToMatlab[rules_?ExtraUtil`RuleQ] :=
Module[{},
	If[ExtraUtils`EmptyQ[rules],
		foldlines[ToMatlabaux[{}] <> ";\n"]
	,
		StringJoin[Table[ToMatlab[rule[[2]], rule[[1]]], {rule, rules}]]
	]
]

ToMatlab[exprSet:{rules_,expr_}?ExtraUtil`ExpressionSetQ, name_ /; !NumberQ[name]] :=
	StringJoin[{ToMatlab[rules], ToMatlab[expr, name]}];

ToMatlab[e_, name_ /; !NumberQ[name]] :=
    ToMatlabaux[name] <> "=" <> ToMatlab[e];

ToMatlab[e_, margin_Integer] :=
    Block[{s},
	SetMargin[margin];
	s = ToMatlab[e];
	RestoreMargin[];
	s]

ToMatlab[e_, name_ /; !NumberQ[name], margin_Integer] :=
    Block[{s},
	SetMargin[margin];
	s = ToMatlab[e, name];
	RestoreMargin[];
	s]


RulesToMatlab[l_List] :=
    If[Length[l] === 0,
	"",
	Block[{s = RulesToMatlab[ l[[1]] ]},
	    Do[s = s <> RulesToMatlab[ l[[i]] ], {i, 2, Length[l]}];
	    s]]

RulesToMatlab[Rule[x_, a_]]:=
	ToMatlab[a, ToMatlab[x] // StringDrop[#, -2]&] 

(*** Numbers and strings *****************************************************)

ToMatlabaux[x_?ExtraUtils`EmptyQ] := "[]"

ToMatlabaux[s_String] := s

ToMatlabaux[n_Integer] :=
    If[n >= 0, ToString[n], "(" <> ToString[n] <> ")"]

(*ToMatlabaux[r_Rational] := 
    "(" <> ToMatlabaux[Numerator[r]] <> "/" <>
           ToMatlabaux[Denominator[r]] <> ")"*)

ToMatlabaux[r_Rational] := 
    "(" <> ToString[Numerator[r]] <> "/" <>
           ToString[Denominator[r]] <> ")"

ToMatlabaux[r_Real] := 
    Block[{str},
    	str = StringReplace[ToString[r, InputForm], "*^" -> "e"];
        If[r >= 0,
            str
        ,
            "(" <> str <> ")"
        ]
    ]

(*
ToMatlabaux[r_Real] := 
    Block[{a = MantissaExponent[r]},
        If[r >= 0,
            ToString[N[a[[1]],18]] <> "e" <> ToString[a[[2]]],
            "(" <> ToString[N[a[[1]],18]] <> "e" <> ToString[a[[2]]] <> ")"]]
*)

ToMatlabaux[I] := "sqrt(-1)";

ToMatlabaux[c_Complex] :=
    "(" <>
    If[Re[c] === 0,
        "",
        ToMatlabaux[Re[c]] <> "+"] <>
    If[Im[c] === 1,
        "sqrt(-1)",
        "sqrt(-1)*" <> ToMatlabaux[Im[c]] ] <> ")"


(*** Lists, vectors and matrices *********************************************)

numberMatrixQ[m_] := MatrixQ[m] && (And @@ Map[numberListQ,m])

numberListQ[l_] := ListQ[l] && (And @@ Map[NumberQ,l])

numbermatrixToMatlab[m_] :=
    Block[{i, s=""}, 
	For[i=1, i<=Length[m], i++,
	    s = s <> numbermatrixrow[m[[i]]];    
	    If[i < Length[m], s = s <> ";"]];
	s]

numbermatrixrow[l_] :=
    Block[{i, s=""},
	For[i=1, i<=Length[l], i++, 
	    s = s <> ToMatlabaux[l[[i]]];
	    If[i < Length[l], s = s <> ","]];
	s]

ToMatlabaux[l_List /; MatrixQ[l]] :=
    If[numberMatrixQ[l],
	"[" <> numbermatrixToMatlab[l] <> "]",
	"[" <> matrixToMatlab[l] <> "]"]

matrixToMatlab[m_] :=
    If[Length[m] === 1, 
        ToMatlabargs[m[[1]]],
        ToMatlabargs[m[[1]]] <> ";" <>
            matrixToMatlab[ argslistdrop[m] ] ]

ToMatlabaux[l_List] := "[" <> ToMatlabargs[l] <> "]"


(*** Symbols *****************************************************************)
(***Changed ArcTan from atan to atan2***)

ToMatlabaux[Colon] = ":"
ToMatlabaux[Abs] = "abs"
ToMatlabaux[Min] = "min"
ToMatlabaux[Max] = "max"
ToMatlabaux[Sin] = "sin"
ToMatlabaux[Cos] = "cos"
ToMatlabaux[Tan] = "tan"
ToMatlabaux[Cot] = "cot"
ToMatlabaux[Csc] = "csc"
ToMatlabaux[Sec] = "sec"
ToMatlabaux[ArcSin] = "asin"
ToMatlabaux[ArcCos] = "acos"
ToMatlabaux[ArcTan] = "atan2"
ToMatlabaux[ArcCot] = "acot"
ToMatlabaux[ArcCsc] = "acsc"
ToMatlabaux[ArcSec] = "asec"
ToMatlabaux[Sinh] := "sinh"
ToMatlabaux[Cosh] := "cosh"
ToMatlabaux[Tanh] := "tanh"
ToMatlabaux[Coth] := "coth"
ToMatlabaux[Csch] := "csch"
ToMatlabaux[Sech] := "sech"
ToMatlabaux[ArcSinh] := "asinh"
ToMatlabaux[ArcCosh] := "acosh"
ToMatlabaux[ArcTanh] := "atanh"
ToMatlabaux[ArcCoth] := "acoth"
ToMatlabaux[ArcCsch] := "acsch"
ToMatlabaux[ArcSech] := "asech"
ToMatlabaux[Log] := "log"
ToMatlabaux[Exp] := "exp"
ToMatlabaux[MatrixExp] := "expm"
ToMatlabaux[Pi] := "pi"
ToMatlabaux[E] := "exp(1)"
ToMatlabaux[True] := "true"
ToMatlabaux[False] := "false"

ToMatlabaux[e_Symbol] := ToString[e]


(*** Relational operators ****************************************************)

ToMatlabaux[e_ /; Head[e] === Equal] :=
    ToMatlabrelop[ argslist[e], "=="]
ToMatlabaux[e_ /; Head[e] === Unequal] :=
    ToMatlabrelop[ argslist[e], "~="]
ToMatlabaux[e_ /; Head[e] === Less] :=
    ToMatlabrelop[ argslist[e], "<"]
ToMatlabaux[e_ /; Head[e] === Greater] :=
    ToMatlabrelop[ argslist[e], ">"]
ToMatlabaux[e_ /; Head[e] === LessEqual] :=
    ToMatlabrelop[ argslist[e], "<="]
ToMatlabaux[e_ /; Head[e] === GreaterEqual] :=
    ToMatlabrelop[ argslist[e], ">="]
ToMatlabaux[e_ /; Head[e] === And] :=
    ToMatlabrelop[ argslist[e], "&"]
ToMatlabaux[e_ /; Head[e] === Or] :=
    ToMatlabrelop[ argslist[e], "|"]
ToMatlabaux[e_ /; Head[e] === Not] :=
    "~(" <> ToMatlabaux[e[[1]]] <> ")"

ToMatlabrelop[e_, o_] :=
    If[Length[e] === 1, 
        "(" <> ToMatlabaux[e[[1]]] <> ")",
        "(" <> ToMatlabaux[e[[1]]] <> ") " <> o <> " " <>
         ToMatlabrelop[ argslistdrop[e], o] ]

relopQ[e_] := MemberQ[{Equal, Unequal, Less, Greater, LessEqual,
    GreaterEqual, And, Or, Not}, Head[e]]


(*** Addition, multiplication and powers *************************************)

ToMatlabaux[e_ /; Head[e] === Plus] :=
    If[relopQ[e[[1]]],
        "(" <> ToMatlabaux[e[[1]]] <> ")",
        ToMatlabaux[e[[1]]] ] <>
    " + " <>
        If[Length[e] === 2,
            If[relopQ[e[[2]]],
                "(" <> ToMatlabaux[e[[2]]] <> ")",
                ToMatlabaux[e[[2]]] ],
            ToMatlabaux[ dropfirst[e] ]]

ToMatlabaux[e_ /; Head[e] === Times] :=
    If[Head[e[[1]]] === Plus,
        "(" <> ToMatlabaux[e[[1]]] <> ")",
        ToMatlabaux[e[[1]]] ] <>
    ".*" <>
        If[Length[e] === 2,
            If[Head[e[[2]]] === Plus,
                "(" <> ToMatlabaux[e[[2]]] <> ")",
                ToMatlabaux[e[[2]]] ],
            ToMatlabaux[ dropfirst[e] ]]

ToMatlabaux[e_ /; Head[e] === Power] :=
    If[Head[e[[1]]] === Plus || Head[e[[1]]] === Times || Head[e[[1]]] === Power,
        "(" <> ToMatlabaux[e[[1]]] <> ")",
        ToMatlabaux[e[[1]]] ] <>
    ".^" <>
        If[Length[e] === 2,
            If[Head[e[[2]]] === Plus || Head[e[[2]]] === Times || Head[e[[2]]] === Power,
                "(" <> ToMatlabaux[e[[2]]] <> ")",
                ToMatlabaux[e[[2]]] ],
            ToMatlabaux[ dropfirst[e] ]]


(*** Special cases of functions **********************************************)

ToMatlabaux[Rule[_,r_]] := ToMatlabaux[r]

ToMatlabaux[Log[10, z_]] := "log10(" <> ToMatlabaux[z] <> ")"
ToMatlabaux[Log[b_, z_]] :=
    "log(" <> ToMatlabaux[z] <> ")./log(" <> ToMatlabaux[b] <> ")"

ToMatlabaux[Power[e_, 1/2]] := "sqrt(" <> ToMatlabaux[e] <> ")"
ToMatlabaux[Power[E, z_]] := "exp(" <> ToMatlabaux[z] <> ")"

ToMatlabaux[If[test_, t_, f_]] :=
    Block[{teststr = ToMatlabaux[test]},
        "((" <> teststr <> ").*(" <> ToMatlabaux[t] <> ")+(~("
             <> teststr <> ")).*(" <> ToMatlabaux[f] <> "))"]

ToMatlabaux[e__ /; (Head[e] === Max || Head[e] == Min)] :=
    ToMatlabaux[Head[e]] <> "(" <>
        If[ Length[e] === 2,
            ToMatlabargs[e] <> ")",
            ToMatlabaux[e[[1]]] <> "," <> ToMatlabaux[dropfirst[e]] <> ")"]

ToMatlabaux[Colon[a_,b_]] :=
    "((" <> ToMatlabaux[a] <> "):(" <> ToMatlabaux[b] <> "))"
(*Is this correct? *)
ToMatlabaux[Colon[a_,b_,c_]] :=
    "((" <> ToMatlabaux[a] <> "):(" <> ToMatlabaux[b] <> 
        "):(" <> ToMatlabaux[c] <> "))"


(*** General functions *******************************************************)

ToMatlabaux[e_] :=
    ToMatlabaux[Head[e]] <> "(" <>
        ToMatlabargs[ argslist[e] ] <> ")"

ToMatlabargs[e_] :=
    If[Length[e] === 1, 
        ToMatlabaux[e[[1]]],
        ToMatlabaux[e[[1]]] <> "," <>
            ToMatlabargs[ argslistdrop[e] ] ]


(*** Argument lists **********************************************************)

(*** argslist returns a List of the arguments ***)
argslist[e_] :=
    Block[{ARGSLISTINDEX}, Table[ e[[ARGSLISTINDEX]],
        {ARGSLISTINDEX, 1, Length[e]}]]

(*** argslistdrop returns a List of all arguments except the first one ***)
argslistdrop[e_] :=
    Block[{ARGSLISTINDEX}, Table[ e[[ARGSLISTINDEX]], 
        {ARGSLISTINDEX, 2, Length[e]}]]

(*** dropfirst is like argslistdrop but retains the original Head ***)
dropfirst[e_] :=
    e[[ Block[{i}, Table[i, {i,2,Length[e]}]] ]]


(*** Folding long lines ******************************************************)

(*Bug: Need to make sure that this doesn't fold line before operator with spaces - for matrices*)
MARGIN = 66
MARGINS = {}

SetMargin[m_] := (MARGINS = Prepend[MARGINS, MARGIN]; MARGIN = m; MARGINS)

RestoreMargin[] := 
    If[Length[MARGINS] > 0,
	MARGIN = MARGINS[[1]];
	MARGINS = Drop[MARGINS, 1]]		

foldlines[s_String] :=
    Block[{cut, sin=s, sout=""},
	While[StringLength[sin] >= MARGIN, 
	    cut = findcut[sin];
	    If[cut > 0,		
		sout = sout <> StringTake[sin,cut] <> " ...\n  ";
		sin = StringDrop[sin,cut],
		(* else *)
		sout = sout <> StringTake[sin,MARGIN];
		sin = StringDrop[sin,MARGIN]]];
	sout <> sin]

findcut[s_String] :=
    Block[{i=MARGIN}, 
        While[i > 0 &&
              !MemberQ[{";", ",", "(", ")", "+", "*", " "}, StringTake[s,{i}]],
            i--];
        i]

End[]

EndPackage[]




