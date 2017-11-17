function obj = configure(obj, config, base, load_path, varargin)
    % configures the robot manipulator objects from the configuration
    % (struct or URDF/YAML) file 
    %
    % Parameters:
    % config: the configuration of the joints and links @type char           
    % base: the configuration of the floating base
    % coordinates  @type struct
    
    parser = inputParser;
    addOptional(parser,'removeFixedJoints',false)
    parse(parser, varargin{:});
    parser_results = parser.Results;
    
    eval_math('Needs["RobotManipulator`"];');
            
    
    % configure base joint for the model
    
    if ischar(base)
        base_dofs = get_base_dofs(base);
    elseif isstruct(base)
        fields = {'Name','Type','Offset','R','Axis','Parent','Child'};
        assert(all(isfield(base,fields)),...
            'The base dof structure must have the following fields:\n %s',implode(fields,', '));
        base_dofs = base;
    elseif isempty(base)
        base_dofs = base;
    else
        error(['The second argument must be either a character vector of ',...
            'the type of the floating base coordinates, or a structure array of base DOFs.'])
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
            [name, links, joints, transmissions] = ros_load_urdf(config_file);
            obj.Name = name;
        else
            error('Invalid configuration file type detected: %s.\n',file_ext(2:end));
        end
        
        
    elseif isstruct(config)
        obj.Name = config.name;
        
        fields = {'Name','Mass','Offset','R','Inertia'};
        assert(all(isfield(config.links,fields)),...
            'The links structure must have the following fields:\n %s',implode(fields,', '));
        links = config.links;
        
        fields = {'Name','Type','Offset','R','Axis','Parent','Child'};
        assert(all(isfield(config.joints,fields)),...
            'The joints structure must have the following fields:\n %s',implode(fields,', '));
        joints = config.joints;
        if isfield(config,'transmissions')
            fields = {'Joint','MechanicalReduction'};
            assert(all(isfield(config.transmissions,fields)),...
                'The transmissions structure must have the following fields:\n %s',implode(fields,', '));
            transmissions = config.transmissions;
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
    
    %% Remove fixed joints
    if parser_results.removeFixedJoints
        Rz = @(th) [cos(th), -sin(th), 0; sin(th), cos(th), 0; 0,0,1];
        Ry = @(th) [cos(th), 0, sin(th); 0, 1, 0; -sin(th), 0, cos(th)];
        Rx = @(th) [1,0,0; 0, cos(th), -sin(th); 0, sin(th), cos(th)];
        Rot = @(q) Rz(q(3))*Ry(q(2))*Rx(q(1));
        joints_to_remove = [];
        links_to_remove = [];
        for i = 1:length(joints)
            if strcmp(joints(i).Type, 'fixed')
                parent_index = find(strcmp({links.Name}, joints(i).Parent));
                child_index = find(strcmp({links.Name}, joints(i).Child));
                % Add mass together
                M = links(parent_index).Mass + links(child_index).Mass;
                % Recompute center of mass
                COM = (1.0/M) * (links(parent_index).Mass * links(parent_index).Offset ...
                    +  links(child_index).Mass * links(child_index).Offset);
                % Recompute Inertia matrix
                % Compute inertias about new COM and add together
                R1 = (COM - links(parent_index).Offset);
                R2 = (COM - links(child_index).Offset);
                J1 = links(parent_index).Inertia + links(parent_index).Mass * (dot(R1,R1)*eye(3) - (R1'*R1));
                J2 = links(child_index).Inertia + links(child_index).Mass * (dot(R2,R2)*eye(3) - (R2'*R2));

                % Update parent link
                links(parent_index).Mass = M;
                links(parent_index).Offset = COM;
                links(parent_index).Inertia = J1 + J2;

                % Find and remove the fixed joint and all children links
                fixed_joint_children_indices = find(strcmp({links.Name}, joints(i).Child));
                for j = 1:length(fixed_joint_children_indices)
                    child_link = links(fixed_joint_children_indices);
                    joints_with_fixed_parent = find(strcmp({joints.Parent}, child_link.Name));
                    for k = 1:length(joints_with_fixed_parent)
                        joints(joints_with_fixed_parent(k)).Parent = links(parent_index).Name;
                        H01 = [Rot(joints(i).R), joints(i).Offset'; zeros(1,3), 1];
                        H12 = [Rot(joints(joints_with_fixed_parent(k)).R), joints(joints_with_fixed_parent(k)).Offset'; zeros(1,3), 1];
                        H = H01*H12;
                        joints(joints_with_fixed_parent(k)).Offset = H(1:3, end)';
                        joints(joints_with_fixed_parent(k)).R = H(1:3, 1:3);
                    end
                end
                joints_to_remove = horzcat(joints_to_remove, i); %#ok<*AGROW>
                links_to_remove = horzcat(links_to_remove, child_index);
            end
        end
        joints(joints_to_remove) = [];
        links(links_to_remove) = [];
    end
    
    %%
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
                    dofs(i).Actuator.Ratio = mechanicalReduction(i);
                    if isfield(transmissions(idx), 'Inertia')
                        dofs(i).Actuator.Inertia = transmissions(idx).Inertia;
                    else
                        dofs(i).Actuator.Inertia = 0;
                    end
                end
            end
        end
        
        actuated_joints = dofs(mechanicalReduction~=0);
        nact = length(actuated_joints);
        
        gf = zeros(obj.numState, nact);
        gf(mechanicalReduction~=0,:) = diag(mechanicalReduction(mechanicalReduction~=0));
        
        u = SymVariable('u',[nact,1],{actuated_joints.Name});
        if isempty(load_path)
            obj.addInput('Control','u',u,gf);
        else
            obj.addInput('Control','u',u,gf,'LoadPath',load_path);
        end
    end

    
    %% Configure and setup the forward kinematics of the robots
    obj = configureKinematics(obj, dofs, links);
    
    %% add fixed joints as holonomic constraints
    % find the fixed joint indices
    fixed_joint_indices = str_index('fixed',{obj.Joints.Type});
    % enforce holonomic constraints
    if ~isempty(fixed_joint_indices)
        if isempty(load_path)
            obj = addFixedJoint(obj,fixed_joint_indices);
        else
            obj = addFixedJoint(obj,fixed_joint_indices,load_path);
        end
    end
    
end