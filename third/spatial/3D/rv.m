function  out = rv( in )

% rv  3D rotation vector <--> 3x3 coordinate rotation matrix
% E=rv(v) and v=rv(E) convert between a rotation vector v, whose magnitude
% and direction describe the angle and axis of rotation of a coordinate
% frame B relative to frame A, and the 3x3 coordinate rotation matrix E
% that transforms from A to B coordinates.  For example, if v=[theta;0;0]
% then rv(v) produces the same matrix as rx(theta).  If the argument is a
% 3x3 matrix then it is assumed to be E, otherwise it is assumed to be v.
% rv(E) expects E to be accurately orthonormal, and returns a column vector
% with a magnitude in the range [0,pi].  If the magnitude is exactly pi
% then the sign of the return value is unpredictable, since pi*u and -pi*u,
% where u is any unit vector, both represent the same rotation.  rv(v) will
% accept a row or column vector of any magnitude.

if all(size(in)==[3 3])
  out = Etov( in );
else
  out = vtoE( [in(1);in(2);in(3)] );
end


function  E = vtoE( v )

theta = norm(v);
if theta == 0
  E = eye(3);
else
  s = sin(theta);
  c = cos(theta);
  c1 = 2 * sin(theta/2)^2;		% 1-cos(h) == 2sin^2(h/2)
  u = v/theta;
  E = c*eye(3) - s*skew(u) + c1*u*u';
end


function  v = Etov( E )

% This function begins by extracting the skew-symmetric component of E,
% which, as can be seen from the previous function, is -s*skew(v/theta).
% For angles sufficiently far from pi, v is then calculated directly from
% this quantity.  However, for angles close to pi, E is almost symmetric,
% and so extracting the skew-symmetric component becomes numerically
% ill-conditioned, and provides an increasingly inaccurate value for the
% direction of v.  Therefore, the component c1*u*u' is extracted as well,
% and used to get an accurate value for the direction of v.  If the angle
% is exactly pi then the sign of v will be indeterminate, since +v and -v
% both represent the same rotation, but the direction will still be
% accurate.

w = -skew(E);				% w == s/theta * v
s = norm(w);
c = (trace(E)-1)/2;
theta = atan2(s,c);

if s == 0
  v = [0;0;0];
elseif theta < 0.9*pi			% a somewhat arbitrary threshold
  v = theta/s * w;
else					% extract v*v' component from E and
  E = E - c * eye(3);			% pick biggest column (best chance
  E = E + E';				% to get sign right)
  if E(1,1) >= E(2,2) && E(1,1) >= E(3,3)
    if w(1) >= 0
      v = E(:,1);
    else
      v = -E(:,1);
    end
  elseif E(2,2) >= E(3,3)
    if w(2) >= 0
      v = E(:,2);
    else
      v = -E(:,2);
    end
  else
    if w(3) >= 0
      v = E(:,3);
    else
      v = -E(:,3);
    end
  end
  v = theta/norm(v) * v;
end
