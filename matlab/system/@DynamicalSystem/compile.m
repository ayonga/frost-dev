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
    
    input_categories = {'Control','ConstraintWrench','External'};
    for k=1:3
        category = input_categories{k};
        % export the input map
        gmap_funcs = fieldnames(obj.Gmap.(category));
        if ~isempty(gmap_funcs)
            for i=1:length(gmap_funcs)
                fun = gmap_funcs{i};
                if ~isempty(obj.Gmap.(category).(fun))
                    export(obj.Gmap.(category).(fun),export_path,varargin{:});
                end
            end
        end
        
        
        % export the input vector fields
        gvec_funcs = fieldnames(obj.Gvec.(category));
        if ~isempty(gvec_funcs)
            for i=1:length(gvec_funcs)
                fun = gvec_funcs{i};
                if ~isempty(obj.Gvec.(category).(fun))
                    export(obj.Gvec.(category).(fun),export_path,varargin{:});
                end
            end
        end
    end
    
    
end