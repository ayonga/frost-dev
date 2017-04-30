function checkVariables(obj, x, output_file)
    % Check the violation of the constraints 
    
    
    
    phase = obj.Phase;
    phase_var_indices = obj.PhaseVarIndices;
    n_phase = length(phase);
    permission = 'w';
    for i=1:n_phase
        if i > 1
            permission = 'a';
        end
        
        
        var = x(phase_var_indices(i,1):phase_var_indices(i,2));
        if nargin > 2
            checkVariables(phase(i), var, output_file, permission);
        else
            checkVariables(phase(i), var);
        end
        
        
    end
    

end