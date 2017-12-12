%%  translate burger behavior is provided here
% goto_joints 0.44734 0.19477 -1.00479 0.60115 0.72393 0.16223
x_pos = 0.0:0.02:0.4;
y_pos = 0.5:0.02:0.8;
% for i=1:numel(x_pos)
%     for j=1:numel(y_pos)
%         initial.position = [x_pos(i) y_pos(j) 0.25];
%         initial.orientation = [0,0,pi/2];
%         final.position = [0.6 -0.1 0.25];
%         final.orientation = [0,0,0];
%         translate_burger_behavior(flippy,cur,initial, final);
%     end
% end
% 
% 
% yd_pos_LR(2.4502,reshape(alpha,42,1))

corners = getGrillAndTableCorners();

initial.position = corners.grill.far_left;
% home = [0.55,0.14,0.25]
final.position = corners.grill.near_right;
burger.position = [0.68 -0.30 0.086];
drop.position = [0 0.75 0.115];

initial.orientation = [0 0 pi/2];
final.orientation = [0 0 pi/2];
burger.orientation = [0 0 0];
drop.orientation = [0 0 pi/2];

% Behavior_mama = translate_burger_behavior(flippy, cur, initial, final);
Behavior_mama = pickup_and_flip_burger_behavior(flippy, cur, burger);
% Behavior_mama = pickup_and_drop_burger_behavior(flippy, cur, burger, drop);

%% Data
q = zeros(1,6);
pose_pos_1 = [endeffx_sca_LR(q),endeffy_sca_LR(q),endeffz_sca_LR(q)];
pose_ori_1 = [o_endeffx_LR(q),o_endeffy_LR(q),o_endeffz_LR(q)];
% from ros
pose_pos_ros_1 = [0.764,0,0.817];
pose_ori_ros_q_1 = [-0.19268,-0.25422,0.05150,0.94636];

% %% Data
% q(1) = pi/2;
% pose_pos = [endeffx_sca_LR(q),endeffy_sca_LR(q),endeffy_sca_LR(q)]
% pose_ori = [o_endeffx_LR(q),o_endeffy_LR(q),o_endeffz_LR(q)]

%% Data
q =  [1.9443,    0.3849,   -0.5388,    0.7538,    0.4321,    0.0953];
pose_pos_2 = [endeffx_sca_LR(q),endeffy_sca_LR(q),endeffz_sca_LR(q)];
pose_ori_2 = [o_endeffx_LR(q),o_endeffy_LR(q),o_endeffz_LR(q)];

pose_pos_ros_2 = [-0.186,0.716,0.277];
pose_ori_ros_q_2 = [0.04454,0.07948,0.67476,0.73240];

%% checking the collision constraints

for i=1:6
    for j=1:2
        v = matlab.lang.makeValidName(['CollisionJointtoLineSca_',num2str(i),num2str(j), 'LR']);
        value  = eval([v,'([',num2str(x'),'])']);
        if value < 0
            error('Failed')
        end
%         CollisionJointtoLineSca_21LR(x)
    end
end

for i=1:4
    for j=1:6
        v = matlab.lang.makeValidName(['CollisionLinetoJointSca_',num2str(i),num2str(j), 'LR']);
        eval([v,'([',num2str(x'),'])']);
%         CollisionJointtoLineSca_21LR(x)
        if value < 0
            error('Failed')
        end
    end
end


%% functions given here

function ret = rot(ox,oy,oz)
     ret = rz (oz) * ry (oy) * rx (ox) ; 
end


function ret = rx (ox)
      ret = [1, 0, 0; 
           0, cos(ox), -sin(ox);
           0, sin(ox),  cos(ox)];
end

function ret = ry (oy)
      ret = [ cos(oy), 0, sin(oy);
                 0,  1,      0;
           -sin(oy), 0, cos(oy)];
end

function ret = rz (oz)
      ret = [  cos(oz), -sin(oz), 0;
            sin(oz),  cos(oz), 0;
                  0,        0,  1];
end


%%


