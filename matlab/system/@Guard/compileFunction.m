function obj = compileFunction(obj, model, varargin)
    % Compiles the symbolic expression of the kinematic function
    % for the guard in Mathematica.
    %
    % Parameters:
    % model: a rigid body model of type RigidBodyModel
    % varargin: optional arguments for kinematic compile function.
    
    assert(isa(model,'RigidBodyModel'),...
        'Guard:invalidType',...
        'The model must be a RigidBodyModel object');
    
    % compile the kinematic function
    compileExpression(obj.kin, model, varargin{:});
    
    % Assign the symbolic variable
    eval_math(['$h[',obj.funcs.pos,']=', obj.kin.symbol,'];']);
    
    eval_math(['$Jh[',obj.funcs.jac,']=', obj.kin.jac_symbol,'];']);
end
