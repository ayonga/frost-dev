function obj = addDynamicsConstraint(obj, phase, model)
    % Add system dynamics equations as a set of equality constraints   
    %
    % dynamics equation: D*ddq + H(q,dq) - Be*u - J^T(q)*Fe = 0;
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % model: the rigid body model of the robot @type RigidBodyModel
    
    
    num_node = obj.Phase{phase}.NumNode;
    col_names = obj.Phase{phase}.ConstrTable.Properties.VariableNames;
    
    
    % natrual dynamics    
    De_ddq = SymNlpFunction('Name', 'De_ddq_vec', ...
        'Expression', 'InertiaMatrix[].ddQe',...
        'Type', 'Nonlinear',...
        'Dimension', model.nDof);
    De_ddq.DepSymbols = {'Qe', 'dQe', 'ddQe'};
    De_ddq.PreCommands = 'Qe = GetQe[]; dQe = D[Qe, t]; ddQe = D[dQe, t];';
    
    Ce = SymNlpFunction('Name', 'Ce_vec', ...
        'Expression', 'InertiaToCoriolis[]',...
        'Type', 'Nonlinear',...
        'Dimension', model.nDof);
    Ce.DepSymbols = {'Qe', 'dQe'};
    Ce.PreCommands = 'Qe = GetQe[]; dQe = D[Qe, t];';
    
    Ge = SymNlpFunction('Name', 'Ge_vec', ...
        'Expression', 'GravityVector[]',...
        'Type', 'Nonlinear',...
        'Dimension', model.nDof);
    Ge.DepSymbols = {'Qe'};
    Ce.PreCommands = 'Qe = GetQe[];';
end