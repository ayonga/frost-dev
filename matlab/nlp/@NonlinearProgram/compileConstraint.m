function [obj] = compileConstraint(obj, export_path)
    % Compile and export symbolic expression and derivatives of all NLP functions
    %
    % Parameters:         
    %  export_path: the complete directory path where the compiled symbolic
    %  function will be exported to @type char
    
    
    
    opts = struct();
    opts.StackVariable = true;
    opts.ForceExport = false;
    opts.BuildMex = true;
    opts.Namespace = string(obj.Name);
    
    
    
    deps_array_cell = arrayfun(@(x)getSummands(x), obj.ConstrArray, 'UniformOutput', false);
    func_array = vertcat(deps_array_cell{:});
    arrayfun(@(x)export(x.SymFun, export_path, opts), func_array, 'UniformOutput', false);
    
    % first order derivatives (Jacobian)
    if obj.Options.DerivativeLevel >= 1
        arrayfun(@(x)exportJacobian(x.SymFun, export_path, opts), func_array, 'UniformOutput', false);
    end
    
    % second order derivatives (Hessian)
    if obj.Options.DerivativeLevel >= 2
        arrayfun(@(x)exportHessian(x.SymFun, export_path, opts), func_array, 'UniformOutput', false);
    end
end