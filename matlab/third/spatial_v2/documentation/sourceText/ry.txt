function  E = ry( theta )

% ry  3x3 coordinate rotation (Y-axis)
% ry(theta)  calculates the 3x3 rotational coordinate transform matrix from
% A to B coordinates, where coordinate frame B is rotated by an angle theta
% (radians) relative to frame A about their common Y axis.

c = cos(theta);
s = sin(theta);

E = [ c  0 -s;
      0  1  0;
      s  0  c ];
