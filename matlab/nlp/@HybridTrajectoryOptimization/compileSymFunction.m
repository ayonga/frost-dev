function obj = compileSymFunction(obj, field, phase, export_path)
    % This function compiles symbolic functions for the hybrid trajectory
    % optimization problem. 
    %
    % Parameters:
    % field: the field of symbolic function to be compiled @type char
    % phase:  name or index of particular phases @type char
    % export_path: the directory to export compiled files @type char
    %
    
    
    % always build
    do_build = true;
    derivative_level = obj.Options.DerivativeLevel;
    
    % first initialize the rigid body model 
    model = obj.Model;
    initialize(model);
    
    
    switch field
        case 'Model'
            % compile dynamics and CoM
            compileDynamics(model);
            
            compileCoM(model);
            % get fields
            model_funcs = fields(obj.Funcs.Model);
            
            % export each fields
            for i=1:numel(model_funcs)
                export(obj.Funcs.Model.(model_funcs{i}), export_path, do_build, derivative_level);
            end
        case 'Phase'
            
            
            
            
            
            for i=1:length(phase)
                phase_idx = getPhaseIndex(obj, phase(i));
                % compile domain
                domain = obj.Gamma.Nodes.Domain{obj.Phase{phase_idx}.CurrentVertex};
                compile(domain, model, true);
                
                if ~obj.Phase{phase_idx}.IsTerminal
                    edge_idx = findedge(obj.Gamma, obj.Phase{phase_idx}.CurrentVertex, obj.Phase{phase_idx}.NextVertex);
                    guard  = obj.Gamma.Edges.Guard{edge_idx};
                    compile(guard, model, true);
                    if guard.ResetMap.RigidImpact
                        next_domain = obj.Gamma.Nodes.Domain{obj.Phase{phase_idx}.NextVertex};
                        compile(next_domain.HolonomicConstr, model, true);
                    end
                end
                
                % get fields
                phase_funcs = fields(obj.Funcs.Phase{phase_idx});
                
                % export each fields
                for j=1:numel(phase_funcs)
                    export(obj.Funcs.Phase{phase_idx}.(phase_funcs{j}), export_path, do_build, derivative_level);
                end
            end
        case 'Generic'
            % get fields
            generic_funcs = fields(obj.Funcs.Generic);
            
            % export each fields
            for i=1:numel(generic_funcs)
                export(obj.Funcs.Generic.(generic_funcs{i}), export_path, do_build, derivative_level);
            end
        otherwise
            % get fields
            funcs = fields(obj.Funcs.(field));
            
            % export each fields
            for i=1:numel(funcs)
                export(obj.Funcs.(field).(funcs{i}), export_path, do_build, derivative_level);
            end
    end
   
    
end