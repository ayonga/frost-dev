function  E = rx( theta )

% rx  3x3 coordinate rotation (X-axis)
% rx(theta)  calculates the 3x3 rotational coordinate transform matrix from
% A to B coordinates, where coordinate frame B is rotated by an angle theta
% (radians) relative to frame A about their common X axis.

c = cos(theta);
s = sin(theta);

E = [ 1  0  0;
      0  c  s;
      0 -s  c ];
