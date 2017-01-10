function obj = addUnilateralConstraint(obj, kins)
% Adds unilateral kinematic constraints other than contact constraints to
% the domain
%
% Parameters:
%  kins: a cell array of kinematic constraints @type Kinematic


% validate input argument
if iscell(kins)
    assert(all(cellfun(@(x)isa(x,'Kinematics')&&~isa(x,'KinematicContact'),kins)),...
        ['The input must be a cell array of objects of type ''Kinematics'' other than ''KinematicContact''\n. '...
        'To add contact constraints, please use %s'], 'KinematicContact');
else
    assert(isa(kins,'Kinematics')&&~isa(kins,'KinematicContact'),...
        ['The input must be a cell array of objects of type ''Kinematics'' other than ''KinematicContact''\n. '...
        'To add contact constraints, please use %s'], 'KinematicContact');
    kins = {kins};
end

% add to the holonomic constraints group
obj.UnilateralConstr = addKinematic(obj.UnilateralConstr, kins);


end
