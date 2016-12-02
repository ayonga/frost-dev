function  model = singlebody

% SINGLEBODY  free-floating single rigid body
% singlebody creates a model data structure for a single free-floating,
% unit-mass rigid body having the shape of a rectangular box with
% dimensions of 3, 2 and 1 in the x, y and z directions, respectively.

% For efficient use with Simulink, this function builds a new model only
% the first time it is called.  Thereafter, it returns this stored copy.

persistent memory;

if length(memory) ~= 0
  model = memory;
  return
end

model.NB = 1;
model.parent = 0;

model.jtype = {'R'};		% sacrificial joint replaced by floatbase
model.Xtree = {eye(6)};

model.gravity = [0 0 0];		% zero gravity is not the default,
                                        % so it must be stated explicitly

% This is the inertia of a uniform-density box with one vertex at (0,0,0)
% and a diametrically opposite one at (3,2,1).

model.I = { mcI( 1, [3 2 1]/2, diag([4+1 9+1 9+4]/12) ) };

% Draw the global X, Y and Z axes in red, green and blue

model.appearance.base = ...
  { 'colour', [0.9 0 0], 'line', [0 0 0; 2 0 0], ...
    'colour', [0 0.9 0], 'line', [0 0 0; 0 2 0], ...
    'colour', [0 0.3 0.9], 'line', [0 0 0; 0 0 2] };

% Draw the floating body

model.appearance.body{1} = { 'box', [0 0 0; 3 2 1] };

model = floatbase(model);		% replace joint 1 with a chain of 6
                                        % joints emulating a floating base
memory = model;
