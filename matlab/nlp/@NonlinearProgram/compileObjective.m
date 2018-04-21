function compileObjective(obj, export_path, varargin)
    % Compile and export symbolic expression and derivatives of all NLP functions
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   ForceExport: force the export @type logical
    %   BuildMex: flag whether to MEX the exported file @type logical
    
    
    
    
    opts = struct(varargin{:});
    % overwrite non-changable options
%     opts.StackVariable = false;
    opts.Namespace = obj.Name;
    
    deps_array_cell = arrayfun(@(x)getSummands(x), obj.CostArray, 'UniformOutput', false);
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