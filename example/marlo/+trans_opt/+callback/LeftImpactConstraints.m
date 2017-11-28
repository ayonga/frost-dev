function LeftImpactConstraints(nlp, src, tar, bounds, varargin)
    plant = nlp.Plant;
    
    % no need to be time-continuous
    removeConstraint(nlp,'tContDomain');
    
    % first call the class method (calling impact model since it no longer
    % applies if we have a custom function)
    plant.rigidImpactConstraint(nlp, src, tar, bounds, varargin{:});
    
    
end
