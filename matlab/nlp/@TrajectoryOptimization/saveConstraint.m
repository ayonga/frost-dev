function saveConstraint(obj, constr, export_path, exclude, varargin)
    % save symbolic expression all NLP constraints to files
    %
    % @note If 'constr' is emtpy, then it will compile all constraints.
    %
    % Parameters:
    %  constr: a list of constraints to be compiled @type cellstr
    %  export_path: the path to export the file @type char
    %  exclude: a list of functions to be excluded @type cellstr
    %  varargin: variable input parameters @type varargin
    %   ForceExport: force the export @type logical
    
    if nargin < 4
        exclude = {};
    else
        if ~iscell(exclude), exclude = {exclude}; end
    end
    
    
    if isempty(constr)
        constr = obj.ConstrTable.Properties.VariableNames;
        phase_constr_names = {};
    else
        if ~iscell(constr), constr = {constr}; end
        phase_constr_names = obj.ConstrTable.Properties.VariableNames;
    end
    
    
    for i=1:length(constr)
        if ~isempty(exclude)
            if any(strcmp(constr{i},exclude))
                continue;
            end
        end
        if ~isempty(phase_constr_names)
            if ~any(strcmp(constr{i},phase_constr_names))
                continue;
            end
        end
        
        constr_array = obj.ConstrTable.(constr{i});
        
        % We use the fact that for each constraint there is only one
        % SymFunction object associated with.
        
        % first find out non-empty NlpFunction objects
        constr_array = constr_array(~arrayfun(@(x)x.Dimension==0,constr_array));
        % then just use the first one
        deps_array = getSummands(constr_array(1));
        
        arrayfun(@(x)save(x.SymFun, export_path, varargin{:}), deps_array, 'UniformOutput', false);
        
        
    end
    
    
    
end