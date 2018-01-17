classdef AtlasModel < RobotLinks
    
   properties
       RefPoints
       
   end
   
   methods
       
       function obj = AtlasModel(urdf_file, base, load_path)
            % class constructor function
            
            
            if nargin < 2
                load_path = [];
            end
            
            
            
            %% customized the URDF
            % load model from the URDF file
            % normally we only need to provides the URDF file name.
            % However, exo has some fixed joints as reference point only
            % so, we read it here and remove these joints and provides the
            % updated structure instead
            % In the future, we will add features to RobotLinks to
            % dynamically add/remove joints and links
            
            [name, links, joints, transmissions] = ros_load_urdf(urdf_file);
            
            %             % find fixed joints
            %             fixed_joints = arrayfun(@(x)strcmp(x.Type,'fixed'),joints);
            %             % right/left toe joints
            %             right_toe = arrayfun(@(x)strcmp(x.Name,'RightToeJoint'),joints);
            %             left_toe = arrayfun(@(x)strcmp(x.Name,'LeftToeJoint'),joints);
            %             % store these reference joints to custom properties
            %             ref_joint_indices = find(fixed_joints + right_toe + left_toe);
            %             ref_points = joints(ref_joint_indices);
            
            %             % remove unused joints
            %             joints(ref_joint_indices) = [];
            
            % re-arrange the joint orders
            all_joint_names = {joints.Name};            
            nj = numel(joints);    
            indices = zeros(nj,1);
            joint_names = {
                'back_bkz'
                'back_bky'
                'back_bkx'
                'l_leg_hpz'
                'l_leg_hpx'
                'l_leg_hpy'
                'l_leg_kny'
                'l_leg_aky'
                'l_leg_akx'
                'r_leg_hpz'
                'r_leg_hpx'
                'r_leg_hpy'
                'r_leg_kny'
                'r_leg_aky'
                'r_leg_akx'
                };
            for i=1:nj
                index = str_index(all_joint_names,joint_names{i});
                if isempty(index)
                    warning('the joint %s not exists.', joint_names{i});
                    indices(i) = NaN;
                else
                    indices(i) = index;
                end
                
            end
            joints = joints(indices);
            % remove toe links
            %             right_toe_link = arrayfun(@(x)strcmp(x.Name,'RightToeLink'),links);
            %             left_toe_link = arrayfun(@(x)strcmp(x.Name,'LeftToeLink'),links);
            %             links(right_toe_link) = [];
            %             links(left_toe_link)  = [];
            % FROST does not support special character in the name string
            %             name = strrep(name,'-','_');
            
            % call superclass constructor with custom configuration model
            config.name = name;
            
            %% hack the torque limit for Omar Harib!!!!
            %             if ~isempty(strfind(urdf_file,'omar'))
            %                 torque_limits = 1.0*[   350    67   180   219   350   117   117   219   219   219   180    67].';
            %
            %                 for i=1:numel(joints)
            %                     joints(i).Limit.effort = torque_limits(i);
            %                 end
            %             end
            
            %%
            config.joints = joints;
            config.links = links;
            config.transmissions = transmissions;
            
            
            obj = obj@RobotLinks(config, base, load_path);
            
            
            % create coordinate frame objects for reference points
            
            %             for i=1:length(ref_points)
            %                 p = ref_points(i);
            %                 parent = obj.Links(getLinkIndices(obj, p.Parent));
            %                 obj.RefPoints.(p.Name) = CoordinateFrame(...
            %                     'Name',p.Name,...
            %                     'Reference',parent.Reference,...
            %                     'Offset',p.Offset,...
            %                     'R',p.R...
            %                     );
            %             end
       end
           
   end
    
end