function [nlp] = updateVariableBounds(nlp, bounds)
    nlp.updateVariableBounds(bounds);
    
    
    nlp.Phase(1).Plant.UserNlpConstraint(nlp.Phase(1),bounds.RightStance1);
    nlp.Phase(3).Plant.UserNlpConstraint(nlp.Phase(3),bounds.LeftStance1);
    nlp.Phase(5).Plant.UserNlpConstraint(nlp.Phase(5),bounds.RightStance2);
    nlp.Phase(7).Plant.UserNlpConstraint(nlp.Phase(7),bounds.LeftStance2);  
    
    
    nlp.update();
end
