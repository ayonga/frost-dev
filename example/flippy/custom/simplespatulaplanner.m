function result = simplespatulaplanner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% some specifications
num_node = 30;    % number of nodes
mu = 0.33; % coefficient of restitution
g = 9.8; % gravity
wrist3joint_length = 0.09465;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% initial guess

x0 = [  0.43 0.1113    1.7876  -23.2287   0.0000 -0.2284   -3.6694  ...
      49.9838  0.0000  0.1229    1.9758  -23.2094   0.0000 -0.0058  ...
      -0.0941   -0.4041  0.0000 0.0000  -0.0000   -0.0000   -0.0000];
  
% x0 = [  0.43  8.0710    4.7656   17.6843 0.0000  -4.8033   -3.8895  ...
%       19.9283  0.0000  -1.2500    0.1952   19.9472  0.0000  0.8169   ...
%       0.3390  -10.8831  0.0000 0.0000 -0.0000   -0.0000   -0.0000 ];
    
% x0 = [ 0.43  -2.1324    9.8200   32.9460   0.0000  3.0237   -7.5801 ...
%       35.1640   0.0000   -1.4176     0.9095   23.6561    -0.0000 ...
%       0.2200    0.2995   -11.9874    0.0000 ...
%       -0.0000    0.0000    0.0000    0.0000];

  x0 = [0.5502      -3.4254    5.5150   -2.9595    0.5293   -0.0000...
   34.1993  -38.1053   11.0640   -0.1926    0.0000 ...
   39.7554   39.8863  -28.7704    3.3420   -0.0000...
    0.1248    0.1533    0.1777   -0.0563    0.2518];

  % This is the solution for slipping constrants in two directions
% x0 = [ 0.43  -0.9835    2.0686   -1.2335    0.2261    0.0000 ...
%    10.9722   -8.6742    1.2113    0.2804    0.0000 ...
%    37.0471   37.0491   21.0005  -11.5201   -0.0000 ...
%    -0.1784   -0.0302    0.0319    0.0669   -1.3290 ];
  
lb = -40*ones(size(x0));
lb(1) = 0.33;
ub =  40*ones(size(x0));
ub(1) = 0.63;

%% run this optimization
options = optimset('MaxFunEvals',10000);
tic
result = fmincon(@objective,x0,[],[],[],[],lb,ub,@mycon,options);
toc

%%  plot this shit
burger_y = [];
burger_z = [];
burger_theta_x = [];
burger_theta_y = [];
burger_ydot = [];
burger_zdot = [];
burger_theta_xdot = [];
burger_theta_ydot = [];

ae = reshape(result(2:end),[4,5]);
t_final = result(1);
timestamps = 0:0.01:t_final;
for j=1:length(timestamps)
    ti = timestamps(j);
    burger_y = [burger_y , poly(ti,ae(1,:))];
    burger_z = [burger_z , poly(ti,ae(2,:))];
    burger_theta_x = [burger_theta_x , poly(ti,ae(3,:))];
    burger_theta_y = [burger_theta_y , poly(ti,ae(4,:))];
    burger_ydot = [burger_ydot , poly_derivative(ti,ae(1,:))];
    burger_zdot = [burger_zdot , poly_derivative(ti,ae(2,:))];
    burger_theta_xdot = [burger_theta_xdot , poly_derivative(ti,ae(3,:))];
	burger_theta_ydot = [burger_theta_ydot , poly_derivative(ti,ae(4,:))];
end
figure(1000);
% plot(timestamps,burger_x);
% plot(timestamps,burger_y,timestamps,burger_z,timestamps,burger_theta_x);

subplot(2,3,1);
plot(timestamps,burger_y,timestamps,burger_z);
legend('y','z');

subplot(2,3,2);
plot(timestamps,burger_theta_x);
legend('theta_x');

subplot(2,3,4);
plot(timestamps,burger_ydot,timestamps,burger_zdot);
legend('ydot','zdot');

subplot(2,3,5);
plot(timestamps,burger_theta_xdot);
legend('theta_x dot');

subplot(1,3,3);
plot(burger_y,burger_z,'linewidth',2);
axis equal

%%
    function [c,ceq] = mycon(x)

    a = reshape(x(2:end),[4,length(x(2:end))/4]);
    t_final = x(1);
    time = linspace(0,t_final,num_node);

    
    c = [];
    ceq = [];

%% inequality constraints

        for i=1:length(time)
            t = time(i);
            
            %position
            y = poly(t,a(1,:));
            z = poly(t,a(2,:));
            theta_x = poly(t,a(3,:));
%             theta_y = poly(t,a(4,:));
            
            % velocity
            ydot = poly_derivative(t,a(1,:));
            zdot = poly_derivative(t,a(2,:));
            theta_xdot = poly_derivative(t,a(3,:));
                        
            
          c = [c ; -y;  - z; theta_x - pi; - theta_x;  abs(ydot) - 20; abs(zdot) - 20];
          
          
        % acceleration constraints are satisfied for 80% of the trajectory
          if i< 0.80 * length(time)  
              %acceleration
            a_y = poly_double_derivative(t,a(1,:));
            a_z = poly_double_derivative(t,a(2,:));
            a_x = 0;
          
            c = [c; 
                a_z*sin(theta_x)-a_y*cos(theta_x)+g*sin(theta_x) ...
                - mu* (a_y*sin(theta_x) + a_z*cos(theta_x) + g*cos(theta_x));
%                 a_z*sin(theta_y)-a_x*cos(theta_y)+g*sin(theta_y) ...
%                 - mu* (a_x*sin(theta_y) + a_z*cos(theta_y) + g*cos(theta_y));
%                 abs(theta_xdot) - 20;
%                 abs(a_y) - 30;
%                 abs(a_z) - 30;
%                 abs(theta_x) - 30
                ];
          
          end
                                    
        end
        
        
        c = [c; 
%              abs(poly_derivative(t,a(3,:))) - 15 ;
%              0.03 - poly(time(end)/2,a(2,:))
%             abs(ydot) - 0.05
              abs(poly_derivative(0.8*time(end),a(1,:))) - 0.05
               ];
        
        
        %% equality constraints
        ceq = [ceq;
               poly(time(end),a(1,:));
               0.03 - poly(time(end),a(2,:));
               poly(time(end),a(3,:)) - pi;
               poly(time(1),a(1,:));
               poly(time(1),a(2,:));
               poly(time(1),a(3,:))];
      
        % to have a zero impact at touch down -- comment this if
        % acceleration needs to be maintained till the end
           ceq = [ ceq; 
                  poly_derivative(time(end),a(1,:));
                  poly_derivative(time(end),a(2,:))  ];
                  
           
    end

    function f = objective(x)
      
        % calculating arc_length
        a = reshape(x(2:end),[4,length(x(2:end))/4]);
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

