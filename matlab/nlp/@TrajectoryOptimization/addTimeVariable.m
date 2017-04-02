function obj = addTimeVariable(obj, bounds)
    % Adds time as the NLP decision variables to the problem
    %
    % Parameters:
    %  bounds: a structed data stores the boundary information of the
    %  NLP variables @type struct
    
    if ~isnan(obj.Options.ConstantTimeHorizon)
        error('CANNOT add time as NLP variables when using constant time horizon.');
    end
    
    t_var = struct();
    t_var.Name = 'T';
    t_var.Dimension = 1;
    if isfield(bounds,'duration')
        if isfield(bounds.duration','lb')
            t_var.lb = bounds.duration.lb;
        else
            t_var.lb = 0;
        end
        if isfield(bounds.duration','ub')
            t_var.ub = bounds.duration.ub;
        else
            t_var.ub = 2;
        end
        if isfield(bounds.duration','x0')
            t_var.x0 = bounds.duration.x0;
        else
            t_var.x0 = 1;
        end
    end
    
    % determines the nodes at which the variables to be defined.
    if obj.Options.DistributeTimeVariable
        % time variables are defined at all nodes if distributes the weightes
        obj = addVariable(obj, 'T', 'all', t_var);
        
        % add an equality constraint between the time variable at
        % neighboring nodes to make sure they are same
        Ti  = SymVariable('ti');
        Tn  = SymVariable('tn');
        t_cont = SymFunction('tCont',flatten(Ti-Tn),{Ti,Tn});
        
        % create an array of constraints structure
        t_cstr(obj.NumNode-1) = struct();
        [t_cstr.Name] = deal(t_cont.Name);
        [t_cstr.Dimension] = deal(1);
        [t_cstr.lb] = deal(0);
        [t_cstr.ub] = deal(0);
        [t_cstr.Type] = deal('Linear');
        [t_cstr.SymFun] = deal(t_cont);
        for i=1:obj.NumNode-1
            t_cstr(i).DepVariables = [obj.OptVarTable.T(i);obj.OptVarTable.T(i+1)];
        end
        
        % add to the NLP constraints table
        obj = addConstraint(obj,'tCont','except-last',t_cstr);
    else
        % otherwise only define at the first node
        obj = addVariable(obj, 'T', 'first', t_var);
    end
    

end
