function  ret = EnerMo( model, q, qd )

% EnerMo  calculate energy, momentum and related quantities
% EnerMo(robot,q,qd)  returns a structure containing the fields KE, PE,
% htot, Itot, mass, cm and vcm.  These fields contain the kinetic and
% potential energies of the whole system, the total spatial momentum, the
% total spatial inertia, total mass, position of centre of mass, and the
% linear velocity of centre of mass, respectively.  Vector quantities are
% expressed in base coordinates.  PE is defined to be zero when cm is
% zero.

for i = 1:model.NB
  [ XJ, S ] = jcalc( model.jtype{i}, q(i) );
  vJ = S*qd(i);
  Xup{i} = XJ * model.Xtree{i};
  if model.parent(i) == 0
    v{i} = vJ;
  else
    v{i} = Xup{i}*v{model.parent(i)} + vJ;
  end
  Ic{i} = model.I{i};
  hc{i} = Ic{i} * v{i};
  KE(i) = 0.5 * v{i}' * hc{i};
end

ret.Itot = zeros(size(Ic{1}));
ret.htot = zeros(size(hc{1}));

for i = model.NB:-1:1
  if model.parent(i) ~= 0
    Ic{model.parent(i)} = Ic{model.parent(i)} + Xup{i}'*Ic{i}*Xup{i};
    hc{model.parent(i)} = hc{model.parent(i)} + Xup{i}'*hc{i};
  else
    ret.Itot = ret.Itot + Xup{i}'*Ic{i}*Xup{i};
    ret.htot = ret.htot + Xup{i}'*hc{i};
  end
end

a_grav = get_gravity(model);

if length(a_grav) == 6
  g = a_grav(4:6);			% 3D linear gravitational accn
  h = ret.htot(4:6);			% 3D linear momentum
else
  g = a_grav(2:3);			% 2D gravity
  h = ret.htot(2:3);			% 2D linear momentum
end

[mass, cm] = mcI(ret.Itot);

ret.KE = sum(KE);
ret.PE = - mass * dot(cm,g);
ret.mass = mass;
ret.cm = cm;
ret.vcm = h / mass;
