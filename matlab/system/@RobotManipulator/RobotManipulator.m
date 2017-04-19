classdef RobotManipulator < DynamicalSystem
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
    % @author Ayonga Hereid @date 2016-09-26
    %
    % @new{1,0, ayonga, 2016-09-26} Migrated from old modelConfig class
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    %
    
    
    
    
    %% Constant properties
    properties (Constant)
    end
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        
              
        
        % The full path of the model configuration file
        %
        % @type char
        ConfigFile
        
        % An array of rigid links
        %
        % @type struct
        Links
        
        % An array of rigid joints
        %
        % @type RigidJoint
        Joints
        
        
        
       
    end
    
    
    
    
    
    %% Public methods
    methods
        
        
        function obj = RobotManipulator(name, config, base)
            % The class constructor function
            %
            %
            % Parameters:
            % name: the name of the model @type char
            % config: the configuration of the joints and links @type char           
            % base: the configuration of the floating base
            % coordinates  @type struct
            %
            % Return values:
            % obj: an object of this class
           
            
            % construct the object by calling superclass constructor
            % function
            obj = obj@DynamicalSystem(name, 'SecondOrder');
            
            % configure base joint for the model
            if nargin < 3
                % the base joint is not specified, use default
                fprintf('The floating base coordinates are not configured. \n');
                fprintf('Setting it to the default 6 DOF floating base configuration ...\n');
                base_dofs = get_base_dofs('floating');
            else
                if ischar(base)
                    base_dofs = get_base_dofs(base);
                elseif isstruct(base)
                    fields = {'Name','Type','Offset','Rotation','Axis','Parent','Child'};
                    assert(all(isfield(base,fields)),...
                        'The base dof structure must have the following fields:\n %s',implode(fields,', '));
                    base_dofs = base;
                elseif isempty(base)
                    base_dofs = base;
                else
                    error(['The second argument must be either a character vector of ',...
                        'the type of the floating base coordinates, or a structure array of base DOFs.'])
                end
            end
            
            eval_math('Needs["RobotManipulator`"];');
            
            if ischar(config) % configuration file name
                % parse the model configuration file
                [folder_name,file_name,file_ext] = fileparts(config);
            
                % check file type
                if isempty(file_ext) || strcmp(file_ext,'.urdf')
                    file_ext = '.urdf'; % default file type is URDF
                    config_file = GetFullPath(fullfile(folder_name, [file_name,file_ext]));
                    
                    % extract the absolute full file path of the input file
                    obj.ConfigFile = config_file;
                    
                    % load model from the URDF file
                    [~, links, joints, transmissions] = ros_load_urdf(config_file);
                else
                    error('Invalid configuration file type detected: %s.\n',file_ext(2:end));
                end
                
                
            elseif isstruct(config)
                fields = {'Name','Mass','Offset','Rotation','Inertia'};
                assert(all(isfield(config.links,fields)),...
                    'The links structure must have the following fields:\n %s',implode(fields,', '));
                links = config.links;
                
                fields = {'Name','Type','Offset','Rotation','Axis','Parent','Child'};
                assert(all(isfield(config.joints,fields)),...
                    'The joints structure must have the following fields:\n %s',implode(fields,', '));
                joints = config.joints;
                if isfield(config,'transmissions')
                    fields = {'Joint','MechanicalReduction'};
                    assert(all(isfield(config.transmissions,fields)),...
                        'The transmissions structure must have the following fields:\n %s',implode(fields,', '));
                    transmissions = config.transimissions;
                else
                    transmissions = [];
                end
            end
            
            
            
            base_dofs(end).Child = findBaseLink(obj,joints);
            
            dofs = [base_dofs,joints];
            ndof = length(dofs);
            % Add state variables
            x = SymVariable('x',[ndof,1],{dofs.Name});
            dx = SymVariable('dx',[ndof,1],{dofs.Name});
            ddx = SymVariable('ddx',[ndof,1],{dofs.Name});
            
            obj.addState(x,dx,ddx);
            
            if ~isempty(transmissions)
                % Add joint actuator inputs
                mechanicalReduction = zeros(1,numel(dofs));
                for i=1:numel(dofs)
                    if ~strcmp(dofs(i).Type,'fixed')
                        idx = str_index({transmissions.Joint},dofs(i).Name);
                        if ~isempty(idx)
                            mechanicalReduction(i) = transmissions(idx).MechanicalReduction;
                        end
                    end
                end
                
                gf(mechanicalReduction~=0,:) = diag(mechanicalReduction(mechanicalReduction~=0));
                actuated_joints = dofs(mechanicalReduction~=0);
                nact = length(actuated_joints);
                u = SymVariable('u',[nact,1],{actuated_joints.Name});
                
                obj.addInput('u',u,gf);
            end
            
           
            % Compute the forward kinematics of the robots
            obj = setKinematics(obj, dofs, links);
            
            %             obj = setDynamics(obj);
        end
        
        
        
        
        
        
        
        
        
    end
    
    
    %% methods defined in seperate files
    methods
        base_link = findBaseLink(obj, joints);
        
        terminals = findEndEffector(obj, joints);
        
        obj = setKinematics(obj, dofs, links);
        
        mass = getTotalMass(obj);
        
        indices = getLinkIndices(obj, link_names);
        
        indices = getJointIndices(obj, joint_names);
        
        pos = getComPosition(obj);
        
        
        obj = setDynamics(obj);
        
        [M,f] = calcDynamics(obj, qe, dqe);
        
        
        [varargout] = getCartesianPosition(obj, varargin);
        
        [varargout] = getEulerAngles(obj, varargin);
        
        [varargout] = getBodyJacobian(obj, varargin);
        
        [varargout] = getSpatialJacobian(obj, varargin);
    end
    
    %% Private methods
    
    
end

