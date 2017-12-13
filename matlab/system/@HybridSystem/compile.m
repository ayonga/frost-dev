function obj = compile(obj, export_path, varargin)
    % export the symbolic expressions of the system dynamics matrices and
    % vectors and compile as MEX files.
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   StackVariable: whether to stack variables into one @type logical
    %   File: the (full) file name of exported file @type char
    %   ForceExport: force the export @type logical
    %   BuildMex: flag whether to MEX the exported file @type logical
    %   Namespace: the namespace of the function @type char
    
    
    if ~isempty(obj.Gamma.Nodes)
        cellfun(@(x)compile(x,export_path,varargin{:}), ...
            obj.Gamma.Nodes.Domain, 'UniformOutput',false);
    end
    
    if ~isempty(obj.Gamma.Edges)
        cellfun(@(x)compile(x,export_path,varargin{:}), ...
            obj.Gamma.Edges.Guard, 'UniformOutput',false);
    end
end