function obj = updateConstraintBounds(obj, bounds, varargin)
    % This function updates the boundary conditions of the custom
    % optimization constraints
    %
    %
    % Parameters:
    %  bounds: a structed data stores the boundary information of the
    %  NLP variables @type struct
    
   
    plant = obj.Plant;
    if ~isempty(plant.UserNlpConstraint)
        plant.UserNlpConstraint(obj, bounds, varargin{:});
    end
    
    
    
end
