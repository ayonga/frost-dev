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
    
    
    num_node = obj.Phase{phase}.NumNode;
    col_names = obj.Phase{phase}.OptVarTable.Properties.VariableNames;
    domain = obj.Phase{phase}.Domain;
    
    
    
    
    if obj.Options.DistributeParamWeights
        % state variables are defined at all collocation nodes if
        % distributes the weightes
        nodeList = 1:num_node;
    else
        % otherwise only define at the first node
        nodeList = 1;
    end
    
    %% Phase variable parameters (p)
    if isa(domain.PhaseVariable.Var, 'KinematicExpr')
        if ~isempty(domain.PhaseVariable.Var.Parameters)
            n_p = domain.PhaseVariable.Var.Parameters.Dimension;
            
            % create an array of ''p'' NlpVariable objects
            p = create_object_array('NlpVariable', num_node, nodeList, ...
                'Name', 'p', 'Dimension', n_p, ...
                'lb', lb.p, 'ub', ub.p, 'x0', x0.p);
            
            % add to the decision variable table
            obj.Phase{phase}.OptVarTable = [...
                obj.Phase{phase}.OptVarTable;...
                array2table(p,'VariableNames',col_names,'RowNames',{'p'})];
        end
    end
    
    %% velocity outputs (v)
    if ~isempty(domain.DesVelocityOutput)
        
        n_v = domain.DesVelocityOutput.NumParam;
        
        % create an array of ''v'' NlpVariable objects
        v = create_object_array('NlpVariable', num_node, nodeList, ...
            'Name', 'v', 'Dimension', n_v, ...
            'lb', lb.v, 'ub', ub.v, 'x0', x0.v);
        
        obj.Phase{phase}.OptVarTable = [...
            obj.Phase{phase}.OptVarTable;...
            array2table(v,'VariableNames',col_names,'RowNames',{'v'})];
    end
    
    %% position outputs (a)
    
    n_pos_outputs = getDimension(domain.ActPositionOutput);
    n_a = n_pos_outputs*domain.DesPositionOutput.NumParam*n_pos_outputs;
    a = create_object_array('NlpVariable', num_node, nodeList, ...
        'Name', 'a', 'Dimension', n_a,...
        'lb', lb.a, 'ub', ub.a, 'x0', x0.a);
    obj.Phase{phase}.OptVarTable = [...
        obj.Phase{phase}.OptVarTable;...
        array2table(a,'VariableNames',col_names,'RowNames',{'a'})];
    


end