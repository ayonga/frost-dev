function saveExpression(obj, export_path, varargin)
    % save the symbolic expressions of the constraints matrices to MX
    % binary files
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   ForceExport: force the export @type logical
    
    
    cellfun(@(x)save_funcs(x,export_path, varargin{:}), obj.ActualFuncs, ...
        'UniformOutput',false);
    cellfun(@(x)save_funcs(x,export_path, varargin{:}), obj.DesiredFuncs, ...
        'UniformOutput',false);
    
    %     if ~isempty(obj.OutputFuncs)
    %         cellfun(@(x)save_funcs(x,export_path, varargin{:}), obj.OutputFuncs, ...
    %             'UniformOutput',false);
    %     end
    
    if ~isempty(obj.tau_)
        cellfun(@(x)save_funcs(x,export_path, varargin{:}), obj.PhaseFuncs, ...
            'UniformOutput',false);
    end
    
    function save_funcs(x, export_path, varargin)        
        if ~isempty(x), save(x,export_path, varargin{:}); end
    end
end