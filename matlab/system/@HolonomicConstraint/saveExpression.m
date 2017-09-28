function obj = saveExpression(obj, export_path, varargin)
    % export the symbolic expressions of the constraints matrices to MX
    % binary files
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   ForceExport: force the export @type logical
    
    save(obj.h_,export_path, varargin{:});
    save(obj.Jh_,export_path, varargin{:});
    save(obj.dh_,export_path, varargin{:});
    
    if ~isempty(obj.dJh_)
        save(obj.dJh_,export_path, varargin{:});
    end
    
    if ~isempty(obj.ddh_)
        save(obj.ddh_,export_path, varargin{:});
    end
end