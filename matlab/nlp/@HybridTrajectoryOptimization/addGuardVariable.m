function obj = addGuardVariable(obj, phase, lb, ub, x0)
    % Adds defect variables associated with discrete transition at the
    % guard as the NLP decision variables to the problem. It includes the
    % constant vector of holonomic constraints, instantaneous impact force,
    % etc.
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % model: the rigid body model of the robot @type RigidBodyModel
    % lb: the lower bound of the parameters @type struct
    % ub: the upper bound of the parameters @type struct
    % x0: the typical initial value of the parameters @type struct
    
    
    % use default values if not given explicitly
    if nargin < 3
        lb = struct('h',0,...
            'Fi', -1e5);        
    end
    
    if nargin < 4
        ub = struct('h',0,...
            'Fi', 1e5);
    end
    
    if nargin < 4
        x0 = struct('h',0,...
            'Fi', 0);
    end
    
    
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};


    n_node = phase_info.NumNode;
    col_names = phase_info.OptVarTable.Properties.VariableNames;

    domain = phase_info.Domain;
    guard = phase_info.Guard;
    
    % h - the constant value of the holonomic kinematic constraints
    if ~isempty(domain.HolonomicConstr)
        n_hol_constr = getDimension(domain.HolonomicConstr);
        h = repmat({{}},1, n_node);
        if obj.Options.DistributeParamWeights
            % variables are defined at all collocation nodes if
            % distributes the weightes
            node_list = 1:n_node;
        else
            % otherwise only define at the first node
            node_list = 1;
        end
        
        for i=node_list
            h{i} = {NlpVariable(...
                'Name', 'h', 'Dimension', n_hol_constr, ...
                'lb', lb.h,  'ub', ub.h, 'x0', x0.h)};
        end
        % add to the table
        obj.Phase{phase_idx}.OptVarTable = [...
            obj.Phase{phase_idx}.OptVarTable;...
            cell2table(h,'VariableNames',col_names,'RowNames',{'H'})];
    end
    
    % Fi - impact wrenches if the discrete transition involves a rigid
    % impact
    if ~isempty(guard) && guard.DeltaOpts.ApplyImpact
        
        % the dimension of the impact wrenches equals to the the dimension
        % of the holonomic constraints of the next domain.
        next_domain  = obj.Gamma.Nodes.Domain{obj.Phase{phase_idx}.NextVertex};
        n_hol_constr = getDimension(next_domain.HolonomicConstr);
        Fi = repmat({{}},1, n_node);
        % defined at the last node
        Fi{n_node} = {NlpVariable(...
            'Name', 'impF', 'Dimension', n_hol_constr, ...
            'lb', lb.Fi,  'ub', ub.Fi, 'x0', x0.Fi)};
        
        % add to the table
        obj.Phase{phase_idx}.OptVarTable = [...
            obj.Phase{phase_idx}.OptVarTable;...
            cell2table(Fi,'VariableNames',col_names,'RowNames',{'Fi'})];
    end
    


end