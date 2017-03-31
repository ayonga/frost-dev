function [J,Js] = exportJacobian(obj, export_path, varargin)
    % Export the symbolic expression of the Jacobian of the function to
    % C/C++ source files and build them as MEX files.
    %
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   Vars: a list of symbolic variables @type SymVariable
    %   File: the (full) file name of exported file @type char
    %   ForceExport: force the export @type logical
    %   BuildMex: flag whether to MEX the exported file @type logical
    %   Namespace: the namespace of the function @type string
    
    ip = inputParser;
    ip.addParameter('StackVariable',false,@(x) isequal(x,true) || isequal(x,false));
    ip.addParameter('ForceExport',false,@(x) isequal(x,true) || isequal(x,false));
    ip.addParameter('BuildMex',true,@(x) isequal(x,true) || isequal(x,false));
    ip.addParameter('Namespace',string('SymFunction'),@(x) isstring(x));
    ip.parse(varargin{:});
    
    opts = ip.Results;
    
    if obj.Status.JacobianExported && ~opts.ForceExport
        J = fullfile(export_path, obj.Funcs.Hess);
        Js = fullfile(export_path, obj.Funcs.HessStruct);
        return;
    end

    if nargin < 2
        export_path = pwd;
    end
    
    if ~isempty(obj.Vars) && opts.StackVariable
        vars = cellfun(@(x)flatten(x), obj.Vars,'UniformOutput',false);
        vars = {[vars{:}]};
    elseif isempty(obj.Vars)
        error('The dependent variables CANNOT be empty.');
    else
        vars = obj.Vars;
    end
    
    if ~isempty(obj.Params) && opts.StackVariable
        params = cellfun(@(x)flatten(x), obj.Params,'UniformOutput',false);
        params = {[params{:}]};
    else
        params = obj.Params;
    end
    opts = rmfield(opts,'StackVariable');
    
    
    export_opts = opts;   
    export_opts.Vars = [vars, params];
  
    
    
    
    
    s = SymExpression(obj);
    fvar = cellfun(@(x)flatten(x), obj.Vars,'UniformOutput',false);
    fvar = [fvar{:}];
    % export the first order Jacobian matrix
    jac = jacobian(s, fvar);
    
    % the non-zero values of the sparse Jacobian matrix
    jac_nonzeros = nonzeros(jac);
    export_opts.File = fullfile(export_path, obj.Funcs.Jac);
    J = export(jac_nonzeros, export_opts);
    
    % the non-zero positions of the sparse Jacobian matrix
    jac_nzind = nzind(jac);
    export_opts.Vars = SymVariable('var');
    export_opts.File = fullfile(export_path, obj.Funcs.JacStruct);
    Js = export(jac_nzind, export_opts);
    
    
    
   
    obj.Status.JacobianExported = true;
    
    
    
    
end




