function virtual_constraints(nlp, bounds, load_path)
    %VIRTUAL_CONSTRAINTS Summary of this function goes here
    %   Detailed explanation goes here
    
    if nargin < 3
        load_path = [];
    end
    
    % relative degree 2 outputs
    domain = nlp.Plant;
    x = domain.States.x;
    
    T  = SymVariable('t',[2, 1]);
    field_names = fieldnames(domain.VirtualConstraints);
    for i = 1:length(field_names)
        
        if bounds.options.enforceVirtualConstraints
            domain.VirtualConstraints.(field_names{i}).imposeNLPConstraint(nlp, [bounds.gains.kp,bounds.gains.kd], [1,1], load_path);
        end
        
        p_name = domain.VirtualConstraints.(field_names{i}).PhaseParamName;
        p = domain.VirtualConstraints.(field_names{i}).PhaseParams;
        %         p = {SymVariable(tomatrix(domain.VirtualConstraints.(field_names{i}).PhaseParams(:)))};
        tau = SymFunction(['tau_',p_name,'_',domain.Name], T - p, {T,p});
        %         tau_F = SymFunction(['tau_F_',p_name,'_',domain.Name], T(2) - p{1}(2), [{T},p]);
        addNodeConstraint(nlp, 'first', tau, [{'T'},p_name], 0, 0);
%         addNodeConstraint(nlp, tau_F, [{'T'},p_name], 'last', 0, 0, 'Nonlinear');
    end
    
end

