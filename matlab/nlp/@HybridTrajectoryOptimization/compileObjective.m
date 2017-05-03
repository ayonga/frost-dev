function [obj] = compileObjective(obj, phase, cost, export_path, exclude, varargin)
    % Compile and export symbolic expression and derivatives of all NLP functions
    %
    % @note If 'phase' is empty, then it will compile all phases.
    % @note If 'cost' is emtpy, then it will compile all cost functions.
    %
    % Parameters:
    %  phase: the phase Nlp @type integer
    %  constr: a list of constraints to be compiled @type cellstr
    %  export_path: the path to export the file @type char
    %  exclude: a list of functions to be excluded @type cellstr
    %  varargin: variable input parameters @type varargin
    %   StackVariable: whether to stack variables into one @type logical
    %   ForceExport: force the export @type logical
    %   BuildMex: flag whether to MEX the exported file @type logical
    %   Namespace: the namespace of the function @type string
    
    if nargin < 5
        exclude = {};
    else
        if ~iscell(exclude), exclude = {exclude}; end
    end
    
    opts = struct(varargin{:});
    % overwrite non-changable options
    opts.StackVariable = false;
    opts.Namespace = obj.Name;

    if isempty(phase)
        phase = 1:1:numel(obj.Phase);
    elseif ischar(phase)
        phase = getPhaseIndex(obj,phase);
    elseif iscell(phase)
        phase = getPhaseIndex(obj,phase{:});
    end


    for k=phase
        phase_nlp = obj.Phase(k);
        if isempty(cost)
            phase_cost = phase_nlp.CostTable.Properties.VariableNames;
            phase_cost_names = [];
        else
            if ~iscell(cost)
                phase_cost = {cost}; 
            else
                phase_cost = cost;
            end
            phase_cost_names = phase_nlp.CostTable.Properties.VariableNames;
        end
        
        
        for i=1:length(phase_cost)
            if ~isempty(exclude)
                if any(strcmp(phase_cost{i},exclude))
                    continue;
                end
            end
            if ~isempty(phase_cost_names)
                if ~any(strcmp(phase_cost{i},phase_cost_names))
                    continue;
                end
            end
            cost_array = phase_nlp.CostTable.(phase_cost{i});
            
            % We use the fact that for each objective function there could
            % be multiple SymFunction objects (running cost) associated
            % with
            cost_array = cost_array(~arrayfun(@(x)x.Dimension==0,cost_array));
            deps_array_cell = arrayfun(@(x)getSummands(x), cost_array, 'UniformOutput', false);
            func_array = vertcat(deps_array_cell{:});
            arrayfun(@(x)export(x.SymFun, export_path, opts), func_array, 'UniformOutput', false);
            
            % first order derivatives (Jacobian)
            if phase_nlp.Options.DerivativeLevel >= 1
                arrayfun(@(x)exportJacobian(x.SymFun, export_path, opts), func_array, 'UniformOutput', false);
            end
            
            % second order derivatives (Hessian)
            if phase_nlp.Options.DerivativeLevel >= 2
                arrayfun(@(x)exportHessian(x.SymFun, export_path, opts), func_array, 'UniformOutput', false);
            end
        end
    end
end