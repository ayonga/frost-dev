function posvel = gcPosVel( model, xfb, q, qd )

% gcPosVel  calculate positions and velocities of contact points
% gcPosVel(model,q,qd), gcPosVel(model,xfb,q,qd) and gcPosVel(model,xfb)
% calculate a 4xn or 6xn matrix, depending on whether the model is planar
% or spatial, containing the position and linear velocity of every point
% specified in model.gc.point (n==length(model.gc.point)).  The position
% coordinates appear in the top rows, and the velocity coordinates at the
% bottom.  All are expressed in base (i.e., absolute) coordinates.  The
% data for model.gc.point(i) appears in column i.  The argument are: the
% model data structure (which must contain a .gc substructure); the
% position and velocity variables of a floating base (as defined by FDfb
% and IDfb); the joint position variables; and the joint velocity
% variables.  The call gcPosVel(model,xfb) is permissible only if the
% model describes a single floating rigid body.

if nargin==4 || nargin==2		% xfb supplied

  qn = xfb(1:4);			% unit quaternion fixed-->f.b.
  r = xfb(5:7);				% position of f.b. origin
  Xa{6} = plux( rq(qn), r );		% xform fixed --> f.b. coords

  vfb = xfb(8:end);
  vb{6} = Xa{6} * vfb;			% f.b. vel in f.b. coords

  for i = 7:model.NB
    [ XJ, S ] = jcalc( model.jtype{i}, q(i-6) );
    Xup = XJ * model.Xtree{i};
    vJ = S*qd(i-6);
    Xa{i} = Xup * Xa{model.parent(i)};
    vb{i} = Xup * vb{model.parent(i)} + vJ;
  end

else					% xfb not supplied

  qd = q;  q = xfb;			% shift up the arguments

  for i = 1:model.NB
    [ XJ, S ] = jcalc( model.jtype{i}, q(i) );
    Xup = XJ * model.Xtree{i};
    vJ = S*qd(i);
    if model.parent(i) == 0
      Xa{i} = Xup;
      vb{i} = vJ;
    else
      Xa{i} = Xup * Xa{model.parent(i)};
      vb{i} = Xup * vb{model.parent(i)} + vJ;
    end
  end

end

for i = unique(model.gc.body)
  X = inv(Xa{i});			% xform body i -> abs coords
  v = X * vb{i};			% body i vel in abs coords
  iset = model.gc.body == i;		% set of points assoc with body i
  pt = Xpt( X, model.gc.point(:,iset) );	% xform points to abs coords
  vpt = Vpt( v, pt );			% linear velocities of points
  posvel(:,iset) = [ pt; vpt ];		% insert into correct columns
end
