function [y_d1, y_d2, Dy_d1, Dy_d2, DLfy_d2, phip, tau, dtau, dy_d2_tau] = ...
    calcDesiredOutputs(obj, t, x, model)
    % calcActualOutputs- Calculate the actual outputs of the domain
    %   
    % 
    % Input: 
    %    * domain - domain
    %    * x  -  system states
    %
    % Output:
    %    * y_d1, y_d2, Dy_d1, Dy_d2, DLfy_d2
    %
    % Copyright 2014-2015 Texas A&M University AMBER Lab
    % Author: Ayonga Hereid <ayonga@tamu.edu>
    
    
    
    % Get parameters for easy access
    params = obj.params;
    v = params.v;
    a = params.a(:);
    p = params.p;
    p_range = params.p_range;
    
    %% phase variables
    if strcmpi(obj.outputs.type,'State-Based')
        % if state-based outputs, use MEX functions to compute
        % compute phase variable first
        tau   = obj.tau(x,p);   % phase variable
        dtau  = obj.dtau(x,p);  % time derivative of phase variable
        Jtau  = obj.Jtau(x,p);  % Jacobian of 'tau' w.r.t 'x'
        Jdtau = obj.Jdtau(x,p); % Jacobian of 'dtau' w.r.t 'x'
        
        % compute
        phip = obj.deltaphip(x);
        if obj.options.use_clamped_outputs
            
            if phip < p_range(1)
                phip_new = p_range(1);
                dtau = 0;
            elseif phip > p_range(2)
                phip_new = p_range(2);
                dtau = 0;
            end
            
            % compute tau using clamped phip value
            tau = (phip_new - p(2))/(p(1) - p(2));
        end
 
        
        
    else
        % if time-based outputs
        tau   = t;
        dtau  = 1;
        Jtau  = [1, zeros(1,model.n_dofs), ...
            0, zeros(1,model.n_dofs)];
        Jdtau = [0, zeros(1,model.n_dofs), ...
            1, zeros(1,model.n_dofs)];
        phip = [];
    end
    
    %% compute desired outputs
    % compute relative degree one output
    if ~isempty(obj.yd1)
        y_d1  = obj.yd1(tau,v);
        dy_d1 = obj.dyd1(tau,v);
        % chain rule
        Dy_d1 = dy_d1*Jtau;
    else
        y_d1  = [];
        Dy_d1 = [];
    end
    
    % compute relative degree two outputs
    y_d2   = obj.yd2(tau,a);
    
    dy_d2  = obj.dyd2(tau,a);
    ddy_d2 = obj.ddyd2(tau,a);
    
    % chain rule to compute jacobian
    Dy_d2   = dy_d2*Jtau;
    DLfy_d2 = ddy_d2*dtau*Jtau + dy_d2*Jdtau;
        
    % velocity of desired outputs
    dy_d2_tau = dy_d2*dtau;
end