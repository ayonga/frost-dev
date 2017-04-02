function obj = addRunningCost(obj, func, deps)
    % Add a running cost to the problem
    %
    % Parameters:
    % func: a symbolic function to be integrated @type SymFunction
    % deps: a list of dependent variables @type cellstr
    
    
    % basic information of NLP decision variables
    nNode  = obj.NumNode;
    vars   = obj.OptVarTable;
    if ~iscell(deps), deps = {deps}; end
    
    siz = size(func);
    assert(isa(func,'SymFunction') && prod(siz)==1,...
        'The second argument must be a scalar SymFunction object.'); %#ok<PSIZE>
    
    
    
    T  = SymVariable('ts');
    N = SymVariable('nNode');
    
    
    
    
    
    cost(nNode) = struct();
    [cost.Name] = deal(func.Name);
    [cost.Dimension] = deal(1);
    [cost.Type] = deal('Nonlinear');
    
    
    if isnan(obj.Options.ConstantTimeHorizon)
    
        dep_vars = [{T},func.Vars];
        dep_params = {N};
        [cost.AuxData] = deal(nNode);
    else
        dep_vars = func.Vars;
        dep_params = {T,N};
        [cost.AuxData] = deal([obj.Options.ConstantTimeHorizon, nNode]);
    end
    switch obj.Options.CollocationScheme
        case 'HermiteSimpson'
            cost_terminal = SymFunction([func.Name,'_terminal'],...
                ((T./(N-1))./6).*func, dep_vars, dep_params);
            cost_interior = SymFunction([func.Name,'_interior'],...
                (2.*(T./(N-1))./3).*func, dep_vars, dep_params);
            
            % first node
            cost(1).SymFun = cost_terminal;
            if isnan(obj.Options.ConstantTimeHorizon)
                dep_vars = [{vars.T(1)},cellfun(@(x)vars.(x)(1),deps,'UniformOutput',false)];
            else
                dep_vars = cellfun(@(x)vars.(x)(1),deps,'UniformOutput',false);
            end
            cost(1).DepVariables = vertcat(dep_vars{:});
            
            % last node
            cost(nNode).SymFun = cost_terminal;
            if isnan(obj.Options.ConstantTimeHorizon)
                if obj.Options.DistributeTimeVariable
                    dep_vars = [{vars.T(nNode)},cellfun(@(x)vars.(x)(nNode),deps,'UniformOutput',false)];
                else
                    dep_vars = [{vars.T(1)},cellfun(@(x)vars.(x)(nNode),deps,'UniformOutput',false)];
                end
            else
                dep_vars = cellfun(@(x)vars.(x)(nNode),deps,'UniformOutput',false);                
            end
            cost(nNode).DepVariables = vertcat(dep_vars{:});
            
            
            % nlp function for interior nodes
            for i=2:nNode-1
                if obj.Options.DistributeTimeVariable
                    node_time = i;
                else
                    node_time = 1;
                end
                cost(i).SymFun = cost_interior;
                if isnan(obj.Options.ConstantTimeHorizon)
                    dep_vars = [{vars.T(node_time)},cellfun(@(x)vars.(x)(i),deps,'UniformOutput',false)];
                else
                    dep_vars = cellfun(@(x)vars.(x)(i),deps,'UniformOutput',false);
                end
                cost(i).DepVariables = vertcat(dep_vars{:});
            end
        case 'Trapzoidal'
            error('Not yet implemented.')
            
        case 'PseudoSpectral'
            error('Not yet implemented.')
    end
    
    
    
    obj = addCost(obj,func.Name,'all',cost);
end