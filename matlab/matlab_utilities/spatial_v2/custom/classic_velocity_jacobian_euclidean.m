%> @brief classic_velocity_jacobian Compute the classic velocity Jacobian
%> using the Euclidean formulation
%> @authors Eric Cousineau, Matthew Powell, Jordan Lack
%> @note Filched from:
%> amber_classic/core/matlab/+control/calcJacobianEuclidean.m (sha:
%> 3215f14)
function [J, dJ, calc] = classic_velocity_jacobian_euclidean(...
    model, q, dq, ib, offset, use_body_frame)

if nargin < 6 || isempty(use_body_frame)
    use_body_frame = false;
end

nb = model.NB;

% Following RBDL, Kinematics.cc, CalcPointJacobian
% Get chain for current dof, tracing up parent list
es = false(1, nb);
jb = ib;
while jb ~= 0
    es(jb) = true;
    jb = model.parent(jb);
end
% Get chain indices in a collapsed list
jbs = find(es);
nj = length(jbs);

% Position, velocity of end-effector
r = zeros(3, nj);
v = zeros(3, nj);
% Axis of dof in base frame
S = zeros(3, nj);
% Angular velocity in base frame
w = zeros(3, nb);
R = zeros(3, 3, nj);
dR = zeros(3, 3, nj);
dS = zeros(3, nb);

for j = 1:nj
    jb = jbs(j);
    axis = model.axis(jb);
    if j == 1
        R_lambda = eye(3);
        dR_lambda = zeros(3);
        w_lambda = zeros(3, 1);
        r_lambda = zeros(3, 1);
        v_lambda = zeros(3, 1);
    else
        R_lambda = R(:, :, j - 1);
        dR_lambda = dR(:, :, j - 1);
        w_lambda = w(:, j - 1);
        r_lambda = r(:, j - 1);
        v_lambda = v(:, j - 1);
        jb_lambda = jbs(j - 1);
        % Offset linear dofs
        if ~model.isRevolute(jb_lambda)
            r_lambda = r_lambda + S(:, j - 1) * q(jb_lambda);
            v_lambda = v_lambda + S(:, j - 1) * dq(jb_lambda);
        end
    end
    
    % Axis in base frame
    S(:, j) = rotation_axis(axis, R_lambda);
    
    if ~model.isRevolute(jb)
        Rj = R_lambda;
        wj = w_lambda;
    else
        R_rel = rotation_matrix(axis, q(jb));
        Rj = R_lambda * R_rel;
        wj = w_lambda + S(:, j) * dq(jb);
    end
    
    % TODO THIS IS INACCURATE! Use SVA verison! Verify velocities! or
    % something...
    Xtree = model.Xtree(:,:,jb);
    [E_j, offset_j] = plux(Xtree);
    
    r(:, j) = r_lambda + R_lambda * offset_j;
    v(:, j) = v_lambda + dR_lambda * offset_j;
    
    w(:, j) = wj;
    R(:, :, j) = Rj * E_j';
    dR(:, :, j) = skew(wj) * Rj * E_j';
    dS(:, j) = rotation_axis(axis, dR_lambda); % skew(wp) * S(:, j)
end

%% Linear and Angular Velocity Jacobians
rp = r(:, nj) + R(:, :, nj) * offset;
vp = v(:, nj) + dR(:, :, nj) * offset;

Jv = zeros(3, nb);
Jw  = zeros(3, nb);
dJv = zeros(3, nb);
dJw  = zeros(3, nb);

for j = 1:nj
    rp_rel = rp - r(:, j);
    % Might be able to simplify this
    vp_rel = vp - v(:, j);
    
    jb = jbs(j);
    if model.isRevolute(jb)
        Jv(:, jb) = skew(S(:, j)) * rp_rel;
        dJv(:, jb) = skew(dS(:, j)) * rp_rel + skew(S(:, j)) * vp_rel;
        
        if use_body_frame
            Jw(:, jb) = R(:, :, nj)' * S(:, j);
            dJw(:, jb) = dR(:, :, nj)' * S(:, j) ...
                + R(:, :, nj)' * dS(:, j);
        else
            Jw(:, jb) = S(:, j);
            dJw(:, jb) = dS(:, j);
        end
    else
        Jv(:, jb) = S(:, j);
    end
end

% Keeping Sastry's order for twist, \xi = [v; w]
J = [Jv; Jw];
dJ = [dJv; dJw];

if nargin >= 3
    calc = struct();
    calc.rp = rp;
    calc.vp = vp;
end

end
