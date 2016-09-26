%> @brief rotation_matrix Produce a canonical rotation matrix given an axis
%> index, selecting from [1, 2, 3], allowing negatives. The values (axis,
%> q) dictate a frame B rotated with respect to a parent from A. The
%> resulting matrix projects from B's frame to A, \f$ R = {}^AR_B \f$.
%> @authors Eric Cousineau, Matthew Powells
function R = rotation_matrix(axis, q)
%> @todo Replace with Sva library? Will need to transpose
% http://en.wikipedia.org/wiki/Rotation_matrix#Basic_rotations

c = cos(q);
s = sin(q);

if axis < 0
	s = -s;
	axis = -axis;
end

if axis == 1
	R = [1, 0, 0;
		0, c, -s;
		0, s, c ];
elseif axis == 2
	R = [c, 0, s;
		0, 1, 0;
		-s, 0, c ];
elseif axis == 3
	R = [c, -s, 0;
		s, c, 0;
		0, 0, 1 ];
end

return
