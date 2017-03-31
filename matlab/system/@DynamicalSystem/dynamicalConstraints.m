function ret = dynamicalConstraints(obj)
    % This function will return the symbolic expression (SynNlpFunction) of
    % the system dynamical equation constraints for the dynamical system object.
    %
    % @note We return a group of symbolic vector expressions -M(x)*dx,
    % f(x), g(x)*u, G(x)*F, such that -M(x)*dx + f_1(x) + f_2(x) + ... +
    % f_n(x) + g(x)*u + G(x)*F = 0
    %
    % Return values:
    %  ret: a list of symbolic function objects @type varargout
    
    
    if isa(obj,'SecondOrderSystem')
        second_order_system = true;
    else
        second_order_system = false;
    end
            
    
    
    
    %% -M(x)*dx (-M(x)*ddx for 2nd order system)
    if ~isfield(obj.TrajOptFuncs.Dynamics, 'mass_matrix')
        M = obj.DynamicsEqn.M;
        
        if second_order_system
            ddx = obj.States.ddx;
            if isempty(M)
                fx = SymFunction(['mass_ddx_' obj.Name],-ddx,{ddx});
            else
                x = obj.States.x;
                fx = SymFunction(['mass_ddx_' obj.Name],-M*ddx,{x,ddx});
            end
        else
            dx = obj.States.dx;
            if isempty(M)
                fx = SymFunction(['mass_ddx_' obj.Name],-dx,{dx});
            else
                x = obj.States.x;
                fx = SymFunction(['mass_dx_' obj.Name],-M*dx,{x,dx});
            end
        end
        obj.TrajOptFuncs.Dynamics.('mass_matrix') = fx;
        
    end
    
    %% vector fields f(x)
    num_fx = numel(obj.DynamicsEqn.vf);
    for i=1:num_fx
        vf = obj.DynamicsEqn.vf{i};
        x = obj.States.x;
        dx = obj.States.dx;
        if ~isfield(obj.TrajOptFuncs.Dynamics, vf.Name)
            fx = SymFunction([vf.Name '_' obj.Name],vf,{x,dx});
            obj.TrajOptFuncs.Dynamics.(vf.Name) = fx;
        end
    end
       
     
    %% vector field g(x)*u
    if obj.numControl > 0
        x = obj.States.x;
        u  = obj.Inputs.u;
        gf = obj.DynamicsEqn.gf;
        if ~isfield(obj.TrajOptFuncs.Dynamics, 'control_input')
            fx = SymFunction(['control_input_' obj.Name],gf*u,{x, u});
            obj.TrajOptFuncs.Dynamics.('control_input') = fx;
        end
    end
    
    %% vector field G(x)*F
    if obj.numExternal > 0
        x = obj.States.x;
        f  = obj.Inputs.f;
        G = obj.DynamicsEqn.G;
        if ~isfield(obj.TrajOptFuncs.Dynamics, 'external_input')
            fx = SymFunction(['external_input_' obj.Name],G*f,{x, f});
            obj.TrajOptFuncs.Dynamics.('external_input') = fx;
        end
    end
    
    ret = obj.TrajOptFuncs.Dynamics;
end