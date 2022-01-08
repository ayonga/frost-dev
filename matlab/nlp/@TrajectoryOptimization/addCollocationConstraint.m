function obj = addCollocationConstraint(obj)
    % Add direct collocation equations as a set of equality constraints
    
    
    
    
    % basic information of NLP decision variables
    nNode  = obj.NumNode;
    vars   = obj.OptVarTable;
    plant  = obj.Plant;
    
    
    
    switch obj.Options.CollocationScheme
        case 'HermiteSimpson' % Hermite-Simpson Scheme
            % collocation constraints are enforced at all interior nodes
            node_list = 2:2:nNode-1;
            n_node = numel(node_list);
            
            hs_int_x = directCollocation(obj, ['x_',plant.Name], plant.Dimension);
            % construct a structure array of collocation constraints
            int_x_cstr = repmat(NlpFunction(),n_node,1);
            
            
            
            if isnan(obj.Options.ConstantTimeHorizon)
                % specify the dependent variables
                for i=1:numel(node_list)
                    idx = node_list(i);
                    if obj.Options.DistributeTimeVariable
                        node_time = idx;
                    else
                        node_time = 1;
                    end
                    
                    dep_vars = [vars.T(node_time);... % time
                        vars.x(idx-1);vars.dx(idx-1);...      % states at previous cardinal node
                        vars.x(idx);vars.dx(idx);...          % states at a interior node
                        vars.x(idx+1);vars.dx(idx+1)];        % states at next cardinal node
                    int_x_cstr(i) = NlpFunction(hs_int_x, dep_vars, 'lb', 0, 'ub', 0, 'AuxData', {nNode});
                    
                end
            else
                % specify the dependent variables
                for i=1:numel(node_list)
                    idx = node_list(i);
                    
                    dep_vars = [...
                        vars.x(idx-1);vars.dx(idx-1);...      % states at previous cardinal node
                        vars.x(idx);vars.dx(idx);...         % states at a interior node
                        vars.x(idx+1);vars.dx(idx+1)];        % states at next cardinal node
                    
                    int_x_cstr(i) = NlpFunction(hs_int_x, dep_vars, 'lb', 0, 'ub', 0, ...
                        'AuxData', {obj.Options.ConstantTimeHorizon, nNode});
                    
                end
            end
            % add to the NLP constraints table
            obj = addConstraint(obj,'interior',int_x_cstr);
            
            if strcmp(plant.Type,'SecondOrder') 
                % gets the symbolic expression (function) of the
                % collocation constraints
                hs_int_dx = directCollocation(obj, ['dx_',plant.Name], plant.Dimension);
                int_dx_cstr = repmat(NlpFunction(),n_node,1);
                
                
                
                if isnan(obj.Options.ConstantTimeHorizon)
                    % specify the dependent variables
                    for i=1:numel(node_list)
                        idx = node_list(i);
                        if obj.Options.DistributeTimeVariable
                            node_time = idx;
                        else
                            node_time = 1;
                        end
                        
                        dep_vars = [vars.T(node_time);... % time
                            vars.dx(idx-1);vars.ddx(idx-1);...      % states at previous cardinal node
                            vars.dx(idx); vars.ddx(idx);...         % states at a interior node
                            vars.dx(idx+1);vars.ddx(idx+1)];        % states at next cardinal node
                        int_dx_cstr(i) = NlpFunction(hs_int_dx, dep_vars, 'lb', 0, 'ub', 0, 'AuxData', {nNode});
                    end
                else
                    % specify the dependent variables
                    for i=1:numel(node_list)
                        idx = node_list(i);
                        dep_vars = [...
                            vars.dx(idx-1);vars.ddx(idx-1);...      % states at previous cardinal node
                            vars.dx(idx); vars.ddx(idx);...         % states at a interior node
                            vars.dx(idx+1);vars.ddx(idx+1)];        % states at next cardinal node
                        int_dx_cstr(i) = NlpFunction(hs_int_dx, dep_vars, 'lb', 0, 'ub', 0, ...
                            'AuxData', {obj.Options.ConstantTimeHorizon, nNode});
                    end
                end
                
                % add to the NLP constraints table
                obj = addConstraint(obj,'interior',int_dx_cstr);
            end
                
            
            
           
        case 'Trapezoidal'
            % collocation constraints are enforced at all nodes except
            % the last node
            node_list = 1:1:nNode-1;
            n_node = numel(node_list);
            
            tr_int_x = directCollocation(obj, ['x_',plant.Name], plant.Dimension);
            % construct a structure array of collocation constraints
            int_x_cstr = repmat(NlpFunction(),n_node,1);
            
            
            
            if isnan(obj.Options.ConstantTimeHorizon)
                % specify the dependent variables
                for i=1:numel(node_list)
                    idx = node_list(i);
                    if obj.Options.DistributeTimeVariable
                        node_time = idx;
                    else
                        node_time = 1;
                    end
                    
                    dep_vars = [vars.T(node_time);... % time
                        vars.x(idx);vars.dx(idx);...          % states at a interior node
                        vars.x(idx+1);vars.dx(idx+1)];        % states at next cardinal node
                    int_x_cstr(i) = NlpFunction(tr_int_x, dep_vars, 'lb', 0, 'ub', 0, 'AuxData', {nNode});
                    
                end
            else
                % specify the dependent variables
                for i=1:numel(node_list)
                    idx = node_list(i);
                    
                    dep_vars = [...
                        vars.x(idx);vars.dx(idx);...         % states at a interior node
                        vars.x(idx+1);vars.dx(idx+1)];        % states at next cardinal node
                    
                    int_x_cstr(i) = NlpFunction(tr_int_x, dep_vars, 'lb', 0, 'ub', 0, ...
                        'AuxData', {obj.Options.ConstantTimeHorizon, nNode});
                    
                end
            end
            % add to the NLP constraints table
            obj = addConstraint(obj,'except-last',int_x_cstr);
            
            if strcmp(plant.Type,'SecondOrder') 
                % gets the symbolic expression (function) of the
                % collocation constraints
                tr_int_dx = directCollocation(obj, ['dx_',plant.Name], plant.Dimension);
                int_dx_cstr = repmat(NlpFunction(),n_node,1);
                
                
                if isnan(obj.Options.ConstantTimeHorizon)
                    % specify the dependent variables
                    for i=1:numel(node_list)
                        idx = node_list(i);
                        if obj.Options.DistributeTimeVariable
                            node_time = idx;
                        else
                            node_time = 1;
                        end
                        
                        dep_vars = [vars.T(node_time);... % time
                            vars.dx(idx); vars.ddx(idx);...         % states at a interior node
                            vars.dx(idx+1);vars.ddx(idx+1)];        % states at next cardinal node
                        int_dx_cstr(i) = NlpFunction(tr_int_dx, dep_vars, 'lb', 0, 'ub', 0, 'AuxData', {nNode});
                    end
                else
                    % specify the dependent variables
                    for i=1:numel(node_list)
                        idx = node_list(i);
                        
                        
                        dep_vars = [...
                            vars.dx(idx); vars.ddx(idx);...         % states at a interior node
                            vars.dx(idx+1);vars.ddx(idx+1)];        % states at next cardinal node
                        int_dx_cstr(i) = NlpFunction(tr_int_dx, dep_vars, 'lb', 0, 'ub', 0,  ...
                            'AuxData', {obj.Options.ConstantTimeHorizon, nNode});
                    end
                end
                
                % add to the NLP constraints table
                obj = addConstraint(obj,'except-last',int_dx_cstr);
                
            end
            
        case 'PseudoSpectral'
            % PS constraint is only enforced at the single node 
            
            ps_int_x = directCollocation(obj, ['x_',plant.Name], plant.Dimension);
            % construct a structure of the collocation constraint
            
            if obj.Options.DistributeTimeVariable
                warning('There is no need to distribute time variable with PseudoSpectral method. Set ''DistributeTimeVariable'' option to ''false''.');
            end
            if isnan(obj.Options.ConstantTimeHorizon)
                
                dep_x = [vars.x'; vars.dx'];
                dep_vars = [vars.T(1);... % time
                    dep_x(:)]; % states
                int_x_cstr = NlpFunction(ps_int_x, dep_vars, 'lb', 0, 'ub', 0);
            else
                % specify the dependent variables
                dep_x = [vars.x'; vars.dx'];
                dep_vars = dep_x(:);
                int_x_cstr = NlpFunction(ps_int_x, dep_vars, 'lb', 0, 'ub', 0, ...
                    'AuxData',{obj.Options.ConstantTimeHorizon});
            end
            
            
            
            % add to the NLP constraints table
            obj = addConstraint(obj,'first',int_x_cstr);
            
            if strcmp(plant.Type,'SecondOrder') 
                ps_int_dx = directCollocation(obj, ['dx_',plant.Name], plant.Dimension);
                if obj.Options.DistributeTimeVariable
                    warning('There is no need to distribute time variable with PseudoSpectral method. Set ''DistributeTimeVariable'' option to ''false''.');
                end
                if isnan(obj.Options.ConstantTimeHorizon)
                    
                    dep_dx = [vars.dx'; vars.ddx'];
                    dep_vars = [vars.T(1);... % time
                        dep_dx(:)]; % states
                    int_dx_cstr = NlpFunction(ps_int_dx, dep_vars, 'lb', 0, 'ub', 0);
                else
                    % specify the dependent variables
                    dep_dx = [vars.dx'; vars.ddx'];
                    dep_vars = dep_dx(:); % states
                    int_dx_cstr = NlpFunction(ps_int_dx, dep_vars, 'lb', 0, 'ub', 0, ...
                        'AuxData',{obj.Options.ConstantTimeHorizon});
                end
                % add to the NLP constraints table
                obj = addConstraint(obj,'first',int_dx_cstr);
            end
        otherwise
            error('Unsupported collocation scheme');
    end
    
    
    
end




