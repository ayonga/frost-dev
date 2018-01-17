function  [f, ud, fcone] = gcontact( K, D, mu, p, pd, u )

% gcontact  calculate 2D/3D ground reaction forces due to compliant contact
% [f,ud,fcone] = gcontact(K,D,mu,p,pd,u)  calculates the ground-reaction
% forces acting on a set of points due to contact with a compliant ground
% plane.  In 3D, the x-y plane is the ground plane, and z is up.  In 2D,
% the x axis is the ground plane and y is up.  K, D and mu are scalars
% giving the stiffness, damping and friction coefficients of the ground
% plane.  p and pd are (nD)x(np) matrices giving the positions and
% velocities of a set of np points in nD-dimensional space (nD=2 or 3).
% gcontact uses the size of p to determine whether it is working in 2D or
% 3D space.  u is an (nD-1)x(np) matrix containing the tangential
% deformation state variables used to implement the friction model.  f is
% an (nD)x(np) matrix of calculated ground-reaction forces.  If f(nD,i)==0
% then point i is not in contact; and if f(nD,i)>0 then point i is in
% contact.  ud is the time derivative of u; and fcone is a 1x(np) matrix
% indicating the stick/slip status of each point.  If fcone(i)<=1 then
% point i is sticking.  This can happen only if point i is in contact.  To
% facilitate use with Simulink, if gcontact is called with only a single
% return value then it returns the concatenation of f, ud and fcone (i.e.,
% the return value is [f;ud;fcone]).  To model a frictionless surface,
% gcontact can be called as follows: f=gcontact(K,D,0,p,pd), where p, pd
% and f are all 1x(np) matrices containing only the normal components of
% position, velocity and reaction force.

% Implementation note:  This function implements the nonlinear
% spring-damper model described in Azad & Featherstone "Modelling the
% Contact Between a Rolling Sphere and a Compliant Ground Plane", ACRA
% 2010, Brisbane, Australia, Dec. 1-3.  However, the implementation here is
% for points rather than spheres.

% Normal force calculation

z = p(end,:);
zd = pd(end,:);
zr = sqrt(max(0,-z));

fn = zr .* ((-K)*z - D*zd);

if mu == 0			% special case: modelling frictionless
  f = max( 0, fn );		% contact, so return the normal force now
  return
end

% Algorithm for full normal+tangent force calculation: (1) set all output
% variables to their correct no-contact values; (2) correct all the values
% that are wrong because their respective points are in contact.  Step (2)
% is subdivided into (2a) calculate correct values for sticking; (2b)
% adjust the values for those points that are found to be slipping; (2c)
% make the corrections to the output variables.

% Step 1: set output variables to correct no-contact values

[nd,np] = size(p);
f = zeros(nd,np);
ud = (-K/D) * u;
fcone = repmat(2,1,np);			% 2 is just an arbitrary value > 1

in_ctact = fn > 0;

% Step 2: correct all those values that are wrong because their respective
% points are in contact.  Note: variables with names ending in c have one
% column for each point that is in contact.

if any(in_ctact)

  % Step 2a: calculate correct values for sticking

  fnc = fn(in_ctact);
  udc = pd(1:end-1,in_ctact);

  zrc = repmat(zr(in_ctact),nd-1,1);
  Kc = K * zrc;
  Dc = D * zrc;
  fKc = Kc .* u(:,in_ctact);

  ftc = -fKc - Dc .* udc;		% correct tangent force for sticking

  % now test for slipping

  fslip = mu * fnc;
  if nd == 3				% 3D contact
    ftcmag = sqrt(sum(ftc.^2,1));
  else					% 2D contact
    ftcmag = abs(ftc);
  end
  fconec = ftcmag ./ fslip;
  slipping = fconec > 1;

  % Step 2b: adjust values for those points that are found to be slipping

  if any(slipping)
    attenuator = repmat(fconec(slipping),nd-1,1);
    fts = ftc(:,slipping) ./ attenuator;
    ftc(:,slipping) = fts;
    udc(:,slipping) = -(fts + fKc(:,slipping)) ./ Dc(:,slipping);
  end

  % Step 2c: apply the corrections to the output variables
  
  f(:,in_ctact) = [ftc;fnc];
  ud(:,in_ctact) = udc;
  fcone(in_ctact) = min(2,fconec);

end

if nargout == 1
  f = [f; ud; fcone];
end
