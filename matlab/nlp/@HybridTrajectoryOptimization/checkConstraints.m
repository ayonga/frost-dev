function [yc, cl, cu] = checkConstraints(obj, x, tol, output_file)
    % Check the violation of the constraints 
    
    if nargin < 3
        tol = 1e-3;
    end
    
    if ~iscolumn(x)
        x = x.';
    end
    
    phase = obj.Phase;
    % phase_var_indices = obj.PhaseVarIndices;
    n_phase = length(phase);
    yc = cell(n_phase,1);
    cl = cell(n_phase,1);
    cu = cell(n_phase,1);
    permission = 'w';
    for i=1:n_phase
        if i > 1
            permission = 'a';
        end
        
        
        % var = x(phase_var_indices(i,1):phase_var_indices(i,2));
        if nargin > 3
            [yc{i}, cl{i}, cu{i}] = checkConstraints(phase(i), x, tol, output_file, permission);
        else
            [yc{i}, cl{i}, cu{i}] = checkConstraints(phase(i), x, tol);
        end
        
        
    end

end