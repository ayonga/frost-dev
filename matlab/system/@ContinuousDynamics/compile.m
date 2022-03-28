function obj = compile(obj, export_path, varargin)
    % export the symbolic expressions of the system dynamics matrices and
    % vectors and compile as MEX files.
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   StackVariable: whether to stack variables into one @type logical
    %   ForceExport: force the export @type logical
    %   BuildMex: flag whether to MEX the exported file @type logical
    %   Namespace: the namespace of the function @type char
    %   NoPrompt: answer yes to all prompts
    
    %     opts = struct(varargin{:});
    %     noPrompt = false;
    %     if isfield(opts, 'noPrompt')
    %         noPrompt = opts.noPrompt;
    %     end
    
    arguments
        obj 
        export_path char {mustBeFolder}
    end
    arguments (Repeating)
        varargin
    end
    
    %     % Create export directory if it does not exst
    %     if ~exist(export_path,'dir')
    %         mkdir(export_path);
    %         addpath(export_path);
    %     end
    
    % export the mass matrix
    if ~isempty(obj.Mmat)
        cellfun(@(x)export(x,export_path,varargin{:}),obj.Mmat,'UniformOutput',false);
    end
    
    % export the drift vector
    if ~isempty(obj.Fvec)
        cellfun(@(x)export(x,export_path,varargin{:}),obj.Fvec,'UniformOutput',false);
    end
    
    
    
    % export the holonomic constraints    
    h_constrs = fieldnames(obj.HolonomicConstraints);
    if ~isempty(h_constrs)
        for i=1:length(h_constrs)
            input = h_constrs{i};
            export(obj.HolonomicConstraints.(input),export_path,varargin{:});
           
        end
        
    end
    
    % export the unilateral constraints       
    u_constrs = fieldnames(obj.UnilateralConstraints);
    if ~isempty(u_constrs)
        for i=1:length(u_constrs)
            input = u_constrs{i};
            export(obj.UnilateralConstraints.(input),export_path,varargin{:});
        end
        
    end
    
    % export the virtual constraints       
    v_constrs = fieldnames(obj.VirtualConstraints);
    if ~isempty(v_constrs)
        for i=1:length(v_constrs)
            input = v_constrs{i};
            export(obj.VirtualConstraints.(input),export_path,varargin{:});
        end
        
    end
    
    % export the input maps    
    inputs = fieldnames(obj.Inputs);
    if ~isempty(inputs)
        for i=1:length(inputs)
            input = inputs{i};
            export(obj.Inputs.(input),export_path,varargin{:});
        end        
    end
    
    % export the event functions
    funcs = fieldnames(obj.EventFuncs);
    if ~isempty(funcs)
        for i=1:length(funcs)
            fun = funcs{i};
            export(obj.EventFuncs.(fun),export_path,varargin{:});
        end        
    end
    
    % call superclass method
    %     compile@DynamicalSystem(obj, export_path, varargin{:});
    
end
