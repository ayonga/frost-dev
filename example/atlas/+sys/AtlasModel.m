classdef AtlasModel < RobotLinks
    
   
   
   methods
       
       function obj = AtlasModel(urdf_file, base, load_path)
            % class constructor function
            
            
            if nargin < 2
                load_path = [];
            end
            
            
            
            %% customized the URDF
            
            [name, links, joints, transmissions] = load_urdf(urdf_file);
            
           
            
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
            
            
            config.name = name;
            
            
            %%
            config.joints = joints;
            config.links = links;
            config.transmissions = transmissions;
            
            % call superclass constructor with custom configuration model
            obj = obj@RobotLinks(config, base, 'LoadPath',load_path,...
                'RemoveFixedJoints',true);
            
            
       end
           
   end
    
end