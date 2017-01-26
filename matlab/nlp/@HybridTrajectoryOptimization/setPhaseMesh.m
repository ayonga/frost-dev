function obj = setPhaseMesh(obj, phase, n_grid)
    % Specifies non-default number of grid for particular phases
    %
    % Parameters:
    % phase: name or index of particular phases @type char
    % n_grid: the number of grids for the phase 
    % @type double

    phase_idx = getPhaseIndex(obj, phase);

    if isscalar(n_grid)
        n_grid = n_grid*ones(1,length(phase_idx));
    end

    assert(length(phase_idx)==length(n_grid),...
        'The length of the ''n_grid'' argument must be 1 (scalar) or matches the length of the given phases');

    for i=1:length(phase_idx)
        if obj.Phase{phase_idx(i)}.IsTerminal 
            num_node = 1;
        else
            switch obj.Options.CollocationScheme
                case 'HermiteSimpson'
                    num_node = n_grid(i)*2 + 1;
                case 'Trapzoidal'
                    num_node = n_grid(i) + 1;
                case 'PseudoSpectral'
                    num_node = n_grid(i) + 1;
            end
        end
        
        obj.Phase{phase_idx(i)}.NumNode = num_node;
        
        col_name = cellfun(@(x)['node',num2str(x)], num2cell(1:num_node),...
            'UniformOutput',false);
        obj.Phase{phase_idx(i)}.OptVarTable = cell2table(cell(0,num_node),...
            'VariableName',col_name);
        obj.Phase{phase_idx(i)}.ConstrTable = cell2table(cell(0,num_node),...
            'VariableName',col_name);
        obj.Phase{phase_idx(i)}.CostTable   = cell2table(cell(0,num_node),...
            'VariableName',col_name);
        
    end
end