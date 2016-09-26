function  vcross = crm( v )

% crm  spatial/planar cross-product operator (motion).
% crm(v)  calculates the 6x6 (or 3x3) matrix such that the expression
% crm(v)*m is the cross product of the motion vectors v and m.  If
% length(v)==6 then it is taken to be a spatial vector, and the return
% value is a 6x6 matrix.  Otherwise, v is taken to be a planar vector, and
% the return value is 3x3.

if length(v) == 6

  vcross = [  0    -v(3)  v(2)   0     0     0    ;
	      v(3)  0    -v(1)   0     0     0    ;
	     -v(2)  v(1)  0      0     0     0    ;
	      0    -v(6)  v(5)   0    -v(3)  v(2) ;
	      v(6)  0    -v(4)   v(3)  0    -v(1) ;
	     -v(5)  v(4)  0     -v(2)  v(1)  0 ];

else

  vcross = [  0     0     0    ;
	      v(3)  0    -v(1) ;
	     -v(2)  v(1)  0 ];
end
