(* Wolfram Language Package *)

(* :Title: RobotModel.m *)

BeginPackage["RobotModel`",{"Screws`","RobotLinks`","ExtraUtils`","URDFParser`"}]
(* Exported symbols added here with SymbolName::usage *) 


InitializeModel::usage = 
	"InitializeModel[file] initializes the 3D robot model from an URDF file.
	 InitializeModel[file, type] initializes a model from an URDF file, with a specified \
model type (either floating or planar). "

GetFlag::usage = "GetFlag[flag] returns the status of the flag.";
	
GetQe::usage = "GetQe[] returns the list of extend coordinates: Qe.";
GetQeDot::usage = "GetQeDot[] returns the list of velocity of extend coordinates: QeDot.";	

GravityVector::usage = 
	"GravityVector[] computes the gravity vector of the robot model."
	
InertiaMatrix::usage = 
	"InertiaMatrix[] computes the inertia matrix of the robot model."	

InertiaToCoriolis::usage = 
	"InertiaToCoriolis[D] computes the Coriolis matrix given the \
inertia matrix, D."

InertiaToCoriolisPart1::usage = 
	"InertiaToCoriolisPart1[D] computes the first part of the Coriolis matrix given the \
inertia matrix, D."

InertiaToCoriolisPart2::usage = 
	"InertiaToCoriolisPart2[D] computes the second part of the Coriolis matrix given the \
inertia matrix, D."

InertiaToCoriolisPart3::usage = 
	"InertiaToCoriolisPart3[D] computes the third part of the Coriolis matrix given the \
inertia matrix, D."

ComputeComPosition::usage = 
	"ComputeComPosition[] returns the position vectors of the \
center of mass of the robot."

(*ComputeComJacobian::usage = 
	"ComputeComJacobian[] returns the velocity vectors of the \
center of mass of the robot."*)

ComputeForwardKinematics::usage = 
	"ComputeForwardKinematics[{link1,offset1},...,{link$n,offset$n}] \
Compute the forward homogeneous transformation from the base to the point that is rigidly attached \
to a link with a given offset."

ComputeBodyJacobians::usage =
	"ComputeBodyJacobians[{link1,offset1},...,{link$n,offset$n}] \
Compute the body jacobian of the point that is rigidly attached to the link with a given offset."; 




ComputeKinJacobians::usage=
	"ComputeKinJacobians[pos] computes the Jacobian of the input expression pos w.r.t. qe. \
In other words, it equals \[PartialD]pos/\[PartialD]qe.";

ComputeSpatialPositions::usage = 
	"ComputeSpatialPositions[{link1,offset1},...,{link$n,offset$n}] computes \
the 6-dimensional spatial positions (3-dimension rigid position + 3-dimension Euler \
angles specified by the links and relative offset vectors";

ComputeSpatialJacobians::usage = 
	"ComputeSpatialJacobians[{link1,offset1},...,{link$n,offset$n}] computes Jacobian of\
the 6-dimensional spatial positions (3-dimension rigid position + 3-dimension Euler \
angles specified by the links and relative offset vectors";




(*GetJointIndex::usage = 
	"GetJointIndex[name] returns the position index of the jointName in the list of joints.";*)
	
ComputeJointConstraint::usage = "ComputeJointConstraint[dofIndex] computes the joint based holonomic constraints.";
(*
GetLinkIndex::usage = 
	"GetLinkIndex[name] returns the position index of the linkName in the list of rigid links."; 

GetJointSymbol::usage = 
	"GetJointSymbol[name} returns the joint symbol of the given joints";

GetInertia::usage = 
	"GetInertia[link] returns the inertia of a link.";
	
GetMass::usage = 
	"GetMass[link] returns the mass of the link.";	
	
GetPosition::usage = 
	"GetPosition[link] returns the center of mass position of the link.
	GetPosition[joint] returns the position of the child joint in the parent joint \
coordinate system.";	

GetRotationMatrix::usage = 
	"GetRotationMatrix[joint] returns the relative rotation matrix of the child joint coordinates \
with respect to the parent joint coordinates.";
*)






GetKinematicTree::usage = 
	"GetKinematicTree[] Return the kinematic tree indices of the multi-body model.";

GetBaseLink::duplicated = "Duplicated base links: `1` and `2`.";
GetBaseLink::notfound = " Unable to find the base link of the system.";
GetBaseLink::usage = 
	"GetBaseLink[] returns the base link of the multi-body system.";
	

GetStateSubs::usage = "Return the substitutation rule for system states.";	
GetZeroStateSubs::usage = "Returns the system states to all zero substitutation rule.";	
GetnDof::usage = "Returns the degrees of freedom";
	

