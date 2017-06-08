function result = simplespatulaplanner2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% some specifications
num_node = 40;    % number of nodes
mu = 0.5; % coefficient of friction
g = 9.8; % gravity
t_final = 0.18; %original: 0.4     working slip: 0.18,.19
wrist3joint_length = 0.09465;
y_pos_final = 0.025; % added final y position     working (sort of) slip: 0.02

W = .07; % width of spatula in meters 
L = 0.12; % length of spatula in meters

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

ae = reshape(result,[4,5]);
timestamps = 0:0.01:t_final;

for j=1:length(timestamps)
    ti = timestamps(j);
%     burger_x = [burger_x, poly(ti,ae(???)]
    burger_y = [burger_y , poly(ti,ae(1,:))];
    burger_z = [burger_z , poly(ti,ae(2,:))];
    burger_theta_x = [burger_theta_x , poly(ti,ae(3,:))];
    burger_theta_y = [burger_theta_y , poly(ti,ae(4,:))];
    burger_ydot = [burger_ydot , poly_derivative(ti,ae(1,:))];
    burger_zdot = [burger_zdot , poly_derivative(ti,ae(2,:))];
    burger_theta_xdot = [burger_theta_xdot , poly_derivative(ti,ae(3,:))];
	burger_theta_ydot = [burger_theta_ydot , poly_derivative(ti,ae(4,:))];
end

% creating spatula vertices
q_r_x = zeros(size(burger_y)); % x-coord of right edge point
q_r_y = burger_y + 0.5*W.*cos(burger_theta_x); % y-coord of right edge point 
q_r_z = burger_z + 0.5*W.*sin(burger_theta_x); % z-coord of right edge point
q_r = [q_r_y, q_r_z]; % right edge point of spatula 

q_l_x = zeros(size(burger_y)); % x-coord of left edge point
q_l_y = burger_y - 0.5*W.*cos(burger_theta_x);  % y-coord of left edge point
q_l_z = burger_z - 0.5*W.*sin(burger_theta_x);   % z-coord of left edge point
q_l = [q_r_y, q_r_z]; % left edge point of spatula

q_f_x = 0.5*L.*cos(burger_theta_y);   % x-coord of front middle edge point
q_f_y = burger_y; % y-coord of front middle edge point
q_f_z = burger_z - 0.5*L.*sin(burger_theta_y); % z-coord of front middle edge point

q_b_x = -0.5*L.*cos(burger_theta_y); % x-coord of back middle edge point
q_b_y = burger_y; % y-coord of back middle edge point
q_b_z = burger_z - 0.5*L .*sin(burger_theta_y); % z-coord of back middle edge point

q_fr_x = q_r_x  + q_f_x; % x-coord of front right vertex 
q_fr_y = q_r_y + q_f_y; % y-coord of front right vertex
q_fr_z = q_r_z + q_f_z; % z-coord of front right vertex
% q_fr = matrix(q_fr_x, q_fr_y, q_fr_z); % front right vertex

q_br_x = q_r_x  + q_b_x; % x-coord of back right vertex 
q_br_y = q_r_y + q_b_y; % y-coord of back right vertex
q_br_z = q_r_z + q_b_z; % z-coord of back right vertex
% q_br = [q_br_x, q_br_y, q_br_z];  % back right vertex

q_fl_x = q_l_x  + q_f_x; % x-coord of front left vertex 
q_fl_y = q_l_y + q_f_y; % y-coord of front left vertex
q_fl_z = q_l_z + q_f_z; % z-coord of front left vertex
% q_fl = [q_fl_x, q_fl_y, q_fl_z]; % front left vertex

q_bl_x = q_l_x  + q_b_x; % x-coord of back left vertex 
q_bl_y = q_l_y + q_b_y; % y-coord of back left vertex
q_bl_z = q_l_z + q_b_z; % z-coord of back left vertex
% q_bl = [q_bl_x, q_bl_y, q_bl_z]; % back left vertex

% disp('dist between q_r and q_l')
% disp(sqrt((q_r_y - q_l_y).^2 + (q_r_z - q_l_z).^2))

figure(1000);
% plot(timestamps,burger_x);
% plot(timestamps,burger_y,timestamps,burger_z,timestamps,burger_theta_x);

subplot(2,3,1);
plot(timestamps,burger_y,timestamps,burger_z);
xlabel('time [sec]');
ylabel('y and z positions of spatula center [m]')
legend('y','z');

subplot(2,3,2);
plot(timestamps,burger_theta_x, timestamps, burger_theta_y);
xlabel('time [sec]');
ylabel('theta_x and theta_y');
legend('theta_x','theta_y');

subplot(2,3,4);
plot(timestamps,burger_ydot,timestamps,burger_zdot);
xlabel('time [sec]');
ylabel('ydot and zdot [m/s]');
legend('ydot','zdot');

subplot(2,3,5);
plot(timestamps,burger_theta_xdot,timestamps,burger_theta_ydot);
xlabel('time [sec]');
ylabel('theta_x dot and theta_y dot [rad/sec]')
legend('theta_x dot','theta_y dot');

subplot(1,3,3);
plot(burger_y,burger_z,'linewidth',2,'color','k');
xlabel('burger_y [m]');
ylabel('burger_z [m]');
title('z,y phase space of spatula trajectory');
axis equal
hold on 
plot(q_r_y, q_r_z, 'LineWidth', 2, 'color', 'm');  % position of left center edge point
plot(q_l_y, q_l_z, 'LineWidth', 2, 'color', 'c');    % position of right center edge point
hold off

figure(3);
clf();
% plot3(zeros(length(burger_y)), burger_y, burger_z, 'linewidth',2, 'color', 'k');

xlabel('x pos');
ylabel('y pos');
zlabel('z pos');

grid on
hold on 

% plotting the four corner vertices 
plot3(q_bl_x, q_bl_y, q_bl_z, 'linewidth', 0.5, 'color', 'k');
plot3(q_fl_x, q_fl_y, q_fl_z, 'linewidth', 0.5, 'color', 'k');
plot3(q_fr_x, q_fr_y, q_fr_z,'linewidth', 0.5, 'color', 'k');
plot3(q_br_x, q_br_y, q_br_z, 'linewidth', 0.5, 'color', 'k');

% plot3(zeros(length(burger_y)), q_r_y, q_r_z, 'LineWidth', 2, 'color', 'm'); % right edge point in magenta
% plot3(zeros(length(burger_y)), q_l_y, q_l_z, 'LineWidth', 2, 'color', 'c'); % left edge point in cyan
% plot3(q_f_x, q_f_y, q_f_z, 'LineWidth', 2, 'color', 'r'); % front middle edge point in red
% plot3(q_b_x, q_b_y, q_b_z, 'LineWidth', 2, 'color', 'g'); % back middle edge point in green

% xlim([-.05,.05])
% ylim([-.05,.05])
% zlim([0,.25])

% axis equal
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
            q_r_y = y + 0.5*W.*cos(theta_x);
            q_r_z = z + 0.5*W.*sin(theta_x);
            q_l_y = y - 0.5*W.*cos(theta_x);
            q_l_z = z - 0.5*W.*sin(theta_x);
            q_f_z = z + 0.5*L.*sin(theta_y); % z-coord of front middle edge point
            q_fl_z = q_l_z + q_f_z; % z-coord of front left vertex
            q_fr_z = q_r_z + q_f_z; % z-coord of front right vertex
            
            
            % velocity
            ydot = poly_derivative(t,a(1,:));
            zdot = poly_derivative(t,a(2,:));
            theta_xdot = poly_derivative(t,a(3,:));
            theta_ydot = poly_derivative(t,a(4,:));
          
          c = [c ; 
                -y; 
                - z; 
                - q_fr_z;
                - q_fl_z;
%                 -theta_y;
                theta_y - pi/4;
                - theta_ydot;
%                 -theta_x;
%                 theta_x - pi;
                -theta_xdot;            
                y - 0.1;        %original: 0.2   ... working for drop: 0.1
                z - 0.61*W;   % original:0.25   ... working for drop: 0.61*W
                norm([zdot,ydot]) - 5;
%                 q_l_z - 0.01;
%                 q_r_z - 0.08;
%                 q_r_z  - 0.04;
%                 q_r_z - 0.07;
%                 q_l_y - 0.03;
                ];  
            
        % acceleration constraints are satisfied for 80% of the trajectory
          if i< 1.0 * length(time)  
              % acceleration
            a_y = poly_double_derivative(t,a(1,:));
            a_z = poly_double_derivative(t,a(2,:));
            a_theta_x =poly_double_derivative(t,a(3,:));
            a_x = 0;
          
            c = [c; 
                   -1*(a_z*sin(theta_x)+a_y*cos(theta_x)+g*sin(theta_x) ...
                - mu* (-a_y*sin(theta_x) + a_z*cos(theta_x) + g*cos(theta_x)));
               -1*(a_z*sin(theta_y)-a_x*cos(theta_y)+g*sin(theta_y) ...
              - mu* (-a_x*sin(theta_y) + a_z*cos(theta_y) + g*cos(theta_y)));
%                 a_z*sin(theta_x)+a_y*cos(theta_x)+g*sin(theta_x) ...
%                 - mu* (-a_y*sin(theta_x) + a_z*cos(theta_x) + g*cos(theta_x));
%                a_z*sin(theta_y)-a_x*cos(theta_y)+g*sin(theta_y) ...
%               - mu* (-a_x*sin(theta_y) + a_z*cos(theta_y) + g*cos(theta_y));
%                 abs(theta_x) - 20;
                abs(theta_xdot) - 20; %original: 20 ... working for drop: 20
                abs(a_y) - 15; %original: 30... working for drop: 15
                abs(a_z) - 15; %original: 30 ... working for drop: 15
                abs(a_theta_x) - 10;
%                 abs(poly(time(end),a(4,:))) - 0.5*pi;  %original: stops
%                 q_4z - 0.05;  %original: none
%                 q_1z - 0.08;   %original: none
%                 -y;
%                 -z;
                ];
       
          end
                           
        end
        
%          c = [c; 
% %              abs(poly_derivative(t,a(3,:))) - 15 ;
% %              0.03 - poly(time(end)/2,a(2,:))
% %             abs(ydot) - 0.05
%                abs(poly_derivative(0.8*time(end),a(1,:))) - 0.08;
%                 ];
        
        
        %% equality constraints
        ceq = [ceq;
               poly(time(end),a(1,:));    % sort of working for drop: 0.1
               poly(time(end),a(2,:)) - 0.2*W;   %working for drop: 0.5*W
               poly(time(end),a(3,:)) - pi/3;
               poly(time(1),a(1,:));
               poly(time(1),a(2,:));
               poly(time(1),a(3,:))
               poly(time(1),a(4,:));
%                poly(time(end),a(4,:)) - pi/6;
               ];
      
% %         to have a zero impact at touch down -- comment this if
% %         acceleration needs to be maintained till the end
%            ceq = [ ceq; 
%                  poly_derivative(time(end),a(1,:));
%                  poly_derivative(time(end),a(2,:))  ];
%                   
           
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
%%

h = animatedline('Color','r');
% clf('reset');
% h2 = animatedline('Color',[0.5 0.5 0.5]');
x = linspace(0,t_final,length(burger_theta_y));
for i = 1:5
    for k = 1:length(x)
%     addpoints(h,q_f_x(k), q_f_y(k), q_f_z(k));
%     addpoints(h, zeros(size(21)), q_r_y(k), q_r_z(k));
%     addpoints(h,q_b_x(k), q_b_y(k), q_b_z(k));
%     addpoints(h, zeros(size(21)), q_l_y(k), q_l_z(k));
%     addpoints(h,q_f_x(k), q_f_y(k), q_f_z(k));
%     addpoints(h2, q_r_x, q_r_y, q_r_z);
%     addpoints(h2, q_l_x, q_l_y, q_l_z);
        addpoints(h, q_bl_x(k), q_bl_y(k), q_bl_z(k));
        addpoints(h, q_fl_x(k), q_fl_y(k), q_fl_z(k));
        addpoints(h, q_fr_x(k), q_fr_y(k), q_fr_z(k));
        addpoints(h, q_br_x(k), q_br_y(k), q_br_z(k));
        addpoints(h, q_bl_x(k), q_bl_y(k), q_bl_z(k));
%      if mod(k,10)==0
        drawnow
        pause(0.05)
if i < 5
% clearpoints(h)
%         end
     end
    pause(0.05)
end
if i < 5
clearpoints(h)
end
end
% reshape(result,[4,5]);
% csvwrite('/home/william/proj/git/simulation/paramfile.dat', result);
% type paramfile.dat
% r = reshape(result,[4,5]);
% csvwrite('/home/william/proj/git/simulation/paramfile.dat', r);
% disp(r);

% dlmwrite('/home/william/proj/git/simulation/paramfileflip.csv', r,'delimiter',',')

%% save the result in a file
% n_outputs = 5;
% shape = [4,5];
if exist('writecsvfileSP2.m', 'file')
    writecsvfileSP2(t_final, result);
else
    sprintf('Warning: file writecsvfileSP2.m does not exist. Copy and save the following text in file name: writecsvfile.m in subfolder custom \n\n\n function writecsvfile(result,n_output) \n r = reshape(result(2:end),[n_output,n_output]); \n csvwrite(your file name with path,r); \n end')
end
end
