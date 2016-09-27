%> @brief calcJacobianSvaHack Compute the velocity Jacobian
%> using the SVA
%> @author Matthew Powell
%> @author Eric Cousineau
%> @note Filched from:
%> amber_classic:3215f14:core/matlab/+control/calcJacobianSvaHack.m
function [J, Jdot, calc] = calcJacobianSvaHack(sva, qe, dqe, ...
    dofIndex, offset, useBodyFrame, tIndices, rIndices)


if nargin < 6 || isempty(useBodyFrame)
    useBodyFrame = false;
end

nb = sva.NB;
ib = dofIndex;

% Following RBDL, Kinematics.cc, CalcPointJacobian
% Get chain for current dof, tracing up parent list
es = false(1, nb);
jb = ib;
while jb ~= 0
    es(jb) = true;
    jb = sva.parent(jb);
end
% Get chain indices in a collapsed list
jbs = find(es);
nj = length(jbs);

% if isempty(kin)
%     [~, ~, kin] = amber.control.HandCKinematic(sva, qe, dqe);
% end

[Xbase, S, v] = spatial_kinematics(sva, qe, dqe);

X_T = xlt(offset);
jb = jbs(end);
L_X_b = Xbase(:,:,jb);
L_XT_b = X_T * L_X_b;
[~, b_r_p] = plux(L_XT_b);
% Orientation of p w.r.t. world 'b'
b_R_p = plux(L_X_b)';
% Angular velocity of 'p' w.r.t. world
b_w_p = b_R_p * v(1:3,:,jb);
b_Rdot_p = skew(b_w_p) * b_R_p;

b_vh_p = rot(b_R_p) * X_T * v(:,:,jb);
b_v_p = b_vh_p(4:6);

Jv = zeros(3, nb);
Jw  = zeros(3, nb);
Jvdot = zeros(3, nb);
Jwdot  = zeros(3, nb);

for j = 1:nj
    jb = jbs(j);
    if j == 1
        L_X_b = eye(6);
        vh_L = zeros(6, 1);
    else
        jbLambda = sva.parent(jb);
        L_X_b = Xbase(:,:,jbLambda);
        vh_L = v(:,:,jbLambda);
    end
    
    % THERE IS A BETTER WAY FOR Jvdot... Just don't know it yet :/
    
    % Origin at this dof, but in parent's orientation (see Martin's
    % stuff)
    X_T = sva.Xtree(:,:,jb);
    L_XT_b = X_T * L_X_b;
    [L_R_b, b_r_j] = plux(L_XT_b);
%     b_Xr_L = rot(L_R_b');
    
    j_X_b = Xbase(:,:,jb);
    [j_R_b, ~] = plux(j_X_b);
    b_Xr_j = rot(j_R_b');
    
    % Angular Velocity - just reorient
    b_S_j = b_Xr_j * S(:,:,jb);
    %     b_vh_j = b_Xr_j * kin.v{jb};
    %     b_w_j = b_vh_j(1:3);
    b_w_j = j_R_b' * v(1:3,:,jb);
    
    % Linear Velocity of point in parent's frame, L_v_j = XT * vh_lambda
    % b_v_j = b_R_L * (v_L + skew(w_L) * L_r_Lj) -- L_r_Lj - displacement from L to j in L's frame 
    % Very similar to XT_lambda, but with position removed
    L_vh_j = X_T * vh_L;
    b_v_j = L_R_b' * L_vh_j(4:6);
    
    % Rdot = skew(w) * R  <==>  Rdot' = -R' * skew(w)
    b_R_j = j_R_b';
    b_Rdot_j = skew(b_w_j) * b_R_j;
    % Could just multiply by crm([b_w_j; zeros(3, 1)])
    b_Sdot_j = rot(b_Rdot_j) * S(:,:,jb);
    
    rp_rel = b_r_p - b_r_j;
    % Might be able to simplify this
    vp_rel = b_v_p - b_v_j;
    
    if sva.isRevolute(jb)
        b_Sw_j = b_S_j(1:3);
        b_Swdot_j = b_Sdot_j(1:3);
        
        Jv(:, jb) = skew(b_Sw_j) * rp_rel;
        Jvdot(:, jb) = skew(b_Swdot_j) * rp_rel + skew(b_Sw_j) * vp_rel;
        
        Jw(:, jb) = b_Sw_j;
        Jwdot(:, jb) = b_Swdot_j;
    else
        b_Sv_j = b_S_j(4:6);
        b_Svdot_j = b_Sdot_j(4:6); % update: 12/23/2014
        b_Sw_j = b_S_j(1:3);
        b_Swdot_j = b_Sdot_j(1:3);
        
        Jv(:, jb) = b_Sv_j;
        Jvdot(:, jb) = b_Svdot_j; % update: 12/23/2014
        Jw(:, jb) = b_Sw_j;
        Jwdot(:, jb) = b_Swdot_j;
    end
end

if useBodyFrame
    Jw = b_R_p' * Jw;    
    Jwdot = b_Rdot_p' * Jw + b_R_p' * Jwdot;
end

% Linear, then angular

% J_full    = [Jv; Jw];
% Jdot_full = [Jvdot; Jwdot];
% 
% J = J_full(indices,:);
% Jdot = Jdot_full(indices,:);
J = [Jv(tIndices,:); Jw(rIndices,:)];
Jdot = [Jvdot(tIndices,:); Jwdot(rIndices,:)];

if nargout >= 3
    calc = struct();
    calc.rp = b_r_p;
    calc.vp = b_v_p;
end

end