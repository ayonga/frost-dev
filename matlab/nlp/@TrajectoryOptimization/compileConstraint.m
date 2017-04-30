function compileConstraint(obj, constr, export_path, varargin)
    % Compile and export symbolic expression and derivatives of all NLP functions
    %
    % Parameters:
    %  constr: a list of constraints to be compiled @type cellstr
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   StackVariable: whether to stack variables into one @type logical
    %   ForceExport: force the export @type logical
    %   BuildMex: flag whether to MEX the exported file @type logical
    %   Namespace: the namespace of the function @type string
    
    
    
    opts = struct(varargin{:});
    % overwrite non-changable options
    opts.StackVariable = false;
    opts.Namespace = obj.Name;
    
    if isempty(constr)
        compileConstraint@NonlinearProgram(obj, export_path, varargin);
    else
        if ~iscell(constr), constr = {constr}; end
        
        for i=1:length(constr)
            constr_array = obj.ConstrTable.(constr{i});
            
            % We use the fact that for each constraint there is only one
            % SymFunctioni object associated with.
            deps_array = getSummands(constr_array(1));
            
            arrayfun(@(x)export(x.SymFun, export_path, opts), deps_array, 'UniformOutput', false);
            
            % first order derivatives (Jacobian)
            if obj.Options.DerivativeLevel >= 1
                arrayfun(@(x)exportJacobian(x.SymFun, export_path, opts), deps_array, 'UniformOutput', false);
            end
            
            % second order derivatives (Hessian)
            if obj.Options.DerivativeLevel >= 2
                arrayfun(@(x)exportHessian(x.SymFun, export_path, opts), deps_array, 'UniformOutput', false);
            end
        end
        
    end
    
    
    
end