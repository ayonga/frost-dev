function obj = configureActuator(obj, dofs, actuators)
    % Configure the actuator information of the actuated joints
    %
    % Parameters:
    % dofs: an object array or name cellstr of actuated joints 
    % @type cell
    % actuators: a structure array of actuator configuration @type struct
    %
    % The actuator configuration may include the inertia and gear
    % ratio of the actuator.
    
    if iscellstr(dofs)
        dof_indices = getJointIndices(obj, dofs);
    elseif isa(dofs,'RigidJoint')
        dof_indices = getJointIndices(obj, {dofs.Name});
    end
    
    n_dof = length(dof_indices);
    
    assert(length(actuators)==n_dof,...
        'The length of the joints and actuators must be the same.');
    
    for i=1:n_dof
        idx = dof_indices(i);
        obj.Joints(idx).setActuator(actuators(i));        
    end
end