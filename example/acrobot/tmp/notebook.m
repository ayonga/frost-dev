pcom = robot.getComPosition();
pcom_fun = SymFunction(['pcom_',robot.Name],pcom,{robot.States.x});
pcom_fun.export(export_path);

pcom = robot.getComPosition();

for i=1:length(gait.tspan)
    pcom_n(:,i) = double(subs(pcom,robot.States.x,gait.states.x(:,i))); %#ok<SAGROW>
end
pzmp_n = -gait.inputs.ffoot(3,:)./gait.inputs.ffoot(2,:);
pcmp_n = pcom_n(1,:) - (gait.inputs.ffoot(1,:)./gait.inputs.ffoot(2,:)).*pcom_n(3,:);

% ffoot = SymVariable('f',[3,1]);
% 
% pzmp = ffoot(3)/ffoot(2);

% M = robot.getTotalMass();
% g = -9.81;
figure();clf;
plot(gait.tspan,pcom_n(1,:));
hold on;
plot(gait.tspan,pzmp_n);
hold on;
plot(gait.tspan,pcmp_n);
legend('com','zmp','cmp');

