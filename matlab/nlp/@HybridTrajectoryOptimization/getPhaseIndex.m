function phase_idx = getPhaseIndex(obj, phase)
    % Returns the index of a particular phase specified by input argument
    % ''phase''.
    %
    
    if isnumeric(phase)
        phase_idx = phase;
    elseif iscellstr(phase)
        phase_idx = findnode(obj.Plant.Gamma, phase);
    elseif ischar(phase)
        phase_idx = findnode(obj.Plant.Gamma, phase);
    elseif isempty(phase)
        phase_idx = 1:length(obj.Phase);
    end

end