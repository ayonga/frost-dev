function obj = addFixedJoint(obj, fixed_joints)
    % enforces fixed joints as holonomic constraints of the dynamical system of
    % the robot manipulator
    %
    % Parameters:
    % joints: the list of fixed joints @type cellstr
    
    
    
    if iscellstr(fixed_joints)
        j_name = fixed_joints;
    elseif isstruct(fixed_joints)
        j_name = {fixed_joints.Name};
    elseif isa(fixed_joints,'RigidJoint')
        j_name = {fixed_joints.Name};
    else
        error('The list of fixed joints must be given as a cellstr, structure array or RigidJoint object array.');
    end
        
    constr = obj.States.x(j_name);
    
    name = ['fixed' j_name{:}];
    obj = addHolonomicConstraint(obj, name, constr);
end
    