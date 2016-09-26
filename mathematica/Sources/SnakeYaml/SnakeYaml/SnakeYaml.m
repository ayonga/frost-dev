(* ::Package:: *)

BeginPackage["SnakeYaml`"];


(*
\file SnakeYaml.m
\brief Simple YAML Reader, using SnakeYAML
\author Eric Cousineau (AMBER Lab)

Derived from / inspired by yamlmatlab: \
http://code.google.com/p/yamlmatlab/

TODO: Figure out how to correctly export integers.
*)

YamlInit::usage = "YamlInit[yamlClassPath]  initialize YAML setup.
  yamlClassPath - This will be the path to the SnakeYAML JAR file. Will use default if not specified.";

YamlRead::usage = 
  "YamlRead[text]  read YAML structure from 'text' and return result.
  Maps / structures are represented as {field -> value}. Use \
GetField[] helper to navigate them.
  NOTE: This can handle basic types, but more advanced functionality \
might not be supported. Be wary!";

YamlReadFile::usage = 
  "YamlReadFile[file]  reads content of file and passes it to \
YamlRead[]:\n\n" <> YamlRead::usage;

YamlWrite::usage =
"YamlWrite[obj]  write Mathematica object to YAML, return string.";

YamlWriteFile::usage =
"YamlWriteFile[obj, file]  write Mathematica object to YAML, writes to file.";

YamlNotParsed::usage = "If you see this symbol, it means SnakeYAML returned an object that this package did not handle.
It returns this instead of the object because the code is executed instead a JavaBlock[], which releases it.";


Begin["`Private`"];

AllHeadQ[list_List,head_] := And@@Map[Head[#] === head&, list];

RuleQ[x_] := False;
RuleQ[rule_Rule] := True;
RuleQ[{}] := True; (* An empty list can be a Rule set... *)

RuleQ[rules_List] := AllHeadQ[rules, Rule];

(* Meat and Potatoes *)

yaml = None;
yamlClassPath = FileNameJoin[{DirectoryName[$InputFileName],"Java", "snakeyaml-1.10.jar"}];

YamlInit[] :=
Module[{},
	YamlInit[yamlClassPath];
];

YamlInit[yamlClassPath_] :=
Module[{},
	If[SameQ[yaml, None],
		Needs["JLink`"];
		JLink`InstallJava[];
		JLink`AddToClassPath[yamlClassPath];
		tmp = JLink`JavaNew["org.yaml.snakeyaml.Yaml"];
		If[!SameQ[tmp, $Failed],
			yaml = tmp;
		];
	,
		Print["Yaml already initizialized"];
	];
];

YamlUnload[] :=
Module[{},
	If[!SameQ[yaml, None],
		Jlink`ReleaseJavaObject[yaml];
		yaml = None;
	,
		Print["Yaml not initialized"];
	];
];

(*
WARNING: If any Java objects are not handled through YamlScan, it \
will make for problems in the future,
especially if the objects are released through the JavaBlock[].
*)
YamlRead[text_String] :=
Module[{raw, obj},
	If[yaml === None, Throw["Yaml has not been loaded. Please call YamlInit[]"]];
	JLink`JavaBlock[
		raw = yaml@load[text];
		obj = FromYaml[raw];
	];
    Return[obj];
];

YamlReadFile[file_String] := YamlRead[Import[file, "Text"]];

YamlWrite[obj_] :=
Module[{javaObj, text},
	If[yaml === None, Throw["Yaml has not been loaded. Please call YamlInit[]"]];
	JLink`JavaBlock[
		javaObj = ToYaml[obj];
		text = yaml@dump[javaObj];
	];
    Return[text];
];

YamlWriteFile[obj_, file_String] := Export[file, YamlWrite[obj], "Text"];



(* Default (non-Java object) - Mathematica handles most of it*)
FromYaml[obj_] := obj;

(* List *)
FromYaml[obj_ /; JLink`InstanceOf[obj, "java.util.List"]] := 
Module[{result, iter, value},
    result = {};
	JLink`JavaBlock[
		iter = obj@iterator[];
		While[iter@hasNext[],
			value = iter@next[];
			AppendTo[result, FromYaml[value]];
		];
	];
    Return[result];
];

(* Null*)
(*FromYaml[obj/;JLink`InstanceOf[obj,"Null"]] := {};*)
FromYaml[Null] := {};

(* Map *)
(*
NOTE: If using Map.get(), you can't just pass a \
Mathematica string.
You must wrap it in JavaNew["java.lang.String", "key"] so Java \
doesn't complain.
For that reason, we're just going to use entrySet ().
*)
FromYaml[obj_ /; JLink`InstanceOf[obj, "java.util.Map"]] := 
Module[{result, iter, entry, key, value},
    result = {};
	JLink`JavaBlock[
		iter = obj@entrySet[]@iterator[];
		While[iter@hasNext[],
			entry = iter@next[];
			key = entry@getKey[];
			value = entry@getValue[];
			AppendTo[result, key -> FromYaml[value]];
		];
	];
    Return[result];
];

FromYaml[obj_?JLink`JavaObjectQ] := YamlNotParsed[JLink`ClassName[obj],ToString[obj]];


ToYaml[obj_] := YamlNotParsed[obj];

ToYaml[True] := JLink`JavaNew["java.lang.Boolean", True];
ToYaml[False] := JLink`JavaNew["java.lang.Boolean", False];

ToYaml[obj_Integer] := JLink`JavaNew["java.lang.Integer", obj];
ToYaml[obj_?NumberQ] := JLink`JavaNew["java.lang.Double", obj];

ToYaml[obj_String] := JLink`JavaNew["java.lang.String", obj];

ToYaml[list_List] :=
Module[{result, value},
	result = JLink`JavaNew["java.util.ArrayList"];
	Table[
		result@add[ToYaml[item]];
	, {item, list}
	];
	Return[result];
];

ToYaml[obj_List?RuleQ]:=
Module[{result, key, value},
	result = JLink`JavaNew["java.util.LinkedHashMap"];
	Table[
		key = set[[1]];
		value = set[[2]];
		result@put[ToYaml[key], ToYaml[value]];
	, {set, obj}
	];
	Return[result];
];

ToYaml[obj_?AssociationQ]:=
Module[{result, key, value, keys},
	result = JLink`JavaNew["java.util.LinkedHashMap"];
	keys = Keys[obj];
	Table[
		value = obj[key];
		result@put[ToYaml[key], ToYaml[value]];
	, {key, keys}
	];
	Return[result];
];


End[];


EndPackage[];
