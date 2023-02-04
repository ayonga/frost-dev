function LeftImpactConstraints(nlp, bounds)
%     plant = nlp.Plant;
    
    % no need to be time-continuous
    if ~isempty(find(ismember(nlp.ConstrTable.Properties.VariableNames,'tContDomain'), 1))
        removeConstraint(nlp,'tContDomain');
    end  
    
    % first call the class method (calling impact model since it no longer
    % applies if we have a custom function)
    %     plant.rigidImpactConstraint(nlp, src, tar, bounds, varargin{:});
    
    
end
