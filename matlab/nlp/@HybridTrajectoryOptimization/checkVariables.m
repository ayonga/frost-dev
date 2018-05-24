function checkVariables(obj, x, tol, output_file)
    % Check the violation of the constraints 
    
    
    if nargin < 3
        tol = 1e-3;
    end
    
    if ~iscolumn(x)
        x = x.';
    end
    
    phase = obj.Phase;
    %     phase_var_indices = obj.PhaseVarIndices;
    n_phase = length(phase);
    permission = 'w';
    for i=1:n_phase
        if i > 1
            permission = 'a';
        end
        
        
        %         var = x(phase_var_indices(i,1):phase_var_indices(i,2));
        if nargin > 3
            checkVariables(phase(i), x, tol, output_file, permission);
        else
            checkVariables(phase(i), x, tol);
        end
        
        
    end
    

end