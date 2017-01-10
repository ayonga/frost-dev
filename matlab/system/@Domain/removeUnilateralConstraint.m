function obj = removeUnilateralConstraint(obj, kins)
% Removes unilateral kinematic constraints other than contact constraints
% from the domain
%
% Parameters:
%  kins: a cell array of kinematic objects or name string @type Kinematic




% remove from the unilateral constraints group
obj.UnilateralConstr = removeKinematic(obj.UnilateralConstr, kins);


end
