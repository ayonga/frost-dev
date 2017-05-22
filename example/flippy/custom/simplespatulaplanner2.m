function result = simplespatulaplanner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% some specifications
num_node = 40;    % number of nodes
mu = 0.8; % coefficient of restitution
g = 9.8; % gravity
t_final = 0.43;
wrist3joint_length = 0.09465;
y_pos_final = 0.02; % added final y position

W = .07; % width of spatula in meters 
L = 0.09; % length of spatula in meters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% initial guess

% x0 = [  0.1113    1.7876  -23.2287   0.0000 -0.2284   -3.6694  ...
%       49.9838  0.0000  0.1229    1.9758  -23.2094   0.0000 -0.0058  ...
%       -0.0941   -0.4041  0.0000 0.0000  -0.0000   -0.0000   -0.0000];
  
% x0 = [    8.0710    4.7656   17.6843 0.0000  -4.8033   -3.8895  ...
%       19.9283  0.0000  -1.2500    0.1952   19.9472  0.0000  0.8169   ...
%       0.3390  -10.8831  0.0000 0.0000 -0.0000   -0.0000   -0.0000 ];
    
x0 = [   -2.1324    9.8200   32.9460   0.0000  3.0237   -7.5801 ...
      35.1640   0.0000   -1.4176     0.9095   23.6561    -0.0000 ...
      0.2200    0.2995   -11.9874    0.0000 ...
      -0.0000    0.0000    0.0000    0.0000];

  % This is the solution for slipping constrants in two directions
% x0 = [   -0.9835    2.0686   -1.2335    0.2261    0.0000 ...
%    10.9722   -8.6742    1.2113    0.2804    0.0000 ...
%    37.0471   37.0491   21.0005  -11.5201   -0.0000 ...
%    -0.1784   -0.0302    0.0319    0.0669   -1.3290 ];
  
lb = -40*ones(size(x0));
ub =  40*ones(size(x0));

%% run this optimization
options = optimset('MaxFunEvals',1000000);
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

ae = reshape(result,[4,5]);
timestamps = 0:0.01:t_final;
for j=1:length(timestamps)
    ti = timestamps(j);
    burger_y = [burger_y , poly(ti,ae(1,:))];
    burger_z = [burger_z , poly(ti,ae(2,:))];
    %spatula_right = (burger_y).*(cos(burger_theta_x)) + (burger_z).*(sin(burger_theta_x))
    burger_theta_x = [burger_theta_x , poly(ti,ae(3,:))];
    burger_theta_y = [burger_theta_y , poly(ti,ae(4,:))];
    burger_ydot = [burger_ydot , poly_derivative(ti,ae(1,:))];
    burger_zdot = [burger_zdot , poly_derivative(ti,ae(2,:))];
    burger_theta_xdot = [burger_theta_xdot , poly_derivative(ti,ae(3,:))];
	burger_theta_ydot = [burger_theta_ydot , poly_derivative(ti,ae(4,:))];
end

% creating spatula vertices (in 2D, yz-plane)
q_1y = burger_y + 0.5*W.*cos(burger_theta_x);% y-coordinate of spatula vertex q_1
%q_1y = q_1y/norm(q_1y,2); %normalize
q_1z = burger_z + 0.5*W.*sin(burger_theta_x);   % z-coordinate of spatula vertex q_1
%q_1z = q_1z/norm(q_1z,2); %normalize
q_1 = [q_1y, q_1z];
%q_2 = 
%q_3 =
q_4y = burger_y - 0.5*W.*cos(burger_theta_x);  % y-coordinate of spatula vertex q_4
%q_4y = q_4y/norm(q_4y,2); %normalize
q_4z = burger_z - 0.5*W.*sin(burger_theta_x);   % z-coordinate of spatula vertex q_4
%q_4z = q_4z/norm(q_4z,2); %normalize
q_4 = [q_1y, q_1z]; 

%disp('dist between q_1 and q_4')
%disp(sqrt((q_1y - q_4y).^2 + (q_1z - q_4z).^2))

figure(1000);
% plot(timestamps,burger_x);
% plot(timestamps,burger_y,timestamps,burger_z,timestamps,burger_theta_x);

subplot(2,3,1);
plot(timestamps,burger_y,timestamps,burger_z);
xlabel('time [sec]');
ylabel('y and z positions of spatula center [m]')
legend('y','z');

subplot(2,3,2);
plot(timestamps,burger_theta_x);
xlabel('time [sec]');
ylabel('theta_x = roll [rad]');
legend('theta_x');

subplot(2,3,4);
plot(timestamps,burger_ydot,timestamps,burger_zdot);
xlabel('time [sec]');
ylabel('ydot and zdot [m/s]');
legend('ydot','zdot');

subplot(2,3,5);
plot(timestamps,burger_theta_xdot);
xlabel('time [sec]');
ylabel('theta_x dot [rad/sec]')
legend('theta_x dot');

