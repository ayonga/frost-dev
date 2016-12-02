function  robot = planar( n )

% planar  create an n-link planar robot.
% planar(n)  creates an all-revolute n-link planar robot with identical
% links.  For efficient use with Simulink, this function stores a copy of
% the last robot it created, and returns the copy if the arguments match.

persistent  last_robot last_n;

if length(last_robot) ~= 0 && last_n == n
  robot = last_robot;
  return
end

robot.NB = n;
robot.parent = [0:n-1];

for i = 1:n
  robot.jtype{i} = 'r';
  if i == 1
    robot.Xtree{i} = plnr( 0, [0 0]);
  else
    robot.Xtree{i} = plnr( 0, [1 0]);
  end
  robot.I{i} = mcI( 1, [0.5 0], 1/12 );
end

robot.appearance.base = ...
  { 'box', [-0.2 -0.3 -0.2; 0.2 0.3 -0.07] };

for i = 1:n
  robot.appearance.body{i} = ...
    { 'box', [0 -0.07 -0.04; 1 0.07 0.04], ...
      'cyl', [0 0 -0.07; 0 0 0.07], 0.1 };
end

last_robot = robot;
last_n = n;
