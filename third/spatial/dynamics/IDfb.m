function  [xdfb,tau] = IDfb( model, xfb, q, qd, qdd, f_ext )

% IDfb  Floating-Base Inverse Dynamics (=Hybrid Dynamics)
% [xdfb,tau]=IDfb(model,xfb,q,qd,qdd,f_ext) calculates the inverse dynamics
% of a floating-base kinematic tree via the algorithm in Table 9.6 of RBDA
% (which is really a special case of hybrid dynamics), using the same
% singularity-free representation of the motion of the floating base as
% used by FDfb.  xfb is a 13-element column vector containing: a unit
% quaternion specifying the orientation of the floating base (=body 6)'s
% coordinate frame relative to the fixed base; a 3D vector specifying the
% position of the origin of the floating base's coordinate frame in
% fixed-base coordinates; and a spatial vector giving the velocity of the
% floating base in fixed-base coordinates.  The return value xdfb is the
% time-derivative of xfb.  The arguments q, qd and qdd contain the
% position, velocity and acceleration variables for the real joints in the
% system (i.e., joints 7 onwards in the system model); so q(i), qd(i) and
% qdd(i) all apply to joint i+6.  The return value tau is the vector of
% force variables required to produce the given acceleration qdd.  f_ext is
% an optional argument specifying the external forces acting on the bodies.
% It can be omitted if there are no external forces.  If supplied, it must
% be a cell array of length model.NB, of which the first 5 elements are
% ignored, and f_ext{6} onward specify the forces acting on the floating
% base (body 6) onward.  The format of f_ext is explained in the source
% code of apply_external_forces.

a_grav = get_gravity(model);

qn = xfb(1:4);				% unit quaternion fixed-->f.b.
r = xfb(5:7);				% position of f.b. origin
Xup{6} = plux( rq(qn), r );		% xform fixed --> f.b. coords

vfb = xfb(8:end);
v{6} = Xup{6} * vfb;			% f.b. vel in f.b. coords

a{6} = zeros(6,1);

IC{6} = model.I{6};
pC{6} = model.I{6}*a{6} + crf(v{6})*model.I{6}*v{6};

for i = 7:model.NB
  [ XJ, S{i} ] = jcalc( model.jtype{i}, q(i-6) );
  vJ = S{i}*qd(i-6);
  Xup{i} = XJ * model.Xtree{i};
  v{i} = Xup{i}*v{model.parent(i)} + vJ;
  a{i} = Xup{i}*a{model.parent(i)} + S{i}*qdd(i-6) + crm(v{i})*vJ;
  IC{i} = model.I{i};
  pC{i} = IC{i}*a{i} + crf(v{i})*IC{i}*v{i};
end

if nargin == 6 && length(f_ext) > 0
  prnt = model.parent(6:end) - 5;
  pC(6:end) = apply_external_forces(prnt, Xup(6:end), pC(6:end), f_ext(6:end));
end

for i = model.NB:-1:7
  IC{model.parent(i)} = IC{model.parent(i)} + Xup{i}'*IC{i}*Xup{i};
  pC{model.parent(i)} = pC{model.parent(i)} + Xup{i}'*pC{i};
end

a{6} = - IC{6} \ pC{6};			% floating-base acceleration
                                        % without gravity
for i = 7:model.NB
  a{i} = Xup{i} * a{model.parent(i)};
  tau(i-6,1) = S{i}'*(IC{i}*a{i} + pC{i});
end

qnd = rqd( vfb(1:3), qn );		% derivative of qn
rd = Vpt( vfb, r );			% lin vel of flt base origin
afb = Xup{6} \ a{6} + a_grav;		% f.b. accn in fixed-base coords

xdfb = [ qnd; rd; afb ];
