function tau = inverseDynamics(obj, q, dq, ddq, lambda, g)
    % calculates the Euler-Newton inverse dynamics
    %
    % Parameters:
    % x: joint position vector @type colvec
    % dx: joint velocity vector @type colvec
    % ddx: joint acceleration vector @type colvec
    % lambda: lagrangian multiplier @type struct
    % g: the gravity vector @type colvec
    %
    % Return values:
    % tau: the joint torques @type colvec
    
    
    if nargin < 5
        lambda = struct;
    end
    
    if nargin < 6
        g = obj.g;
    end
    
    nDof = obj.Dimension;
    V0 = zeros(6,1);
    dV0 = [g;0;0;0];
    V = zeros(6,nDof);
    dV = zeros(6,nDof);
    Vm = V;
    dVm = dV;
    T_i = cell(nDof,1);
    Adj_i = cell(nDof,1);
    adV_i = cell(nDof,1);
    adVm_i = cell(nDof,1);
    % compute body twists
    for i=1:nDof
        
        idx = obj.JointIndices(i);        
        if i==1
            v_p = V0;
            dv_p = dV0;
        else
            v_p = V(:,obj.Joints(idx).ChainIndices(end-1));
            dv_p = dV(:,obj.Joints(idx).ChainIndices(end-1));
        end
        
        B_i = obj.Joints(idx).TwistAxis;
        M_i = obj.Joints(idx).Tinv;
        T_i{idx} = twist_exp_mex(-B_i,q(idx)) * M_i;
        Adj_i{idx} = rigid_adjoint_mex(T_i{idx});
        V(:,idx) = Adj_i{idx} * v_p + B_i*dq(idx);
        adV_i{idx} = adV_mex(V(:,idx));
        dV(:,idx) = Adj_i{idx} * dv_p + ...
             adV_i{idx} * (B_i*dq(idx)) + B_i*ddq(idx);
        
        if ~isempty(obj.Joints(idx).Actuator)
            actuator = obj.Joints(idx).Actuator;
            if ~isempty(obj.Joints(idx).Actuator)
                Vm(:,idx) = B_i*actuator.GearRatio*dq(idx); 
                adVm_i{idx} = adV_mex(Vm(:,idx)) ;
                dVm(:,idx) = adVm_i{idx} * Vm(:,idx) + B_i*actuator.GearRatio*ddq(idx);
            end
        end
    end
    F = zeros(6,nDof);
    for i=nDof:-1:1
        idx = obj.JointIndices(i); 
        F(:,idx) = obj.Joints(idx).G * dV(:,idx) - transpose(adV_i{idx}) * (obj.Joints(idx).G * V(:,idx));
        
        for c_idx = obj.Joints(idx).ChildJointIndices
            F(:,idx) = F(:,idx) + transpose(Adj_i{c_idx}) * F(:,c_idx);
            B_c = obj.Joints(c_idx).TwistAxis;
            if ~isempty(obj.Joints(c_idx).Actuator)
                F(:,c_idx) = F(:,c_idx) + ...
                    B_c.*((obj.Joints(c_idx).Actuator.GearRatio)*(obj.Joints(c_idx).Gm * dVm(:,c_idx) - transpose(adVm_i{c_idx}) * (obj.Joints(c_idx).Gm * Vm(:,c_idx))));
                
            end
        end
        
    end

    
    tau = zeros(nDof,1);
    for idx=1:nDof
        tau(idx) = transpose(obj.Joints(idx).TwistAxis)*F(:,idx);
    end

    
    if ~isempty(lambda)
        Gv = zeros(obj.Dimension,1);
        l_fields = fieldnames(lambda);
        for l_idx = 1:numel(l_fields)
            input = obj.Inputs.(l_fields{l_idx});
            Gmap = feval(input.Gmap.Name,q);
            Gv = Gv + Gmap*lambda.(l_fields{l_idx});
        end
        
        tau = tau - Gv;
    end
    

    


end

