(* ::Package:: *)

(*
Provide common functionality
*)


BeginPackage["ExtraUtil`"];


(* Moved from AmberShared package 05/17/2016 Ayonga Hereid*)

ParallelSimplify::usage="Simplifies a matrix or vector in parallel.";

ParallelFullSimplify::usage="Fully simplifies a matrix or vector in parallel.";

J::usage="Computes the Jacobian of a quantity with respect to the given coordinates.";

Lie::usage="Computes the Lie derivative of the passed quantity with respect to the passed vector field in the passed coordinates.";

CrossProd::usage="Extracts the cross product vector form which is dual to the passed skew-symmetric matrix.";

Vec::usage="Vec[x]  Turn arbitrary list into vector";

ToExpressionEx::usage="ToExpressionEx[expr]  loosely converts any string types in an 0- to n-dimensional list to an expression.";

RationalizeEx::usage="RationalizeEx[expr]  loosely rationalize any expression to an arbitrary precision";

RationalizeAny::usage="RationalizeAny[value]  convert `value` to an expression and use RationalizeEx";

BlockDiagonalMatrix::usage="Create block diagonal matrx.";

EnsureDirectoryExists::usage="Ensure directory exists, if not create one.";

CRoundEx::usage="For eliminating those pesky small numbers in rotation matrices";


EmptyQ::usage =
"EmptyQ[x]  Expression is a list that, when flattened, has no elements.";

SymbolQ::usage =
"SymbolQ[expr]  determines if an expression is a symbol";

GetTopSymbol::usage =
"GetTopSymbol[expr]  gets the top level symbol for a given expression. May return a primitive symbol type, or the function that is being called";

GetAllSymbols::usage =
"GetAllSymbols[expr]  gets all symbols used in an expression";

PseudoSplice::usage =
"PsuedoSplice[body, subs]  takes subs as form {'a'->'b', ...} and replaces '@a@' with 'b', somewhat like Splice";

SprintF::usage =
"SprintF[format, args ...]  shortened version of StringForm that returns a string";

FoldMod::usage =
"FoldMod[f, list]  simply starts folding with f[list[[1]], list[[2]]] and so on";
StringImplode::usage = "
StringImplode[list, delim = '', format = '``']  joins list of strings with  delim  and formats each arg with format";


ExpressionSetQ::usage = "ExpressionSetQ[expr]  Returns whether an expression is of the form {rules, expr}.
Useful for checking if an expression use returned by CSE.";


ContextChange::usage =
"ContextChange[expr, from, to : \"\"
Evaluates expr from another context, changes it into a string, replaces any occurences
of another context  from  with  to. Be sure to include the `!";

ContextChangeRule::usage =
"This works sometimes... Maybe only when context is Global` ????

