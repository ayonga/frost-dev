function  xp = Xpt( X, p )

% Xpt  apply Plucker/planar coordinate transform to 2D/3D points
% xp=Xpt(X,p)  applies the coordinate transform X to the points in p,
% returning the new coordinates in xp.  If X is a 6x6 matrix then it is
% taken to be a Plucker coordinate transform, and p is expected to be a
% 3xn matrix of 3D points.  Otherwise, X is assumed to be a planar
% coordinate transform and p a 2xn array of 2D points.
  
if all(size(X)==[6 6])			% 3D points
  E = X(1:3,1:3);
  r = -skew(E'*X(4:6,1:3));
else					% 2D points
  E = X(2:3,2:3);
  r = [ X(2,3)*X(2,1)+X(3,3)*X(3,1); X(2,3)*X(3,1)-X(3,3)*X(2,1) ];
end

if size(p,2) > 1
  r = repmat(r,1,size(p,2));
end

xp = E * (p - r);
