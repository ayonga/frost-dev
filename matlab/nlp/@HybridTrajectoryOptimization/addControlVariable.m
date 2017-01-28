function obj = addControlVariable(obj, phase)
    % Adds control variables as the NLP decision variables to the problem
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer    
    % model: the rigid body model of the robot @type RigidBodyModel
    
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};


    n_node = phase_info.NumNode;
    col_names = phase_info.OptVarTable.Properties.VariableNames;

    domain = obj.Gamma.Nodes.Domain{phase_info.CurrentVertex};
    model = obj.Model;
    % state variables are defined at all collocation nodes
    node_list = 1:1:n_node;
    
    
    %% actuator torque (u)
    u_dim = size(domain.ActuationMap, 2);
    u_lb = domain.ActuationMap'*[model.Dof.minEffort]';
    u_ub = domain.ActuationMap'*[model.Dof.maxEffort]';
    u = repmat({{}},1, n_node);
    for i=node_list
        u{i} = {NlpVariable(...
            'Name', 'u', 'Dimension', u_dim, ...
            'lb', u_lb, ...
            'ub', u_ub)};
    end
    % add to the decision variable table
    obj.Phase{phase_idx}.OptVarTable = [...
        obj.Phase{phase_idx}.OptVarTable;...
        cell2table(u,'VariableNames',col_names,'RowNames',{'U'})];
    
    
    %% constraint wrenches (Fe)
    if ~isempty(domain.HolonomicConstr)
        n_hol_constr = getDimension(domain.HolonomicConstr);
        
        min_force = -1e4;
        max_force = 1e4;
        
        Fe = repmat({{}},1, n_node);
        for i=node_list
            Fe{i} = {NlpVariable(...
                'Name', 'Fe', 'Dimension', n_hol_constr, ...
                'lb', min_force, ...
                'ub', max_force)};
        end
        % add to the decision variable table
        obj.Phase{phase_idx}.OptVarTable = [...
            obj.Phase{phase_idx}.OptVarTable;...
            cell2table(Fe,'VariableNames',col_names,'RowNames',{'Fe'})];
        
        
    end
    
    


end