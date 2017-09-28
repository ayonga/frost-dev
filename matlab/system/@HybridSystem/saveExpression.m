function obj = saveExpression(obj, export_path, varargin)
    % save the symbolic expression of system dynamical equations to a MX
    % binary files
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   ForceExport: force the export @type logical
    
    cellfun(@(x)saveExpression(x,export_path,varargin{:}), ...
        obj.Gamma.Nodes.Domain, 'UniformOutput',false);
    cellfun(@(x)saveExpression(x,export_path,varargin{:}), ...
        obj.Gamma.Edges.Guard, 'UniformOutput',false);
    
    
end