function [obj] = compileConstraint(obj, export_path)
    % Compile and export symbolic expression and derivatives of all NLP functions
    %
    % Parameters:         
    %  export_path: the complete directory path where the compiled symbolic
    %  function will be exported to @type char
    
    
    
    derivative_level = obj.Options.DerivativeLevel;
    
    do_build = true;
    
    
    
    func_array = cellfun(@(x)getDepObject(x), obj.ConstrArray, 'UniformOutput', false);
    
    cellfun(@(x)export(x.SymFun, export_path, derivative_level, do_build), ...
        func_array, 'UniformOutput', false);
end