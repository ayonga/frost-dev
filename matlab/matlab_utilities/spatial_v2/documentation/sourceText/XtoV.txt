function v = XtoV( X )

% XtoV  obtain spatial/planar vector from small-angle transform.
% XtoV(X)  interprets X as the coordinate transform from A to B
% coordinates, which implicitly defines the location of frame B relative to
% frame A.  XtoV calculates the velocity of a third frame, C(t), that
% travels at constant velocity from frame A to frame B in one time unit.
% Thus, C(0)=A, C(1)=B and dC/dt is a constant.  The return value, v, is
% the velocity of C, calculated using a small-angle approximation.  It is
% therefore exact only if A and B are parallel.  The return value is a
% spatial vector if X is a 6x6 matrix; otherwise it is a planar vector.
% The return value is an invariant of X (i.e., v=X*v), and can therefore be
% regarded as being expressed in both A and B coordinates.

if all(size(X)==[6 6])			% Plucker xform -> spatial vector

  v = 0.5 * [ X(2,3) - X(3,2);
	      X(3,1) - X(1,3);
	      X(1,2) - X(2,1);
	      X(5,3) - X(6,2);
	      X(6,1) - X(4,3);
	      X(4,2) - X(5,1) ];

else					% planar xform -> planar vector

  v = [  X(2,3);
	 (X(3,1) + X(2,2)*X(3,1) + X(2,3)*X(2,1))/2;
	 (-X(2,1) - X(2,2)*X(2,1) + X(2,3)*X(3,1))/2  ];
end
