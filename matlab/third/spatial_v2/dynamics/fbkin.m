function  [o1, o2, o3] = fbkin( i1, i2, i3 )

% fbkin  Forward and Inverse Kinematics of Floating Base
% [x,xd]=fbkin(q,qd,qdd) calculates the forward kinematics, and
% [q,qd,qdd]=fbkin(x,xd) calculates the inverse kinematics, of a spatial
% floating base constructed by floatbase.  The vectors q, qd and qdd are
% the joint position, velocity and acceleration variables for the six
% joints forming the floating base; x is the 13-element singularity-free
% state vector used by FDfb and IDfb; and xd is its derivative.  The
% component parts of x are: a unit quaternion specifying the orientation of
% the floating-base frame relative to the fixed base, a 3D vector giving
% the position of the origin of the floating-base frame, and the spatial
% velocity of the floating base expressed in fixed-base coordinates.  If
% the acceleration calculation is not needed then use the simpler calls
% x=fbkin(q,qd) and [q,qd]=fbkin(x); and if the velocity calculation is
% also not needed then use p=fbkin(q) and q=fbkin(p) (or q=fbkin(x)), where
% p contains the first 7 elements of x.  If the length of the first
% argument is 7 or 13 then it is assumed to be p or x, otherwise it is
% assumed to be q.  All vectors are expected to be column vectors.  The
% returned value of q(5) is normalized to the range -pi/2 to pi/2; and the
% returned values of q(4) and q(6) are normalized to the range -pi to pi.
% The calculation of qd and qdd fails if the floating base is in one of its
% two kinematic singularities, which occur when q(5)==+/-pi/2.  However,
% the calculation of q is robust, and remains accurate both in and close to
% the singularities.

if length(i1) == 13 || length(i1) == 7
  if nargout == 3
    [o1, o2, o3] = invkin( i1, i2 );
  elseif nargout == 2
    [o1, o2] = invkin( i1 );
  else
    o1 = invkin( i1 );
  end
else
  if nargout == 2
    [o1, o2] = fwdkin( i1, i2, i3 );
  elseif nargin == 2
    o1 = fwdkin( i1, i2 );
  else
    o1 = fwdkin( i1 );
  end
end



function  [x, xd] = fwdkin( q, qd, qdd )

c4 = cos(q(4));  s4 = sin(q(4));
c5 = cos(q(5));  s5 = sin(q(5));
c6 = cos(q(6));  s6 = sin(q(6));

E = [  c5*c6,  c4*s6+s4*s5*c6,  s4*s6-c4*s5*c6;
      -c5*s6,  c4*c6-s4*s5*s6,  s4*c6+c4*s5*s6;
        s5,       -s4*c5,           c4*c5 ];

qn = rq(E);				% unit quaternion fixed-->floating
r = q(1:3);				% position of floating-base origin

x(1:4,1) = qn;
x(5:7) = r;

if nargin > 1				% do velocity calculation

  S = [ 1  0    s5;
	0  c4  -s4*c5;
	0  s4   c4*c5 ];

  omega = S*qd(4:6);
  rd = qd(1:3);				% lin vel of floating-base origin

  v = [ omega; rd+cross(r,omega) ];	% spatial vel in fixed-base coords

  x(8:13) = v;
end

if nargout == 2				% calculate xd

  c4d = -s4*qd(4);  s4d = c4*qd(4);
  c5d = -s5*qd(5);  s5d = c5*qd(5);

  Sd = [ 0  0     s5d;
	 0  c4d  -s4d*c5-s4*c5d;
	 0  s4d   c4d*c5+c4*c5d ];

  omegad = S*qdd(4:6) + Sd*qd(4:6);
  rdd = qdd(1:3);
					% spatial accn in fixed-base coords
  a = [ omegad; rdd+cross(rd,omega)+cross(r,omegad) ];

  xd(1:4,1) = rqd( omega, rq(E) );
  xd(5:7) = rd;
  xd(8:13) = a;
end



function  [q, qd, qdd] = invkin( x, xd )

E = rq(x(1:4));				% coord xfm fixed-->floating
r = x(5:7);				% position of floating-base origin

q(1:3,1) = r;

q(5) = atan2( E(3,1), sqrt(E(1,1)*E(1,1)+E(2,1)*E(2,1)) );
q(6) = atan2( -E(2,1), E(1,1) );
if E(3,1) > 0
  q(4) = atan2( E(2,3)+E(1,2), E(2,2)-E(1,3) ) - q(6);
else
  q(4) = atan2( E(2,3)-E(1,2), E(2,2)+E(1,3) ) + q(6);
end
if q(4) > pi
  q(4) = q(4) - 2*pi;
elseif q(4) < -pi
  q(4) = q(4) + 2*pi;
end

if nargout > 1				% calculate qd

  c4 = cos(q(4));  s4 = sin(q(4));
  c5 = cos(q(5));  s5 = sin(q(5));

  S = [ 1  0    s5;
	0  c4  -s4*c5;
	0  s4   c4*c5 ];

  omega = x(8:10);
  rd = x(11:13) - cross(r,omega);	% lin vel of floating-base origin

  qd(1:3,1) = rd;
  qd(4:6) = S \ omega;			% this will fail at a singularity
end

if nargout == 3				% calculate qdd

  c4d = -s4*qd(4);  s4d = c4*qd(4);
  c5d = -s5*qd(5);  s5d = c5*qd(5);

  Sd = [ 0  0     s5d;
	 0  c4d  -s4d*c5-s4*c5d;
	 0  s4d   c4d*c5+c4*c5d ];

  omegad = xd(8:10);
  rdd = xd(11:13) - cross(rd,omega) - cross(r,omegad);

  qdd(1:3,1) = rdd;
  qdd(4:6) = S \ (omegad - Sd*qd(4:6));	% this will fail at a singularity
end
