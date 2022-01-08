function obj = addRunningCost(obj, func, deps, auxdata)
    % Add a running cost to the problem
    %
    % Parameters:
    % func: a symbolic function to be integrated @type SymFunction
    % deps: a list of dependent variables @type cellstr
    % auxdata: auxilary constant data to be feed in the function 
    % @type double
    arguments
        obj        
        func (1,1) SymFunction
        deps (:,1) cell
        auxdata cell = {}
    end
    
    % basic information of NLP decision variables
    
    vars   = obj.OptVarTable;
    
    
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
        auxdata = [auxdata, {obj.Options.ConstantTimeHorizon}];
    end
    
    cost_integral = SymFunction([func.Name,'_integral'],...
            tovector(w.*Ts.*func), s_dep_vars, s_dep_params);
    
    nNode = obj.NumNode;
    cost = repmat(NlpFunction(),nNode,1);
    for i=1:nNode
        dep_vars = cellfun(@(x)get_dep_vars(obj.Plant, vars, obj.Options, x, i),deps,'UniformOutput',false);        
        cost(i) = NlpFunction(cost_integral, [dep_vars{:}]);
    end
    
    
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
                setAuxdata(cost(i), [auxdata,{weight}]);
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
                
                setAuxdata(cost(i), [auxdata,{weight}]);
            end
            
        case 'PseudoSpectral'
            t = sym('t');
            p = legendreP(nNode-1,t);
            dp = jacobian(p,t);
            
            roots = vpasolve(dp*(1-t)*(1+t)==0);
            
            for i = 1:nNode
                weight = double(1/((nNode-1)*nNode*(subs(p,t,roots(i)))^2));
                
                setAuxdata(cost(i), [auxdata,{weight}]);
            end
    end
    
    
    obj = addCost(obj,'all',cost);
    
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