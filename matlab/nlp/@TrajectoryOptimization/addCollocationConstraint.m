function obj = addCollocationConstraint(obj)
    % Add direct collocation equations as a set of equality constraints
    
    
    
    
    % basic information of NLP decision variables
    nNode  = obj.NumNode;
    vars   = obj.OptVarTable;
    plant  = obj.Plant;
    nState = plant.numState;
    
    
    
    ceq_err_bound = obj.Options.EqualityConstraintBoundary;
    
    
    
    
    
    switch obj.Options.CollocationScheme
        case 'HermiteSimpson' % Hermite-Simpson Scheme
            % collocation constraints are enforced at all interior nodes
            node_list = 2:2:nNode-1;
            
            hs_int_x = directCollocation(obj, 'x', plant.States.x, plant.States.dx);
            % construct a structure array of collocation constraints
            int_x_cstr(numel(node_list)) = struct();
            [int_x_cstr.Name] = deal(hs_int_x.Name);
            [int_x_cstr.Dimension] = deal(2*nState);
            [int_x_cstr.lb] = deal(-ceq_err_bound);
            [int_x_cstr.ub] = deal(ceq_err_bound);
            [int_x_cstr.SymFun] = deal(hs_int_x);
            
            
            if isnan(obj.Options.ConstantTimeHorizon)
                [int_x_cstr.Type] = deal('Nonlinear');
                % The number of node being auxilary constant
                [int_x_cstr.AuxData] = deal({nNode});
                % specify the dependent variables
                for i=1:numel(node_list)
                    idx = node_list(i);
                    if obj.Options.DistributeTimeVariable
                        node_time = idx;
                    else
                        node_time = 1;
                    end
                    
                    int_x_cstr(i).DepVariables = [vars.T(node_time);... % time
                        vars.x(idx-1);vars.dx(idx-1);...      % states at previous cardinal node
                        vars.x(idx);vars.dx(idx);...          % states at a interior node
                        vars.x(idx+1);vars.dx(idx+1)];        % states at next cardinal node
                    
                    
                end
            else
                [int_x_cstr.Type] = deal('Linear');
                % Both the constant time duration and the number of
                % node being auxilary constants
                [int_x_cstr.AuxData] = deal({obj.Options.ConstantTimeHorizon, nNode});
                % specify the dependent variables
                for i=1:numel(node_list)
                    idx = node_list(i);
                    
                    int_x_cstr(i).DepVariables = [...
                        vars.x(idx-1);vars.dx(idx-1);...      % states at previous cardinal node
                        vars.x(idx);vars.dx(idx);...         % states at a interior node
                        vars.x(idx+1);vars.dx(idx+1)];        % states at next cardinal node
                    
                    
                    
                end
            end
            % add to the NLP constraints table
            obj = addConstraint(obj,'intX','interior',int_x_cstr);
            
            if strcmp(plant.Type,'SecondOrder') 
                % gets the symbolic expression (function) of the
                % collocation constraints
                hs_int_dx = directCollocation(obj, 'dx', plant.States.dx, plant.States.ddx);
                int_dx_cstr(numel(node_list)) = struct();
                [int_dx_cstr.Name] = deal(hs_int_dx.Name);
                [int_dx_cstr.Dimension] = deal(nState*2);
                [int_dx_cstr.lb] = deal(-ceq_err_bound);
                [int_dx_cstr.ub] = deal(ceq_err_bound);
                [int_dx_cstr.SymFun] = deal(hs_int_dx);
                
                
                
                if isnan(obj.Options.ConstantTimeHorizon)
                    % The number of node being auxilary constant
                    [int_dx_cstr.AuxData] = deal({nNode});
                    [int_dx_cstr.Type] = deal('Nonlinear');
                    % specify the dependent variables
                    for i=1:numel(node_list)
                        idx = node_list(i);
                        if obj.Options.DistributeTimeVariable
                            node_time = idx;
                        else
                            node_time = 1;
                        end
                        
                        int_dx_cstr(i).DepVariables = [vars.T(node_time);... % time
                            vars.dx(idx-1);vars.ddx(idx-1);...      % states at previous cardinal node
                            vars.dx(idx); vars.ddx(idx);...         % states at a interior node
                            vars.dx(idx+1);vars.ddx(idx+1)];        % states at next cardinal node
                        
                    end
                else
                    [int_dx_cstr.Type] = deal('Linear');
                    % Both the constant time duration and the number of
                    % node being auxilary constants
                    [int_dx_cstr.AuxData] = deal({obj.Options.ConstantTimeHorizon, nNode});
                    % specify the dependent variables
                    for i=1:numel(node_list)
                        idx = node_list(i);
                        
                        
                        int_dx_cstr(i).DepVariables = [...
                            vars.dx(idx-1);vars.ddx(idx-1);...      % states at previous cardinal node
                            vars.dx(idx); vars.ddx(idx);...         % states at a interior node
                            vars.dx(idx+1);vars.ddx(idx+1)];        % states at next cardinal node
                        
                    end
                end
                
                % add to the NLP constraints table
                obj = addConstraint(obj,'intXdot','interior',int_dx_cstr);
            end
                
            
            
           
        case 'Trapezoidal'
            % collocation constraints are enforced at all nodes except
            % the last node
            node_list = 1:1:nNode-1;
            
            
            tr_int_x = directCollocation(obj, 'x', plant.States.x, plant.States.dx);
            % construct a structure array of collocation constraints
            int_x_cstr(numel(node_list)) = struct();
            [int_x_cstr.Name] = deal(tr_int_x.Name);
            [int_x_cstr.Dimension] = deal(nState);
            [int_x_cstr.lb] = deal(-ceq_err_bound);
            [int_x_cstr.ub] = deal(ceq_err_bound);
            [int_x_cstr.SymFun] = deal(tr_int_x);
            
            
            if isnan(obj.Options.ConstantTimeHorizon)
                [int_x_cstr.Type] = deal('Nonlinear');
                % The number of node being auxilary constant
                [int_x_cstr.AuxData] = deal({nNode});
                % specify the dependent variables
                for i=1:numel(node_list)
                    idx = node_list(i);
                    if obj.Options.DistributeTimeVariable
                        node_time = idx;
                    else
                        node_time = 1;
                    end
                    
                    int_x_cstr(i).DepVariables = [vars.T(node_time);... % time
                        vars.x(idx);vars.dx(idx);...          % states at a interior node
                        vars.x(idx+1);vars.dx(idx+1)];        % states at next cardinal node
                    
                    
                end
            else
                [int_x_cstr.Type] = deal('Linear');
                % Both the constant time duration and the number of
                % node being auxilary constants
                [int_x_cstr.AuxData] = deal({obj.Options.ConstantTimeHorizon, nNode});
                % specify the dependent variables
                for i=1:numel(node_list)
                    idx = node_list(i);
                    
                    int_x_cstr(i).DepVariables = [...
                        vars.x(idx);vars.dx(idx);...         % states at a interior node
                        vars.x(idx+1);vars.dx(idx+1)];        % states at next cardinal node
                    
                    
                    
                end
            end
            % add to the NLP constraints table
            obj = addConstraint(obj,'intX','except-last',int_x_cstr);
            
            if strcmp(plant.Type,'SecondOrder') 
                % gets the symbolic expression (function) of the
                % collocation constraints
                tr_int_dx = directCollocation(obj, 'dx', plant.States.dx, plant.States.ddx);
                int_dx_cstr(numel(node_list)) = struct();
                [int_dx_cstr.Name] = deal(tr_int_dx.Name);
                [int_dx_cstr.Dimension] = deal(nState);
                [int_dx_cstr.lb] = deal(-ceq_err_bound);
                [int_dx_cstr.ub] = deal(ceq_err_bound);
                [int_dx_cstr.SymFun] = deal(tr_int_dx);
                
                
                
                if isnan(obj.Options.ConstantTimeHorizon)
                    % The number of node being auxilary constant
                    [int_dx_cstr.AuxData] = deal({nNode});
                    [int_dx_cstr.Type] = deal('Nonlinear');
                    % specify the dependent variables
                    for i=1:numel(node_list)
                        idx = node_list(i);
                        if obj.Options.DistributeTimeVariable
                            node_time = idx;
                        else
                            node_time = 1;
                        end
                        
                        int_dx_cstr(i).DepVariables = [vars.T(node_time);... % time
                            vars.dx(idx); vars.ddx(idx);...         % states at a interior node
                            vars.dx(idx+1);vars.ddx(idx+1)];        % states at next cardinal node
                        
                    end
                else
                    [int_dx_cstr.Type] = deal('Linear');
                    % Both the constant time duration and the number of
                    % node being auxilary constants
                    [int_dx_cstr.AuxData] = deal({obj.Options.ConstantTimeHorizon, nNode});
                    % specify the dependent variables
                    for i=1:numel(node_list)
                        idx = node_list(i);
                        
                        
                        int_dx_cstr(i).DepVariables = [...
                            vars.dx(idx); vars.ddx(idx);...         % states at a interior node
                            vars.dx(idx+1);vars.ddx(idx+1)];        % states at next cardinal node
                        
                    end
                end
                
                % add to the NLP constraints table
                obj = addConstraint(obj,'intXdot','except-last',int_dx_cstr);
                
            end
            
        case 'PseudoSpectral'
            % PS constraint is only enforced at the single node 
            
            ps_int_x = directCollocation(obj, 'x', plant.States.x, plant.States.dx);
            % construct a structure of the collocation constraint
            int_x_cstr = struct();
            int_x_cstr.Name = deal(ps_int_x.Name);
            int_x_cstr.Dimension = nNode*nState;
            int_x_cstr.lb = -ceq_err_bound;
            int_x_cstr.ub = ceq_err_bound;
            int_x_cstr.SymFun = ps_int_x;
            
            if obj.Options.DistributeTimeVariable
                warning('There is no need to distribute time variable with PseudoSpectral method. Set ''DistributeTimeVariable'' option to ''false''.');
            end
            if isnan(obj.Options.ConstantTimeHorizon)
                int_x_cstr.Type = 'Nonlinear';
                
                dep_x = [vars.x'; vars.dx'];
                int_x_cstr.DepVariables = [vars.T(1);... % time
                    dep_x(:)]; % states
                
            else
                int_x_cstr.Type = 'Linear';
                % Both the constant time duration and the number of
                % node being auxilary constants
                int_x_cstr.AuxData = {obj.Options.ConstantTimeHorizon};
                % specify the dependent variables
                dep_x = [vars.x'; vars.dx'];
                int_x_cstr.DepVariables = dep_x(:); % states
            end
            % add to the NLP constraints table
            obj = addConstraint(obj,'intX','first',int_x_cstr);
            
            if strcmp(plant.Type,'SecondOrder') 
                % gets the symbolic expression (function) of the
                % collocation constraints
                ps_int_dx = directCollocation(obj, 'dx', plant.States.dx, plant.States.ddx);
                % construct a structure of the collocation constraint
                int_dx_cstr = struct();
                int_dx_cstr.Name = deal(ps_int_dx.Name);
                int_dx_cstr.Dimension = nNode*nState;
                int_dx_cstr.lb = -ceq_err_bound;
                int_dx_cstr.ub = ceq_err_bound;
                int_dx_cstr.SymFun = ps_int_dx;
                
                if obj.Options.DistributeTimeVariable
                    warning('There is no need to distribute time variable with PseudoSpectral method. Set ''DistributeTimeVariable'' option to ''false''.');
                end
                if isnan(obj.Options.ConstantTimeHorizon)
                    int_dx_cstr.Type = 'Nonlinear';
                    
                    dep_dx = [vars.dx'; vars.ddx'];
                    int_dx_cstr.DepVariables = [vars.T(1);... % time
                        dep_dx(:)]; % states
                    
                else
                    int_dx_cstr.Type = 'Linear';
                    % Both the constant time duration and the number of
                    % node being auxilary constants
                    int_dx_cstr.AuxData = {obj.Options.ConstantTimeHorizon};
                    % specify the dependent variables
                    dep_dx = [vars.dx'; vars.ddx'];
                    int_dx_cstr.DepVariables = dep_dx(:); % states
                end
                % add to the NLP constraints table
                obj = addConstraint(obj,'intXdot','first',int_dx_cstr);
            end
        otherwise
            error('Unsupported collocation scheme');
    end
    
    
    
end




