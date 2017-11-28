function plotOptStates(model, nlp, gait, indices)
    
    
    if nargin < 4
        indices = 1:length(model.Joints);
    else
        if isempty(indices), return; end
    end
    
    cont_domain_idx = find(cellfun(@(x)isa(x,'ContinuousDynamics'),{nlp.Phase.Plant}));
    joint_names = {model.Joints.Name};
    
    t = [];
    x_opt = []; x_lb = [];  x_ub = [];
    dx_opt = []; dx_lb = [];  dx_ub = [];
    ddx_opt = []; ddx_lb = [];  ddx_ub = [];
    
    for j=cont_domain_idx
        t = [t,gait(j).tspan];
        
        x_opt = [x_opt,gait(j).states.x];
        x_lb  = [x_lb,[nlp.Phase(j).OptVarTable.x.LowerBound]];
        x_ub  = [x_ub,[nlp.Phase(j).OptVarTable.x.UpperBound]];
        
        dx_opt = [dx_opt,gait(j).states.dx];
        dx_lb  = [dx_lb,[nlp.Phase(j).OptVarTable.dx.LowerBound]];
        dx_ub  = [dx_ub,[nlp.Phase(j).OptVarTable.dx.UpperBound]];
        
        ddx_opt = [ddx_opt,gait(j).states.ddx];
        ddx_lb  = [ddx_lb,[nlp.Phase(j).OptVarTable.ddx.LowerBound]];
        ddx_ub  = [ddx_ub,[nlp.Phase(j).OptVarTable.ddx.UpperBound]];
    end
    
    
    ax = [];
    for i=indices
        f = figure;clf;
        set(f, 'WindowStyle', 'docked');
        ax = [ax, subplot(3, 1, 1)]; %#ok<*AGROW>
        hold on;
        plot(t, x_opt(i,:), 'b');
        plot(t, x_lb(i,:), 'r--');
        plot(t, x_ub(i,:), 'g--');
        
        title('Joint Displacement');
        legend('q', 'lb', 'ub'); 
        
        ax = [ax, subplot(3, 1, 2)];
        hold on;
        plot(t, dx_opt(i,:), 'b');
        plot(t, dx_lb(i,:), 'r--');
        plot(t, dx_ub(i,:), 'g--');
        title('Joint Velocity');
        legend('dq', 'lb', 'ub'); 
        
        ax = [ax, subplot(3, 1, 3)];
        hold on;
        plot(t, ddx_opt(i,:), 'b');
        plot(t, ddx_lb(i,:), 'r--');
        plot(t, ddx_ub(i,:), 'g--');
        
        title('Joint Acceleration');
        legend('ddq', 'lb', 'ub'); 
        
        
        f.Name = [joint_names{i},'_state'];
    end
    
    linkaxes(ax, 'x');
    
    
    
    
end