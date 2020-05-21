function nlp = rigidImpactConstraint(obj, nlp, src, tar, bounds, varargin)
    % Impose system specific constraints as NLP constraints for the
    % trajectory optimization problem
    %
    % Parameters:
    % nlp: an trajectory optimization NLP object of the system
    % @type TrajectoryOptimization
    % src: the NLP of the source domain system
    % @type TrajectoryOptimization
    % tar: the NLP of the target domain system
    % @type TrajectoryOptimization
    % bounds: a struct data contains the boundary values @type struct
    % varargin: extra argument @type varargin
    
    
    
    addNodeConstraint(nlp, obj.xMap, {'x','xn'}, 'first', 0, 0, 'Linear');
    cstr_name = fieldnames(obj.ImpactConstraints);
    
    % the velocities determined by the impact constraints
    if isempty(cstr_name)
        % by default, identity map
        
        
        addNodeConstraint(nlp, obj.dxMap, {'dx','dxn'}, 'first', 0, 0, 'Linear');
    else
        vars   = nlp.OptVarTable;
        dep_vars = [vars.dx(1);vars.xn(1);vars.dxn(1)];
        numState = vars.dx(1).Dimension;
        %% impact constraints
        cstr = obj.ImpactConstraints;
        n_cstr = numel(cstr_name);
        for i=1:n_cstr
            c_name = cstr_name{i};
            input_name = cstr.(c_name).InputName;
            dep_vars = [dep_vars;vars.(input_name)(1)];
        end
        
        n_fun = numel(obj.dxMap);
        
        
        dep_funcs(n_fun,1) = NlpFunction();   % preallocation
        for i=1:n_fun
            dep_funcs(i) = NlpFunction('Name',obj.dxMap{i}.Name,...
                'Dimension',numState,'SymFun',obj.dxMap{i},...
                'DepVariables',dep_vars);
        end
      
        
        dxMap_cstr_fun = NlpFunction('Name','dxMap',...
            'Dimension',numState,'lb',0,'ub',0,...
            'Type','Nonlinear','Summand',dep_funcs);
        
        % add dynamical equation constraints
        addConstraint(nlp,'dxMap','first',dxMap_cstr_fun);
        
        
        
    end
    
end
