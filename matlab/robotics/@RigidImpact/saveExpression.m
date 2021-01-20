function obj = saveExpression(obj, export_path, varargin)
    % export the symbolic expressions of the system dynamics matrices and
    % vectors and compile as MEX files.
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   ForceExport: force the export @type logical
    
    
    
    
    % export the impact constraints    
    i_constrs = fieldnames(obj.ImpactConstraints);
    if ~isempty(i_constrs)
        for i=1:length(i_constrs)
            constr = i_constrs{i};
            saveExpression(obj.ImpactConstraints.(constr),export_path,varargin{:});
           
        end
        
    end
    
    
    % The mass matrix will be exported by the continuoud dynamics object,
    % but call it here again will not re-export if it has been exported.
    %     if ~isempty(obj.Mmat)
    %         save(obj.Mmat,export_path,varargin{:});
    %     end
    
    
    if ~isempty(obj.xMap)
        save(obj.xMap,export_path,varargin{:});
    end
    
    if ~isempty(obj.dxMap)
        if iscell(obj.dxMap)
            cellfun(@(x)save_funcs(x,export_path,varargin{:}),obj.dxMap,'UniformOutput',false);
        elseif isa(obj.dxMap,'SymFunction')
            save(obj.dxMap,export_path,varargin{:});
        end
            
    end
    
    % call superclass method
    saveExpression@DiscreteDynamics(obj, export_path, varargin{:});
    
    function save_funcs(x, export_path, varargin)        
        if ~isempty(x), save(x,export_path, varargin{:}); end
    end
end