function [xdot] = secondOrderDynamics_stand(obj, t, x, controller, params, logger, alpha,min,max)
% calculate the dynamical equation of the second order dynamical system
%
% Parameters:
% t: the time instant @type double
% x: the states @type colvec
% controller: the controller @type Controller
% params: the parameter structure @type struct
% logger: the data logger object @type SimLogger
%
% Return values:
% xdot: the derivative of the system states @type colvec

% extract the state variables into x and dx
nx = obj.numState;
q = x(1:nx);
dq = x(nx+1:end);

% [overLim,q]=ExoCalculations.capStates(obj,q);
% if overLim
%     'pause'
% end

% store time and states into object private data for future use
obj.t_ = t;
obj.states_.x = q;
obj.states_.dx = dq;

% compute the mass matrix and drift vector (internal dynamics)
M = calcMassMatrix(obj, q);
Fv = calcDriftVector(obj, q, dq);

global standUp original

% original=1;

%% get the external input
% initialize the Gv_ext vector
if strcmp(obj.Name,'slowDown')
    'pause';
end
Gv_ext = zeros(nx,1);
f_ext_name = fieldnames(obj.Inputs.External);
if ~isempty(f_ext_name)              % if external inputs are defined
    n_ext = length(f_ext_name);
    
    for i=1:n_ext
        f_name = f_ext_name{i};
        % get the Gvec function object
        % g_fun = obj.Gvec.External.(f_name);
        % call the callback function to get the external input
        
        f_ext = obj.ExternalInputFun(obj, f_name, t, q, dq, params, logger);
        
        % compute the Gvec, and add it up
        %         if ~original
        %             f_ext=[f_ext;0];
        %         end
        if length(f_ext)==1
            'wrong size'
        end
        Gv_ext = Gv_ext + feval(obj.GvecName_.External.(f_name),q,f_ext);
        
        % store the external inputs into the object private data
        obj.inputs_.External.(f_name) = f_ext;
    end
end


%% holonomic constraints
h_cstr_name = fieldnames(obj.HolonomicConstraints);
if ~isempty(h_cstr_name)           % if holonomic constraints are defined
    h_cstr = struct2array(obj.HolonomicConstraints);
    n_cstr = length(h_cstr);
    % determine the total dimension of the holonomic constraints
    cdim = sum([h_cstr.Dimension]);
    % initialize the Jacobian matrix
    Je = zeros(cdim,nx);
    Jedot = zeros(cdim,nx);
    
    idx = 1;
    for i=1:n_cstr
        cstr = h_cstr(i);
        
        % calculate the Jacobian
        [Jh,dJh] = calcJacobian(cstr,q,dq);
        cstr_indices = idx:idx+cstr.Dimension-1;
        tol = 1e-2;
        if norm(Jh*dq) > tol
            warning('The holonomic constraint %s violated.', h_cstr_name{i});
        end
        Je(cstr_indices,:) = Jh;
        Jedot(cstr_indices,:) = dJh;
        idx = idx + cstr.Dimension;
    end
else
    Je = [];
    Jedot = [];
end


