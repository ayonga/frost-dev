function obj = addControlVariable(obj, phase, model)
    % Adds control variables as the NLP decision variables to the problem
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer    
    % model: the rigid body model of the robot @type RigidBodyModel
    
    num_node = obj.Phase{phase}.NumNode;
    col_names = obj.Phase{phase}.OptVarTable.Properties.VariableNames;
    domain = obj.Phase{phase}.Domain;
    
    % state variables are defined at all collocation nodes
    nodeList = 1:1:num_node;
    
    
    %% actuator torque (u)
    u_dim = size(domain.ActuationMap, 2);
    u_lb = -domain.ActuationMap'*[model.Dof.effort]';
    u_ub = domain.ActuationMap'*[model.Dof.effort]';
    u = create_object_array('NlpVariable', num_node, nodeList, ...
        'Name', 'u', 'Dimension', u_dim, ...
        'lb', u_lb, ...
        'ub', u_ub);
    
    % add to the decision variable table
    obj.Phase{phase}.OptVarTable = [...
        obj.Phase{phase}.OptVarTable;...
        array2table(u,'VariableNames',col_names,'RowNames',{'u'})];
    
    
    %% constraint wrenches (Fe)
    if ~isempty(domain.HolonomicConstr)
        n_hol_constr = getDimension(domain.HolonomicConstr);
        
        min_force = -1e5;
        max_force = 1e5;
        
        Fe = create_object_array('NlpVariable', num_node, nodeList, ...
            'Name', 'Fe', 'Dimension', n_hol_constr, ...
            'lb', min_force, ...
            'ub', max_force);
        
        % add to the decision variable table
        obj.Phase{phase}.OptVarTable = [...
            obj.Phase{phase}.OptVarTable;...
            array2table(Fe,'VariableNames',col_names,'RowNames',{'Fe'})];
        
        
    end
    
    


end