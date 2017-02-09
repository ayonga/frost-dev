classdef Atlas3DMultiWalkingOpt < HybridTrajectoryOptimization
    
    properties
        
        
    end
    
    methods
        
        function obj = Atlas3DMultiWalkingOpt(plant)
            
            
            model = plant.Model;
            
            
            
            %% Remove Left leg stance domains
            plant = rmVertex(plant, {'LeftToeStrike', 'LeftToeLift', 'LeftHeelStrike'});
            
            %% Add a transition at the end of step to the beginning of step
            left_toe_strike_relabel = LeftToeStrikeRelabel(model);
            plant = rmEdge(plant, 'RightHeelStrike', 'RightToeStrike');
            plant = addEdge(plant, 'RightHeelStrike', 'RightToeStrike', 'Guard', left_toe_strike_relabel);
            
            %% initialize the problem
            obj = obj@HybridTrajectoryOptimization(plant);
            obj = initializeNLP(obj);
            obj = configureOptVariables(obj);
            
            
            
            %% custom specifications
            
            for k=1:3
                
                
                min_p_initial = -0.4;
                max_p_initial = -0.1;
                min_p_final = 0.1;
                max_p_final = 0.4;
                min_velocity = 0.4;
                max_velocity = 0.9;
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
                
                minStepLength= 0.35;
                maxStepLength= 0.5;
                minStepWidth = 0.17;
                maxStepWidth = 0.25;
                lt = 0.1728;
                lh = 0.082;
                switch k
                    case 1 %
                        obj = updateVariableProp(obj, 'H', k, 'first','lb',[0,0,0,0,0,0,-maxStepLength,minStepWidth,0,0,0,0,0,0]);
                        obj = updateVariableProp(obj, 'H', k, 'first','ub',[0,0,0,0,0,0,-minStepLength,maxStepWidth,0,0,0,0,0,0]);
                    case 2
                        obj = updateVariableProp(obj, 'H', k, 'first','lb',[0,0,0,0,0,0,0,0,0]);
                        obj = updateVariableProp(obj, 'H', k, 'first','ub',[0,0,0,0,0,0,0,0,0]);
                    case 3
                        obj = updateVariableProp(obj, 'H', k, 'first','lb',[0,0,0,0,0,minStepLength-(lt+lh),minStepWidth,0,0,0,0,0,0]);
                        obj = updateVariableProp(obj, 'H', k, 'first','ub',[0,0,0,0,0,maxStepLength-(lt+lh),maxStepWidth,0,0,0,0,0,0]);
                end
                
                
                
                
            end
            
            %% Configure constraints
            obj = configureConstraints(obj);
            
            %% Custom constraints
            obj = customSymFunction(obj);
            
            %% p[1] - deltaphip(qf) = 0;
            n_node = obj.Phase{3}.NumNode;
            if obj.Options.DistributeParamWeights
                param_node = n_node;
            else
                param_node = 1;
            end
            var_table = obj.Phase{3}.OptVarTable;
            deltaphipf = repmat({{}},1, n_node);
            deltaphipf{n_node} = {NlpFunction(...
                'Name','deltaphipf', 'Dimension',1, 'Type', 'linear',...
                'lb',0,'ub',0,'DepVariables',...
                {{var_table{'Qe',n_node}{1},var_table{'P',param_node}{1}}},...
                'Funcs', obj.Funcs.Phase{3}.deltaphipf.Funcs)};
            obj.Phase{3}.ConstrTable = [...
                obj.Phase{3}.ConstrTable;...
                cell2table(deltaphipf,'RowNames',{'deltaphipf'},'VariableNames',...
                obj.Phase{3}.ConstrTable.Properties.VariableNames)];
            
            % p[2] - deltaphip(q0) = 0;
            var_table = obj.Phase{1}.OptVarTable;
            n_node = obj.Phase{1}.NumNode;
            deltaphip0 = repmat({{}},1, n_node);
            deltaphip0{1} = {NlpFunction(...
                'Name','deltaphip0', 'Dimension',1, 'Type', 'linear',...
                'lb',0,'ub',0,'DepVariables',...
                {{var_table{'Qe',1}{1},var_table{'P',1}{1}}},...
                'Funcs', obj.Funcs.Phase{1}.deltaphip0.Funcs)};
            obj.Phase{1}.ConstrTable = [...
                obj.Phase{1}.ConstrTable;...
                cell2table(deltaphip0,'RowNames',{'deltaphip0'},'VariableNames',...
                obj.Phase{1}.ConstrTable.Properties.VariableNames)];
            % impact heel velocity
            var_table = obj.Phase{2}.OptVarTable;
            n_node = obj.Phase{2}.NumNode;
            impactHeelVelocity = repmat({{}},1, n_node);
            impactHeelVelocity{n_node} = {NlpFunction(...
                'Name','impactHeelVelocity', 'Dimension', 3, 'Type', 'nonlinear',...
                'lb',[-0.5,-0.3,-0.5],'ub',[ 0.5, 0.2, -0.0],'DepVariables',...
                {{var_table{'Qe',n_node}{1},var_table{'dQe',n_node}{1}}},...
                'Funcs', obj.Funcs.Phase{2}.impactHeelVelocity.Funcs)};
            obj.Phase{2}.ConstrTable = [...
                obj.Phase{2}.ConstrTable;...
                cell2table(impactHeelVelocity,'RowNames',{'impactHeelVelocity'},'VariableNames',...
                obj.Phase{2}.ConstrTable.Properties.VariableNames)];
            % impact toe velocity
            var_table = obj.Phase{3}.OptVarTable;
            n_node = obj.Phase{3}.NumNode;
            impactToeVelocity = repmat({{}},1, n_node);
            impactToeVelocity{n_node} = {NlpFunction(...
                'Name','impactToeVelocity', 'Dimension', 3, 'Type', 'nonlinear',...
                'lb',[-0.5,-0.3,-0.5],'ub',[ 0.5, 0.2, -0.0],'DepVariables',...
                {{var_table{'Qe',n_node}{1},var_table{'dQe',n_node}{1}}},...
                'Funcs', obj.Funcs.Phase{3}.impactToeVelocity.Funcs)};
            obj.Phase{3}.ConstrTable = [...
                obj.Phase{3}.ConstrTable;...
                cell2table(impactToeVelocity,'RowNames',{'impactToeVelocity'},'VariableNames',...
                obj.Phase{3}.ConstrTable.Properties.VariableNames)];
            
            % output boundary
            %% torso roll
            for i = 1:3
                var_table = obj.Phase{i}.OptVarTable;
                n_node = obj.Phase{i}.NumNode;
                torsoRoll = repmat({{}},1, n_node);
                for j=1:n_node
                    torsoRoll{j} = {NlpFunction(...
                        'Name','torsoRoll', 'Dimension', 1, 'Type', 'linear',...
                        'lb',-0.2,'ub',0.2,'DepVariables',...
                        {{var_table{'Qe',j}{1}}},...
                        'Funcs', obj.Funcs.Phase{1}.torsoRollBoundary.Funcs)};
                end
                obj.Phase{i}.ConstrTable = [...
                    obj.Phase{i}.ConstrTable;...
                    cell2table(torsoRoll,'RowNames',{'torsoRoll'},'VariableNames',...
                    obj.Phase{i}.ConstrTable.Properties.VariableNames)];
            end
            %% swing leg roll
            var_table = obj.Phase{2}.OptVarTable;
            n_node = obj.Phase{2}.NumNode;
            legRoll = repmat({{}},1, n_node);
            for j=1:n_node
                legRoll{j} = {NlpFunction(...
                    'Name','legRoll', 'Dimension', 1, 'Type', 'linear',...
                    'lb',-0.2,'ub',0.2,'DepVariables',...
                    {{var_table{'Qe',j}{1}}},...
                    'Funcs', obj.Funcs.Phase{2}.legRollBoundary.Funcs)};
            end
            obj.Phase{2}.ConstrTable = [...
                obj.Phase{2}.ConstrTable;...
                cell2table(legRoll,'RowNames',{'legRoll'},'VariableNames',...
                obj.Phase{2}.ConstrTable.Properties.VariableNames)];
            
            
            %% Heel clearance
            
            %             var_table = obj.Phase{1}.OptVarTable;
            %             n_node = obj.Phase{1}.NumNode;
            %             heelClearance = repmat({{}},1, n_node);
            %             for j=1:n_node
            %                 heelClearance{j} = {NlpFunction(...
            %                     'Name','heelClearance', 'Dimension', 1, 'Type', 'linear',...
            %                     'lb',0.02,'ub',0,'DepVariables',...
            %                     {{var_table{'Qe',j}{1}}},...
            %                     'Funcs', obj.Funcs.Phase{1}.heelClearance.Funcs)};
            %             end
            %             obj.Phase{1}.ConstrTable = [...
            %                 obj.Phase{1}.ConstrTable;...
            %                 cell2table(heelClearance,'RowNames',{'heelClearance'},'VariableNames',...
            %                 obj.Phase{1}.ConstrTable.Properties.VariableNames)];
            
            var_table = obj.Phase{2}.OptVarTable;
            n_node = obj.Phase{2}.NumNode;
            heelClearance = repmat({{}},1, n_node);
            toeClearance = repmat({{}},1, n_node);
            heelClearance{1} = {NlpFunction(...
                'Name','heelClearance', 'Dimension', 1, 'Type', 'linear',...
                'lb',0.02,'ub',1,'DepVariables',...
                {{var_table{'Qe',1}{1}}},...
                'Funcs', obj.Funcs.Phase{2}.heelClearance.Funcs)};
            heelClearance{round(n_node/2)} = {NlpFunction(...
                'Name','heelClearance', 'Dimension', 1, 'Type', 'linear',...
                'lb',0.02,'ub',1,'DepVariables',...
                {{var_table{'Qe',round(n_node/2)}{1}}},...
                'Funcs', obj.Funcs.Phase{2}.heelClearance.Funcs)};
            toeClearance{round(n_node/2)} = {NlpFunction(...
                'Name','toeClearance', 'Dimension', 1, 'Type', 'linear',...
                'lb',0.02,'ub',1,'DepVariables',...
                {{var_table{'Qe',round(n_node/2)}{1}}},...
                'Funcs', obj.Funcs.Phase{2}.toeClearance.Funcs)};
            toeClearance{n_node} = {NlpFunction(...
                'Name','toeClearance', 'Dimension', 1, 'Type', 'linear',...
                'lb',0.02,'ub',1,'DepVariables',...
                {{var_table{'Qe',n_node}{1}}},...
                'Funcs', obj.Funcs.Phase{2}.toeClearance.Funcs)};
            obj.Phase{2}.ConstrTable = [...
                obj.Phase{2}.ConstrTable;...
                cell2table(heelClearance,'RowNames',{'heelClearance'},'VariableNames',...
                obj.Phase{2}.ConstrTable.Properties.VariableNames);
                cell2table(toeClearance,'RowNames',{'toeClearance'},'VariableNames',...
                obj.Phase{2}.ConstrTable.Properties.VariableNames)];    
            %% Add cost function
            for i=1:3
                obj = addRunningCost(obj, i, obj.Funcs.Phase{i}.power);
            end
        end
        
        function obj = customSymFunction(obj)
            % create symbolic functions for custom constraints
            
            model = obj.Model;
            
            
            %% p[2] - deltaphip(q0) = 0
            domain = obj.Gamma.Nodes.Domain{1};
            deltaphip0 = SymFunction('Name', ['deltaphip0_sca']);
            deltaphip0 = setPreCommands(deltaphip0, ...
                ['Qe = GetQe[];',...
                'P = Vec[Table[p[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];',...
                ]);
            deltaphip0 = setExpression(deltaphip0,...
                [domain.PhaseVariable.Var.Dependents{1}.Symbols.Kin,' - p[2]']);
            deltaphip0 = setDepSymbols(deltaphip0,{'Qe','P'});
            deltaphip0 = setDescription(deltaphip0,'p[2] - deltaphip(q0) = 0');
            obj.Funcs.Phase{1}.deltaphip0 = deltaphip0;
            %% p[1] - deltaphip(qf) = 0
            domain = obj.Gamma.Nodes.Domain{3};
            deltaphipf = SymFunction('Name', ['deltaphipf_sca']);
            deltaphipf = setPreCommands(deltaphipf, ...
                ['Qe = GetQe[];',...
                'P = Vec[Table[p[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];',...
                ]);
            deltaphipf = setExpression(deltaphipf,...
                [domain.PhaseVariable.Var.Dependents{1}.Symbols.Kin,' - p[1]']);
            deltaphipf = setDepSymbols(deltaphipf,{'Qe','P'});
            deltaphipf = setDescription(deltaphipf,'p[1] - deltaphip(qf) = 0');
            obj.Funcs.Phase{3}.deltaphipf = deltaphipf;
            
            %% impact toe velocity
            impactToeVelocity = SymFunction('Name', ['impactToeVelocity_vec']);
            impactToeVelocity = setPreCommands(impactToeVelocity, ...
                ['Qe = GetQe[]; dQe = D[Qe,t];']);
            impactToeVelocity = setExpression(impactToeVelocity,...
                ['Join[',model.KinObjects.LeftToePosX.Symbols.Jac,',',...
                model.KinObjects.LeftToePosY.Symbols.Jac,',',...
                model.KinObjects.LeftToePosZ.Symbols.Jac,'].dQe']);
            impactToeVelocity = setDepSymbols(impactToeVelocity,{'Qe','dQe'});
            impactToeVelocity = setDescription(impactToeVelocity,'toe impact velocities in x,y,z directions');
            obj.Funcs.Phase{3}.impactToeVelocity = impactToeVelocity;
            
            %% impact heel velocity
            impactHeelVelocity = SymFunction('Name', ['impactHeelVelocity_vec']);
            impactHeelVelocity = setPreCommands(impactHeelVelocity, ...
                ['Qe = GetQe[]; dQe = D[Qe,t];']);
            impactHeelVelocity = setExpression(impactHeelVelocity,...
                ['Join[',model.KinObjects.LeftHeelPosX.Symbols.Jac,',',...
                model.KinObjects.LeftHeelPosY.Symbols.Jac,',',...
                model.KinObjects.LeftHeelPosZ.Symbols.Jac,'].dQe']);
            impactHeelVelocity = setDepSymbols(impactHeelVelocity,{'Qe','dQe'});
            impactHeelVelocity = setDescription(impactHeelVelocity,'heel impact velocities in x,y,z directions');
            obj.Funcs.Phase{2}.impactHeelVelocity = impactHeelVelocity;
            
            %% torso roll output boundary
            index = obj.Gamma.Nodes.Domain{1}.ActPositionOutput.getIndex('RightTorsoRoll');
            kin_obj = obj.Gamma.Nodes.Domain{1}.ActPositionOutput.KinGroupTable(index).KinObj;
            torsoRollBoundary = SymFunction('Name', ['torsoRollBoundary_sca']);
            torsoRollBoundary = setPreCommands(torsoRollBoundary, ...
                ['Qe = GetQe[];']);
            torsoRollBoundary = setExpression(torsoRollBoundary,...
                kin_obj.Symbols.Kin);
            torsoRollBoundary = setDepSymbols(torsoRollBoundary,{'Qe'});
            torsoRollBoundary = setDescription(torsoRollBoundary,'boundary constraints on right torso roll output');
            obj.Funcs.Phase{1}.torsoRollBoundary = torsoRollBoundary;
            
            %% leg roll output boundary
            index = obj.Gamma.Nodes.Domain{2}.ActPositionOutput.getIndex('LeftLegRoll');
            kin_obj = obj.Gamma.Nodes.Domain{2}.ActPositionOutput.KinGroupTable(index).KinObj;
            legRollBoundary = SymFunction('Name', ['legRollBoundary_sca']);
            legRollBoundary = setPreCommands(legRollBoundary, ...
                ['Qe = GetQe[];']);
            legRollBoundary = setExpression(legRollBoundary,...
                kin_obj.Symbols.Kin);
            legRollBoundary = setDepSymbols(legRollBoundary,{'Qe'});
            legRollBoundary = setDescription(legRollBoundary,'boundary constraints on left leg roll output');
            obj.Funcs.Phase{2}.legRollBoundary = legRollBoundary;
            
            
            %% heel clearance
            heelClearance = SymFunction('Name', ['heelClearance_sca']);
            heelClearance = setPreCommands(heelClearance, ...
                ['Qe = GetQe[]; ']);
            heelClearance = setExpression(heelClearance,...
                model.KinObjects.LeftHeelPosZ.Symbols.Kin);
            heelClearance = setDepSymbols(heelClearance,{'Qe'});
            heelClearance = setDescription(heelClearance,'heel clearance');
            obj.Funcs.Phase{2}.heelClearance = heelClearance;
            
            
            %% toe clearance
            toeClearance = SymFunction('Name', ['toeClearance_sca']);
            toeClearance = setPreCommands(toeClearance, ...
                ['Qe = GetQe[]; ']);
            toeClearance = setExpression(toeClearance,...
                model.KinObjects.LeftToePosZ.Symbols.Kin);
            toeClearance = setDepSymbols(toeClearance,{'Qe'});
            toeClearance = setDescription(toeClearance,'toe clearance');
            obj.Funcs.Phase{2}.toeClearance = toeClearance;
        end
        
        
        function obj = loadInitialGuess(obj, plant)
            % load initial guess from a simulated results
            for k = 1:numel(obj.Phase)
                calcs = plant.Flow{k};
                param = plant.Gamma.Nodes.Param{k};
                n_node = obj.Phase{k}.NumNode;
                hbar = feval(obj.Gamma.Nodes.Domain{k}.HolonomicConstr.Funcs.Kin,calcs.qe(:,1));
                
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
                obj = updateVariableProp(obj, 'H', k, 'first', 'x0',hbar);
            end
        end
    end
    
    
end