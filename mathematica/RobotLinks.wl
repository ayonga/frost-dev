(* ::Package:: *)

(*
 *	RobotLinks.m - robot kinematics package using Screws.m
 *
 *		    Richard Murray and Sudipto Sur
 *	     Division of Engineering and Applied Science
 *		  California Institute of Technology
 *			  Pasadena, CA 91125
 *
 * RobotLinks.m is a Mathematica package for performing screw calculus.
 * It uses the basic functions defined in Screws.m to implement some
 * common function in robot kinematics. It follows the treatment described
 * Chapter 3 of _A Mathematical Introduction to Robotic Manipulation_,
 * by R. M. Murray, Z. Li, and S. S. Sastry (CRC Press, 1994).
 *
 * Copyright (c) 1994, Richard Murray.
 * Permission is granted to copy, modify and redistribute this file, 
 * provided that this header message is retained.
 *
 * Revision history:
 *
 * Version 1.1 (10 Dec 1992)
 *   Split off code from Screws.m
 *)

BeginPackage["RobotLinks`", {"Screws`","ExtraUtils`"}];(* "pbar`"}];*)

RevoluteTwist::usage=
 "RevoluteTwist[q,w] gives the 6-vector corresponding to point q on \
  the axis and a screw with axis w for a revolute joint";

PrismaticTwist::usage=
 "PrismaticTwist[q,w] gives the 6-vector corresponding to point q \
  on the axis and a screw with axis w for a prismatic joint";

ForwardKinematics::usage=
 "ForwardKinematics[{xi1,th1},...,{xiN,thN},g0] computes the
  forward kinematics via the product of exponentials formula";

SpatialJacobian::usage=
 "SpatialJacobian[{xi1,th1},{xi2,th2},...,g0] computes the spatial \
  manipulator Jacobian of a robot defined by the given twists";

BodyJacobian::usage=
 "BodyJacobian[{xi1,th1},{xi2,th2},...,g0] computes the body \
  manipulator Jacobian of a robot defined by the given twists";

InertiaToCoriolis::usage=
 "InertiaToCoriolis[M, theta, omega] computes the Coriolis matrix given the \
  inertia matrix, M, a list of the joint variables, theta, and a list of
  joint velocities, omega";


Begin["`Private`"];

(* Modifications to existing defs *)
Unprotect[ArcCos];	ArcCos[Cos[expr_]]:=expr;	Protect[ArcCos];
Unprotect[Times];	Times[1.,expr_]:=expr;		Protect[Times];

(* Gives Xi 6 vector given axis and point on axis *)
RevoluteTwist[q_,w_]:= Flatten[{Cross[q,w],w}];

(* Gives Xi 6 vector given point on axis q and axis w *)		
PrismaticTwist[q_,w_]:= Flatten[{w, {0,0,0}}];
		
(* Compute the forward kinematic map via the product of expoentials *)
ForwardKinematics[args__, gst0_]:= 
  Module[
    { g, i,
      $MaxExtraPrecision=6,
      argList = {args},		(* turn arguments into a real list *)
      n = Length[{args}]	(* decide on the number of joints *)
    },

    (* Initialize the transformation matrix *)
    g = TwistExp[argList[[1,1]], argList[[1,2]]];   

    (* Build up the Jacobian joint by joint *)
    For[i = 2, i <= n, i++,
      (* Update the transformation matrix *)
      g = g . TwistExp[argList[[i,1]], argList[[i,2]]];
    ];      

    (* Finish by multiplying by the initial tool configuration *)
    Chop[g . gst0]
  ];
			

(* Construct the Jacobian for a robot of any no of links *)
SpatialJacobian[args__, gst0_]:= 
  Module[
    { i, xi, Js, g,
      argList = {args},		(* turn arguments into a real list *)
      n = Length[{args}]	(* decide on the number of joints *)
    },

    (* First initialize the Jacobian and compute the first column *)
    Js = {argList[[1,1]]};
    g = TwistExp[argList[[1,1]], argList[[1,2]]];   

    (* Build up the Jacobian joint by joint *)
    For[i = 2, i <= n, i++,
      (* Compute this column of the Jacobian and append it to Js *)
      xi = RigidAdjoint[g] . argList[[i,1]];
      Js = Join[Js, {xi}];      

      (* Update the transformation matrix *)
      g = g . TwistExp[argList[[i,1]], argList[[i,2]]];
    ];      

    (* Return the Jacobian *)
    Transpose[Chop[Js]]
  ];
			
BodyJacobian[args__, gst0_]:= 
  Module[
    { i, xi, Jb, g,
      argList = {args},		(* turn arguments into a real list *)
      n = Length[{args}]	(* decide on the number of joints *)
    },

    (* Initialize the Jacobian and the transformation matrix *)
    Jb = {};
    g = gst0;

    (* Build up the Jacobian joint by joint *)
    For[i = n, i >= 1, i--,
      (* Compute this column of the Jacobian and prepend it to Jb *)
      xi = RigidAdjoint[RigidInverse[g]] . argList[[i,1]];
      Jb = Join[{xi}, Jb];      

      (* Update the transformation matrix *)
      g = TwistExp[argList[[i,1]], argList[[i,2]]] . g;
    ];      

    (* Return the Jacobian *)
    Transpose[Chop[Jb]]
  ];

InertiaToCoriolis[M_, theta_, omega_] :=
  Module[
    {Cmat, i, j, k, n = Length[M],q,w},
	q = Flatten[theta];
	w = Flatten[omega];
    (* Brute force calculation *)
    Cmat = Array[0&, {n,n}];
	
    For[i = 1, i <= n, ++i,
      For[j = 1, j <= n, ++j,
        For[k = 1, k <= n, ++k,
          Cmat[[i,j]] += 1/2 * w[[k]] *
          (D[M[[i,j]], q[[k]]] + D[M[[i,k]], q[[j]]] - D[M[[j,k]], q[[i]]]);
        ]
      ]
    ];
    Chop@Cmat
  ];
  
End[];
EndPackage[];

