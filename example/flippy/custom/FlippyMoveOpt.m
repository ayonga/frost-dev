classdef FlippyMoveOpt < HybridTrajectoryOptimization
    
    properties
        
        
    end
    
    methods
        
        function obj = FlippyMoveOpt(plant)
            
            
            %% initialize the problem
            obj = obj@HybridTrajectoryOptimization(plant);
            obj = initializeNLP(obj);
            obj = configureOptVariables(obj);
            
            
            
            %% custom specifications
            
            for k=1:1   % the number of domains
                
%                 q_initial = x_plus(1:12);
%                 dq_initial = x_plus(13:24);
                min_p_initial = 0.0;
                max_p_initial = 0.0;
                min_p_final = pi;
                max_p_final = pi;
                min_velocity = 4*pi;
                max_velocity = 4*pi;
                if obj.Options.DistributeParamWeights && obj.Options.EnableVirtualConstraint
                    obj = updateVariableProp(obj, 'P', k, 'all',...
                        'lb',[min_p_final, min_p_initial], 'ub', [max_p_final, max_p_initial]);
                    obj = updateVariableProp(obj, 'V', k, 'all',...
                        'lb',min_velocity, 'ub', max_velocity);
                else
                    obj = updateVariableProp(obj, 'P', k, 'first',...
                        'lb',[min_p_final, min_p_initial], 'ub', [max_p_final, max_p_initial]);
                    obj = updateVariableProp(obj, 'V', k, 'first',...
                        'lb',min_velocity, 'ub', max_velocity);
                end
                
                q_min  = [obj.Model.BaseDof.lower, -pi, -pi, 0, -pi, -pi, -pi];
                q_max  = [obj.Model.BaseDof.upper,  pi,  pi, pi, pi, pi, pi];
                
                dq_max = [obj.Model.BaseDof.maxVelocity, 17*ones(1,6)];
                dq_min = [obj.Model.BaseDof.minVelocity, -17*ones(1,6)];

                ddq_max = [0,0,0,0,0,0,1000,1000,1000,1000,1000,1000];
                ddq_min = [0,0,0,0,0,0,-1000,-1000,-1000,-1000,-1000,-1000];
                
                
                obj = updateVariableProp(obj, 'Qe', k, 'all', ...
                        'lb',q_min, 'ub', q_max);
                obj = updateVariableProp(obj, 'dQe', k, 'all', ...
                        'lb',dq_min, 'ub', dq_max);
                obj = updateVariableProp(obj, 'ddQe', k, 'all', ...
                        'lb',ddq_min, 'ub', ddq_max);

                
                    
