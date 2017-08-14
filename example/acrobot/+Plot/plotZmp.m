function plotZmp(model, nlp, gait)
    
    mu = 0.9;
    La = 0.;
    Lb = 0.2;
    ax = [];
    
    if length(gait)==1 && isa(nlp,'TrajectoryOptimization')
        
        t = gait.tspan;
        
        force = gait.inputs.ffoot;
        q = gait.states.x;
    else
        cont_domain_idx = find(cellfun(@(x)isa(x,'ContinuousDynamics'),{nlp.Phase.Plant}));
        t = [];
        q = []; force = [];
        
        for j=cont_domain_idx
            t = [t,gait(j).tspan];
            force = [force,gait(j).inputs.ffoot];
            q = [q,gait(j).states.x];
        end
        
    end
    
    %     if length(gait)==1
    %         force = gait.inputs.ffoot;
    %         q = gait.states.x;
    %         t = gait.tspan;
    %     else
    %         t = [gait(1).tspan,gait(3).tspan, gait(5).tspan];
    %         q = [gait(1).states.x,gait(3).states.x, gait(5).states.x];
    %         force = [gait(1).inputs.ffoot,gait(3).inputs.ffoot, gait(5).inputs.ffoot];
    %     end
    
    f = figure(1);clf;
    f.Name = 'Friction Cone';
    set(f, 'WindowStyle', 'docked');
    ax = [ax, axes(f)];
    hold on;
    
    plot(t,force(1,:));
    plot(t,force(2,:).*mu./sqrt(2));
    plot(t,-force(2,:).*mu./sqrt(2));
    legend('Fx','Upper','Lower');
    
    
    
    f = figure(2);clf;
    f.Name = 'ZMP';
    set(f, 'WindowStyle', 'docked');
    ax = [ax, axes(f)];
    hold on;
    
    plot(t,force(3,:));
    plot(t,force(2,:).*Lb);
    plot(t,-force(2,:).*La);
    legend('My','Upper','Lower');
    
    
    for i=1:length(t)
        pcom_n(:,i) = pcom_acrobot(q(:,i));  %#ok<*AGROW>
    end
    pzmp_n = -force(3,:)./force(2,:);
    pcmp_n = pcom_n(1,:) - (force(1,:)./force(2,:)).*pcom_n(2,:);
    
    f = figure(3);clf;
    f.Name = 'ZMP Position';
    set(f, 'WindowStyle', 'docked');
    ax = [ax, axes(f)];
    plot(t,pcom_n(1,:));
    hold on;
    plot(t,pzmp_n);
    hold on;
    plot(t,pcmp_n);
    legend('com','zmp','cmp');
    
    linkaxes(ax, 'x');
end

