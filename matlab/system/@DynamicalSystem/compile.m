function obj = compile(obj, export_path, varargin)
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
    if ~isempty(obj.Mmat)
        export(obj.Mmat,export_path,varargin{:});
    end
    
    % export the drift vector
    if ~isempty(obj.Fvec)
        cellfun(@(x)export(x,export_path,varargin{:}),obj.Fvec,'UniformOutput',false);
    end
    
    % export the input map    
    gmap_funcs = fieldnames(obj.Gmap);
    if ~isempty(gmap_funcs)
        for i=1:length(gmap_funcs)
            fun = gmap_funcs{i};
            if ~isempty(obj.Gmap.(fun))
                export(obj.Gmap.(fun),export_path,varargin{:});
            end
        end
    end
    
    
    % export the input vector fields
    gvec_funcs = fieldnames(obj.Gvec);
    if ~isempty(gvec_funcs)
        for i=1:length(gvec_funcs)
            fun = gvec_funcs{i};
            if ~isempty(obj.Gvec.(fun))
                export(obj.Gvec.(fun),export_path,varargin{:});
            end
        end
    end
    
    % export the holonomic constraints    
    h_constrs = fieldnames(obj.HolonomicConstraints);
    if ~isempty(h_constrs)
        for i=1:length(h_constrs)
            constr = h_constrs{i};
            export(obj.HolonomicConstraints.(constr).h,export_path,varargin{:});
            export(obj.HolonomicConstraints.(constr).Jh,export_path,varargin{:});
            if ~isempty(obj.HolonomicConstraints.(constr).dJh)
                export(obj.HolonomicConstraints.(constr).dJh,export_path,varargin{:});
            end
        end
        
    end
    
    u_constrs = fieldnames(obj.UnilateralConstraints);
    if ~isempty(fieldnames(obj.UnilateralConstraints))
        for i=1:length(u_constrs)
            constr = u_constrs{i};
            export(obj.UnilateralConstraints.(constr).h,export_path,varargin{:});
        end
        
    end
    
end