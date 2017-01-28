function phase_idx = getPhaseIndex(obj, phase)
    % Returns the index of a particular phase specified by input argument
    % ''phase''.
    
    
    
    
    if isnumeric(phase)
        assert(isscalar(phase), 'Expected scalar number.');
        phase_idx = phase;
    elseif iscellstr(phase)
        assert(isscalar(phase), 'Expected scalar cell string.');
        phase_idx = findnode(obj.Gamma, phase);
    elseif ischar(phase)
        phase_idx = findnode(obj.Gamma, phase);
    else
        error('The phase must be specified by the name or the index number.');
    end

end