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
    
    
    % export the event functions
    export(obj.Event,export_path,varargin{:});
    
    % call superclass method
    %     compile@DynamicalSystem(obj, export_path, varargin{:});
    
end
