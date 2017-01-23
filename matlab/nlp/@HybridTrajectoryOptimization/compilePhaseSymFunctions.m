function obj = compilePhaseSymFunctions(obj, phase, export_path)
    % This function compiles symbolic functions for the hybrid trajectory
    % optimization problem. 
    %
    % Parameters:
    % phase:  name or index of particular phases @type char
    % export_path: the directory to export compiled files @type char
    
    
    
    if isnumeric(phase)
        phase_idx = phase;
    elseif iscellstr(phase)
        phase_idx = findnode(obj.Plant.Gamma, phase);
    elseif ischar(phase)
        phase_idx = findnode(obj.Plant.Gamma, phase);
    elseif isempty(phase)
        phase_idx = 1:length(obj.Phase);
    end
    % always build
    do_build = true;
    derivative_level = obj.Options.DerivativeLevel;
       
    
    % first initialize the rigid body model 
    initialize(obj.Model);
    
    
    for i=1:length(phase_idx)
        % compile domain
        compile(obj.Phase(phase_idx(i)).Domain, obj.Model, true);
        
        % get fields
        phase_funcs = fields(obj.FuncObjects.Phase{phase_idx(i)});
        
        % export each fields
        for j=1:numel(phase_funcs)
            export(obj.FuncObjects.Phase{phase_idx(i)}.(phase_funcs{j}), export_path, do_build, derivative_level);
        end
    end
    
   
    
end