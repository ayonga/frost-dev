function  model = rollingdisc( npt )

% rollingdisc  disc with ground contact points (Simulink Example 7)
% rollingdisc(npt)  creates a model data structure for a polyhedral
% approximation to a thick circular disc (i.e., a cylinder) that can make
% contact with, bounce, and roll over the ground (the x-y plane).  The
% argument is the number of vertices in the polygon approximating a circle.
% The model contains 2*npt ground-contact points -- npt around each end
% face of the cylinder.  See Simulink Example 7.

% For efficient use with Simulink, this function builds a new model only
% if it doesn't have a stored copy of the right model.

persistent last_model last_npt;

if length(last_model) ~= 0 && last_npt == npt
  model = last_model;
  return
end

model.NB = 1;
model.parent = 0;

model.jtype = {'R'};		% sacrificial joint replaced by floatbase
model.Xtree = {eye(6)};

% Disc dimensions and inertia

R = 0.05;			% radius
T = 0.01;			% thickness

density = 3000;			% kg / m^3
mass = pi * R^2 * T * density;
Ibig = mass * R^2 / 2;
Ismall = mass * (3*R^2 + T^2) / 12;

model.I = { mcI( mass, [0 0 0], diag([Ismall Ibig Ismall]) ) };

% Drawing instructions

model.appearance.base = { 'tiles', [-0.1 1; -0.3 0.3; 0 0], 0.1 };

model.appearance.body{1} = { 'facets', npt, 'cyl', [0 -T/2 0; 0 T/2 0], R };

% Camera settings

model.camera.body = 1;
model.camera.direction = [1 0 0.1];
model.camera.locus = [0 0.5];

% Ground contact points (have to match how the cylinder is drawn)

ang = (0:npt-1) * 2*pi / npt;

Y = ones(1,npt) * T/2;
X = sin(ang) * R;
Z = cos(ang) * R;

model.gc.point = [ X X; -Y Y; Z Z ];
model.gc.body = ones(1,2*npt);

% Final step: float the base

model = floatbase(model);		% replace joint 1 with a chain of 6
                                        % joints emulating a floating base
last_model = model;
last_npt = npt;