%% calculate the constrained vector fields and control inputs
control_name = fieldnames(obj.Inputs.Control);
Gv_u = zeros(nx,1);
if ~isempty(control_name)
    Be = feval(obj.GmapName_.Control.(control_name{1}),q);
    Ie    = eye(nx);
    
    if isempty(Je)
        vfc = [
            dq;
            M \ (Fv)];
        gfc = [
            zeros(size(Be));
            M \ Be];
    else
        XiInv = Je * (M \ transpose(Je));
        % compute vector fields
        % f(x)
        vfc = [
            dq;
            M \ ((Ie-transpose(Je) * (XiInv \ (Je / M))) * (Fv) - transpose(Je) * (XiInv \ Jedot * dq))];
        
        
        % g(x)
        gfc = [
            zeros(size(Be));
            M \ (Ie - transpose(Je)* (XiInv \ (Je / M))) * Be];
    end
    %%
    if alpha.controllerModel.exist
        sysCtrl=alpha.controllerModel.sys;
        if alpha.domain.fiveNodes
            if strcmp(obj.Name,'sit')
                objCtrl=sysCtrl.Gamma.Nodes(1,:).Domain{1};
            elseif strcmp(obj.Name,'standZMP')
                objCtrl=sysCtrl.Gamma.Nodes(2,:).Domain{1};
            elseif strcmp(obj.Name,'standVert')
                objCtrl=sysCtrl.Gamma.Nodes(3,:).Domain{1};
            elseif strcmp(obj.Name,'slowDown')
                objCtrl=sysCtrl.Gamma.Nodes(4,:).Domain{1};
            end
        elseif alpha.domain.stabilizeDomain
            objCtrl=sysCtrl.Gamma.Nodes(1,:).Domain{1};
        end
        extF_name=obj.GvecName_.External.(f_name);
        BeF_name=obj.GmapName_.Control.(control_name{1});
        info.controller=controller;
        info.params=params;
        info.logger=logger;
        info.alpha=alpha;
        info.min=min;
        info.max=max;
        info.original=original;
        info.extF_name=extF_name;
        info.BeF_name=BeF_name;
        [M_ctrl,Fv_ctrl,Je_ctrl,Jedot_ctrl,Be_ctrl,Gv_ext_ctrl,f_ext_ctrl]=ExoController.secondOrderDynamicsControllerModel(objCtrl, t, x, info);
   
    else
        M_ctrl=M;
        Fv_ctrl=Fv;
        Je_ctrl=Je;
        Jedot_ctrl=Jedot;
        Be_ctrl=Be;
        Gv_ext_ctrl=Gv_ext;
        f_ext_ctrl=f_ext;
        objCtrl=obj;
    end
    
    
    %%
    % compute control inputs
    if ~isempty(controller)
        %                     u = calcControl(controller, t, x, vfc, gfc, obj, params, logger,alpha,min,max);
        if standUp || strcmp(obj.Name,'slowDown')   %if strcmp(alpha{10},'standUp')
            u_eva=ExoController.standController(objCtrl, t,params,logger, q, dq, Je_ctrl,Jedot_ctrl, M_ctrl, Be_ctrl, Fv_ctrl, Gv_ext_ctrl, alpha,min,max,original,f_ext_ctrl);
        else
            if original
                %            u_eva=ExoController.torqueGroundReactionForce(obj, t,params,logger, q, dq, Je,Jedot, M, Be, Fv, Gv_ext, alpha,min,max);
                u_eva=ExoController.torqueGroundReactionForce_Final(objCtrl, t,params,logger, q, dq, Je_ctrl,Jedot_ctrl, M_ctrl, Be_ctrl, Fv_ctrl, Gv_ext_ctrl, alpha,min,max);
                %             u_eva=ExoController.standDomainTime(obj, t,params,logger, q, dq, Je,Jedot, M, Be, Fv, Gv_ext, alpha,min,max);
                %              u_eva=ExoController.standDomainPhase(obj, t,params,logger, q, dq, Je,Jedot, M, Be, Fv, Gv_ext, alpha,min,max);
            else
                
                %                 u_eva=ExoController.torqueGroundReactionForce_Slack(obj, t,params,logger, q, dq, Je_ctrl,Jedot_ctrl, M_ctrl, Be_ctrl, Fv_ctrl, f_ext_ctrl, alpha,min,max);
                u_eva=ExoController.torqueGroundReactionForce_Slack_ZMP(objCtrl, t,params,logger, q, dq, Je_ctrl,Jedot_ctrl, M_ctrl, Be_ctrl, Fv_ctrl, f_ext_ctrl, alpha,min,max);
                
            end
        end
        u=u_eva(1:12);
        %
    else
        u = zeros(size(Be_ctrl,2),1);
    end
    Gv_u = Be_ctrl*u;
    obj.inputs_.Control.(control_name{1}) = u;
    
end
%% calculate constraint wrench of holonomic constraints
if original
    Gv = Gv_ext + Gv_u; %if the optimizer did not find the user force
else   %if the optimizer found the user force
    
    Gv_ext = zeros(nx,1);
    f_ext_name = fieldnames(obj.Inputs.External);
    if ~isempty(f_ext_name)              % if external inputs are defined
        n_ext = length(f_ext_name);
        
        for i=1:n_ext
            f_name = f_ext_name{i};
            % get the Gvec function object
            % g_fun = obj.Gvec.External.(f_name);
            % call the callback function to get the external input
            %             f_ext = u_eva(end-8:end-6); %grabbing the user force from the qp solution
            f_ext = u_eva(end-2:end); %grabbing the user force from the qp solution
            
            % compute the Gvec, and add it up
            
            Gv_ext = Gv_ext + feval(obj.GvecName_.External.(f_name),q,f_ext);
            
            % store the external inputs into the object private data
            obj.inputs_.External.(f_name) = f_ext;
        end
    end
    Gv = Gv_ext + Gv_u;
end
% Calculate constrained forces
Gv_c = zeros(nx,1);
if ~isempty(h_cstr_name)
    lambda = -XiInv \ (Jedot * dq + Je * (M \ (Fv + Gv)));
    
    %         if original
    %                 lambda_ctrl=u_eva(13:end);
    %         else
    %                 lambda_ctrl=u_eva(13:end-4);
    %         end
    % the constrained wrench inputs
    %     lambda=lambda_ctrl;
    Gv_c = transpose(Je)*lambda;
    
    % extract and store
    idx = 1;
    for i=1:n_cstr
        cstr = h_cstr(i);
        hval.(h_cstr_name{i}) = calcConstraint(cstr,q);
        cstr_indices = idx:idx+cstr.Dimension-1;
        input_name = cstr.InputName;
        obj.inputs_.ConstraintWrench.(input_name) = lambda(cstr_indices);
        idx = idx + cstr.Dimension;
    end
else
    hval = [];
end

Gv = Gv + Gv_c;

% the system dynamics
xdot = [dq;
    M \ (Fv + Gv)];
% xdot=[dq;inv(M)*(Fv+Be*u+Je'*lambda+Gv_ext)];
obj.states_.ddx = xdot(nx+1:end);
% dq_eva=xdot(1:18)
% other=xdot(19:end)
%     xdot=[xdot(7:nx);xdot((nx+7):end)];


if ~isempty(logger)
    calc = logger.calc;
    
    calc.t       = t;
    calc.states  = obj.states_;
    calc.inputs  = obj.inputs_;
    calc.hval     = hval;
    
    logger.calc  = calc;
end
end