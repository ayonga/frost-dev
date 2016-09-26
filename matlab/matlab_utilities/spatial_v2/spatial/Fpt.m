function  f = Fpt( fp, p )

% Fpt  forces at points --> spatial/planar forces
% f=Fpt(fp,p)  converts one or more linear forces fp acting at one or more
% points p to their equivalent spatial or planar forces.  In 3D, fp and p
% are 3xn arrays and f is 6xn.  In 2D, fp and p are 2xn and f is 3xn.  In
% both cases, f(:,i) is the equivalent of fp(:,i) acting at p(:,i).

if size(fp,1)==3			% 3D forces at 3D points
  f = [ cross(p,fp,1); fp ];
else					% 2D forces at 2D points
  f = [ p(1,:).*fp(2,:) - p(2,:).*fp(1,:); fp ];
end
