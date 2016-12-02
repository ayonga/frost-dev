function  robot = vee( L2 )

% VEE  free-floating 1R robot consisting of two rods
% vee(L2) creates a free-floating robot consisting of two thin rods
% connected by a revolute joint with an axis at 45 degrees to the axis of
% each rod.  When the joint variables are zero, rod 1 lies on the X axis,
% rod 2 lies on the Y axis, and the connecting joint lies on the line x=y,
% z=0.  Rod 1 has a length of 1, and rod 2 has a length of L2.  If the
% length argument is omitted then it defaults to 1.  The rods have a radius
% of 0.01, and their masses equal their lengths.

if nargin < 1
  L2 = 1;
end

% For efficient use with Simulink, this function builds a new model the
% first time it is called, and stores it in the persistent variable
% 'memory'; and it stores the corresponding length argument in 'memory_L2'.
% On each subsequent occasion that it is called, it compares the L2 value
% with memory_L2, and if they are the same then it simply returns the
% stored model instead of creating a new one.

persistent memory memory_L2;

if length(memory) ~= 0 && memory_L2 == L2
  robot = memory;
  return
end

% To make a new vee model, we first create a two-link robot with two
% revolute joints.  The first joint is just a place-holder, as it will be
% replaced with a chain of six joints when floatbase is called near the end
% of this function.  When that happens, link 1 (=rod 1) will become link 6,
% link 2 will become link 7, and joint 2 (the real joint) will become joint
% 7.  For now, the first step is to define the connectivity and kinematics
% of a two-link robot.

robot.NB = 2;
robot.parent = [0 1];
robot.jtype = {'R', 'R'};

robot.Xtree = { eye(6), roty(pi/2) * rotz(pi/4) };

robot.gravity = [0 0 0];		% zero gravity is not the default,
                                        % so it must be stated explicitly

% The next step is to calculate the inertias of the two links, assuming
% they are uniform solid cylinders of radius 0.01.  Note that L2 is both
% the length and mass of link 2.  One little complication here is that rod
% 1 lies on the X axis of its local coordinate system, but rod 2 lies on
% the line x=0, y=z of its local coordinate system.  We get over this by
% first defining the inertia of rod 2 as if it were lying on the Y axis,
% and then rotate it by pi/4 about the X axis.

Ibig1 = 1.0003/12;
Ibig2 = L2*(L2^2+0.0003)/12;
Ismall1 = 0.00005;
Ismall2 = L2*0.00005;
rod1 = mcI( 1, [0.5,0,0], diag([Ismall1,Ibig1,Ibig1]) );
rod2 = mcI( L2, [0,L2/2,0], diag([Ibig2,Ismall2,Ibig2]) );

% The next two lines rotate rod 2 by pi/4 about the X axis.  Note that X2
% is actually a cordinate transform, but it is being used as a rotation
% operator on this occasion.

X2 = rotx(pi/4);
rod2 = X2' * rod2 * X2;

robot.I = { rod1, rod2 };

% The next step is to draw some visual guide lines in the fixed coordinate
% system, to help the viewer understand the motion.  Lines are drawn on the
% X axis, the Y axis, a line at 45 degrees to these axes, and a line
% joining the two centres of mass.

robot.appearance.base = ...
  { 'line', [1.1 0 0; 0 0 0; 0 1.1 0], ...
    'line', [0 0 0; 0.8 0.8 0], ...
    'line', [0.55 -L2*0.05 0; -0.05 L2*0.55 0] };

% The next step is to draw the two bodies.  A small red sphere marks each
% centre of mass.  Observe that rod 2 lies at 45 degrees to the Y and Z
% axes in its local coordinate system, so the cylinder representing it is
% drawn at [0 0 0; 0 L2 L2]/sqrt(2).  Similar comments apply to the
% cylinder in link 1 that models the appearance of the revolute joint.

robot.appearance.body{1} = ...
  { 'cyl', [0 0 0; 1 0 0], 0.01, ...
    'cyl', [0.02 0.02 0; -0.02 -0.02 0]/sqrt(2), 0.02, ...
    'colour', [0.9 0 0], ...
    'sphere', [0.5 0 0], 0.015 };

robot.appearance.body{2} = ...
  { 'cyl', [0 0 0; 0 L2 L2]/sqrt(2), 0.01, ...
    'cyl', [0 0 0.02; 0 0 0.06], 0.02, ...
    'colour', [0.9 0 0], ...
    'sphere', [0 L2/2 L2/2]/sqrt(2), 0.015 };

% To further assist the viewer, if L2 takes a value other than 1 then three
% small orange spheres are added to the drawing instructions: one at the
% system centre of mass, and one embedded in each rod at the point where
% that rod intersects with the system CoM.

if L2 ~= 1

  Lcm = (1+L2^2) / (1+L2) / 2;
  robot.appearance.body{1} = ...
    [ robot.appearance.body{1}, ...
      { 'colour', [0.9 0.5 0], 'sphere', [Lcm 0 0], 0.015 } ];

  robot.appearance.body{2} = ...
    [ robot.appearance.body{2}, ...
      { 'colour', [0.9 0.5 0], ...
	'sphere', [0 sqrt(0.5) sqrt(0.5)]*Lcm, 0.015 } ];

  sys_CoM = [0.5 L2^2/2 0] / (1+L2);	% system centre of mass
  robot.appearance.base = ...
    [ robot.appearance.base, ...
      { 'colour', [0.9 0.5 0], 'sphere', sys_CoM, 0.015 } ];
end

% And finally, we call floatbase to replace joint 1 with a chain of six
% joints (three prismatic and three revolute), and store a copy of the new
% robot in 'memory'.

robot = floatbase(robot);

memory = robot;
memory_L2 = L2;
