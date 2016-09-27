%> @brief rotation_axis Extract a unit vector from a rotation matrix given
%> an axis from [1, 2, 3], which may be negative
%> @author Matthew Powell, Eric Cousineau
function [r] = rotation_axis(axis, R)

i = abs(axis);
if axis < 0
    r = -R(:, i);
else
    r = R(:, i);
end
    
end
