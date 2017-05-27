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
t_max = 0.3;
n_outputs = 5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% initial guess

  x0 = [0.3      -16.4445         0    3.1462         0    0.0000 ...
         0         0         0         0         0 ...
   -0.4403         0   -0.1888         0    0.0206 ...
         0         0         0         0         0 ...
   -6.2221         0   -3.3289         0    0.3500]; 

  
lb = -100*ones(size(x0));
lb(1) = t_min;
% lb(2:6) = 
lb(7:11) = zeros(1,5);
lb(17:21) = zeros(1,5);
ub =  100*ones(size(x0));
ub(1) = t_max;
ub(7:11) = zeros(1,5);
ub(17:21) = zeros(1,5);

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

%%
    function [c,ceq] = mycon(x)

    a = reshape(x(2:end),[n_outputs,length(x(2:end))/n_outputs]);
    t_final = x(1);
    time = linspace(0,t_final,num_node);

    
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
        
        spatulaedge_z_i =  z_i - spatula_depth*sin(theta_y_i);
        spatulaedge_z_f =  z_f - spatula_depth*sin(theta_y_f);
        
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


          c = [c ; -x;  -z; -xdot; zdot; abs(xdot) - 20; abs(zdot) - 20];
          
          
        % acceleration constraints are satisfied for 80% of the trajectory
          if i< 0.8 * length(time)  
              %acceleration
%             a_x = poly_double_derivative(t,a(1,:));
%             a_y = poly_double_derivative(t,a(2,:));
%             a_z = poly_double_derivative(t,a(3,:));
          
            c = [c; 
%                  -(a_z*sin(theta_y)-a_x*cos(theta_y)+g*sin(theta_y)) ...
%                 + mu* (a_x*sin(theta_y) + a_z*cos(theta_y) + g*cos(theta_y));
                %                     spatulaedge_z - 0.20;
                ];
          
          end
                  %% equality constraints
            ceq = [ceq;
                    y;
                    spatulaedge_z;
                    theta_x;
                    ];
                                    
        end

        
        %% inequality terminal constraints
%         c  = [ c;
%                 
%              ];
         
        
        %% equality terminal constraints
        
        ceq = [ceq;
                theta_y_i - 0.35; % initial pitch angle
                theta_y_f - 0.02;         % final pitch angle
%                 thetadot_y_i;     % intitial pitch velocity
                x_i;
                x_f - 0.15;
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
        f=t_final^2;
            
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

