function  [xdfb,qdd] = FDfb( model, xfb, q, qd, tau, f_ext )

% FDfb  Floating-Base Forward Dynamics via Articulated-Body Algorithm
% [xdfb,qdd]=FDfb(model,xfb,q,qd,tau,f_ext) calculates the forward dynamics
% of a floating-base kinematic tree via the articulated-body algorithm.
% This function avoids the kinematic singularity in the six-joint chain
% created by floatbase to mimic a true 6-DoF joint.  xfb is a 13-element
% column vector containing: a unit quaternion specifying the orientation of
% the floating base (=body 6)'s coordinate frame relative to the fixed
% base; a 3D vector specifying the position of the origin of the floating
% base's coordinate frame in fixed-base coordinates; and a spatial vector
% giving the velocity of the floating base in fixed-base coordinates.  The
% return value xdfb is the time-derivative of this vector.  The arguments
% q, qd and tau contain the position, velocity and force variables for the
% real joints in the system (i.e., joints 7 onwards in the system model);
% so q(i), qd(i) and tau(i) all apply to joint i+6.  The return value qdd
% is the time-derivative of qd.  f_ext is an optional argument specifying
% the external forces acting on the bodies.  It can be omitted if there are
% no external forces.  If supplied, it must be a cell array of length
% model.NB, of which the first 5 elements are ignored, and f_ext{6} onward
% specify the forces acting on the floating base (body 6) onward.  The
% format of f_ext is explained in the source code of apply_external_forces.

a_grav = get_gravity(model);

qn = xfb(1:4);				% unit quaternion fixed-->f.b.
r = xfb(5:7);				% position of f.b. origin
Xup{6} = plux( rq(qn), r );		% xform fixed --> f.b. coords

vfb = xfb(8:end);
v{6} = Xup{6} * vfb;			% f.b. vel in f.b. coords

IA{6} = model.I{6};
pA{6} = crf(v{6}) * model.I{6} * v{6};

for i = 7:model.NB
  [ XJ, S{i} ] = jcalc( model.jtype{i}, q(i-6) );
  vJ = S{i}*qd(i-6);
  Xup{i} = XJ * model.Xtree{i};
  v{i} = Xup{i}*v{model.parent(i)} + vJ;
  c{i} = crm(v{i}) * vJ;
  IA{i} = model.I{i};
  pA{i} = crf(v{i}) * model.I{i} * v{i};
end

if nargin == 6 && length(f_ext) > 0
  prnt = model.parent(6:end) - 5;
  pA(6:end) = apply_external_forces(prnt, Xup(6:end), pA(6:end), f_ext(6:end));
end

for i = model.NB:-1:7
  U{i} = IA{i} * S{i};
  d{i} = S{i}' * U{i};
  u{i} = tau(i-6) - S{i}'*pA{i};
  Ia = IA{i} - U{i}/d{i}*U{i}';
  pa = pA{i} + Ia*c{i} + U{i} * u{i}/d{i};
  IA{model.parent(i)} = IA{model.parent(i)} + Xup{i}' * Ia * Xup{i};
  pA{model.parent(i)} = pA{model.parent(i)} + Xup{i}' * pa;
end

a{6} = - IA{6} \ pA{6};			% floating base accn without gravity

qdd = zeros(0,1);			% avoids a matlab warning when NB==6

for i = 7:model.NB
  a{i} = Xup{i} * a{model.parent(i)} + c{i};
  qdd(i-6,1) = (u{i} - U{i}'*a{i})/d{i};
  a{i} = a{i} + S{i}*qdd(i-6);
end

qnd = rqd( vfb(1:3), qn );		% derivative of qn
rd = Vpt( vfb, r );			% lin vel of flt base origin
afb = Xup{6} \ a{6} + a_grav;		% true f.b. accn in fixed-base coords

xdfb = [ qnd; rd; afb ];
