function sva = configureSVA(obj, model, base_dofs)
    % Configure the sva struct for the spatial vector algebra package
    %
    % @attention The SVA 2.0 package could not correctly compute the rigid
    % body dynamics if the kinematic tree is not ordered in strictly
    % increasing order. 
    %
    % Parameters:
    % model: a parsed model structure from URDF file @type struct
    %
    % Return values:
    %  sva:   the SVA model structure @type struct
    
    
    
    
    sva = struct();
    % Number of bodies
    sva.NB = obj.nDof;
    n_base_dofs = obj.nBaseDof;
    % model type
    type = obj.Type;
    % Precollocation
    blankc = cell(sva.NB, 1);
    blankVec = zeros(sva.NB, 1);
    switch type
        case 'spatial'
            blankMat = zeros(6, 6, sva.NB);
            sva.gravity = [0, 0, -9.81];
            jtype = {'Px','Py','Pz','Rx','Ry','Rz'};
        case 'planar'
            blankMat = zeros(3,3,sva.NB);
            sva.gravity = [0, -9.81];
            jtype = {'px','py','r'};
    end
    
    sva.jtype = blankc;
    sva.Xtree = blankMat;
    sva.I     = blankMat;
    sva.parent  = blankVec;    
    sva.axis  = blankVec;
    sva.isRevolute = blankVec;
    
    parent_indices = getLinkIndices(obj,{model.joints.parent});
    child_indices = getLinkIndices(obj,{model.joints.child});
    
    % find the base link, which should be the link that is the parent link
    % of some joints but is the child link to no joint. In other words, the
    % indices that occurs in 'parent_indices' but not occurs in
    % 'child_indices'.
    base_link_index = unique(parent_indices(~ismember(parent_indices,child_indices)));
    % configure floating base coordiantes as stacked joints with zero
    % mass/inertia/length
    for i=1:n_base_dofs
        sva.parent(i) = i-1;
        sva.jtype{i} = base_dofs.axis{i};
        switch sva.jtype{i}
            case {'Px','px'}
                sva.isRevolute(i) = false; % prismatic joint
                sva.axis(i) = 1;           % x-axis
            case {'Py','py'}
                sva.isRevolute(i) = false; % prismatic joint
                sva.axis(i) = 2;           % y-axis
            case 'Pz'
                sva.isRevolute(i) = false; % prismatic joint
                sva.axis(i) = 3;           % z-axis
            case {'Rx','r'}
                sva.isRevolute(i) = true;  % revolute joint
                sva.axis(i) = 1;           % x-axis
            case 'Ry'
                sva.isRevolute(i) = true;  % revolute joint
                sva.axis(i) = 2;           % y-axis
            case 'Rz'
                sva.isRevolute(i) = true;  % revolute joint
                sva.axis(i) = 3;           % z-axis
        end
        % Assign other configuration
        if strcmp(type,'spatial')
            sva.Xtree(:,:,i) = plux(eye(3), zeros(1,3));
        else
            sva.Xtree(:,:,i) = plnr(0, zeros(1,2));
        end
        if i < n_base_dofs
            if strcmp(type,'spatial')
                sva.I(:,:,i) = mcI(0, zeros(1,3), zeros(3));
            else
                sva.I(:,:,i) = mcI(0, zeros(1,2), 0);
            end
        else
            
            base_link = model.links(base_link_index);
            l_xyz = base_link.origin.xyz;
            l_rpy = base_link.origin.rpy;
            R = eye(3);
            for j=3:1
                R = R*rotation_matrix(j,l_rpy(j));
            end
            inertia = transpose(R)*base_link.inertia*R;
            if strcmp(type,'spatial')
                sva.I(:,:,i) =  mcI(base_link.mass, l_xyz, inertia);
            else
                sva.I(:,:,i) =  mcI(base_link.mass, l_xyz([1,3]), inertia(2,2));
            end
        end
        
    end
    
    %| @todo how to model 'fixed' joints in SVA?
    %| @todo verify the correctness of the SVA model.
    
    
    
    
    for i = 1:numel(model.joints)
        joint = model.joints(i);
        lambda = find(eq(child_indices,parent_indices(i)));
        if isempty(lambda)
            lambda = 0;            
        end
        sva.parent(i+n_base_dofs) = lambda + n_base_dofs;
        
        j_xyz = joint.origin.xyz;
        j_rpy = joint.origin.rpy;
        if strcmp(type,'spatial')
            E = eye(3);
            for j=3:-1:1
                E = E*rotation_matrix(j,j_rpy(j));
            end
            %| @note why we need to transpose the matrix 'E'? Is it because
            %ROS (URDF) uses fixed axis transformation?
            sva.Xtree(:,:,i+n_base_dofs) = plux(E', j_xyz);
        else
            sva.Xtree(:,:,i+n_base_dofs) = plnr(j_rpy(2), j_xyz([1,3]));
        end
        
        
        
        
        % Specify axis type, and assign prefix
        switch joint.type
            case 'prismatic'
                sva.isRevolute(i+n_base_dofs) = false;
                full_index = find(joint.axis);
                if strcmp(type, 'spatial')
                    index = full_index;
                else
                    if full_index == 1
                        index = 1; % 'px'
                    elseif full_index == 3
                        index = 2; %'py'
                    end
                end
            case {'revolute', 'continuous'}
                sva.isRevolute(i+n_base_dofs) = true;
                full_index = find(joint.axis);
                if strcmp(type, 'spatial')
                    index = full_index + 3;
                else
                    index = 3; %'r'
                end
            case 'fixed'
                sva.isRevolute(i+n_base_dofs) = true;
                full_index = find(joint.axis);
                if strcmp(type, 'spatial')
                    index = full_index + 3;
                else
                    index = 3; %'r'
                end
            otherwise
                error('RigidBodyModel:invalidJointType.');
        end
        
        
        
        % Specify whether it is positive or negative axis
        axis_value = joint.axis(full_index);
        if axis_value < 0
            sva.jtype{i+n_base_dofs} = ['-', jtype{index}];
            axis = -full_index;
        else
            sva.jtype{i+n_base_dofs} = jtype{index};
            axis = full_index;
        end
        sva.axis(i+n_base_dofs) = axis;
        
        
        child_link = model.links(child_indices(i));
        l_xyz = child_link.origin.xyz;
        l_rpy = child_link.origin.rpy;
        R = eye(3);
        for j=3:-1:1
            R = R*rotation_matrix(j,l_rpy(j));
        end
        inertia = transpose(R)*child_link.inertia*R;        
        if strcmp(type,'spatial')
            sva.I(:,:,i+n_base_dofs) =  mcI(child_link.mass, l_xyz, inertia);
        else
            sva.I(:,:,i+n_base_dofs) =  mcI(child_link.mass, l_xyz([1,3]), inertia(2,2));
        end
    end
    
    sva.type = type;
    
    
    
    
end
