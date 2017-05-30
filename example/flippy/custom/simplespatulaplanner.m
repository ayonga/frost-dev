function result = simplespatulaplanner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% some specifications
num_node = 30;    % number of nodes
mu = 0.17; % coefficient of restitution
g = 9.8; % gravity
wrist3joint_length = 0.09465;
% distance from mid point of spatula to its edge in x direction
spatula_depth = 0.06; 
t_min = 0.3;
t_max = 0.35;
n_outputs = 5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% initial guess

x0 = [    0.3059   27.8116         0   26.8203         0   96.2501   -9.5711         0   -8.9718      ...
    0  -26.9055   -1.7519         0    0.6834         0   -1.8161    1.2891         0   -0.0931       ...
    0   -1.1531    0.0000         0    0.0207         0    0.3500]; 


lb = -100*ones(size(x0));
lb(1) = t_min;
ub =  100*ones(size(x0));
ub(1) = t_max;

%% run this optimization
% options = optimset('MaxFunEvals',10000);
options =[];
tic
result = fmincon(@objective,x0,[],[],[],[],lb,ub,@mycon,options);
toc

%%  plot this 
burger_x = [];
burger_y = [];
burger_z = [];
burger_theta_x = [];
burger_theta_y = [];
burger_xdot = [];
burger_ydot = [];
burger_zdot = [];
burger_theta_xdot = [];
burger_theta_ydot = [];

ae = reshape(result(2:end),[n_outputs,n_outputs]);
t_final = result(1);
timestamps = 0:0.01:t_final;
for j=1:length(timestamps)
    ti = timestamps(j);
    burger_x = [burger_x,  poly(ti,ae(1,:))];
    burger_y = [burger_y , poly(ti,ae(2,:))];
    burger_z = [burger_z , poly(ti,ae(3,:))];
    burger_theta_x = [burger_theta_x , poly(ti,ae(4,:))];
    burger_theta_y = [burger_theta_y , poly(ti,ae(5,:))];
    burger_xdot = [burger_xdot , poly_derivative(ti,ae(1,:))];
    burger_ydot = [burger_ydot , poly_derivative(ti,ae(2,:))];
    burger_zdot = [burger_zdot , poly_derivative(ti,ae(3,:))];
    burger_theta_xdot = [burger_theta_xdot , poly_derivative(ti,ae(4,:))];
	burger_theta_ydot = [burger_theta_ydot , poly_derivative(ti,ae(5,:))];
end
figure(1000);


subplot(2,3,1);
plot(timestamps,burger_x,timestamps,burger_z);
legend('x','z');

subplot(2,3,2);
plot(timestamps,burger_theta_y);
legend('theta_y');

subplot(2,3,4);
plot(timestamps,burger_xdot,timestamps,burger_zdot);
legend('xdot','zdot');

subplot(2,3,5);
plot(timestamps,burger_theta_ydot);
legend('theta_y dot');

subplot(1,3,3);
plot3(burger_x,burger_y,burger_z,'linewidth',2);
xlabel('x');
ylabel('y');
zlabel('z');
grid on;
axis equal

axis([0 0.4 -0.2 0.2 -0.1 0.3])

%% save the result in a file
    if exist('writecsvfile.m', 'file')
        writecsvfile(result,n_outputs);
    else
        sprintf('Warning: file writecsvfile.m does not exist. Copy and save the following text in file name: writecsvfile.m in subfolder custom \n\n\n function writecsvfile(result,n_output) \n r = reshape(result(2:end),[n_output,n_output]); \n csvwrite(your file name with path,r); \n end')
    end

%%
    function [c,ceq] = mycon(input)

    a = reshape(input(2:end),[n_outputs,length(input(2:end))/n_outputs]);
    t_final = input(1);
    time = linspace(0,t_final,num_node);

    t_mid = 0.6*t_final;
    
    c = [];
    ceq = [];

    
    %% terminal values
        x_i = poly(time(1),a(1,:));
        y_i = poly(time(1),a(2,:));
        z_i = poly(time(1),a(3,:));
        theta_x_i = poly(time(1),a(4,:));
        theta_y_i = poly(time(1),a(5,:));
        x_f = poly(time(end),a(1,:));
        y_f = poly(time(end),a(2,:));
        z_f = poly(time(end),a(3,:));
        theta_x_f = poly(time(end),a(4,:));
        theta_y_f = poly(time(end),a(5,:));
        %
        xdot_i = poly_derivative(time(1),a(1,:));
        ydot_i = poly_derivative(time(1),a(2,:));
        zdot_i = poly_derivative(time(1),a(3,:));
        thetadot_x_i = poly_derivative(time(1),a(4,:));
        thetadot_y_i = poly_derivative(time(1),a(5,:));
        xdot_f = poly_derivative(time(end),a(1,:));
        ydot_f = poly_derivative(time(end),a(2,:));
        zdot_f = poly_derivative(time(end),a(3,:));
        thetadot_x_f = poly_derivative(time(end),a(4,:));
        thetadot_y_f = poly_derivative(time(end),a(5,:));
        
        spatulaedge_z_f = z_f - spatula_depth*sin(theta_y_f);
        
        %% mid values
        x_mid = poly(t_mid,a(1,:));
        theta_y_mid = poly(t_mid,a(5,:));
        
