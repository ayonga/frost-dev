function obj = setAcutation(obj, model, actuated_joints)
    % Sets the actuation map for the current domain.
    %
    % @todo better implementation ...
    %
    % Parameters:
    % model: a rigid body model of type RigidBodyModel
    % actuated_joints: a list of actuated joints @type cellstr
    %
    
    
    if nargin < 3
        actuated_joints = model.actuated_joints;
    end
    
    actuated_indices = getDofIndices(model, actuated_joints);
    
    Be = eye(model.nDof);
    
    obj.ActuationMap = Be(:, actuated_indices);
    
    
    
    
end
