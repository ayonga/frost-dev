function [tspan, states, inputs, params] = exportSolution(obj, sol)
    % Analyzes the solution of the NLP problem
    %
    % Parameters:
    % sol: The solution vector of the NLP problem @type colvec
    
    phase = obj.Phase;
    % phase_var_indices = obj.PhaseVarIndices;
    n_phase = length(phase);
    
    tspan = cell(n_phase,1);
    states = cell(n_phase,1);
    inputs = cell(n_phase,1);
    params = cell(n_phase,1);
    
    
    for i = 1:n_phase
        % sol_i = sol(phase_var_indices(i,1):phase_var_indices(i,2));
        [tspan{i}, states{i}, inputs{i}, params{i}] = exportSolution(phase(i), sol);
    end
end