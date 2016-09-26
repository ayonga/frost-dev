function  qdd = FDcrb( model, q, qd, tau, f_ext )

% FDcrb  Forward Dynamics via Composite-Rigid-Body Algorithm
% FDcrb(model,q,qd,tau,f_ext)  calculates the forward dynamics of a
% kinematic tree via the composite-rigid-body algorithm.  q, qd and tau are
% vectors of joint position, velocity and force variables; and the return
% value is a vector of joint acceleration variables.  f_ext is an optional
% argument specifying the external forces acting on the bodies.  It can be
% omitted if there are no external forces.  The format of f_ext is
% explained in the source code of apply_external_forces.

if nargin == 4
  [H,C] = HandC( model, q, qd );
else
  [H,C] = HandC( model, q, qd, f_ext );
end

qdd = H \ (tau - C);
