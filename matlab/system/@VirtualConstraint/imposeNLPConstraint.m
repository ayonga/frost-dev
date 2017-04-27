function nlp = imposeNLPConstraint(obj, nlp, ep, nzy)
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
    
    if nargin > 2
        validateattributes(ep, {'double'},...
            {'vector','numel',rel_deg,'positive','real'},...
            'VirtualConstraint.imposeNLPConstraint','ep');
    else
        warning('The coefficient vector (ep) of outputs are not defined. Use 1 for all derivatives.');
        ep = ones(1,rel_deg);
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
    a = {SymVariable(tomatrix(obj.OutputParams(:)))};   
    a_name = obj.OutputParamName;
    
    % phat variable parameters and its name in the var table of the NLP
    if ~isempty(obj.PhaseParams)
        p = {SymVariable(tomatrix(obj.PhaseParams(:)))};
        p_name = obj.PhaseParamName;
    else
        p = {};
        p_name = {};
    end
    
    % states and their name representation in the var table of the NLP
    switch model.Type
        case 'FirstOrder'
            x = {model.States.x};
            dx = {model.States.dx};
            x_name = {'x'};
            dx_name = {'dx'};
            
            
            dX = model.States.dx;
        case 'SecondOrder'
            x = {model.States.x, model.States.dx};
            dx = {model.States.ddx};
            x_name = {'x','dx'};
            dx_name = {'ddx'};
            
            dX = [model.States.dx; model.States.ddx];
    end
    
    % if the desired outputs are time-based, get the function for
    % converting the horizon time T to the actual node time t
    if ~is_state_based
        t = SymVariable('t');
        k = SymVariable('k');
        T  = SymVariable('T');
        nNode = SymVariable('N');
        tsubs = ((k-1)/(nNode-1))*T;
    end
    
    y_fun = cell(rel_deg+1,1);
    
    
    %% y(x,a,p) = 0
    if nzy(1)==1
        y = ya{1} - yd{1};
        if is_state_based
            %% state-based output, no need to use time variable
            if is_holonomic
                % holonomic virtual constraints
                y_fun{1} = SymFunction(['y_' name], y, [{model.States.x},a,p]);
                % add constraint at the first node
                nlp = addNodeConstraint(nlp, y_fun{1}, [{'x'},a_name, p_name], 'first',...
                    0, 0, 'Nonlinear');
            else
                % non-holonomic constraints
                y_fun{1} = SymFunction(['y_' name], y, [{model.States.x, model.States.dx},a,p]);
                % add constraint at the first node
                nlp = addNodeConstraint(nlp, y_fun{1}, [{'x','dx'},a_name, p_name], 'first',...
                    0, 0, 'Nonlinear');
            end
        else
            %% Time-based outputs, need to incoorporates the time variable
            y = subs(y,t,tsubs);
            if ~isnan(nlpOptions.ConstantTimeHorizon) % constant horizon
                if is_holonomic
                    % holonomic virtual constraints
                    y_fun{1} = SymFunction(['y_' name], y, [{model.States.x},a], {T,k,nNode});
                    % add constraint at the first node
                    nlp = addNodeConstraint(nlp, y_fun{1}, [{'x'},a_name], 'first',...
                        0, 0, 'Nonlinear',{nlpOptions.ConstantTimeHorizon,1,n_node});
                else
                    % non-holonomic constraints
                    y_fun{1} = SymFunction(['y_' name], y, [{model.States.x, model.States.dx},a], {T,k,nNode});
                    % add constraint at the first node
                    nlp = addNodeConstraint(nlp, y_fun{1}, [{'x','dx'},a_name], 'first',...
                        0, 0, 'Nonlinear',{nlpOptions.ConstantTimeHorizon,1,n_node});
                end
            else
                if is_holonomic
                    % holonomic virtual constraints
                    y_fun{1} = SymFunction(['y_' name], y, [{T, model.States.x},a], {k,nNode});
                    % add constraint at the first node
                    nlp = addNodeConstraint(nlp, y_fun{1}, [{'T','x'},a_name], 'first',...
                        0, 0, 'Nonlinear',{1,n_node});
                else
                    % non-holonomic constraints
                    y_fun{1} = SymFunction(['y_' name], y, [{T, model.States.x, model.States.dx}, a], {k,nNode});
                    % add constraint at the first node
                    nlp = addNodeConstraint(nlp, y_fun{1}, [{'T','x','dx'},a_name], 'first',...
                        0, 0, 'Nonlinear',{1,n_node});
                end
                
            end
        end
    end
    
        
    %% higher order derivatives
    if rel_deg > 1
        if is_state_based
            for i=2:rel_deg     
                if nzy(i) == 1
                    dy = ya{i} - yd{i};
                    %% state-based output, no need to use time variable
                    y_fun{i} = SymFunction(['d' num2str(i-1) 'y_' name], dy, [x,a,p]);
                    % add constraint at the first node
                    
                    nlp = addNodeConstraint(nlp, y_fun{i}, [x_name,a_name, p_name], 'first',...
                        0, 0, 'Nonlinear');
                end
            end
        else
            for i=2:rel_deg     
                if nzy(i) == 1
                    dy = ya{i} - yd{i};
                    %% Time-based outputs, need to incoorporates the time variable
                    dy = subs(dy,t,tsubs);
                    if ~isnan(nlpOptions.ConstantTimeHorizon) % constant horizon
                        y_fun{i} = SymFunction(['d' num2str(i-1) 'y_' name], dy, [x,a], {T,k,nNode});
                        % add constraint at the first node
                        
                        nlp = addNodeConstraint(nlp, y_fun{i}, [x_name,a_name], 'first',...
                            0, 0, 'Nonlinear',{nlpOptions.ConstantTimeHorizon,1,n_node});
                        
                    else
                        y_fun{i} = SymFunction(['d' num2str(i-1) 'y_' name], dy, [{T}, x, a], {k,nNode});
                        % add constraint at the first node
                        nlp = addNodeConstraint(nlp, y_fun{i}, [{'T'},x_name,a_name], 'first',...
                            0, 0, 'Nonlinear',{1,n_node});
                    end
                end
            end
        end
        
    end
    
    %% the highest order derivatives imposed at all nodes (feedback linearization) 
    node_list = 1:1:n_node;
    dim = obj.Dimension;
    vars   = nlp.OptVarTable;
    ceq_err_bound = nlpOptions.EqualityConstraintBoundary;   
    
    y_dynamics(1,n_node) = NlpFunction();
    
    if is_state_based
        %% state-based output, no need to use time variable
        ddy = (ya{rel_deg+1} - yd{rel_deg+1})*dX;
        for j=1:1:rel_deg
            ddy = ddy + ep(j)*(ya{j} - yd{j});
        end
        ddy_fun = SymFunction(['d' num2str(rel_deg) 'y_' name], ddy, [x,dx,a,p]);
        
        
        for i=node_list
            idx = node_list(i);
            if nlpOptions.DistributeParameters
                a_deps = vars.(a_name)(idx);
                if ~isempty(p_name)
                    p_deps = vars.(p_name)(idx);
                else
                    p_deps = {};
                end
            else
                a_deps = vars.(a_name)(1);
                if ~isempty(p_name)
                    p_deps = vars.(p_name)(1);
                else
                    p_deps = {};
                end
            end
            x_deps = cellfun(@(x)vars.(x)(idx),x_name,'UniformOutput',false);
            dx_deps = cellfun(@(x)vars.(x)(idx),dx_name,'UniformOutput',false);
            
            y_dynamics(i) = NlpFunction('Name',[obj.Name '_output_dynamics'],...
                'Dimension',dim,'SymFun',ddy_fun,'lb',-ceq_err_bound,...
                'ub',ceq_err_bound,'Type','Nonlinear',...
                'DepVariables',[x_deps{:}, dx_deps{:}, a_deps, p_deps]');
            
            
        end
        
        
        
            
    else
        %% Time-based outputs, need to incoorporates the time variable
        ddy = ya{rel_deg+1}*dX - yd{rel_deg+1};
        ddy = subs(ddy,t,tsubs);
        for j=1:1:rel_deg
            ddy = ddy + ep(j)*(ya{j} - yd{j});
        end
        
        if ~isnan(nlpOptions.ConstantTimeHorizon) % constant horizon
            ddy_fun= SymFunction(['d' num2str(rel_deg) 'y_' name], ddy, [x,dx,a], {T,k,nNode});
            
            for i=node_list
                idx = node_list(i);
                if nlpOptions.DistributeParameters
                    a_deps = vars.(a_name)(idx);
                else
                    a_deps = vars.(a_name)(1);
                end
                x_deps = cellfun(@(x)vars.(x)(idx),x_name,'UniformOutput',false);
                dx_deps = cellfun(@(x)vars.(x)(idx),dx_name,'UniformOutput',false);
                
                y_dynamics(i) = NlpFunction('Name',[obj.Name '_output_dynamics'],...
                    'Dimension',dim,'SymFun',ddy_fun,'Type','Nonlinear',...
                    'lb',-ceq_err_bound,'ub',ceq_err_bound,...
                    'DepVariables',[x_deps{:}, dx_deps{:}, a_deps]',...
                    'AuxData',{{nlpOptions.ConstantTimeHorizon,i,n_node}});
                
                
            end
            
        else
            ddy_fun= SymFunction(['d' num2str(rel_deg) 'y_' name], ddy, [T, x,dx,a], {k,nNode});
            
            for i=node_list
                idx = node_list(i);
                if nlpOptions.DistributeParameters
                    a_deps = vars.(a_name)(idx);
                else
                    a_deps = vars.(a_name)(1);
                end
                if nlpOptions.DistributeTimeVariable
                    t_deps = vars.T(idx);
                else
                    t_deps = vars.T(1);
                end
                
                x_deps = cellfun(@(x)vars.(x)(idx),x_name,'UniformOutput',false);
                dx_deps = cellfun(@(x)vars.(x)(idx),dx_name,'UniformOutput',false);
                y_dynamics(i) = NlpFunction('Name',[obj.Name '_output_dynamics'],...
                    'Dimension',dim,'SymFun',ddy_fun,'Type','Nonlinear',...
                    'lb',-ceq_err_bound,'ub',ceq_err_bound,...
                    'DepVariables',[t_deps, x_deps{:}, dx_deps{:}, a_deps]',...
                    'AuxData',{{i,n_node}});
            end
            
            
        end
        
        
    end
    % add output dynamics at all nodes
    % add dynamical equation constraints
    nlp = addConstraint(nlp,[obj.Name '_output_dynamics'],'all',y_dynamics);
        
    
end