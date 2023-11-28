clc;

nDof = robot.Dimension;
V0 = zeros(6,1);
dV0 = [0;0;9.81;0;0;0];

idx = 4;
q = gait(1).states.x(:,idx);
dq = gait(1).states.dx(:,idx);
u = gait(1).inputs.torque(:,idx);
V = zeros(6,nDof);

ddq_test = gait(1).states.ddx(:,idx);
lambda_test = gait(1).inputs.fRightSole(:,idx);

V_test = zeros(6,nDof);
dV_test = zeros(6,nDof);
F_test = zeros(6,nDof);
for j_idx = 1:nDof
    V_test(:,j_idx) = gait(1).states.(['v',num2str(j_idx)])(:,idx);
    dV_test(:,j_idx) = gait(1).states.(['dv',num2str(j_idx)])(:,idx);
    F_test(:,j_idx) = gait(1).states.(['f',num2str(j_idx)])(:,idx);
end

dV = zeros(6,nDof);
F = zeros(6,nDof);
lambda = zeros(6,1);

nContact = 6; % plane contact
n_vars = 6*nDof + 6*nDof + nDof + nContact; % dV, F, ddq, lambda
n_expr = 6*nDof + 6*nDof + nDof + nContact; % dV, F, tau, dV_contact

dV_indices = reshape(cumsum(ones(1,6*nDof)),6,nDof);
F_indices  = reshape(cumsum(ones(1,6*nDof))+6*nDof,6,nDof);
ddq_indices  = reshape(cumsum(ones(1,nDof))+6*nDof+6*nDof,nDof,1);
lambda_indices  = reshape(cumsum(ones(1,nContact))+6*nDof+6*nDof+nDof,nContact,1);


dV_expr_indices = reshape(cumsum(ones(1,6*nDof)),6,nDof);
F_expr_indices  = reshape(cumsum(ones(1,6*nDof))+6*nDof,6,nDof);
tau_expr_indices  = reshape(cumsum(ones(1,nDof))+6*nDof+6*nDof,nDof,1);
contact_expr_indices  = reshape(cumsum(ones(1,nContact))+6*nDof+6*nDof+nDof,nContact,1);

base_joints_name = {robot.BaseJoints.Name};

M = zeros(n_expr, n_vars);
b = zeros(n_expr, 1);

for j_idx=1:nDof
    joint = robot.Joints(j_idx);

    if ~isempty(str_index(joint.Name,base_joints_name))
        prev_j_idx = 0;
    else
        prev_j_idx = getJointIndices(robot, joint.Reference.Name);
    end

    B_i = joint.TwistAxis;
    M_i = joint.Tinv;
    T_i = twist_exp(-B_i,q(j_idx)) * M_i;

    %         expr_dV = dV - CoordinateFrame.RigidAdjoint(T_i) * dV_p - ...
    %             CoordinateFrame.LieBracket(V) * (B_i*dx(j_idx)) - B_i*ddx(j_idx);
    M(dV_expr_indices(:,j_idx), dV_indices(:,j_idx)) = eye(6); % dV_i
    M(dV_expr_indices(:,j_idx), ddq_indices(j_idx)) = -B_i; % - B_i*ddx(j_idx)

    if prev_j_idx==0
        V_p = V0;
        dV_p = dV0;        
        V(:,j_idx) = CoordinateFrame.RigidAdjoint(T_i) * V_p + B_i*dq(j_idx);

        
        b(dV_expr_indices(:,j_idx)) =  ...
            CoordinateFrame.LieBracket(V(:,j_idx)) * (B_i*dq(j_idx)) ... % CoordinateFrame.LieBracket(V) * (B_i*dx(j_idx))
            + CoordinateFrame.RigidAdjoint(T_i) * dV_p; % - CoordinateFrame.RigidAdjoint(T_i) * dV_p
    else
        V_p = V(:,prev_j_idx);
        V(:,j_idx) = CoordinateFrame.RigidAdjoint(T_i) * V_p + B_i*dq(j_idx);
        
       
        M(dV_expr_indices(:,j_idx), dV_indices(:,prev_j_idx)) = ...
            - CoordinateFrame.RigidAdjoint(T_i); % - CoordinateFrame.RigidAdjoint(T_i) * dV_p
      
        b(dV_expr_indices(:,j_idx)) =  ...
            CoordinateFrame.LieBracket(V(:,j_idx)) * (B_i*dq(j_idx)); % CoordinateFrame.LieBracket(V) * (B_i*dx(j_idx))
    end

    G_i = joint.G;
    M(F_expr_indices(:,j_idx), F_indices(:,j_idx)) = eye(6); % F_i
    M(F_expr_indices(:,j_idx), dV_indices(:,j_idx)) = -G_i ; % - G_i * dV 
    b(F_expr_indices(:,j_idx)) = - transpose(CoordinateFrame.LieBracket(V(:,j_idx))) * (G_i * V(:,j_idx));

    if ~isempty(joint.ChildJoints)
            
        for idx =1:numel(joint.ChildJoints)
            child_joint = joint.ChildJoints(idx);

            next_j_idx = getJointIndices(robot, child_joint.Name);
            

            B_next = child_joint.TwistAxis;
            M_next = child_joint.Tinv;
            T_next = twist_exp(-B_next,q(next_j_idx)) * M_next;


            M(F_expr_indices(:,j_idx), F_indices(:,next_j_idx)) = ...
                - transpose(CoordinateFrame.RigidAdjoint(T_next)); % - transpose(CoordinateFrame.RigidAdjoint(T_next)) * f_next
            
        end
    end
    
    B_i = joint.TwistAxis;

    M(tau_expr_indices(j_idx), F_indices(:,j_idx)) = transpose(B_i); % transpose(joint.TwistAxis)*F
    if ~isempty(joint.Actuator)
        act = joint.Actuator;
        Vm = B_i*act.GearRatio*dq(j_idx);

        M(tau_expr_indices(j_idx), ddq_indices(j_idx)) = transpose(B_i)*(B_i.*((act.GearRatio)*(joint.Gm))*B_i*act.GearRatio);


        dVm= adV(Vm) * (Vm);
        b(tau_expr_indices(j_idx)) = - transpose(B_i)*(...
            B_i.*((act.GearRatio)*(joint.Gm * dVm - transpose(adV(Vm)) * (joint.Gm * Vm))));
    end

    

end

% inputs
torque = robot.Inputs.torque;
tau_map = double(torque.Gmap);
b(tau_expr_indices) = tau_map*u;


rs_contact = system.Gamma.Nodes.Domain{1}.HolonomicConstraints.RightSole;
Jh_rs = feval(rs_contact.Jh_name,q);
dJh_rs = feval(rs_contact.dJh_name,q,dq);

M(tau_expr_indices, lambda_indices) = -transpose(Jh_rs);


M(contact_expr_indices, ddq_indices) = Jh_rs;
b(contact_expr_indices) = -dJh_rs*dq;

% X = M\b;
% dV_res = X(dV_indices);
% F_res = X(F_indices);
% ddq_res = X(ddq_indices);
% lambda_res = X(lambda_indices);

    
X_test = [dV_test(:);F_test(:);ddq_test;lambda_test];


