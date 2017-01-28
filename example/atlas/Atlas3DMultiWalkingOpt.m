classdef Atlas3DMultiWalkingOpt < HybridTrajectoryOptimization
    
    properties
    end
    
    methods
        
        function obj = Atlas3DMultiWalkingOpt(plant)
            
            
            model = plant.Model;
            
            
            
            
            left_toe_strike_relabel = LeftToeStrikeRelabel(model);
            plant = rmEdge(plant, 'RightHeelStrike', 'RightToeStrike');
            plant = addEdge(plant, 'RightHeelStrike', 'RightToeStrike', 'Guard', left_toe_strike_relabel);
            plant = rmVertex(plant, {'LeftToeStrike', 'LeftToeLift', 'LeftHeelStrike'});
            
            obj = obj@HybridTrajectoryOptimization(plant);
            obj = initializeNLP(obj);
            obj = configureOptVariables(obj);
            
            
            
            
            
            for k=1:3
                calcs = plant.Flow{k}.calcs;
                param = plant.Gamma.Nodes.Param{k};
                n_node = obj.Phase{k}.NumNode;
                hbar = feval(obj.Gamma.Nodes.Domain{k}.HolonomicConstr.Funcs.Kin,calcs{1}.qe);
                
                obj = updateVariableProp(obj, 'T', k, 'first', 'x0', calcs{end}.t);
                for i=1:n_node
                    obj = updateVariableProp(obj, 'Qe', k, i, 'x0',calcs{i}.qe);
                    obj = updateVariableProp(obj, 'dQe', k, i, 'x0',calcs{i}.dqe);
                    obj = updateVariableProp(obj, 'ddQe', k, i, 'x0',calcs{i}.ddqe);
                    obj = updateVariableProp(obj, 'U', k, i, 'x0',calcs{i}.u);
                    obj = updateVariableProp(obj, 'Fe', k, i, 'x0',calcs{i}.Fe);
                end
                obj = updateVariableProp(obj, 'P', k, 'first', 'x0',param.p(:));
                obj = updateVariableProp(obj, 'V', k, 'first', 'x0',param.v(:));
                a = param.a';
                obj = updateVariableProp(obj, 'A', k, 'first', 'x0',a(:));
                obj = updateVariableProp(obj, 'H', k, 'first', 'x0',hbar);
                
                obj = updateVariableProp(obj, 'P', k, 'first','lb',[0.1, -0.4], 'ub', [0.4, -0.1]);
                obj = updateVariableProp(obj, 'V', k, 'first','lb',0.5, 'ub', 0.9);
                
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
            
            obj = configureConstraints(obj);
            for i=1:3
                obj = addRunningCost(obj, i, obj.Funcs.Phase{i}.power);
            end
        end
        
        
    end
    
    
end