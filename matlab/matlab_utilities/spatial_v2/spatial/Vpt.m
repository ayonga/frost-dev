function  vp = Vpt( v, p )

% Vpt  spatial/planar velocities --> velocities at points
% vp=Vpt(v,p)  calculates the linear velocities vp at one or more points p
% due to one or more spatial/planar velocities v.  In 3D, v is either 6x1
% or 6xn, and p and vp are 3xn.  In 2D, v is either 3x1 or 3xn, and p and
% vp are 2xn.  If v is just a single spatial/planar vector then it applies
% to every point in p; otherwise, vp(:,i) is calculated from v(:,i) and
% p(:,i).

if size(v,2)==1 && size(p,2)>1
  v = repmat(v,1,size(p,2));
end

if size(v,1)==6				% 3D points and velocities
  vp = v(4:6,:) + cross(v(1:3,:),p,1);
else					% 2D points and velocities
  vp = v(2:3,:) + [ -v(1,:).*p(2,:); v(1,:).*p(1,:) ];
end
