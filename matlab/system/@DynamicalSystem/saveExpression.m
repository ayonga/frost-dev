function obj = saveExpression(obj, export_path, varargin)
    % save the symbolic expression of system dynamical equations to a MX
    % binary files
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   ForceExport: force the export @type logical
    
    input_categories = {'Control','ConstraintWrench','External'};
    for k=1:3
        category = input_categories{k};
        % export the input map
        gmap_funcs = fieldnames(obj.Gmap.(category));
        if ~isempty(gmap_funcs)
            for i=1:length(gmap_funcs)
                fun = gmap_funcs{i};
                if ~isempty(obj.Gmap.(category).(fun))
                    save(obj.Gmap.(category).(fun),export_path,varargin{:});
                end
            end
        end
        
        
        % export the input vector fields
        gvec_funcs = fieldnames(obj.Gvec.(category));
        if ~isempty(gvec_funcs)
            for i=1:length(gvec_funcs)
                fun = gvec_funcs{i};
                if ~isempty(obj.Gvec.(category).(fun))
                    save(obj.Gvec.(category).(fun),export_path,varargin{:});
                end
            end
        end
    end
    
    
end