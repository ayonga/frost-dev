function obj = setPhaseMesh(obj, phase, n_grid)
    % Specifies non-default number of grid for particular phases
    %
    % Parameters:
    % phase: name or indx of particular phases @type char
    % n_grid: the number of grids for the phase 
    % @type double

    if isnumeric(phase)
        phase_idx = phase;
    elseif iscellstr(phase)
        phase_idx = findnode(obj.Plant.Gamma, phase);
    elseif ischar(phase)
        phase_idx = findnode(obj.Plant.Gamma, phase);
    elseif isempty(phase)
        phase_idx = 1:length(obj.Phase);
    end

    if isscalar(n_grid)
        n_grid = n_grid*ones(1,length(phase_idx));
    end

    assert(length(phase_idx)==length(n_grid),...
        'The length of the ''n_grid'' argument must be 1 (scalar) or matches the length of the given phases');

    for i=1:length(phase_idx)
        switch obj.Options.CollocationScheme
            case 'HermiteSimpson'
                obj.Phase(phase_idx(i)).NumNode = n_grid(i)*2 + 1;
            case 'Trapzoidal'
                obj.Phase(phase_idx(i)).NumNode = n_grid(i) + 1;
            case 'PseudoSpectral'
                obj.Phase(phase_idx(i)).NumNode = n_grid(i) + 1;
        end
    end
end