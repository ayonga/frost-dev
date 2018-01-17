function  out = skew( in )

% skew  convert 3D vector <--> 3x3 skew-symmetric matrix
% S=skew(v) and v=skew(A) calculate the 3x3 skew-symmetric matrix S
% corresponding to the given 3D vector v, and the 3D vector corresponding
% to the skew-symmetric component of the given arbitrary 3x3 matrix A.  For
% vectors a and b, skew(a)*b is the cross product of a and b.  If the
% argument is a 3x3 matrix then it is assumed to be A, otherwise it is
% assumed to be v.  skew(A) produces a column-vector result, but skew(v)
% will accept a row or column vector argument.

if all(size(in)==[3 3])			% do v = skew(A)
  out = 0.5 * [ in(3,2) - in(2,3);
		in(1,3) - in(3,1);
		in(2,1) - in(1,2) ];
else					% do S = skew(v)
  out = [  0,    -in(3),  in(2);
	   in(3),  0,    -in(1);
	  -in(2),  in(1),  0 ];
end
