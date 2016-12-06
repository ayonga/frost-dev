function c_indices = getConstrainedDofs(obj, model)
    % Returns the indices of constrained degrees of freedom of the
    % kinematic contact
    %
    % Parameters:
    % model: a rigid body model of type RigidBodyModel
    %
    % Return values:
    % c_indices: constrained degrees of freedom indices @type rowvec
    
    % all potential degrees of freedom
    dof_indices = [1, 2, 3, 4, 5, 6];
    
    % if the model is planar, then remove translation dof along y-axis
    % (2) and rotation along x-axis(4) and z-axis(6).
    if strcmp(model.type, 'planar')
        dof_indices([2,4,6]) = 0;
    end
    
    % remove the normal axis translation
    dof_indices(strcmp(obj.NormalAxis,{'x','y','z'})) = 0;
    
    % if the contact is with friction, remove all three
    % translantional degrees of freedom
    if regexp(obj.ContactType,'\w*WithFriction$')
        dof_indices(1:3) = 0;
    end
    
    % if the contact is a line contact with friction, keep only the
    % tangent axis
    if strcmp(obj.ContactType,'LineContactWithFriction')
        rot_indices = dof_indices(4:6);
        rot_indices(~strcmp(obj.TangentAxis,{'x','y','z'})) = 0;
        dof_indices(4:6) = rot_indices;
    end
    % if the contact is a line contact without friction, keep both
    % the normal axis and tangent axis
    if strcmp(obj.ContactType,'LineContactWithoutFriction')
        rot_indices = dof_indices(4:6);
        rot_indices(~(strcmp(obj.TangentAxis,{'x','y','z'}) + ...
            strcmp(obj.NormalAxis,{'x','y','z'}))) = 0;
        dof_indices(4:6) = rot_indices;
    end
    
    % if the contact is a planar contact with friction, remove all three
    % rotational degrees of freedom
    if strcmp(obj.ContactType,'PlanarContactWithFriction')
        dof_indices(4:6) = 0;
    end
    
    % if the contact is a planar contact without friction, keep
    % only the rotation along the normal force
    if strcmp(obj.ContactType,'PlanarContactWithoutFriction')
        rot_indices = dof_indices(4:6);
        rot_indices(~strcmp(obj.NormalAxis,{'x','y','z'})) = 0;
        dof_indices(4:6) = rot_indices;
    end
    
    % keep all zero indcies
    c_indices = find(~dof_indices);
end
