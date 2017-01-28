function obj = addParamVariable(obj, phase, a_props, v_props, p_props)
    % Adds virtual constraint parameters as the NLP decision variables to
    % the problem
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % model: the rigid body model of the robot @type RigidBodyModel
    % a_props: properties of parameter ''a'' @type struct
    % v_props: properties of parameter ''v'' @type struct
    % p_props: properties of parameter ''v'' @type struct
    %
    % Required fields of a_props:
    % lb: the lower bound of the parameters @type struct
    % ub: the upper bound of the parameters @type struct
    % x0: the typical initial value of the parameters @type struct
    %
    % Required fields of v_props:
    % lb: the lower bound of the parameters @type struct
    % ub: the upper bound of the parameters @type struct
    % x0: the typical initial value of the parameters @type struct
    %
    % Required fields of p_props:
    % lb: the lower bound of the parameters @type struct
    % ub: the upper bound of the parameters @type struct
    % x0: the typical initial value of the parameters @type struct
    
    % use default values if not given explicitly
    if nargin < 3
        a_props = struct('lb',-100,'ub',100,'x0',1);       
    end
    
    if nargin < 4
        v_props = struct('lb',0,'ub',1,'x0',0.1);
    end
    
    if nargin < 5
        p_props = struct('lb',-1,'ub',1,'x0',0.2);
    end
    
    
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};


    n_node = phase_info.NumNode;
    col_names = phase_info.OptVarTable.Properties.VariableNames;

    domain = obj.Gamma.Nodes.Domain{phase_info.CurrentVertex};
    
    
    
    
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
            p_props.Name = 'p';
            p_props.Dimension = n_p;
            for i=node_list
                p{i} = {NlpVariable(p_props)};
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
        v_props.Name = 'v';
        v_props.Dimension = n_v;
        for i=node_list
            v{i} = {NlpVariable(v_props)};
        end
        obj.Phase{phase_idx}.OptVarTable = [...
            obj.Phase{phase_idx}.OptVarTable;...
            cell2table(v,'VariableNames',col_names,'RowNames',{'V'})];
    end
    
    %% position outputs (a)
    
    n_pos_outputs = getDimension(domain.ActPositionOutput);
    n_a = n_pos_outputs*domain.DesPositionOutput.NumParam;
    
    a = repmat({{}},1, n_node);
    a_props.Name = 'a';
    a_props.Dimension = n_a;
    for i=node_list
        a{i} = {NlpVariable(a_props)};
    end
    
    obj.Phase{phase_idx}.OptVarTable = [...
        obj.Phase{phase_idx}.OptVarTable;...
        cell2table(a,'VariableNames',col_names,'RowNames',{'A'})];
    


end