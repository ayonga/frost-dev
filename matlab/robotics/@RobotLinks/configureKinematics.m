function obj = configureKinematics(obj, dofs, links)
    % Compute the forward kinematics of the robots using the coordinate
    % configurations
    %
    % Parameters:
    % dofs: a structure array of coordinate configuration @type struct
    % links: a structure array of link configuration @type struct
    %
    % This function computes the kinematic tree structure of the multibody
    % system, homogeneous transformation, and twists of the each coordinate
    % frames.
    
    
    % first create a RigidJoint object array using the basic configuration
    % of coordinates
    n_dof = length(dofs);
    %     dof_obj(n_dof) = RigidJoint();
    for i=1:n_dof
        dof_cell = namedargs2cell(dofs(i));
        dofs_obj(i) = RigidJoint(dof_cell{:}); %#ok<*AGROW>
    end
    child_links = {dofs_obj.Child};
    
    %% compute the kinematic tree structure
    
    % first find the all end effector links
    terminals = find_terminal_link(dofs);
    % the number of end effector links equals to the number of total branch
    kin_tree = cell(1,length(terminals));
    for i=1:length(terminals)
        kin_branch(1) = terminals(i);
        % find the parent link
        c_index = str_index(dofs_obj(kin_branch(1)).Parent, child_links);
        % do until the the parent link is the base link
        while ~isempty(c_index)
            dofs_obj(kin_branch(1)).setReference(dofs_obj(c_index));
            
            dofs_obj(c_index).addChildJoints(dofs_obj(kin_branch(1)));
            
            kin_branch = [c_index,kin_branch]; 
        
            c_index = str_index(dofs_obj(kin_branch(1)).Parent, child_links);
        end
        kin_tree{i} = kin_branch;
        
        
        kin_branch = [];
    end
   
    % update the forward kinematics (homogeneous transformation) of the
    % rigid joints
    base_frame = CoordinateFrame('Name','base','P',[0;0;0],'R',[0;0;0]);
    for i=1:length(kin_tree)
        kin_branch = kin_tree{i};
        for j=1:numel(kin_branch)
            if j > 1
                dofs_obj(kin_branch(j)).setReference(dofs_obj(kin_branch(j-1)));
            else
                %                 dof_obj(kin_branch(j)).setReference(dof_obj(kin_branch(j)));
                dofs_obj(kin_branch(j)).setReference(base_frame);
            end
            dofs_obj(kin_branch(j)).setChainIndices(kin_branch(1:j));
            
        end
    end
    
    % update the joint (relative) twists and the twist pairs
    for i=1:n_dof
        dofs_obj(i).setTwistPairs(dofs_obj, obj.States.x);
    end
    
    obj.Joints = dofs_obj;

    joint_name = {obj.Joints.Name}';
    setLabel(obj.States.x, joint_name);
    setLabel(obj.States.dx, joint_name);
    setLabel(obj.States.ddx, joint_name);
    
    
    child_joints = [obj.Joints.ChildJoints];
    child_joints_name = {child_joints.Name};
    joints_name = {obj.Joints.Name};
    joint_indices = str_indices(joints_name, child_joints_name);
    base_joint_indices = find(cellfun(@isempty,joint_indices));
    obj.BaseJoints = obj.Joints(base_joint_indices);
    
    v = cell(1,n_dof);
    dv = cell(1,n_dof);
    f = cell(1,n_dof);
    for i = 1:n_dof
        v{i} = StateVariable(['v',num2str(i)],6);
        dv{i} = StateVariable(['dv',num2str(i)],6);        
        f{i} = StateVariable(['f',num2str(i)],6,[],[]);
    end
    
    obj.addState(v{:},dv{:});
    obj.addState(f{:});
    
    
    %     A = zeros(6*obj.Dimension,obj.Dimension);
    %     for j_idx=1:obj.Dimension
    %         B_j_idx = obj.Joints(j_idx).TwistAxis;
    %         A((j_idx-1)*6 + (1:6) ,j_idx) = B_j_idx;
    %     end
    %     obj.Amat = sparse2(transpose(A));
    
    n_link = length(links);
    %     link_obj(n_link) = RigidBody();
    for i=1:n_link
        % first create a RigidBody object array using the basic configuration
        % of links
        link_cell = namedargs2cell(links(i));
        link_obj(i) = RigidBody(link_cell{:});
        % find the index of the parent joint (reference coordinate frame)
        % of each rigid link
        idx = str_index(link_obj(i).Name, child_links);
        
        % set the reference frame of the rigid link
        link_obj(i) = setReference(link_obj(i),dofs_obj(idx));
    end
    
    
    obj.Links  = link_obj;
    
    link_names = {obj.Links.Name};
    for j_idx = 1:n_dof
        joint = obj.Joints(j_idx);
        l_idx = str_index(joint.Child,link_names);
        if isempty(l_idx)
            obj.Joints(j_idx).G = zeros(6);
        else
            link = obj.Links(l_idx);
            G_i = link.SpatialInertia;
            L_i = CoordinateFrame.RigidInverse(CoordinateFrame.RPToHomogeneous(link.R,link.P));   % T_{link, joint}
            obj.Joints(j_idx).G = transpose(CoordinateFrame.RigidAdjoint(L_i)) * G_i * CoordinateFrame.RigidAdjoint(L_i);
        end
    end
    
end