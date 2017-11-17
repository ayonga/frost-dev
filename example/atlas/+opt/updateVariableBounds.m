function [nlp] = updateVariableBounds(nlp, bounds)
    nlp.updateVariableBounds(bounds);
    
    
    nlp.Phase(1).Plant.UserNlpConstraint(nlp.Phase(1),bounds.RightStance);
    nlp.Phase(3).Plant.UserNlpConstraint(nlp.Phase(3),bounds.LeftStance);
    
    nlp.update();
end
