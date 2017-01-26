classdef Atlas3DMultiWalkingOpt < HybridTrajectoryOptimization
    
    properties
    end
    
    methods
        
        function obj = Atlas3DMultiWalkingOpt(plant)
            
            
            model = plant.Model;
            
            left_toe_strike_relabel = LeftToeStrikeRelabel(model);
            plant = addEdge(plant, 'RightHeelStrike', 'RightToeStrike', 'Guard', left_toe_strike_relabel);
            plant = rmVertex(plant, {'LeftToeStrike', 'LeftToeLift', 'LeftHeelStrike'});
            
            obj = obj@HybridTrajectoryOptimization(plant);
            obj = initializeNLP(obj);
            obj = configureOptVariables(obj);
            
            
            
            obj = configureConstraints(obj);
            for i=1:3
                obj = addRunningCost(obj, i, obj.Funcs.Phase{i}.power);
            end
        end
        
        function obj = configureOptVariables(obj)
            % This function configures the structure of the optimization variable
            % by adding (registering) them to the optimization variable table.
            %
            % A particular project might inherit the class and overload this
            % function to achieve custom configuration of the optimization
            % variables
            
            obj = configureOptVariables@HybridTrajectoryOptimization(obj);
            
            for k=1:3
                calcs = obj.Plant.Flow{k}.calcs;
                phase = obj.Phase{k}.OptVarTable;
                param = obj.Plant.Gamma.Nodes.Param{k};
                n_node = obj.Phase{k}.NumNode;
                t = table2cell(phase('T',:));
                q = table2cell(phase('Qe',:));
                dq = table2cell(phase('dQe',:));
                ddq = table2cell(phase('ddQe',:));
                u = table2cell(phase('U',:));
                Fe = table2cell(phase('Fe',:));
                v = table2cell(phase('V',:));
                p = table2cell(phase('P',:));
                a = table2cell(phase('A',:));
                h = table2cell(phase('H',:));
                hbar = feval(obj.Gamma.Nodes.Domain{k}.HolonomicConstr.Funcs.Kin,calcs{k}.qe);
                for i=1:n_node
                    updateProp(t{i},'x0',calcs{end}.t);
                    updateProp(q{i},'x0',calcs{i}.qe);
                    updateProp(dq{i},'x0',calcs{i}.dqe);
                    updateProp(ddq{i},'x0',calcs{i}.ddqe);
                    updateProp(u{i},'x0',calcs{i}.u);
                    updateProp(Fe{i},'x0',calcs{i}.Fe);
                    updateProp(p{i},'x0',param.p(:));
                    updateProp(v{i},'x0',param.v(:));
                    updateProp(a{i},'x0',param.a(:));
                    updateProp(h{i},'x0',hbar);
                end
                
            end
            
            
        end
    end
    
    
end