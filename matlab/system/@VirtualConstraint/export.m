function export(obj, export_path, varargin)
    % export the symbolic expressions of the system dynamics matrices and
    % vectors and compile as MEX files.
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   Vars: a list of symbolic variables @type SymVariable
    %   File: the (full) file name of exported file @type char
    %   ForceExport: force the export @type logical
    %   BuildMex: flag whether to MEX the exported file @type logical
    %   Namespace: the namespace of the function @type char
    
    
    cellfun(@(x)export_funcs(x,export_path, varargin{:}), obj.ActualFuncs, ...
        'UniformOutput',false);
    cellfun(@(x)export_funcs(x,export_path, varargin{:}), obj.DesiredFuncs, ...
        'UniformOutput',false);
    
    cellfun(@(x)export_funcs(x,export_path, varargin{:}), obj.PhaseFuncs, ...
        'UniformOutput',false);
    
    
    function ret = export_funcs(x,export_path, varargin)        
        if ~isempty(x), ret = export(x,export_path, varargin{:}); end
    end
end