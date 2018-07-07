function f = export(obj, export_path, varargin)
    % Export the symbolic expression of functions to C/C++ source
    % files and build them as MEX files.
    %
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   StackVariable: whether to stack variables into one @type logical
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
    ip.addParameter('noPrompt',false,@(x) islogical(x));
    ip.parse(varargin{:});
    
    opts = ip.Results;
    
    

    if nargin < 2
        export_path = pwd;
    end
    
    if obj.Status.FunctionExported && ~opts.ForceExport
        f = fullfile(export_path, obj.Name);
        return;
    end
        
%     if exist(fullfile(export_path, [obj.Name, '.mexw64']), 'file')
%         f = fullfile(export_path, obj.Name);
%         return;
%     end
    
    
    
    if ~isempty(obj.Vars) && opts.StackVariable
        vars = cellfun(@(x)flatten(x), obj.Vars,'UniformOutput',false);
        vars = {[vars{:}]};
        vars = flatten(vars{:});
    else
        vars = obj.Vars;
    end
    
    if ~isempty(obj.Params) && opts.StackVariable
        params = cellfun(@(x)flatten(x), obj.Params,'UniformOutput',false);
        params = {[params{:}]};
        params = flatten(params{:});
    else
        params = obj.Params;
    end
    
    
    
    export_opts = opts;
    export_opts.Vars = [vars, params];
    export_opts.File = fullfile(export_path, obj.Name);
    export_opts = rmfield(export_opts,'StackVariable');
    % The argument list cannot be empty. Use dummy variable
    if isempty(export_opts.Vars)
        export_opts.Vars = SymVariable('var'); 
    end
    
    f = obj.export@SymExpression(export_opts);
    
    obj.Status.FunctionExported = true;
    
    
    
end