subplot(1,3,3);
plot(burger_y,burger_z,'linewidth',2,'color','k');
xlabel('burger_y [m]');
ylabel('burger_z [m]');
title('z,y phase space of spatula trajectory');
%axis equal
hold on 
plot(q_1y,q_1z,'LineWidth',2, 'color', 'm');  % position of near-left vertex
plot(q_4y, q_4z,'LineWidth',2,'color','c');    % position of near-right vertex
hold off

figure(2);
plot3(zeros(length(burger_y)),burger_y,burger_z, 'linewidth',2,'color','k');
xlabel('x pos');
ylabel('y pos');
zlabel('z pos');
grid on
hold on 


plot3(zeros(length(burger_y)), q_1y, q_1z, 'LineWidth', 2,'color','m');
plot3(zeros(length(burger_y)), q_4y, q_4z, 'LineWidth', 2, 'color', 'c');

%{
h = animatedline(ones(length(burger_y)), burger_y, burger_z);
for k = 0:t_final
    addpoints(h,burger_y,burger_z)
    draw now
    wait 1.0
end
th = [burger_theta_x, burger_theta_y, burger_theta_z];
s = (SPATULA_WIDTH/2).*[cos(th[1]), sin(th[1])];
X = x[1].*ones((2)) + array([s[0], -s[0]]);
Y = x[2].*ones((2)) + array([s[1], -s[1]]);
plot3(X, Y,timesteps);
%}

hold off

%%
    function [c,ceq] = mycon(x)

    time = linspace(0,t_final,num_node);

    a = reshape(x,[4,length(x)/4]);
    c = [];
    ceq = [];

%% inequality constraints
  
        for i=1:length(time)
            t = time(i);
            
            %position
            y = poly(t,a(1,:));
            z = poly(t,a(2,:));
            theta_x = poly(t,a(3,:));
            theta_y = poly(t,a(4,:));
            q_1y = y + 0.5*W.*cos(theta_x);
            q_1z = z + 0.5*W.*sin(theta_x);
            q_4y = y - 0.5*W.*cos(theta_x);
            q_4z = z - 0.5*W.*sin(theta_x);
            
            
            % velocity
            ydot = poly_derivative(t,a(1,:));
            zdot = poly_derivative(t,a(2,:));
            theta_xdot = poly_derivative(t,a(3,:));
            
          
          c = [c ; 
                %-y; 
                -z; 
                theta_x - pi; 
                y - 0.2; 
                z - 0.25; 
                norm([zdot,ydot])-4];  
         
          
        % acceleration constraints are satisfied for 80% of the trajectory
          if i< 0.80 * length(time)  
              %acceleration
            a_y = poly_double_derivative(t,a(1,:));
            a_z = poly_double_derivative(t,a(2,:));
            a_x = 0;
          
            c = [c; 
                a_z*sin(theta_x)-a_y*cos(theta_x)+g*sin(theta_x) ...
                - mu* (a_y*sin(theta_x) + a_z*cos(theta_x) + g*cos(theta_x));
                a_z*sin(theta_y)-a_x*cos(theta_y)+g*sin(theta_y) ...
                - mu* (a_x*sin(theta_y) + a_z*cos(theta_y) + g*cos(theta_y));
                abs(poly_derivative(t,a(3,:))) - 20;
                abs(theta_xdot)-20;           
                abs(a_y) - 10;
                abs(a_z) - 10;
                abs(poly(time(end),a(4,:))) - 0.5*pi];
               
            
          
          end
          
                                    
        end
        
        
        c = [c; 
%              abs(poly_derivative(t,a(3,:))) - 15 ;
%              0.03 - poly(time(end)/2,a(2,:))
%             abs(ydot) - 0.05
              abs(poly_derivative(0.8*time(end),a(1,:))) - 0.05             % ?????
               ];
        
        
        %% equality constraints
        ceq = [ceq;
               poly(time(end),a(1,:));
               poly(time(end),a(2,:));
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
        a = reshape(x,[4,length(x)/4]);
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

%{
%% 2d dynamic spatula
spatula = [-0.5*W.*cos(burger_theta_x), 0.5*W.*sin(burger_theta_x);zeros(length(burger_y)), zeros(length(burger_y))];


xmin = -10;
xmax =105;
ymin = -10;
ymax = 10;
%axis equal
axis([xmin xmax ymin ymax])
hold on


N = 44;
t = linspace(0,t_final,N); 
trajectory = [burger_y,burger_z];
scale = linspace(1,t_final,N);
for i = 1:N
    % object moving along projectile
    h = fill(spatula(1,:) + t(i),spatula(2,:) + trajectory(i),'r');
    hold on;
    % scales the figure from 100% to 25%
    fill(scale(i)*spatula(1,:) + t(i), scale(i)*spatula(2,:) + trajectory(i), 'r');
    hold off;
    pause(0.3)
end
%}

end