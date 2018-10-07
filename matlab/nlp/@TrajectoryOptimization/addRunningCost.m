function obj = addRunningCost(obj, func, deps, auxdata, load_path)
    % Add a running cost to the problem
    %
    % Parameters:
    % func: a symbolic function to be integrated @type SymFunction
    % deps: a list of dependent variables @type cellstr
    % auxdata: auxilary constant data to be feed in the function 
    % @type double
    
    % basic information of NLP decision variables
    nNode  = obj.NumNode;
    vars   = obj.OptVarTable;
    if ~iscell(deps), deps = {deps}; end
    
    assert(isa(func,'SymFunction'),...
        'The second argument must be a SymFunction object.'); %#ok<PSIZE>
    
    if nargin < 4
        auxdata = [];
    else
        if ~iscell(auxdata), auxdata = {auxdata}; end
    end
    if nargin < 5
        load_path = [];
    end
    
    T  = [SymVariable('t0');SymVariable('tf')];
    Ts = T(2) - T(1);
    % N = SymVariable('nNode');
    w = SymVariable('w'); % weight
    
    if isnan(obj.Options.ConstantTimeHorizon)    
        s_dep_vars = [{T},func.Vars];
        deps = [{'T'},deps(:)'];
        s_dep_params = [func.Params,{w}];
    else
        s_dep_vars = func.Vars;
        s_dep_params = [func.Params,{T,w}];
    end
    
    if isempty(load_path)
        cost_integral = SymFunction([func.Name,'_integral'],...
            tovector(w.*Ts.*func), s_dep_vars, s_dep_params);
    else
        cost_integral = SymFunction([func.Name,'_integral'],...
            [], s_dep_vars, s_dep_params);
        load(cost_integral,load_path);
    end
    
    siz = size(cost_integral);
    assert(prod(siz)==1,...
        'The cost function must be a scalar function.'); %#ok<PSIZE>
    
    cost(nNode) = struct();
    [cost.Name] = deal(func.Name);
    [cost.Dimension] = deal(1);
    [cost.SymFun] = deal(cost_integral);
    % [cost.Type] = deal('Nonlinear');
    
    
    
    
    % configure weights
    switch obj.Options.CollocationScheme
        case 'HermiteSimpson'
            nGrid = floor(nNode/2);
            % nlp function for interior nodes
            for i=1:nNode
                if i==1 || i==nNode
                    weight = 1/(6*nGrid);
                else
                    weight = 2/(3*nGrid);
                end
                
                if isnan(obj.Options.ConstantTimeHorizon)                    
                    cost(i).AuxData = [auxdata,{weight}];
                else
                    cost(i).AuxData = [auxdata, {obj.Options.ConstantTimeHorizon, weight}];
                end
            end
        case 'Trapezoidal'
            nGrid = nNode - 1;
            % nlp function for interior nodes
            for i=1:nNode
                if i==1 || i==nNode
                    weight = 1/(2*nGrid);
                else
                    weight = 1/(1*nGrid);
                end
                
                if isnan(obj.Options.ConstantTimeHorizon)                    
                    cost(i).AuxData = [auxdata,{weight}];
                else
                    cost(i).AuxData = [auxdata, {obj.Options.ConstantTimeHorizon, weight}];
                end
            end
            
        case 'PseudoSpectral'
            t = sym('t');
            p = legendreP(nNode-1,t);
            dp = jacobian(p,t);
            
            roots = vpasolve(dp*(1-t)*(1+t)==0);
            
            for i = 1:nNode
                weight = double(1/((nNode-1)*nNode*(subs(p,t,roots(i)))^2));
                
                if isnan(obj.Options.ConstantTimeHorizon)                    
                    cost(i).AuxData = [auxdata,{weight}];
                else
                    cost(i).AuxData = [auxdata, {obj.Options.ConstantTimeHorizon, weight}];
                end
            end
    end
    
    % dependent variables
    for i = 1:nNode
        dep_vars = cellfun(@(x)get_dep_vars(obj.Plant, vars, obj.Options, x, i),deps,'UniformOutput',false);
        cost(i).DepVariables = vertcat(dep_vars{:});
    end
    
    obj = addCost(obj,func.Name,'all',cost);
    
    function var = get_dep_vars(plant, vars, options, x, idx)
        
        if strcmp(x,'T') && ~options.DistributeTimeVariable % time variable
            var = vars.(x)(1);
        elseif isParam(plant, x) && ~options.DistributeParameters
            var = vars.(x)(1);
        else
            var = vars.(x)(idx);
        end
        
    end
end