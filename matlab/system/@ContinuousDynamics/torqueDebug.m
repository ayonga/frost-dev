function [u_sim,u_ff_sim,u_fb_sim] = torqueDebug(obj,controller,params,traj,time,u_opt,alpha,min,max)

for j=1:size(traj,2)
    nx = obj.numState;
    t=time(j);
    x=traj(:,j);
    q = x(1:nx);
    dq = x(nx+1:end);
    u_guess=u_opt(:,j);
    
    % store time and states into object private data for future use
    %         obj.t_ = t;
    %         obj.states_.x = q;
    %         obj.states_.dx = dq;
    
    % compute the mass matrix and drift vector (internal dynamics)
    M = calcMassMatrix(obj, q);
    Fv = calcDriftVector(obj, q, dq);

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
        % compute control inputs
        if ~isempty(controller)
            [u,u_ff,u_fb] = calcControl(controller, t, x, vfc, gfc, obj, params, [],alpha,max,min);
        else
            u = zeros(size(Be,2),1);
        end
        
        u_sim(:,j)=u;
        u_ff_sim(:,j)=u_ff;
        u_fb_sim(:,j)=u_fb;
        %         if strcmp(obj.Name,'stand')
        %             x;
        %             u;
        %         end
        
        
        %
        %         Gv_u = Be*u;
        %         obj.inputs_.Control.(control_name{1}) = u;
        
        
    end
    
end


end