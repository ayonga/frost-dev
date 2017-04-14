function obj = compileDynamics(obj, export_path, varargin)
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
    
    % export the mass matrix
    export(obj.Mmat,export_path,varargin{:});
    
    
    % export the drift vector
    cellfun(@(x)export(x,export_path,varargin{:}),obj.Fvec,'UniformOutput',false);
end