function plotSimTorques(system, logger, indices)
    
    domain = system.Gamma.Nodes.Domain{1};
    act_joint_idx = find(arrayfun(@(x)~isempty(x.Actuator),domain.Joints));
    
    if nargin < 4
        indices = act_joint_idx;
    else
        if isempty(indices), return; end
    end
    
    joint_names = {domain.Joints.Name};
    
    t = [];
    u_sim = [];
    
    for j=1:numel(logger)
        t = [t,logger(j).flow.t];
        
        u_sim = [u_sim,logger(j).flow.inputs.Control.u];
    end
    
    
    ax = [];
    for i=1:length(indices)
        idx = indices(i);
        if ~ismember(idx,act_joint_idx)
            continue;
        end
        f = figure;clf;
        set(f, 'WindowStyle', 'docked');
        %         f.Position = [680 558 560 420];
        ax = [ax, axes(f)]; %#ok<LAXES,*AGROW>
        hold on;
        plot(t, u_sim(i,:), 'b');
        
        title('Torque');
        
        
        
        
        f.Name = [joint_names{idx},'_torque'];
    end
    
    linkaxes(ax, 'x');
    
    
    
    
end