function  [o1,o2] = plnr( i1, i2 )

% plnr  compose/decompose planar-vector coordinate transform.
% X=plnr(theta,r) and [theta,r]=plnr(X)  compose a planar-vector coordinate
% transform X from its component parts theta and r, and decompose it into
% those parts, respectively.  theta is a scalar and r is a 2D vector.  r is
% returned as a column vector, but it can be supplied as a row or column
% vector.  X is the transform from A to B coordinates, in which frame B is
% located at point r (expressed in A coordinates) and is rotated by an
% angle theta (radians) relative to frame A.  If two arguments are supplied
% then they are assumed to be theta and r, otherwise X.

if nargin == 2				% theta,r --> X

  c = cos(i1);
  s = sin(i1);

  o1 = [        1          0  0 ;
	 s*i2(1)-c*i2(2)   c  s ;
	 c*i2(1)+s*i2(2)  -s  c ];

else					% X --> theta,r

  c = i1(2,2);
  s = i1(2,3);

  o1 = atan2(s,c);
  o2 = [ s*i1(2,1)+c*i1(3,1); s*i1(3,1)-c*i1(2,1) ];

end
