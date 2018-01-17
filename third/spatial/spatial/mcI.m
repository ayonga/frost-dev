function  [o1,o2,o3] = mcI( i1, i2, i3 )

% mcI  rigid-body inertia <--> mass, CoM and rotational inertia.
% rbi=mcI(m,c,I) and [m,c,I]=mcI(rbi) convert between the spatial or planar
% inertia matrix of a rigid body (rbi) and its mass, centre of mass and
% rotational inertia about the centre of mass (m, c and I).  In the spatial
% case, c is 3x1, I is 3x3 and rbi is 6x6.  In the planar case, c is 2x1, I
% is a scalar and rbi is 3x3.  In both cases, m is a scalar.  When c is an
% argument, it can be either a row or a column vector.  If only one
% argument is supplied then it is assumed to be rbi; and if it is a 6x6
% matrix then it is assumed to be spatial.  Otherwise, three arguments must
% be supplied, and if length(c)==3 then mcI calculates a spatial inertia
% matrix.  NOTE: (1) mcI(rbi) requires rbi to have nonzero mass; (2) if |c|
% is much larger than the radius of gyration, or the dimensions of the
% inertia ellipsoid, then extracting I from rbi is numerically
% ill-conditioned.

if nargin == 1
  [o1,o2,o3] = rbi_to_mcI( i1 );
else
  o1 = mcI_to_rbi( i1, i2, i3 );
end


function  rbi = mcI_to_rbi( m, c, I )

if length(c) == 3			% spatial

  C = skew(c);
  rbi = [ I + m*C*C', m*C; m*C', m*eye(3) ];

else					% planar

  rbi = [  I+m*dot(c,c), -m*c(2), m*c(1);
	  -m*c(2),        m,      0;
	   m*c(1),        0,      m  ];
end


function  [m,c,I] = rbi_to_mcI( rbi )

if all(size(rbi)==[6 6])		% spatial

  m = rbi(6,6);
  mC = rbi(1:3,4:6);
  c = skew(mC)/m;
  I = rbi(1:3,1:3) - mC*mC'/m;

else					% planar

  m = rbi(3,3);
  c = [rbi(3,1);-rbi(2,1)]/m;
  I = rbi(1,1) - m*dot(c,c);

end
