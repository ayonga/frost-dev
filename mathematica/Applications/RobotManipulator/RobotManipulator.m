(* Wolfram Language Package *)

(* :Title: RobotManipulator.m *)

BeginPackage["RobotManipulator`",{"Screws`","RobotLinks`","ExtraUtils`"}]
(* Exported symbols added here with SymbolName::usage *) 


InitializeModel::usage = 
	"InitializeModel[robotJoints, q] initializes a model from an URDF file, with a specified \
model type (either floating or planar). "

PotentialEnergy::usage = 
	"PotentialEnergy[robotLinks,robotJoints] compute the potential energy of the mechanical \
	system due to the gravity forces."

GravityVector::usage = 
	"GravityVector[q,robotLinks,robotJoints] computes the gravity vector of the robot model."
	
InertiaMatrix::usage = 
	"InertiaMatrix[robotLinks, robotJoints] computes the inertia matrix of the robot model."	



ComputeComPosition::usage = 
	"ComputeComPosition[robotLinks,robotJoints] returns the position vectors of the \
center of mass of the robot."





ComputeBodyJacobians::usage =
	"ComputeBodyJacobians[{frame1,offset1,rpy1},...,{frame$n,offset$n,rpy$n},nDof] \
Compute the body jacobian of the point that is rigidly attached to the frame with a given offset."; 





ComputeCartesianPositions::usage = 
	"ComputeCartesianPositions[{frame1,offset1, rpy1},...,{frame$n,offset$n,rpy$n}] computes \
the 3-dimensional cartesian positions specified by the frames and relative offset vectors";

ComputeEulerAngles::usage = 
	"ComputeEularAngles[{frame1,offset1,rpy1},...,{frame$n,offset$n,rpy$n}] computes \
the 3-dimensional cartesian positions specified by the frames and relative offset vectors";

ComputeSpatialJacobians::usage = 
	"ComputeSpatialJacobians[{frame1,offset1,rpy1},...,{frame$n,offset$n,rpy$n},nDof] computes Jacobian of\
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




