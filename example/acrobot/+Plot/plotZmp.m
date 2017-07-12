function plotZmp(gait)
    
    mu = 0.9;
    La = 0.;
    Lb = 0.2;
    
    
    if length(gait)==1
        force = gait.inputs.ffoot;
        q = gait.states.x;
        t = gait.tspan;
    else
        t = [gait(1).tspan,gait(3).tspan, gait(5).tspan];
        q = [gait(1).states.x,gait(3).states.x, gait(5).states.x];
        force = [gait(1).inputs.ffoot,gait(3).inputs.ffoot, gait(5).inputs.ffoot];
    end
    
    f = figure(1);clf;
    f.Name = 'Friction Cone';
    
    hold on;
    
    plot(t,force(1,:));
    plot(t,force(2,:).*mu./sqrt(2));
    plot(t,-force(2,:).*mu./sqrt(2));
    legend('Fx','Upper','Lower');
    
    
    
    f = figure(2);clf;
    f.Name = 'ZMP';
    
    hold on;
    
    plot(t,force(3,:));
    plot(t,force(2,:).*Lb);
    plot(t,-force(2,:).*La);
    legend('My','Upper','Lower');
    
    
    for i=1:length(t)
        pcom_n(:,i) = pcom_acrobot(q(:,i));  %#ok<*AGROW>
    end
    pzmp_n = -force(3,:)./force(2,:);
    pcmp_n = pcom_n(1,:) - (force(1,:)./force(2,:)).*pcom_n(3,:);
    
    f = figure(3);clf;
    f.Name = 'ZMP Position';
    plot(t,pcom_n(1,:));
    hold on;
    plot(t,pzmp_n);
    hold on;
    plot(t,pcmp_n);
    legend('com','zmp','cmp');
end

