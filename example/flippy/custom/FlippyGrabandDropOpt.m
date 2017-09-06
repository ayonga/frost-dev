classdef FlippyMoveOpt < HybridTrajectoryOptimization
    
    properties
        
        
    end
    
    methods
        
        function obj = FlippyMoveOpt(plant)
            
            
            model = plant.Model;
            
            
            
            %% Remove Left leg stance domains
%             plant = rmVertex(plant, {'LeftToeStrike', 'LeftToeLift', 'LeftHeelStrike'});
            
            %% Add a transition at the end of step to the beginning of step
%             left_toe_strike_relabel = LeftToeStrikeRelabel(model);
%             plant = rmEdge(plant, 'RightHeelStrike', 'RightToeStrike');
%             plant = addEdge(plant, 'RightHeelStrike', 'RightToeStrike', 'Guard', left_toe_strike_relabel);
            
            %% initialize the problem
            obj = obj@HybridTrajectoryOptimization(plant);
            obj = initializeNLP(obj);
            obj = configureOptVariables(obj);
            
            
            
            %% custom specifications
            
            for k=1:2
                
                
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
                
%                 minStepLength= 0.35;
%                 maxStepLength= 0.5;
%                 minStepWidth = 0.17;
% %                 maxStepWidth = 0.25;
%                 lt = 0.1728;
%                 lh = 0.082;
%                 switch k
%                     case 1 %
%                         obj = updateVariableProp(obj, 'H', k, 'first','lb',[0,0,0,0,0,0,-maxStepLength,minStepWidth,0,0,0,0,0,0]);
%                         obj = updateVariableProp(obj, 'H', k, 'first','ub',[0,0,0,0,0,0,-minStepLength,maxStepWidth,0,0,0,0,0,0]);
%                     case 2
%                         obj = updateVariableProp(obj, 'H', k, 'first','lb',[0,0,0,0,0,0,0,0,0]);
%                         obj = updateVariableProp(obj, 'H', k, 'first','ub',[0,0,0,0,0,0,0,0,0]);
%                     case 3
%                         obj = updateVariableProp(obj, 'H', k, 'first','lb',[0,0,0,0,0,minStepLength-(lt+lh),minStepWidth,0,0,0,0,0,0]);
%                         obj = updateVariableProp(obj, 'H', k, 'first','ub',[0,0,0,0,0,maxStepLength-(lt+lh),maxStepWidth,0,0,0,0,0,0]);
%                 end
                
                
                
                
            end
            
            %% Configure constraints
            obj = configureConstraints(obj);
            
            %% Custom constraints
            obj = customSymFunction(obj);
            
            %% p[1] - deltaphip(qf) = 0;
            n_node = obj.Phase{2}.NumNode;
            if obj.Options.DistributeParamWeights
                param_node = n_node;
            else
                param_node = 1;
            end
            
            var_table = obj.Phase{2}.OptVarTable;
            deltapanf = repmat({{}},1, n_node);
            deltapanf{n_node} = {NlpFunction(...
                'Name','deltapan0', 'Dimension',1, 'Type', 'linear',...
                'lb',0,'ub',0,'DepVariables',...
                {{var_table{'Qe',n_node}{1},var_table{'P',param_node}{1}}},...
                'Funcs', obj.Funcs.Phase{2}.deltapanf.Funcs)};
            obj.Phase{2}.ConstrTable = [...
                obj.Phase{2}.ConstrTable;...
                cell2table(deltapanf,'RowNames',{'deltapan0'},'VariableNames',...
                obj.Phase{2}.ConstrTable.Properties.VariableNames)];
            
            % p[2] - deltaphip(qf) = 0;
            var_table = obj.Phase{1}.OptVarTable;
            n_node = obj.Phase{1}.NumNode;
            deltapan0 = repmat({{}},1, n_node);
            deltapan0{1} = {NlpFunction(...
                'Name','deltapanf', 'Dimension',1, 'Type', 'linear',...
                'lb',0,'ub',0,'DepVariables',...
                {{var_table{'Qe',1}{1},var_table{'P',1}{1}}},...
                'Funcs', obj.Funcs.Phase{1}.deltapan0.Funcs)};
            obj.Phase{1}.ConstrTable = [...
                obj.Phase{1}.ConstrTable;...
                cell2table(deltapan0,'RowNames',{'deltapan0'},'VariableNames',...
                obj.Phase{1}.ConstrTable.Properties.VariableNames)];
            
            % impact velocity
            var_table = obj.Phase{2}.OptVarTable;
            n_node = obj.Phase{2}.NumNode;
            impactDropVelocity = repmat({{}},1, n_node);
            impactDropVelocity{n_node} = {NlpFunction(...
                'Name','impactVelocity', 'Dimension', 3, 'Type', 'nonlinear',...
                'lb',[-0.5,-0.3,-0.5],'ub',[ 0.5, 0.2, -0.0],'DepVariables',...
                {{var_table{'Qe',n_node}{1},var_table{'dQe',n_node}{1}}},...
                'Funcs', obj.Funcs.Phase{2}.impactDropVelocity.Funcs)};
            obj.Phase{2}.ConstrTable = [...
                obj.Phase{2}.ConstrTable;...
                cell2table(impactDropVelocity,'RowNames',{'impactVelocity'},'VariableNames',...
                obj.Phase{2}.ConstrTable.Properties.VariableNames)];
            
            % impact pick velocity
            var_table = obj.Phase{1}.OptVarTable;
            n_node = obj.Phase{1}.NumNode;
            impactGrabVelocity = repmat({{}},1, n_node);
            impactGrabVelocity{n_node} = {NlpFunction(...
                'Name','impactVelocity', 'Dimension', 3, 'Type', 'nonlinear',...
                'lb',[-0.5,-0.3,-0.5],'ub',[ 0.5, 0.2, -0.0],'DepVariables',...
                {{var_table{'Qe',n_node}{1},var_table{'dQe',n_node}{1}}},...
                'Funcs', obj.Funcs.Phase{1}.impactPickVelocity.Funcs)};
            obj.Phase{1}.ConstrTable = [...
                obj.Phase{1}.ConstrTable;...
                cell2table(impactGrabVelocity,'RowNames',{'impactPickVelocity'},'VariableNames',...
                obj.Phase{1}.ConstrTable.Properties.VariableNames)];

