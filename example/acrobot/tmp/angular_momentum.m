D = robot.Mmat;
qs = robot.States.x;
dqs = robot.States.dx;
xs = [qs;dqs];
h_t = D(3,:)*dqs;
h_a = D(4,:)*dqs;
if length(gait)==1
    force = gait.inputs.ffoot;
    q = gait(1).states.x;
    dq = gait(1).states.dx;
    t = gait.tspan;
else
    t = [gait(1).tspan,gait(3).tspan, gait(5).tspan];
    q = [gait(1).states.x,gait(3).states.x, gait(5).states.x];
    dq = [gait(1).states.dx,gait(3).states.dx, gait(5).states.dx];
    force = [gait(1).inputs.ffoot,gait(3).inputs.ffoot, gait(5).inputs.ffoot];
end


for i=1:length(t)
    x_i = [q(:,i);dq(:,i)];
    ht_n(:,i) = double(subs(h_t,xs,x_i)); %#ok<SAGROW>
    ha_n(:,i) = double(subs(h_a,xs,x_i)); %#ok<SAGROW>
end

%% 
f = figure();clf
plot(t,ht_n); hold on
plot(t,ha_n);

%% 
m = robot.getTotalMass;