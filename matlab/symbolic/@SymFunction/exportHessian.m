function [H,Hs] = exportHessian(obj, export_path, varargin)
    % Export the symbolic expression of the Hessian of the function to
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
    ip.addParameter('Namespace','SymFunction',@(x) ischar(x));
    ip.addParameter('TemplateFile','',@(x) ischar(x));
    ip.addParameter('TemplateHeader','',@(x) ischar(x));
    ip.parse(varargin{:});
    
    opts = ip.Results;
    
    if obj.Status.HessianExported && ~opts.ForceExport
        H = fullfile(export_path, obj.Funcs.Hess);
        Hs = fullfile(export_path, obj.Funcs.HessStruct);
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
    
    
    s = SymExpression(obj);
    fvar = cellfun(@(x)flatten(x), obj.Vars,'UniformOutput',false);
    fvar = [fvar{:}];
    % export the Hessian matrix
    hess = hessian(s, fvar);
    nexpr = length(s);
    lambda = SymVariable('lambda',nexpr);
    
    hess_symbol = hess.s;
    lambda_symbol = lambda.s;
    
    cmd = ['Sum[' lambda_symbol '[[i]]*LowerTriangularize@' hess_symbol '[[i, ;;]], {i,' num2str(nexpr) '}]'];
    hess_sum = SymExpression(cmd);
    
    hess_nonzeros = nonzeros(hess_sum);
    export_opts.File = fullfile(export_path, obj.Funcs.Hess);
    export_opts.Vars = [vars, params, {lambda}];
    H = export(hess_nonzeros, export_opts);
    
    
    % the non-zero positions of the sparse Jacobian matrix
    hess_nzind = nzind(hess_sum);
    export_opts.Vars = SymVariable('var');
    export_opts.File = fullfile(export_path, obj.Funcs.HessStruct);
    Hs = export(hess_nzind, export_opts);
    
    
   
    obj.Status.HessianExported = true;
    
    
    
    
end




