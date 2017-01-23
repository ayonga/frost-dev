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
    
    
    num_node = obj.Phase{phase}.NumNode;
    col_names = obj.Phase{phase}.OptVarTable.Properties.VariableNames;
    domain = obj.Phase{phase}.Domain;
    guard = obj.Phase{phase}.Guard;
    
    % h - the constant value of the holonomic kinematic constraints
    if ~isempty(domain.HolonomicConstr)
        n_hol_constr = getDimension(domain.HolonomicConstr);
        h = cell(1,num_node);
        % defined at the first node
        h{1} = NlpVariable(...
            'Name', 'h', 'Dimension', n_hol_constr, ...
            'lb', lb.h,  'ub', ub.h, 'x0', x0.h);
        
        % add to the table
        obj.Phase{phase}.OptVarTable = [...
            obj.Phase{phase}.OptVarTable;...
            cell2table(h,'VariableNames',col_names,'RowNames',{'h'})];
    end
    
    % Fi - impact wrenches if the discrete transition involves a rigid
    % impact
    if guard.DeltaOpts.ApplyImpact
        
        % the dimension of the impact wrenches equals to the the dimension
        % of the holonomic constraints of the next domain.
        next_domain  = obj.Phase{phase+1}.Domain;
        n_hol_constr = getDimension(next_domain.HolonomicConstr);
        Fi = cell(1,num_node);
        % defined at the last node
        Fi{num_node} = NlpVariable(...
            'Name', 'impF', 'Dimension', n_hol_constr, ...
            'lb', lb.Fi,  'ub', ub.Fi, 'x0', x0.Fi);
        
        % add to the table
        obj.Phase{phase}.OptVarTable = [...
            obj.Phase{phase}.OptVarTable;...
            cell2table(Fi,'VariableNames',col_names,'RowNames',{'Fi'})];
    end
    


end