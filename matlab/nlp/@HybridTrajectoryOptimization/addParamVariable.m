function obj = addParamVariable(obj, phase, lb, ub, x0)
    % Adds virtual constraint parameters as the NLP decision variables to
    % the problem
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % model: the rigid body model of the robot @type RigidBodyModel
    % lb: the lower bound of the parameters @type struct
    % ub: the upper bound of the parameters @type struct
    % x0: the typical initial value of the parameters @type struct
    
    
    % use default values if not given explicitly
    if nargin < 3
        lb = struct('p',0,...
            'v', 0.0, ...
            'a', -100);        
    end
    
    if nargin < 4
        ub = struct('p',1,...
            'v', 1.0, ...
            'a', 100);
    end
    
    if nargin < 4
        x0 = struct('p',0.5,...
            'v', 0.5, ...
            'a', 1);
    end
    
    
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};


    n_node = phase_info.NumNode;
    col_names = phase_info.OptVarTable.Properties.VariableNames;

    domain = phase_info.Domain;
    
    
    
    
    if obj.Options.DistributeParamWeights
        % state variables are defined at all collocation nodes if
        % distributes the weightes
        node_list = 1:n_node;
    else
        % otherwise only define at the first node
        node_list = 1;
    end
    
    %% Phase variable parameters (p)
    if isa(domain.PhaseVariable.Var, 'KinematicExpr')
        if ~isempty(domain.PhaseVariable.Var.Parameters)
            n_p = domain.PhaseVariable.Var.Parameters.Dimension;
            p  = repmat({{}},1, n_node);
            % create an array of ''p'' NlpVariable objects
            for i=node_list
                p{i} = {NlpVariable( ...
                    'Name', 'p', 'Dimension', n_p, ...
                    'lb', lb.p, 'ub', ub.p, 'x0', x0.p)};
            end
            % add to the decision variable table
            obj.Phase{phase_idx}.OptVarTable = [...
                obj.Phase{phase_idx}.OptVarTable;...
                cell2table(p,'VariableNames',col_names,'RowNames',{'P'})];
        end
    end
    
    %% velocity outputs (v)
    if ~isempty(domain.DesVelocityOutput)
        
        n_v = domain.DesVelocityOutput.NumParam;
        v = repmat({{}},1, n_node);
        % create an array of ''v'' NlpVariable objects
        for i=node_list
            v{i} = {NlpVariable( ...
                'Name', 'v', 'Dimension', n_v, ...
                'lb', lb.v, 'ub', ub.v, 'x0', x0.v)};
        end
        obj.Phase{phase_idx}.OptVarTable = [...
            obj.Phase{phase_idx}.OptVarTable;...
            cell2table(v,'VariableNames',col_names,'RowNames',{'V'})];
    end
    
    %% position outputs (a)
    
    n_pos_outputs = getDimension(domain.ActPositionOutput);
    n_a = n_pos_outputs*domain.DesPositionOutput.NumParam;
    
    a = repmat({{}},1, n_node);
    for i=node_list
        a{i} = {NlpVariable(...
            'Name', 'a', 'Dimension', n_a,...
            'lb', lb.a, 'ub', ub.a, 'x0', x0.a)};
    end
    
    obj.Phase{phase_idx}.OptVarTable = [...
        obj.Phase{phase_idx}.OptVarTable;...
        cell2table(a,'VariableNames',col_names,'RowNames',{'A'})];
    


end