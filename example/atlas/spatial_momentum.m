%%
[model] = utils.body_struct_to_spatial_model(robot);
model.parent(1) = 0;
load('D:\Dropbox\Dropbox (Personal)\research\dzopt\frost\example\atlas\local\good_gait.mat')
q = gait(1).states.x(:,1);
dq = gait(1).states.dx(:,1);
%%
D = robot.calcMassMatrix(q);
F = robot.calcDriftVector(q,dq);
[H,C] = HandC(model,q,dq);
%%
n_link = length(robot.Links);
pcm = transpose(pcom_atlas(q));
h_tot = zeros(6,1);
De = zeros(size(D));
KE = 0;
h_tot = 0;
for i=1:n_link
    frame = robot.Links(i);
    Jb{i} = double(subs(getBodyJacobian(robot,frame),robot.States.x,q));
    Se{i} = double(subs(computeForwardKinematics(frame),robot.States.x,q));
    R{i} = Se{i}(1:3,1:3);
    p{i} = Se{i}(1:3,4);
    I{i} = blkdiag(frame.Mass*eye(3),frame.Inertia);
    pcm = pcom_atlas(q);
    Xg{i} = plux(R{i}',(p{i}-pcm'));
    vb{i} = Jb{i}*dq;
    h{i} = I{i}*Jb{i}*dq;
    %         De = De + Jb{i}'*I{i}*Jb{i};
    %         KE = KE + 0.5 * dq'*Jb{i}'*I{i}*Jb{i}*dq;
    h_tot = h_tot + Xg{i}'*h{i}([4:6,1:3]);
end

%%
pcom = robot.getComPosition();
Ag = zeros(6,21);
for i=1:n_link
    frame = robot.Links(i);
    Jb{i} = getBodyJacobian(robot,frame);
    gst = computeForwardKinematics(frame);
    R{i} = frame.RigidOrientation(gst);
    p{i} = frame.RigidPosition(gst);
    I{i} = blkdiag(frame.Mass*eye(3),frame.Inertia);
    Xg{i} = [ R{i}', -R{i}'*skew(p{i}-pcom'); zeros(3), R{i}' ];
    A{i} =  Xg{i}'*I{i}*Jb{i};
    Ag = Ag + A{i};
    %     vb{i} = Jb{i}*dq;
    %     h{i} = I{i}*Jb{i}*dq;
    %         De = De + Jb{i}'*I{i}*Jb{i};
    %         KE = KE + 0.5 * dq'*Jb{i}'*I{i}*Jb{i}*dq;
    %     h_tot = h_tot + Xg{i}'*h{i};
end
hg = Ag*robot.States.dx;
dAg = jacobian(Ag*robot.States.dx,robot.States.x);

hg_fun = SymFunction('hg_atlas',hg,{robot.States.x,robot.States.dx});
hg_fun.export('gen/sim');
hg_fun = SymFunction('Ag_atlas',Ag,{robot.States.x});
hg_fun.export('gen/sim');
hg_fun = SymFunction('dAg_atlas',dAg,{robot.States.x,robot.States.dx});
hg_fun.export('gen/sim');

for j=1:length(logger.flow.t)
    q = logger.flow.states.x(:,j);
    dq = logger.flow.states.dx(:,j);
    ddq = logger.flow.states.ddx(:,j);
    hdot(:,i) = Ag_atlas(q)*ddq + dAg_atlas(q,dq)*dq;
end
%%
for j=1:length(logger.flow.t)
    q = logger.flow.states.x(:,j);
    dq = logger.flow.states.dx(:,j);
    h_tot = 0;
    for i=1:n_link
        frame = robot.Links(i);
        Jb{i} = double(subs(getBodyJacobian(robot,frame),robot.States.x,q));
        Se{i} = double(subs(computeForwardKinematics(frame),robot.States.x,q));
        R{i} = Se{i}(1:3,1:3);
        p{i} = Se{i}(1:3,4);
        I{i} = blkdiag(frame.Mass*eye(3),frame.Inertia);
        pcm = pcom_atlas(q);
        Xg{i} = plux(R{i}',(p{i}-pcm'));
        vb{i} = Jb{i}*dq;
        h{i} = I{i}*Jb{i}*dq;
        %         De = De + Jb{i}'*I{i}*Jb{i};
        %         KE = KE + 0.5 * dq'*Jb{i}'*I{i}*Jb{i}*dq;
        h_tot = h_tot + Xg{i}'*h{i}([4:6,1:3]);
    end
    h_traj(:,j) = h_tot;
    ret = EnerMo(model,q,dq);
    h1_traj(:,j)=ret.htot;
end
%%
h_tot = 0;
for i = 1:model.NB
  [ XJ, S ] = jcalc( model.jtype{i}, q(i) );
  vJ = S*dq(i);
  Xup{i} = XJ * model.Xtree{i};
  if model.parent(i) == 0
    v{i} = vJ;
  else
    v{i} = Xup{i}*v{model.parent(i)} + vJ;
  end
  Ic{i} = model.I{i};
  hc{i} = Ic{i} * v{i};
  KE(i) = 0.5 * v{i}' * hc{i};
  
  
  frame = robot.Joints(i);
  Jb{i} = double(subs(getBodyJacobian(robot,frame),robot.States.x,q));
  Se{i} = double(subs(computeForwardKinematics(frame),robot.States.x,q));
  R{i} = Se{i}(1:3,1:3);
  p{i} = Se{i}(1:3,4);
  I{i} = model.I{i};
  Xg{i} = plux(R{i}',(p{i}));
  vb{i} = Jb{i}*dq;
  h{i} = I{i}*vb{i}([4:6,1:3]);
  h_tot = h_tot + Xg{i}'*h{i};
  assert(any(hc{i}-h{i}<1e-5));
%   frame = robot.Joints(i);
%   child_link_idx = getLinkIndices(robot, frame.Child);
%   if ~isnan(child_link_idx)        
%       link = robot.Links(child_link_idx);
%       offset = link.Offset;
%   else
%       offset = [0,0,0];
%   end
%   Jb{i} = double(subs(getBodyJacobian(robot,frame,[0,0,0]),robot.States.x,q));
%   vb{i} = Jb{i}*dq;
%   child_link_idx = getLinkIndices(robot, frame.Child);
%   if ~isnan(child_link_idx)        
%       link = robot.Links(child_link_idx);
%       Jl{i} = double(subs(getBodyJacobian(robot,link),robot.States.x,q));
%       vl{i} = Jl{i}*dq;
%   else
%       vl{i} = zeros(6,1);
%   end
%   [v{i}, vb{i}([4:6,1:3]), vl{i}([4:6,1:3])]
%   keyboard
end