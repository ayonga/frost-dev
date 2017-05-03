function obj = configureVariables(obj, bounds)
    % This function configures the structure of the optimization variable
    % by adding (registering) them to the optimization variable table.
    %
    % A particular project might inherit the class and overload this
    % function to achieve custom configuration of the optimization
    % variables
    %
    % Parameters:
    %  bounds: a structed data stores the boundary information of the
    %  NLP variables @type struct
    
    
    
    % validate the input argument
    validateattributes(bounds,{'struct'},{},...
        'TrajectoryOptimization','bounds');
            
            
    %% configure NLP decision variables
    if any(isnan(obj.Options.ConstantTimeHorizon)) && obj.NumNode ~= 1
        % add time as decision variables if the problem does not
        % use constant time horizon
        if ~isfield(bounds,'time')
            warning('No boundary value for time variables defined.')
            time = struct();
        else
            time = bounds.time;
        end
        obj.addTimeVariable(time);
    end
    
    % states as the decision variables
    if ~isfield(bounds,'states')
        warning('No boundary value for state variables defined.')
        states = struct();
    else
        states = bounds.states;
    end
    obj.addStateVariable(states);
    
    % inputs as the decision variables
    if ~isfield(bounds,'inputs')
        warning('No boundary value for input variables defined.')
        inputs = struct();
    else
        inputs = bounds.inputs;
    end
    obj.addInputVariable(inputs);
    
    % parameters as the decision variables
    if ~isempty(fieldnames(obj.Plant.Params))
        if ~isfield(bounds,'params')
            warning('No boundary value for parameters defined.')
            params = struct();
        else
            params = bounds.params;
        end
        obj.addParamVariable(params);
    end
end