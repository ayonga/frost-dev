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
    
    
    
    assert(isstruct(bounds), ...
        'The second argument must be a struct specifies the setup of the problem.');
            
            
    % configure NLP decision variables
    if isnan(obj.Options.ConstantTimeHorizon)
        % add time as decision variables if the problem does not
        % use constant time horizon
        obj.addTimeVariable(bounds.time);
    end
    
    % states as the decision variables
    obj.addStateVariable(bounds.states);
    
    if ~isempty(obj.Plant.Inputs)
        obj.addInputVariable(bounds.inputs);
    end
    
    if ~isempty(obj.Plant.Params)
        obj.addParamVariable(bounds.params);
    end
end