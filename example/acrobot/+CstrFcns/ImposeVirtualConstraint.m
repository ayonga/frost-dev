function nlp = ImposeVirtualConstraint(nlp, bounds)
    
    plant = nlp.Plant;
    
    
    % relative degree 2 outputs
    plant.VirtualConstraints.joints.imposeNLPConstraint(nlp, [bounds.gain.kp,bounds.gain.kd], [1,1]);
    
    T  = SymVariable('t',[2, 1]);
    field_names = fieldnames(plant.VirtualConstraints);
    for i = 1:length(field_names)
        p_name = plant.VirtualConstraints.(field_names{i}).PhaseParamName;
        p = {SymVariable(tomatrix(plant.VirtualConstraints.(field_names{i}).PhaseParams(:)))};
        tau_0 = SymFunction(['tau_0_',p_name,'_',plant.Name], T(1) - p{1}(1), [{T},p]);
        tau_F = SymFunction(['tau_F_',p_name,'_',plant.Name], T(2) - p{1}(2), [{T},p]);
        addNodeConstraint(nlp, tau_0, [{'T'},p_name], 'first', 0, 0, 'Nonlinear');
        addNodeConstraint(nlp, tau_F, [{'T'},p_name], 'last', 0, 0, 'Nonlinear');
    end

end