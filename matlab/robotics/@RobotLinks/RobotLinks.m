classdef RobotLinks < ContinuousDynamics
    % A class with basic model descriptions and functionalities
    % of the multi-link rigid-body robot platform.
    %
    % References:
    % The descriptions of rigid body model is based on but not limited to
    % the following resrouces
    % - Richard Murray, Zexiang Li, and Shankar Sastry. "A Mathematical Introduction to Robotic
    % Manipulation". 1994, CRC Press. http://www.cds.caltech.edu/~murray/mlswiki.
    % - Roy Featherstones. "Rigid Body Dynamics Algorithm". Springer, 2008.
    % http://royfeatherstone.org/spatial/
    %
    % @author Ayonga Hereid @date 2021-12-20
    %
    %
    % Copyright (c) 2022, Cyberbotics Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    %
    
    
    
    
    %% Constant properties
    properties (Constant, Hidden)
        g = [0;0;9.81]
    end
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        
              
        
        % The full path of the model configuration file
        %
        % @type char
        ConfigFile
        
        % An array of rigid links
        %
        % @type RigidBody
        Links
        
        % An array of rigid joints
        %
        % @type RigidJoint
        Joints
        
       
       
    end
    
    properties (Hidden,SetAccess=protected, GetAccess=public)
        BaseJoints
        
        %         Amat
    end
    
    
    
    
    %% Public methods
    methods
        
        
        function obj = RobotLinks(config, base, options)
            % The class constructor function
            %
            %
            % Parameters:
            % config: the configuration of the joints and links @type char           
            % base: the configuration of the floating base
            % coordinates  @type struct
            %
            % Return values:
            % obj: an object of this class
            
            arguments
                config
                base = []
                options.RemoveFixedJoints logical = true
                options.LoadPath = []
                options.RoundNumber double {mustBeInteger, mustBeNonnegative} = 6
            end
            
                        
            
            
            
            config_file = [];
            if ischar(config) % configuration file name
                % parse the model configuration file
                [folder_name,file_name,file_ext] = fileparts(config);
                
                % check file type
                if isempty(file_ext) || strcmp(file_ext,'.urdf')
                    file_ext = '.urdf'; % default file type is URDF
                    config_file = GetFullPath(fullfile(folder_name, [file_name,file_ext]));
                                        
                    % load model from the URDF file
                    [name, links, joints, ~] = load_urdf(config_file,options.RoundNumber);
                    
                else
                    error('Invalid configuration file type detected: %s.\n',file_ext(2:end));
                end
                
                
            elseif isstruct(config)
                name = config.name;
                
                fields = {'Name','Mass','P','R','Inertia'};
                assert(all(isfield(config.links,fields)),...
                    'The links structure must have the following fields:\n %s',implode(fields,', '));
                links = config.links;
                
                fields = {'Name','Type','P','R','Axis','Parent','Child','Limit','Actuator'};
                assert(all(isfield(config.joints,fields)),...
                    'The joints structure must have the following fields:\n %s',implode(fields,', '));
                joints = config.joints;
                
                %                 if isfield(config,'transmissions')
                %                     fields = {'Joint','MechanicalReduction'};
                %                     assert(all(isfield(config.transmissions,fields)),...
                %                         'The transmissions structure must have the following fields:\n %s',implode(fields,', '));
                %                     transmissions = config.transmissions;
                %                 else
                %                     transmissions = [];
                %                 end
            end
            
            % remove links with zero mass and inertia
            link_indices_to_remove = [];
            for joint_index=1:numel(links)
                link = links(joint_index);
                if link.Mass == 0 && all(all(link.Inertia == zeros(3)))
                    link_indices_to_remove = [link_indices_to_remove,joint_index]; %#ok<*AGROW>
                end
            end
            if ~isempty(link_indices_to_remove)
                links(link_indices_to_remove) = [];
            end
            
            % remove joints with no child links (except base coordinates)
            joint_indices_to_remove = [];
            for joint_index=1:numel(joints)
                joint = joints(joint_index);
                child_index = str_index(joint.Child,{links.Name});
                if isempty(child_index)
                    joint_indices_to_remove = [joint_indices_to_remove,joint_index];
                end
            end
            if ~isempty(joint_indices_to_remove)
                joints(joint_indices_to_remove) = [];
            end
            
            % always remove fixed joints
            if options.RemoveFixedJoints
                joints_to_remove = [];
                links_to_remove = [];
                for joint_index = 1:length(joints)
                    if strcmp(joints(joint_index).Type, 'fixed')
                        joint_to_remove = joints(joint_index);
                        R_jot = joint_to_remove.R; % the rotation matrix of the current joint w.r.t. the parent joint
                        p_jot = joint_to_remove.P'; % the offset of the current joint in the parent joint frame
                        parent_index = str_index(joint_to_remove.Parent,{links.Name});
                        child_index = str_index(joint_to_remove.Child,{links.Name});
                        % Add mass together
                        M = links(parent_index).Mass + links(child_index).Mass;
                        % Recompute center of mass
                        p_parent = links(parent_index).P';  % the offset of parent link CoM in the parent joint
                        p_child  = R_jot*links(child_index).P' + p_jot; % the offset of child link CoM in the parent joint
                        p_com_new = (1.0/M) * (links(parent_index).Mass * p_parent ...
                            +  links(child_index).Mass * p_child);
                        % Recompute Inertia matrix
                        % Compute inertias about new COM and add together
                        
                        R_parent = links(parent_index).R;    % the rotation matrix of the parent link CoM in the parent joint frame
                        R_child  = R_jot*links(child_index).R; % the rotation matrix of the child link CoM in the parent joint frame
                        
                        R1 = (p_com_new - p_parent);
                        R2 = (p_com_new - p_child);
                        J1 = R_parent*links(parent_index).Inertia*R_parent' + links(parent_index).Mass * (dot(R1,R1)*eye(3) - (R1*R1'));
                        J2 = R_child*links(child_index).Inertia*R_child' + links(child_index).Mass * (dot(R2,R2)*eye(3) - (R2*R2'));
                        
                        % Update parent link
                        links(parent_index).Mass = M;
                        links(parent_index).P = p_com_new';
                        links(parent_index).Inertia = J1 + J2;
                        links(parent_index).R = eye(3);
                        % Find and remove the fixed joint and all children links
                        child_link = links(child_index);
                        next_joints = str_index(child_link.Name, {joints.Parent});
                        for k = 1:length(next_joints)
                            joints(next_joints(k)).Parent = links(parent_index).Name;
                            H01 = [R_jot, p_jot; zeros(1,3), 1];
                            H12 = [joints(next_joints(k)).R, joints(next_joints(k)).P'; zeros(1,3), 1];
                            H = H01*H12;
                            joints(next_joints(k)).P = H(1:3, end)';
                            joints(next_joints(k)).R = H(1:3, 1:3);
                        end
                        joints_to_remove = horzcat(joints_to_remove, joint_index); %#ok<*AGROW>
                        links_to_remove = horzcat(links_to_remove, child_index);
                    end
                end
                joints(joints_to_remove) = [];
                links(links_to_remove) = [];
            end
            
            if ischar(base)
                base_dofs = get_base_dofs(base);
            elseif isstruct(base)
                fields = {'Name','Type','P','R','Axis','Parent','Child'};
                assert(all(isfield(base,fields)),...
                    'The base dof structure must have the following fields:\n %s',implode(fields,', '));
                base_dofs = base;
            elseif isempty(base)
                base_dofs = base;
            else
                error(['The second argument must be either a character vector of ',...
                    'the type of the floating base coordinates, or a structure array of base DOFs.'])
            end
            
            
            if ~isempty(base_dofs)
                % non-fixed base coordiantes
                base_dofs(end).Child = find_base_link(joints);
            else
                % fixed base coordinates, we remove the base link (which is not
                % moving anyway) from the list of rigid links
                base_link = find_base_link(joints);
                % find the index of the base link
                base_link_idx = str_index(base_link,{links.Name});
                % remove the base link
                links(base_link_idx) = [];
            end
            
            
                        
            dofs = [base_dofs,joints];
            ndof = length(dofs);
            
            % Add joint actuator inputs
            %             for joint_index=1:numel(dofs)
            %                 dofs(joint_index).Actuator = struct();
            %                 if ~isempty(transmissions)
            %                     idx = str_index({transmissions.Joint},dofs(joint_index).Name);
            %                     if ~isempty(idx)
            %                         dofs(joint_index).Actuator.GearRatio = transmissions(idx).MechanicalReduction;
            %                         if isfield(transmissions(idx), 'Inertia')
            %                             dofs(joint_index).Actuator.RotorInertia = transmissions(idx).Inertia;
            %                         else
            %                             dofs(joint_index).Actuator.RotorInertia = 0;
            %                         end
            %                     end
            %                 end
            %             end
            
            
            % construct the object by calling superclass constructor
            % function
            obj = obj@ContinuousDynamics(name, 'SecondOrder');
            obj.Dimension = ndof;
            
            obj.ConfigFile = config_file;
            
            limits = [dofs.Limit];
    
            state_bounds = struct;
            
            q_lb = [limits.lower]';
            q_ub = [limits.upper]';
            
            state_bounds.x.lb = q_lb;
            state_bounds.x.ub = q_ub;
            
            dq_ub = [limits.velocity]';
            dq_lb = -dq_ub;
            
            state_bounds.dx.lb = dq_lb;
            state_bounds.dx.ub = dq_ub;
            
            state_bounds.ddx.lb = -10000*ones(ndof,1);
            state_bounds.ddx.ub = 10000*ones(ndof,1);
            obj.configureSystemStates(state_bounds);
            
            %% Configure and setup the forward kinematics of the robots
            obj = configureKinematics(obj, dofs, links);
            
            
            
            obj = configureDynamics(obj, options.LoadPath);
        end
        
        
        
        
        
        
        
        
        
    end
    
    
    %% methods defined in seperate files
    methods
        
        obj = addContact(obj, contact, fric_coef, geometry, load_path);
                
        obj = removeContact(obj, contact);        
        
                
        indices = getLinkIndices(obj, link_names);
        
        indices = getJointIndices(obj, joint_names);
        
        
        
        obj = configureKinematics(obj, dofs, links);
        
        obj = configureDynamics(obj, load_path);
        
        
        ang = getRelativeEulerAngles(obj, frame, R, p);
        
        [varargout] = getCartesianPosition(obj, frame, p);
        
        [varargout] = getEulerAngles(obj, frame, p);
        
        [varargout] = getBodyJacobian(obj, frame, p);
        
        [varargout] = getSpatialJacobian(obj, frame, p);
        
        [A_G_fun, A_G_dot_fun] = getCMM(obj, frame, export_path);
        
        [A_G, A_G_dot] = calcCMM(obj, q, dq);
        
        mass = getTotalMass(obj);        
        
        pos = getComPosition(obj);
        
        bounds = getLimits(obj);
        
        f = calcDriftVector(obj, q, dq);
        
        tau = inverseDynamics(obj, q, dq, ddq, lambda, g);
    
        nlp = imposeNLPConstraint(obj, nlp, varargin);
    
    end
    
    
    properties (Hidden)
        
        CMMat
        
        CMMatDot
    end
end

