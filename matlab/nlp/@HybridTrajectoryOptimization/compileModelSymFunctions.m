function obj = compileModelSymFunctions(obj, export_path)
    % This function compiles symbolic functions for the hybrid trajectory
    % optimization problem. 
    %
    % Parameters:
    % export_path: the directory to export compiled files @type char
    % varargin: additional options 
    
    % always build
    do_build = true;
    derivative_level = obj.Options.DerivativeLevel;
       
    
    % first initialize the rigid body model 
    initialize(obj.Model);
    
    % compile dynamics and CoM
    compileDynamics(obj.Model);
    
    compileCoM(obj.Model);
    
    % get fields
    model_funcs = fields(obj.FuncObjects.Model);
    
    % export each fields
    for i=1:numel(model_funcs)
        export(obj.FuncObjects.Model.(model_funcs{i}), export_path, do_build, derivative_level);
    end
    
end