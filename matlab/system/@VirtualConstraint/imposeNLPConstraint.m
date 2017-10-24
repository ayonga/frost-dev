function nlp = imposeNLPConstraint(obj, nlp, ep, nzy, load_path)
    % impose virtual constraints as NLP constraints in the trajectory
    % optimization problem 'nlp' of the dynamical system 
    %
    % For each (vector) virtual constraints, we will enforce the following
    % constraints at the first node:
    % {y, y', ..., y^N} % where N = RelativeDegree - 1
    % and this constraint:
    % y^(N+1) + ep_N y^N + ... ep_1 y = 0
    % at all nodes.
    %
    % Parameters:
    % nlp: the trajectory optimization NLP @type TrajectoryOptimization
    % ep: the coefficients of the derivatives @type rowvec
    % nzy: the derivatives that does not requires to be zero at the first
    % node @type rowvec
    %
    % @note For example, ep = [kp, kd] for typical vector relative degree 2
    % holonomic virtual constraints.
    %
    % @note For example, nzy = [0] for a relative degree 1 nonholonomic
    % virtual constraint (velocity outputs) means we do not require y to
    % be zero at the first node. Another example, nzy = [0,0] for a
    % relative degree 2 virtual constraints, we do not require both y and
    % y' to be zero at the first node, on the other hand, nzy = [1,0] for a
    % relative degree 2 virtual constraints, we only enforce y being zero
    % at the first node.
    
    if nargin < 5
        load_path = [];
    end
    
    % local variables for speed
    rel_deg = obj.RelativeDegree;
    is_holonomic = obj.Holonomic;
    is_state_based = strcmp(obj.PhaseType, 'StateBased');
    model = obj.Model;
    ya = obj.ActualFuncs;
    yd = obj.DesiredFuncs;
    
    assert(~isempty(ya) || ~isempty(yd),...
        'The virtual constraint functions are not compiled yet. Please run compile method first.');
    
    %% validate input arguments
    validateattributes(nlp, {'NonlinearProgram'},...
        {'scalar'},'VirtualConstraint.imposeNLPConstraint',...
        'nlp');
    nlpOptions = nlp.Options;
    n_node     = nlp.NumNode;
    %%
    if strcmp(nlpOptions.CollocationScheme,'PseudoSpectral')
        error('The PseudoSpectral is incompatible with virtual constraints.');
    end
    
    if nargin > 2
        validateattributes(ep, {'double'},...
            {'vector','numel',rel_deg,'positive','real'},...
            'VirtualConstraint.imposeNLPConstraint','ep');
    else
        warning('The coefficient vector (ep) of outputs are not defined. Use 1 for all derivatives.');
        ep = ones(1,rel_deg);
        for l= 1:rel_deg
            ep(l) = nchoosek(rel_deg,l-1)*10^(rel_deg - l + 1);
        end
    end
    if nargin > 3
        validateattributes(nzy, {'double'},...
            {'vector','numel',rel_deg,'binary'},...
            'VirtualConstraint.imposeNLPConstraint','nzy');
    else
        nzy = ones(1,rel_deg);
        
        
    end
    
    % the name suffix of functions
    name = [obj.Name '_' model.Name];
    
    % desired output parameters and its name in the var table of the NLP
    if isa(obj.OutputParams,'SymVariable')        
        a_var = {SymVariable(tomatrix(obj.OutputParams(:)))};
        a_name = obj.OutputParamName;
    else
        a_var = {};
        a_name = {};
    end
    
    % phase variable parameters and its name in the var table of the NLP
    if isa(obj.PhaseParams,'SymVariable')
        p_var = {SymVariable(tomatrix(obj.PhaseParams(:)))};
        p_name = obj.PhaseParamName;
    else
        p_var = {};
        p_name = {};
    end
    
    % offset variable parameters and its name in the var table of the NLP
    if isa(obj.OffsetParams,'SymVariable')
        c_var = {SymVariable(tomatrix(obj.OffsetParams(:)))};
        c_name = obj.OffsetParamName;
    else
        c_var = {};
        c_name = {};
    end
    
    
    % states and their name representation in the var table of the NLP
    switch model.Type
        case 'FirstOrder'
            x_var = {model.States.x};
            dx_var = {model.States.dx};
            x_name = {'x'};
            dx_name = {'dx'};
            
            
            dX = model.States.dx;
        case 'SecondOrder'
            x_var = {model.States.x, model.States.dx};
            dx_var = {model.States.ddx};
            x_name = {'x','dx'};
            dx_name = {'ddx'};
            
            dX = [model.States.dx; model.States.ddx];
    end
    
    if is_holonomic
        q_var = {model.States.x};
        q_name = {'x'};
    else
        q_var = {model.States.x,model.States.dx};
        q_name = {'x','dx'};
    end
    
    
    
    % if the desired outputs are time-based, get the function for
    % converting the horizon time T to the actual node time t
    if is_state_based
        t_var = {};
        t_name = {};
        aux_var = {};
    else
        t = SymVariable('t');
        k = SymVariable('k');
        T  = SymVariable('t',[2,1]);
        nNode = SymVariable('nNode');
        tsubs = T(1) + ((k-1)./(nNode-1)).*(T(2)-T(1));
        
        if ~isnan(nlpOptions.ConstantTimeHorizon)
            t_var = {};
            t_name = {};
            aux_var = {T,k,nNode};
        else
            t_var = {T};
            t_name = 'T';
            aux_var = {k,nNode};
        end
    end
    
    y_fun = cell(rel_deg+1,1);
    
    
    %% y(x,a,p) = 0
    if nzy(1)==1
        if isempty(load_path)
            y = ya{1} - yd{1};
            if ~is_state_based
                %% Time-based outputs, need to incoorporates the time variable
                y = subs(y,t,tsubs);
            end
            
            % holonomic virtual constraints
            y_fun{1} = SymFunction(['y_' name], y, [t_var, q_var, a_var, p_var, c_var], aux_var);
        else
            % holonomic virtual constraints
            y_fun{1} = SymFunction(['y_' name], [], [t_var, q_var, a_var, p_var, c_var], aux_var);
            y_fun{1} = load(y_fun{1},load_path);
        end
        if ~isempty(aux_var)
            switch length(aux_var)
                case 2
                    % k, nNode
                    aux_data = {1,n_node};
                    
                case 3
                    % T, k, nNode
                    aux_data = {nlpOptions.ConstantTimeHorizon, 1,n_node};
                    
            end
        else
            aux_data = [];
        end
        % add constraint at the first node
        nlp = addNodeConstraint(nlp, y_fun{1}, [t_name, q_name ,a_name, p_name, c_name], 'first',...
            0, 0, 'Nonlinear', aux_data);
        
    end
    
        
    %% higher order derivatives
    if rel_deg > 1
        
        for i=2:rel_deg     
            if nzy(i) == 1
                %% state-based output, no need to use time variable
                if isempty(load_path)
                    dy = ya{i} - yd{i};
                    if ~is_state_based
                        %% Time-based outputs, need to incoorporates the time variable
                        dy = subs(dy,t,tsubs);
                    end
                    y_fun{i} = SymFunction(['d' num2str(i-1) 'y_' name], dy, [t_var, x_var, a_var, p_var], aux_var);
                else
                    y_fun{i} = SymFunction(['d' num2str(i-1) 'y_' name], [], [t_var, x_var, a_var, p_var], aux_var);
                    y_fun{i} = load(y_fun{i}, load_path);
                end
                % add constraint at the first node
                
                nlp = addNodeConstraint(nlp, y_fun{i}, [t_name, x_name ,a_name, p_name], 'first',...
                    0, 0, 'Nonlinear', aux_data);
            end
        end
    end
        
        
        
    
    %% the highest order derivatives imposed at all nodes (feedback linearization) 
    node_list = 1:1:n_node;
    dim = obj.Dimension;
    vars   = nlp.OptVarTable;
    ceq_err_bound = nlpOptions.EqualityConstraintBoundary;   
    
    y_dynamics(1,n_node) = NlpFunction();
    
    if isempty(load_path)
        % state-based output, no need to use time variable
        if is_state_based
            ddy = (ya{rel_deg+1} - yd{rel_deg+1})*dX;
        else
            ddy = ya{rel_deg+1}*dX - yd{rel_deg+1};
        end
        
        ep_s = SymVariable('k',[rel_deg,1]);
        
        for j=1:1:rel_deg
            ddy = ddy + ep_s(j)*(ya{j} - yd{j});
        end
        % Time-based outputs, need to incoorporates the time variable
        if ~is_state_based
            ddy = subs(ddy,t,tsubs);
        end
        
        
        ddy_fun = SymFunction(['d' num2str(rel_deg) 'y_' name], ddy, [t_var, x_var, dx_var, a_var, p_var, c_var], [aux_var,{ep_s}]);
    else        
        ep_s = SymVariable('k',[rel_deg,1]);
        
        ddy_fun = SymFunction(['d' num2str(rel_deg) 'y_' name], [], [t_var, x_var, dx_var, a_var, p_var, c_var], [aux_var,{ep_s}]);
        ddy_fun = load(ddy_fun, load_path);
        
    end
        
        
        
        
    for i=node_list
        idx = node_list(i);
        if nlpOptions.DistributeParameters
            param_index = idx;
        else
            param_index = 1;
        end
        
        if ~isempty(a_name)
            a_deps = vars.(a_name)(param_index);
        else
            a_deps = {};
        end
        if ~isempty(p_name)
            p_deps = vars.(p_name)(param_index);
        else
            p_deps = {};
        end
        if ~isempty(c_name)
            c_deps = vars.(c_name)(param_index);
        else
            c_deps = {};
        end
        
        if nlpOptions.DistributeTimeVariable
            time_index = idx;
        else
            time_index = 1;
        end
        
        if ~isempty(t_name)
            t_deps = vars.(t_name)(time_index);
        else
            t_deps = {};
        end
        if ~isempty(aux_var)
            switch length(aux_var)
                case 2
                    % k, nNode
                    aux_data = {idx,n_node};
                    
                case 3
                    % T, k, nNode
                    aux_data = {nlpOptions.ConstantTimeHorizon, idx,n_node};
                    
            end
        else
            aux_data = [];
        end
        x_deps = cellfun(@(x)vars.(x)(idx),x_name,'UniformOutput',false);
        dx_deps = cellfun(@(x)vars.(x)(idx),dx_name,'UniformOutput',false);
        
        y_dynamics(i) = NlpFunction('Name',[obj.Name '_output_dynamics'],...
            'Dimension',dim,'SymFun',ddy_fun,'lb',-ceq_err_bound,...
            'ub',ceq_err_bound,'Type','Nonlinear',...
            'DepVariables',[t_deps, x_deps{:}, dx_deps{:}, a_deps, p_deps, c_deps]',...
            'AuxData', {[aux_data,{ep}]});
        
    end
        
        
    obj.OutputFuncs = [y_fun;{ddy_fun}];
    %     obj.OutputFuncsName_ = cellfun(@(f)f.Name, obj.OutputFuncs,'UniformOutput',false);
    
    % add output dynamics at all nodes
    % add dynamical equation constraints
    nlp = addConstraint(nlp,[obj.Name '_output_dynamics'],'all',y_dynamics);
    
    
end