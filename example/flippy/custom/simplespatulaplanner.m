function result = simplespatulaplanner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% some specifications
num_node = 40;    % number of nodes
mu = 0.26; % coefficient of restitution
g = 9.8; % gravity
t_final = 0.43;
wrist3joint_length = 0.09465;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% initial guess

% x0 = [-14.0053  -14.0053    0.2848   -9.1907   -9.1907   ...
%      -0.3845   -1.0825   -1.0825   -1.4906   24.2785   ...
%      24.2785    4.7320    0.0000    0.0000   -0.0000];

% x0 = [  0.1113    1.7876  -23.2287   -0.2284   -3.6694  ...
%       49.9838    0.1229    1.9758  -23.2094   -0.0058  ...
%       -0.0941   -0.4041   -0.0000   -0.0000   -0.0000];
  
% x0 = [    8.0710    4.7656   17.6843   -4.8033   -3.8895  ...
%       19.9283   -1.2500    0.1952   19.9472    0.8169   ...
%       0.3390  -10.8831   -0.0000   -0.0000   -0.0000 ];
  
% x0 = [  11.1073    7.1104   19.4655   -7.7461   -4.5978  ...
%       22.8534   -0.5843   -0.8550   23.5007    0.8403  ...
%       0.7481  -13.6137    0.0000    0.0000   -0.0000 ];
  
x0 = [   -2.1324    9.8200   32.9460    3.0237   -7.5801 ...
      35.1640   -1.4176    0.9095   23.6561    0.2200  ...
      0.2995  -11.9874   -0.0000    0.0000    0.0000];
  
lb = -40*ones(size(x0));
ub =  40*ones(size(x0));

%% run this optimization
tic
result = fmincon(@objective,x0,[],[],[],[],lb,ub,@mycon);
toc

%%  plot this shit
burger_y = [];
burger_z = [];
burger_theta = [];
burger_ydot = [];
burger_zdot = [];
burger_thetadot = [];
ae = reshape(result,[3,5]);
timestamps = 0:0.01:t_final;
for j=1:length(timestamps)
    ti = timestamps(j);
    burger_y = [burger_y , poly(ti,ae(1,:))];
    burger_z = [burger_z , poly(ti,ae(2,:))];
    burger_theta = [burger_theta , poly(ti,ae(3,:))];
    burger_ydot = [burger_ydot , poly_derivative(ti,ae(1,:))];
    burger_zdot = [burger_zdot , poly_derivative(ti,ae(2,:))];
    burger_thetadot = [burger_thetadot , poly_derivative(ti,ae(3,:))];
end
figure(1000);
% plot(timestamps,burger_x);
% plot(timestamps,burger_y,timestamps,burger_z,timestamps,burger_theta);

subplot(2,3,1);
plot(timestamps,burger_y,timestamps,burger_z);
legend('y','z');

subplot(2,3,2);
plot(timestamps,burger_theta);
legend('theta');

subplot(2,3,4);
plot(timestamps,burger_ydot,timestamps,burger_zdot);
legend('ydot','zdot');

subplot(2,3,5);
plot(timestamps,burger_thetadot);
legend('theta dot');

subplot(1,3,3);
plot(burger_y,burger_z,'linewidth',2);
axis equal

%%
    function [c,ceq] = mycon(x)

    time = linspace(0,t_final,num_node);

    a = reshape(x,[3,length(x)/3]);
    c = [];
    ceq = [];

%     ceq = [];
%% inequality constraints

        for i=1:length(time)
            t = time(i);
            
            %position
            y = poly(t,a(1,:));
            z = poly(t,a(2,:));
            theta = poly(t,a(3,:));
%             wrist2_y = poly(t,a(4,:));
%             wrist2_z = poly(t,a(5,:));
            
            % velocity
            ydot = poly_derivative(t,a(1,:));
            zdot = poly_derivative(t,a(2,:));
%             wrist2dot_y = poly_derivative(t,a(4,:));
%             wrist2dot_z = poly_derivative(t,a(5,:));
            
%             length2to3 = (wrist2_y - y)^2 + (wrist2_z -z)^2;
            
            
          c = [c ; - y; - z; theta - pi; y - 0.2 ; z - 0.25; ydot - 20; zdot - 20];
          
%           ceq = [ ceq];
          
% acceleration constraints are satisfied for 90% of the trajectory
          if i< 0.80 * length(time)  
              %acceleration
            a_y = poly_double_derivative(t,a(1,:));
            a_z = poly_double_derivative(t,a(2,:));
          
            c = [c; a_z*sin(theta)-a_y*cos(theta)+g*sin(theta) ...
                - mu* (a_y*sin(theta) + a_z*cos(theta) + g*cos(theta));
                abs(poly_derivative(t,a(3,:))) - 20;
                abs(a_y) - 10;
                abs(a_z) - 10;
                abs(theta) - 10];
          
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
        a = reshape(x,[3,length(x)/3]);
        time = linspace(0,t_final,num_node);
        f=0;
        y_dot = 0;
        z_dot = 0;
        for i =1:length(time)
            t = time(i);
            y_dot = poly_derivative(t,a(1,:));
%             z_dot = poly_derivative(t,a(2,:));
            
%             f = f + sqrt(1  + y_dot^2) + sqrt(1 + z_dot^2);
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

