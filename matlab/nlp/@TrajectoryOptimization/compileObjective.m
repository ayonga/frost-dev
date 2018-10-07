function compileObjective(obj, cost, export_path, exclude, varargin)
    % Compile and export symbolic expression and derivatives of all NLP functions
    %
    % @note If 'cost' is emtpy, then it will compile all cost functions.
    %
    % Parameters:         
    %  cost: the cost function to be compiled @type cellstr
    %  export_path: the path to export the file @type char
    %  exclude: a list of functions to be excluded @type cellstr
    %  varargin: variable input parameters @type varargin
    %   ForceExport: force the export @type logical
    %   BuildMex: flag whether to MEX the exported file @type logical
    
    if nargin < 4
        exclude = {};
    else
        if ~iscell(exclude), exclude = {exclude}; end
    end
    
    
    opts = struct(varargin{:});
    % overwrite non-changable options
    %opts.StackVariable = false;
    opts.Namespace = obj.Name;
    
    if isempty(cost)
        cost = obj.CostTable.Properties.VariableNames;
        phase_cost_names = [];
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
        
        % % % % % % % This is no longer true! % % % % % % 
        % % We use the fact that for each objective function there could
        % % be multiple SymFunction objects (running cost) associated
        % % with
        %         deps_array_cell = arrayfun(@(x)getSummands(x), cost_array, 'UniformOutput', false);
        %         func_array = vertcat(deps_array_cell{:});
        % % % % % % % % % % % % %% % % % % % % % % % % % % 
        
        % We use the fact that for each constraint there is only one
        % SymFunction object associated with.
        func_array = getSummands(cost_array(1));
        
        arrayfun(@(x)export(x.SymFun, export_path, opts), func_array, 'UniformOutput', false);
        
        % first order derivatives (Jacobian)
        if obj.Options.DerivativeLevel >= 1
            arrayfun(@(x)exportJacobian(x.SymFun, export_path, opts), func_array, 'UniformOutput', false);
        end
        
        % second order derivatives (Hessian)
        if obj.Options.DerivativeLevel >= 2
            arrayfun(@(x)exportHessian(x.SymFun, export_path, opts), func_array, 'UniformOutput', false);
        end
    end
end