%             % impact toe velocity
%             var_table = obj.Phase{3}.OptVarTable;
%             n_node = obj.Phase{3}.NumNode;
%             impactToeVelocity = repmat({{}},1, n_node);
%             impactToeVelocity{n_node} = {NlpFunction(...
%                 'Name','impactToeVelocity', 'Dimension', 3, 'Type', 'nonlinear',...
%                 'lb',[-0.5,-0.3,-0.5],'ub',[ 0.5, 0.2, -0.0],'DepVariables',...
%                 {{var_table{'Qe',n_node}{1},var_table{'dQe',n_node}{1}}},...
%                 'Funcs', obj.Funcs.Phase{3}.impactToeVelocity.Funcs)};
%             obj.Phase{3}.ConstrTable = [...
%                 obj.Phase{3}.ConstrTable;...
%                 cell2table(impactToeVelocity,'RowNames',{'impactToeVelocity'},'VariableNames',...
%                 obj.Phase{3}.ConstrTable.Properties.VariableNames)];
%             
%             % output boundary
%             %% torso roll
%             for i = 1:3
%                 var_table = obj.Phase{i}.OptVarTable;
%                 n_node = obj.Phase{i}.NumNode;
%                 torsoRoll = repmat({{}},1, n_node);
%                 for j=1:n_node
%                     torsoRoll{j} = {NlpFunction(...
%                         'Name','torsoRoll', 'Dimension', 1, 'Type', 'linear',...
%                         'lb',-0.2,'ub',0.2,'DepVariables',...
%                         {{var_table{'Qe',j}{1}}},...
%                         'Funcs', obj.Funcs.Phase{1}.torsoRollBoundary.Funcs)};
%                 end
%                 obj.Phase{i}.ConstrTable = [...
%                     obj.Phase{i}.ConstrTable;...
%                     cell2table(torsoRoll,'RowNames',{'torsoRoll'},'VariableNames',...
%                     obj.Phase{i}.ConstrTable.Properties.VariableNames)];
%             end
%             %% swing leg roll
%             var_table = obj.Phase{2}.OptVarTable;
%             n_node = obj.Phase{2}.NumNode;
%             legRoll = repmat({{}},1, n_node);
%             for j=1:n_node
%                 legRoll{j} = {NlpFunction(...
%                     'Name','legRoll', 'Dimension', 1, 'Type', 'linear',...
%                     'lb',-0.2,'ub',0.2,'DepVariables',...
%                     {{var_table{'Qe',j}{1}}},...
%                     'Funcs', obj.Funcs.Phase{2}.legRollBoundary.Funcs)};
%             end
%             obj.Phase{2}.ConstrTable = [...
%                 obj.Phase{2}.ConstrTable;...
%                 cell2table(legRoll,'RowNames',{'legRoll'},'VariableNames',...
%                 obj.Phase{2}.ConstrTable.Properties.VariableNames)];
            
            
            %% end effector clearance
            
            var_table = obj.Phase{2}.OptVarTable;
            n_node = obj.Phase{2}.NumNode;
            endeffClearance = repmat({{}},1, n_node);
