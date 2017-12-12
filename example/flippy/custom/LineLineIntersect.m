function [pa, pb, pa1, pa2, pb3, pb4] = LineLineIntersect(p1,p2,p3,p4)
%
%  [pa, pb, mua, mub] = LineLineIntersect(p1,p2,p3,p4)
%
%   Calculates the line segment pa_pb that is the shortest route
%   between two lines p1_p2 and p3_p4. Calculates also the values of
%   mua and mub where 
%        pa = p1 + mua (p2 - p1) 
%        pb = p3 + mub (p4 - p3)
%
%   Returns a MATLAB error if no solution exists.
%   
%   This a simple conversion to MATLAB of the C code posted by Paul
%   Bourke at
%   http://astronomy.swin.edu.au/~pbourke/geometry/lineline3d/. The
%   author of this all too imperfect translation is Cristian Dima
%   (csd@cmu.edu) 




% p13(1) = p1(1) - p3(1);
% p13(2) = p1(2) - p3(2);
% p13(3) = p1(3) - p3(3);
p13      = p1 - p3;

% p43(1) = p4(1) - p3(1);
% p43(2) = p4(2) - p3(2);
% p43(3) = p4(3) - p3(3);
p43      = p4 - p3;

% if ((abs(p43(1))  < eps) & ...
%     (abs(p43(2))  < eps) & ...
%     (abs(p43(3))  < eps))
%   error('Could not compute LineLineIntersect!');
% end

% p21(1) = p2(1) - p1(1);
% p21(2) = p2(2) - p1(2);
% p21(3) = p2(3) - p1(3);
p21 = p2 - p1;

% if ((abs(p21(1))  < eps) & ...
%     (abs(p21(2))  < eps) & ...
%     (abs(p21(3))  < eps))
%   error('Could not compute LineLineIntersect!');
% end

d1343 = p13(1) * p43(1) + p13(2) * p43(2) + p13(3) * p43(3);
d4321 = p43(1) * p21(1) + p43(2) * p21(2) + p43(3) * p21(3);
d1321 = p13(1) * p21(1) + p13(2) * p21(2) + p13(3) * p21(3);
d4343 = p43(1) * p43(1) + p43(2) * p43(2) + p43(3) * p43(3);
d2121 = p21(1) * p21(1) + p21(2) * p21(2) + p21(3) * p21(3);

denom = d2121(1) .* d4343(1) - d4321(1) .* d4321(1);

% if (abs(denom) < eps)
%   error('Could not compute LineLineIntersect!');
% end

numer = d1343(1) .* d4321(1) - d1321(1) .* d4343(1);

mua = numer(1) / denom(1);
mub = (d1343(1) + d4321(1) * mua(1)) / d4343(1);

% pa(1) = p1(1) + mua * p21(1);
% pa(2) = p1(2) + mua * p21(2);
% pa(3) = p1(3) + mua * p21(3);
pa = p1 + mua * p21;
pa2 = pa - p2;
pa1 = pa - p1;
% pb(1) = p3(1) + mub * p43(1);
% pb(2) = p3(2) + mub * p43(2);
% pb(3) = p3(3) + mub * p43(3);
pb = p3 + mub * p43;
pb4 = pb - p4;
pb3 = pb - p3;

