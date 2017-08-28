classdef acrobot < RobotLinks
    % create 2D pendulum with N links
    % - all joints are actuated
    % - each link assume to has point mass at the center (no inertia)
    % - each link has length of 0.5m and mass of 5kg
    
    properties
        
        
    end
    
    methods
        function obj = acrobot()
            
            
            base = get_base_dofs('fixed');
            
            config = struct();
            config.name = ['acrobot'];
            
            foot_link = struct(...
                'Name','foot',...
                'Mass',0.4,...
                'Inertia',diag([0,0.1,0]),...
                'Offset',[-0.12,0,0],...
                'R',[0,0,0]);
            
            shin_link = struct(...
                'Name','shin',...
                'Mass',6.4,...
                'Inertia',diag([0,0.4,0]),...
                'Offset',[0,0,0.16],...
                'R',[0,0,0]);
            
            thigh_link = struct(...
                'Name','thigh',...
                'Mass',13.6,...
                'Inertia',diag([0,0.94,0]),...
                'Offset',[0,0,0.29],...
                'R',[0,0,0]);
            
            torso_link = struct(...
                'Name','torso',...
                'Mass',12,...
                'Inertia',diag([0,1.33,0]),...
                'Offset',[0,0,0.24],...
                'R',[0,0,0]);
            
            
            config.links = [foot_link,...
                shin_link,...
                thigh_link,...
                torso_link];
            
            ankle_limit = struct('effort',100,...
                'lower',deg2rad(-50),...
                'upper',deg2rad(50),...
                'velocity',3.14);
            
            ankle_joint = struct('Name','ankle',...
                'Type','revolute',...
                'Offset',[-0.15,0,0],...
                'Parent','foot',...
                'R',[0,0,0],...
                'Axis',[0,-1,0],...
                'Child','shin',...
                'Limit',ankle_limit...
                );
            
            knee_limit = struct('effort',100,...
                'lower',0,...
                'upper',deg2rad(150),...
                'velocity',4.2);
            knee_joint = struct('Name','knee',...
                'Type','revolute',...
                'Offset',[0,0,0.4],...
                'Parent','shin',...
                'R',[0,0,0],...
                'Axis',[0,-1,0],...
                'Child','thigh',...
                'Limit',knee_limit...
                );
            
            hip_limit = struct('effort',100,...
                'lower',deg2rad(-150),...
                'upper',deg2rad(15),...
                'velocity',5);
            hip_joint = struct('Name','hip',...
                'Type','revolute',...
                'Offset',[0,0,0.4],...
                'Parent','thigh',...
                'R',[0,0,0],...
                'Axis',[0,-1,0],...
                'Child','torso',...
                'Limit',hip_limit...
                );
            
            config.joints = [ankle_joint,...
                knee_joint,...
                hip_joint];
            
            transmissions(3) = struct;
            for i=1:3
                transmissions(i).Joint = config.joints(i).Name;
                transmissions(i).MechanicalReduction = 1;
                transmissions(i).Inertia = 0;
            end
            config.transmissions = transmissions;
            
            obj = obj@RobotLinks(config,base);
            
        end
        
    end
    
end