%             toeClearance = repmat({{}},1, n_node);
            endeffClearance{1} = {NlpFunction(...
                'Name','heelClearance', 'Dimension', 1, 'Type', 'linear',...
                'lb',0.02,'ub',1,'DepVariables',...
                {{var_table{'Qe',1}{1}}},...
                'Funcs', obj.Funcs.Phase{2}.EndEffClearance.Funcs)};
            endeffClearance{round(n_node/2)} = {NlpFunction(...
                'Name','heelClearance', 'Dimension', 1, 'Type', 'linear',...
                'lb',0.02,'ub',1,'DepVariables',...
                {{var_table{'Qe',round(n_node/2)}{1}}},...
                'Funcs', obj.Funcs.Phase{2}.EndEffClearance.Funcs)};
%             toeClearance{round(n_node/2)} = {NlpFunction(...
%                 'Name','toeClearance', 'Dimension', 1, 'Type', 'linear',...
%                 'lb',0.02,'ub',1,'DepVariables',...
%                 {{var_table{'Qe',round(n_node/2)}{1}}},...
%                 'Funcs', obj.Funcs.Phase{2}.toeClearance.Funcs)};
%             toeClearance{n_node} = {NlpFunction(...
%                 'Name','toeClearance', 'Dimension', 1, 'Type', 'linear',...
%                 'lb',0.02,'ub',1,'DepVariables',...
%                 {{var_table{'Qe',n_node}{1}}},...
%                 'Funcs', obj.Funcs.Phase{2}.toeClearance.Funcs)};
            obj.Phase{2}.ConstrTable = [...
                obj.Phase{2}.ConstrTable;...
                cell2table(endeffClearance,'RowNames',{'endeffClearance'},'VariableNames',...
                obj.Phase{2}.ConstrTable.Properties.VariableNames)];    
            %% Add cost function
            for i=1:2
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
            %% p[1] - deltaphip(qf) = 0
            domain = obj.Gamma.Nodes.Domain{2};
            deltapanf = SymFunction('Name', ['deltapanf']);
            deltapanf = setPreCommands(deltapanf, ...
                ['Qe = GetQe[];',...
                'P = Vec[Table[p[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];',...
                ]);
            deltapanf = setExpression(deltapanf,...
                [domain.PhaseVariable.Var.Dependents{1}.Symbols.Kin,' - p[1]']);
            deltapanf = setDepSymbols(deltapanf,{'Qe','P'});
            deltapanf = setDescription(deltapanf,'p[1] - deltapanf(qf) = 0');
            obj.Funcs.Phase{2}.deltapanf = deltapanf;
            
            %% impact velocity
            impactPickVelocity = SymFunction('Name', ['impactToeVelocity_vec']);
            impactPickVelocity = setPreCommands(impactPickVelocity, ...
                ['Qe = GetQe[]; dQe = D[Qe,t];']);
            impactPickVelocity = setExpression(impactPickVelocity,...
                ['Join[',model.KinObjects.EndEffPosZ.Symbols.Jac,',',...
                model.KinObjects.EndEffPosZ.Symbols.Jac,',',...
                model.KinObjects.EndEffPosZ.Symbols.Jac,'].dQe']);
            impactPickVelocity = setDepSymbols(impactPickVelocity,{'Qe','dQe'});
            impactPickVelocity = setDescription(impactPickVelocity,'end effector impact velocities in x,y,z directions');
            obj.Funcs.Phase{1}.impactPickVelocity = impactPickVelocity;
            
            impactDropVelocity = SymFunction('Name', ['impactToeVelocity_vec']);
            impactDropVelocity = setPreCommands(impactDropVelocity, ...
                ['Qe = GetQe[]; dQe = D[Qe,t];']);
            impactDropVelocity = setExpression(impactDropVelocity,...
                ['Join[',model.KinObjects.EndEffPosZ.Symbols.Jac,',',...
                model.KinObjects.EndEffPosZ.Symbols.Jac,',',...
                model.KinObjects.EndEffPosZ.Symbols.Jac,'].dQe']);
            impactDropVelocity = setDepSymbols(impactDropVelocity,{'Qe','dQe'});
            impactDropVelocity = setDescription(impactDropVelocity,'end effector impact velocities in x,y,z directions');
            obj.Funcs.Phase{2}.impactDropVelocity = impactDropVelocity;
            
            %% impact heel velocity
