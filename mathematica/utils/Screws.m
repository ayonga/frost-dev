(* ::Package:: *)

(*
 *	      Screws.m - a screw package for mathematica
 *
 *		    Richard Murray and Sudipto Sur
 *				   
 *	     Division of Engineering and Applied Science
 *		  California Institute of Technology
 *			  Pasadena, CA 91125
 *
 * Screws.m is a Mathematica package for performing screw calculus.
 * It follows the treatment described in _A Mathematical Introduction to
 * Robotic Manipulation_, by R. M. Murray, Z. Li, and S. S. Sastry
 * (CRC Press, 1994).  This package implements screw theory in
 * 3-dimensional Euclidean space (some functions work in n dimensions).
 *
 * Copyright (c) 1994, Richard Murray.
 * Permission is granted to copy, modify and redistribute this file, 
 * provided that this header message is retained.
 *
 * Revision history:
 *
 * Version 1.1 (7 Dec 1991)
 *   Initial implementation (as RobotLinks.m)
 *
 * Version 1.2 (10 Dec 1992)
 *   Removed robot specific code, leaving screw theory operations only
 *   Changed name to Screws.m to reflect new emphasis
 *   Rewrote some functions to use features of Mma more effectively
 *
 * Version 1.2a (30 Jan 1995)
 *   Modified TwistExp, TwistMagnitude and TwistAxis, 10/6/94, Jeff Wendlandt
 *   ...Changed If[w.w != 0, ... to If[(MatchQ[w,{0,0,0}] || .., ...
 *   If[w.w != 0,... does not work when w is a symbolic expression.
 *   
 *)

BeginPackage["Screws`"];

(*
 * Function usage
 *
 * Document all of the functions which are defined in this file.
 * This is the same line that appears in the printed documentation.
 *)

AxisToSkew::usage=Skew::usage=
  "AxisToSkew[w] generates skew symmetric matrix given 3 vector w";

SkewToAxis::usage=UnSkew::usage=
  "SkewToAxis[S] extracts vector w from skewsymmetric matrix S";

SkewExp::usage=
 "SkewExp[w,(theta)] gives the matrix exponential of an axis w.
  Default value of Theta is 1.";

RotationAxis::usage=
  "RotationAxis[R] finds the rotation axis given the rotation matrix R";

RotationQ::usage=
  "RotationQ[m] tests whether matrix m is a rotation matrix";

RPToHomogeneous::usage=
  "RPToHomogeneous[R,p] forms homogeneous matrix from rotation matrix R \
  and position vector p";

TwistExp::usage=
 "TwistExp[xi,(Theta)] gives the matrix exponential of a twist xi.
  Default value of Theta is 1.";

TwistToHomogeneous::usage=
  "TwistToHomogeneous[xi] converts xi from a 6 vector to a 4X4 matrix";

HomogeneousToTwist::usage=
  "HomogeneousToTwist[xi] converts xi from a 4x4 matrix to a 6 vector";

RigidOrientation::usage=
  "RigidOrientation[g] extracts rotation matrix R from g";

RigidPosition::usage=
  "RigidPosition[g] extracts position vector p from g";

RigidTwist::usage=
  "RigidTwist[g] extracts 6 vector xi from g";

TwistPitch::usage=
  "TwistPitch[xi] gives pitch of screw corresponding to a twist";

TwistAxis::usage=
  "TwistAxis[xi] gives axis of screw corresponding to a twist";

TwistMagnitude::usage=
  "TwistMagnitude[xi] gives magnitude of screw corresponding to a twist";

RigidAdjoint::usage=
  "RigidAdjoint[g] gives the adjoint matrix corresponding to g";

RigidInverse::usage=
  "RigidInverse[g] gives the inverse transformation of g";

PointToHomogeneous::usage=
  "PointToHomogeneous[q] gives the homogeneous representation of a point";

VectorToHomogeneous::usage=
  "VectorToHomogeneous[q] gives the homogeneous representation of a vector";

ScrewToTwist::usage=
  "ScrewToTwist[h, q, w] returns the twist coordinates of a screw";

DrawScrew::usage=
  "DrawScrew[q, w, h] generates a graphical description of a screw";

DrawFrame::usage=
  "DrawFrame[p, R] generates a graphical description of a coordinate frame";

ScrewSize::usage=
  "ScrewSize sets the length of a screw for DrawScrew";

AxisSize::usage=
  "AxisSize sets the length of an axis vector for DrawFrame";

(* Utility functions which might be useful in this context *)
StackRows::usage="StackRows[Mat1,Mat2,..] stacks matrix rows together";
StackCols::usage="StackCols[Mat1,Mat2,...] stacks matrix columns together";

(*
 * Error messages
 *
 * Use the Mma error message facility so that we can turn off error
 * messages that we don't want to hear about
 *
 *)

AxisToSkew::wrongD = "`1` is not a 3 vector.";
SkewToAxis::notskewsymmetric = "`1` is not a skew symmetric matrix";
Screws::wrongDimensions = "`1`: Dimensions of input matrices incorrect.";
Screws::notSquare = "`1`: Input matrix is not square.";
Screws::notVector = "`1`: Input is not a vector.";

(* Begin private section of the package *)
Begin["`Private`"];

(*
 * Rotation matrices
 *
 * Operations on SO(n), the Lie group of rotation matrices.
 *
 *)

(* Find the axis of a rotation matrix *)
RotationAxis[R_] :=
  Module[
    {v, nr, nc, axis},

    (* Check to make sure that our input makes sense *)
    If[Not[MatrixQ[R]] || ({nr, nc} = Dimensions[R]; nr != nc),
        Message[Screws::wrongDimensions, "RotationAxis"];
	Return Null;
    ];

    (* Construct a dummy vector to operate on *)   
    v = Table[Unique["v"], {nc}];

    (* First check for degenerate case: R = identity *)
    If[And @@ (R . v == v), 
        Message[Screws::notUnique, "RotationAxis"];
        axis = Table[0, {nc}];  axis[[1]] = 1;
        Return[axis];
    ];

    (* Otherwise, solve a linear equation to find the answer *)
    v /. Solve[R . v == v, v][[1]] /. Map[# -> 1&, v]
  ];

(* Generate a skew symmetric matrix from an axis *)
(*! This only works in R^3 for now !*)
Skew[w_] := AxisToSkew[w];	(* backwards compatibility *)
AxisToSkew[omega_?VectorQ]:=
  Module[
    {},

    (* Check to make sure the dimensions are okay *)
    If[Not[VectorQ[omega]] || Length[omega] != 3,
      Message[Screws::wrongDimension];
      Return Null;
    ];

    (* Return the appropriate matrix *)
    {{ 0,          -omega[[3]],  omega[[2]]},
     { omega[[3]], 0,           -omega[[1]]},
     {-omega[[2]], omega[[1]],  0          }}
  ];

(* Generate an axis from a skew symmetric matrix *)
UnSkew[S_] := SkewToAxis[S];	(* for compatibility *)
SkewToAxis[S_]:=
  Module[
    {},

    (* First check to make sure we have a skew symmetric matrix *)
    If[Not[skewQ[S]] || Dimensions[S] != {3,3},
      Message[Screws::wrongDimension];
      Return Null
    ];

    (* Now extract the appropriate component *)
    {S[[3,2]], S[[1,3]], S[[2,1]]}
  ];

(* Matrix exponential for a skew symmetric matrix *)
SkewExp[v_?VectorQ,theta_:1] := SkewExp[AxisToSkew[v],theta];
SkewExp[S_?skewQ,theta_:1]:=
  Module[
    {n = Dimensions[S][[1]]},

    (* Use Rodrigues's formula *)
    IdentityMatrix[3] + Sin[theta] S + (1 - Cos[theta]) S.S
  ];

(*
 * Homogeneous representation
 *
 * These functions convert back and forth from elements of SE(3)
 * and their homogeneous representations.
 *
 *)

(* Convert a rotation + translation to a homogeneous matrix *)
RPToHomogeneous[R_, p_] :=
  Module[
    {n},

    (* Check to make sure the dimensions of the args make sense *)
    If[Not[VectorQ[p]] || Not[MatrixQ[R]] ||
       (n = Length[p]; Dimensions[R] != {n, n}),
	Message[Screws::wrongDimensions, "RPToHomogeneous:"];
    ];

    (* Now put everything together into a homogeneous transformation *)
    StackCols[
      StackRows[R, zeroMatrix[1, n]],
      StackRows[p, {1}]
    ]
  ];  

(* Convert a point into homogeneous coordinates *)
PointToHomogeneous[p_] :=
  Block[{},
    (* Check to make sure the dimensions of the args make sense *)
    If[Not[VectorQ[p]], Message[Screws::notVector, "PointToHomogeneous"]];

    (* Now put everything together into a homogeneous vector *)
    StackRows[p, {1}]
  ];  

(* Convert a vector into homogeneous coordinates *)
VectorToHomogeneous[p_] :=
  Block[{},
    (* Check to make sure the dimensions of the args make sense *)
    If[Not[VectorQ[p]], Message[Screws::notVector, "VectorToHomogeneous"]];

    (* Now put everything together into a homogeneous vector *)
    StackRows[p, {0}]
  ];

(* Extract the orientation portion from a homogeneous transformation *)
RigidOrientation[g_?MatrixQ]:=
  Module[
    {nr, nc},

    (* Check to make sure that we were passed a square matrix *)
    If[Not[MatrixQ[g]] || ({nr, nc} = Dimensions[g]; nr != nc) || nr < 3,
        Message[Screws::wrongDimensions, "RigidOrientation"];
	Return Null;
    ];

    (* Extract the upper left corner *)
    extractSubMatrix[g, {1,nr-1}, {1,nc-1}]
  ];

(* Extract the orientation portion from a homogeneous transformation *)
RigidPosition[g_?MatrixQ]:=
  Module[
    {nr, nc},

    (* Check to make sure that we were passed a square matrix *)
    If[Not[MatrixQ[g]] || ({nr, nc} = Dimensions[g]; nr != nc) || nr < 3,
        Message[Screws::wrongDimensions, "RigidPosition"];
	Return Null;
    ];

    (* Extract the upper left column *)
    Flatten[extractSubMatrix[g, {1,nr-1}, {nc}]]
  ];

(* 
 * Twists
 *
 * Functions for manipulating twists and converting rigid body
 * transformations back and forth from twists.
 *
 *)

(* Figure out the dimension of a twist [private] *)
xidim[xi_?VectorQ] :=
  Module[
    {l = Length[xi], n},

    (* Check the dimensions of the vector to make sure everything is okay *)
    n = (Sqrt[1 + 8l] - 1)/2;
    If[Not[IntegerQ[n]],
      Message[Screws::wrongDimensions, "xidim"];
      Return 0;
    ];
    n
];

(* Extract the angular portion of a twist [private] *)
xitow[xi_?VectorQ] :=
  Module[
    {n = xidim[xi]},

    (* Make sure that the vector had a reasonable length *)   
    If[n == 0, Return Null];

    (* Extract the angular portion of the twist *)
    Take[xi, -(n (n-1) / 2)]
  ];

(* Extract the linear portion of a twist [private] *)
xitov[xi_?VectorQ] :=
  Module[
    {n = xidim[xi]},

    (* Make sure that the vector had a reasonable length *)   
    If[n == 0, Return Null];

    (* Extract the linear portion of the twist *)
    Take[xi, n]
  ];

(* Check to see if a matrix is a twist matrix *)
(*! Not implemented !*)
TwistMatrixQ[A_] := MatrixQ[A];

(* Convert a homogeneous matrix to a twist *)
(*! This only works in dimensions 2 and 3 for now !*)
HomogeneousToTwist[A_] :=
  Module[
    {nr, nc},

    (* Check to make sure that our input makes sense *)
    If[Not[MatrixQ[A]] || ({nr, nc} = Dimensions[A]; nr != nc),
        Message[Screws::wrongDimensions, "HomogeneousToTwist"];
	Return Null;
    ];

    (* Make sure that we have a twist and not a rigid motion *)
    If[A[[nr,nc]] != 0,
        Message[Screws::notTwistMatrix, "HomogeneousToTwist"];
	Return Null;
    ];

    (* Extract the skew part and the vector part and make a vector *)
    Join[
      Flatten[extractSubMatrix[A, {1,nr-1}, {nc}]],
      SkewToAxis[ extractSubMatrix[A, {1,nr-1}, {1,nc-1}] ]
    ]
  ];

(* Convert a twist to homogeneous coordinates *)
TwistToHomogeneous[xi_?VectorQ] :=
  Module[
    {w = xitow[xi], v = xitov[xi], R, p},
    
    (* Make sure that we got a real twist *)
    If[w == Null || v == NULL, Return Null];

    (* Now put everything together into a homogeneous transformation *)
    StackCols[
      StackRows[AxisToSkew[w], zeroMatrix[1, Length[w]]],
      StackRows[v, {0}]
    ]
  ];  

(* Take the exponential of a twist *)
(*! This only works in dimension 3 for now !*)
TwistExp[xi_?MatrixQ, theta_:1]:=TwistExp[HomogeneousToTwist[xi], theta]; 
TwistExp[xi_?VectorQ, theta_:1] :=
  Module[
    {w = xitow[xi], v = xitov[xi], R, p},
    
    (* Make sure that we got a real twist *)
    If[w == Null || v == NULL, Return Null];

    (* Use the exponential formula from MLS *)
    If [(MatchQ[w,{0,0,0}] || MatchQ[w, {{0},{0},{0}}]),
      R = IdentityMatrix[3];
      p = v * theta,
     (* else *)
      R = SkewExp[w, theta];
      p = (IdentityMatrix[3] - R) . (AxisToSkew[w] . v) + w (w.v) theta;
    ];
    RPToHomogeneous[R, p]
  ];

(* Find the twist which generates a rigid motion *)
RigidTwist[g_?MatrixQ] :=
  Module[
    {R, p, axis, v, theta},

    (* Make sure the dimensions are okay *)
    (*! Missing !*)

    (* Extract the appropriate pieces of the homogeneous transformation *)
    R = RigidOrientation[g];
    p = RigidPosition[g];

    (* Now find the axis from the rotation *)    
    w = RotationAxis[R];
    theta = RotationAngle[R];

    (* Split into cases depending on whether theta is zero *)
    If[theta == 0,
      theta = Magnitude[p];
      v = p/Magnitude[p];
      w = 0;
    (* else *)
      (* Solve a linear equation to figure out what v is *)   
      v = LinearSolve[
        (IdentityMatrix[3]-Outer[Times,w,w]) Sin[theta] +
        Skew[w] (1 - Cos[theta]) + Outer[Times,w,w] theta,
      p]
    ];
    Flatten[{v, w}]
  ];

(*
 * Geometric attributes of twists and wrenches.
 *
 * For twists in R^3, find the attributes of that twist.
 *
 * Wrench attributes are defined by switching the role of linear
 * and angular portions
 *)

(* Build a twist from a screw *)
ScrewToTwist[Infinity, q_, w_] := Join[w, {0,0,0}];
ScrewToTwist[h_, q_, w_] := Join[-AxisToSkew[w] . q + h w, w]

(* Find the pitch associated with a twist in R^3 *)
TwistPitch[xi_?VectorQ] := 
  Module[
    {v, w},
    {v, w} = Partition[xi, 3];
    v . w / w.w
  ];
WrenchPitch[xi_?VectorQ] := Null;

(* Find the axis of a twist *)
TwistAxis[xi_?VectorQ] := 
  Module[
    {v, w},
    {v, w} = Partition[xi, 3];
    If[(MatchQ[w,{0,0,0}] || MatchQ[w, {{0},{0},{0}}]), 
     {0, v / Sqrt[v.v]}, {AxisToSkew[w] . v / w.w, (w / w.w)}]
  ];

WrenchAxis[xi_?VectorQ] := Null;

(* Find the magnitude of a twist *)
TwistMagnitude[xi_?VectorQ] := 
  Module[
    {v, w},
    {v, w} = Partition[xi, 3];
    If[(MatchQ[w,{0,0,0}] || MatchQ[w, {{0},{0},{0}}]), 
      Sqrt[v.v], Sqrt[w.w]]
  ];
WrenchMagnitude[xi_?VectorQ] := Null;

(* Inverse matrix calculation *)
(*! This only works in R^3 !*)
RigidInverse[g_?MatrixQ] := 
  Module[
    {R = RigidOrientation[g], p = RigidPosition[g]},
    RPToHomogeneous[Transpose[R], -Transpose[R].p]
  ];


(*
 * Adjoint calculation
 *
 * The adjoint matrix maps twist vectors to twist vectors.
 *
 *)

(* Adjoint matrix calculation *)
(*! This only works in R^3 !*)
RigidAdjoint[g_?MatrixQ] := 
  Module[
    {R = RigidOrientation[g], p = RigidPosition[g]},
    StackRows[
        StackCols[R, AxisToSkew[p] . R],
	StackCols[zeroMatrix[3], R]	
    ]
  ];


(*
 * Predicate (query) functions
 *
 * Define predicates to test for the various types of objects which
 * occur in Screw theory.
 *
 * RotationQ	rotation matrix
 * skewQ	skew symmetric [private]
 *)

(* check to see if a matrix is a rotation matrix (any dimension) *)
RotationQ[mat_] :=
  Module[
    {nr, nc, zmat},

    (* First check to make sure that this is square matrix *)
    If[Not[MatrixQ[mat]] || ({nr, nc} = Dimensions[mat]; nr != nc),
	Message[Screws::notSquare];    
        Return[False]];

    (* Check to see if R^T R = Identity *)
    zmat = Simplify[mat . Transpose[mat]] - IdentityMatrix[nr];
    Return[ And @@ Map[TrueQ[Simplify[#] == 0]&, Flatten[zmat]]]
  ];

skewQ[mat_] :=
  Module[
    {nr, nc, zmat},

    (* First check to make sure that this is square matrix *)
    If[Not[MatrixQ[mat]] || ({nr, nc} = Dimensions[mat]; nr != nc),
	Message[Screws::notSquare];    
        Return[False]];

    (* Check to see if A = -A^T *)
    zmat = mat + Transpose[mat];
    Return[ And @@ Map[TrueQ[Simplify[#] == 0]&, Flatten[zmat]]]
];

(*
 * Graphics functions
 *
 * DrawScrew		generate a graphical representation of a screw
 *
 *)

(* Define default options for screws *)
Options[DrawScrew] = {ScrewSize->2}

(* Draw a screw through the point q, in direction w, with pitch h *)
DrawScrew[q_, w_, h_:0, opts___Rule] :=
  Module[
    {x, y, z, R, axis, tip},

    (* Generate the rotation to get things to align with the tip *)
    z = w / Sqrt[w.w];
    y = NullSpace[{z}][[1]];	y = y / Sqrt[y.y];
    x = AxisToSkew[y] . z;
    R = Transpose[{x,y,z}];

    (* Generate the arrow for the tip *)
    tip := TranslateShape[
      Graphics3D[
        Cone[ScrewSize/20, ScrewSize/20, 10] /.
          {Polygon[list_] :> Polygon[Map[R . #&, list]]} ],
      q + ScrewSize * w];

    (* Generate the axis of the screw *)
    axis = Graphics3D[
      Point[q],
      Thickness[0.01 * ScrewSize/2], Line[{q, q + ScrewSize * w}]
    ];

    (* Put everything together as a list of graphics objects *)
    Flatten[{axis, tip} /. {opts} /. Options[DrawScrew]]
  ];

(* Draw a coordinate frame at a point *)
Options[DrawFrame] = {AxisSize->1}

(* Draw a coordinate frame at the appropriate point *)
DrawFrame[p_, R_, opts___Rule] :=
  Flatten[{Graphics3D[
    Thickness[0.01], Line[{p, p + R[[1]] * AxisSize}],
    Line[{p, p + R[[2]] * AxisSize}], Line[{p, p + R[[3]] * AxisSize}]
  ]} /. {opts} /. Options[DrawFrame]];

(*
 * Utility functions for stacking rows, cols, + other matrix operations
 *
 * StackRows		stack rows of matrices together
 * StackCols		stack cols of matrices together
 * zeroMatrix		create a matrix of zeros [private]
 * extractSubMatrix	pick out pieces of a matrix [private]
 *)

(* Stack matrix columns together *)
StackCols[mats__] :=
  Block[
    {i,j},
    Table[
      Join[ Flatten[Table[{mats}[[j]][[i]], {j,Length[{mats}]}], 1] ],
      {i, Length[ {mats}[[1]] ]}]
  ];

(* Stack matrix rows together *)
StackRows[mats__] := Join[Flatten[{mats}, 1]];
	
(* Create matrices of zeros *)
zeroMatrix[nr_, nc_] := Table[0, {nr}, {nc}];
zeroMatrix[nr_] := zeroMatrix[nr, nr];

(* Extract a submatrix from a bigger matrix *)
extractSubMatrix[A_, rows_, cols_] := Map[Take[#, cols]&, Take[A, rows]];


(* Close up the open environments *)
End[];
EndPackage[];

(* End Screws.m *)

