function  X = roty( theta )

% roty  spatial coordinate transform (Y-axis rotation).
% roty(theta)  calculates the coordinate transform matrix from A to B
% coordinates for spatial motion vectors, where coordinate frame B is
% rotated by an angle theta (radians) relative to frame A about their
% common Y axis.

c = cos(theta);
s = sin(theta);

X = [ c  0 -s  0  0  0 ;
      0  1  0  0  0  0 ;
      s  0  c  0  0  0 ;
      0  0  0  c  0 -s ;
      0  0  0  0  1  0 ;
      0  0  0  s  0  c
    ];
