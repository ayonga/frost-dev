function obj = saveExpression(obj, export_path, varargin)
    % save the symbolic expression of system dynamical equations to a MX
    % binary files
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   ForceExport: force the export @type logical
    
    arguments
        obj 
        export_path char {mustBeFolder}
    end
    arguments (Repeating)
        varargin
    end
    
    % Create export directory if it does not exst
    %     if ~exist(export_path,'dir')
    %         mkdir(export_path);
    %         addpath(export_path);
    %     end
    
    
    
    
    % export the holonomic constraints    
    saveExpression(obj.Event,export_path,varargin{:});
    
    
    
    
end