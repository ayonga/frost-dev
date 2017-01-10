% insert comment here (if needed)
% @todo fix the QP-CLF for the new controller
function [ret_u, extra] = calcClfMultiLagrange(obj,controller, model, ...
    eta, Abar, Lf_mat, AeqLagrange, beqLagrange)

use_fast_qp = false;


ep = controller.ep;
e = 1/ep;
clfs = obj.clfs;
%%%%%%%%%%%%%%%%%% INITIALIZATION
nExtForce = obj.nHolConstr;
nActuators = obj.nAct;
nClf = length(clfs);

H = zeros(nClf + nActuators + nExtForce);
f = zeros(1,nClf + nActuators + nExtForce);

nVar = nClf + nActuators + nExtForce;
nBar = nActuators + nExtForce;

Aclf = zeros(nClf, nClf + nActuators + nExtForce);
bclf = zeros(nClf, 1);

%%%%%%%%%%%%%%%%%% COST
for i = 1:nClf
    H(i,i) = clfs(i).penalty;
end



% if ~isempty(prevCalc)
%     uPrev = prevCalc.u;
% else
%     uPrev = zeros(nActuators, 1);
% end

if controller.useUTransposeU
    Hbar = blkdiag(eye(nActuators), zeros(nExtForce));
    fbar = zeros(nBar, 1);
else
    Hbar = Abar' * Abar;
    fbar = 2 * Lf_mat' * Abar;
end

if controller.useUPrev
    Hbar = Hbar + blkdiag(eye(nActuators), zeros(nExtForce));
	fbar = fbar - [2 * uPrev', zeros(nExtForce,1)'];
end

if controller.useSVD
	[U,S,~] = svd(Hbar);
	r = rank(S);
	U1 = U(:,1:r);
	U2 = U(:,r+1:end);
	S1 = S(1:r,1:r);
	
	Htemp = U1*S1*U1' + controller.posDefSafety*(U2*U2');