%             impactHeelVelocity = SymFunction('Name', ['impactHeelVelocity_vec']);
%             impactHeelVelocity = setPreCommands(impactHeelVelocity, ...
%                 ['Qe = GetQe[]; dQe = D[Qe,t];']);
%             impactHeelVelocity = setExpression(impactHeelVelocity,...
%                 ['Join[',model.KinObjects.LeftHeelPosX.Symbols.Jac,',',...
%                 model.KinObjects.LeftHeelPosY.Symbols.Jac,',',...
%                 model.KinObjects.LeftHeelPosZ.Symbols.Jac,'].dQe']);
%             impactHeelVelocity = setDepSymbols(impactHeelVelocity,{'Qe','dQe'});
%             impactHeelVelocity = setDescription(impactHeelVelocity,'heel impact velocities in x,y,z directions');
%             obj.Funcs.Phase{2}.impactHeelVelocity = impactHeelVelocity;
            
%             %% torso roll output boundary
%             index = obj.Gamma.Nodes.Domain{1}.ActPositionOutput.getIndex('RightTorsoRoll');
%             kin_obj = obj.Gamma.Nodes.Domain{1}.ActPositionOutput.KinGroupTable(index).KinObj;
%             torsoRollBoundary = SymFunction('Name', ['torsoRollBoundary_sca']);
%             torsoRollBoundary = setPreCommands(torsoRollBoundary, ...
%                 ['Qe = GetQe[];']);
%             torsoRollBoundary = setExpression(torsoRollBoundary,...
%                 kin_obj.Symbols.Kin);
%             torsoRollBoundary = setDepSymbols(torsoRollBoundary,{'Qe'});
%             torsoRollBoundary = setDescription(torsoRollBoundary,'boundary constraints on right torso roll output');
%             obj.Funcs.Phase{1}.torsoRollBoundary = torsoRollBoundary;
            
%             %% leg roll output boundary
%             index = obj.Gamma.Nodes.Domain{2}.ActPositionOutput.getIndex('LeftLegRoll');
%             kin_obj = obj.Gamma.Nodes.Domain{2}.ActPositionOutput.KinGroupTable(index).KinObj;
%             legRollBoundary = SymFunction('Name', ['legRollBoundary_sca']);
%             legRollBoundary = setPreCommands(legRollBoundary, ...
%                 ['Qe = GetQe[];']);
%             legRollBoundary = setExpression(legRollBoundary,...
%                 kin_obj.Symbols.Kin);
%             legRollBoundary = setDepSymbols(legRollBoundary,{'Qe'});
%             legRollBoundary = setDescription(legRollBoundary,'boundary constraints on left leg roll output');
%             obj.Funcs.Phase{2}.legRollBoundary = legRollBoundary;
            
            
%             %% heel clearance
%             heelClearance = SymFunction('Name', ['heelClearance_sca']);
%             heelClearance = setPreCommands(heelClearance, ...
%                 ['Qe = GetQe[]; ']);
%             heelClearance = setExpression(heelClearance,...
%                 model.KinObjects.LeftHeelPosZ.Symbols.Kin);
%             heelClearance = setDepSymbols(heelClearance,{'Qe'});
%             heelClearance = setDescription(heelClearance,'heel clearance');
%             obj.Funcs.Phase{2}.heelClearance = heelClearance;
            
            
            %% end effector clearance
            EndEffClearance = SymFunction('Name', ['endeffclearance_sca']);
            EndEffClearance = setPreCommands(EndEffClearance, ...
                ['Qe = GetQe[]; ']);
            EndEffClearance = setExpression(EndEffClearance,...
                model.KinObjects.EndEffPosZ.Symbols.Kin);
            EndEffClearance = setDepSymbols(EndEffClearance,{'Qe'});
            EndEffClearance = setDescription(EndEffClearance,'end effector clearance');
            obj.Funcs.Phase{2}.EndEffClearance = EndEffClearance;
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