%                 obj = updateVariableProp(obj, 'dQe', k, 'all', ...
%                         'lb',-10*ones(1,12), 'ub', 10*ones(1,12));
%                 obj = updateVariableProp(obj, 'U', k, 'all', ...
%                         'lb',-1000*ones(1,6), 'ub', 1000*ones(1,6));
                    
                
            end
            
            %% Configure constraints
            obj = configureConstraints(obj);
            
            %% Custom constraints
            obj = customSymFunction(obj);
            
            %% p[1] - deltapan(qf) = 0;

            var_table = obj.Phase{1}.OptVarTable;
            n_node = obj.Phase{1}.NumNode;

            if obj.Options.DistributeParamWeights
                param_node = n_node;
            else
                param_node = 1;
            end
            
            deltapanf = repmat({{}},1, n_node);
            deltapanf{n_node} = {NlpFunction(...
                'Name','deltapanf', 'Dimension',1, 'Type', 'linear',...
                'lb',0,'ub',0,'DepVariables',...
                {{var_table{'Qe',n_node}{1},var_table{'P',param_node}{1}}},...
                'Funcs', obj.Funcs.Phase{1}.deltapanf.Funcs)};
            obj.Phase{1}.ConstrTable = [...
                obj.Phase{1}.ConstrTable;...
                cell2table(deltapanf,'RowNames',{'deltapanf'},'VariableNames',...
                obj.Phase{1}.ConstrTable.Properties.VariableNames)];
            
            %% p[2] - deltapan(q0) = 0;
            deltapan0 = repmat({{}},1, n_node);
            deltapan0{1} = {NlpFunction(...
                'Name','deltapan0', 'Dimension',1, 'Type', 'linear',...
                'lb',0,'ub',0,'DepVariables',...
                {{var_table{'Qe',1}{1},var_table{'P',1}{1}}},...
                'Funcs', obj.Funcs.Phase{1}.deltapan0.Funcs)};
            obj.Phase{1}.ConstrTable = [...
                obj.Phase{1}.ConstrTable;...
                cell2table(deltapan0,'RowNames',{'deltapan0'},'VariableNames',...
                obj.Phase{1}.ConstrTable.Properties.VariableNames)];
                     

            %% end effector clearance
            
            endeffClearance = repmat({{}},1, n_node);

            endeffClearance{n_node} = {NlpFunction(...
                'Name','endeffClearance', 'Dimension', 1, 'Type', 'linear',...
                'lb',0.0,'ub',0.03,'DepVariables',...
                {{var_table{'Qe',n_node}{1}}},...
                'Funcs', obj.Funcs.Phase{1}.EndEffClearance.Funcs)};
            
            endeffClearance{1} = {NlpFunction(...
                'Name','endeffClearance', 'Dimension', 1, 'Type', 'linear',...
                'lb',0.0,'ub',0.0,'DepVariables',...
                {{var_table{'Qe',1}{1}}},...
                'Funcs', obj.Funcs.Phase{1}.EndEffClearance.Funcs)};
            
            endeffClearance{round(n_node/2)} = {NlpFunction(...
                'Name','endeffClearance', 'Dimension', 1, 'Type', 'linear',...
                'lb',0.2,'ub',0.3,'DepVariables',...
                {{var_table{'Qe',round(n_node/2)}{1}}},...
                'Funcs', obj.Funcs.Phase{1}.EndEffClearance.Funcs)};
            
            obj.Phase{1}.ConstrTable = [...
                obj.Phase{1}.ConstrTable;...
                cell2table(endeffClearance,'RowNames',{'endeffClearance'},'VariableNames',...
                obj.Phase{1}.ConstrTable.Properties.VariableNames)];    

            
            %% end eff pos x and y constraints
                        
            endeffEndX = repmat({{}},1, n_node);
            endeffEndX{1} = {NlpFunction(...
                'Name','endeffEndX', 'Dimension', 1, 'Type', 'linear',...
                'lb',0.4,'ub',0.5,'DepVariables',...
                {{var_table{'Qe',1}{1}}},...
                'Funcs', obj.Funcs.Phase{1}.EndEffEndX.Funcs)};
            endeffEndX{round(n_node)} = {NlpFunction(...
                'Name','endeffEndX', 'Dimension', 1, 'Type', 'linear',...
                'lb',0.4,'ub',0.5,'DepVariables',...
                {{var_table{'Qe',round(n_node)}{1}}},...
                'Funcs', obj.Funcs.Phase{1}.EndEffEndX.Funcs)};

            obj.Phase{1}.ConstrTable = [...
                obj.Phase{1}.ConstrTable;...
                cell2table(endeffEndX,'RowNames',{'endeffEndX'},'VariableNames',...
                obj.Phase{1}.ConstrTable.Properties.VariableNames)];  
             
                         
            endeffEndY = repmat({{}},1, n_node);
            endeffEndY{1} = {NlpFunction(...
                'Name','endeffEndY', 'Dimension', 1, 'Type', 'linear',...
                'lb',0.0,'ub',0.0,'DepVariables',...
                {{var_table{'Qe',1}{1}}},...
                'Funcs', obj.Funcs.Phase{1}.EndEffEndY.Funcs)};
            endeffEndY{round(n_node)} = {NlpFunction(...
                'Name','endeffEndY', 'Dimension', 1, 'Type', 'linear',...
                'lb',0.0,'ub',0.0,'DepVariables',...
                {{var_table{'Qe',round(n_node)}{1}}},...
                'Funcs', obj.Funcs.Phase{1}.EndEffEndY.Funcs)};

            obj.Phase{1}.ConstrTable = [...
                obj.Phase{1}.ConstrTable;...
                cell2table(endeffEndY,'RowNames',{'endeffEndY'},'VariableNames',...
                obj.Phase{1}.ConstrTable.Properties.VariableNames)];  
            
            %% Add cost function
            for i=1:1
                obj = addRunningCost(obj, i, obj.Funcs.Phase{i}.power);
            end
        end
        
        function obj = customSymFunction(obj)
            % create symbolic functions for custom constraints
            
            model = obj.Model;
            
            
            %% p[2] - deltapan(q0) = 0
            domain = obj.Gamma.Nodes.Domain{1};
            deltapan0 = SymFunction('Name', ['deltapan0']);
            deltapan0 = setPreCommands(deltapan0, ...
                ['Qe = GetQe[];',...
                'P = Vec[Table[p[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];',...
                ]);
            deltapan0 = setExpression(deltapan0,...
                [domain.PhaseVariable.Var.Dependents{1}.Symbols.Kin,' - p[2]']);
            deltapan0 = setDepSymbols(deltapan0,{'Qe','P'});
            deltapan0 = setDescription(deltapan0,'p[2] - deltapan0(q0) = 0');
            obj.Funcs.Phase{1}.deltapan0 = deltapan0;
            %% p[1] - deltapan(qf) = 0
            domain = obj.Gamma.Nodes.Domain{1};
            deltapanf = SymFunction('Name', ['deltapanf']);
            deltapanf = setPreCommands(deltapanf, ...
                ['Qe = GetQe[];',...
                'P = Vec[Table[p[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];',...
                ]);
            deltapanf = setExpression(deltapanf,...
                [domain.PhaseVariable.Var.Dependents{1}.Symbols.Kin,' - p[1]']);
            deltapanf = setDepSymbols(deltapanf,{'Qe','P'});
            deltapanf = setDescription(deltapanf,'p[1] - deltapanf(qf) = 0');
            obj.Funcs.Phase{1}.deltapanf = deltapanf;
             
 
            %% end effector clearance
            EndEffClearance = SymFunction('Name', ['endeffclearance_sca']);
            EndEffClearance = setPreCommands(EndEffClearance, ...
                ['Qe = GetQe[]; ']);
            EndEffClearance = setExpression(EndEffClearance,...
                [model.KinObjects.EndEffHeight.Symbols.Kin]);
            EndEffClearance = setDepSymbols(EndEffClearance,{'Qe'});
            EndEffClearance = setDescription(EndEffClearance,'end effector clearance');
            obj.Funcs.Phase{1}.EndEffClearance = EndEffClearance;
            
            
            EndEffEndX = SymFunction('Name', ['endeffendx']);
            EndEffEndX = setPreCommands(EndEffEndX, ...
                ['Qe = GetQe[]; ']);
            EndEffEndX = setExpression(EndEffEndX,...
                [model.KinObjects.EndEffPosX.Symbols.Kin]);
            EndEffEndX = setDepSymbols(EndEffEndX,{'Qe'});
            EndEffEndX = setDescription(EndEffEndX,'end effector end position x');
            obj.Funcs.Phase{1}.EndEffEndX = EndEffEndX;
            
            EndEffEndY = SymFunction('Name', ['endeffendy']);
            EndEffEndY = setPreCommands(EndEffEndY, ...
                ['Qe = GetQe[]; ']);
            EndEffEndY = setExpression(EndEffEndY,...
                [model.KinObjects.EndEffPosY.Symbols.Kin]);
            EndEffEndY = setDepSymbols(EndEffEndY,{'Qe'});
            EndEffEndY = setDescription(EndEffEndY,'end effector end position y');
            obj.Funcs.Phase{1}.EndEffEndY = EndEffEndY;
        end
        
        
        function obj = loadInitialGuess(obj, plant)
            % load initial guess from a simulated results
            for k = 1:numel(obj.Phase)
                calcs = plant.Flow{k};
                param = plant.Gamma.Nodes.Param{k};
                n_node = obj.Phase{k}.NumNode;
%                 hbar = feval(obj.Gamma.Nodes.Domain{k}.HolonomicConstr.Funcs.Kin,calcs.qe(:,1));
                
                obj = updateVariableProp(obj, 'T', k, 'first', 'x0', calcs.t(end));
                for i=1:n_node
                    obj = updateVariableProp(obj, 'Qe', k, i, 'x0',calcs.qe(:,i));
                    obj = updateVariableProp(obj, 'dQe', k, i, 'x0',calcs.dqe(:,i));
                    obj = updateVariableProp(obj, 'ddQe', k, i, 'x0',calcs.ddqe(:,i));
                    obj = updateVariableProp(obj, 'U', k, i, 'x0',calcs.u(:,i));
                    obj = updateVariableProp(obj, 'Fe', k, i, 'x0',calcs.Fe(:,i));
                end
                obj = updateVariableProp(obj, 'P', k, 'first', 'x0',param.p(:));
                obj = updateVariableProp(obj, 'V', k, 'first', 'x0',param.v(:));
                a = param.a';
                obj = updateVariableProp(obj, 'A', k, 'first', 'x0',a(:));
%                 obj = updateVariableProp(obj, 'H', k, 'first', 'x0',hbar);
            end
        end
    end
    
    
end