% 	Htempnorm = norm(Htemp - Htemp');
% 	rank(Htemp) - length(Htemp);
	%%% Update Hbar with symmetric Htemp
	Hbar = (Htemp + Htemp')/2;
%     Htempnormnew = norm(Htemp - Htemp');
end

H(nClf + 1:end, nClf + 1:end) = Hbar;
f(nClf + 1:end) = fbar;

Psi0s = zeros(nClf, 1);

%%%%%%%%%%%%%%%%%% CONSTRAINTS, BUILDUP CLF's FIRST
for i = 1:nClf
    clf = clfs(i);
    etaIndices = clf.etaIndices;
    qcare = clf.care;
    if (clf.nOutputs ~= 0)
        etaSplit = eta(etaIndices);
        
        if clf.relDegree == 1
            % Degree one
            Ve1_num   = etaSplit^2;
            Psi0 = (1/e) * Ve1_num;
            Psi1  = 2 * etaSplit;
        else
            % Degree two
            G_mat = qcare.G;
            F_mat = qcare.F;
            C3_num = qcare.C3;
            Pe_mat = qcare.Pe;
            
            Ve_num = Ve(etaSplit, Pe_mat);
            
            LfVe_num = LfVe(etaSplit, Pe_mat, F_mat);
            Psi0 = LfVe_num + (C3_num/e) * Ve_num;
            Psi1 = (2 * etaSplit' * Pe_mat * G_mat)';
        end
        
        Aclf(i, i) = clf.relaxation;
        % Better name needed
        etaIndicesNoDot = etaIndices(1:clf.nOutputs);
        Aclf(i, nClf + 1:end) = Psi1' * Abar(etaIndicesNoDot, :);
        bclf(i) = -Psi0 - Psi1' * Lf_mat(etaIndicesNoDot);
        
        Psi0s(i) = Psi0;
    end
end


%% torque limit
if controller.applyTorqueLimit
    Atorque = ...
        [zeros(2*nActuators,nClf),...
        [eye(nActuators); -eye(nActuators)],...
        zeros(2*nActuators,nExtForce)];
    uMax = model.torqueLimitMax(obj.qaIndices);
    uMin = model.torqueLimitMin(obj.qaIndices);
    btorque = [uMax;-uMin];
else
    Atorque = [];
    btorque = [];
end


%% ZMP constraints


%% max convergence
if controller.MaxConvergence

    AMaxConvergence = [];
    bMaxConvergence = [];

%     for i = 1:nClf
%         AMaxConvergence_tem = zeros(nActuators,nCLF+nActuators+nExtForce);
%         bMaxConvergence_tem = zeros(nActuators,1);
%         
%         AMaxConvergence_tem(:,i) = -1;
%         diag(AMaxConvergence_tem(nCLF+[1:nActuators],nCLF+[1:nActuators])) = Psi1'*A;
%         
%         AMaxConvergence = [AMaxConvergence;AMaxConvergence_tem];
%         bMaxConvergence = [bMaxConvergence;bMaxConvergence_tem];
%     end
    
else
    AMaxConvergence = [];
    bMaxConvergence = [];
end




%% positive normal forces
if obj.nHolConstr ~= 0
    %     ExtForceDirections = +(~cellfun(@isempty, strfind(obj.holConstrName,'PosZ')));
    %     ForceIndicies = find(ExtForceDirections);
    %     nForce = length(ForceIndicies);
    %     extForce = diag(ExtForceDirections');
    %     AExtForce = [zeros(nForce, nClf + nActuators), -extForce(ForceIndicies, :)];
    %     bExtForce = zeros(nForce, 1);
    AExtForce = [];
    bExtForce = [];
else
    AExtForce = [];
    bExtForce = [];
end

%% ZMP constraints

if controller.applyZMPConstraints
    % Foot dimensions
    wf = model.widthFoot;
    lh = model.lengthHeel;
    lt = model.lengthToe;
    
    zmpList = {{'RightFootCartX','RightFootPosZ',[wf,-wf/2;-wf,-wf/2]};...
        {'RightFootCartY','RightFootPosZ',[lh+lt,-lt;-(lh+lt),-lh]};...
        {'RightToeCartX','RightToePosZ',[wf,-wf/2;-wf,-wf/2]};...
        {'RightToeCartY','RightToePosZ',[lh+lt,0;-(lh+lt),-(lt+lh)]};...
        {'RightHeelCartX','RightHeelPosZ',[wf,-wf/2;-wf,-wf/2]};...
        {'RightHeelCartY','RightHeelPosZ',[lh+lt,-(lt+lh);-(lh+lt),0]};...
        {'LeftFootCartX','LeftFootPosZ',[wf,-wf/2;-wf,-wf/2]};...
        {'LeftFootCartY','LeftFootPosZ',[lh+lt,-lt;-(lh+lt),-lh]};...
        {'LeftToeCartX','LeftToePosZ',[wf,-wf/2;-wf,-wf/2]};...
        {'LeftToeCartY','LeftToePosZ',[lh+lt,0;-(lh+lt),-(lt+lh)]};...
        {'LeftHeelCartX','LeftHeelPosZ',[wf,-wf/2;-wf,-wf/2]};...
        {'LeftHeelCartY','LeftHeelPosZ',[lh+lt,-(lt+lh);-(lh+lt),0]}};
    AzmpCell = cell(numel(zmpList),1);
    
    for i = 1:numel(zmpList)
        zmp_i = zmpList{i};
        m_index = find(strcmp(obj.holConstrName,zmp_i{1}),1);
        if ~isempty(m_index)
            Azmp_i = zeros(2,obj.nHolConstr);            
            f_index = find(strcmp(obj.holConstrName,zmp_i{2}),1);
            Azmp_i(:,[m_index,f_index]) = zmp_i{3};
            AzmpCell{i} = Azmp_i;
        else
            AzmpCell{i} = [];
        end
    end
    Azmp_f = vertcat(AzmpCell{:});
    
    Azmp = [zeros(size(Azmp_f,1),nClf+nActuators),Azmp_f];
    bzmp = zeros(size(Azmp_f,1),1);
else
    Azmp = [];
    bzmp = [];
    
end

if ~isempty(controller.frictionCoeff)
    k = controller.frictionCoeff/sqrt(2);
    
    fricList = {{'RightFootPosX','RightFootPosZ',[1,-k;-1,-k]};...
        {'RightFootPosY','RightFootPosZ',[1,-k;-1,-k]};...
        {'RightToePosX','RightToePosZ',[1,-k;-1,-k]};...
        {'RightToePosY','RightToePosZ',[1,-k;-1,-k]};...
        {'RightHeelPosX','RightHeelPosZ',[1,-k;-1,-k]};...
        {'RightHeelPosY','RightHeelPosZ',[1,-k;-1,-k]};...
        {'LeftFootPosX','LeftFootPosZ',[1,-k;-1,-k]};...
        {'LeftFootPosY','LeftFootPosZ',[1,-k;-1,-k]};...
        {'LeftToePosX','LeftToePosZ',[1,-k;-1,-k]};...
        {'LeftToePosY','LeftToePosZ',[1,-k;-1,-k]};...
        {'LeftHeelPosX','LeftHeelPosZ',[1,-k;-1,-k]};...
        {'LeftHeelPosY','LeftHeelPosZ',[1,-k;-1,-k]}};
    AfricCell = cell(numel(fricList),1);
    
    for i = 1:numel(fricList)
        fric_i = fricList{i};
        xy_index = find(strcmp(obj.holConstrName,fric_i{1}),1);
        if ~isempty(xy_index)
            Afric_i = zeros(2,obj.nHolConstr);            
            z_index = find(strcmp(obj.holConstrName,fric_i{2}),1);
            Afric_i(:,[xy_index,z_index]) = fric_i{3};
            AfricCell{i} = Afric_i;
        else
            AfricCell{i} = [];
        end
    end
    Afric_f = vertcat(AfricCell{:});
    
    Afric = [zeros(size(Afric_f,1),nClf+nActuators),Afric_f];
    bfric = zeros(size(Afric_f,1),1);
else
    Afric = [];
    bfric = [];
end
%% rate limit on control input 'u' (must be used with useUPrev)
if ~isnan(controller.uRateLimit)
    Alimit = [zeros(2 * nActuators, nClf), ...
        [eye(nActuators); -eye(nActuators)], zeros(2 * nActuators, nExtForce)];
    blimit = [controller.uRateLimit + uPrev;
        controller.uRateLimit - uPrev];
else
    Alimit = [];
    blimit = [];
end
%% 



% equality constraints
Aeq = [zeros(nExtForce, nClf), AeqLagrange];
beq = beqLagrange;

% inequality constraints
Aiq = [Aclf; Atorque; Azmp; Afric; AExtForce;  Alimit; AMaxConvergence];
biq = [bclf; btorque; bzmp; bfric; bExtForce;  blimit; bMaxConvergence];




%%% Old H matrix with Identity regularization
if ~controller.useSVD
    H = H + controller.posDefSafety * eye(nVar);
end

% QP option
quad_opt = optimset('Display','off','Algorithm', 'interior-point-convex',...
        'TolX',1e-6,'TolFun',1e-6);
    
    
if use_fast_qp
    u_qp = quadprog_fast(2 * H, f', Aiq, biq, Aeq, beq);
else
    [u_qp,fval,exitflag,output,lambda] = quadprog(2 * H,f',Aiq,biq,Aeq,beq,[],[],[],quad_opt);
end




if nargout >= 2
    extra = struct();
    extra.obj = fval;
    extra.H = H;
    extra.f = f;
    extra.Aiq = Aiq;
    extra.biq = biq;
    extra.Aeq = Aeq;
    extra.beq = beq;
%     extra.Ve_num = Ve_num;
%     extra.LfVe_num = LfVe_num;
    extra.Psi0s = Psi0s;
%     extra.Psi1 = Psi1;
    extra.x = u_qp;
	extra.ep = ep;
	extra.exitflag = exitflag;
end


ret_u = u_qp(nClf+1:end); 

    function ret = Ve(etav,Pem)
        ret = etav' * Pem *etav;
    end

    function ret = LfVe(etav,Pem,Fm)
        ret = etav'*(Fm'*Pem + Pem*Fm)*etav;
    end

end