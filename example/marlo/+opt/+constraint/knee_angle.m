function knee_angle(nlp, bounds)
    % constraints for step length and step width
    
    domain = nlp.Plant;
    x = domain.States.x;
    
    % knee angle
    knee = [x('qBRight') - x('qARight')
        x('qBLeft') - x('qALeft')];
    knee_fun = SymFunction(['kneeAngles_',domain.Name], knee, {x});
    addNodeConstraint(nlp, knee_fun, {'x'}, 'all', ...
        bounds.constrBounds.knee.lb, ...
        bounds.constrBounds.knee.ub,'Linear');
    
end

