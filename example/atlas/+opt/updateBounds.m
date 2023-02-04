function [nlp] = updateBounds(nlp, bounds, varargin)
    nlp.updateVariableBounds(bounds);
    
    nlp.updateConstraintBounds(bounds, varargin{:});
    
    nlp.update();
end
