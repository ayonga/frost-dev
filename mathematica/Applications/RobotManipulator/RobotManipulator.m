(* Wolfram Language Package *)

(* :Title: RobotManipulator.m *)

BeginPackage["RobotManipulator`",{"Screws`","RobotLinks`","ExtraUtils`","URDFParser`"}]
(* Exported symbols added here with SymbolName::usage *) 


InitializeModel::usage = 
	"InitializeModel[robotJoints, q] initializes a model from an URDF file, with a specified \
model type (either floating or planar). "

PotentialEnergy::usage = 
	"PotentialEnergy[robotLinks,robotKinematics] compute the potential energy of the mechanical \
	system due to the gravity forces."

GravityVector::usage = 
	"GravityVector[q,robotLinks,robotKinematics] computes the gravity vector of the robot model."
	
InertiaMatrix::usage = 
	"InertiaMatrix[robotLinks, robotKinematics] computes the inertia matrix of the robot model."	



ComputeComPosition::usage = 
	"ComputeComPosition[robotLinks, robotKinematics] returns the position vectors of the \
center of mass of the robot."





ComputeBodyJacobians::usage =
	"ComputeBodyJacobians[{link1,offset1},...,{link$n,offset$n},robotKinematics] \
Compute the body jacobian of the point that is rigidly attached to the link with a given offset."; 





ComputeCartesianPositions::usage = 
	"ComputeCartesianPositions[{link1,offset1},...,{link$n,offset$n},robotKinematics] computes \
the 3-dimensional cartesian positions specified by the links and relative offset vectors";

ComputeEulerAngles::usage = 
	"ComputeEularAngles[{link1,offset1},...,{link$n,offset$n},robotKinematics] computes \
the 3-dimensional cartesian positions specified by the links and relative offset vectors";

ComputeSpatialJacobians::usage = 
	"ComputeSpatialJacobians[{link1,offset1},...,{link$n,offset$n},robotKinematics] computes Jacobian of\
the 6-dimensional spatial positions (3-dimension rigid position + 3-dimension Euler \
angles specified by the links and relative offset vectors";




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
	"GetKinematicTree[robotJoints] Return the kinematic tree indices of the multi-body model.";

GetBaseLink::duplicated = "Duplicated base links: `1` and `2`.";
GetBaseLink::notfound = " Unable to find the base link of the model.";

GetBaseLink::usage = 
	"GetBaseLink[robotJoints] returns the base link of the multi-body model.";
	


(**)
Begin["`Private`"]
(* Implementation of the package *)



(* ::Section:: *)
(* Private Constant *)
I3=IdentityMatrix[3];
Z3=ConstantArray[0,{3,3}];
I4=IdentityMatrix[4];
(* SE(3) *)
E4=Screws`RPToHomogeneous[I3,{0,0,0}];
grav = 9.81; (* the gravity constant*)






(* ::Section:: *)
(* Functions *)




(* If the model type is not specified, we assume that the model 
is a "spatial" model by default. *)	
InitializeModel[robotJoints_,q_] :=
	Block[{i,pIndices,gst0,chainIndices,kinTwists},
		
		
		
		(* get the indices of parent joints of rigid links. *)
		pIndices = ExtraUtils`GetFieldIndices[robotJoints,"child"];
		
		(* compute homogeneous transformation of zero configuration *)
		(*Print["Computing homogenous transformations of the multi-body system ..."];*)
		gst0 = ComputeHomogeneousTransforms[robotJoints];
		
		(* get the kinematic chains (joint indices) of each joint *)
		chainIndices = GetChainIndices[robotJoints];		
		
		(* compute kinematic chains (twist pairs) of each coordinates *)
		kinTwists = GetKinematicChains[robotJoints,q,gst0,chainIndices];	
		
		Return[Association["pIndices"->pIndices,"gst0"->gst0,"chainIndices"->chainIndices,"kinTwists"->kinTwists]];
	];






	
	
