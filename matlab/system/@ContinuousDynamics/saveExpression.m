function obj = saveExpression(obj, export_path, varargin)
    % save the symbolic expression of system dynamical equations to a MX
    % binary files
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   ForceExport: force the export @type logical
    
    % Create export directory if it does not exst
    if ~exist(export_path,'dir')
        mkdir(export_path);
        addpath(export_path);
    end
    
    % export the mass matrix
    if ~isempty(obj.Mmat)
        save(obj.Mmat,export_path,varargin{:});
        save(obj.MmatDx,export_path,varargin{:});
    end
    
    % export the drift vector
    if ~isempty(obj.FvecName_)
        cellfun(@(x)save_funcs(x,export_path,varargin{:}),obj.Fvec,'UniformOutput',false);
    end
    
    
    
    % export the holonomic constraints    
    h_constrs = fieldnames(obj.HolonomicConstraints);
    if ~isempty(h_constrs)
        for i=1:length(h_constrs)
            constr = h_constrs{i};
            saveExpression(obj.HolonomicConstraints.(constr),export_path,varargin{:});
           
        end
        
    end
    
    % export the virtual constraints       
    v_constrs = fieldnames(obj.VirtualConstraints);
    if ~isempty(v_constrs)
        for i=1:length(v_constrs)
            constr = v_constrs{i};
            saveExpression(obj.VirtualConstraints.(constr),export_path,varargin{:});
        end
        
    end
    
    saveExpression@DynamicalSystem(obj,export_path,varargin{:});
    
    
    function save_funcs(x, export_path, varargin)        
        if ~isempty(x), save(x,export_path, varargin{:}); end
    end
end