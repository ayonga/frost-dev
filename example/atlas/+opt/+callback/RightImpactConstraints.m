function RightImpactConstraints(nlp, bounds)
    plant = nlp.Plant;
    
    % no need to be time-continuous
    if ~isempty(find(ismember(nlp.ConstrTable.Properties.VariableNames,'tContDomain'), 1))
        removeConstraint(nlp,'tContDomain');
    end  
    
    nlp.updateConstrProp(['xPlusCont_',plant.Name],1,'lb',[-inf(3,1);zeros(15,1)],'ub',[inf(3,1);zeros(15,1)]);
end
