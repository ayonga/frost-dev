function obj = addTimeVariable(obj, bounds)
    % Adds time as the NLP decision variables to the problem
    %
    % Parameters:
    %  bounds: a structed data stores the boundary information of the
    %  NLP variables @type struct
    
    
    
    t_var = struct();
    t_var.Name = 'T';
    t_var.Dimension = 2;
    t_var.lb = zeros(2,1);
    t_var.ub = ones(2,1);
    t_var.x0 = [0;1];
    if isfield(bounds, 't0')
        if isfield(bounds.t0,'lb')
            t_var.lb(1) = bounds.t0.lb;
        end
        if isfield(bounds.t0,'ub')
            t_var.ub(1) = bounds.t0.ub;
        end
        if isfield(bounds.t0,'x0')
            t_var.x0(1) = bounds.t0.x0;
        end
    end
    
    if isfield(bounds, 'tf')
        if isfield(bounds.tf,'lb')
            t_var.lb(2) = bounds.tf.lb;
        end
        if isfield(bounds.tf,'ub')
            t_var.ub(2) = bounds.tf.ub;
        end
        if isfield(bounds.tf,'x0')
            t_var.x0(2) = bounds.tf.x0;
        end
    end
    
    
    
    % determines the nodes at which the variables to be defined.
    if obj.Options.DistributeTimeVariable
        % time variables are defined at all nodes if distributes the weightes
        obj = addVariable(obj, 'all', t_var);
        
        % add an equality constraint between the time variable at
        % neighboring nodes to make sure they are same
        Ti  = SymVariable('ti',[2,1]);
        Tn  = SymVariable('tn',[2,1]);
        t_cont = SymFunction('tCont',Ti-Tn,{Ti,Tn});
        
        % create an array of constraints structure
        constr = repmat(NlpFunction(),obj.NumNode-1,1);
        for i=1:obj.NumNode-1
            dep_vars = [obj.OptVarTable.T(i);obj.OptVarTable.T(i+1)];
            constr(i) = NlpFunction(t_cont, dep_vars, 'lb', 0, 'ub', 0);            
        end
        
        % add to the NLP constraints table
        obj = addConstraint(obj,'except-last',t_cstr);
    else
        % otherwise only define at the first node
        obj = addVariable(obj, 'first', t_var);
    end
    
    if isfield(bounds,'duration')
        % only impose at the first node
        T  = SymVariable('t',[2,1]);
        timeDuration = SymFunction('timeDuration',flatten(T(2)-T(1)),{T});
        
        if isfield(bounds.duration','lb')
            lb = bounds.duration.lb;
        else
            lb = 0;
        end
        if isfield(bounds.duration','ub')
            ub = bounds.duration.ub;
        else
            ub = inf;
        end
        
        addNodeConstraint(obj, 'first', timeDuration, {'T'}, lb, ub);
   
    end
    

end
