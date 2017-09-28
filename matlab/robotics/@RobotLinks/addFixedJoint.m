function obj = addFixedJoint(obj, fixed_joints, load_path)
    % enforces fixed joints as holonomic constraints of the dynamical system of
    % the robot manipulator
    %
    % Parameters:
    % fixed_joints: the list of fixed joints @type cellstr
    % load_path: the path from which the symbolic expressions for the
    % input map can be loaded @type char
    
    if iscellstr(fixed_joints)
        indices = obj.getJointIndices(fixed_joints);
    elseif isnumeric(fixed_joints)
        indices = fixed_joints;
    elseif isstruct(fixed_joints)
        indices = obj.getJointIndices({fixed_joints.Name});
    elseif isa(fixed_joints,'RigidJoint')
        indices = obj.getJointIndices({fixed_joints.Name});
    else
        error('The list of fixed joints must be given as a cellstr, structure array or RigidJoint object array.');
    end
        
    constr = obj.States.x(indices);
    
    % the name will looks like something like "fixedq7q8q9" with the numbers
    % are the indices of the fixed joints
    label = arrayfun(@(x)['q' num2str(x)],indices, 'UniformOutput',false);
     
    name = 'qfixed'; 
    if nargin < 3
        load_path = [];
    end
    if isempty(load_path)
        % create a holonomic constraint object
        fixed_joints = HolonomicConstraint(obj,constr,name,...
            'ConstrLabel',{label},...
            'DerivativeOrder',2);
        
        obj = addHolonomicConstraint(obj, fixed_joints);
    else
        % create a holonomic constraint object
        fixed_joints = HolonomicConstraint(obj,constr,name,...
            'LoadPath', load_path,...
            'ConstrLabel',{label},...
            'DerivativeOrder',2);
        
        obj = addHolonomicConstraint(obj, fixed_joints, load_path);
    end
end
    