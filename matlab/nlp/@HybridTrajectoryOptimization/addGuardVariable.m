function obj = addGuardVariable(obj, phase, hbar_props, impf_props)
    % Adds defect variables associated with discrete transition at the
    % guard as the NLP decision variables to the problem. It includes the
    % constant vector of holonomic constraints, instantaneous impact force,
    % etc.
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % model: the rigid body model of the robot @type RigidBodyModel
    % hbar_props: properties of parameter ''hbar'' @type struct
    % impf_props: properties of parameter ''impF'' @type struct
    %
    % Required fields of hbar_props:
    % lb: the lower bound of the parameters @type struct
    % ub: the upper bound of the parameters @type struct
    % x0: the typical initial value of the parameters @type struct
    %
    % Required fields of impf_pros:
    % lb: the lower bound of the parameters @type struct
    % ub: the upper bound of the parameters @type struct
    % x0: the typical initial value of the parameters @type struct
    
    
    % use default values if not given explicitly
    if nargin < 3
        hbar_props = struct('lb',0,'ub',0,'x0',0);       
    end
    
    if nargin < 4
        impf_props = struct('lb',-10000,'ub',10000,'x0',0);
    end
    
    
    
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};


    n_node = phase_info.NumNode;
    col_names = phase_info.OptVarTable.Properties.VariableNames;

    domain = obj.Gamma.Nodes.Domain{phase_info.CurrentVertex};
    edge_idx = findedge(obj.Gamma, phase_info.CurrentVertex, phase_info.NextVertex);
    guard  = obj.Gamma.Edges.Guard{edge_idx};
    
    % h - the constant value of the holonomic kinematic constraints
    if ~isempty(domain.HolonomicConstr)
        n_hol_constr = getDimension(domain.HolonomicConstr);
        h = repmat({{}},1, n_node);
        hbar_props.Name = 'h';
        hbar_props.Dimension = n_hol_constr;
        h{1} = {NlpVariable(hbar_props)};
        % add to the table
        obj.Phase{phase_idx}.OptVarTable = [...
            obj.Phase{phase_idx}.OptVarTable;...
            cell2table(h,'VariableNames',col_names,'RowNames',{'H'})];
    end
    
    % Fi - impact wrenches if the discrete transition involves a rigid
    % impact
    if ~isempty(guard) && guard.ResetMap.RigidImpact
        
        % the dimension of the impact wrenches equals to the the dimension
        % of the holonomic constraints of the next domain.
        next_domain  = obj.Gamma.Nodes.Domain{obj.Phase{phase_idx}.NextVertex};
        n_hol_constr = getDimension(next_domain.HolonomicConstr);
        Fi = repmat({{}},1, n_node);
        % defined at the last node
        impf_props.Name = 'impF';
        impf_props.Dimension = n_hol_constr;
        Fi{n_node} = {NlpVariable(impf_props)};
        
        % add to the table
        obj.Phase{phase_idx}.OptVarTable = [...
            obj.Phase{phase_idx}.OptVarTable;...
            cell2table(Fi,'VariableNames',col_names,'RowNames',{'Fi'})];
    end
    


end