%%  constraints

        for i=1:length(time)
            t = time(i);
            
            %position
            x = poly(t,a(1,:));
            y = poly(t,a(2,:));
            z = poly(t,a(3,:));
            theta_x = poly(t,a(4,:));
            theta_y = poly(t,a(5,:));
            theta_z = 0;
            
            % velocity
            xdot = poly_derivative(t,a(1,:));
            ydot = poly_derivative(t,a(2,:));
            zdot = poly_derivative(t,a(3,:));
            theta_xdot = poly_derivative(t,a(4,:));
            theta_ydot = poly_derivative(t,a(5,:));
            
            % spatula edge position
            spatulaedge_x = x + spatula_depth*cos(theta_y);
            spatulaedge_y = y + spatula_depth*sin(theta_z);
            spatulaedge_z = z - spatula_depth*sin(theta_y);


          c = [c ; -x; -z; -xdot;  abs(xdot) - 20; abs(zdot) - 20];
          
          
        % acceleration constraints are satisfied for 80% of the trajectory
          if time(i) < t_mid  
              %acceleration
              if time(i) < 0.8*t_mid
                  a_x = poly_double_derivative(t,a(1,:));
                  a_y = poly_double_derivative(t,a(2,:));
                  a_z = poly_double_derivative(t,a(3,:));
                  
                  c = [c;
                          -(a_z*sin(theta_y)-a_x*cos(theta_y)+g*sin(theta_y)) ...
                         + mu* (a_x*sin(theta_y) + a_z*cos(theta_y) + g*cos(theta_y));
                      %                     spatulaedge_z - 0.20;
                      ];
              end
            ceq = [ceq;
                    spatulaedge_z;];
          else
              a_x = poly_double_derivative(t,a(1,:));
              a_y = poly_double_derivative(t,a(2,:));
              a_z = poly_double_derivative(t,a(3,:));
            
              c = [c; 
                 (a_z*sin(theta_y)-a_x*cos(theta_y)+g*sin(theta_y)) ...
                - mu* (a_x*sin(theta_y) + a_z*cos(theta_y) + g*cos(theta_y));
%                                     - spatulaedge_z;
                ];
          
          end
                  %% equality constraints
            ceq = [ceq;
                    y;
%                     spatulaedge_z;
                    theta_x;
                    ];
                                    
        end

        
        %% inequality terminal constraints
        c  = [ c;
                - spatulaedge_z_f + 0.03;
%                 z_f - 0.2;
%                 z_i - 0.2;
             ];
         
        
        %% equality terminal constraints
        
        ceq = [ceq;
                theta_y_i - 0.35; % initial pitch angle
                theta_y_mid - 0.02;         % mid pitch angle
                theta_y_f + 0.1;   % final pitch angle
%                 thetadot_y_i;     % intitial pitch velocity
                x_i;            % initial x position
                x_mid - 0.15;  % mid x position
                x_f - 0.2;    % final x position
                ];
                  
           
    end

    function f = objective(x)
      
        % calculating arc_length
        a = reshape(x(2:end),[n_outputs,length(x(2:end))/n_outputs]);
        t_final = x(1);
        time = linspace(0,t_final,num_node);
        f=0;
        y_dot = 0;
        z_dot = 0;
        for i =1:length(time)
            t = time(i);
            y_dot = poly_derivative(t,a(1,:));
        end
        f=0;
            
    end

    function out = poly (t,a)
       out = 0;
       % last element of out is a constant
       for i=1:length(a)
           out = t* out + a(i);
       end
    end

    function out = poly_derivative (t,a)
       out = 0;
       % last element of out is a constant
       for i=1:length(a)-1
           out = t* out + (5-i) * a(i);
       end
    end

    function out = poly_double_derivative (t,a)
       out = 0;
       % last element of out is a constant
       for i=1:length(a)-2
           out = t* out + (5-i)*(4-i) * a(i);
       end  
    end

end

