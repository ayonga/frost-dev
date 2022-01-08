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
        param_var = params.(p_name);
        if isfield(bounds,p_name)
            param_bound = bounds.(p_name);
            lb = [];
            ub = [];
            x0 = [];
            if isfield(param_bound,'lb')
                lb = param_bound.lb(:);
            end
            if isfield(param_bound,'ub')
                ub = param_bound.ub(:);
            end
            if isfield(param_bound,'x0')
                x0 = param_bound.x0(:);
            end
        end
        % determines the nodes at which the variables to be defined.
        if obj.Options.DistributeParameters
            % time variables are defined at all nodes if distributes the weightes
            obj = addVariable(obj, 'all', param_var, 'lb', lb, 'ub', ub, 'x0', x0);
            
            % add an equality constraint between the time variable at
            % neighboring nodes to make sure they are same
            p   = flatten(param_var);
            siz = length(p);
            pn  = SymVariable([p_name 'n'],siz);
            p_cont = SymFunction([p_name 'Cont_' obj.Plant.Name],transpose(p-pn),{p,pn});
            % create an array of constraints structure
            
            p_cstr = repmat(NlpFunction(), obj.NumNode-1, 1);
            for i=1:obj.NumNode-1
                dep_vars = [obj.OptVarTable.(p_name)(i);obj.OptVarTable.(p_name)(i+1)];
                p_cstr(i) = NlpFunction(p_cont, dep_vars, 'lb', 0, 'ub', 0);
            end
            
            % add to the NLP constraints table
            obj = addConstraint(obj,'except-last',p_cstr);
        
        
        else
            % otherwise only define at the first node
            obj = addVariable(obj, 'first', param_var, 'lb', lb, 'ub', ub, 'x0', x0);
        end
        
        
    end
    
    
    


end