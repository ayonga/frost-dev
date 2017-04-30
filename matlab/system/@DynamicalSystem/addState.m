function obj = addState(obj, varargin)
    % Add state variables of the dynamical system
    %
    % Parameters:
    %  varargin: the name-value pairs (or struct) of the system
    %  parameters
    
    states = struct(varargin{:});
    state_names = fieldnames(states);
    state_vars = struct2cell(states);
    n_state = length(state_vars{1});
    
    % validate the state variables
    for i=1:numel(state_names)
        validateStates(state_vars{i},state_names{i},n_state);
    end
    
    
    
    for i=1:length(state_names)
        x = state_names{i};
        
        if isfield(obj.States, x)
            error('The states (%s) has been already defined.\n',x);
        else
            obj.States.(x) = states.(x);
            
            obj.states_.(x) = nan(n_state,1);
        end
    end
    
    
    obj.numState = n_state;
    
    
    function validateStates(x,var_name,n_state)
        validateattributes(x,{'SymVariable'},...
            {'size', [n_state,1]},...
            'DynamicalSystem.addState',var_name);
        
        assert(isempty(regexp(var_name, '\W', 'once')) || ~isempty(regexp(var_name, '\$', 'once')),...
            'Invalid symbol string, can NOT contain special characters.');
        
        assert(isempty(regexp(var_name, '_', 'once')),...
            'Invalid symbol string, can NOT contain ''_''.');
        
        assert(~isempty(regexp(var_name, '^[a-z]\w*', 'match')),...
            'First letter must be lowercase character.');
    end
end
