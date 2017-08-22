rcom_list = [0.3,0.4,0.5,0.6,0.7];
thcom_list = [72,78,84,90,96];
prefix = 'res/gaits/static_trans_';

input = zeros(25,2);
output1 = zeros(25,6);
output2 = zeros(25,6);
output3 = zeros(25,6);
k = 0;
for i=1:length(rcom_list)
    for j=1:length(thcom_list)
        k = k+1;
        name = [prefix,'r-',num2str(rcom_list(i)),'_th=',num2str(thcom_list(j))];
        name = strrep(name,'.','-');
        param = load(name,'gait');
        x = param.gait(1).states.x(:,1);
        r = rcom_acrobot(x);
        theta = theta_com_acrobot(x);
        input(k,:) = [r,theta];
        
        a = reshape(param.gait(1).params.ajoints,3,6);
        output1(k,:) = a(1,:);
        output2(k,:) = a(2,:);
        output3(k,:) = a(3,:);
        
    end
end

for j=1:6
    f = figure();clf;
    set(f, 'WindowStyle', 'docked');
    plot3(input(:,1),input(:,2),output1(:,j),'*');
end
for j=1:6
    f = figure();clf;
    set(f, 'WindowStyle', 'docked');
    plot3(input(:,1),input(:,2),output2(:,j),'*');
end
for j=1:6
    f = figure();clf;
    set(f, 'WindowStyle', 'docked');
    plot3(input(:,1),input(:,2),output3(:,j),'*');
end
