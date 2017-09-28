function file = save(obj, export_path, varargin)
    % Save the symbolic expression of a wolframe MX file
    %
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   ForceExport: force the export @type logical
    %
    % Return values:
    %   file: the full file name of the exported function @type char
    
    if nargin < 2
        export_path = pwd;
    end
    
    
    ip = inputParser;
    ip.addParameter('ForceExport',false,@(x) isequal(x,true) || isequal(x,false));
    ip.parse(varargin{:});
    
    opts = ip.Results;
    
    
    
    if obj.Status.FunctionSaved && ~opts.ForceExport        
        return;
    end
    file = obj.save@SymExpression(export_path, obj.Name);
    obj.Status.FunctionSaved = true;
end  
    