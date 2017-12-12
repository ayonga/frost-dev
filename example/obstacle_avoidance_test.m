%% this is a test for simple 2 dimensional obstacle avoidance path planning
%% some specifications
t_min = 0.1; % original: 0.3
t_max = 1; % original: 0.35

[nnode,nx,nw] = getConstants();
%% initial guess

x0 = [0.1000 ...
    9.8594   -2.9472    0.5237   -6.0327    0.6000 ...
    0.1028    0.4850    2.1211    6.7829         0 ...
    9.6050   -2.4886    2.9031   -0.2750    0.2500 ...
    0   90    90   0  0.05    ]; 

lb = -100*ones(size(x0));
lb(1) = t_min;
lb(end)  = t_min/2;
ub =  100*ones(size(x0));
ub(1) = t_max;
ub(end) = t_max;
%%
% options = optimset('MaxFunEvals',10000);
options = optimset('Display','iter','Algorithm','sqp', 'MaxIter', 10000, 'MaxFunEvals', 100000, 'TolX',1e-5,'TolCon', 1e-5);
% options =[];
tic
result = fmincon(@f_obj,x0,[],[],[],[],lb,ub,@f_con,options);
toc


%% plot maadi
burger_x = [];
burger_y = [];
burger_z = [];

ae = reshape(result(2:16),[nx,5])
t_final = result(1)
t_mid  = result(end)


timestamps = 0:0.01:t_final;
for j=1:length(timestamps)
    ti = timestamps(j);
    burger_x = [burger_x,  poly_val(ti,ae(1,:))];
    burger_y = [burger_y , poly_val(ti,ae(2,:))];
    burger_z = [burger_z , poly_val(ti,ae(3,:))];
end
figure(1000);


subplot(2,1,1);
plot(timestamps,burger_x,timestamps,burger_y,timestamps,burger_z);
legend('x','y','z');
subplot(2,1,2);

corners = getGrillAndTableSpecs();
borderx = [corners.grill_box.p_min(1),...
           corners.grill_box.p_max(1),...
           corners.grill_box.p_max(1),...
           corners.table_box.p_min(1),...
           corners.table_box.p_min(1),...
           corners.grill_box.p_min(1),...
           corners.grill_box.p_min(1)];
bordery = [corners.grill_box.p_max(2),...
           corners.grill_box.p_max(2),...
           corners.grill_box.p_min(2),...
           corners.grill_box.p_min(2),...
           corners.table_box.p_max(2),...
           corners.table_box.p_max(2),...
           corners.grill_box.p_max(2)];
plot(borderx,bordery,burger_x,burger_y);
axis equal;


    %% objective function
    function ret = f_obj(input)
%     [nnode,nx,nw] = getConstants();

        ret = input(17)*input(18) + input(19)*input(20);
    end

    %% constraints
    function [c,ceq] = f_con(input)
        [nnode,nx,nw] = getConstants();
        nvar = nx;
        a = reshape(input(2:16),[nvar,5]);
        t_final = input(1);
        t_mid = input(end);
        time = linspace(0,t_final,nnode);

        c=[];
        ceq=[];
        
        %%
        x_i = poly_val(time(1),a(1,:));
        y_i = poly_val(time(1),a(2,:));
        z_i = poly_val(time(1),a(3,:));
        x_f = poly_val(time(end),a(1,:));
        y_f = poly_val(time(end),a(2,:));
        z_f = poly_val(time(end),a(3,:));
        
        p_start = [0.8;0.10;0.25];
        p_end = [0.3;0.8;0.25];
        
        w1 = input(17);
        w2 = input(18);
            
        w3 = input(19);
        w4 = input(20);
        
        for i = 1:length(time)
            t = time(i);
            x_pos = poly_val(t,a(1,:));
            y_pos = poly_val(t,a(2,:));
            z_pos = poly_val(t,a(3,:));
            if t < t_mid
                wsample = [w1;w2];
            else
                wsample = [w3;w4];
            end
            xsample = [x_pos;y_pos;z_pos];
            c = [c;
                f_obstacle(xsample,wsample)
                ];
        end

        c = [c;
             -w1;
             -w2;
             -w3;
             -w4;
             input(end) - input(1)
             ];
        
        ceq = [ceq;
            w_sum([w1,w2]);
             w_sum([w3,w4]);
%              w_mult([w1,w2]);
%              w_mult([w3,w4]);
                [x_i;y_i;z_i] - p_start;
                [x_f;y_f;z_f] - p_end];
                
    end

    %% miscellaneous 
    function ret = w_sum(w)
        ret = 100 - sum(w);
    end

    function ret = w_mult(w)
        ret = w(1) * w(2);
    end

    function collision_linear_constraints = f_obstacle(p_spatula,w)

    %     spatula_specs = getSpatulaSpecs();

        corners = getGrillAndTableSpecs();
        grill_box = corners.grill_box;
        table_box = corners.table_box;

        Region = struct();
        Region.nSubRegions = 2;
        % this is grill subregion
        Region.SubRegion(1).nPlanes = 4;
        Region.SubRegion(1).Planes(1).normal = [1,0,0];
        Region.SubRegion(1).Planes(1).point = grill_box.p_min;
        Region.SubRegion(1).Planes(2).normal = [0,-1,0];
        Region.SubRegion(1).Planes(2).point = grill_box.p_max;
        Region.SubRegion(1).Planes(3).normal = [-1,0,0];
        Region.SubRegion(1).Planes(3).point = grill_box.p_max;
        Region.SubRegion(1).Planes(4).normal = [0,1,0];
        Region.SubRegion(1).Planes(4).point = grill_box.p_min;
        % this is table subregion
        Region.SubRegion(2).nPlanes = 4;
        Region.SubRegion(2).Planes(1).normal = [1,0,0];
        Region.SubRegion(2).Planes(1).point = table_box.p_min;
        Region.SubRegion(2).Planes(2).normal = [0,-1,0];
        Region.SubRegion(2).Planes(2).point = table_box.p_max;
        Region.SubRegion(2).Planes(3).normal = [-1,0,0];
        Region.SubRegion(2).Planes(3).point = table_box.p_max;
        Region.SubRegion(2).Planes(4).normal = [0,1,0];
        Region.SubRegion(2).Planes(4).point = grill_box.p_min;

        collision_linear_constraints = [];

        for i = 1:Region.nSubRegions
            SubRegion = Region.SubRegion(i);
            for j = 1:SubRegion.nPlanes
                point = SubRegion.Planes(j).point;
                normal = SubRegion.Planes(j).normal;
                collision_linear_constraints = [collision_linear_constraints;...
                                                - (p_spatula' - point)*normal' - w(i)];
            end
        end
    end

    %% constant 
    function [nnode,nx,nw] = getConstants()
        nnode = 10;
        nx = 3;
        nw = 2;
    end
    
    function out = poly_val (t,a)
       out = 0;
       % last element of out is a constant
       for i=1:length(a)
           out = t* out + a(i);
       end
    end

 