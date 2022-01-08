function obj = updateConstraintBounds(obj, varargin)
    % This function updates the boundary conditions of the custom
    % optimization constraints
    %
    %
    % Parameters:
    %  bounds: a structed data stores the boundary information of the
    %  NLP variables @type struct
    
   
    plant = obj.Plant;
    
    inputs = plant.Inputs;
    input_names = fieldnames(inputs);
    n_input = length(input_names);
    if n_input > 0
        for i=1:n_input
            input_name = input_names{i};
            input = inputs.(input_name);
            if ~isempty(input.CustomNLPConstraint)
                input.CustomNLPConstraint(input, obj, bounds, varargin{:});
            end
        end
    end
    % impose the system specific constraints (such as holonomic
    % constraints and unilateral constraints)
    if ~isempty(plant.CustomNLPConstraint)
        plant.CustomNLPConstraint(obj, bounds, varargin{:});
    end
    
end
