function  model = scissor

% SCISSOR  free-floating two-body system resembling a pair of scissors
% scissor  creates a model data structure for a free-floating two body
% system consisting of two identical flat rectangular bodies connected
% together at the middle by a revolute joint in a manner resembling a pair
% of scissors.  In the zero position, both bodies extend from -0.1 to 0.1
% in the x direction, and from -0.5 to 0.5 in the z direction, but one
% extends from 0 to -0.1 and the other from 0 to +0.1 in the y direction,
% and the connecting joint lies on the y axis.  Both bodies have unit
% mass.  This mechanism is used in Simulink Example 5.

% For efficient use with Simulink, this function builds a new model only
% the first time it is called.  Thereafter, it returns this stored copy.

persistent memory;

if length(memory) ~= 0
  model = memory;
  return
end

model.NB = 2;
model.parent = [0 1];

model.jtype = {'R', 'Ry'};	% 1st joint will be replaced by floatbase
model.Xtree = {eye(6), eye(6)};

model.gravity = [0 0 0];		% zero gravity is not the default,
                                        % so it must be stated explicitly

% centroidal inertia of a unit-mass box with dimensions 0.2, 0.1 and 1:

Ic = diag( [1.01 1.04 0.05] / 12 );

model.I = { mcI(1,[0 -0.05 0],Ic),  mcI(1,[0 0.05 0],Ic) };

% Draw the bodies

model.appearance.body{1} = ...
  { 'box', [-0.1 -0.1 -0.5; 0.1 0 0.5], ...
    'colour', [0.6 0.3 0.8], ...
    'cyl', [0 -0.13 0; 0 0.13 0], 0.07 };

model.appearance.body{2} = ...
  { 'box', [-0.1 0 -0.5; 0.1 0.1 0.5] };

model.camera.direction = [0 -3 1];	% a better viewing angle
model.camera.zoom = 0.9;

model = floatbase(model);		% replace joint 1 with a chain of 6
                                        % joints emulating a floating base
memory = model;