RobotModel::init = "The robot model has not been initiliazed. Please run InitializeModel[file] \
to initialize the robot model from the URDF file.";

(**)
Begin["`Private`"]
(* Implementation of the package *)



(* ::Section:: *)
(* Private Constant *)
I3=IdentityMatrix[3];
Z3=ConstantArray[0,{3,3}];
I4=IdentityMatrix[4];
(* SE(3) *)
E4=RPToHomogeneous[I3,{0,0,0}];
grav = 9.81; (* the gravity constant*)





(* ::Section:: *)
(* Private model parameters *)
(* Note:
   We use private symbols to store basic information of robot model to reduce 
   the redundant computation required for different functions. These parameters 
   are required to be initialized when a robot model is loaded (in the form 
   of URDF file) to perform other functionalities.
 *)

GetStateSubs[]:=Join[
	(($Qe[[#+1,1]]-> HoldForm@Global`q[[#]]&)/@(Range[$nDof]-1)),
	(($dQe[[#+1,1]]-> HoldForm@Global`dq[[#]]&)/@(Range[$nDof]-1))];
 
(* assume the model is 3D spatial model by default *)
(*$modelType = None; *)
$nBase  = None;   (* number of base coordinates*)
$nDof   = None;   (* total degrees of freedom*)
$nJoint = None;   (* number of joints*)
$nLink  = None;   (* number of links *)

$robotLinks  = None; (* a structure contains parameters of rigid links *)
$robotJoints = None; (* a structure contains parameters of robot joints *)


$Qb  = None; (* a vector of floating base coordinates symbol *)
$Q   = None; (* a vector of joint coordinates symbol *)
$Qe  = None; (* a vector of extended (floating base + joint) coordinates symbol *)
$dQb  = None; (* a vector of floating base velocities symbol *)
$dQ   = None; (* a vector of joint velocities symbol *)
$dQe  = None; (* a vector of extended (floating base + joint) velocities symbol *)

$qe0subs = None;
$dqe0subs = None;

$gst0 = None; (* a list of homogeneous transformation from initial configuration (q = 0) *)

$bChains = None;
$jChains = None;
$chainIndices = None;
$pIndices = None;
$dofName = None;
$baseDofs = {};
$ModelInitialized = False;
(* ::Section:: *)
(* Functions *)

GetFlag["$ModelInitialized"]:=TrueQ[$ModelInitialized];
(*GetFlag[flag_]:=Evaluate[TrueQ@flag];*)


InitializeModel::notfound = "Fild not found.";	
InitializeModel::loaderr = "Cannot successfully load the URDF model.";
(* If the model type is not specified, we assume that the model 
is a "spatial" model by default. *)	
InitializeModel[file_,baseAxes_:{"Px","Py","Pz","Rx","Ry","Rz"}] :=
	Block[{i},
		(*If[!EmptyQ[baseAxes],
			Print["Setting floating base coordinates of the model ..."];		
		];*)
		SetBaseDoF[baseAxes];
		(* check if the file exists *)
		If[!FileExistsQ[file], 
			Message[InitializeModel::notfound];
			Abort[];
		];
		(* load the robot URDF file to extract the links and joints information *)
		(*Print["Loading the robot URDf file ..."];*)
		{$robotLinks, $robotJoints} = LoadURDF[file];
		(* check if the URDF model is successfully loaded *)
		If[EmptyQ[$robotLinks] || EmptyQ[$robotJoints],
			Message[InitializeModel::loaderr];
			Abort[];
		];
		
		$nLink  = Length[$robotLinks];
		$nJoint = Length[$robotJoints];
		$nDof = $nJoint + $nBase;
		
		(* construct the base and joint coordinates symbol *)
		$Qb  = Vec[Table[Subscript[Global`qb,i][Global`t],{i,1,$nBase}]];		
		$Q  = Vec[Table[Subscript[Global`q,i][Global`t],{i,1,$nJoint}]];		
		$Qe  = Join[$Qb, $Q];
		$qe0subs = Table[$Qe[[i,1]]->0,{i,$nDof}];
		(* construct the base and joint velocities symbol *)
		$dQb = D[$Qb,Global`t];
		$dQ =  D[$Q,Global`t];
		$dQe = Join[$dQb, $dQ];	
		$dqe0subs = Table[$dQe[[i,1]]->0,{i,$nDof}];
		
		(* get the indices of parent joints of rigid links. *)
		$pIndices = GetParentJointIndices[];
		
		(* compute homogeneous transformation of zero configuration *)
		(*Print["Computing homogenous transformations of the multi-body system ..."];*)
		$gst0 = ComputeHomogeneousTransforms[];
		
		(* get the kinematic chains (joint indices) of each joint *)
		$chainIndices = GetChainIndices[];		
		
		(* compute kinematic chains (twist pairs) of each coordinates *)
		{$bChains,$jChains} = GetKinematicChains[baseAxes];	
		
		$dofName = Join[$baseDofs,
			Map[#["name"] &, $robotJoints]];
		(*Print["The initialization process of the robot model is completed."];*)
		$ModelInitialized = True;
		Return[Null];
	];

GetZeroStateSubs[]:= {$qe0subs,$dqe0subs};
GetnDof[]:={$nDof};
GetQe[]:=$Qe;
GetQeDot[]:=$dQe;
(*SetModelType::usage = 
	"SetModelType[type] sets the type of the robot model. \
The type can be either planar or floating.";
SetModelType::wrongType = "The model type can be only planar or floating: `1`";
SetModelType::undefined = "The model type is not defined.";*)
SetBaseDoF[axes_]:= 
	Block[{},
		$baseDofs = Map[Switch[#, "Px","BasePosX", 
				   "Py","BasePosY", 
				   "Pz","BasePosZ", 
				   "Rx","BaseRoll", 
				   "Ry", "BasePitch", 
				   "Rz", "BaseYaw", 
				   "px", "BasePosX", 
				   "py", "BasePosZ", 
				   "r", "BasePitch"] &, axes];
	    $nBase = Length[axes];
	];
	
(*GetModelType[] :=	
	Block[{},
		If[SameQ[$modelType,None],
			Message[SetModelType::undefined];
			,
			Return[$modelType];
		];
	];	*)
	

(*GetLinkIndex[name_?StringQ] :=
	Block[{indices},
		(* check if the robot model is successfully initialized *)
		If[EmptyQ[$robotLinks] || SameQ[$robotLinks,None],
			Message[RobotModel::init];
			Abort[];
		];
		indices = GetFieldIndices[$robotLinks,"name"];
		Return[indices[name]];
	];*)



(*GetJointSymbol[name_?StringQ] :=
	Block[{indices},
		(* check if the robot model is successfully initialized *)
		If[EmptyQ[$robotJoints] || SameQ[$robotJoints,None],
			Message[RobotModel::init];
			Abort[];
		];
		indices = PositionIndex[$dofName];
		Return[$Qe[[First@indices[name]]]];
	];*)


(*GetJointIndex[name_?StringQ] :=
	Block[{indices},
		(* check if the robot model is successfully initialized *)
		If[EmptyQ[$robotJoints] || SameQ[$robotJoints,None],
			Message[RobotModel::init];
			Abort[];
		];
		indices = PositionIndex[$dofName];
		Return[First@indices[name]];
	];*)
	
	
PotentialEnergy[] :=
	Block[{links, linkPos, masses, Ve, i},
		(* construct pairs of link name and position offset *)
		links = Map[{#["name"], GetPosition[#]} &, $robotLinks];
		
		(* center of mass positions of each link*)
		linkPos = ComputeRigidPositions[Sequence@@links];
		
		(* get mass of links *)
		masses = Map[GetMass[#]&, $robotLinks];
		
		Ve = Sum[grav*masses[[i]]*linkPos[[i,3]],{i,$nLink}];
		
		Return[Ve];
	];	

GravityVector[] :=
	Block[{V, ge},
		(* compute potential energy of the robot *)
		V = PotentialEnergy[];
		
		(* take partial derivatives to get the gravity vector *)
		ge = Vec[D[Flatten[V],{Flatten[$Qe],1}]];
		
		Return[ge];
	];

InertiaToCoriolis[De_] := InertiaToCoriolis[De,Flatten[$Qe],Flatten[$dQe]];
InertiaToCoriolis[] := 
	Block[{De},
		De = InertiaMatrix[];
		InertiaToCoriolis[De,Flatten[$Qe],Flatten[$dQe]];
	];
	
InertiaToCoriolisPart1[De_] := InertiaToCoriolisPart1[De,Flatten[$Qe],Flatten[$dQe]];
InertiaToCoriolisPart2[De_] := InertiaToCoriolisPart2[De,Flatten[$Qe],Flatten[$dQe]];
InertiaToCoriolisPart3[De_] := InertiaToCoriolisPart3[De,Flatten[$Qe],Flatten[$dQe]];


(* The contributions of motor inertia to the robot dynamics are not addressed
in the URDF model definition. To include the motor inertia in the dynamics 
please include the motor inertia information when call InertiaMatrix[] function.
NOTE: the provided motor inertia value should be the reflected inertia value at 
the joint side = original actuator inertia * gear ratio ^2.
*)
InertiaMatrix[motorInertia_:None] :=
	Block[{MM, link, mass, inertia, links, Je, De, DeMotor, i, jIndex, jointIndices},
		MM = Table[
			mass=GetMass[link];
			inertia=GetInertia[link];
			BlockDiagonalMatrix[{I3*mass,inertia}]
			,
			{link,$robotLinks}
		];
		
		(* construct pairs of link name and position offset *)
		links = Map[{#["name"], GetPosition[#]} &, $robotLinks];
		
		(* compute body jacobians of each link CoM position *)
		Je = ComputeBodyJacobians[Sequence@@links];
		
		De = Sum[Transpose[Je[[i]]].MM[[i]].Je[[i]],{i,$nLink}];
		DeMotor = ConstantArray[0, {$nDof,$nDof}];
		If[!SameQ[motorInertia, None], (* if motor inertia specified *)
			If[Length[motorInertia] != $nJoint,
				Message[InertiaMatrix::inequal, Length[motorInertia],$nJoint];
				Abort[];
				,
				jointIndices = GetFieldIndices[$robotJoints,"name"];
				Table[
					(* find the joint index based on the joint name*)
					jIndex = jointIndices[motorInertia[[i,1]]]; 
					(* assign the motor inertia to the specified joint *)
					DeMotor[[jIndex, jIndex]] = motorInertia[[i,2]]; 
					,
					{i,$nJoint}
				];
			];			
		];
		
		Return[De + DeMotor];
	];
InertiaMatrix::inequal = 
	"The length of given motor inertia `1` is not equal to the number of joints `2`.";

ComputeComPosition[] :=
	Block[{links, linkPos, masses, pcom, i},
		
		(* construct pairs of link name and position offset *)
		links = Map[{#["name"], GetPosition[#]} &, $robotLinks];
		
		(* center of mass positions of each link*)
		linkPos = ComputeRigidPositions[Sequence@@links];
		
		(* get mass of links *)
		masses = Map[GetMass[#]&, $robotLinks];
		
		pcom = {Sum[Times[masses[[i]], linkPos[[i]]], {i, 1, Length[links]}]}/Total[masses];		
		
		Return[pcom];
	];
	
(*ComputeComJacobian[pcom_] :=
	Block[{links, linkPos, masses, Jcom, vcom, dJcom},
		
		(*pcom = ComputeComPosition[];*)
		
		(* compute the jacobian of center of mass positions *)
		Jcom = D[Flatten[pcom], {Flatten[$Qe],1}];
		
		
		Return[Jcom];
	];*)

ComputeBodyJacobians[args__] :=
	Block[{gs0,i,np,Jz,Je,curIndices,linkName,offset,jIndex,
		argList = {args}}, (* turn arguments into a real list *)
		
		(* check if the robot model is successfully initialized *)
		If[EmptyQ[$robotJoints] || SameQ[$robotJoints,None],
			Message[RobotModel::init];
			Abort[];
		];		
		
		(* extract the number of points to be calculated *)
		np = Length[argList];
		
		(* forward homogeneous transformation *)
		Table[		
			(* a string represents the name of the link on which the point is rigidly attached to.*)
			linkName = argList[[i,1]];  
			(* the relative argList[[i,2]] of the point from the origin of the link (in the link coordinates). *)
			offset   = Flatten@argList[[i,2]];
			
			(* take the index of parent joint of the rigid link *)
			jIndex   = First@$pIndices[linkName];
			
			(* initialize the Jacobian with fixed length (ndof) *)
			Jz    = ConstantArray[0,{6,$nDof}];
			
			(* compute homogeneous transformation from base to the point with initial tool configuration (Qe=0)*)
			gs0 = $gst0[[jIndex+1]].RPToHomogeneous[I3, offset];
			
			
			If[jIndex == 0, (* the link is the base link *)
				(* assign the dependent coordinate indices *)
				curIndices = Range[$nBase];
				(* compute body jacobian *)
				Jz[[;;,curIndices]]=BodyJacobian[Sequence@@$bChains, gs0];
				, 
				(* otherwise *)
				(* assign the dependent coordinate indices *)
				curIndices = Join[Range[$nBase],$nBase+$chainIndices[[jIndex]]];		
				(* compute body jacobian *)		
				Jz[[;;,curIndices]]=BodyJacobian[Sequence@@$bChains, Sequence@@$jChains[[jIndex]], gs0];
			];
					
			Je[i] = Jz;
			,
			{i,np}
		];
		Return[Table[Je[i],{i,1,np}]];	
	];
	
	

ToEulerAngles[gst_] :=
	Block[{R, R0, Rw, yaw, roll, pitch},
		(* compute rigid orientation*)
		R = RigidOrientation[gst];
		(* compute rigid orientation with initial tool configuration (Qe = 0) *)
		R0 = R/.$qe0subs;
		(* compute spatial orientation *)
		Rw = R.Transpose[R0];
		(* compute Euler angles *)
		yaw=ArcTan[Rw[[1,1]],Rw[[2,1]]];
		roll=ArcTan[Rw[[3,3]],Rw[[3,2]]];
		pitch=ArcTan[Rw[[3,3]],-Rw[[3,1]]Cos[roll]];
		
		Return[{roll,pitch,yaw}];
	];
	


ComputeKinJacobians[pos_] :=
	Block[{Jac},
		
		Jac = Map[D[Flatten[#],{Flatten[$Qe],1}]&, pos];
		
		Return[Jac];
	];
	
ComputeRigidPositions[args__] :=
	Block[{pos, gst},
		
		(* first compute the forward kinematics *)
		gst = ComputeForwardKinematics[args];
		
		(* compute rigid positions *)
		pos = Map[RigidPosition[#]&,gst];
		
		Return[pos];
	];

ComputeSpatialPositions[args__] :=
	Block[{pos, gst},
		
		(* first compute the forward kinematics *)
		gst = ComputeForwardKinematics[args];
		
		(* compute rigid positions *)
		pos = Map[Join[RigidPosition[#],ToEulerAngles[#]]&,gst];
		
		Return[pos];
	];
	
ComputeSpatialJacobians[args__] :=
	Block[{pos, argList = {args}, np, i, Je, 
		linkName, offset, jIndex, Jz, gs0, curIndices},
		(* check if the robot model is successfully initialized *)
		If[EmptyQ[$robotJoints] || SameQ[$robotJoints,None],
			Message[RobotModel::init];
			Abort[];
		];		
		
		(* extract the number of points to be calculated *)
		np = Length[argList];
		
		(* forward homogeneous transformation *)
		Table[		
			(* a string represents the name of the link on which the point is rigidly attached to.*)
			linkName = argList[[i,1]];  
			(* the relative offset of the point from the origin of the link (in the link coordinates). *)
			offset   = Flatten@argList[[i,2]];
			
			(* take the index of parent joint of the rigid link *)
			jIndex   = First@$pIndices[linkName];
			
			(* initialize the Jacobian with fixed length (ndof) *)
			Jz    = ConstantArray[0,{6,$nDof}];
			
			(* compute homogeneous transformation from base to the point with initial tool configuration (Qe=0)*)
			gs0 = $gst0[[jIndex+1]].RPToHomogeneous[I3, offset];
			
			
			If[jIndex == 0, (* the link is the base link *)
				(* assign the dependent coordinate indices *)
				curIndices = Range[$nBase];
				(* compute spatial jacobian *)
				Jz[[;;,curIndices]]=SpatialJacobian[Sequence@@$bChains, gs0];
				, 
				(* otherwise *)
				(* assign the dependent coordinate indices *)
				curIndices = Join[Range[$nBase],$nBase+$chainIndices[[jIndex]]];		
				(* compute spatial jacobian *)		
				Jz[[;;,curIndices]]=SpatialJacobian[Sequence@@$bChains, Sequence@@$jChains[[jIndex]], gs0];
			];
					
			Je[i] = Jz; (* take only the orientation portions of spatial jacobian*)
			,
			{i,np}
		];
		Return[Table[Je[i],{i,1,np}]];	
	];	
	
ComputeForwardKinematics[args__] :=
	Block[{i,np,gst,gs0,linkName,offset,jIndex,
		argList = {args}}, (* turn arguments into a real list *)
		(* check if the robot model is successfully initialized *)
		If[EmptyQ[$robotJoints] || SameQ[$robotJoints,None],
			Message[RobotModel::init];
			Abort[];
		];
		
		
		(* extract the number of points to be calculated *)
		np = Length[argList];
		
		
		(* forward homogeneous transformation *)
		Table[		
			(* a string represents the name of the link on which the point is rigidly attached to.*)
			linkName = argList[[i,1]];  
			(* the relative offset of the point from the origin of the link (in the link coordinates). *)
			offset   = Flatten@argList[[i,2]];
			
			(* take the index of parent joint of the link *)
			jIndex   = First@$pIndices[linkName];
			
			(* compute homogeneous transformation from base to the point with initial tool configuration (Qe=0)*)
			gs0 = $gst0[[jIndex+1]].RPToHomogeneous[I3, offset];
			
			(* compute forward kinematics *)
			If[jIndex == 0, (* the link is the base link *)
				gst[i]=ForwardKinematics[Sequence@@$bChains, gs0];
				,
				gst[i]=ForwardKinematics[Sequence@@$bChains, Sequence@@$jChains[[jIndex]], gs0];
			];
					
			,
			{i,np}
		];
		Return[Table[gst[i],{i,1,np}]];	
	];


	









(*GetLinkParams::usage = "GetLinkParams[link] 
	Return the association that describes the robot link paramters."*)
(*GetLinkParams[linkName_?StringQ] := 
	Block[{link},
		If[SameQ[$robotLinks,None],
			Message[RobotModel::init]
			,
			link = First@$robotLinks[[$LinkIndices[linkName]]];
			Return[link];
		];
	];*)


(*GetJointParams::usage = "GetJointParams[joint] 
	Return the association that describes the robot joint paramters."*)
(*GetJointParams[jointName_?StringQ] := 
	Block[{joint},
		If[SameQ[$robotJoints,None],
			Message[RobotModel::init];
			,
			joint = First@$robotJoints[[$JointIndices[jointName]]];
			Return[joint];
		];
	];*)
	
GetKinematicTree[] := 
	Block[{parentIndex,link,jointIndex,base,numBranch,tree,i,j}, 
		(* check if the robot model is successfully initialized *)
		If[EmptyQ[$robotJoints] || SameQ[$robotJoints,None],
			Message[RobotModel::init];
			Abort[];
		];
		(* get the indices of parent links *)
		parentIndex = GetFieldIndices[$robotJoints, "parent"];
		
		(* get the base link of the multi-body system *)
		base = GetBaseLink[];
		If[SameQ[base, None],
  			Message[GetBaseLink::notfound];
  			Abort[];
  		];
		(* the number of parent link indices associated with 
		the base link determines the number of branches in the 
		kinematic tree. *)
		numBranch = Length[parentIndex[base]];
		
		(* initialize the tree structure *)
		tree=Transpose@{parentIndex[base]};
		
		(* iteratively get the joint indices of each kinematic branch. *)
		Table[
			(* find the child link of the first joint in the branch. *)
		  	link=$robotJoints[[parentIndex[base][[i]]]]["child"];
		  	
		  	(* find the child joint until there is no child joint *)
		  	While[
		  		(* check if the current link is the parent link of some joint *)
		  		KeyExistsQ[parentIndex,link], 
		  		
		  		(* get the index of this child joint *)
		    	jointIndex=parentIndex[link];
		    	
		    	(* append this link to the current branch *)
			    tree[[i]]=Flatten@AppendTo[tree[[i]],jointIndex];
			    
			    (* set the current link to the child link of the joint *)
		    	link=$robotJoints[[jointIndex]][[1]]["child"];
		  ];
		  ,
		  {i,1,numBranch}
		];
		
		(* return the kinematic tree structure *)
		Return[tree];			
	];


GetBaseLink[] :=
	Block[{plink, clink, baselink = None, i}, 
		(* check if the robot model is successfully initialized *)
		If[EmptyQ[$robotJoints] || SameQ[$robotJoints,None],
			Message[RobotModel::init];
			Abort[];
		];
		(* extract the name list of the parent and child links *)
		plink = Map[ToString@#["parent"] &, $robotJoints];
 		clink = Map[ToString@#["child"] &, $robotJoints];
 		
 		(* the base link is the parent link that is not a child link of any joint *)
 		Table[
 			(* check if the current link is a member of the child link list*)
 			If[! MemberQ[clink, plink[[i]]],
 				
 				If[SameQ[baselink, None], (* if first time find the link*)
      				baselink = plink[[i]]; (* simply assign the base link *)
      				,
      				(* if the base link is assigned before *)
      				(* check if the base link is the same as previous base link *)
      				If[! StringMatchQ[baselink, plink[[i]]], 
      					(* warning if there are publicated base link *)
        				Message[GetBaseLink::duplicated, baselink, plink[[i]]];        			
        			];
      			];
    		];
  			,
  			{i, Length[plink]}
  		];
  		If[SameQ[baselink, None],
  			Message[GetBaseLink::notfound];
  		];
   		Return[baselink];
 	];


GetRelativeTwist::undefinedAxisType = "Undefinied joint axis type: `1`.";
GetRelativeTwist::usage = 
	"GetRelativeTwist[joint] returns the relatvie twist of the joint.";	
(*TODO: verify if it is true that the twist is zero if the joint is fixed.*)	
GetRelativeTwist[joint_?AssociationQ]:=
	Block[{type,axis,xi},
		type=joint["type"];
		axis=joint["axis"];	
		(* Relative, DH-style twists, see MLS p. 94 *)
		(* Note that the twists are in body frame, so q = 0 *)	
		Switch[type,
			"prismatic",
			(* xi : (q = 0, v = axis ) *)
			xi = PrismaticTwist[{0, 0, 0}, axis];
			,
			"revolute",
			(* xi : (q = 0, w = axis, v (handled by function) *)
			xi = RevoluteTwist[{0, 0, 0}, axis];
			,
			"continuous",
			(* xi : (q = 0, w = axis, v (handled by function) *)
			xi = RevoluteTwist[{0, 0, 0}, axis];
			,
			"fixed",
			xi = RevoluteTwist[{0, 0, 0}, axis];
			,
			_, (* none *)
			xi = Null;
			Message[GetRelativeTwist::undefinedAxisType, type];
		];
		Return[xi];
	];
	

GetInertia[link_?AssociationQ]:=
	Block[{roll,pitch,yaw,Ic,R},
		If[KeyExistsQ[link["origin"],"rpy"],
			{roll,pitch,yaw}=link["origin"]["rpy"];
			(* From the definition of URDF link:
			Represents the rotation around fixed axis: first roll around x, then pitch 
			around y and finally yaw around z. All angles are specified in radians. *)
			R = RotZ[yaw].RotY[pitch].RotX[roll];
			,
			R = IdentityMatrix[3];
		];
		Ic = link["inertia"];
		
		
		(* compute inertia in the joint coordiate, and return *)
		Return[Transpose[R].Ic.R];
	];


GetMass[link_?AssociationQ]:= link["mass"];


GetPosition[arg_?AssociationQ] := arg["origin"]["xyz"];


GetRotationMatrix[joint_?AssociationQ]:=
	Block[{roll,pitch,yaw,R},		
		If[KeyExistsQ[joint["origin"],"rpy"],
			{roll,pitch,yaw} = joint["origin"]["rpy"];
			(* From the definition of URDF joint:
			Represents the rotation around fixed axis: first roll around x, then pitch 
			around y and finally yaw around z. All angles are specified in radians. *)
			R = RotZ[yaw].RotY[pitch].RotX[roll];
			,
			R = IdentityMatrix[3];
		];
		
		Return[R];
	];
	

ComputeHomogeneousTransforms::usage = 
	"ComputeHomogeneousTransforms[] Compute the homogeneous transformation of \
each joint from the base by the initial tool configuration."
ComputeHomogeneousTransforms[] :=
	Block[{kinTree,branch,EL,rL,joint,gst0,i,j},
		(* check if the robot model is successfully initialized *)
		If[EmptyQ[$robotJoints] || SameQ[$robotJoints,None],
			Message[RobotModel::init];
			Abort[];
		];
		
		gst0[0] = E4; (* floating base homogeneous transformation*)
		(* compute kinematic tree *)
		kinTree = GetKinematicTree[];
		Table[
			branch = kinTree[[i]];
			(** Kinematics **)
			(* From SVA, we're given ^{i}X_{i-1} = X(^{i}E_{i-1}, ^{i-1}r)  -  spatial transform from i-1 to i *)
			(* With this, we can put together g_{i-1,i}(0) = T(^{i-1}E_{i}, ^{i-1}r)  -  homogeneous transfrom from i to i-1 *)
			Table[
				joint = Part[$robotJoints,branch[[j]]];
				EL = GetRotationMatrix[joint];
				rL = GetPosition[joint];
				If[j==1,
					gst0[branch[[j]]] = gst0[0].RPToHomogeneous[EL, rL];
					,
					gst0[branch[[j]]] = gst0[branch[[j-1]]].RPToHomogeneous[EL, rL];
				];
				,
				{j,1,Length[branch]}
			];
			,
			{i,1,Length[kinTree]}
		];
		
		Return[Table[gst0[i],{i,0,$nJoint}]];
	];


GetParentJointIndices::usage = 
	"GetParentJointIndices[] Return position indices of joints of the child links.";	
GetParentJointIndices[] := 
	Block[{baseLink,pIndices}, 
		(* first find the base link *)
		baseLink = GetBaseLink[]; 
		
		(* child link indices *)
		pIndices = GetFieldIndices[$robotJoints,"child"];
		
		(* append the child index for the base link (floating base = 0) *)
		pIndices = Append[pIndices, baseLink->{0}];
		
		Return[pIndices];
	];
	
FloatingBaseTwists::usage = 
	"FloatingBaseTwists[axes] returns the twists of floating base coordinates.";
FloatingBaseTwists[axes_] :=
	Block[{qb, xi},
		(* spatial floating base contains full 6-dimension axes. *)
		qb = Map[Switch[#, "Px", <|"type" -> "prismatic", "axis" -> {1, 0, 0}|>, 
						   "Py", <|"type" -> "prismatic", "axis" -> {0, 1, 0}|>, 
						   "Pz", <|"type" -> "prismatic", "axis" -> {0, 0, 1}|>, 
						   "Rx", <|"type" -> "revolute", "axis" -> {1, 0, 0}|>, 
						   "Ry", <|"type" -> "revolute", "axis" -> {0, 1, 0}|>, 
						   "Rz", <|"type" -> "revolute", "axis" -> {0, 0, 1}|>, 
						   "px", <|"type" -> "prismatic", "axis" -> {1, 0, 0}|>, 
						   "py", <|"type" -> "prismatic", "axis" -> {0, 0, 1}|>, 
						   "r", <|"type" -> "revolute", "axis" -> {0, 1, 0}|>] &, axes];
		xi = Map[GetRelativeTwist[#]&,qb];
		Return[xi];
	];


GetChainIndices::usage = "GetChainIndices[] returns the chain indices of each joint.";
GetChainIndices[] :=
	Block[{kinTree,chainIndices,jList,i,j},
		
		kinTree = GetKinematicTree[];
		Table[
			jList = kinTree[[i]];
		  	Table[
				chainIndices[jList[[j]]] = Flatten[jList[[1 ;; j]]];
				,
		  		{j, Length[jList]}
		  	];
			,
			{i, Length[kinTree]}
		];
		Return[Table[chainIndices[i], {i, $nJoint}]];		 
	];
	
GetKinematicChains::usage = 
	"GetKinematicChains[baseAxes]	Return the kinematic chains from the base to each joint.";
GetKinematicChains[baseAxes_] :=
	Block[{xi, xib, basechain, chains, i, j},
		
		(* compute twist for base coordinates  *)
		xib = FloatingBaseTwists[baseAxes];
		(* floating base kinematic chain (twist paris) *)
		basechain = 
			Table[
				Join[{xib[[j]]},$Qb[[j]]]
				,
				{j,$nBase}
			];
			
		(* compute twist for each coordinates (joints) *)
		xi = ComputeTwists[];
		
		
		(* construct twist pairs for each joint chain *)
		Table[
			chains[i] = 
				Table[
					Join[{Part[xi, $chainIndices[[i, j]]]},Part[$Q, $chainIndices[[i, j]]]]
					,
					{j,Length[$chainIndices[[i]]]}
				];
				
			,
			{i,$nJoint}
		];
		
		Return[{basechain, Table[chains[i],{i,$nJoint}]}];
	];
	

ComputeTwists::usage = 
	"ComputeTwists[]	computes relative twist (in joint frame i) to base frame S.";
ComputeTwists[] :=
	Block[{xi,twist,i},  
		(* check if the robot model is successfully initialized *)
		If[EmptyQ[$robotJoints] || SameQ[$robotJoints,None],
			Message[RobotModel::init];
			Abort[];
		];
		
		xi = Table[
			(* compute relative twist *)
			twist = GetRelativeTwist[$robotJoints[[i]]];
			
			(* Transform relative twist (in joint frame i) to base frame S - using adjoint transform for twists (MLS, p .55, Eq. (2.58) *)
			(* Same as spatial transform (Featherstone, p .22, Eq. (2.26) -- note that twist is (v, w) and Plucker is (w, v) *)
			(* URDF Docs say that joint axis is in joint frame, so we will use the joint's frame in S to transform twist *)
			(* See http://www.ros.org/wiki/urdf/XML/joint *)
			
			RigidAdjoint[$gst0[[i+1]]].twist
			, 
			{i, $nJoint}
		];
		Return[xi];
	];

ComputeJointConstraint[dofIndex_] :=
	Block[{},
		Return[$Qe[[dofIndex]]];
	];






(* Basic rotation matrices *)

RotX[q_]:=CRoundEx[N@{{1,0,0},{0,Cos[q],-Sin[q]},{0,Sin[q],Cos[q]}}];
RotY[q_]:=CRoundEx[N@{{Cos[q],0,Sin[q]},{0,1,0},{-Sin[q],0,Cos[q]}}];
RotZ[q_]:=CRoundEx[N@{{Cos[q],-Sin[q],0},{Sin[q],Cos[q],0},{0,0,1}}];	
	
	
End[]

EndPackage[]

