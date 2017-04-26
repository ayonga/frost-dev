function obj = configure(obj, config, base)
    % configures the robot manipulator objects from the configuration
    % (struct or URDF/YAML) file 
    %
    % Parameters:
    % config: the configuration of the joints and links @type char           
    % base: the configuration of the floating base
    % coordinates  @type struct
    
    eval_math('Needs["RobotManipulator`"];');
            
    
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
    
    
    if ~isempty(base_dofs) 
        % non-fixed base coordiantes
        base_dofs(end).Child = findBaseLink(obj,joints);
    else
        % fixed base coordinates, we remove the base link (which is not
        % moving anyway) from the list of rigid links
        base_link = findBaseLink(obj,joints); 
        % find the index of the base link
        base_link_idx = str_index(base_link,{links.Name});
        % remove the base link
        links(base_link_idx) = [];
    end
    
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
    
    
    %% Configure and setup the forward kinematics of the robots
    obj = configureKinematics(obj, dofs, links);
    
    
    %% add fixed joints as holonomic constraints
    % find the fixed joint indices
    fixed_joint_indices = str_index('fixed',{obj.Joints.Type});
    % enforce holonomic constraints
    obj = addFixedJoint(obj,fixed_joint_indices);
end