function saveObjective(obj, cost, export_path, exclude, varargin)
    % save symbolic expression all NLP constraints to files
    %
    % @note If 'constr' is emtpy, then it will compile all constraints.
    %
    % Parameters:
    %  cost: a list of constraints to be compiled @type cellstr
    %  export_path: the path to export the file @type char
    %  exclude: a list of functions to be excluded @type cellstr
    %  varargin: variable input parameters @type varargin
    %   ForceExport: force the export @type logical
    
    if nargin < 4
        exclude = {};
    else
        if ~iscell(exclude), exclude = {exclude}; end
    end
    
    
    if isempty(cost)
        cost = obj.CostTable.Properties.VariableNames;
        phase_cost_names = {};
    else
        if ~iscell(cost), cost = {cost}; end
        phase_cost_names = obj.CostTable.Properties.VariableNames;
    end
    
    
    for i=1:length(cost)
        if ~isempty(exclude)
            if any(strcmp(cost{i},exclude))
                continue;
            end
        end
        if ~isempty(phase_cost_names)
            if ~any(strcmp(cost{i},phase_cost_names))
                continue;
            end
        end
        
        cost_array = obj.CostTable.(cost{i});
        
        
        cost_array = cost_array(~arrayfun(@(x)x.Dimension==0,cost_array));
        
        %         deps_array_cell = arrayfun(@(x)getSummands(x), cost_array, 'UniformOutput', false);
        %         func_array = vertcat(deps_array_cell{:});
        
        % We use the fact that for each constraint there is only one
        % SymFunction object associated with.
        func_array = getSummands(cost_array(1));
        arrayfun(@(x)save(x.SymFun, export_path, varargin{:}), func_array, 'UniformOutput', false);
        
        
    end
    
    
    
end