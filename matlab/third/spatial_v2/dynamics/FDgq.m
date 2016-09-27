function  qdd = FDgq( model, q, qd, tau, f_ext )

% FDgq  Forward Dynamics via CRBA + constraint function gamma_q
% FDgq(model,q,qd,tau,f_ext)  calculates the forward dynamics of a
% kinematic tree, subject to the kinematic constraints embodied in the
% function model.gamma_q, via the composite-rigid-body algorithm.  q, qd
% and tau are vectors of joint position, velocity and force variables; and
% the return value is a vector of joint acceleration variables.  q and qd do
% not have to satisfy the constraints exactly, but are expected to be
% close.  qdd will typically contain a constraint-stabilization component
% that tends to reduce constraint violation over time.  f_ext is an optional
% argument specifying the external forces acting on the bodies.  It can be
% omitted if there are no external forces.  The format of f_ext is
% explained in the source code of apply_external_forces.  A detailed
% description of gamma_q appears at the end of this source code.

[q,qd,G,g] = model.gamma_q( model, q, qd );

if nargin == 4
  [H,C] = HandC( model, q, qd );
else
  [H,C] = HandC( model, q, qd, f_ext );
end

qdd = G * ((G'*H*G) \ (G'*(tau-C-H*g))) + g;       % cf. eq 3.20 in RBDA




%{
How to Create Your Own gamma_q
------------------------------

[See also Section 3.2 of "Rigid Body Dynamics Algorithms", and maybe also
Section 8.3.]

The purpose of this function is to define a set of algebraic constraints among
the elements of q, and therefore also among the elements of qd and qdd.  These
constraints could be due to kinematic loops, gears, pulleys, and so on.  To
create a function gamma_q, proceed as follows:

1.  Identify a set of independent variables, y.  Typically, y will be a subset
    of the variables in q.

2.  Define a function, gamma, that maps y to q; i.e., q=gamma(y).  The
    calculated value of q must satisfy the constraints exactly.

3.  Define an inverse function, gamma^-1, that maps q to y.  This function
    must satisfy gamma^-1(gamma(y))==y for all y, and gamma(gamma^-1(q))==q
    for all q that satisfy the constraints exactly.

4.  Optional:  For some kinds of constraints, gamma may be ambiguous (i.e.,
    multi-valued).  In these cases, gamma can be modified to take a second
    argument, q0, which is a vector satisfying gamma^-1(q0)==y.  This vector
    plays the role of a disambiguator---it identifies which one of multiple
    possible values of gamma(y) is the correct one in the present context.
    For differentiation purposes, this extra argument is regarded as a
    constant.

5.  Having defined gamma, G is the matrix partial d/dy gamma (i.e., it is
    the Jacobian of gamma).

6.  G provides the following relationship between qd and yd: qd = G * yd,
    which can be used to calculate qd from yd.  Alternatively, qd could be
    calculated directly from d/dt gamma(y).

7.  To obtain yd from qd, use yd = d/dt gamma^-1(q).  In general, the
    right-hand side will be a function of both q and qd.  However, if y is a
    subset of q then yd is the same subset of qd.

8.  Given that qd = G * yd, it follows that qdd = G * ydd + dG/dt * yd.
    However, it is advisable to add a stabilization term to this formula, so
    that qdd = G * ydd + g, where g = dG/dt * yd + gs, and gs is a
    stabilization term defined as follows: gs = 2/Ts * qderr + 1/Ts^2 * qerr.
    Ts is a stabilization time constant, and qerr and qderr are measures of
    the degree to which the (given) prevailing values of q and qd fail to
    satisfy the constraints.  If q0 and qd0 are the prevailing values then
    qerr = gamma(gamma^-1(q0)) - q0 and qderr = G*yd - qd0 (where yd is
    calculated from qd0).

The function gamma_q can now be defined as follows:

function call:  [q,qd,G,g] = gamma_q( model, q0, qd0 )

where q0 and qd0 are the current values of the joint position and velocity
variables, q and qd are new values that exactly satisfy the constraints, and G
and g are as described above.

function body:

y = gamma^-1(q0);
q = gamma(y);			% or gamma(y,q0)

G = Jacobian of gamma;

yd = d/dt gamma^-1(q0);		% a function of q0 and qd0
qd = G * yd;			% or d/dt gamma(y)

Ts = some suitable value, such as 0.1 or 0.01;

gs = 2/Ts * (qd - qd0) + 1/Ts^2 * (q - q0);

g = dG/dt * yd + gs;

Tip: gamma_q can be used at the beginning of a simulation run to initialize q
and qd to values that satisfy the constraints exactly.
%}