PotentialEnergy[robotLinks_,robotKinematics_] :=
	Block[{links, linkPos, masses, Ve, i},
		(* construct pairs of link name and position offset *)
		links = Map[{#["name"], GetPosition[#]} &, robotLinks];
		
		(* center of mass positions of each link*)
		linkPos = ComputeRigidPositions[Sequence@@links,robotKinematics];
		
		(* get mass of links *)
		masses = Map[GetMass[#]&, robotLinks];
		
		(* sum up the gravity potential energy of links *)
		Ve = Sum[grav*masses[[i]]*linkPos[[i,3]],{i,1,Length[robotLinks]}];
		
		Return[Ve];
	];	

GravityVector[q_,robotLinks_,robotKinematics_] :=
	Block[{V, ge},
		(* compute potential energy of the robot *)
		V = PotentialEnergy[robotLinks,robotKinematics];
		
		(* take partial derivatives to get the gravity vector *)
		ge = ExtraUtils`Vec[D[Flatten[V],{Flatten[q],1}]];
		
		Return[ge];
	];




(* The contributions of motor inertia to the robot dynamics are not addressed
in the URDF model definition. To include the motor inertia in the dynamics 
please include the motor inertia information when call InertiaMatrix[] function.
NOTE: the provided motor inertia value should be the reflected inertia value at 
the joint side = original actuator inertia * gear ratio ^2.
*)
InertiaMatrix[robotLinks_, robotKinematics_] :=
	Block[{MM, link, mass, inertia, links, Je, De},
		MM = Table[
			mass=GetMass[link];
			inertia=GetInertia[link];
			ExtraUtils`BlockDiagonalMatrix[{I3*mass,inertia}]
			,
			{link,robotLinks}
		];
		
		(* construct pairs of link name and position offset *)
		links = Map[{#["name"], GetPosition[#]} &, robotLinks];
		
		(* compute body jacobians of each link CoM position *)
		Je = ComputeBodyJacobians[Sequence@@links,robotKinematics];
		
		De = Sum[Transpose[Je[[i]]].MM[[i]].Je[[i]],{i,1,Length[robotLinks]}];
		
		
		Return[De];
	];
InertiaMatrix::inequal = 
	"The length of given motor inertia `1` is not equal to the number of joints `2`.";

ComputeComPosition[robotLinks_,robotKinematics_] :=
	Block[{links, linkPos, masses, pcom, i},
		
		(* construct pairs of link name and position offset *)
		links = Map[{#["name"], GetPosition[#]} &, robotLinks];
		
		(* center of mass positions of each link*)
		linkPos = ComputeRigidPositions[Sequence@@links,robotKinematics];
		
		(* get mass of links *)
		masses = Map[GetMass[#]&, robotLinks];
		
		pcom = {Sum[Times[masses[[i]], linkPos[[i]]], {i, 1, Length[links]}]}/Total[masses];		
		
		Return[pcom];
	];
	
(*ComputeComJacobian[pcom_] :=
	Block[{links, linkPos, masses, Jcom, vcom, dJcom},
		
		(*pcom = ComputeComPosition[];*)
		
		(* compute the jacobian of center of mass positions *)
		Jcom = D[Flatten[pcom], {Flatten[$q],1}];
		
		
		Return[Jcom];
	];*)

ComputeBodyJacobians[args__,robotKinematics_] :=
	Block[{gs0,i,np,Jz,Je,curIndices,linkName,offset,jIndex,pIndices,gst0,kinTwists,chainIndices,
		argList = {args}}, (* turn arguments into a real list *)
		
		
		(* extract the number of points to be calculated *)
		np = Length[argList];
		
		pIndices  = robotKinematics["pIndices"];
		gst0      = robotKinematics["gst0"]; 
		kinTwists = robotKinematics["kinTwists"];
		chainIndices = robotKinematics["chainIndices"];
		
		(* forward homogeneous transformation *)
		Table[		
			(* a string represents the name of the link on which the point is rigidly attached to.*)
			linkName = argList[[i,1]];  
			(* the relative argList[[i,2]] of the point from the origin of the link (in the link coordinates). *)
			offset   = Flatten@argList[[i,2]];
			
			(* take the index of parent joint of the rigid link *)
			jIndex   = First@pIndices[linkName];
			
			(* initialize the Jacobian with fixed length (ndof) *)
			Jz    = ConstantArray[0,{6,Length[gst0]}];
			
			(* compute homogeneous transformation from base to the point with initial tool configuration (q=0)*)
			gs0 = gst0[[jIndex]].Screws`RPToHomogeneous[I3, offset];
			
			
			If[jIndex != 0, (* the link is not the base link *)
				(* assign the dependent coordinate indices *)
				curIndices = chainIndices[[jIndex]];		
				(* compute body jacobian *)		
				Jz[[;;,curIndices]]=RobotLinks`BodyJacobian[Sequence@@kinTwists[[jIndex]], gs0];
			];
					
			Je[i] = Jz;
			,
			{i,np}
		];
		Return[Table[Je[i],{i,1,np}]];	
	];
	
	

ToEulerAngles[gst_,q_] :=
	Block[{R, R0, Rw, yaw, roll, pitch,q0subs},
		(* compute rigid orientation*)
		R = Screws`RigidOrientation[gst];
		(* compute rigid orientation with initial tool configuration (q = 0) *)
		
		q0subs = Join[Sequence @@ Map[Association[#-> 0] &, Flatten@q]];
		R0 = R/.q0subs;
		(* compute spatial orientation *)
		Rw = R.Transpose[R0];
		(* compute Euler angles *)
		yaw=ArcTan[Rw[[1,1]],Rw[[2,1]]];
		roll=ArcTan[Rw[[3,3]],Rw[[3,2]]];
		pitch=ArcTan[Rw[[3,3]],-Rw[[3,1]]Cos[roll]];
		
		Return[{roll,pitch,yaw}];
	];
	



	
ComputeCartesianPositions[args__,robotKinematics_] :=
	Block[{pos, gst},
		
		(* first compute the forward kinematics *)
		gst = ComputeForwardKinematics[args,robotKinematics];
		
		(* compute rigid positions *)
		pos = Map[Screws`RigidPosition[#]&,gst];
		
		Return[pos];
	];

ComputeEulerAngles[args__,robotKinematics_,q_] :=
	Block[{pos, gst},
		
		(* first compute the forward kinematics *)
		gst = ComputeForwardKinematics[args,robotKinematics];
		
		(* compute rigid positions *)
		pos = Map[ToEulerAngles[#,q]&,gst];
		
		Return[pos];
	];
	
ComputeSpatialJacobians[args__,robotKinematics_] :=
	Block[{pos, argList = {args}, np, i, Je, pIndices,gst0,kinTwists,chainIndices,
		linkName, offset, jIndex, Jz, gs0, curIndices},
			
		
		(* extract the number of points to be calculated *)
		np = Length[argList];
		
		pIndices  = robotKinematics["pIndices"];
		gst0      = robotKinematics["gst0"]; 
		kinTwists = robotKinematics["kinTwists"];
		chainIndices = robotKinematics["chainIndices"];
		
		(* forward homogeneous transformation *)
		Je = Table[		
			(* a string represents the name of the link on which the point is rigidly attached to.*)
			linkName = argList[[i,1]];  
			(* the relative offset of the point from the origin of the link (in the link coordinates). *)
			offset   = Flatten@argList[[i,2]];
			
			(* take the index of parent joint of the rigid link *)
			jIndex   = First@pIndices[linkName];
			
			(* initialize the Jacobian with fixed length (ndof) *)
			Jz    = ConstantArray[0,{6,Length[gst0]}];
			
			(* compute homogeneous transformation from base to the point with initial tool configuration (q=0)*)
			gs0 = gst0[[jIndex]].Screws`RPToHomogeneous[I3, offset];
			
			
			If[jIndex != 0, (* the link is not the base link *)				
				(* assign the dependent coordinate indices *)
				curIndices = chainIndices[[jIndex]];		
				(* compute spatial jacobian *)		
				Jz[[;;,curIndices]]=RobotLinks`SpatialJacobian[Sequence@@kinTwists[[jIndex]], gs0];
			];
					
			Jz
			,
			{i,np}
		];
		Return[Je];	
	];	
	
	
ComputeForwardKinematics::usage = 
	"ComputeForwardKinematics[{link1,offset1},...,{link$n,offset$n},robotKinematics] \
Compute the forward homogeneous transformation from the base to the point that is rigidly attached \
to a link with a given offset."
ComputeForwardKinematics[args__,robotKinematics_] :=
	Block[{i,np,gst,gs0,linkName,offset,jIndex,pIndices,gst0,kinTwists,
		argList = {args}}, (* turn arguments into a real list *)
		
		
		
		(* extract the number of points to be calculated *)
		np = Length[argList];
		
		pIndices  = robotKinematics["pIndices"];
		gst0      = robotKinematics["gst0"]; 
		kinTwists = robotKinematics["kinTwists"];
		
		(* forward homogeneous transformation *)
		Table[		
			(* a string represents the name of the link on which the point is rigidly attached to.*)
			linkName = argList[[i,1]];  
			(* the relative offset of the point from the origin of the link (in the link coordinates). *)
			offset   = Flatten@argList[[i,2]];
			
			(* take the index of parent joint of the link *)
			jIndex   = First@pIndices[linkName];
			
			(* compute homogeneous transformation from base to the point with initial tool configuration (q=0)*)
			gs0 = gst0[[jIndex]].Screws`RPToHomogeneous[I3, offset];
			
			(* compute forward kinematics *)
			If[jIndex == 0, (* the link is the base link *)
				gst[i]=gs0;
				,
				gst[i]=RobotLinks`ForwardKinematics[Sequence@@kinTwists[[jIndex]], gs0];
			];
					
			,
			{i,np}
		];
		Return[Table[gst[i],{i,1,np}]];	
	];


	










	
GetKinematicTree[robotJoints_] := 
	Block[{childIndex,link,jointIndex,terminals,numBranch,tree,i,j, tIndex}, 
		
		(* get the indices of child links *)
		childIndex = ExtraUtils`GetFieldIndices[robotJoints, "child"];
		
		(* get the terminal links of the multi-body system *)
		terminals = GetTerminalLink[robotJoints];
		If[SameQ[terminals, None],
  			Message[GetTerminalLink::notfound];
  			Abort[];
  		];
		(* the number of terminal links determines the number of branches in the 
		kinematic tree. *)
		tIndex = Flatten[childIndex /@ terminals];
		numBranch = Length[tIndex];
		
		(* initialize the tree structure *)
		tree=Transpose@{tIndex};
		
		(* iteratively get the joint indices of each kinematic branch. *)
		Table[
			(* find the parent link of the first joint in the branch. *)
		  	link=robotJoints[[tIndex[[i]]]]["parent"];
		  	
		  	(* find the parent joint until there is no child joint *)
		  	While[
		  		(* check if the current link is the child link of some joint *)
		  		KeyExistsQ[childIndex,link], 
		  		
		  		(* get the index of this parent joint *)
		    	jointIndex=childIndex[link];
		    	
		    	(* append this link to the current branch *)
			    tree[[i]]=Flatten@AppendTo[tree[[i]],jointIndex];
			    
			    (* set the current link to the child link of the joint *)
		    	link=robotJoints[[jointIndex]][[1]]["parent"];
		  ];
		  ,
		  {i,1,numBranch}
		];
		
		(* return the kinematic tree structure *)
		Return[Reverse[tree, {2}]];			
	];

GetTerminalLink::notfound = " Unable to find the terminal links of the model.";
GetTerminalLink[robotJoints_] :=
	Block[{plink, clink, terminallink = None, i, links}, 
		
		(* extract the name list of the parent and child links *)
		plink = Map[ToString@#["parent"] &, robotJoints];
 		clink = Map[ToString@#["child"] &, robotJoints];
 		
 		(* the terminal (end) link is the child link that is not a parent link of any joint *)
 		links = Table[
 			(* check if the current link is a member of the child link list*)
 			If[! MemberQ[plink, clink[[i]]],
 				
 				clink[[i]]
    		]
  			,
  			{i, Length[clink]}
  		];
  		terminallink = Pick[links, Not /@ Map[# === Null &, links]];
  		If[SameQ[terminallink, None],
  			Message[GetTerminalLink::notfound];
  		];
   		Return[terminallink];
 	];

GetBaseLink[robotJoints_] :=
	Block[{plink, clink, baselink = None, i}, 
		
		(* extract the name list of the parent and child links *)
		plink = Map[ToString@#["parent"] &, robotJoints];
 		clink = Map[ToString@#["child"] &, robotJoints];
 		
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
      					(* warning if there are dublicated base link *)
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
GetRelativeTwist[joint_?AssociationQ]:=
	Block[{type,axis,xi},
		type=joint["type"];
		axis=Rationalize@Flatten@joint["axis"];	
		(* Relative, DH-style twists, see MLS p. 94 *)
		(* Note that the twists are in body frame, so q = 0 *)	
		Switch[type,
			"prismatic",
			(* xi : (q = 0, v = axis ) *)
			xi = RobotLinks`PrismaticTwist[{0, 0, 0}, axis];
			,
			"revolute",
			(* xi : (q = 0, w = axis, v (handled by function) *)
			xi = RobotLinks`RevoluteTwist[{0, 0, 0}, axis];
			,
			"continuous",
			(* xi : (q = 0, w = axis, v (handled by function) *)
			xi = RobotLinks`RevoluteTwist[{0, 0, 0}, axis];
			,
			"fixed",
			xi = RobotLinks`RevoluteTwist[{0, 0, 0}, axis];
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
			{roll,pitch,yaw}=Rationalize@Flatten@link["origin"]["rpy"];
			(* From the definition of URDF link:
			Represents the rotation around fixed axis: first roll around x, then pitch 
			around y and finally yaw around z. All angles are specified in radians. *)
			R = RotZ[yaw].RotY[pitch].RotX[roll];
			,
			R = IdentityMatrix[3];
		];
		Ic = Rationalize@link["inertia"];
		
		
		(* compute inertia in the joint coordiate, and return *)
		Return[Transpose[R].Ic.R];
	];


GetMass[link_?AssociationQ]:= Rationalize@link["mass"];


GetPosition[arg_?AssociationQ] := Rationalize@Flatten@arg["origin"]["xyz"];


GetRotationMatrix[joint_?AssociationQ]:=
	Block[{roll,pitch,yaw,R},		
		If[KeyExistsQ[joint["origin"],"rpy"],
			{roll,pitch,yaw} = Rationalize@Flatten@joint["origin"]["rpy"];
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
	"ComputeHomogeneousTransforms[robotJoints] Compute the homogeneous transformation of \
each joint from the base by the initial tool configuration."
ComputeHomogeneousTransforms[robotJoints_] :=
	Block[{kinTree,branch,EL,rL,joint,gst0,i,j},
		
		
		gst0[0] = E4; (* floating base homogeneous transformation*)
		(* compute kinematic tree *)
		kinTree = GetKinematicTree[robotJoints];
		Table[
			branch = kinTree[[i]];
			(** Kinematics **)
			(* From SVA, we're given ^{i}X_{i-1} = X(^{i}E_{i-1}, ^{i-1}r)  -  spatial transform from i-1 to i *)
			(* With this, we can put together g_{i-1,i}(0) = T(^{i-1}E_{i}, ^{i-1}r)  -  homogeneous transfrom from i to i-1 *)
			Table[
				joint = Part[robotJoints,branch[[j]]];
				EL = GetRotationMatrix[joint];
				rL = GetPosition[joint];
				If[j==1,
					gst0[branch[[j]]] = gst0[0].Screws`RPToHomogeneous[EL, rL];
					,
					gst0[branch[[j]]] = gst0[branch[[j-1]]].Screws`RPToHomogeneous[EL, rL];
				];
				,
				{j,1,Length[branch]}
			];
			,
			{i,1,Length[kinTree]}
		];
		
		Return[Table[gst0[i],{i,1,Length[robotJoints]}]];
	];



	



GetChainIndices::usage = "GetChainIndices[robotJoints] returns the chain indices of each joint.";
GetChainIndices[robotJoints_] :=
	Block[{kinTree,chainIndices,jList,i,j},
		
		kinTree = GetKinematicTree[robotJoints];
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
		Return[Table[chainIndices[i], {i, Length[robotJoints]}]];		 
	];
	
GetKinematicChains::usage = 
	"GetKinematicChains[robotJoints,q,gst0,chainIndices]	Return the kinematic chains from the base to each joint.";
GetKinematicChains[robotJoints_,q_,gst0_,chainIndices_] :=
	Block[{xi, xib, basechain, chains, i, j,qvec},
		
					
		(* compute twist for each coordinates (joints) *)
		xi = ComputeTwists[robotJoints,gst0];
		
		qvec = ExtraUtils`Vec[q];
		(* construct twist pairs for each joint chain *)
		chains = Table[
			Table[
				Join[{Part[xi, chainIndices[[i, j]]]},Part[qvec, chainIndices[[i, j]]]]
				,
				{j,Length[chainIndices[[i]]]}
			]	
			,
			{i,Length[robotJoints]}
		];
		
		Return[chains];
	];
	

ComputeTwists::usage = 
	"ComputeTwists[robotJoints,gst0]	computes relative twist (in joint frame i) to base frame S.";
ComputeTwists[robotJoints_,gst0_] :=
	Block[{xi,twist,i},  
		
		
		xi = Table[
			(* compute relative twist *)
			twist = GetRelativeTwist[robotJoints[[i]]];
			
			(* Transform relative twist (in joint frame i) to base frame S - using adjoint transform for twists (MLS, p .55, Eq. (2.58) *)
			(* Same as spatial transform (Featherstone, p .22, Eq. (2.26) -- note that twist is (v, w) and Plucker is (w, v) *)
			(* URDF Docs say that joint axis is in joint frame, so we will use the joint's frame in S to transform twist *)
			(* See http://www.ros.org/wiki/urdf/XML/joint *)
			
			Screws`RigidAdjoint[gst0[[i]]].twist
			, 
			{i, Length[robotJoints]}
		];
		Return[xi];
	];






(* Basic rotation matrices *)

RotX[q_]:=ExtraUtils`CRoundEx[N@{{1,0,0},{0,Cos[q],-Sin[q]},{0,Sin[q],Cos[q]}}];
RotY[q_]:=ExtraUtils`CRoundEx[N@{{Cos[q],0,Sin[q]},{0,1,0},{-Sin[q],0,Cos[q]}}];
RotZ[q_]:=ExtraUtils`CRoundEx[N@{{Cos[q],-Sin[q],0},{Sin[q],Cos[q],0},{0,0,1}}];	
	
	
End[]

EndPackage[]

