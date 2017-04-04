function obj = addParamVariable(obj, bounds)
    % Adds parameters as the NLP decision variables to the problem
    %
    % Parameters:
    %  bounds: a structed data stores the boundary information of the
    %  NLP variables @type struct
    
    

    
    % get basic information of the variables
    params = obj.Plant.Params;
    
    param_names = fieldnames(params);
    
    
    for j=1:length(param_names)
        
        p_name = param_names{j};
        
        var = struct();
        var.Name = p_name;
        siz = size(params.(p_name));
        var.Dimension = prod(siz); %#ok<PSIZE>
        if isfield(bounds,p_name)
            if isfield(bounds.(p_name),'lb')
                var.lb = bounds.(p_name).lb;
            end
            if isfield(bounds.(p_name),'ub')
                var.ub = bounds.(p_name).ub;
            end
            if isfield(bounds.(p_name),'x0')
                var.x0 = bounds.(p_name).x0;
            end
        end
        % determines the nodes at which the variables to be defined.
        if obj.Options.DistributeParameters
            % time variables are defined at all nodes if distributes the weightes
            obj = addVariable(obj, p_name, 'all', var);
            
            % add an equality constraint between the time variable at
            % neighboring nodes to make sure they are same
            p   = flatten(params.(p_name));
            siz = size(p);
            pn  = SymVariable([p_name 'n'],siz);
            p_cont = SymFunction([p_name 'Cont_' obj.Plant.Name],transpose(p-pn),{p,pn});
            % create an array of constraints structure
            p_cstr = struct();
            p_cstr(obj.NumNode-1) = struct();
            [p_cstr.Name] = deal(p_cont.Name);
            [p_cstr.Dimension] = deal(var.Dimension);
            [p_cstr.lb] = deal(0);
            [p_cstr.ub] = deal(0);
            [p_cstr.Type] = deal('Linear');
            [p_cstr.SymFun] = deal(p_cont);
            for i=1:obj.NumNode-1
                p_cstr(i).DepVariables = [obj.OptVarTable.(p_name)(i);obj.OptVarTable.(p_name)(i+1)];
            end
            
            % add to the NLP constraints table
            obj = addConstraint(obj,[p_name 'Cont'],'except-last',p_cstr);
        
        
        else
            % otherwise only define at the first node
            obj = addVariable(obj, p_name, 'first', var);
        end
        
        
    end
    
    
    


end