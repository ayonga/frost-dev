function [yc] = checkCosts(obj, x, output_file)
    % Check the value of const function 
    
    if ~iscolumn(x)
        x = x.';
    end
    
    phase = obj.Phase;
    %     phase_var_indices = obj.PhaseVarIndices;
    n_phase = length(phase);
    yc = cell(n_phase,1);
    permission = 'w';
    for i=1:n_phase
        if i > 1
            permission = 'a';
        end
        
        
        %         var = x(phase_var_indices(i,1):phase_var_indices(i,2));
        if nargin > 2
            [yc{i}] = checkCosts(phase(i), x, output_file, permission);
        else
            [yc{i}] = checkCosts(phase(i), x);
        end
        
        
    end
end