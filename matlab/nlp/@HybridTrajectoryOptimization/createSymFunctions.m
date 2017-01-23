function obj = createSymFunctions(obj)
    % This function creates symbolic functions for the hybrid trajectory
    % optimization problem. 
    %
    % @note This function will only creates mandatory constraints
    % functions. To create user-defined constraints or cost function, it is
    % suggested to write your own function for the purpose.
    %
    % @note This function should be called first by the overloaded method
    % in any inherited classed, if any.
    
    
    model = obj.Model;
    
    
    % natrual dynamics of the rigid body model
    De_ddq = SymFunction('Name', 'inertia_vec', ...
        'Expression', 'De.ddQe');
    De_ddq = setDepSymbols(De_ddq, {'Qe', 'dQe', 'ddQe'});
    De_ddq = setPreCommands(De_ddq, 'Qe = GetQe[]; dQe = D[Qe, t]; ddQe = D[dQe, t];');
    De_ddq = setDescription(De_ddq, 'Inertia matrix times joint acceleration: De(q)*ddq)');
    obj.FuncObjects.Model.De_ddq = De_ddq;
    
    
    Ce = SymFunction('Name', 'coriolis_vec', ...
        'Expression', 'Ce');
    Ce = setDepSymbols(Ce, {'Qe', 'dQe'});
    Ce = setPreCommands(Ce, 'Qe = GetQe[]; dQe = D[Qe, t];');
    Ce = setDescription(Ce, 'Coriolis vector: Ce(q,dq)');
    obj.FuncObjects.Model.Ce = Ce;
    
    Ge = SymFunction('Name', 'gravity_vec', ...
        'Expression', 'Ge');
    Ge = setDepSymbols(Ge, {'Qe'});
    Ge = setPreCommands(Ge, 'Qe = GetQe[];');
    Ge = setDescription(Ge, 'Gravity vector: G(q)');
    obj.FuncObjects.Model.Ge = Ge;
    
    
    num_phase = length(obj.Phase);
    
    for i = 1:num_phase
        phase = obj.Phase{i};
        domain = phase.Domain;
        guard = phase.Guard;
        
        % control dynamics
        control = SymFunction('Name', ['controlDynamics_',domain.Name]);
        control = setPreCommands(control, ...
            ['Qe = GetQe[];',...
            'U = Vec[Table[u[i],{i,',num2str(size(domain.ActuationMap,2)),'}]];',...
            'Fe = Vec[Table[f[i],{i,',num2str(getDimension(domain.HolonomicConstr)),'}]];',...
            'Be = ',mat2math(domain.ActuationMap),';',...
            ]);
        control = setExpression(control, ...
            ['-Be.U - Transpose[',domain.HolonomicConstr.Symbols.Jac,'].Fe']);
        control = setDepSymbols(control, {'Qe','U', 'Fe'});
        phase_funcs.control = control;
        
        
        % holonomic constraints
        
        % guard condition
        
        % outputs
        
        % collocation
        
        % reset map
        
        % parameter consistency
        
        % ZMP 
        
        % cost function
        
        
        obj.FuncObjects.Phase{i} = phase_funcs;
    end
    
end