ContextChange[from, to:Context[]]  For testing against results in different notebooks.
Returns rule pattern that changes context from  from  to  to.
Useful if you change default Notebook context - Evaluation > Notebook's Default Context > Other...
If you have subscripts, you will need to use those when referring to them, i.e.
\!\(\*SubscriptBox[\(GlobalA`y\), \(GlobalA`a, 1\)]\)/.ContextChange[\"GlobalA`\"].";


(* Put the basic functions into a util *)
Linearize::usage = "Linearize[f, x, x0] gives a first-order linearization of  f  with respect to  x  around  x0";

ContextAlias::usage =
"ContextAlias[vars, context]  If you're lazy and are using symbols from another package, you can alias / import them in your package.
NOTE: ONLY call this in your package's Private context! Otherwise you will get shadowing issues.";

(*FileNameJoinTree::usage =
"FileNameJoinTree[list]  makes a list of directories by recursing through each element of a list.";
*)

RuleQ::usage = 
  "RuleQ[expr]  return whether an expression is a rule / rule list. \
Useful for GetField[]";


JoinTo::usage = "JoinTo[list, items...]  Same as  list = Join[list, items...]";

GetFieldIndex::usage = "GetFieldIndex[obj, field]  returns index of a field in a struct.
GetFieldIndex[obj, fields]  returns indices of given fields in a struct";
GetFields::usage = "GetFields[obj, field, [default]]  returns value of a field given a struct obj, or  default  ($Failed if not specified) if it does not exist
GetFields[obj, fields_List], GetFields[objs_?StructListQ, field], GetFields[objs_?StructListQ, fields]

No GetField[] because SetField[] is defined in JLink`. I hate Mathematica.";
GetListFields::usage = "GetListFields[objs, field[s], [default]]  returns a set of fields for a given set of objects";

SetFields::usage = "SetFields[obj, field, value]  sets value of a field given a struct obj
SetFields[obj, rules_?StructQ]

No SetField[] because SetField[] is defined in JLink`. I hate Mathematica.";
SetListFields::usage = "SetListFields[objs, fields, rules] ...";
SetReplaceFields::usage = "SetReplaceFields[obj, fields]  Same as SetFields[], but errors out if a field is not present";
ReplaceFields::usage = "ReplaceFields[obj, fields]  Same as SetReplaceFields[], but returns a new copy and does not modify original";

FieldQ::usage = "FieldQ[obj, field]  See if a  field  is part of an  obj.";
StructQ::usage = "StructQ[obj]  If it's a struct";
StructListQ::usage = "StructListQ[objs]  If it's a list of structs";

FindFirst::usage = "FindFirst[obj, pattern]  returns index of first pattern matching in list only in the first level.";
FindFirstByField::usage = "FindFirstByField[objs_?StructListQ, field, value]  return index of first struct with field value";
FieldNames::usage = "FieldNames[obj]  get field names for a given struct";

SetFieldsFunc::usage = "SetFieldsFunc[obj[s], func [, fields]]  Set the values of given fields with a function that takes in the original value.
If no fields are supplied, will set all fields. Can take a list of objects";
RuleReverse::usage = "RuleReverse[rules]  Reverse top-level list of rules from pattern {a -> b} to {b -> a}";
(* Could use Replace[rules, (a_ -> b_) :> (b -> a), 1] *)

(*RationalizeEx::usage =
"";
RatExpress::usage = "";
(* Add from ModelBuilder later *)*)


Begin["`Private`"];

(* Algebra *)
Linearize[f_?VectorQ,x_?VectorQ,x0_?VectorQ]:=Module[{subs,f0,Jf0,dx,count},
	count=Length[x];
	subs=Table[x[[i]]->x0[[i]],{i,count}];
	f0=f/.subs;
	Jf0=D[f,{x}]/.subs;
	dx=Transpose[{x-x0}];
	Flatten[f0+Jf0.dx]
];
Linearize[f_/;!ListQ[f],args__]:=Module[{expr},
	expr=Linearize[{f},args];
	expr[[1]]
];

(* This is not great. Copy util/matlab/generateDirTree.m *)
(*FileNameJoinTree[tree_List] := Module[{newTree, pathCombos, pathLists, paths},
   newTree = 
    Table[If[StringQ[branch], {branch}, branch], {branch, tree}]; (* 
   Wrap all as lists *)
   pathCombos = Outer @@ Join[{List}, newTree];
   pathLists = Flatten[pathCombos, Length[Dimensions[pathCombos]] - 2];
   paths = Map[FileNameJoin, pathLists];
   Return[paths];
];
*)


ContextAlias[vars_List, fromContext_:"ExtraUtil`"] := Module[{},
	If[Context[] == "Global`", Throw["This should not be called in notebook context - shadowing issues. Should only be called privately."]];
	Table[
		ToExpression[var <> " = " <> fromContext <> var]
		, {var, vars}
	]
];


FindFirst[list_List, pattern_] :=
Module[{res},
	res = Flatten[Position[list, pattern, 1]];
	Return[If[Length[res] > 0, First[res], $Failed]];
];

FindFirstByField[list_?StructListQ, field_, pattern_] :=
	FindFirst[GetListFields[list, field], pattern];

FieldRule[field_] := field -> _;

GetFieldIndex[obj_?StructQ, field_] := \
	FindFirst[obj, FieldRule[field]];
GetFieldIndex[obj_?StructQ, fields_List] := \
	Table[GetFieldIndex[obj, field], {field, fields}];
  
FieldQ[obj_?StructQ, field_] := NumberQ[GetFieldIndex[obj, field]];

FieldNames[obj_?StructQ] := obj[[;;, 1]];

(* How to handle failure if given an empty list?
It will automatically match to StructQ, so it would not be good practice to just give an empty...
Maybe it's best to have a GetListFields[] function... Yep.
*)

GetFields[obj_?StructQ, field_, default_:$Failed] :=
Module[{index},
	index = GetFieldIndex[obj, field];
	If[SameQ[index, $Failed],
		Return[default];
	,
		(* How to return a reference? *)
		Return[obj[[index, 2]]];
	];
];
GetFields[obj_?StructQ, fields_?ListQ, default_:$Failed] :=
	Table[GetFields[obj, field, default], {field, fields}];
SetAttributes[GetFields, HoldFirst];

GetListFields[list_?StructListQ, fieldOrFields_, default_:$Failed]:=
	Table[GetFields[struct, fieldOrFields, default], {struct, list}];
SetAttributes[GetListFields, HoldFirst];

SetFields[obj_?StructQ, field_, value_] :=
Module[{index},
	index = GetFieldIndex[obj, field];
	If[SameQ[index, $Failed],
		AppendTo[obj, field -> value];
	,
		obj[[index, 2]] = value;
	];
];
SetFields[obj_?StructQ, rules_?StructQ] :=
	Do[SetFields[obj, rule[[1]], rule[[2]]], {rule, rules}];
SetFields[obj_?StructQ, rules_?StructQ] :=
	Do[SetFields[obj, rule[[1]], rule[[2]]], {rule, rules}];
SetAttributes[SetFields, HoldFirst];

SetReplaceFields[obj_?StructQ, rules_?StructQ] :=
Module[{fields, indices, badIndices, values},
	fields = FieldNames[rules];
	indices = GetFieldIndex[obj, fields];
	badIndices = Flatten@Position[indices, $Failed];
	If[badIndices =!= {},
		Throw["Fields not present in object: ", fields[[badIndices]]];
	];
	values = rules[[;;, 2]];
	obj[[indices, 2]] = values;
];	
SetAttributes[SetReplaceFields, HoldFirst];

ReplaceFields[objTemp_?StructQ, rules_?StructQ] :=
Module[{obj},
	obj = objTemp;
	SetReplaceFields[obj, rules];
	Return[obj];
];
(* This does not update values, but returns a copy*)
	
SetListFields[objs_?StructListQ, field_, valuesTemp_List] :=
Module[{count, temp},
	values = valuesTemp; (* For copying and not assigning to list *)
	count = Length[objs];
	valueCount = Length[values];
	If[valueCount == 1,
		values = Table[values[[1]], {i, count}];
	,
		If[count != valueCount,	Throw@"Must have same number of values as objects"];
	];
	Do[SetFields[objs[[i]], field, values[[i]]], {i, count}];
];
SetListFields[objs_?StructListQ, rules_?StructQ] :=
	Do[SetFields[obj, rules], {obj, objs}];
SetListFields[objs_?StructListQ, rulesList_?StructListQ] :=
Module[{count},
	count = Length[objs];
	Assert[count == Length[rulesList], "Must have same number of setting structs as objects"];
	Do[SetFields[objs[[i]], rulesList[[i]]], {i, count}];
];
SetAttributes[SetListFields, HoldFirst];


ExpressionSetQ[expr_] := ListQ[expr] && Length[expr] == 2 && RuleQ[expr[[1]]] && !RuleQ[expr[[2]]];



(* Helpers *)
AllHeadQ[list_List,head_] := And@@Map[Head[#] === head&, list];

RuleQ[x_] := False;
RuleQ[rule_Rule] := True;
RuleQ[{}] := True; (* An empty list can be a Rule set... *)

RuleQ[rules_List] := AllHeadQ[rules, Rule];

StructQ[x_] := False;
StructQ[rules_List?RuleQ] := True;
StructListQ[x_] := False;
StructListQ[structs_List] := And@@Map[StructQ, structs];


RuleReverse[rule_Rule] := rule[[2]] -> rule[[1]];
RuleReverse[rules_List] := Map[RuleReverse, rules];


(* For some reason won't work with list_List, only with list_?ListQ *)
JoinTo[list_?ListQ, items__] := list = Join[list, items];
SetAttributes[JoinTo, HoldFirst];


SetFieldsFunc[obj_?StructQ, f_] :=
Module[{},
	obj[[;;, 2]] = Map[f, obj[[;;, 2]]];
];
(* Have to use indices to preserve reference
Probably because of the chain of iterators used in Do[] / Table[] *)
SetFieldsFunc[obj_?StructQ, f_, fields_List] :=
Module[{indices},
	indices = GetFieldIndex[obj, fields];
	obj[[indices, 2]] = Map[f, obj[[indices, 2]]];
];
(*
SetFieldsFunc[objs_?StructListQ, f_] :=
	Do[SetFieldsFunc[objs[[i]], f], {i, Length[objs]}];
SetFieldsFunc[objs_?StructListQ, f_, fields_List] :=
	Do[SetFieldsFunc[objs[[i]], f, fields], {i, Length[objs]}];
*)

SetAttributes[SetFieldsFunc, HoldFirst];


ContextChange[expr_, from_String, to_String:""] :=
Module[{},
	ToExpression@StringReplace[ToString[expr, InputForm], from -> to]
];

(* For testing against different notebooks *)
(* This only seems to work sometimes... *)
ContextChangeRule[from_,toRaw_:""]:=
Module[{to, sub},
	to=If[toRaw=="",Context[],to];
	Return[
		(*Weird crap with contexts and patterns. Obfuscate var name, don't use q, makes for problems *)
		(q12345_:> ToExpression[to<>Last[StringSplit[ToString[q12345],"`"]]] /; SymbolQ[q12345]&&Context[q12345]==from )
	];
];


EmptyQ[x_List]:=ListQ[x]&&Length[Flatten[x]]==0;

SymbolQ[expr_Symbol] := True;
SymbolQ[expr_] := False;

GetTopSymbol[expr_] :=
Module[{head = expr, done = False},
   While[! done,
    If[AtomQ[head],
      If[SymbolQ[head],
       Return[head],
       done = True;
       head = {};
       ]
      ,
      head = Head[head];
      ];
    ];
   Return[head];
   ];

GetAllSymbols[expr_] :=
Module[{pieces, symbols},
   pieces = Level[expr, {0, Infinity}];
   symbols = DeleteCases[
     Union[
      Table[GetTopSymbol[piece], {piece, pieces}]
      ], {}];
   Return[symbols];
   ];

FoldMod[f_, list_] := Fold[f, list[[1]], list[[2 ;;]]];

StringImplode[list_, delim_: "", format_: "``"] := 
  StringJoin[
    Riffle[Table[SprintF[format, item], {item, list}], delim]
  ];

SprintF[args__] := ToString[StringForm[args]];
(*Subtract 1 from indices to go from 1..n to 0..n-1*)

PseudoSplice[body_, subs_] := 
  StringReplace[body, 
   Table["@" <> sub[[1]] <> "@" -> sub[[2]], {sub, subs}]
  ];


(* ::Section:: *)
(*AmberShared Package*)


J[h_,x_]:=D[Flatten[h],{Flatten[x]}]
Lie[h_,x_,f_]:=J[h,x].f
CrossProd[\[CapitalOmega]_?MatrixQ]:={\[CapitalOmega][[3,2]],\[CapitalOmega][[1,3]],\[CapitalOmega][[2,1]]};
Vec[x_]:=Transpose[{Flatten[x]}];


ToExpressionEx[value_]:=Module[{result},result=If[StringQ[value],ToExpression[value],If[ListQ[value],Map[If[StringQ[#],ToExpression[#],#]&,value,-1],value]];
Return[result];];
RationalizeEx[expr_]:=Rationalize[expr,0];
RationalizeEx[expr_List]:=Map[RationalizeEx,expr,-1];
RationalizeAny[expr_]:=RationalizeEx[ToExpressionEx[expr]];


ParallelSimplify[A_?MatrixQ]:=ParallelTable[Simplify[A[[i,j]]],{i,Dimensions[A][[1]]},{j,Dimensions[A][[2]]}]
ParallelSimplify[A_?VectorQ]:=ParallelTable[Simplify[A[[i]]],{i,Length[A]}]
ParallelSimplify[A_]:=Simplify[A]

ParallelFullSimplify[A_?MatrixQ]:=ParallelTable[FullSimplify[A[[i,j]]],{i,Dimensions[A][[1]]},{j,Dimensions[A][[2]]}]
ParallelFullSimplify[A_?VectorQ]:=ParallelTable[FullSimplify[A[[i]]],{i,Length[A]}]
ParallelFullSimplify[A_]:=FullSimplify[A]


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


End[];


EndPackage[];
