function  robot = doubleElbow

% doubleElbow  planar robot with geared 2R elbow joint (Simulink Example 6)
% doubleElbow  creates a two-link planar robot that resembles planar(2),
% except that the elbow joint has been replaced by a pair of revolute
% joints close together, which are geared 1:1.  This kind of joint can be
% implemented with a pair of gears, or a pair of pulleys and a figure-eight
% cable.  This robot therefore has three revolute joints in total, but only
% two independent degrees of fredom.  The gearing constraint is implemented
% by a constraint function provided in gamma_q.  This robot is used in
% Simulink Example 6.

% For efficient use with Simulink, this function creates a model data
% structure the first time it is called, and thereafter returns the stored
% value below.

persistent memory;

if length(memory) ~= 0
  robot = memory;
  return
end

% This robot is implemented as a 3-link chain with 3 revolute joints,
% but the joints are subject to the constraint q(2)==q(3).

robot.NB = 3;
robot.parent = [0 1 2];
robot.jtype = { 'r', 'r', 'r' };

robot.gamma_q = @gamma_q;		% constraint-imposing function

robot.Xtree = { eye(3), plnr(0,[1,0]), plnr(0,[0.25,0]) };

Ilink = mcI(1,[0.5,0],1/12);		% inertia of the two main links

robot.I = { Ilink, zeros(3), Ilink };

robot.appearance.base = ...
  { 'box', [-0.2 -0.3 -0.2; 0.2 0.3 -0.07] };

robot.appearance.body{1} = ...
  { 'box', [0 -0.07 -0.04; 1 0.07 0.04], ...
    'cyl', [0 0 -0.07; 0 0 0.07], 0.1, ...
    'cyl', [1 0 -0.05; 1 0 0.05], 0.125 };

robot.appearance.body{2} = ...
  { 'box', [0 -0.06 0.05; 0.25 0.06 0.08], ...
    'box', [0 -0.06 -0.05; 0.25 0.06 -0.08], ...
    'cyl', [0 0 -0.08; 0 0 0.08], 0.06, ...
    'cyl', [0.25 0 -0.08; 0.25 0 0.08], 0.06 };

robot.appearance.body{3} = ...
  { 'box', [0 -0.07 -0.04; 1 0.07 0.04], ...
    'cyl', [0 0 -0.05; 0 0 0.05], 0.125 };


% The function below implements the constraint q(2)==q(3).  If qo and qdo
% satisfy the constraints exactly then they are returned as q and qd.
% Otherwise, qo(2) and qdo(2) are taken as correct, qo(3) and qdo(3) as
% erroneous, and the returned value of gs includes a constraint
% stabilization term that causes qo(3) and qdo(3) to converge towards qo(2)
% and qdo(2) as the simulation proceeds.

function [q,qd,G,gs] = gamma_q( model, qo, qdo )

q = [ qo(1); qo(2); qo(2) ];		% satisfies constraint exactly

qd = [ qdo(1); qdo(2); qdo(2) ];	% satisfies constraint exactly

G = [ 1 0; 0 1; 0 1 ];

Tstab = 0.1;

gs = 2/Tstab*(qd-qdo) + 1/Tstab^2*(q-qo);
