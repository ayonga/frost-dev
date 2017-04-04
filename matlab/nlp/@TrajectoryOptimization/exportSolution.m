function [tspan, states, inputs, params] = exportSolution(obj, sol, t0)
    % Analyzes the solution of the NLP problem
    %
    % Parameters:
    % sol: The solution vector of the NLP problem @type colvec
    % t0: the initial time @type double
    %
    % Return values:
    % tspan: the time span of the trajectory @type rowvec
    % states: the state trajectories @type struct
    % inputs: the input variable trajectories @type struct
    % params: the parameter variables @type struct
    
    
    if nargin < 3
        t0 = 0;
    end
    
    states = struct();
    inputs = struct();
    params = struct();
    
    vars = obj.OptVarTable;
    
    if isnan(obj.Options.ConstantTimeHorizon)
        T = sol(vars.T(1).Indices);
    else
        T = obj.Options.ConstantTimeHorizon;
    end
    
    switch obj.Options.CollocationScheme
        case 'HermiteSimpson'
            tspan = t0:T/(obj.NumNode-1):(t0+T);
        case 'Trapezoidal'
            tspan = t0:T/(obj.NumNode-1):(t0+T);
        case 'PseudoSpectral'
        otherwise
            error('Undefined integration scheme.');
    end
    
    plant = obj.Plant;
    state_names = fieldnames(plant.States);
    for j=1:length(state_names)        
        name = state_names{j};
        
        states.(name) = sol([vars.(name).Indices]);
    end
    
    input_names = fieldnames(plant.Inputs);
    if ~isempty(input_names)        
        for j=1:length(input_names)
            name = input_names{j};            
            inputs.(name) = sol([vars.(name).Indices]);
        end
    end
    
    
    
    param_names = fieldnames(plant.Params);
    if ~isempty(param_names)        
        for j=1:length(param_names)
            name = param_names{j};            
            params.(name) = sol([vars.(name)(1).Indices]);
        end
    end
            
    
    
    
    
end