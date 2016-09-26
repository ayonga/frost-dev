function  E = rz( theta )

% rz  3x3 coordinate rotation (Z-axis)
% rz(theta)  calculates the 3x3 rotational coordinate transform matrix from
% A to B coordinates, where coordinate frame B is rotated by an angle theta
% (radians) relative to frame A about their common Z axis.

c = cos(theta);
s = sin(theta);

E = [ c  s  0;
     -s  c  0;
      0  0  1 ];
