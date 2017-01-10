function obj = removeContact(obj, contacts)
% Removes holonomic kinematic constraints other than contact constraints
% from the domain
%
% Parameters:
%  kins: a cell array of kinematic objects or name string @type Kinematic




% remove from the holonomic constraints group
obj.HolonomicConstr = removeKinematic(obj.HolonomicConstr, contacts);

% remove from the unilateral constraints group
obj.UnilateralConstr = removeKinematic(obj.UnilateralConstr, contacts);


end
