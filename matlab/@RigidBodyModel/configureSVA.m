function sva = configureSVA(obj)
    % Configure the sva struct for the spatial vector algebra package
    %
    % Return values:
    %  sva:   the SVA model structure @type struct
    
    
    sva = struct();
    % Number of bodies
    sva.NB = obj.nDof;
    % model type
    type = obj.options.base_joint_type;
    % Precollocation
    blankc = cell(sva.NB, 1);
    blankVec = zeros(sva.NB, 1);
    switch type
        case 'floating'
            blankMat = zeros(6, 6, sva.NB);
            sva.gravity = [0, 0, -9.81];
            jtype = {'Px', 'Py', 'Pz', 'Rx', 'Ry', 'Rz'};
        case 'planar'
            blankMat = zeros(3,3,sva.NB);
            sva.gravity = [0, -9.81];
            jtype = {'px', 'pz', 'r'};
    end
    
    sva.jtype = blankc;
    sva.Xtree = blankMat;
    sva.I     = blankMat;
    sva.parent  = blankVec;    
    sva.axis  = blankVec;
    sva.isRevolute = blankVec;
    
    
    % configure floating base coordiantes as stacked joints with zero
    % mass/inertia/length
    for i=1:obj.nBase
        sva.parent(i) = i-1;
        if i <= 3 
            sva.isRevolute(i) = false; % first three are positions
            sva.axis(i) = i;
        else
            sva.isRevolute(i) = true;  % last three are rotations
            sva.axis(i) = i-3;
        end
        % Assign other configuration
        sva.Xtree(:,:,i) = plux(eye(3), zeros(1,3));
        sva.I(:,:,i) = mcI(0, zeros(1,3), zeros(3));
        sva.jtype{i} = jtype{i};
    end
    
    %| @todo how to model 'fixed' joints in SVA?
    %| @todo verify the correctness of the SVA model.
    
    
    parent_indices = getLinkIndices(obj,{obj.joints.parent});
    child_indices = getLinkIndices(obj,{obj.joints.child});
    
    %| @todo implement configure SVA
    for i = 1:numel(obj.joints)
        lambda = find(eq(child_indices,parent_indices(i)));
        if isempty(lambda)
            lambda = 0;
            j_xyz = zeros(3,1);
            j_rpy = zeros(3,1);
        else
            j_xyz = obj.joints(lambda).origin.xyz;
            j_rpy = obj.joints(lambda).origin.xyz;
        end
        sva.parent(i+obj.nBase) = lambda + obj.nBase;
        E = eye(3);
        for j=3:1
            E = E*rotation_matrix(j,j_rpy(j));
        end
        sva.Xtree(:,:,i+obj.nBase) = plux(E, j_xyz);
        
        joint = obj.joints(i);
        
        % Specify axis type, and assign prefix
        switch joint.type
            case 'prismatic'
                sva.isRevolute(i+obj.nBase) = false;
                full_index = find(joint.axis);
                if strcmp(type,'planar')
                    if full_index == 1
                        index = 1; % 'px'
                    elseif full_index == 3
                        index = 2; %'pz'
                    end
                elseif strcmp(type, 'floating')
                    index = full_index;
                end
            case {'revolute', 'continuous'}
                sva.isRevolute(i+obj.nBase) = true;
                full_index = find(joint.axis);
                if strcmp(type,'planar')
                    index = 3; %'r'
                elseif strcmp(type, 'floating')
                    index = full_index + 3;
                end
            case 'fixed'
                sva.isRevolute(i+obj.nBase) = true;
                full_index = find(joint.axis);
                if strcmp(type,'planar')
                    index = 3; %'r'
                elseif strcmp(type, 'floating')
                    index = full_index + 3;
                end
            otherwise
                error('robotModel:: undefined joint type.');
        end
        
        
        
        % Specify whether it is positive or negative axis
        axis_value = joint.axis(full_index);
        if axis_value < 0
            sva.jtype{i+obj.nBase} = ['-', jtype{index}];
            axis = -full_index;
        else
            sva.jtype{i+obj.nBase} = jtype{index};
            axis = full_index;
        end
        sva.axis(i+obj.nBase) = axis;
        
        
        child_link = obj.links(child_indices(i));
        l_xyz = child_link.origin.xyz;
        l_rpy = child_link.origin.rpy;
        R = eye(3);
        for j=3:1
            R = R*rotation_matrix(j,l_rpy(j));
        end
        inertia = transpose(R)*child_link.inertia*R;
        sva.I(:,:,i+obj.nBase) = mcI(child_link.mass, l_xyz, inertia);
        
        
        
    end
    
    sva.type = type;
end