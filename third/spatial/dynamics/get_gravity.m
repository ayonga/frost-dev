function  a_grav = get_gravity( model )

% get_gravity  spatial/planar gravitational accn vector for given model
% get_gravity(model) returns the gravitational acceleration vector to be
% used in dynamics calculations for the given model.  The return value is
% either a spatial or a planar vector, according to the type of model.  It
% is computed from the field model.gravity, which is a 2D or 3D (row or
% column) vector specifying the linear acceleration due to gravity.  If
% this field is not present then get_gravity uses the following defaults:
% [0,0,-9.81] for spatial models and [0,0] for planar.

if isfield( model, 'gravity' )
  g = model.gravity;
else
  g = [0;0;-9.81];
end

if size(model.Xtree{1},1) == 3		% is model planar?
  a_grav = [0;g(1);g(2)];
else
  a_grav = [0;0;0;g(1);g(2);g(3)];
end
