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
    dof_obj(n_dof) = RigidJoint();
    for i=1:n_dof
        dof_obj(i) = RigidJoint(dofs(i));
    end
    child_links = {dof_obj.Child};
    
    %% compute the kinematic tree structure
    
    % first find the all end effector links
    terminals = findEndEffector(obj, dofs);
    % the number of end effector links equals to the number of total branch
    kin_tree = cell(1,length(terminals));
    for i=1:length(terminals)
        kin_branch(1) = terminals(i);
        % find the parent link
        c_index = str_index(dof_obj(kin_branch(1)).Parent, child_links);
        % do until the the parent link is the base link
        while ~isempty(c_index)
            dof_obj(kin_branch(1)).setReference(dof_obj(c_index));
            
            kin_branch = [c_index,kin_branch]; %#ok<AGROW>
        
            c_index = str_index(dof_obj(kin_branch(1)).Parent, child_links);
        end
        kin_tree{i} = kin_branch;
        
        
        kin_branch = [];
    end
   
        
    % update the forward kinematics (homogeneous transformation) of the
    % rigid joints
    for i=1:length(kin_tree)
        kin_branch = kin_tree{i};
        for j=1:numel(kin_branch)
            if j > 1
                dof_obj(kin_branch(j)).setReference(dof_obj(kin_branch(j-1)));
            else
                dof_obj(kin_branch(j)).setReference(dof_obj(kin_branch(j)));
            end
            dof_obj(kin_branch(j)).setChainIndices(kin_branch(1:j));
            dof_obj(kin_branch(j)).computeHomogeneousTransform();
            
        end
    end
    
    % update the joint (relative) twists and the twist pairs
    for i=1:n_dof
        dof_obj(i).computeTwist();
        dof_obj(i).setTwistPairs(dof_obj, obj.States.x);
    end
    
    obj.Joints = dof_obj;

    
    
    
    n_link = length(links);
    link_obj(n_link) = RigidBody();
    for i=1:n_link
        % first create a RigidBody object array using the basic configuration
        % of links
        link_obj(i) = RigidBody(links(i));
        % find the index of the parent joint (reference coordinate frame)
        % of each rigid link
        idx = str_index(link_obj(i).Name, child_links);
        
        % set the reference frame of the rigid link
        link_obj(i) = setReference(link_obj(i),dof_obj(idx));
    end
    
    
    obj.Links  = link_obj;
end