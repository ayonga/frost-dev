(* Wolfram Language Package *)

(* Created by the Wolfram Workbench Sep 19, 2016 *)

BeginPackage["URDFParser`",{"ExtraUtils`"}]
(* Exported symbols added here with SymbolName::usage *) 


LoadURDF::usage = 
	"LoadURDF[file]	Load the robot model information from the URDF file."

ParseLinks::usage = 
	"ParseLinks[urdfModel] Parse the XMLObjects that describe the rigid body links \
of the robot, then return as an associated structure.";

ParseJoints::usage = 
	"ParseJoints[urdfModel]	Parse the XMLObjects that describe the rigid body joints \
of the robot, then return as an associated structure.";



Begin["`Private`"]
(* Implementation of the package *)
(* ::Section:: *)
(* Public Expressions *)
LoadURDF::failed = "Cannot import the URDF file, please check the syntax of the file.";
LoadURDF[file_] :=
	Block[{robot,links = {},joints = {}},
		robot = Import[file, "XML"];
		If[SameQ[robot,$Failed],
			Message[LoadURDF::failed];
			Return[{links,joints}];
		];
		joints = ParseJoints[robot];
		links = ParseLinks[robot];
		Return[{links,joints}];
	];
	

ParseLinks[urdfModel_] :=
	Block[{links,assoc},
		links = Cases[urdfModel,XMLElement["link",_,_],Infinity];
		assoc = ConvertXMLLinks[links];
		Return[assoc];
	];

ParseJoints[urdfModel_] :=
	Block[{joints,assoc},
		joints= Cases[urdfModel,XMLElement["joint",{"name"->_,"type"->_},_],Infinity];
		assoc = ConvertXMLJoints[joints];
		Return[assoc];
	];


	

	


(* ::Section:: *)
(* Private Expressions *)



	
JointTransform[XMLElement["joint", tag_, children_]] :=  
  Association@Join[Map[Association[#]&,tag],Map[JointTransform[#]&,children]];

JointTransform[XMLElement["origin", tag_, {}]] :=  
  <|"origin"-> Map[Str2Num[#]&,Map[StringSplit[#]&,Association[tag]]]|>;
JointTransform[XMLElement["parent", tag_, {}]] :=  
  <|"parent"-> "link"/.tag|>;
JointTransform[XMLElement["child", tag_, {}]] :=  
  <|"child"-> "link"/.tag|>;
JointTransform[XMLElement["axis", tag_, {}]] :=  
  <|"axis"-> "xyz"/.Map[Str2Num[#]&,Map[StringSplit[#]&,Association[tag]]]|>;
JointTransform[XMLElement["limit", tag_, {}]] :=  
  <|"limit"-> Map[ToExpression[#]&,Association[tag]]|>;
JointTransform[XMLElement[_, tag_, {}]] :=  {};


LinkTransform[XMLElement["link",tag_,children_]]:=
	Association@Join[Map[Association[#]&,tag],Map[LinkTransform[#]&,children]];

LinkTransform[XMLElement["visual",_,_]]:={};
LinkTransform[XMLElement["collision",_,_]]:={};
LinkTransform[XMLElement["inertial",_,children_]]:=
	Map[LinkTransform[#]&,children];
LinkTransform[XMLElement["origin", tag_, {}]] :=  
  <|"origin"-> Map[Str2Num[#]&,Map[StringSplit[#]&,Association[tag]]]|>;
LinkTransform[XMLElement["mass", tag_, {}]] :=  
  <|"mass"-> "value"/.Map[Str2Num[#]&,Association[tag]]|>;
LinkTransform[XMLElement["inertia", tag_, {}]] :=  
  <|"inertia"-> 
	{{"ixx","ixy","ixz"},
	 {"ixy","iyy","iyz"},
	 {"ixz","iyz","izz"}}
	/.Map[Str2Num[#]&,Association[tag]]|>;
LinkTransform[XMLElement[_, tag_, {}]] :={};



	
	

ConvertXMLJoints[XMLJoints_] := Map[JointTransform[#]&,Join[XMLJoints]];


ConvertXMLLinks[XMLLinks_] := Map[LinkTransform[#]&,Join[XMLLinks]];
	
	




End[]

EndPackage[]

