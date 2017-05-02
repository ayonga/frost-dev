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
    
    
    
    
    % export the impact constraints    
    i_constrs = fieldnames(obj.ImpactConstraints);
    if ~isempty(i_constrs)
        for i=1:length(i_constrs)
            constr = i_constrs{i};
            export(obj.ImpactConstraints.(constr),export_path,varargin{:});
           
        end
        
    end
    
    
    % The mass matrix will be exported by the continuoud dynamics object,
    % but call it here again will not re-export if it has been exported.
    if ~isempty(obj.Mmat)
        export(obj.Mmat,export_path,varargin{:});
    end
    
    % call superclass method
    compile@DiscreteDynamics(obj, export_path, varargin{:});
end