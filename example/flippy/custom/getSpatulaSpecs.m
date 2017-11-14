function spatula = getSpatulaSpecs()
    


    spatula.length = 0.127; % this is the width
    spatula.width = 0.06; % this is the length
    
    % remember to recompile if these are modified
    spatula.Offset  = [-0.014 0.0 0.208]; % offset position w.r.t. joint
    spatula.R       = [0,-2 * pi/3,-23*pi/180]; % offset orientation w.r.t. joint orientation
    
    
end