ComputeForwardKinematics::usage = 
	"ComputeForwardKinematics[{twists$1,gst0$1},...,{twists$N,gst0$N}] \
	Compute the forward homogeneous transformation from the base to the coordinate frame.";	

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











	
	




		
(* The contributions of motor inertia to the robot dynamics are not addressed
in the URDF model definition. To include the motor inertia in the dynamics 
please include the motor inertia information when call InertiaMatrix[] function.
NOTE: the provided motor inertia value should be the reflected inertia value at 
the joint side = original actuator inertia * gear ratio ^2.
*)
InertiaMatrix[robotLinks__,nDof_] :=
	Block[{MM, links, Je, De, i},
		
		links = {robotLinks};
		
		(* the mass/inertia matrix *)
		MM = Map[ExtraUtils`BlockDiagonalMatrix[{I3*GetMass[#],GetInertia[#]}]&, links];
		
		(* compute body jacobians of each link CoM position *)
		Je = ComputeBodyJacobians[robotLinks, nDof];
		
		De = Sum[Transpose[Je[[i]]].MM[[i]].Je[[i]],{i,1,Length[links]}];
		
		
		Return[De];
	];
InertiaMatrix::inequal = 
	"The length of given motor inertia `1` is not equal to the number of joints `2`.";

ComputeComPosition[robotLinks__] :=
	Block[{links,linkPos, masses, pcom, i},
		
		links = {robotLinks};
		
		(* center of mass positions of each link*)
		linkPos = ComputeCartesianPositions[robotLinks];
		
		(* get mass of links *)
		masses = Map[GetMass[#]&, links];
		
		pcom = {Sum[Times[masses[[i]], linkPos[[i]]], {i, 1, Length[links]}]}/Total[masses];		
		
		Return[pcom];
	];
	
PotentialEnergy[robotLinks__] :=
	Block[{links, linkPos, masses, Ve, i},
		links = {robotLinks};
		
		(* center of mass positions of each link*)
		linkPos = ComputeCartesianPositions[robotLinks];
		
		(* get mass of links *)
		masses = Map[GetMass[#]&, links];
		
		(* sum up the gravity potential energy of links *)
		Ve = Sum[grav*masses[[i]]*linkPos[[i,3]],{i,1,Length[links]}];
		
		Return[Ve];
	];	

GravityVector[robotLinks__,q_] :=
	Block[{V, ge},
		(* compute potential energy of the robot *)
		V = PotentialEnergy[robotLinks];
		
		(* take partial derivatives to get the gravity vector *)
		ge = ExtraUtils`Vec[D[Flatten[V],{Flatten[q],1}]];
		
		Return[ge];
	];

ComputeBodyJacobians[args__,nDof_] :=
	Block[{argList = {args}, np, i, Je, twist, Jz, gs0, curIndices},
			
		
		(* extract the number of points to be calculated *)
		np = Length[argList];
		
		
		(* forward homogeneous transformation *)
		Je = Table[		
			(* a string represents the name of the link on which the point is rigidly attached to.*)
			twist = GetTwist[argList[[i]]]; 
			(* the relative offset of the point from the origin of the frame (in the frame coordinates). *)
			gs0   = GetGST0[argList[[i]]];
			
			
			(* initialize the Jacobian with fixed length (ndof) *)
			Jz    = ConstantArray[0,{6,IntegerPart@nDof}];
			If[!ExtraUtils`EmptyQ[twist], (* the link is the base link *)		
				(* assign the dependent coordinate indices *)
				curIndices = GetChainIndices[argList[[i]]];
				(* compute spatial jacobian *)		
				Jz[[;;,curIndices]]=RobotLinks`BodyJacobian[Sequence@@twist, gs0];
			];
					
			Jz
			,
			{i,np}
		];
		Return[Je];	
	];	
	
	

ToEulerAngles[gst_,gst0_] :=
	Block[{R, R0, Rw, yaw, roll, pitch,q0subs},
		(* compute rigid orientation*)
		R = Screws`RigidOrientation[gst];
		(* compute rigid orientation with initial tool configuration (q = 0) *)
		R0 = Screws`RigidOrientation[gst0];
		(* compute spatial orientation *)
		Rw = R.Transpose[R0];
		(* compute Euler angles *)
		yaw=ArcTan[Rw[[1,1]],Rw[[2,1]]];
		roll=ArcTan[Rw[[3,3]],Rw[[3,2]]];
		pitch=ArcTan[Rw[[3,3]],-Rw[[3,1]]Cos[roll]];
		
		Return[{roll,pitch,yaw}];
	];
	



	
ComputeCartesianPositions[args__] :=
	Block[{pos, gst},
		
		(* first compute the forward kinematics *)
		gst = ComputeForwardKinematics[args];
		
		(* compute rigid positions *)
		pos = Map[Screws`RigidPosition[#]&,gst];
		
		Return[pos];
	];

ComputeEulerAngles[args__] :=
	Block[{pos, gst, gst0, argList = {args}},
		
		(* first compute the forward kinematics *)
		gst = ComputeForwardKinematics[args];
		gst0 = Map[#["gst0"] &, argList];
		(* compute rigid positions *)
		pos = MapThread[ToEulerAngles,{gst,gst0}];
		
		
		Return[pos];
	];
	
ComputeSpatialJacobians[args__,nDof_] :=
	Block[{argList = {args}, np, i, Je, twist,curIndices,
		Jz, gs0},
			
		
		(* extract the number of points to be calculated *)
		np = Length[argList];
		
		
		(* forward homogeneous transformation *)
		Je = Table[		
			(* a string represents the name of the link on which the point is rigidly attached to.*)
			twist = GetTwist[argList[[i]]]; 
			(* the relative offset of the point from the origin of the frame (in the frame coordinates). *)
			gs0   = GetGST0[argList[[i]]];
			
			
			
			(* initialize the Jacobian with fixed length (ndof) *)
			Jz    = ConstantArray[0,{6,IntegerPart@nDof}];
			If[!ExtraUtils`EmptyQ[twist], (* the link is the base link *)		
				(* assign the dependent coordinate indices *)
				curIndices = GetChainIndices[argList[[i]]];
				(* compute spatial jacobian *)		
				Jz[[;;,curIndices]]=RobotLinks`SpatialJacobian[Sequence@@twist, gs0];
			];
					
			Jz
			,
			{i,np}
		];
		Return[Je];	
	];	
	
	

ComputeForwardKinematics[args__] :=
	Block[{i,np,gst,gs0,twist,argList = {args}}, (* turn arguments into a real list *)
		
		
		
		(* extract the number of points to be calculated *)
		np = Length[argList];
		
		
		(* forward homogeneous transformation *)
		Table[		
			(* a string represents the name of the link on which the point is rigidly attached to.*)
			twist = GetTwist[argList[[i]]]; 
			(* the relative offset of the point from the origin of the frame (in the frame coordinates). *)
			gs0   = GetGST0[argList[[i]]];
			
			(* compute forward kinematics *)
			If[ExtraUtils`EmptyQ[twist], (* the link is the base link *)
				gst[i]=gs0;
				,
				gst[i]=RobotLinks`ForwardKinematics[Sequence@@twist, gs0];
			];
					
			,
			{i,np}
		];
		Return[Table[gst[i],{i,1,np}]];	
	];


	
GetInertia[arg_?AssociationQ]:= Rationalize@arg["Inertia"];


GetMass[arg_?AssociationQ]:= Rationalize@arg["Mass"];


GetPosition[arg_?AssociationQ] := Rationalize@Flatten@arg["Offset"];


GetRotationMatrix[arg_?AssociationQ]:= Rationalize@arg["R"];


GetGST0[arg_?AssociationQ]:= Rationalize@arg["gst0"];

GetTwist[arg_?AssociationQ]:= Rationalize@arg["TwistPairs"];

GetChainIndices[arg_?AssociationQ]:= Flatten@{arg["ChainIndices"]};



(*
GetKinematicTree[robotJoints_] := 
	Block[{childIndex,link,jointIndex,terminals,numBranch,tree,i,j, tIndex}, 
		
		(* get the indices of child links *)
		childIndex = ExtraUtils`GetFieldIndices[robotJoints, "Child"];
		
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
		  	link=robotJoints[[tIndex[[i]]]]["Parent"];
		  	
		  	(* find the parent joint until there is no child joint *)
		  	While[
		  		(* check if the current link is the child link of some joint *)
		  		KeyExistsQ[childIndex,link], 
		  		
		  		(* get the index of this parent joint *)
		    	jointIndex=childIndex[link];
		    	
		    	(* append this link to the current branch *)
			    tree[[i]]=Flatten@AppendTo[tree[[i]],jointIndex];
			    
			    (* set the current link to the child link of the joint *)
		    	link=robotJoints[[jointIndex]][[1]]["Parent"];
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
		plink = Map[ToString@#["Parent"] &, robotJoints];
 		clink = Map[ToString@#["Child"] &, robotJoints];
 		
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
		plink = Map[ToString@#["Parent"] &, robotJoints];
 		clink = Map[ToString@#["Child"] &, robotJoints];
 		
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



(*GetRelativeTwist[joint_?AssociationQ]:=
	Block[{type,axis,xi},
		type=joint["type"];
		axis=Rationalize@Flatten@joint["axis"];	*)
GetRelativeTwist[type_, axis_]:=
	Block[{xi,axisv},
		axisv=Rationalize@Flatten@axis;
		(* Relative, DH-style twists, see MLS p. 94 *)
		(* Note that the twists are in body frame, so q = 0 *)	
		Switch[type,
			"prismatic",
			(* xi : (q = 0, v = axis ) *)
			xi = RobotLinks`PrismaticTwist[{0, 0, 0}, axisv];
			,
			"revolute",
			(* xi : (q = 0, w = axis, v (handled by function) *)
			xi = RobotLinks`RevoluteTwist[{0, 0, 0}, axisv];
			,
			"continuous",
			(* xi : (q = 0, w = axis, v (handled by function) *)
			xi = RobotLinks`RevoluteTwist[{0, 0, 0}, axisv];
			,
			"fixed",
			xi = RobotLinks`RevoluteTwist[{0, 0, 0}, axisv];
			,
			_, (* none *)
			xi = Null;
			Message[GetRelativeTwist::undefinedAxisType, type];
		];
		Return[xi];
	];
*)


	

(*
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
	

GetTwistPairs[robotJoints_,q_] :=
	Block[{xi, chainIndices, chains, i, j, qvec = ExtraUtils`Vec[q]},
		
					
		(* compute twist for each coordinates (joints) *)
		xi = ComputeTwists[robotJoints];
		
		(* construct twist pairs for each joint chain *)
		chains = Table[
			chainIndices=Flatten@{robotJoints[[i]]["chainIndices"]};
			Table[
				Join[{Part[xi, chainIndices[[j]]]},Part[qvec, chainIndices[[j]]]]
				,
				{j,Length[chainIndices]}
			]	
			,
			{i,Length[robotJoints]}
		];
		
		Return[chains];
	];
	


ComputeTwists[robotJoints_] :=
	Block[{xi,twist,i},  
		
		
		xi = Table[
			(* compute relative twist *)
			twist = GetRelativeTwist[robotJoints[[i]]];
			
			(* Transform relative twist (in joint frame i) to base frame S - using adjoint transform for twists (MLS, p .55, Eq. (2.58) *)
			(* Same as spatial transform (Featherstone, p .22, Eq. (2.26) -- note that twist is (v, w) and Plucker is (w, v) *)
			(* URDF Docs say that joint axis is in joint frame, so we will use the joint's frame in S to transform twist *)
			(* See http://www.ros.org/wiki/urdf/XML/joint *)
			
			Screws`RigidAdjoint[robotJoints[[i]]["gst0"]].twist
			, 
			{i, Length[robotJoints]}
		];
		Return[xi];
	];

*)




(* Basic rotation matrices *)

RotX[q_]:=ExtraUtils`CRoundEx[N@{{1,0,0},{0,Cos[q],-Sin[q]},{0,Sin[q],Cos[q]}}];
RotY[q_]:=ExtraUtils`CRoundEx[N@{{Cos[q],0,Sin[q]},{0,1,0},{-Sin[q],0,Cos[q]}}];
RotZ[q_]:=ExtraUtils`CRoundEx[N@{{Cos[q],-Sin[q],0},{Sin[q],Cos[q],0},{0,0,1}}];	
	
	
End[]

EndPackage[]

