function plotSimStates(system, logger, indices)
    
    
    
    domain = system.Gamma.Nodes.Domain{1};
    joint_names = {domain.Joints.Name};
    
    if nargin < 4
        indices = 1:length(domain.Joints);
    else
        if isempty(indices), return; end
    end
    
    t = [];
    x_sim = []; 
    dx_sim = []; 
    ddx_sim = [];
    
    for j=1:numel(logger)
        t = [t,logger(j).flow.t];
        
        x_sim = [x_sim,logger(j).flow.states.x];
        
        dx_sim = [dx_sim,logger(j).flow.states.dx];
        
        ddx_sim = [ddx_sim,logger(j).flow.states.ddx];
    end
    
    
    ax = [];
    for i=indices
        f = figure;clf;
        set(f, 'WindowStyle', 'docked');
        ax = [ax, subplot(3, 1, 1)]; %#ok<*AGROW>
        hold on;
        plot(t, x_sim(i,:), 'b');
        
        title('Joint Displacement');
        
        ax = [ax, subplot(3, 1, 2)];
        hold on;
        plot(t, dx_sim(i,:), 'b');
        title('Joint Velocity');
        
        ax = [ax, subplot(3, 1, 3)];
        hold on;
        plot(t, ddx_sim(i,:), 'b');
        
        title('Joint Acceleration');
        
        
        f.Name = [joint_names{i},'_state'];
    end
    
    linkaxes(ax, 'x');
    
    
    
    
end